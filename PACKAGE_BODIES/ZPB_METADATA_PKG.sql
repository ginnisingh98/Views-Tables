--------------------------------------------------------
--  DDL for Package Body ZPB_METADATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_METADATA_PKG" as
/* $Header: ZPBMDPKB.pls 120.31 2007/12/04 14:35:35 mbhat noship $ */

  G_PKG_NAME CONSTANT VARCHAR2(16) := 'ZPB_METADATA_PKG';

-------------------------------------------------------------------------------
--  insertDimensionRecord - Private function that inserts a
--                      zpb_md_records.dimensions_entry into zpb_dimensions and
--                                          returns the primary key of the newly created entry
--
--              if p_primary_key_provided is true, then the primary key for the
--                      dimension to be inserted is provided and we do not select it from sequence
-------------------------------------------------------------------------------
function insertDimensionRecord(p_dimension_rec in zpb_md_records.DIMENSIONS_ENTRY,
                                                       p_primary_key_provided in boolean default false)
        return number is

                l_dimension_rec         zpb_md_records.dimensions_entry;
                bus_area_id_num         number;
                insert_flag                     boolean;
begin

        l_dimension_rec := p_dimension_rec;

        bus_area_id_num := sys_context('ZPB_CONTEXT', 'business_area_id');
        insert_flag := p_primary_key_provided;

        if insert_flag = false then

                begin

                        select dimension_id into l_dimension_rec.DimensionId
                         from  zpb_dimensions
                         where bus_area_id = bus_area_id_num and
                                   epb_id = l_dimension_rec.EpbId;

                        update zpb_dimensions
                        set
 AW_NAME                        =       l_dimension_rec.AwName,
 DEFAULT_HIER           =       l_dimension_rec.DefaultHier,
 DEFAULT_MEMBER         =       l_dimension_rec.DefaultMember,
 DIM_CODE                       =       l_dimension_rec.DimCode,
 DIM_TYPE                       =       l_dimension_rec.DimType,
 IS_CURRENCY_DIM        =       l_dimension_rec.IsCurrencyDim,
 IS_DATA_DIM            =       l_dimension_rec.IsDataDim,
 IS_OWNER_DIM           =       l_dimension_rec.IsOwnerDim,
 PERS_CWM_NAME          =       l_dimension_rec.PersCWMName,
 PERS_TABLE_ID          =       l_dimension_rec.PersTableId,
 SHAR_CWM_NAME          =       l_dimension_rec.SharCWMName,
 SHAR_TABLE_ID          =       l_dimension_rec.SharTableId,
 ANNOTATION_DIM         =       l_dimension_rec.AnnotationDim,
 CREATED_BY                     =       FND_GLOBAL.USER_ID,
 CREATION_DATE          =       sysdate,
 LAST_UPDATED_BY        =       FND_GLOBAL.USER_ID,
 LAST_UPDATE_DATE       =       sysdate,
 LAST_UPDATE_LOGIN      =       FND_GLOBAL.LOGIN_ID

                        where dimension_id = l_dimension_rec.DimensionId;


                exception
                        when NO_DATA_FOUND then
                        SELECT zpb_dimensions_seq.NEXTVAL INTO l_dimension_rec.DimensionId FROM DUAL;
                        insert_flag := true;
                end;
        end if;

        if insert_flag=true then

                insert into zpb_dimensions
                        (
 AW_NAME,
 BUS_AREA_ID,
 DEFAULT_HIER,
 DEFAULT_MEMBER,
 DIMENSION_ID,
 DIM_CODE,
 DIM_TYPE,
 EPB_ID,
 IS_CURRENCY_DIM,
 IS_DATA_DIM,
 IS_OWNER_DIM,
 PERS_CWM_NAME,
 PERS_TABLE_ID,
 SHAR_CWM_NAME,
 SHAR_TABLE_ID,
 ANNOTATION_DIM,
 CREATED_BY,
 CREATION_DATE,
 LAST_UPDATED_BY,
 LAST_UPDATE_DATE,
 LAST_UPDATE_LOGIN
)
VALUES
(
l_dimension_rec.AwName,
bus_area_id_num,
l_dimension_rec.DefaultHier,
l_dimension_rec.DefaultMember,
l_dimension_rec.DimensionId,
l_dimension_rec.DimCode,
l_dimension_rec.DimType,
l_dimension_rec.EpbId,
l_dimension_rec.IsCurrencyDim,
l_dimension_rec.IsDataDim,
l_dimension_rec.IsOwnerDim,
l_dimension_rec.PersCWMName,
l_dimension_rec.PersTableId,
l_dimension_rec.SharCWMName,
l_dimension_rec.SharTableId,
l_dimension_rec.AnnotationDim,
FND_GLOBAL.USER_ID,
sysdate,
FND_GLOBAL.USER_ID,
sysdate,
FND_GLOBAL.LOGIN_ID
);

        end if;

        return l_dimension_rec.DimensionId;
end insertDimensionRecord;

-------------------------------------------------------------------------------
--  insertTableRecord - Private function that inserts a
--                      zpb_md_records.tables_entry into zpb_tables and
--                                          returns the primary key of the newly created entry
--
--              if p_primary_key_provided is true, then the primary key for the
--                      table to be inserted is provided and we do not select it from sequence
-------------------------------------------------------------------------------
function insertTableRecord(p_table_rec in zpb_md_records.TABLES_ENTRY,
                                                   p_primary_key_provided in boolean default false)
        return number is
                l_table_rec             zpb_md_records.tables_entry;
                bus_area_id_num         number;
                insert_flag                     boolean;

begin

        l_table_rec := p_table_rec;
        bus_area_id_num := sys_context('ZPB_CONTEXT', 'business_area_id');
        insert_flag := p_primary_key_provided;

        if p_primary_key_provided = false then

                begin

                select table_id into l_table_rec.TableId
                from zpb_tables
                where bus_area_id = bus_area_id_num and
                          table_name = l_table_rec.TableName;

                update zpb_tables
                set
 AW_NAME                        =        l_table_rec.AwName,
 TABLE_TYPE                     =        l_table_rec.TableType,
 CREATED_BY                     =        FND_GLOBAL.USER_ID,
 CREATION_DATE          =        sysdate,
 LAST_UPDATED_BY        =        FND_GLOBAL.USER_ID,
 LAST_UPDATE_DATE       =        sysdate,
 LAST_UPDATE_LOGIN      =        FND_GLOBAL.LOGIN_ID
                where table_id = l_table_rec.TableId;

                exception
                        when NO_DATA_FOUND then
                        SELECT zpb_tables_seq.NEXTVAL INTO l_table_rec.TableId FROM DUAL;
                        insert_flag := true;
                end;
        end if;

if insert_flag = true then

insert into zpb_tables
        (
 AW_NAME,
 BUS_AREA_ID,
 TABLE_ID,
 TABLE_NAME,
 TABLE_TYPE,
 CREATED_BY,
 CREATION_DATE,
 LAST_UPDATED_BY,
 LAST_UPDATE_DATE,
 LAST_UPDATE_LOGIN
)
VALUES
(
 l_table_rec.AwName,
 bus_area_id_num,
 l_table_rec.TableId,
 l_table_rec.TableName,
 l_table_rec.TableType,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.LOGIN_ID
);

end if;

  return l_table_rec.TableId;
end insertTableRecord;


-------------------------------------------------------------------------------
--  insertColumnRecord - Private function that inserts a
--                      zpb_md_records.columns_entry into zpb_columns and
--                                          returns the primary key of the newly created entry
-------------------------------------------------------------------------------
function insertColumnRecord(p_col_rec in zpb_md_records.columns_entry)
        return number is
                l_col_rec                       zpb_md_records.columns_entry;
                bus_area_id_num         number;

begin

        l_col_rec := p_col_rec;

        begin

                select column_id into l_col_rec.ColumnId
                from zpb_columns
                where table_id = l_col_rec.TableId and
                          column_name = l_col_rec.ColumnName;

                update zpb_columns
                set
 AW_NAME                        =        l_col_rec.AwName,
 COLUMN_NAME            =        l_col_rec.ColumnName,
 COLUMN_TYPE            =        l_col_rec.ColumnType,
 TABLE_ID                       =        l_col_rec.TableId,
 CREATED_BY                     =        FND_GLOBAL.USER_ID,
 CREATION_DATE          =        sysdate,
 LAST_UPDATED_BY        =        FND_GLOBAL.USER_ID,
 LAST_UPDATE_DATE       =        sysdate,
 LAST_UPDATE_LOGIN      =        FND_GLOBAL.LOGIN_ID
                where column_id = l_col_rec.ColumnId;


                exception
                        when NO_DATA_FOUND then
                        SELECT zpb_columns_seq.NEXTVAL INTO l_col_rec.ColumnId FROM DUAL;

                insert into zpb_columns
(
 COLUMN_ID,
 AW_NAME,
 COLUMN_NAME,
 COLUMN_TYPE,
 TABLE_ID,
 CREATED_BY,
 CREATION_DATE,
 LAST_UPDATED_BY,
 LAST_UPDATE_DATE,
 LAST_UPDATE_LOGIN
)
VALUES
(
 l_col_rec.ColumnId,
 l_col_rec.AwName,
 l_col_rec.ColumnName,
 l_col_rec.ColumnType,
 l_col_rec.TableId,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.LOGIN_ID
);
                end;

  return l_col_rec.ColumnId;
end insertColumnRecord;

-------------------------------------------------------------------------------
--  insertLevelRecord - Private function that inserts a
--                      zpb_md_records.levels_entry into zpb_levels and
--                                          returns the primary key of the newly created entry
-------------------------------------------------------------------------------
function insertLevelRecord(p_level_rec zpb_md_records.levels_entry)
        return number is

        l_level_rec zpb_md_records.levels_entry;

begin

        l_level_rec := p_level_rec;

        begin

                select level_id into l_level_rec.LevelId
                from zpb_levels
                where dimension_id = l_level_rec.DimensionId and
                        pers_cwm_name = l_level_rec.PersCWMName;

                update zpb_levels
                set

 PERS_CWM_NAME  =        l_level_rec.PersCWMName,
 DIMENSION_ID   =        l_level_rec.DimensionId,
 EPB_ID =        l_level_rec.EpbId,
 SHAR_CWM_NAME  =        l_level_rec.SharCWMName,
 PERS_LEVEL_FLAG        =        l_level_rec.PersLevelFlag,
 CREATED_BY     =        FND_GLOBAL.USER_ID,
 CREATION_DATE  =        sysdate,
 LAST_UPDATED_BY        =        FND_GLOBAL.USER_ID,
 LAST_UPDATE_DATE       =        sysdate,
 LAST_UPDATE_LOGIN      =        FND_GLOBAL.LOGIN_ID
                where level_id = l_level_rec.LevelId;

        exception
                when NO_DATA_FOUND then
                SELECT zpb_levels_seq.NEXTVAL INTO l_level_rec.LevelId FROM DUAL;

        insert into zpb_levels
(
 PERS_CWM_NAME,
 DIMENSION_ID,
 EPB_ID,
 LEVEL_ID,
 SHAR_CWM_NAME,
 PERS_LEVEL_FLAG,
 CREATED_BY,
 CREATION_DATE,
 LAST_UPDATED_BY,
 LAST_UPDATE_DATE,
 LAST_UPDATE_LOGIN
)
        VALUES
(
 l_level_rec.PersCWMName,
 l_level_rec.DimensionId,
 l_level_rec.EpbId,
 l_level_rec.LevelId,
 l_level_rec.SharCWMName,
 l_level_rec.PersLevelFlag,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.LOGIN_ID
);
                end;

        return l_level_rec.LevelId;
end insertLevelRecord;

-------------------------------------------------------------------------------
--  insertHierLevelRecord - Private function that inserts a
--                      zpb_md_records.hier_level_entry into zpb_hier_levels and
--                                          returns the primary key of the newly created entry
-------------------------------------------------------------------------------
function insertHierLevelRecord(p_hier_level_rec zpb_md_records.hier_level_entry)
        return number is

        l_hier_level_rec zpb_md_records.hier_level_entry;

begin

        l_hier_level_rec := p_hier_level_rec;

        begin

        select relation_id into l_hier_level_rec.RelationId
        from   zpb_hier_level
        where  level_id = l_hier_level_rec.LevelId and
                   hier_id = l_hier_level_rec.HierId;

        update zpb_hier_level
        set

 LEVEL_ORDER            =        l_hier_level_rec.LevelOrder,
 PERS_COL_ID            =        l_hier_level_rec.PersColId,
 SHAR_COL_ID            =        l_hier_level_rec.SharColId,
 CREATED_BY                     =        FND_GLOBAL.USER_ID,
 CREATION_DATE          =        sysdate,
 LAST_UPDATED_BY        =        FND_GLOBAL.USER_ID,
 LAST_UPDATE_DATE       =        sysdate,
 LAST_UPDATE_LOGIN      =        FND_GLOBAL.LOGIN_ID
        where relation_id = l_hier_level_rec.RelationId;

        exception
        when NO_DATA_FOUND then
        SELECT zpb_hier_level_seq.NEXTVAL INTO l_hier_level_rec.RelationId FROM DUAL;

insert into zpb_hier_level
        (
 HIER_ID,
 LEVEL_ID,
 LEVEL_ORDER,
 PERS_COL_ID,
 RELATION_ID,
 SHAR_COL_ID,
 CREATED_BY,
 CREATION_DATE,
 LAST_UPDATED_BY,
 LAST_UPDATE_DATE,
 LAST_UPDATE_LOGIN
)
VALUES
        (
 l_hier_level_rec.HierId,
 l_hier_level_rec.LevelId,
 l_hier_level_rec.LevelOrder,
 l_hier_level_rec.PersColId,
 l_hier_level_rec.RelationId,
 l_hier_level_rec.SharColId,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.LOGIN_ID
);

        end;

return l_hier_level_rec.RelationId;

end insertHierLevelRecord;

-------------------------------------------------------------------------------
--  inserAttributeRecord - Private function that inserts a
--                      zpb_md_records.attributes_entry into zpb_attributes and
--                                          returns the primary key of the newly created entry
-------------------------------------------------------------------------------
function insertAttributeRecord(p_attr_rec zpb_md_records.attributes_entry)
        return number is

        l_attr_rec zpb_md_records.attributes_entry;

begin

        l_attr_rec := p_attr_rec;

        begin

                select attribute_id into l_attr_rec.AttributeId
                from zpb_attributes
                where dimension_id = l_attr_rec.DimensionId and
                          pers_cwm_name = l_attr_rec.PersCWMName;

                update zpb_attributes
                set
 DIMENSION_ID                   =        l_attr_rec.DimensionId,
 EPB_ID                 =        l_attr_rec.EpbId,
 LABEL                  =        l_attr_rec.Label,
 RANGE_DIM_ID                   =        l_attr_rec.RangeDimId,
 SHAR_CWM_NAME                  =        l_attr_rec.SharCWMName,
 TYPE                   =        l_attr_rec.Type,
 PERS_CWM_NAME                  =        l_attr_rec.PersCWMName,
 FEM_ATTRIBUTE_ID       =                l_attr_rec.FEMAttrId,
 CREATED_BY             =        FND_GLOBAL.USER_ID,
 CREATION_DATE                  =        sysdate,
 LAST_UPDATED_BY        =        FND_GLOBAL.USER_ID,
 LAST_UPDATE_DATE       =        sysdate,
 LAST_UPDATE_LOGIN      =        FND_GLOBAL.LOGIN_ID
                where attribute_id = l_attr_rec.AttributeId;

        exception
                when NO_DATA_FOUND then
                SELECT zpb_attributes_seq.NEXTVAL INTO l_attr_rec.AttributeId FROM DUAL;

insert into zpb_attributes
        (

 ATTRIBUTE_ID,
 DIMENSION_ID,
 EPB_ID,
 LABEL,
 RANGE_DIM_ID,
 SHAR_CWM_NAME,
 TYPE,
 PERS_CWM_NAME,
 FEM_ATTRIBUTE_ID,
 CREATED_BY,
 CREATION_DATE,
 LAST_UPDATED_BY,
 LAST_UPDATE_DATE,
 LAST_UPDATE_LOGIN
)
VALUES
        (
 l_attr_rec.AttributeId,
 l_attr_rec.DimensionId,
 l_attr_rec.EpbId,
 l_attr_rec.Label,
 l_attr_rec.RangeDimId,
 l_attr_rec.SharCWMName,
 l_attr_rec.Type,
 l_attr_rec.PersCWMName,
 l_attr_rec.FEMAttrId,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.LOGIN_ID
);

        end;

return l_attr_rec.AttributeId;

end insertAttributeRecord;


-------------------------------------------------------------------------------
--  insertAttrTableColRecord - Private function that inserts a
--                      zpb_md_records.attr_table_col_entry into zpb_attr_table_col and
--                                          returns the primary key of the newly created entry
-------------------------------------------------------------------------------
function insertAttrTableColRecord(p_attr_table_col_rec zpb_md_records.attr_table_col_entry)
        return number is

        l_attr_table_col_rec zpb_md_records.attr_table_col_entry;

begin

        l_attr_table_col_rec := p_attr_table_col_rec;

        begin

        select relation_id into l_attr_table_col_rec.RelationId
        from   zpb_attr_table_col
        where  attribute_id = l_attr_table_col_rec.AttributeId and
                   table_id = l_attr_table_col_rec.TableId and
                   column_id = l_attr_table_col_rec.ColumnId;

        update zpb_attr_table_col
        set

 CREATED_BY             =        FND_GLOBAL.USER_ID,
 CREATION_DATE  =        sysdate,
 LAST_UPDATED_BY        =        FND_GLOBAL.USER_ID,
 LAST_UPDATE_DATE       =        sysdate,
 LAST_UPDATE_LOGIN      =        FND_GLOBAL.LOGIN_ID
        where relation_id = l_attr_table_col_rec.RelationId;

        exception
                when NO_DATA_FOUND then
        SELECT zpb_attr_table_col_seq.NEXTVAL INTO l_attr_table_col_rec.RelationId FROM DUAL;

insert into zpb_attr_table_col
        (
 ATTRIBUTE_ID,
 COLUMN_ID,
 RELATION_ID,
 TABLE_ID,
 CREATED_BY,
 CREATION_DATE,
 LAST_UPDATED_BY,
 LAST_UPDATE_DATE,
 LAST_UPDATE_LOGIN
)
VALUES
        (
 l_attr_table_col_rec.AttributeId,
 l_attr_table_col_rec.ColumnId,
 l_attr_table_col_rec.RelationId,
 l_attr_table_col_rec.TableId,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.LOGIN_ID
);

        end;

return l_attr_table_col_rec.RelationId;

end insertAttrTableColRecord;


-------------------------------------------------------------------------------
--  insertCubeDimsRecord - Private function that inserts a
--                      zpb_md_records.cube_dims_entry into zpb_cube_dims and
--                                          returns the primary key of the newly created entry
-------------------------------------------------------------------------------
function insertCubeDimsRecord(p_cube_dims_rec zpb_md_records.cube_dims_entry)
        return number is

        l_cube_dims_rec zpb_md_records.cube_dims_entry;

begin

        l_cube_dims_rec := p_cube_dims_rec;

        begin

        select relation_id into l_cube_dims_rec.RelationId
        from zpb_cube_dims
        where cube_id = l_cube_dims_rec.CubeId and
                  dimension_id = l_cube_dims_rec.DimensionId;

        update zpb_cube_dims
        set

 COLUMN_ID                      =        l_cube_dims_rec.ColumnId,
 CREATED_BY                     =        FND_GLOBAL.USER_ID,
 CREATION_DATE          =        sysdate,
 LAST_UPDATED_BY        =        FND_GLOBAL.USER_ID,
 LAST_UPDATE_DATE       =        sysdate,
 LAST_UPDATE_LOGIN      =        FND_GLOBAL.LOGIN_ID
        where relation_id = l_cube_dims_rec.RelationId;

        exception
                when NO_DATA_FOUND then
        SELECT zpb_cube_dims_seq.NEXTVAL INTO l_cube_dims_rec.RelationId FROM DUAL;

insert into zpb_cube_dims
        (

 COLUMN_ID,
 CUBE_ID,
 DIMENSION_ID,
 RELATION_ID,
 CREATED_BY,
 CREATION_DATE,
 LAST_UPDATED_BY,
 LAST_UPDATE_DATE,
 LAST_UPDATE_LOGIN
)
VALUES
        (
 l_cube_dims_rec.ColumnId,
 l_cube_dims_rec.CubeId,
 l_cube_dims_rec.DimensionId,
 l_cube_dims_rec.RelationId,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.LOGIN_ID
);

        end;

return l_cube_dims_rec.RelationId;

end insertCubeDimsRecord;

-------------------------------------------------------------------------------
--  insertCubeHierRecord - Private function that inserts a
--                      zpb_md_records.cube_hier_entry into zpb_cube_hier and
--                                          returns the primary key of the newly created entry
-------------------------------------------------------------------------------
function insertCubeHierRecord(p_cube_hier_rec zpb_md_records.cube_hier_entry)
        return number is

        l_cube_hier_rec zpb_md_records.cube_hier_entry;

begin

        l_cube_hier_rec := p_cube_hier_rec;

        begin

        select relation_id into l_cube_hier_rec.RelationId
        from   zpb_cube_hier
        where  cube_id = l_cube_hier_rec.CubeId and
                   hierarchy_id = l_cube_hier_rec.HierarchyId;

        update zpb_cube_hier
        set

 COLUMN_ID                              =        l_cube_hier_rec.ColumnId,
 CREATED_BY                             =        FND_GLOBAL.USER_ID,
 CREATION_DATE                  =        sysdate,
 LAST_UPDATED_BY                =        FND_GLOBAL.USER_ID,
 LAST_UPDATE_DATE               =        sysdate,
 LAST_UPDATE_LOGIN              =        FND_GLOBAL.LOGIN_ID
        where relation_id =  l_cube_hier_rec.RelationId;

        exception
                when NO_DATA_FOUND then
        SELECT zpb_cube_hier_seq.NEXTVAL INTO l_cube_hier_rec.RelationId FROM DUAL;

insert into zpb_cube_hier
        (
 COLUMN_ID,
 CUBE_ID,
 HIERARCHY_ID,
 RELATION_ID,
 CREATED_BY,
 CREATION_DATE,
 LAST_UPDATED_BY,
 LAST_UPDATE_DATE,
 LAST_UPDATE_LOGIN
)
VALUES
        (
 l_cube_hier_rec.ColumnId,
 l_cube_hier_rec.CubeId,
 l_cube_hier_rec.HierarchyId,
 l_cube_hier_rec.RelationId,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.LOGIN_ID
);

        end;

return l_cube_hier_rec.RelationId;

end insertCubeHierRecord;

-------------------------------------------------------------------------------
--  insertMeasureRecord - Private function that inserts a
--                      zpb_md_records.measures_entry into zpb_measures and
--                                          returns the primary key of the newly created entry
-------------------------------------------------------------------------------
function insertMeasureRecord(p_measure_rec zpb_md_records.measures_entry)
        return number is

        l_measure_rec zpb_md_records.measures_entry;

begin

        l_measure_rec := p_measure_rec;

--      dbms_output.put_line('inserting measure: ' || l_measure_rec.CWMName || ' into cube ' || l_measure_rec.CubeId );

        begin
                select measure_id into l_measure_rec.MeasureId
                from  zpb_measures
                where cube_id = l_measure_rec.CubeId and
                          cwm_name = l_measure_rec.CWMName;

--      dbms_output.put_line('UPDATING');

                update zpb_measures
                set
 AW_NAME        =        l_measure_rec.AwName,
 COLUMN_ID      =        l_measure_rec.ColumnId,
 CURRENCY_TYPE  =        l_measure_rec.CurrencyType,
 CURR_INST_FLAG =        l_measure_rec.CurrInstFlag,
 EPB_ID =        l_measure_rec.EpbId,
 INSTANCE_ID    =        l_measure_rec.InstanceId,
 TEMPLATE_ID    =        l_measure_rec.TemplateId,
 APPROVEE_ID    =        l_measure_rec.ApproveeId,
 TYPE   =        l_measure_rec.Type,
 SELECTED_CUR   =        l_measure_rec.SelectedCur,
 NAME   =        l_measure_rec.Name,
 CURRENCY_REL =      l_measure_rec.CurrencyRel,
 CPR_MEASURE =       l_measure_rec.CPRMeasure,
 CREATED_BY     =        FND_GLOBAL.USER_ID,
 CREATION_DATE  =        sysdate,
 LAST_UPDATED_BY        =        FND_GLOBAL.USER_ID,
 LAST_UPDATE_DATE       =        sysdate,
 LAST_UPDATE_LOGIN      =        FND_GLOBAL.LOGIN_ID
                where  measure_id = l_measure_rec.MeasureId;

        exception
                when NO_DATA_FOUND then
                SELECT zpb_measures_seq.NEXTVAL INTO l_measure_rec.MeasureId FROM DUAL;

--      dbms_output.put_line('INSERTING');

insert into zpb_measures
        (
 AW_NAME,
 COLUMN_ID,
 CUBE_ID,
 CURRENCY_TYPE,
 CURR_INST_FLAG,
 CWM_NAME,
 EPB_ID,
 INSTANCE_ID,
 MEASURE_ID,
 TEMPLATE_ID,
 APPROVEE_ID,
 TYPE,
 SELECTED_CUR,
 NAME,
 CURRENCY_REL,
 CPR_MEASURE,
 CREATED_BY,
 CREATION_DATE,
 LAST_UPDATED_BY,
 LAST_UPDATE_DATE,
 LAST_UPDATE_LOGIN
)
VALUES
        (
 l_measure_rec.AwName,
 l_measure_rec.ColumnId,
 l_measure_rec.CubeId,
 l_measure_rec.CurrencyType,
 l_measure_rec.CurrInstFlag,
 l_measure_rec.CwmName,
 l_measure_rec.EpbId,
 l_measure_rec.InstanceId,
 l_measure_rec.MeasureId,
 l_measure_rec.TemplateId,
 l_measure_rec.ApproveeId,
 l_measure_rec.Type,
 l_measure_rec.SelectedCur,
 l_measure_rec.Name,
 l_measure_rec.CurrencyRel,
 l_measure_rec.CPRMeasure,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.LOGIN_ID
);
        end;

return l_measure_rec.MeasureId;

end insertMeasureRecord;

-------------------------------------------------------------------------------
--  insertAttributeTLRecord - Private procedure that inserts a
--                      zpb_md_records.attributes_tl_entry into zpb_attributes_tl
-------------------------------------------------------------------------------
procedure insertAttributesTLRecord(p_attributes_tl_rec zpb_md_records.attributes_tl_entry)
is
        l_attributes_tl_rec zpb_md_records.attributes_tl_entry;
begin

        l_attributes_tl_rec := p_attributes_tl_rec;

        delete zpb_attributes_tl
        where attribute_id = l_attributes_tl_rec.AttributeId and
                  language = l_attributes_tl_rec.Language;

insert into zpb_attributes_tl
        (
 ATTRIBUTE_ID,
 LANGUAGE,
 LONG_NAME,
 NAME,
 PLURAL_LONG_NAME,
 PLURAL_NAME,
 CREATED_BY,
 CREATION_DATE,
 LAST_UPDATED_BY,
 LAST_UPDATE_DATE,
 LAST_UPDATE_LOGIN
)
VALUES
        (
 l_attributes_tl_rec.AttributeId,
 l_attributes_tl_rec.Language,
 l_attributes_tl_rec.LongName,
 l_attributes_tl_rec.Name,
 l_attributes_tl_rec.PluralLongName,
 l_attributes_tl_rec.PluralName,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.LOGIN_ID
);

end insertAttributesTLRecord;


-------------------------------------------------------------------------------
--  insertDimensionsTLRecord - Private procedure that inserts a
--                      zpb_md_records.dimensions_tl_entry into zpb_dimensions_tl
-------------------------------------------------------------------------------
procedure insertDimensionsTLRecord(p_dimensions_tl_rec zpb_md_records.dimensions_tl_entry)
is
        l_dimensions_tl_rec zpb_md_records.dimensions_tl_entry;
begin

        l_dimensions_tl_rec := p_dimensions_tl_rec;

        delete zpb_dimensions_tl
        where dimension_id = l_dimensions_tl_rec.DimensionId and
                  language = l_dimensions_tl_rec.Language;

insert into zpb_dimensions_tl
        (
 DIMENSION_ID,
 LANGUAGE,
 LONG_NAME,
 NAME,
 PLURAL_LONG_NAME,
 PLURAL_NAME,
 CREATED_BY,
 CREATION_DATE,
 LAST_UPDATED_BY,
 LAST_UPDATE_DATE,
 LAST_UPDATE_LOGIN
)
VALUES
        (
 l_dimensions_tl_rec.DimensionId,
 l_dimensions_tl_rec.Language,
 l_dimensions_tl_rec.LongName,
 l_dimensions_tl_rec.Name,
 l_dimensions_tl_rec.PluralLongName,
 l_dimensions_tl_rec.PluralName,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.LOGIN_ID
);

end insertDimensionsTLRecord;

-------------------------------------------------------------------------------
--  insertHierarchyRecord - Private function that inserts a
--                      zpb_md_records.hierarchies_entry into zpb_hierarchies and
--                                          returns the primary key of the newly created entry
-------------------------------------------------------------------------------
function insertHierarchyRecord(p_hierarchies_rec in zpb_md_records.hierarchies_entry)
        return number is
                l_hierarchies_rec zpb_md_records.hierarchies_entry;

begin

        l_hierarchies_rec := p_hierarchies_rec;

        begin

                select hierarchy_id into l_hierarchies_rec.HierarchyId
                from zpb_hierarchies
                where dimension_id = l_hierarchies_rec.DimensionId and
                          pers_cwm_name = l_hierarchies_rec.PersCWMName;

                update zpb_hierarchies
                set
 EPB_ID =        l_hierarchies_rec.EpbId,
 HIER_TYPE      =        l_hierarchies_rec.HierType,
 PERS_TABLE_ID  =        l_hierarchies_rec.PersTableId,
 SHAR_CWM_NAME  =        l_hierarchies_rec.SharCWMName,
 SHAR_TABLE_ID  =        l_hierarchies_rec.SharTableId,
 CREATED_BY     =        FND_GLOBAL.USER_ID,
 CREATION_DATE  =        sysdate,
 LAST_UPDATED_BY        =        FND_GLOBAL.USER_ID,
 LAST_UPDATE_DATE       =        sysdate,
 LAST_UPDATE_LOGIN      =        FND_GLOBAL.LOGIN_ID
                where hierarchy_id = l_hierarchies_rec.HierarchyId;

        exception
                when NO_DATA_FOUND then
                SELECT zpb_hierarchies_seq.NEXTVAL INTO l_hierarchies_rec.HierarchyId FROM DUAL;

insert into zpb_hierarchies
        (
 DIMENSION_ID,
 EPB_ID,
 HIERARCHY_ID,
 HIER_TYPE,
 PERS_CWM_NAME,
 PERS_TABLE_ID,
 SHAR_CWM_NAME,
 SHAR_TABLE_ID,
 CREATED_BY,
 CREATION_DATE,
 LAST_UPDATED_BY,
 LAST_UPDATE_DATE,
 LAST_UPDATE_LOGIN

)
VALUES
(
 l_hierarchies_rec.DimensionId,
 l_hierarchies_rec.EpbId,
 l_hierarchies_rec.HierarchyId,
 l_hierarchies_rec.HierType,
 l_hierarchies_rec.PersCWMName,
 l_hierarchies_rec.PersTableId,
 l_hierarchies_rec.SharCWMName,
 l_hierarchies_rec.SharTableId,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.LOGIN_ID
);

  end;

  return l_hierarchies_rec.HierarchyId;
end insertHierarchyRecord;

-------------------------------------------------------------------------------
--  insertHierarchyTLRecord - Private procedure that inserts a
--                      zpb_md_records.hierarchies_tl_entry into zpb_hierarchies_tl and
-------------------------------------------------------------------------------
procedure insertHierarchyTLRecord(p_hierarchies_tl_rec in zpb_md_records.hierarchies_tl_entry)
is
                l_hierarchies_tl_rec zpb_md_records.hierarchies_tl_entry;
                l_record_count  number;

begin

        l_hierarchies_tl_rec := p_hierarchies_tl_rec;

        select count(*) into l_record_count
        from zpb_hierarchies_tl
        where hierarchy_id = l_hierarchies_tl_rec.HierarchyId and
                  language = l_hierarchies_tl_rec.Language;

--Make sure do not try to insert hierarchy entry for same language twice
if l_record_count = 0 then

insert into zpb_hierarchies_tl
        (
 HIERARCHY_ID,
 LANGUAGE,
 LONG_NAME,
 NAME,
 PLURAL_LONG_NAME,
 PLURAL_NAME,
 CREATED_BY,
 CREATION_DATE,
 LAST_UPDATED_BY,
 LAST_UPDATE_DATE,
 LAST_UPDATE_LOGIN

)
VALUES
        (
 l_hierarchies_tl_rec.HierarchyId,
 l_hierarchies_tl_rec.Language,
 l_hierarchies_tl_rec.LongName,
 l_hierarchies_tl_rec.Name,
 l_hierarchies_tl_rec.PluralLongName,
 l_hierarchies_tl_rec.PluralName,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.LOGIN_ID
);

else

 update zpb_hierarchies_tl
 set

         LONG_NAME      =        l_hierarchies_tl_rec.LongName,
         NAME   =        l_hierarchies_tl_rec.Name,
         PLURAL_LONG_NAME       =        l_hierarchies_tl_rec.PluralLongName,
         PLURAL_NAME    =        l_hierarchies_tl_rec.PluralName,
         CREATED_BY     =        FND_GLOBAL.USER_ID,
         CREATION_DATE  =        sysdate,
         LAST_UPDATED_BY        =        FND_GLOBAL.USER_ID,
         LAST_UPDATE_DATE       =        sysdate,
         LAST_UPDATE_LOGIN      =        FND_GLOBAL.LOGIN_ID
  where hierarchy_id = l_hierarchies_tl_rec.HierarchyId and
                        language = l_hierarchies_tl_rec.Language;

end if;

end insertHierarchyTLRecord;

-------------------------------------------------------------------------------
--  insertLevelTLRecord - Private procedure that inserts a
--                      zpb_md_records.levels_tl_entry into zpb_levels_tl and
-------------------------------------------------------------------------------
procedure insertLevelTLRecord(p_levels_tl_rec in zpb_md_records.levels_tl_entry)
is
                l_levels_tl_rec zpb_md_records.levels_tl_entry;
                l_record_count  number;

begin

        l_levels_tl_rec := p_levels_tl_rec;

        select count(*) into l_record_count
        from zpb_levels_tl
        where level_id = l_levels_tl_rec.LevelId and
                  language = l_levels_tl_rec.Language;

        if l_record_count = 1 then

                update zpb_levels_tl
                set
                        LONG_NAME                       =        l_levels_tl_rec.LongName,
                        NAME                            =        l_levels_tl_rec.Name,
                        PLURAL_LONG_NAME        =        l_levels_tl_rec.PluralLongName,
                        PLURAL_NAME                     =        l_levels_tl_rec.PluralName,
                        CREATED_BY                      =        FND_GLOBAL.USER_ID,
                        CREATION_DATE           =        sysdate,
                        LAST_UPDATED_BY         =        FND_GLOBAL.USER_ID,
                        LAST_UPDATE_DATE        =        sysdate,
                        LAST_UPDATE_LOGIN       =        FND_GLOBAL.LOGIN_ID
                where level_id = l_levels_tl_rec.LevelId and
                                             language = l_levels_tl_rec.Language;

        else

                insert into zpb_levels_tl
                        (
                 LEVEL_ID,
                 LANGUAGE,
                 LONG_NAME,
                 NAME,
                 PLURAL_LONG_NAME,
                 PLURAL_NAME,
                 CREATED_BY,
                 CREATION_DATE,
                 LAST_UPDATED_BY,
                 LAST_UPDATE_DATE,
                 LAST_UPDATE_LOGIN
                        )
                VALUES
                        (
                 l_levels_tl_rec.LevelId,
                 l_levels_tl_rec.Language,
                 l_levels_tl_rec.LongName,
                 l_levels_tl_rec.Name,
                 l_levels_tl_rec.PluralLongName,
                 l_levels_tl_rec.PluralName,
                 FND_GLOBAL.USER_ID,
                 sysdate,
                 FND_GLOBAL.USER_ID,
                 sysdate,
                 FND_GLOBAL.LOGIN_ID
                );
        end if;

end insertLevelTLRecord;


-------------------------------------------------------------------------------
--  deleteCubeRecord -     Private procedure that deletes all md records for a
--                         particular cube.
-------------------------------------------------------------------------------
procedure deleteCubeRecord(p_cube_id in number) is

begin

--   zpb_log.write_error('zpb_metadata_pkg.deleteCubeRecord',
--                 'Deleteing Cube '||p_cube_id);

        -- delete cube measures and measure scoping entries

        delete zpb_measures
         where cube_id = p_cube_id;

        -- delete table and column entries for cube
        delete zpb_columns
         where  table_id=(select table_id
                                          from   zpb_cubes
                                      where  cube_id = p_cube_id);

        delete zpb_tables
         where table_id = (select table_id
                                           from   zpb_cubes
                                           where  cube_id = p_cube_id);

        -- delete cube mapping entries (to dims and hierarchies)
        delete zpb_cube_dims
         where cube_id = p_cube_id;

        delete zpb_cube_hier
         where cube_id = p_cube_id;

        -- finally delete cube entry
        delete zpb_cubes
         where cube_id = p_cube_id;

end deleteCubeRecord;

-------------------------------------------------------------------------------
--  insertCubeRecord - Private function that inserts a
--                      zpb_md_records.cubes_entry into zpb_cubes and
--                                          returns the primary key of the newly created entry
--
--              if p_primary_key_provided is true, then the primary key for the
--                      cube to be inserted is provided and we do not select it from sequence
-------------------------------------------------------------------------------
function insertCubeRecord(p_cube_rec in zpb_md_records.CUBES_ENTRY,
                                                   p_primary_key_provided in boolean default false)
        return number is
                l_cube_rec                      zpb_md_records.cubes_entry;
                bus_area_id_num         number;
                insert_flag                     boolean;

begin

        l_cube_rec := p_cube_rec;
        bus_area_id_num := sys_context('ZPB_CONTEXT', 'business_area_id');
        insert_flag := p_primary_key_provided;

        if insert_flag = false then

        begin

                select cube_id into l_cube_rec.CubeId
                from zpb_cubes
                where name = l_cube_rec.Name and
                          bus_area_id = bus_area_id_num;

                update zpb_cubes
                set
 EPB_ID =        l_cube_rec.EpbId,
 TABLE_ID       =        l_cube_rec.TableId,
 TYPE   =        l_cube_rec.Type,
 CREATED_BY     =        FND_GLOBAL.USER_ID,
 CREATION_DATE  =        sysdate,
 LAST_UPDATED_BY        =        FND_GLOBAL.USER_ID,
 LAST_UPDATE_DATE       =        sysdate,
 LAST_UPDATE_LOGIN      =        FND_GLOBAL.LOGIN_ID
                where cube_id = l_cube_rec.CubeId;

        exception
                when NO_DATA_FOUND then
                SELECT zpb_cubes_seq.NEXTVAL INTO l_cube_rec.CubeId FROM DUAL;
                insert_flag:=true;
        end;

        end if;

        if insert_flag = true then

insert into zpb_cubes
        (
 BUS_AREA_ID,
 CUBE_ID,
 EPB_ID,
 NAME,
 TABLE_ID,
 TYPE,
 CREATED_BY,
 CREATION_DATE,
 LAST_UPDATED_BY,
 LAST_UPDATE_DATE,
 LAST_UPDATE_LOGIN
)
VALUES
(
-- l_cube_rec.BusAreaId,
 bus_area_id_num,
 l_cube_rec.CubeId,
 l_cube_rec.EpbId,
 l_cube_rec.Name,
 l_cube_rec.TableId,
 l_cube_rec.Type,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.LOGIN_ID
);

end if;

  return l_cube_rec.CubeId;
end insertCubeRecord;



-------------------------------------------------------------------------------
--  insertHierScopeRecord - Private function that inserts a
--                      zpb_md_records.hier_scope_entry into zpb_hier_scope and
--                                          returns the primary key of the newly created entry
-------------------------------------------------------------------------------
function insertHierScopeRecord(p_hier_scope_rec zpb_md_records.hier_scope_entry)
        return number is

        l_hier_scope_rec zpb_md_records.hier_scope_entry;

begin

        l_hier_scope_rec := p_hier_scope_rec;

        begin

        select scope_id into l_hier_scope_rec.ScopeId
        from   zpb_hier_scope
        where  hierarchy_id = l_hier_scope_rec.HierarchyId and
               user_id = l_hier_scope_rec.UserId and
                           resp_id = nvl(to_number(sys_context('ZPB_CONTEXT', 'resp_id')), FND_GLOBAL.RESP_ID);

        update zpb_hier_scope
        set

 PERS_TABLE_ID  =   l_hier_scope_rec.PersTableId,
 CREATED_BY             =        FND_GLOBAL.USER_ID,
 CREATION_DATE  =        sysdate,
 LAST_UPDATED_BY        =        FND_GLOBAL.USER_ID,
 LAST_UPDATE_DATE       =        sysdate,
 LAST_UPDATE_LOGIN      =        FND_GLOBAL.LOGIN_ID
        where scope_id = l_hier_scope_rec.ScopeId;

        exception
                when NO_DATA_FOUND then
        SELECT zpb_hier_scope_seq.NEXTVAL INTO l_hier_scope_rec.ScopeId FROM DUAL;

insert into zpb_hier_scope
        (
 END_DATE,
 HIERARCHY_ID,
 SCOPE_ID,
 START_DATE,
 USER_ID,
 RESP_ID,
 PERS_TABLE_ID,
 CREATED_BY,
 CREATION_DATE,
 LAST_UPDATED_BY,
 LAST_UPDATE_DATE,
 LAST_UPDATE_LOGIN
)
VALUES
        (
 l_hier_scope_rec.EndDate,
 l_hier_scope_rec.HierarchyId,
 l_hier_scope_rec.ScopeId,
 l_hier_scope_rec.StartDate,
 l_hier_scope_rec.UserId,
 nvl(to_number(sys_context('ZPB_CONTEXT', 'resp_id')), FND_GLOBAL.RESP_ID),
 l_hier_scope_rec.PersTableId,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.LOGIN_ID
);

        end;

return l_hier_scope_rec.ScopeId;

end insertHierScopeRecord;

-------------------------------------------------------------------------------
--  insertHierlevelscopeRecord - Private function that inserts a
--                      zpb_md_records.hier_level_scope_entry into zpb_hier_level_scope and
--                                          returns the primary key of the newly created entry
-------------------------------------------------------------------------------
function insertHierlevelscopeRecord(p_hier_level_scope_rec zpb_md_records.hier_level_scope_entry)
        return number is

        l_hier_level_scope_rec zpb_md_records.hier_level_scope_entry;

begin

        l_hier_level_scope_rec := p_hier_level_scope_rec;

        begin

        select scope_id into l_hier_level_scope_rec.ScopeId
        from   zpb_hier_level_scope
        where  hier_id = l_hier_level_scope_rec.HierId and
               level_id = l_hier_level_scope_rec.LevelId and
               user_id = l_hier_level_scope_rec.UserId and
                           resp_id = nvl(to_number(sys_context('ZPB_CONTEXT', 'resp_id')), FND_GLOBAL.RESP_ID);

        update zpb_hier_level_scope
        set

 PERS_COL_ID    =    l_hier_level_scope_rec.PersColId,
 CREATED_BY             =        FND_GLOBAL.USER_ID,
 CREATION_DATE  =        sysdate,
 LAST_UPDATED_BY        =        FND_GLOBAL.USER_ID,
 LAST_UPDATE_DATE       =        sysdate,
 LAST_UPDATE_LOGIN      =        FND_GLOBAL.LOGIN_ID
        where scope_id = l_hier_level_scope_rec.ScopeId;

        exception
                when NO_DATA_FOUND then
        SELECT zpb_hier_level_scope_seq.NEXTVAL INTO l_hier_level_scope_rec.ScopeId FROM DUAL;

insert into zpb_hier_level_scope
        (
 LEVEL_ID,
 HIER_ID,
 SCOPE_ID,
 USER_ID,
 RESP_ID,
 PERS_COL_ID,
 CREATED_BY,
 CREATION_DATE,
 LAST_UPDATED_BY,
 LAST_UPDATE_DATE,
 LAST_UPDATE_LOGIN
)
VALUES
        (
 l_hier_level_scope_rec.LevelId,
 l_hier_level_scope_rec.HierId,
 l_hier_level_scope_rec.ScopeId,
 l_hier_level_scope_rec.UserId,
 nvl(to_number(sys_context('ZPB_CONTEXT', 'resp_id')), FND_GLOBAL.RESP_ID),
 l_hier_level_scope_rec.PersColId,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.LOGIN_ID
);

        end;

return l_hier_level_scope_rec.ScopeId;

end insertHierlevelscopeRecord;


-------------------------------------------------------------------------------
--  insertAttributescopeRecord - Private function that inserts a
--                      zpb_md_records.attribute_scope_entry into zpb_attribute_scope and
--                                          returns the primary key of the newly created entry
-------------------------------------------------------------------------------
function insertAttributescopeRecord(p_attribute_scope_rec zpb_md_records.attribute_scope_entry)
        return number is

        l_attribute_scope_rec zpb_md_records.attribute_scope_entry;

begin

        l_attribute_scope_rec := p_attribute_scope_rec;

        begin

        select scope_id into l_attribute_scope_rec.ScopeId
        from   zpb_attribute_scope
        where  attribute_id = l_attribute_scope_rec.AttributeId and
               user_id = l_attribute_scope_rec.UserId and
                           resp_id = nvl(to_number(sys_context('ZPB_CONTEXT', 'resp_id')), FND_GLOBAL.RESP_ID);

        update zpb_attribute_scope
        set

 CREATED_BY             =        FND_GLOBAL.USER_ID,
 CREATION_DATE  =        sysdate,
 LAST_UPDATED_BY        =        FND_GLOBAL.USER_ID,
 LAST_UPDATE_DATE       =        sysdate,
 LAST_UPDATE_LOGIN      =        FND_GLOBAL.LOGIN_ID
        where scope_id = l_attribute_scope_rec.ScopeId;

        exception
                when NO_DATA_FOUND then
        SELECT zpb_attribute_scope_seq.NEXTVAL INTO l_attribute_scope_rec.ScopeId FROM DUAL;

insert into zpb_attribute_scope
        (
 SCOPE_ID,
 ATTRIBUTE_ID,
 USER_ID,
 RESP_ID,
 END_DATE,
 START_DATE,
 CREATED_BY,
 CREATION_DATE,
 LAST_UPDATED_BY,
 LAST_UPDATE_DATE,
 LAST_UPDATE_LOGIN
)
VALUES
        (
 l_attribute_scope_rec.ScopeId,
 l_attribute_scope_rec.AttributeId,
 l_attribute_scope_rec.UserId,
 nvl(to_number(sys_context('ZPB_CONTEXT', 'resp_id')), FND_GLOBAL.RESP_ID),
 l_attribute_scope_rec.EndDate,
 l_attribute_scope_rec.StartDate,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.USER_ID,
 sysdate,
 FND_GLOBAL.LOGIN_ID
);

        end;

return l_attribute_scope_rec.ScopeId;

end insertAttributescopeRecord;

-------------------------------------------------------------------------------
-- deleteDimensionRecord - Private procedure that deletes all md records for a
--                         particular dimension.
-------------------------------------------------------------------------------
procedure deleteDimensionRecord(p_dimension_id in number) is

begin

                -- delete dimensions_tl
                delete zpb_dimensions_tl
                where dimension_id = p_dimension_id;

                -- delete attribute_scope
                delete zpb_attribute_scope
                where attribute_id in (select attribute_id
                                                                from zpb_attributes
                                                                where dimension_id = p_dimension_id);

                -- delete attr_table_col
                delete zpb_attr_table_col
                where attribute_id in (select attribute_id
                                                                from zpb_attributes
                                                                where dimension_id = p_dimension_id);

                -- delete attributes_tl
                delete zpb_attributes_tl
                where attribute_id in (select attribute_id
                                                                from zpb_attributes
                                                                where dimension_id = p_dimension_id);

                -- Finally delete attributes
                delete zpb_attributes
                where dimension_id = p_dimension_id;

                -- delete hierarchies_tl
                delete zpb_hierarchies_tl
                where hierarchy_id in (select hierarchy_id
                                                                from zpb_hierarchies
                                                                where dimension_id = p_dimension_id);

                -- delete hier_level
                delete zpb_hier_level
                where hier_id in (select hierarchy_id
                                                                from zpb_hierarchies
                                                                where dimension_id = p_dimension_id);

                -- delete hier_level_scope
                delete zpb_hier_level_scope
                where hier_id in (select hierarchy_id
                                                                from zpb_hierarchies
                                                                where dimension_id = p_dimension_id);

                -- delete hier_scope
                delete zpb_hier_scope
                where hierarchy_id in (select hierarchy_id
                                                                from zpb_hierarchies
                                                                where dimension_id = p_dimension_id);

                                -- delete hierarchy zpb_tables and zpb_column entries
                                delete zpb_tables
                                where table_id in (select pers_table_id from zpb_hierarchies
                                                                                                                where dimension_id = p_dimension_id);

                                delete zpb_columns
                                where table_id in (select pers_table_id from zpb_hierarchies
                                                                                                                where dimension_id = p_dimension_id);

                                delete zpb_tables
                                where table_id in (select shar_table_id from zpb_hierarchies
                                                                                                                where dimension_id = p_dimension_id);

                                delete zpb_columns
                                where table_id in (select shar_table_id from zpb_hierarchies
                                                                                                                where dimension_id = p_dimension_id);

                -- Finally delete hierarchies entry
                delete zpb_hierarchies
                where dimension_id = p_dimension_id;

                -- delete levels_tl
                delete zpb_levels_tl
                where level_id in (select level_id
                                                        from zpb_levels
                                                        where dimension_id = p_dimension_id);

                -- Finally delete levels
                delete zpb_levels
                where dimension_id = p_dimension_id;


                                -- Delete zpb_tables entries for dimension
                                delete zpb_tables where table_id = (select pers_table_id from zpb_dimensions where dimension_id = p_dimension_id);
                                delete zpb_columns where table_id = (select pers_table_id from zpb_dimensions where dimension_id = p_dimension_id);

                                delete zpb_tables where table_id = (select shar_table_id from zpb_dimensions where dimension_id = p_dimension_id);
                                delete zpb_columns where table_id = (select shar_table_id from zpb_dimensions where dimension_id = p_dimension_id);

                -- Finally delete dimension
                delete zpb_dimensions
                where dimension_id = p_dimension_id;

end deleteDimensionRecord;

-------------------------------------------------------------------------------
-- deleteAttributeRecord - Private procedure that deletes all md records for a
--                         particular attribute.
-------------------------------------------------------------------------------
procedure deleteAttributeRecord(p_attribute_id in number) is

begin

                -- delete attribute_scope
                delete zpb_attribute_scope
                where attribute_id = p_attribute_id;

                -- delete attr_table_col
                delete zpb_attr_table_col
                where attribute_id = p_attribute_id;

                -- delete attributes_tl
                delete zpb_attributes_tl
                where attribute_id = p_attribute_id;

                -- detele zpb_attributes
                delete zpb_attributes
                where attribute_id = p_attribute_id;

end deleteAttributeRecord;

-------------------------------------------------------------------------------
-- deleteLevelRecord - Private procedure that deletes all md records for a
--                         particular level.
-------------------------------------------------------------------------------
procedure deleteLevelRecord(p_level_id in number) is

begin

                -- delete levels_tl
                delete zpb_levels_tl
                where level_id = p_level_id;

                -- Finally delete levels
                delete zpb_levels
                where level_id = p_level_id;

end deleteLevelRecord;

-------------------------------------------------------------------------------
--  deleteHierarchyRecord - Private procedure that deletes all md records for a
--                          particular hierarchy.
-------------------------------------------------------------------------------
procedure deleteHierarchyRecord(p_hierarchy_id in number) is

begin

                -- delete hierarchies_tl
                delete zpb_hierarchies_tl
                where hierarchy_id = p_hierarchy_id;

                -- delete hier_level
                delete zpb_hier_level
                where hier_id = p_hierarchy_id;

                -- delete hier_level_scope
                delete zpb_hier_level_scope
                where hier_id = p_hierarchy_id;

                -- delete hier_scope
                delete zpb_hier_scope
                where hierarchy_id = p_hierarchy_id;

                                -- delete zpb_tables for hierarchy
                                delete zpb_tables where table_id = (select pers_table_id from zpb_hierarchies where hierarchy_id = p_hierarchy_id);
                                delete zpb_columns where table_id = (select pers_table_id from zpb_hierarchies where hierarchy_id = p_hierarchy_id);

                                delete zpb_tables where table_id = (select shar_table_id from zpb_hierarchies where hierarchy_id = p_hierarchy_id);
                                delete zpb_columns where table_id = (select shar_table_id from zpb_hierarchies where hierarchy_id = p_hierarchy_id);

                -- Finally delete hierarchies entry
                delete zpb_hierarchies
                where hierarchy_id = p_hierarchy_id;

end deleteHierarchyRecord;
-------------------------------------------------------------------------------
--  cleancleanOldEntries - Private procedure that deletes all md records that
--                                                 have not been updated during a universe refresh and
--                                                 thus no longer exist
-------------------------------------------------------------------------------
procedure cleanOldEntries(p_start_time date) is

                bus_area_id_num number;

                CURSOR c_dimensions is
         select dimension_id
         from zpb_dimensions
         where bus_area_id = bus_area_id_num and
                           last_update_date < p_start_time;

                v_dim   c_dimensions%ROWTYPE;

                CURSOR c_attributes is
                 select attribute_id
                 from   zpb_attributes
                 where  last_update_date < p_start_time and
                                dimension_id in (select dimension_id
                                                                 from zpb_dimensions
                                                                 where bus_area_id = bus_area_id_num);

                v_attribute             c_attributes%ROWTYPE;

                CURSOR c_hierarchies is
                 select hierarchy_id
                 from   zpb_hierarchies
                 where  last_update_date < p_start_time and
                                dimension_id in (select dimension_id
                                                                 from zpb_dimensions
                                                                 where bus_area_id = bus_area_id_num);

                v_hierarchy             c_hierarchies%ROWTYPE;

                CURSOR c_levels is
                 select level_id
                 from   zpb_levels
                 where  last_update_date < p_start_time and
                                dimension_id in (select dimension_id
                                                                 from zpb_dimensions
                                                                 where bus_area_id = bus_area_id_num);

                v_level                 c_levels%ROWTYPE;

begin

        bus_area_id_num := sys_context('ZPB_CONTEXT', 'business_area_id');

        for v_dim in c_dimensions loop
                deleteDimensionRecord(v_dim.dimension_id);
        end loop;

        for v_attribute in c_attributes loop
                deleteAttributeRecord(v_attribute.attribute_id);
        end loop;

        for v_hierarchy in c_hierarchies loop
                deleteHierarchyRecord(v_hierarchy.hierarchy_id);
        end loop;

        for v_level in c_levels loop
                deleteLevelRecord(v_level.level_id);
        end loop;

        delete zpb_attr_table_col
        where last_update_date < p_start_time and
                  table_id in (select table_id
                                           from zpb_tables
                                           where bus_area_id =  bus_area_id_num);

        delete zpb_hier_level
        where last_update_date < p_start_time
                  and hier_id in (select hier.hierarchy_id
                                                    from zpb_hierarchies hier,
                                                                 zpb_dimensions  dim
                                                        where hier.dimension_id = dim.dimension_id and
                                                                  dim.bus_area_id = bus_area_id_num);

end cleanOldEntries;

-------------------------------------------------------------------------------
-- BUILD_DIMS - Exposes metadata for dimensions and objects associated with them
--                              hierarchies, attributes, levels
--
-- IN: p_aw       - The AW to build
--     p_sharedAW - The shared AW (may be the same as p_aw)
--     p_type     - The AW type (PERSONAL or SHARED)
--     p_dims     - Space separated list of dim ID's
-------------------------------------------------------------------------------
procedure BUILD_DIMS(p_aw       in            varchar2,
                     p_sharedAw in            varchar2,
                     p_type     in            varchar2,
                     p_dims     in            varchar2)
   is
      l_hiers           varchar2(500);
      l_levels          varchar2(500);
      l_attrs           varchar2(500);
      l_attrId          varchar2(30);
      l_dim             varchar2(32);
      l_hier            varchar2(32);
      l_level           varchar2(32);
      l_lvlhier         varchar2(32);
      l_persLvl         boolean;
      l_attr            varchar2(32);
      l_aw              varchar2(32);
      l_viewAw          varchar2(32);
      i                 number;
      j                 number;
      hi                number;
      hj                number;
      li                number;
      lj                number;
      ai                number;
      aj                number;
      l_length          number;
      done              boolean;
      nl                varchar2(1) := fnd_global.local_chr(10);

      l_global_ecm      zpb_ecm.global_ecm;
      l_dim_data        zpb_ecm.dimension_data;
          l_range_dim_data  zpb_ecm.dimension_data;
      l_dim_ecm         zpb_ecm.dimension_ecm;
      l_dim_time_ecm    zpb_ecm.dimension_time_ecm;
      l_dim_line_ecm    zpb_ecm.dimension_line_ecm;
      l_global_attr_ecm zpb_ecm.global_attr_ecm;
      l_attr_ecm        zpb_ecm.attr_ecm;
          l_attr_nameFrag   varchar2(500);

      m_dimension_en            zpb_md_records.dimensions_entry;
      m_dimension_tl_en         zpb_md_records.dimensions_tl_entry;
      m_pers_table_en           zpb_md_records.tables_entry;
      m_shar_table_en           zpb_md_records.tables_entry;
      m_pers_column_en          zpb_md_records.columns_entry;
      m_shar_column_en          zpb_md_records.columns_entry;

      m_hier_en                 zpb_md_records.hierarchies_entry;
      m_hier_tl_en              zpb_md_records.hierarchies_tl_entry;
      m_level_en                zpb_md_records.levels_entry;
      m_level_tl_en             zpb_md_records.levels_tl_entry;
      m_hier_level_en           zpb_md_records.hier_level_entry;
      m_hr_shar_table_en        zpb_md_records.tables_entry;
      m_hr_pers_table_en        zpb_md_records.tables_entry;

      -- static hierarchy table columns
      m_hr_pers_col_memCol      zpb_md_records.columns_entry;
      m_hr_shar_col_memCol      zpb_md_records.columns_entry;
      m_hr_pers_col_gidCol      zpb_md_records.columns_entry;
      m_hr_shar_col_gidCol      zpb_md_records.columns_entry;
      m_hr_shar_col_parentCol   zpb_md_records.columns_entry;
      m_hr_pers_col_parentCol   zpb_md_records.columns_entry;
      m_hr_shar_col_pgidCol     zpb_md_records.columns_entry;
      m_hr_pers_col_pgidCol     zpb_md_records.columns_entry;
      m_hr_pers_col_orderCol    zpb_md_records.columns_entry;
      m_hr_shar_col_orderCol    zpb_md_records.columns_entry;

      m_level_order                     number;

          m_table_id                    number;
          m_hierarchy_id                number;
      m_column_id                       number;
      m_level_id                        number;
      m_hier_level_id           number;
      m_attr_table_col_id       number;
          m_dummy_num                           number;

      -- attribute
      m_attr_en                         zpb_md_records.attributes_entry;
      m_attr_table_col_en       zpb_md_records.attr_table_col_entry;

      -- attribute range dimension
      m_attr_rangedim_en        zpb_md_records.dimensions_entry;
      m_attr_rangedim_tl_en     zpb_md_records.dimensions_tl_entry;
      m_attr_rangehier_en       zpb_md_records.hierarchies_entry;
          m_attr_rangetbl_en    zpb_md_records.tables_entry;
      m_attr_rangedimCount      number;
      m_attr_rangecol_en        zpb_md_records.columns_entry;
          m_attr_rangehl_en             zpb_md_records.hier_level_entry;
      m_attr_rangelev_en        zpb_md_records.levels_entry;
          m_attr_rangeattr_en   zpb_md_records.attributes_entry;
          m_attr_rangeatc_en    zpb_md_records.attr_table_col_entry;

      -- shared attribute range dimension
      m_attr_range_sh_tbl_en    zpb_md_records.tables_entry;
      m_attr_range_sh_col_en    zpb_md_records.columns_entry;
      m_attr_sh_rangeatc_en     zpb_md_records.attr_table_col_entry;

          m_attr_tl_en                  zpb_md_records.attributes_tl_entry;

          bus_area_id_num               number;

          -- primary keys found flags
          m_dimension_exists            boolean;
          m_pers_table_exists           boolean;
          m_shar_table_exists           boolean;

          -- language looping
          l_langs                       varchar2(500);
          l_lang                        FND_LANGUAGES.LANGUAGE_CODE%type;
          htld_i                        number;
          htld_j                        number;

                  -- personal-personal hierarchy table MD
                  l_pp_hiert_start_time          date;

begin
   l_aw              := zpb_aw.get_schema||'.'||p_aw||'!';
   l_global_ecm      := zpb_ecm.get_global_ecm (p_aw);
   l_global_attr_ecm := zpb_ecm.get_global_attr_ecm(p_aw);

   l_langs :=zpb_aw.interp
      ('shw CM.GETDIMVALUES('''||l_aw||l_global_ecm.LangDim||''')');

        bus_area_id_num := sys_context('ZPB_CONTEXT', 'business_area_id');

   zpb_aw.execute('push oknullstatus');
   zpb_aw.execute('oknullstatus = yes');

--   dbms_output.put_line('Building dims: ' || p_dims);

   -- Loop pver all dimensions
   i := 1;
   loop
      j := instr (p_dims, ' ', i);
      if (j = 0) then
         l_dim := substr (p_dims, i);
       else
         l_dim := substr (p_dims, i, j-i);
         i     := j+1;
      end if;

          m_dimension_en.EPBId := l_dim;
          -- Get primary key for newly created dimension entry
                begin

                         select dimension_id into m_dimension_en.DimensionId
                         from  zpb_dimensions
                         where bus_area_id = bus_area_id_num and
                                   epb_id = m_dimension_en.EPBId;

                         m_dimension_exists := false;

                exception
                        when NO_DATA_FOUND then
                         SELECT zpb_dimensions_seq.NEXTVAL INTO m_dimension_en.DimensionId  FROM DUAL;
                         m_dimension_exists := true;
                end;


      l_dim_data := zpb_ecm.get_dimension_data (l_dim, p_aw);
      l_dim_ecm  := zpb_ecm.get_dimension_ecm (l_dim, p_aw);

      zpb_aw.execute('push '||l_aw||l_dim_data.ExpObj);

      m_dimension_en.AWName := l_dim_data.ExpObj;

      -- Dimension Default Hierarchy
      m_dimension_en.DefaultHier := l_dim_ecm.HierDefault;

      -- get both the personal and shared CWM dimension names
      m_dimension_en.PersCWMName := zpb_metadata_names.get_dimension_cwm2_name('PRS', l_dim);
      m_dimension_en.SharCWMName := zpb_metadata_names.get_dimension_cwm2_name(p_sharedAw, l_dim);

      m_dimension_en.DimType := l_dim_data.Type;
      m_dimension_en.AnnotationDim := l_dim_ecm.AnnDim ;
      m_dimension_en.DefaultMember := l_dim_ecm.DefaultMember;
      m_dimension_en.IsOwnerDim := l_dim_data.IsOwnerDim;
      m_dimension_en.IsDataDim := l_dim_data.IsDataDim;

      -- get the dimension table names for personal and shared
      m_shar_table_en.TableName:= zpb_metadata_names.get_dimension_view
       (p_sharedAW, 'SHARED', l_dim);
      m_pers_table_en.TableName:=zpb_metadata_names.get_dimension_view
           (p_sharedAW, 'PERSONAL', l_dim);

      m_shar_table_en.TableType := 'DIMENSION';
      m_pers_table_en.TableType := 'DIMENSION';

      m_shar_table_en.AWName := p_sharedAw;
      m_pers_table_en.AWName := p_sharedAw;

      -- insert dimension table records
      m_dimension_en.SharTableId :=       insertTableRecord(m_shar_table_en);
      m_dimension_en.PersTableId :=       insertTableRecord(m_pers_table_en);

        -- set the table id for the Columns Below
        m_pers_column_en.TableId := m_dimension_en.PersTableId;
        m_shar_column_en.TableId := m_dimension_en.SharTableId;

    --TABLE COLUMNS
          -- Create MEMBER_COLUMN's for the tables
      m_pers_column_en.columnType := 'MEMBER_COLUMN';
      m_shar_column_en.columnType := 'MEMBER_COLUMN';

      m_pers_column_en.columnName := zpb_metadata_names.get_dimension_column(l_dim);
      m_shar_column_en.columnName := zpb_metadata_names.get_dimension_column(l_dim);

      m_pers_column_en.AWName := l_dim_data.ExpObj;
      m_shar_column_en.AWName := l_dim_data.ExpObj;

          -- insert column records, we dont care about their primary keys here
      m_column_id := insertColumnRecord(m_pers_column_en);
      m_column_id := insertColumnRecord(m_shar_column_en);

      -- Creat LONG NAME column for the tables
      m_pers_column_en.columnType := 'LNAME_COLUMN';
      m_shar_column_en.columnType := 'LNAME_COLUMN';

      m_pers_column_en.columnName := zpb_metadata_names.get_dim_long_name_column(l_dim);
      m_shar_column_en.columnName := zpb_metadata_names.get_dim_long_name_column(l_dim);

      m_pers_column_en.AWName := l_dim_ecm.LdscVar;
      m_shar_column_en.AWName := l_dim_ecm.LdscVar;

          -- insert column records, we dont care about their primary keys here
          m_column_id := insertColumnRecord(m_pers_column_en);
          m_column_id := insertColumnRecord(m_shar_column_en);

          -- Create SHORT NAME columns for the tables
      m_pers_column_en.columnType := 'SNAME_COLUMN';
      m_shar_column_en.columnType := 'SNAME_COLUMN';

      m_pers_column_en.columnName := zpb_metadata_names.get_dim_short_name_column(l_dim);
      m_shar_column_en.columnName := zpb_metadata_names.get_dim_short_name_column(l_dim);

      m_pers_column_en.AWName := l_dim_ecm.MdscVar;
      m_shar_column_en.AWName := l_dim_ecm.MdscVar;

          -- insert column records, we dont care about their primary keys here
          m_column_id := insertColumnRecord(m_pers_column_en);
          m_column_id := insertColumnRecord(m_shar_column_en);

          -- Create CODE columns for the tables
      m_pers_column_en.columnType := 'CODE_COLUMN';
      m_shar_column_en.columnType := 'CODE_COLUMN';

      m_pers_column_en.columnName := zpb_metadata_names.get_dim_code_column(l_dim);
      m_shar_column_en.columnName := zpb_metadata_names.get_dim_code_column(l_dim);

      m_pers_column_en.AWName := l_dim_ecm.SdscVar;
      m_shar_column_en.AWName := l_dim_ecm.SdscVar;

          -- insert column records, we dont care about their primary keys here
          m_column_id := insertColumnRecord(m_pers_column_en);
          m_column_id := insertColumnRecord(m_shar_column_en);

          -- Create GID columns for the tables
      m_pers_column_en.columnType := 'GID_COLUMN';
      m_shar_column_en.columnType := 'GID_COLUMN';

      m_pers_column_en.columnName := zpb_metadata_names.get_dim_gid_column(l_dim);
      m_shar_column_en.columnName := zpb_metadata_names.get_dim_gid_column(l_dim);

      m_pers_column_en.AWName := l_dim_ecm.GID;
      m_shar_column_en.AWName := l_dim_ecm.GID;

          -- insert column records, we dont care about their primary keys here
          m_column_id :=insertColumnRecord(m_pers_column_en);
          m_column_id :=insertColumnRecord(m_shar_column_en);

      --Prepare columns common to all Hierarchy Table Records
      m_hr_pers_table_en.AWName:= p_sharedAw;
      m_hr_shar_table_en.AWName:= p_sharedAw;

      -- MEMBER COLUMN
      m_hr_pers_col_memCol.columnType := 'MEMBER_COLUMN';
      m_hr_shar_col_memCol.columnType := 'MEMBER_COLUMN';

      m_hr_pers_col_memCol.columnName := zpb_metadata_names.get_dimension_column(l_dim);
      m_hr_shar_col_memCol.columnName := zpb_metadata_names.get_dimension_column(l_dim);

      m_hr_pers_col_memCol.AWName := l_dim_data.ExpObj;
      m_hr_shar_col_memCol.AWName := l_dim_data.ExpObj;

          -- GID COLUMNS
      m_hr_pers_col_gidCol.columnType := 'GID_COLUMN';
      m_hr_shar_col_gidCol.columnType := 'GID_COLUMN';

      m_hr_pers_col_gidCol.columnName := zpb_metadata_names.get_dim_gid_column(l_dim);
      m_hr_shar_col_gidCol.columnName := zpb_metadata_names.get_dim_gid_column(l_dim);

      m_hr_pers_col_gidCol.AWName := l_dim_ecm.GID;
      m_hr_shar_col_gidCol.AWName := l_dim_ecm.GID;

          -- PGID COLUMNS
      m_hr_pers_col_pgidCol.columnType := 'PGID_COLUMN';
      m_hr_shar_col_pgidCol.columnType := 'PGID_COLUMN';

      m_hr_pers_col_pgidCol.columnName := zpb_metadata_names.get_dim_pgid_column(l_dim);
      m_hr_shar_col_pgidCol.columnName := zpb_metadata_names.get_dim_pgid_column(l_dim);

      m_hr_pers_col_pgidCol.AWName := l_dim_ecm.GID;
      m_hr_shar_col_pgidCol.AWName := l_dim_ecm.GID;

          -- PARENT COLUMNS
      m_hr_pers_col_parentCol.columnType := 'PARENT_COLUMN';
      m_hr_shar_col_parentCol.columnType := 'PARENT_COLUMN';

      m_hr_pers_col_parentCol.columnName :=  zpb_metadata_names.get_dim_parent_column(l_dim);
      m_hr_shar_col_parentCol.columnName :=  zpb_metadata_names.get_dim_parent_column(l_dim);

      m_hr_pers_col_parentCol.AWName := l_dim_ecm.ParentRel;
      m_hr_shar_col_parentCol.AWName := l_dim_ecm.ParentRel;

          -- ORDER COLUMNS
      m_hr_pers_col_orderCol.ColumnType := 'ORDER_COLUMN';
      m_hr_shar_col_orderCol.ColumnType := 'ORDER_COLUMN';

      m_hr_pers_col_orderCol.ColumnName := zpb_metadata_names.get_dim_order_column(l_dim);
      m_hr_shar_col_orderCol.ColumnName := zpb_metadata_names.get_dim_order_column(l_dim);

      m_hr_pers_col_orderCol.AWName := l_dim_ecm.FullOrderVar;
      m_hr_shar_col_orderCol.AWName := l_dim_ecm.FullOrderVar;


      --
      -- HierDim can be valid with nothing in status, if scoping rules
      -- out all possible hierarchies for the user:
      --
      done := false;
      if (zpb_aw.interp('shw obj(dimmax '''||l_aw||l_dim_ecm.HierDim||
                        ''')') <> '0') then
         hi := 1;
         l_hiers :=zpb_aw.interp
            ('shw CM.GETDIMVALUES('''||l_aw||l_dim_ecm.HierDim||''')');

         zpb_aw.execute ('push '||l_aw||l_dim_ecm.LevelDim);
         zpb_aw.execute ('push '||l_aw||l_dim_ecm.HierDim);
         loop -- LOOP OVER ALL HIERARCHIES
            hj    := instr (l_hiers, ' ', hi);
            if (hj = 0) then
               l_hier := substr (l_hiers, hi);
             else
               l_hier := substr (l_hiers, hi, hj-hi);
               hi     := hj+1;
            end if;

--                      dbms_output.put_line('Looping for hierarchy  ' || l_hier);

            zpb_aw.execute('lmt '||l_aw||l_dim_ecm.HierDim||' to '''||
                           l_hier||'''');

            zpb_aw.execute('lmt '||l_aw||l_dim_data.ExpObj||' to '||l_aw||
                           l_dim_ecm.HOrderVS);

            if (zpb_aw.interp('shw convert(statlen('||l_aw||l_dim_data.ExpObj||
                              ') text 0 no no)') <> 0) then

                           -- if this hierarchy has members, limit the level dimension to its levels
                           -- and and sort it according to leveldepthvar

               zpb_aw.execute('lmt '||l_aw||l_dim_ecm.HierDim||' to '''||
                              l_hier||'''');

               zpb_aw.execute('lmt '||l_aw||l_dim_ecm.LevelDim||
                              ' to &joinchars ('''||l_aw||''' obj(property '''
                              ||'HIERLEVELVS'' '''||l_dim_ecm.HierDim||'''))');

                           zpb_aw.execute('sort '||l_aw||l_dim_ecm.levelDim||
                              ' a &joinchars ('''||l_aw||''' obj(property '''
                            ||'LEVELDEPTHVAR'' '''||l_dim_ecm.HierDim||'''))');


                           -- if we are in personal mode and user has a personal level in this hierarchy, build
                           -- metadata for the personal-personal hierarchy table (this table has the user's id in its name)
                           if (p_type='PERSONAL' and zpb_aw.interp('shw convert(statlen(limit(' || l_aw||l_dim_ecm.levelDim||
                                                        ' to &joinchars ('''||l_aw||''' obj(property '''
                              ||'PERSONALVAR'' '''||l_dim_ecm.LevelDim||''')))) text 0 no no)') > 0) then

                                  l_persLvl := true;
                  m_hr_pers_table_en.TableName := zpb_metadata_names.get_dimension_view
                                                                                (p_aw, 'PERSONAL', l_dim, l_hier);
                                  m_hr_pers_table_en.AWName:= p_aw;

                                  select sysdate into l_pp_hiert_start_time from dual;
                           else
                                  l_persLvl := false;
                           end if;


                -- Hierarchy Entry
                m_hier_en.DimensionId := m_dimension_en.DimensionId;
                m_hier_en.EPBId := l_hier;
                m_hier_en.HierType := zpb_aw.interp ('shw '||l_dim_ecm.HierTypeRel);

                m_hier_en.PersCWMName := zpb_metadata_names.get_hierarchy_cwm2_name('PRS', l_dim, l_hier);
                m_hier_en.SharCWMName := zpb_metadata_names.get_hierarchy_cwm2_name(p_sharedAw, l_dim, l_hier);

                -- Hierarchy Tables
                -- Have to get the Primary Key before we insert the entry because sub-entries
                -- need to reference entry
                begin
                    select table_id into m_hr_shar_table_en.tableId
                    from zpb_tables
                    where table_id = (select shar_table_id
                                      from zpb_hierarchies
                                      where dimension_id = m_dimension_en.DimensionId and
                                            pers_cwm_name = m_hier_en.PersCWMName);
                    m_shar_table_exists := false;

                exception
                  when NO_DATA_FOUND then
                  SELECT zpb_tables_seq.NEXTVAL INTO m_hr_shar_table_en.tableId  FROM DUAL;

                                  m_shar_table_exists := true;
                end;

                begin

                                        -- if the hierarchy has a personal level, the table name will be different
                                    if l_persLvl = true then

                                                select table_id into m_hr_pers_table_en.tableId
                                                from zpb_tables
                                                where table_name = m_hr_pers_table_en.TableName and
                                                          bus_area_id = bus_area_id_num;

                                         else
                                    select table_id into m_hr_pers_table_en.tableId
                        from zpb_tables
                        where table_id = (select pers_table_id
                                          from   zpb_hierarchies
                                          where  dimension_id = m_dimension_en.DimensionId and
                                                 pers_cwm_name = m_hier_en.PersCWMName);
                                        end if;

                                m_pers_table_exists :=false;

                exception
                 when NO_DATA_FOUND then
                 SELECT zpb_tables_seq.NEXTVAL INTO m_hr_pers_table_en.tableId  FROM DUAL;
                 m_pers_table_exists :=true;
                end;

--                          dbms_output.put_line('Hier Shar Table ID: ' ||  m_hr_shar_table_en.tableId );
--                          dbms_output.put_line('Hier Pers Table ID: ' ||  m_hr_pers_table_en.tableId );

                m_hier_en.SharTableId := m_hr_shar_table_en.tableId;
                m_hier_en.PersTableId := m_hr_pers_table_en.tableId;

                -- If we are building MD for a personal-personal hierarchy, do not update
                                -- zpb_hierarchies as we do not want to store personal-personal table id there
                    if p_type='PERSONAL' then
                                        select hierarchy_id into m_hierarchy_id
                                        from   zpb_hierarchies
                    where  dimension_id = m_dimension_en.DimensionId and
                                          pers_cwm_name = m_hier_en.PersCWMName;
                                else
                                        m_hierarchy_id := insertHierarchyRecord(m_hier_en);
                                end if;


                m_hier_tl_en.HierarchyId := m_hierarchy_id;
                m_hier_tl_en.Language := 'US';

                -- Insert Hierarchy TL Entry
                htld_i := 1;

                zpb_aw.execute ('push '||l_aw||l_global_ecm.LangDim);

                                loop -- LOOP OVER ALL LANGUAGES

                                        htld_j    := instr (l_langs, ' ', htld_i);
                                        if (htld_j = 0) then
                                                        l_lang := substr (l_langs, htld_i);
                                        else
                                                        l_lang := substr (l_langs, htld_i, htld_j-htld_i);
                                                        htld_i     := htld_j+1;
                                        end if;

                                        zpb_aw.execute('lmt '||l_aw||l_global_ecm.LangDim||' to '''||l_lang||'''');

                                        if (zpb_aw.interpbool('shw exists ('''||l_aw||l_dim_ecm.HierVersLdscVar||''')')) then
                                           m_hier_tl_en.Name := zpb_aw.interp('shw '||l_aw||l_dim_ecm.HierVersLdscVar);
                                           if (m_hier_tl_en.Name is null or m_hier_tl_en.Name = 'NA') then
                                                  m_hier_tl_en.Name := zpb_aw.interp('shw '||l_aw||l_dim_ecm.HierLdscVar);
                                                else
                                                  m_hier_tl_en.Name := zpb_aw.interp('shw joinchars('||l_aw||l_dim_ecm.HierLdscVar||
                                                         ' '': '' '||l_dim_ecm.HierVersLdscVar||')');
                                           end if;
                                         else
                                           m_hier_tl_en.Name := zpb_aw.interp('shw '||l_aw||l_dim_ecm.HierLdscVar);
                                        end if;

                                        m_hier_tl_en.LongName :=m_hier_tl_en.Name;
                                        m_hier_tl_en.PluralName :=m_hier_tl_en.Name;
                                        m_hier_tl_en.PluralLongName :=m_hier_tl_en.Name;
                                        m_hier_tl_en.Language:=l_lang;

                                        insertHierarchyTLRecord(m_hier_tl_en);

                exit when htld_j = 0;
                end loop; -- End looping over Languages

                                zpb_aw.execute ('pop '||l_aw||l_global_ecm.LangDim);

                            -- Set Hierarchy Table Types
                                m_hr_pers_table_en.tableType:='HIERARCHY';
                                m_hr_shar_table_en.tableType:='HIERARCHY';

                l_lvlhier := l_hier;


               --
               -- Get the Levels:
               --
               li          := 1;
               l_levels    := zpb_aw.interp('shw CM.GETDIMVALUES('''||l_aw||
                                            l_dim_ecm.LevelDim||''', YES)');
                           -- initialize level order , used for parentage
                           m_level_order := 0;
               loop -- Loop over all levels for hierarchy
                  lj    := instr (l_levels, ' ', li);
                  if (lj = 0) then
                     l_level := substr (l_levels, li);
                   else
                     l_level := substr (l_levels, li, lj-li);
                     li      := lj+1;
                  end if;

--                                dbms_output.put_line('Looping for level  ' || l_level);

                  m_level_order := m_level_order + 1;

                  zpb_aw.execute('lmt '||l_aw||l_dim_ecm.LevelDim||' to '''||
                                 l_level||'''');

                  --
                  -- Check to see if any members are at this level:
                  --
                  zpb_aw.execute('lmt '||l_aw||l_dim_data.ExpObj||' to '||
                                 l_aw||l_dim_ecm.HOrderVS);

                  zpb_aw.execute ('lmt '||l_aw||l_dim_data.ExpObj||' keep '||
                                  l_aw||l_dim_ecm.LevelRel);
                  l_length := to_number(zpb_aw.interp('shw convert(statlen ('||
                                l_aw||l_dim_data.ExpObj||') text 0 no no)'));
                  if (l_length > 0) then

                    -- initialize Level Entry
                    m_level_en.DimensionId := m_dimension_en.DimensionId;
                    m_level_en.EPBId := l_level;

                    m_level_en.PersCWMName := zpb_metadata_names.get_level_cwm2_name('PRS', l_dim, l_lvlHier, l_level);
                    m_level_en.SharCWMName := zpb_metadata_names.get_level_cwm2_name(p_sharedAw, l_dim, l_lvlHier, l_level);

                    -- Level Column Entries
                    m_pers_column_en.TableId := m_hr_pers_table_en.TableId;
                    m_shar_column_en.TableId := m_hr_shar_table_en.TableId;

                    m_pers_column_en.columnType :='LEVEL_COLUMN';
                    m_shar_column_en.columnType :='LEVEL_COLUMN';

                    m_pers_column_en.columnName := zpb_metadata_names.get_level_column(l_dim, l_level);
                    m_shar_column_en.columnName := zpb_metadata_names.get_level_column(l_dim, l_level);

                    -- Initialize Hierarchy To Level Mapping Entry
                    m_hier_level_en.SharColId := insertColumnRecord(m_shar_column_en);
                    m_hier_level_en.PersColId := insertColumnRecord(m_pers_column_en);

                    -- Personal Level Check
                    if (p_type = 'PERSONAL' and upper(zpb_aw.interp('shw '||
                                   l_aw||l_dim_ecm.LevelPersVar)) = 'YES') then
                        l_persLvl := true;
                        m_level_en.PersLevelFlag := 'Y';
                    else
                        m_level_en.PersLevelFlag := 'N';
                    end if;

                    -- insert level entry
--                                      dbms_output.put_line('Inserting level  ' || m_level_en.EPBId);
                    m_level_id := insertLevelRecord(m_level_en);

                    -- insert level TL entry
                    m_level_tl_en.LevelId := m_level_id;

                    zpb_aw.execute ('push '||l_aw||l_global_ecm.LangDim);
                                         htld_i := 1;

                    loop -- LOOP OVER ALL LANGUAGES
                        htld_j    := instr (l_langs, ' ', htld_i);
                        if (htld_j = 0) then
                           l_lang := substr (l_langs, htld_i);
                        else
                           l_lang := substr (l_langs, htld_i, htld_j-htld_i);
                           htld_i     := htld_j+1;
                        end if;

                        zpb_aw.execute('lmt '||l_aw||l_global_ecm.LangDim||' to '''||
                                l_lang||'''');

                        -- Initialize Level TL Entry
                        m_level_tl_en.Name := zpb_aw.interp('shw '||l_aw||l_dim_ecm.LevelLdscVar);
                        m_level_tl_en.PluralLongName :=  zpb_aw.interp('shw '||l_aw||l_dim_ecm.LevelPlLdscVar);
                        m_level_tl_en.LongName := m_level_tl_en.Name;
                        m_level_tl_en.PluralName := m_level_tl_en.PluralLongName;
                        m_level_tl_en.Language := l_lang;
                        insertLevelTLRecord(m_level_tl_en);

                        exit when htld_j = 0;
                     end loop; -- End looping over Languages

                                         zpb_aw.execute ('pop '||l_aw||l_global_ecm.LangDim);

                     m_hier_level_en.HierId  := m_hierarchy_id;
                     m_hier_level_en.LevelId := m_level_id;

                     -- insert hier-level entry
                     m_hier_level_en.LevelOrder := m_level_order;

                        -- If we are building MD for a personal-personal hierarchy, do not update
                                        -- zpb_hier_levels as we do not want to store personal-personal table column id there
                        if (p_type='PERSONAL' and m_level_en.PersLevelFlag='Y') or p_type='SHARED' then
                        m_hier_level_id := insertHierLevelRecord(m_hier_level_en);
                                        end if;

                        end if; -- end of members at level if

                  exit when lj = 0;
               end loop; -- End level loop

               --
               -- Check if there are personal levels.  If so, go against
               -- the personal hierarchy view:
               --

                   -- this is the name of the hierarchy table

               if (l_persLvl) then
                               m_hr_pers_table_en.TableName := zpb_metadata_names.get_dimension_view
                     (p_aw, 'PERSONAL', l_dim, l_hier);
                               m_hr_shar_table_en.TableName := zpb_metadata_names.get_dimension_view
                     (p_sharedAW, 'PERSONAL', l_dim, l_hier);

                                        -- clean up personal-personal hierarchy table columns that have not been updated here
                                        -- these must be removed personal levels
                                        delete zpb_columns
                                        where  table_id = m_hr_pers_table_en.TableId and
                                                   last_update_date < l_pp_hiert_start_time;

               else
                               m_hr_pers_table_en.TableName := zpb_metadata_names.get_dimension_view
                     (p_sharedAW, 'PERSONAL', l_dim, l_hier);
                               m_hr_shar_table_en.TableName := zpb_metadata_names.get_dimension_view
                     (p_sharedAW, 'SHARED', l_dim, l_hier);
               end if;

                       -- Insert Table Record For Hierarchy
                       m_table_id := insertTableRecord(m_hr_pers_table_en, m_pers_table_exists);
                       m_table_id := insertTableRecord(m_hr_shar_table_en, m_shar_table_exists);

                                --insert static hierarchy table columns defined above
                        m_hr_pers_col_memCol.TableId :=m_hr_pers_table_en.tableId;
                        m_hr_shar_col_memCol.TableId :=m_hr_shar_table_en.tableId;
                        m_hr_pers_col_gidCol.TableId :=m_hr_pers_table_en.tableId;
                        m_hr_shar_col_gidCol.TableId :=m_hr_shar_table_en.tableId;
                        m_hr_shar_col_parentCol.TableId :=m_hr_shar_table_en.tableId;
                        m_hr_pers_col_parentCol.TableId :=m_hr_pers_table_en.tableId;
                        m_hr_shar_col_pgidCol.TableId :=m_hr_shar_table_en.tableId;
                        m_hr_pers_col_pgidCol.TableId :=m_hr_pers_table_en.tableId;
                        m_hr_pers_col_orderCol.TableId :=m_hr_pers_table_en.tableId;
                        m_hr_shar_col_orderCol.TableId :=m_hr_shar_table_en.tableId;

                                                m_column_id:=insertColumnRecord(m_hr_pers_col_memCol);
                                                m_column_id:=insertColumnRecord(m_hr_shar_col_memCol);

                                                m_column_id:=insertColumnRecord(m_hr_pers_col_gidCol);
                                                m_column_id:=insertColumnRecord(m_hr_shar_col_gidCol);

                                                m_column_id:=insertColumnRecord(m_hr_shar_col_parentCol);
                                m_column_id:=insertColumnRecord(m_hr_pers_col_parentCol);

                                m_column_id:=insertColumnRecord(m_hr_shar_col_pgidCol);
                                m_column_id:=insertColumnRecord(m_hr_pers_col_pgidCol);

                                m_column_id:=insertColumnRecord(m_hr_pers_col_orderCol);
                                m_column_id:=insertColumnRecord(m_hr_shar_col_orderCol);

               done := true;
            end if; -- Does this hierarchy have members check

            exit when hj = 0;
         end loop; -- End looping over Hierarchies

         zpb_aw.execute ('pop '||l_aw||l_dim_ecm.LevelDim);
         zpb_aw.execute ('pop '||l_aw||l_dim_ecm.HierDim);

      end if;


      if (done = false) then
         -- No Hierarchies exist for Dimension,
         -- Create Null hierarchy:

                m_hier_en.DimensionId := m_dimension_en.DimensionId;
                m_hier_en.EPBId := 'NULL_GID';
                m_hier_en.HierType := 'NULL';
                m_hier_en.PersCWMName := zpb_metadata_names.get_hierarchy_cwm2_name('PRS', l_dim);
                m_hier_en.SharCWMName := zpb_metadata_names.get_hierarchy_cwm2_name(p_sharedAw, l_dim);

         -- Null Hierarchy Table Entry
                m_hr_shar_table_en.TableName := zpb_metadata_names.get_dimension_view(p_sharedAW, 'SHARED', l_dim);
            m_hr_pers_table_en.TableName := zpb_metadata_names.get_dimension_view(p_sharedAW, 'PERSONAL', l_dim);

                m_hr_shar_table_en.AWName := p_sharedAw;
                m_hr_pers_table_en.AWName := p_sharedAw;

                m_hr_shar_table_en.TableType := 'HIERARCHY';
                m_hr_pers_table_en.TableType := 'HIERARCHY';

                -- if DIMENSION table already exists for this dimension, just point the null hierarchy table to this table
                -- otherwise create the new null hierarchy table of type HIERARCHY
                begin

                        select table_id into m_hier_en.SharTableId
                        from zpb_tables
                        where  table_name = m_hr_shar_table_en.TableName and
                                   bus_area_id = bus_area_id_num and
                                   table_type = 'DIMENSION';

                exception
                        when NO_DATA_FOUND then
                        m_hier_en.SharTableId := insertTableRecord(m_hr_shar_table_en);
                end;

                begin

                        select table_id into m_hier_en.PersTableId
                        from zpb_tables
                        where  table_name = m_hr_pers_table_en.TableName and
                                   bus_area_id = bus_area_id_num and
                                   table_type = 'DIMENSION';
                exception
                        when NO_DATA_FOUND then
                        m_hier_en.PersTableId := insertTableRecord(m_hr_pers_table_en);
                end;

                -- Insert Null Hierarchy Record
                m_hierarchy_id := insertHierarchyRecord(m_hier_en);

                -- Insert Null Hierarchy TL Record
                m_hier_tl_en.HierarchyId := m_hierarchy_id;


        zpb_aw.execute ('push '||l_aw||l_global_ecm.LangDim);
                htld_i := 1;

        loop -- LOOP OVER ALL LANGUAGES
            htld_j    := instr (l_langs, ' ', htld_i);
            if (htld_j = 0) then
                l_lang := substr (l_langs, htld_i);
            else
                l_lang := substr (l_langs, htld_i, htld_j-htld_i);
                htld_i     := htld_j+1;
            end if;

                    zpb_aw.execute('lmt '||l_aw||l_global_ecm.LangDim||' to '''||
                       l_lang||'''');

                    m_hier_tl_en.Name := 'Null Hierarchy';
                    m_hier_tl_en.LongName :=m_hier_tl_en.Name;
                    m_hier_tl_en.PluralName :=m_hier_tl_en.Name;
                    m_hier_tl_en.PluralLongName :=m_hier_tl_en.Name;
                    m_hier_tl_en.Language:=l_lang;

                    insertHierarchyTLRecord(m_hier_tl_en);


            exit when htld_j = 0;
         end loop; -- End looping over Languages
         zpb_aw.execute ('pop '||l_aw||l_global_ecm.LangDim);

                -- insert static hierarchy columns for null hierarchy

        m_hr_pers_col_memCol.TableId :=m_hier_en.PersTableId;
        m_hr_shar_col_memCol.TableId :=m_hier_en.SharTableId;
        m_hr_pers_col_gidCol.TableId :=m_hier_en.PersTableId;
        m_hr_shar_col_gidCol.TableId :=m_hier_en.SharTableId;
        m_hr_shar_col_parentCol.TableId :=m_hier_en.SharTableId;
        m_hr_pers_col_parentCol.TableId :=m_hier_en.PersTableId;
        m_hr_shar_col_pgidCol.TableId :=m_hier_en.SharTableId;
        m_hr_pers_col_pgidCol.TableId :=m_hier_en.PersTableId;

        m_column_id:=insertColumnRecord(m_hr_pers_col_memCol);
        m_column_id:=insertColumnRecord(m_hr_shar_col_memCol);

        m_column_id:=insertColumnRecord(m_hr_pers_col_gidCol);
        m_column_id:=insertColumnRecord(m_hr_shar_col_gidCol);

        m_column_id:=insertColumnRecord(m_hr_shar_col_parentCol);
        m_column_id:=insertColumnRecord(m_hr_pers_col_parentCol);

        m_column_id:=insertColumnRecord(m_hr_shar_col_pgidCol);
        m_column_id:=insertColumnRecord(m_hr_pers_col_pgidCol);

        -- initialize Level entry
        m_level_en.DimensionId := m_dimension_en.DimensionId;
        m_level_en.EPBId := '0';
        m_level_en.PersCWMName := zpb_metadata_names.get_level_cwm2_name('PRS', l_dim);
        m_level_en.SharCWMName := zpb_metadata_names.get_level_cwm2_name(p_sharedAw, l_dim);
        m_level_en.PersLevelFlag :='N';

        -- initialize Level TL entry
        m_level_tl_en.Name := 'NULL_HIER_LEVEL';
        m_level_tl_en.LongName :=m_level_tl_en.Name;
        m_level_tl_en.PluralName :=m_level_tl_en.Name;
        m_level_tl_en.PluralLongName :=m_level_tl_en.Name;

                    -- Level Column Entries
                        m_pers_column_en.TableId := m_hier_en.PersTableId;
                        m_shar_column_en.TableId := m_hier_en.SharTableId;

                        m_pers_column_en.columnType := 'LEVEL_COLUMN';
                        m_shar_column_en.columnType := 'LEVEL_COLUMN';

                        m_pers_column_en.columnName := zpb_metadata_names.get_level_column(l_dim, null);
                        m_shar_column_en.columnName := zpb_metadata_names.get_level_column(l_dim, null);

                        -- Insert Column Entries
                m_hier_level_en.SharColId := insertColumnRecord(m_shar_column_en);
                m_hier_level_en.PersColId := insertColumnRecord(m_pers_column_en);

                        -- Insert Level Entry
                m_level_id := insertLevelRecord(m_level_en);

                        -- Insert Level TL Entry
                        m_level_tl_en.LevelId := m_level_id;
                        m_level_tl_en.Language :='US';
                        insertLevelTLRecord(m_level_tl_en);

                        -- Hierarchy Level Mapping Entry
                        m_hier_level_en.LevelId := m_level_id;
                    m_hier_level_en.HierId := m_hierarchy_id;

                    -- insert hier-level entry
                        m_hier_level_en.LevelOrder:=1;
                m_hier_level_id := insertHierLevelRecord(m_hier_level_en);
      end if;

          -- DIMENSION ATTRIBUTES
      zpb_aw.execute('lmt '||l_aw||l_global_ecm.AttrDim||' to '||l_aw||
                     l_global_attr_ecm.DomainDimRel||' eq lmt ('||l_aw||
                     l_global_ecm.DimDim||' to '''||l_dim||''')');

      l_attrs := zpb_aw.interp ('shw CM.GETDIMVALUES('''||l_aw||
                                l_global_ecm.AttrDim||''' YES)');

      if (l_attrs <> 'NA') then
         ai := 1;
         loop -- Loop over Attributes of the Dimension
            aj := instr (l_attrs, ' ', ai);
            if (aj = 0) then
               l_attr := substr (l_attrs, ai);
             else
               l_attr := substr (l_attrs, ai, aj-ai);
               ai     := aj+1;
            end if;

            l_attr_ecm := zpb_ecm.get_attr_ecm(l_attr, l_global_attr_ecm, p_aw);

            zpb_aw.execute ('lmt '||l_aw||l_global_ecm.AttrDim||' to '''|| l_attr||'''');

            -- explicitly exclude timespan and non-displayable attributes
                        if (instr (l_attr, 'TIMESPAN') = 0 and (zpb_aw.interpbool('shw exists(''' || l_aw || l_global_attr_ecm.AttrDisplayVar || ''')')
                 and zpb_aw.interpbool('shw '||l_aw|| l_global_attr_ecm.AttrDisplayVar))) then

                           l_attrId :=zpb_aw.interp('shw '||l_aw||
                                        l_global_attr_ecm.RangeDimRel);

               -- create attribute entry
               m_attr_en.DimensionId := m_dimension_en.DimensionId;
               m_attr_en.EPBId := l_attr;
               m_attr_en.Type :='DIMENSION_ATTRIBUTE';
               m_attr_en.PersCWMName :=  zpb_metadata_names.get_attribute_cwm2_name('PRS',l_dim,l_attr);
               m_attr_en.SharCWMName :=  l_attr;
               m_attr_en.Label := zpb_aw.interp('shw '||l_aw||'ATTRLABEL');
                           m_attr_en.FEMAttrId := null;

                           -- get the FEM attribute label from the namefragment
                           -- if run into parsing problem, give up
                           begin
                                l_attr_nameFrag := zpb_aw.interp('shw '||l_aw|| l_global_attr_ecm.NameFragVar);
                                        m_attr_en.FEMAttrId := to_number(substr(l_attr_nameFrag, 2));
                           exception
                        when others then
                                null;
                           end;
               -- Attribute Column
               m_pers_column_en.TableId := m_dimension_en.PersTableId;
               m_shar_column_en.TableId := m_dimension_en.SharTableId;

               m_pers_column_en.columnType := 'ATTRIBUTE_COLUMN';
               m_shar_column_en.columnType := 'ATTRIBUTE_COLUMN';

               m_pers_column_en.columnName := zpb_metadata_names.get_attribute_column(l_dim, l_attr);
               m_shar_column_en.columnName := zpb_metadata_names.get_attribute_column(l_dim, l_attr);

               m_pers_column_en.AWName := l_attr_ecm.LdscFrm;
               m_shar_column_en.AWNAme := l_attr_ecm.LdscFrm;

                                  -- process attribute range dimension
                              -- insert it into dimension table if it does not already exist there

                              m_attr_rangedim_en.EPBId := l_attrId;



--                                      begin

--                                              select dimension_id into m_attr_rangedim_en.DimensionId
--                                              from  zpb_dimensions
--                                              where bus_area_id = bus_area_id_num and
--                                                        epb_id = m_attr_rangedim_en.EPBId;

--                                      exception
--                                              when NO_DATA_FOUND then
--                                              SELECT zpb_dimensions_seq.NEXTVAL INTO m_attr_rangedim_en.DimensionId  FROM DUAL;
--                                      end;

                                l_range_dim_data := zpb_ecm.get_dimension_data (m_attr_rangedim_en.EPBId, p_aw);

                                m_attr_rangedim_en.PersCWMName := zpb_metadata_names.get_dimension_cwm2_name('PRS', l_attrId);
                                m_attr_rangedim_en.SharCWMName := zpb_metadata_names.get_dimension_cwm2_name(p_sharedAw, l_attrId);
                                m_attr_rangedim_en.SharTableId :=0;
                                m_attr_rangedim_en.AWName := l_range_dim_data.ExpObj;
                                m_attr_rangedim_en.IsDatadim :='N';

                                        -- Attribute Range Dimension Table
                                        -- Feb 02 change from l_attrId to l_attr per Greg
               m_attr_rangetbl_en.TableName := zpb_metadata_names.get_dimension_view
      (p_sharedAW, 'PERSONAL', l_attr);
               m_attr_rangetbl_en.tableType := 'ATTRIBUTE';
               m_attr_rangetbl_en.AWName := p_aw;

               -- shared attribute range dimension table
               m_attr_range_sh_tbl_en.TableName := zpb_metadata_names.get_dimension_view(p_sharedAW, 'SHARED', l_attr);
               m_attr_range_sh_tbl_en.tableType := 'ATTRIBUTE';
               m_attr_range_sh_tbl_en.AWName := p_sharedAW;

               m_attr_rangecol_en.TableId := insertTableRecord(m_attr_rangetbl_en);

               m_attr_range_sh_col_en.TableId := insertTableRecord(m_attr_range_sh_tbl_en);

               m_attr_rangedim_en.PersTableId := m_attr_rangecol_en.TableId;

               m_attr_rangedim_en.SharTableId := m_attr_range_sh_col_en.TableId;

               -- Insert Attribute Range Dimension Entry
               m_attr_rangedim_en.DimensionId := insertDimensionRecord(m_attr_rangedim_en);
               m_attr_rangedim_tl_en.DimensionId := m_attr_rangedim_en.DimensionId;
               m_attr_en.RangeDimId := m_attr_rangedim_en.DimensionId;
               m_attr_rangehier_en.DimensionId := m_attr_rangedim_en.DimensionId;

               -- Attribute Range Dimension Hierarchy
               m_attr_rangehier_en.EPBID :='0';
               m_attr_rangehier_en.PersCWMName := zpb_metadata_names.get_hierarchy_cwm2_name('PRS', l_attr);
               m_attr_rangehier_en.SharCWMName := zpb_metadata_names.get_hierarchy_cwm2_name(p_sharedAw, l_attr);
               m_attr_rangehier_en.HierType := 'NULL';

               m_attr_rangehier_en.SharTableId := m_attr_range_sh_col_en.TableId;
               m_attr_rangehier_en.PersTableId := m_attr_rangecol_en.TableId;

               -- Attribute Range Dimension Column - MEMBER
               m_attr_rangecol_en.columnType := 'MEMBER_COLUMN';
               m_attr_rangecol_en.columnName := zpb_metadata_names.get_dimension_column(l_attr);
               m_attr_rangecol_en.AWName := 'NA';
               m_column_id := insertColumnRecord(m_attr_rangecol_en);

               m_attr_range_sh_col_en.columnType := 'MEMBER_COLUMN';
               m_attr_range_sh_col_en.columnName := zpb_metadata_names.get_dimension_column(l_attr);
               m_attr_range_sh_col_en.AWName := 'NA';
               m_column_id := insertColumnRecord(m_attr_range_sh_col_en);


               -- Attribute Range Dimension Column - GID
               m_attr_rangecol_en.columnType := 'GID_COLUMN';
               m_attr_rangecol_en.columnName := zpb_metadata_names.get_dim_gid_column(l_attr);
               m_column_id := insertColumnRecord(m_attr_rangecol_en);

               m_attr_range_sh_col_en.columnType := 'GID_COLUMN';
               m_attr_range_sh_col_en.columnName := zpb_metadata_names.get_dim_gid_column(l_attr);
               m_column_id := insertColumnRecord(m_attr_range_sh_col_en);

               -- Attribute Range Dimension Column - PGID
               m_attr_rangecol_en.columnType := 'PGID_COLUMN';
               m_attr_rangecol_en.columnName := zpb_metadata_names.get_dim_pgid_column(l_attr);
               m_column_id := insertColumnRecord(m_attr_rangecol_en);

               m_attr_range_sh_col_en.columnType := 'PGID_COLUMN';
               m_attr_range_sh_col_en.columnName := zpb_metadata_names.get_dim_pgid_column(l_attr);
               m_column_id := insertColumnRecord(m_attr_range_sh_col_en);

               -- Attribute Range Dimension Column - PARENT
               m_attr_rangecol_en.columnType := 'PARENT_COLUMN';
               m_attr_rangecol_en.columnName := zpb_metadata_names.get_dim_parent_column(l_attr);
               m_column_id := insertColumnRecord(m_attr_rangecol_en);

               m_attr_range_sh_col_en.columnType := 'PARENT_COLUMN';
               m_attr_range_sh_col_en.columnName :=
                  zpb_metadata_names.get_dim_parent_column(l_attr);
               m_column_id := insertColumnRecord(m_attr_range_sh_col_en);

               -- Attribute Range Dimension Level
               m_attr_rangelev_en.DimensionId :=m_attr_rangedim_en.DimensionId;

               m_attr_rangelev_en.EPBId :='0';
               m_attr_rangelev_en.PersCWMName := zpb_metadata_names.get_level_cwm2_name('PRS', l_attr);
               m_attr_rangelev_en.SharCWMName := zpb_metadata_names.get_level_cwm2_name(p_sharedAw, l_attr);
               m_attr_rangelev_en.PersLevelFlag :='N';

               -- Attribute Range Dimension Hierarchy to Level Mapping
               m_attr_rangehl_en.LevelId := insertLevelRecord(m_attr_rangelev_en);

               -- Attribute Range Dimension Hiearchy Level
               m_attr_rangecol_en.columnName := zpb_metadata_names.get_level_column(l_attr, null);
               m_attr_rangecol_en.columnType := 'LEVEL_COLUMN';
               m_attr_rangecol_en.AWName :='';
               m_attr_rangehl_en.LevelOrder := 1;
               m_attr_rangehl_en.PersColId := insertColumnRecord(m_attr_rangecol_en);

               m_attr_range_sh_col_en.columnName := zpb_metadata_names.get_level_column(l_attr, null);
               m_attr_range_sh_col_en.columnType := 'LEVEL_COLUMN';
               m_attr_range_sh_col_en.AWName :='';
               m_attr_rangehl_en.LevelOrder := 1;
               m_attr_rangehl_en.SharColId := insertColumnRecord(m_attr_range_sh_col_en);

               -- attribute column goes into the same hierarchy table

               m_attr_rangeattr_en.DimensionId := m_attr_rangedim_en.DimensionId;
               m_attr_rangeattr_en.EPBId :='';
               m_attr_rangeattr_en.Type := 'VALUE_NAME_ATTRIBUTE';
               m_attr_rangeattr_en.PersCWMName := zpb_metadata_names.get_dim_long_name_cwm2('PRS',l_attr);
               m_attr_rangeattr_en.SharCWMName := zpb_metadata_names.get_dim_long_name_cwm2(p_sharedAw,l_attr);

               m_attr_rangeattr_en.FEMAttrId := null;
               m_attr_rangeattr_en.Label :=' ';

               m_attr_rangeatc_en.AttributeId := insertAttributeRecord(m_attr_rangeattr_en);
               m_attr_rangeatc_en.TableId := m_attr_rangehier_en.PersTableId;

               m_attr_sh_rangeatc_en.AttributeId := m_attr_rangeatc_en.AttributeId;
               m_attr_sh_rangeatc_en.TableId := m_attr_rangehier_en.SharTableId;

               m_attr_rangecol_en.columnType := 'LNAME_COLUMN';
               m_attr_rangecol_en.columnName := zpb_metadata_names.get_dim_long_name_column(l_attr);
               m_attr_rangeatc_en.ColumnId := insertColumnRecord(m_attr_rangecol_en);

               m_attr_range_sh_col_en.columnType := 'LNAME_COLUMN';
               m_attr_range_sh_col_en.columnName := zpb_metadata_names.get_dim_long_name_column(l_attr);
               m_attr_sh_rangeatc_en.ColumnId := insertColumnRecord(m_attr_range_sh_col_en);

               m_attr_table_col_id := insertAttrTableColRecord(m_attr_rangeatc_en);

               m_attr_table_col_id := insertAttrTableColRecord(m_attr_sh_rangeatc_en);

               m_attr_rangeattr_en.DimensionId := m_attr_rangedim_en.DimensionId;
               m_attr_rangeattr_en.EPBId :='';
               m_attr_rangeattr_en.Type := 'SHORT_VALUE_NAME_ATTRIBUTE';
               m_attr_rangeattr_en.FEMAttrId := null;
               m_attr_rangeattr_en.Label :=' ';

               -- previously we had no shared attribute range dimensions and the personal names for their attributes
               -- was actually using the shared convention.  Now that we do have shared attribute range dimensions,
               -- personal and shared names will use their appropriate conventions.
               m_attr_rangeattr_en.PersCWMName := zpb_metadata_names.get_dim_short_name_cwm2('PRS',l_attr);
               m_attr_rangeattr_en.SharCWMName := zpb_metadata_names.get_dim_short_name_cwm2(p_sharedAW,l_attr);


               m_attr_rangeatc_en.AttributeId := insertAttributeRecord(m_attr_rangeattr_en);
               m_attr_rangeatc_en.TableId := m_attr_rangehier_en.PersTableId;

               m_attr_sh_rangeatc_en.AttributeId := m_attr_rangeatc_en.AttributeId;
               m_attr_sh_rangeatc_en.TableId := m_attr_rangehier_en.SharTableId;

               m_attr_rangecol_en.columnType := 'SNAME_COLUMN';
               m_attr_rangecol_en.columnName := zpb_metadata_names.get_dim_short_name_column(l_attr);
               m_attr_rangeatc_en.ColumnId := insertColumnRecord(m_attr_rangecol_en);

               m_attr_range_sh_col_en.columnType := 'SNAME_COLUMN';
               m_attr_range_sh_col_en.columnName := zpb_metadata_names.get_dim_short_name_column(l_attr);
               m_attr_sh_rangeatc_en.ColumnId := insertColumnRecord(m_attr_range_sh_col_en);

               m_attr_table_col_id := insertAttrTableColRecord(m_attr_rangeatc_en);

               m_attr_table_col_id := insertAttrTableColRecord(m_attr_sh_rangeatc_en);

                                        -- Insert dimension language entries

                                htld_i := 1;

                                zpb_aw.execute ('push '||l_aw||l_global_ecm.LangDim);

                                loop -- LOOP OVER ALL LANGUAGES
                                htld_j    := instr (l_langs, ' ', htld_i);
                                if (htld_j = 0) then
                                        l_lang := substr (l_langs, htld_i);
                                else
                                        l_lang := substr (l_langs, htld_i, htld_j-htld_i);
                                        htld_i     := htld_j+1;
                                end if;

                                    zpb_aw.execute('lmt '||l_aw||l_global_ecm.LangDim||' to '''||
                           l_lang||'''');

                                  l_range_dim_data := zpb_ecm.get_dimension_data (m_attr_rangedim_en.EPBId, p_aw);

                                  m_attr_rangedim_tl_en.Name := l_range_dim_data.Sdsc;
                                  m_attr_rangedim_tl_en.LongName := l_range_dim_data.Ldsc;
                                  m_attr_rangedim_tl_en.PluralName := l_range_dim_data.PlSdsc;
                                  m_attr_rangedim_tl_en.PluralLongName := l_range_dim_data.PlLdsc;
                                                m_attr_rangedim_tl_en.Language:=l_lang;
                                                                  insertDimensionsTLRecord(m_attr_rangedim_tl_en);

                                exit when htld_j = 0;
                                end loop; -- End looping over Languages
                                zpb_aw.execute ('pop '||l_aw||l_global_ecm.LangDim);

                                        -- Insert Attribute Range Dimension Hierarchy Entry
                                        m_attr_rangehl_en.HierId := insertHierarchyRecord(m_attr_rangehier_en);

                                        -- Insert Attribute Range Dimension Hierarchy to Level Mapping Entry
                                        m_hier_level_id := insertHierLevelRecord(m_attr_rangehl_en);

               -- insert attribute, column, and attr_table_col records
               m_attr_table_col_en.attributeId := insertAttributeRecord(m_attr_en);

                   -- create attribute tl entry
                   m_attr_tl_en.AttributeId := m_attr_table_col_en.attributeId;

                htld_i := 1;

                zpb_aw.execute ('push '||l_aw||l_global_ecm.LangDim);

                loop -- LOOP OVER ALL LANGUAGES
                htld_j    := instr (l_langs, ' ', htld_i);
                if (htld_j = 0) then
                        l_lang := substr (l_langs, htld_i);
                else
                        l_lang := substr (l_langs, htld_i, htld_j-htld_i);
                        htld_i     := htld_j+1;
                end if;

                zpb_aw.execute('lmt '||l_aw||l_global_ecm.LangDim||' to '''||
                           l_lang||'''');

                                m_attr_tl_en.Name := zpb_aw.interp('shw '||l_aw||l_global_attr_ecm.LdscVar);
                                m_attr_tl_en.LongName :=m_attr_tl_en.Name;
                                m_attr_tl_en.PluralName :=m_attr_tl_en.Name;
                        m_attr_tl_en.PluralLongName :=m_attr_tl_en.Name;
                                m_attr_tl_en.Language := l_lang;

                                insertAttributesTLRecord(m_attr_tl_en);

                exit when htld_j = 0;
                end loop; -- End looping over Languages
                zpb_aw.execute ('pop '||l_aw||l_global_ecm.LangDim);

               -- pers table relation
               m_attr_table_col_en.tableId := m_dimension_en.PersTableId;
               m_attr_table_col_en.columnId := insertColumnRecord(m_pers_column_en);

               m_attr_table_col_id := insertAttrTableColRecord(m_attr_table_col_en);

               -- shar table relation
               m_attr_table_col_en.tableId := m_dimension_en.SharTableId;
               m_attr_table_col_en.columnId := insertColumnRecord(m_shar_column_en);

               m_attr_table_col_id := insertAttrTableColRecord(m_attr_table_col_en);
           end if;

            exit when aj = 0;
         end loop; -- End Looping Over Attributes
      end if;

          -- Long Name Attribute for Dimension

          m_attr_en.DimensionId := m_dimension_en.DimensionId;
                  m_attr_en.FEMAttrId :=null;
          m_attr_en.RangeDimId := null;
          m_attr_en.EPBId := '';
          m_attr_en.PersCWMName := zpb_metadata_names.get_dim_long_name_cwm2('PERSONAL', l_dim);
          m_attr_en.SharCWMName := zpb_metadata_names.get_dim_long_name_cwm2(p_sharedAw, l_dim);
                  m_attr_en.Label := ' ';
          m_attr_en.Type := 'VALUE_NAME_ATTRIBUTE';

                  m_pers_column_en.TableId := m_dimension_en.PersTableId;
                  m_shar_column_en.TableId := m_dimension_en.SharTableId;

          m_shar_column_en.columnType := 'LNAME_COLUMN';
          m_pers_column_en.columnType := 'LNAME_COLUMN';

          m_shar_column_en.columnName := zpb_metadata_names.get_dim_long_name_column(l_dim);
          m_pers_column_en.columnName := zpb_metadata_names.get_dim_long_name_column(l_dim);

          m_shar_column_en.AWName := l_dim_ecm.LdscVar;
          m_pers_column_en.AWName := l_dim_ecm.LdscVar;

                  m_attr_table_col_en.attributeId := insertAttributeRecord(m_attr_en);

                  -- pers table relation
                  m_attr_table_col_en.tableId := m_dimension_en.PersTableId;
                  m_attr_table_col_en.columnId := insertColumnRecord(m_pers_column_en);

                  m_attr_table_col_id := insertAttrTableColRecord(m_attr_table_col_en);

                  -- shar table relation
                  m_attr_table_col_en.tableId := m_dimension_en.SharTableId;
                  m_attr_table_col_en.columnId := insertColumnRecord(m_shar_column_en);

                  m_attr_table_col_id := insertAttrTableColRecord(m_attr_table_col_en);

                  m_attr_en.DimensionId := m_dimension_en.DimensionId;
          m_attr_en.RangeDimId := null;
          m_attr_en.EPBId := '';
          m_attr_en.PersCWMName := zpb_metadata_names.get_dim_short_name_cwm2('PERSONAL', l_dim);
          m_attr_en.SharCWMName :=  zpb_metadata_names.get_dim_short_name_cwm2(p_sharedAw, l_dim);
          m_attr_en.Type := 'SHORT_VALUE_NAME_ATTRIBUTE';
                  m_attr_en.Label := ' ';

                  m_pers_column_en.TableId := m_dimension_en.PersTableId;
                  m_shar_column_en.TableId := m_dimension_en.SharTableId;

          m_shar_column_en.columnType := 'SNAME_COLUMN';
          m_pers_column_en.columnType := 'SNAME_COLUMN';

          m_shar_column_en.columnName := zpb_metadata_names.get_dim_short_name_column(l_dim);
          m_pers_column_en.columnName := zpb_metadata_names.get_dim_short_name_column(l_dim);

          m_shar_column_en.AWName := l_dim_ecm.MdscVar;
          m_pers_column_en.AWName := l_dim_ecm.MdscVar;

                  m_attr_table_col_en.attributeId := insertAttributeRecord(m_attr_en);

                  -- pers table relation
                  m_attr_table_col_en.tableId := m_dimension_en.PersTableId;
                  m_attr_table_col_en.columnId := insertColumnRecord(m_pers_column_en);

                  m_attr_table_col_id := insertAttrTableColRecord(m_attr_table_col_en);

                  -- shar table relation
                  m_attr_table_col_en.tableId := m_dimension_en.SharTableId;
                  m_attr_table_col_en.columnId := insertColumnRecord(m_shar_column_en);

                  m_attr_table_col_id := insertAttrTableColRecord(m_attr_table_col_en);


      if (l_dim_data.Type = 'TIME') then
         l_dim_time_ecm := zpb_ecm.get_dimension_time_ecm(l_dim, p_aw);

                  m_attr_en.DimensionId := m_dimension_en.DimensionId;
          m_attr_en.FEMAttrId := null;
          m_attr_en.RangeDimId := null;
          m_attr_en.EPBId := 'ENDDATE';
          m_attr_en.PersCWMName := zpb_metadata_names.get_attribute_cwm2_name('PRS',l_dim,'ENDDATE');
          m_attr_en.SharCWMName := 'END DATE';
          m_attr_en.Type := 'ENDDATE_ATTRIBUTE';
          m_attr_en.Label := ' ';

                  m_pers_column_en.TableId := m_dimension_en.PersTableId;
                  m_shar_column_en.TableId := m_dimension_en.SharTableId;

          m_shar_column_en.columnType := 'ENDDATE_COLUMN';
          m_pers_column_en.columnType := 'ENDDATE_COLUMN';

          m_shar_column_en.columnName := zpb_metadata_names.get_dim_enddate_column(l_dim);
          m_pers_column_en.columnName := zpb_metadata_names.get_dim_enddate_column(l_dim);

          m_shar_column_en.AWName := l_dim_time_ecm.EndDateVar;
          m_pers_column_en.AWName := l_dim_time_ecm.EndDateVar;

                  m_attr_table_col_en.attributeId := insertAttributeRecord(m_attr_en);

                   -- pers table relation
                   m_attr_table_col_en.tableId := m_dimension_en.PersTableId;
                   m_attr_table_col_en.columnId := insertColumnRecord(m_pers_column_en);

                   m_attr_table_col_id := insertAttrTableColRecord(m_attr_table_col_en);

                   -- shar table relation
                   m_attr_table_col_en.tableId := m_dimension_en.SharTableId;
                   m_attr_table_col_en.columnId := insertColumnRecord(m_shar_column_en);

                   m_attr_table_col_id := insertAttrTableColRecord(m_attr_table_col_en);

                  m_attr_en.DimensionId := m_dimension_en.DimensionId;
                  m_attr_en.FEMAttrId := null;
          m_attr_en.RangeDimId := null;
          m_attr_en.EPBId := 'TIMESPAN';
          m_attr_en.PersCWMName := zpb_metadata_names.get_attribute_cwm2_name('PRS',l_dim,'TIMESPAN');
          m_attr_en.SharCWMName := 'TIME SPAN';
          m_attr_en.Type := 'TIMESPAN_ATTRIBUTE';
                  m_attr_en.Label := ' ';

                  m_pers_column_en.TableId := m_dimension_en.PersTableId;
                  m_shar_column_en.TableId := m_dimension_en.SharTableId;

          m_shar_column_en.columnType := 'TIMESPAN_COLUMN';
          m_pers_column_en.columnType := 'TIMESPAN_COLUMN';

          m_shar_column_en.columnName := zpb_metadata_names.get_dim_timespan_column(l_dim);
          m_pers_column_en.columnName := zpb_metadata_names.get_dim_timespan_column(l_dim);

          m_shar_column_en.AWName := l_dim_time_ecm.TimeSpanVar;
          m_pers_column_en.AWName := l_dim_time_ecm.TimeSpanVar;

                   m_attr_table_col_en.attributeId := insertAttributeRecord(m_attr_en);

               -- pers table relation
               m_attr_table_col_en.tableId := m_dimension_en.PersTableId;
               m_attr_table_col_en.columnId := insertColumnRecord(m_pers_column_en);

               m_attr_table_col_id := insertAttrTableColRecord(m_attr_table_col_en);

               -- shar table relation
               m_attr_table_col_en.tableId := m_dimension_en.SharTableId;
               m_attr_table_col_en.columnId := insertColumnRecord(m_shar_column_en);

               m_attr_table_col_id := insertAttrTableColRecord(m_attr_table_col_en);

      end if; -- done special attributes for time dimension

         -- build special attributes for line dimension
     if (l_dim_data.Type = 'LINE') then
         l_dim_line_ecm := zpb_ecm.get_dimension_line_ecm(l_dim, p_aw);

                  m_attr_en.DimensionId := m_dimension_en.DimensionId;
          m_attr_en.RangeDimId := null;
                  m_attr_en.FEMAttrId := null;
          m_attr_en.EPBId := 'LINEAGGTIME';
          m_attr_en.PersCWMName := zpb_metadata_names.get_attribute_cwm2_name('PRS',l_dim,'LINEAGGTIME');
          m_attr_en.SharCWMName := zpb_metadata_names.get_attribute_cwm2_name(p_sharedAw,l_dim,'LINEAGGTIME');
          m_attr_en.Type := 'LINEAGG_ATTRIBUTE';
                  m_attr_en.Label := ' ';

                  m_pers_column_en.TableId := m_dimension_en.PersTableId;
                  m_shar_column_en.TableId := m_dimension_en.SharTableId;

          m_shar_column_en.columnType := 'AGGTIME_COLUMN';
          m_pers_column_en.columnType := 'AGGTIME_COLUMN';

          m_shar_column_en.columnName := zpb_metadata_names.get_dim_aggtime_column(l_dim);
          m_pers_column_en.columnName := zpb_metadata_names.get_dim_aggtime_column(l_dim);

          m_shar_column_en.AWName := 'LINEAGGTIME.DL';
          m_pers_column_en.AWName := 'LINEAGGTIME.DL';

                   m_attr_table_col_en.attributeId := insertAttributeRecord(m_attr_en);

               -- pers table relation
               m_attr_table_col_en.tableId := m_dimension_en.PersTableId;
               m_attr_table_col_en.columnId := insertColumnRecord(m_pers_column_en);

               m_attr_table_col_id := insertAttrTableColRecord(m_attr_table_col_en);

               -- shar table relation
               m_attr_table_col_en.tableId := m_dimension_en.SharTableId;
               m_attr_table_col_en.columnId := insertColumnRecord(m_shar_column_en);

               m_attr_table_col_id := insertAttrTableColRecord(m_attr_table_col_en);

                  m_attr_en.DimensionId := m_dimension_en.DimensionId;
          m_attr_en.RangeDimId := null;
                  m_attr_en.FEMAttrId := null;
          m_attr_en.EPBId := 'LINEAGGOTHER';
          m_attr_en.PersCWMName := zpb_metadata_names.get_attribute_cwm2_name('PRS',l_dim,'LINEAGGOTHER');
          m_attr_en.SharCWMName := zpb_metadata_names.get_attribute_cwm2_name(p_sharedAw,l_dim,'LINEAGGOTHER');
          m_attr_en.Type := 'LINEAGG_ATTRIBUTE';
                  m_attr_en.Label := ' ';

                  m_pers_column_en.TableId := m_dimension_en.PersTableId;
                  m_shar_column_en.TableId := m_dimension_en.SharTableId;

          m_shar_column_en.columnType := 'AGGOTHER_COLUMN';
          m_pers_column_en.columnType := 'AGGOTHER_COLUMN';

          m_shar_column_en.columnName := zpb_metadata_names.get_dim_aggother_column(l_dim);
          m_pers_column_en.columnName := zpb_metadata_names.get_dim_aggother_column(l_dim);

          m_shar_column_en.AWName := 'LINEAGGOTHER.DL';
          m_pers_column_en.AWName := 'LINEAGGOTHER.DL';

                   m_attr_table_col_en.attributeId := insertAttributeRecord(m_attr_en);

               -- pers table relation
               m_attr_table_col_en.tableId := m_dimension_en.PersTableId;
               m_attr_table_col_en.columnId := insertColumnRecord(m_pers_column_en);

               m_attr_table_col_id := insertAttrTableColRecord(m_attr_table_col_en);

               -- shar table relation
               m_attr_table_col_en.tableId := m_dimension_en.SharTableId;
               m_attr_table_col_en.columnId := insertColumnRecord(m_shar_column_en);

               m_attr_table_col_id := insertAttrTableColRecord(m_attr_table_col_en);
        end if; -- done special attributes for line dimension

      zpb_aw.execute('pop '||l_aw||l_dim_data.ExpObj);

        -- Insert Dimension Entry
        m_dummy_num := insertDimensionRecord(m_dimension_en, m_dimension_exists);

        -- Insert dimension language entries

         htld_i := 1;

         zpb_aw.execute ('push '||l_aw||l_global_ecm.LangDim);

         loop -- LOOP OVER ALL LANGUAGES
            htld_j    := instr (l_langs, ' ', htld_i);
            if (htld_j = 0) then
               l_lang := substr (l_langs, htld_i);
             else
               l_lang := substr (l_langs, htld_i, htld_j-htld_i);
               htld_i     := htld_j+1;
            end if;

            zpb_aw.execute('lmt '||l_aw||l_global_ecm.LangDim||' to '''||
                           l_lang||'''');

                            l_dim_data := zpb_ecm.get_dimension_data (l_dim, p_aw);
                m_dimension_tl_en.Name := l_dim_data.Sdsc;
                m_dimension_tl_en.LongName := l_dim_data.Ldsc;
                m_dimension_tl_en.PluralName := l_dim_data.PlSdsc;
                m_dimension_tl_en.PluralLongName := l_dim_data.PlLdsc;
                m_dimension_tl_en.Language:=l_lang;
                m_dimension_tl_en.DimensionId :=m_dimension_en.DimensionId;
                insertDimensionsTLRecord(m_dimension_tl_en);

            exit when htld_j = 0;
         end loop; -- End looping over Languages
         zpb_aw.execute ('pop '||l_aw||l_global_ecm.LangDim);

      exit when j=0;
   end loop;

   zpb_aw.execute('pop oknullstatus');

end BUILD_DIMS;

-------------------------------------------------------------------------------
-- BUILD_CUBE -Exposes metadata for a cube (zpb_cubes), its dimensionality
--                              (zpb_cube_dims) and its hierarchies (zpb_cube_hier)
--
-- IN: p_aw       - The AW
--     p_cubeView - The name of the cube
--         p_dims         - Dimensionality of cube
--
-------------------------------------------------------------------------------
procedure BUILD_CUBE(p_aw               in      varchar2,
                     p_cubeView         in      varchar2,
                     p_dims             in      varchar2,
                                 p_cube_type    in              varchar2)
   is

          l_api_name      CONSTANT VARCHAR2(30) := 'BUILD_CUBE';

      l_dim           varchar2(30);
      l_aw            varchar2(30);
      i               number;
      j               number;
      hi              number;
      hj              number;
      l_gid           boolean;
      l_hiers         varchar2(1000);
      l_hier          varchar2(30);
      nl              varchar2(1) := fnd_global.local_chr(10);
      l_dim_ecm       zpb_ecm.dimension_ecm;

      -- interface layer table entrieds
      m_cube_en         zpb_md_records.cubes_entry;
      m_table_en        zpb_md_records.tables_entry;
      m_cube_dims_en    zpb_md_records.cube_dims_entry;
      m_column_en       zpb_md_records.columns_entry;
      m_cube_hier_en    zpb_md_records.cube_hier_entry;

      m_relation_id     number;
          m_table_id            number;

      m_cube_view      varchar2(128);
      m_object_name    varchar(128);
          m_cube_num            number;

          bus_area_id_num  number;

begin

   zpb_log.write('zpb_metadata_pkg.build_cube.begin',
                             'Creating metadata in ' || p_aw ||
                                 ' for cube ' || p_cubeView ||
                 ' of type '|| p_cube_type);
   l_gid := false;
   l_aw := zpb_aw.get_schema||'.'||p_aw||'!';

--   dbms_output.put_line('building cube ' || p_cubeView);
--   dbms_output.put_line('with dims ' || p_dims);

   bus_area_id_num := sys_context('ZPB_CONTEXT', 'business_area_id');

   if p_cube_type = 'SEC_CUBE' then

        m_cube_view := zpb_metadata_names.get_security_cwm2_cube(p_aw);
        m_object_name := 'SEC_CUBE';
    m_cube_en.Type := 'MEASCUBE';
   else
    m_cube_view := p_cubeView;
        m_object_name :=p_cubeView;

        if instr(m_cube_view, '_PRS') > 0 or instr(m_cube_view, 'ZPBDATA')=0 then
                m_cube_en.Type := 'PRSMEASCUBE';
        else
                m_cube_en.Type := 'MEASCUBE';
        end if;
   end if;

   -- initialize cube entry record
   m_cube_en.name := m_cube_view;

        -- initialize table entry
        m_table_en.tableName := p_cubeView;

        m_table_en.AWName:= 'NA';
        m_table_en.tableType := 'MEASURE';

        m_table_id := insertTableRecord(m_table_en);

        m_cube_en.tableId := m_table_id;
        m_cube_en.EpbId := 'NA';

        m_cube_num := insertCubeRecord(m_cube_en);

   i := 1;
   loop
      j := instr (p_dims, ' ', i);
      if (j = 0) then
         l_dim := substr (p_dims, i);
       else
         l_dim := substr (p_dims, i, j-i);
         i     := j+1;
      end if;

      l_dim_ecm := zpb_ecm.get_dimension_ecm(l_dim, p_aw);

      -- initialize cube_dim entry
      m_cube_dims_en.cubeId := m_cube_num;

      -- find appropriate dimension in zpb_dimensions
          begin

      select dimension_id into m_cube_dims_en.dimensionId
      from zpb_dimensions
      where epb_id = l_dim and bus_area_id = bus_area_id_num;

          exception
                when no_data_found then
               zpb_log.write_event('zpb_metadata.build_cube.error',
                             'No metadata for dimension ' || l_dim ||
                 ' of cube ' || p_cubeView);
      end;

      m_column_en.tableId:= m_table_id;
      m_column_en.columnName := zpb_metadata_names.get_dimension_column(l_dim);
      m_column_en.columnType := 'MEMBER_COLUMN';
      m_column_en.AWName := 'NA';

      m_cube_dims_en.columnId := insertColumnRecord(m_column_en);

      m_relation_id := insertCubeDimsRecord(m_cube_dims_en);

      if (zpb_aw.interp('shw obj(dimmax '''||l_aw||l_dim_ecm.HierDim||''')') <> '0')
         then
                zpb_aw.execute ('lmt '||l_aw||l_dim_Ecm.HierDim||' to all');
                l_hiers := zpb_aw.interp ('shw CM.GETDIMVALUES('''||l_aw||
                                   l_dim_Ecm.HierDim||''' yes)');
         hi := 1;
         loop
            hj := instr (l_hiers, ' ', hi);
            if (hj = 0) then
               l_hier := substr (l_hiers, hi);
             else
               l_hier := substr (l_hiers, hi, hj-hi);
               hi     := hj+1;
            end if;

          -- initialize cube_hier entry record
             m_cube_hier_en.cubeId := m_cube_num;

                 -- find MD for this hierarchy
                 begin

             select hierarchy_id into m_cube_hier_en.hierarchyId
             from zpb_hierarchies
             where epb_id = l_hier and
                           dimension_id = m_cube_dims_en.dimensionId;

             exception
                   when no_data_found then

               zpb_log.write_event('zpb_metadata.build_cube.error',
                             'No metadata for hierarchy ' || l_hier ||
                 ' of dimension ' || m_cube_dims_en.dimensionId);
         end;

             m_column_en.tableId := m_table_id;
             m_column_en.columnName := zpb_metadata_names.get_dim_gid_column(l_dim, l_hier);
             m_column_en.columnType := 'GID_COLUMN';
             m_column_en.AWName := 'NA';

             m_cube_hier_en.columnId := insertColumnRecord(m_column_en);

             m_relation_id := insertCubeHierRecord(m_cube_hier_en);

            exit when hj=0;
         end loop;
       elsif (l_gid = false) then
         -- no hierarchies case = null hiearchy

            m_column_en.tableId := m_table_id;
            m_column_en.columnName := zpb_metadata_names.get_dim_gid_column;
            m_column_en.columnType := 'GID_COLUMN';
            m_column_en.AWName :='NA';

            m_cube_hier_en.cubeId := m_cube_num;

        begin

                select hierarchy_id into m_cube_hier_en.hierarchyId
                from zpb_hierarchies
                where dimension_id = m_cube_dims_en.dimensionId and
                          hier_type = 'NULL';

            exception
                   when no_data_found then

               zpb_log.write_event('zpb_metadata.build_cube.error',
                             'No metadata for null hierarchy ' ||
                 ' of dimension ' || m_cube_dims_en.dimensionId);
        end;

            m_cube_hier_en.columnId := insertColumnRecord(m_column_en);

            m_relation_id := insertCubeHierRecord(m_cube_hier_en);

         l_gid := true;
      end if;
      exit when j=0;
   end loop;

  zpb_log.write('zpb_metadata_pkg.build_instance.end',
                             'succesfull completion');

 EXCEPTION
  WHEN OTHERS THEN
    zpb_log.write_event(G_PKG_NAME||'.'||l_api_name,to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));
    return;


end BUILD_CUBE;

-------------------------------------------------------------------------------
-- BUILD_INSTANCE - Expose metadata for all measures of an instance by calling
--                                      BUILD_MEASURE.  If it has not been done yet, call
--                                      BUILD_CUBE to expose metadat for the containing cube
--
-- IN: p_aw       - The AW
--     p_instance - The ID of the instance
--     p_type     - The type of the instance (PERSONAL, SHARED_VIEW, etc)
--     p_approver - The approvee ID.  Null is not applicable
--
-------------------------------------------------------------------------------
procedure BUILD_INSTANCE(p_aw       in            varchar2,
                         p_instance in            varchar2,
                         p_type     in            varchar2,
                         p_template in            varchar2,
                         p_approvee in            varchar2)
   is

          l_api_name      CONSTANT VARCHAR2(30) := 'BUILD_INSTANCE';

      l_instType     varchar2(30);
      l_shrdInstType varchar2(30);
      l_shrdMeas     varchar2(30);
      l_cube         varchar2(30);
      l_column       varchar2(30);
      l_meas         varchar2(30);
      l_measAw       varchar2(30);
      l_awQual       varchar2(30);
      l_objName      varchar2(60);
      l_dims         varchar2(500);
      l_count        number;
      l_global_ecm   zpb_ecm.global_ecm;
      hi                number;
      hj                number;
          l_curMeasures  varchar2(4000);
          l_curMeas              varchar2(64);
          l_curRel               varchar2(16);
          l_write_sec_type varchar2(64);


          l_baseType     varchar2(30);

          bus_area_id_num number;
begin



   zpb_log.write('zpb_metadata_pkg.build_instance.begin',
                             'Creating metadata in ' || p_aw ||
                                 ' of type ' || p_type ||
                 ' for instance '|| p_instance ||
                                 ' and template ' || p_template ||
                                 ' and approvee ' || p_approvee);

   bus_area_id_num := sys_context('ZPB_CONTEXT', 'business_area_id');

   l_awQual     := zpb_aw.get_schema||'.'||p_aw||'!';

   l_global_ecm := zpb_ecm.get_global_ecm (p_aw);

   l_instType   := zpb_aw.interp ('shw CM.GETINSTOBJECT('''||p_instance||
                                  ''' ''TYPE'')');

   -- If we are building md for personal shared measures, get the SHARED measure here.  It will be
   -- renamed correctly (in accordance to PERSONAL measure naming in BUILD_MEASURE
   if p_type = 'SHARED_VIEW' then
                l_baseType :='SHARED';
   else
                l_baseType :=p_type;
   end if;

   if (instr (l_instType, 'CALC') > 0) then
      l_instType     := l_baseType||' CALC';
      l_shrdInstType := 'SHARED CALC';
    else
      l_instType     := l_baseType;
      l_shrdInstType := 'SHARED';
   end if;

   l_objName := 'OBJECT ID'' NA ';
   if (p_approvee is not null) then
      l_objName := l_objName||''''||p_approvee||''' ';
    else
      l_objName := l_objName||'NA ';
   end if;
   if (p_template is not null) then
      l_objName := l_objName||''''||p_template||'''';
   end if;

   l_meas := zpb_aw.interp ('shw CM.GETINSTOBJECT('''||p_instance||''' '''||
                            l_instType||' DATA '||l_objName||'''');

   if (l_meas = 'NA')
      then return;
   end if;

   if (p_type = 'SHARED_VIEW') then
      l_measAw := 'SHARED!';
      l_shrdMeas := zpb_aw.interp('shw CM.GETINSTOBJECT ('''||p_instance||
                                  ''' '''||l_shrdInstType||' DATA OBJECT ID'')');
    else
      l_measAW := l_awQual;
      l_shrdMeas := l_meas;
   end if;

   if (l_shrdMeas = 'NA')
      then return;
   end if;

   zpb_aw.execute ('push '||l_measAw||'MEASURE;'||
                   ' lmt '||l_measAw||'MEASURE to '''||l_shrdMeas||'''');

   l_cube := zpb_aw.interp('shw '||l_measAw||l_global_ecm.MeasViewRel);

   -- Append _PRS to personal cube names
   if p_type = 'SHARED_VIEW' then
                l_cube := l_cube || '_PRS';
   end if;

   l_column := zpb_aw.interp('shw '||l_measAw||l_global_ecm.MeasColVar);

        select count(*)
        into l_count
                from zpb_cubes
                where name = l_cube and
                          bus_area_id = bus_area_id_num;

   if (l_count = 0) then
      l_dims := zpb_aw.interp
         ('shw joinchars(joincols(lmt ('||l_awQual||l_global_ecm.DimDim||
          ' to '||l_awQual||l_global_ecm.MeasDimVar||' ('||l_awQual||
          'MEASURE '''||l_meas||''') eq yes) '' ''))');
      l_dims := substr(l_dims, 1, length(l_dims)-1);
      BUILD_CUBE (p_aw, l_cube, l_dims);
   end if;

   if (zpb_aw.interpbool ('shw isValue('||l_awQual||'MEASURE '''||
                              l_meas||''')')) then
      BUILD_MEASURE(p_aw, p_instance, l_meas, l_cube, l_column,
                    p_template, p_approvee);
   end if;

   l_meas := zpb_aw.interp ('shw CM.GETINSTOBJECT('''||p_instance||''' '''||
                            l_instType||' ANNOTATION '||l_objName||'''');

   if (p_type = 'SHARED_VIEW') then
      l_measAw := 'SHARED!';
      l_shrdMeas := zpb_aw.interp('shw CM.GETINSTOBJECT ('''||p_instance||
                                  ''' '''||l_shrdInstType||' ANNOTATION OBJECT ID'')');
    else
      l_measAW := l_awQual;
      l_shrdMeas := l_meas;
   end if;

   if (zpb_aw.interpbool ('shw isValue('||l_awQual||'MEASURE '''||
                              l_meas||''')')) then
      zpb_aw.execute ('lmt '||l_measAw||'MEASURE to '''||l_shrdMeas||'''');
      l_cube := zpb_aw.interp('shw '||l_measAw||l_global_ecm.MeasViewRel);

           -- Append _PRS to personal cube names
           if p_type = 'SHARED_VIEW' then
                        l_cube := l_cube || '_PRS';
           end if;

      l_column := zpb_aw.interp('shw '||l_measAw||l_global_ecm.MeasColVar);
      BUILD_MEASURE(p_aw, p_instance, l_meas, l_cube, l_column,
                    p_template, p_approvee);
   end if;

   l_meas := zpb_aw.interp ('shw CM.GETINSTOBJECT('''||p_instance||''' '''||
                            l_instType||' FORMAT '||l_objName||'''');
   if (p_type = 'SHARED_VIEW') then
      l_measAw := 'SHARED!';
      l_shrdMeas := zpb_aw.interp('shw CM.GETINSTOBJECT ('''||p_instance||
                                  ''' '''||l_shrdInstType||' FORMAT OBJECT ID'')');
    else
      l_measAW := l_awQual;
      l_shrdMeas := l_meas;
   end if;

   if (zpb_aw.interpbool ('shw isValue('||l_awQual||'MEASURE '''||
                              l_meas||''')')) then
      zpb_aw.execute ('lmt '||l_measAw||'MEASURE to '''||l_shrdMeas||'''');
      l_cube := zpb_aw.interp('shw '||l_measAw||l_global_ecm.MeasViewRel);

           -- Append _PRS to personal cube names
           if p_type = 'SHARED_VIEW' then
                        l_cube := l_cube || '_PRS';
           end if;

      l_column := zpb_aw.interp('shw '||l_measAw||l_global_ecm.MeasColVar);
      BUILD_MEASURE(p_aw, p_instance, l_meas, l_cube, l_column,
                    p_template, p_approvee);
   end if;


   if (p_type = 'PERSONAL') then
      l_meas := zpb_aw.interp ('shw CM.GETINSTOBJECT('''||p_instance||''' '''||
                               l_instType||' TARGET '||l_objName||'''');

      if (zpb_aw.interpbool ('shw isValue('||l_awQual||'MEASURE '''||
                                 l_meas||''')')) then
         zpb_aw.execute ('lmt '||l_awQual||'MEASURE to '''||l_meas||'''');
         l_cube := zpb_aw.interp('shw '||l_awQual||l_global_ecm.MeasViewRel);
         l_column := zpb_aw.interp('shw '||l_measAw||l_global_ecm.MeasColVar);
         BUILD_MEASURE(p_aw, p_instance, l_meas, l_cube, l_column,
                       p_template, p_approvee);
      end if;

      l_meas := zpb_aw.interp ('shw CM.GETINSTOBJECT('''||p_instance||''' '''||
                               l_instType||' TARGET TYPE '||l_objName||'''');

      if (zpb_aw.interpbool ('shw isValue('||l_awQual||'MEASURE '''||
                                 l_meas||''')')) then
         zpb_aw.execute ('lmt '||l_awQual||'MEASURE to '''||l_meas||'''');
         l_cube := zpb_aw.interp('shw '||l_awQual||l_global_ecm.MeasViewRel);

         l_column := zpb_aw.interp('shw '||l_awQual||l_global_ecm.MeasColVar);
         BUILD_MEASURE(p_aw, p_instance, l_meas, l_cube, l_column,
                       p_template, p_approvee);
      end if;

      l_meas := zpb_aw.interp ('shw CM.GETINSTOBJECT('''||p_instance||''' '''||
                               l_instType||' INPUT LEVEL OBJECT ID''');

      if (zpb_aw.interpbool ('shw isValue('||l_awQual||'MEASURE '''||
                                 l_meas||''')')) then

                  zpb_aw.execute ('lmt '||l_measAw||'MEASURE to '''||l_meas||'''');

                 l_cube := zpb_aw.interp('shw '||l_measAw||l_global_ecm.MeasViewRel);

                         -- expose MD for cube if has not been done so yet
                         select count(*)
                 into l_count
                         from zpb_cubes
                         where name = l_cube and
                                   bus_area_id = bus_area_id_num;

                     if (l_count = 0) then
                   l_dims := zpb_aw.interp
                        ('shw joinchars(joincols(lmt ('||l_awQual||l_global_ecm.DimDim||
                        ' to '||l_awQual||l_global_ecm.MeasDimVar||' ('||l_awQual||
                        'MEASURE '''||l_meas||''') eq yes) '' ''))');
                        l_dims := substr(l_dims, 1, length(l_dims)-1);
                        BUILD_CUBE (p_aw, l_cube, l_dims);
                         end if;

                l_column := zpb_aw.interp('shw '||l_awQual||l_global_ecm.MeasColVar);
                BUILD_MEASURE(p_aw, p_instance, l_meas, l_cube, l_column,
                       p_template, p_approvee);

      end if; -- input level MD

          -- expose write security of appropriate currency type
      l_meas := zpb_aw.interp ('shw CM.GETINSTOBJECT('''||p_instance||''' '''||
                               l_instType||' WRITE SECURITY '||l_objName||'''');

      if (zpb_aw.interpbool ('shw isValue('||l_awQual||'MEASURE '''||
                              l_meas||''')')) then

                  zpb_aw.execute ('lmt '||l_measAw||'MEASURE to '''||l_meas||'''');
                  -- if MD for write security of this currency type for this instance has already been
                  -- created, no need to update now
                  if(instr(l_meas, 'PEWSEC')) > 0 then
                        l_write_sec_type := 'PERSONAL_ENTERED_WRITE_SECURITY';
                  else
                        l_write_sec_type := 'PERSONAL_WRITE_SECURITY';
                  end if;

                 l_cube := zpb_aw.interp('shw '||l_measAw||l_global_ecm.MeasViewRel);

                         -- expose MD for cube if it has not been done so yet
                         select count(*)
                 into l_count
                         from zpb_cubes
                         where name = l_cube and
                                   bus_area_id = bus_area_id_num;

                     if (l_count = 0) then

                   l_dims := zpb_aw.interp
                        ('shw joinchars(joincols(lmt ('||l_awQual||l_global_ecm.DimDim||
                        ' to '||l_awQual||l_global_ecm.MeasDimVar||' ('||l_awQual||
                        'MEASURE '''||l_meas||''') eq yes) '' ''))');
                        l_dims := substr(l_dims, 1, length(l_dims)-1);
                        BUILD_CUBE (p_aw, l_cube, l_dims);
                         end if;

                         l_column := zpb_aw.interp('shw '||l_measAw||l_global_ecm.MeasColVar);
                 BUILD_MEASURE(p_aw, p_instance, l_meas, l_cube, l_column,
                           p_template, p_approvee);

           end if; -- write sec block
   end if; -- PERSONAL block

  -- expose translated and entered MD
  if p_type = 'SHARED' or p_type = 'SHARED_VIEW' then

   zpb_aw.execute('push oknullstatus');
   zpb_aw.execute('oknullstatus = yes');

   zpb_aw.execute ('lmt '||l_awQual||'MEASURE to findchars(' || l_awQual || 'MEASURE '''|| p_instance || ''') gt 0');
   zpb_aw.execute ('lmt '||l_awQual||'MEASURE keep findchars(' || l_awQual || 'MEASURE ''.E.'') gt 0');

   l_measAW := l_awQual;

   if (zpb_aw.interp('shw convert(statlen('||l_awQual||'MEASURE'||
                              ') text 0 no no)') <> 0) then

   hi := 1;
   l_curMeasures :=zpb_aw.interp
                    ('shw CM.GETDIMVALUES('''||l_awQual||'MEASURE'||''', ''YES'')');

  loop -- LOOP OVER ALL ENTERED MEASURES
     hj := instr (l_curMeasures, ' ', hi);
     if (hj = 0) then
        l_curMeas := substr (l_curMeasures, hi);
     else
        l_curMeas := substr (l_curMeasures, hi, hj-hi);
        hi     := hj+1;
     end if;

     zpb_aw.execute ('lmt '||l_awQual||'MEASURE to '''||l_curMeas||'''');
     l_cube := zpb_aw.interp('shw '||l_awQual||l_global_ecm.MeasViewRel);

   -- Append _PRS to personal cube names
   if p_type = 'SHARED_VIEW' then
                l_cube := l_cube || '_PRS';
   end if;

  if l_cube <>'NA' then

         select count(*)
        into l_count
                from zpb_cubes
                where name = l_cube and
                          bus_area_id = bus_area_id_num;

     if (l_count = 0) then
       l_dims := zpb_aw.interp
         ('shw joinchars(joincols(lmt ('||l_awQual||l_global_ecm.DimDim||
          ' to '||l_awQual||l_global_ecm.MeasDimVar||' ('||l_awQual||
          'MEASURE '''||l_curMeas||''') eq yes) '' ''))');
       l_dims := substr(l_dims, 1, length(l_dims)-1);
       BUILD_CUBE (p_aw, l_cube, l_dims);
     end if;

     l_column := zpb_aw.interp('shw '||l_measAw||l_global_ecm.MeasColVar);

 --    l_curRel  := zpb_aw.interp('shw &joinchars('''||l_awQual||
 --                               ''' obj(property ''MEASCURRENCYREL'' ''MEASURE''))');

         l_curRel  := zpb_aw.interp('shw '||l_awQual||'MEASCURRENCY');

     BUILD_MEASURE(p_aw, p_instance, l_curMeas, l_cube, l_column,
                       p_template, p_approvee, l_curRel);

   end if; -- cube is NA

     exit when hj = 0;
    end loop; -- End looping over ENTERED MEASURES

 end if; -- if measure dim has any members


   zpb_aw.execute ('lmt '||l_awQual||'MEASURE to findchars(' || l_awQual || 'MEASURE '''|| p_instance || ''') gt 0');
   zpb_aw.execute ('lmt '||l_awQual||'MEASURE keep findchars(' || l_awQual || 'MEASURE ''.T.'') gt 0');

   if (zpb_aw.interp('shw convert(statlen('||l_awQual||'MEASURE'||
                              ') text 0 no no)') <> 0) then

   hi := 1;
   l_curMeasures :=zpb_aw.interp
                    ('shw CM.GETDIMVALUES('''||l_awQual||'MEASURE'||''', ''YES'')');
--   dbms_output.put_line('l_curMeasures: ' || l_curMeasures);

   loop -- LOOP OVER ALL CURRENCY TRANSLATED MEASURES
     hj := instr (l_curMeasures, ' ', hi);
     if (hj = 0) then
        l_curMeas := substr (l_curMeasures, hi);
     else
        l_curMeas := substr (l_curMeasures, hi, hj-hi);
        hi     := hj+1;
     end if;

     zpb_aw.execute ('lmt '||l_awQual||'MEASURE to '''||l_curMeas||'''');

--dbms_output.put_line('l_curMeas: ' || l_curMeas);

     l_cube := zpb_aw.interp('shw '||l_awQual||l_global_ecm.MeasViewRel);

   -- Append _PRS to personal cube names
   if p_type = 'SHARED_VIEW' then
                l_cube := l_cube || '_PRS';
   end if;

--dbms_output.put_line('l_cube: ' || l_cube);

  if l_cube <>'NA' then

         select count(*)
        into l_count
                from zpb_cubes
                where name = l_cube and
                          bus_area_id = bus_area_id_num;

--dbms_output.put_line('l_count: ' || l_count);

     if (l_count = 0) then
       l_dims := zpb_aw.interp
         ('shw joinchars(joincols(lmt ('||l_awQual||l_global_ecm.DimDim||
          ' to '||l_awQual||l_global_ecm.MeasDimVar||' ('||l_awQual||
          'MEASURE '''||l_curMeas||''') eq yes) '' ''))');
       l_dims := substr(l_dims, 1, length(l_dims)-1);
       BUILD_CUBE (p_aw, l_cube, l_dims);
     end if;

     l_column := zpb_aw.interp('shw '||l_measAw||l_global_ecm.MeasColVar);

--     l_curRel  := zpb_aw.interp('shw &joinchars('''||l_awQual||
--                                ''' obj(property ''MEASCURRENCYREL'' ''MEASURE''))');

         l_curRel  := zpb_aw.interp('shw '||l_awQual||'MEASCURRENCY');

     BUILD_MEASURE(p_aw, p_instance, l_curMeas, l_cube, l_column,
                       p_template, p_approvee, l_curRel);

  end if; --cube is NA

     exit when hj = 0;
    end loop; -- End looping over CURRENCY TRANSLATED MEASURES

 end if; -- if measure dim has any members

   zpb_aw.execute('pop oknullstatus');

 end if; -- shared or shared view for currency building
   zpb_aw.execute ('pop '||l_measAw||'MEASURE');

   zpb_log.write('zpb_metadata_pkg.build_instance.end',
                             'succesfull completion');

 EXCEPTION
  WHEN OTHERS THEN
--      dbms_output.put_line('OTHERS : ' || substr(sqlerrm,1,90));
    zpb_log.write_event(G_PKG_NAME||'.'||l_api_name,to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));
    return;

end BUILD_INSTANCE;

-------------------------------------------------------------------------------
-- BUILD_MEASURE - Exposes metadata for a measure
--
-- IN: p_aw   - The AW
--     p_instance - The ID of the measure
-------------------------------------------------------------------------------
procedure BUILD_MEASURE(p_aw       in            varchar2,
                        p_instance in            varchar2,
                        p_meas     in            varchar2,
                        p_cube     in            varchar2,
                        p_column   in            varchar2,
                        p_template in            varchar2,
                        p_approvee in            varchar2,
                                            p_currencyRel in         varchar2)
   is

          l_api_name      CONSTANT VARCHAR2(30) := 'BUILD_MEASURE';

      l_measFrm       varchar2(30);
      l_measType      varchar2(64);
      l_measName      varchar2(200);
      l_awQual        varchar2(30);
      l_subMap        varchar2(4000);
      l_schema        varchar2(30);
      l_type          varchar2(30);
      done            boolean;
      i               number;
      j               number;
      entry           number;
      nl              varchar2(1) := fnd_global.local_chr(10);
      l_global_ecm    zpb_ecm.global_ecm;

      -- measure table entry
      m_meas_en       zpb_md_records.measures_entry;
      m_meas_id       number;
      m_cwm_name      varchar2(128);
          m_column_en     zpb_md_records.columns_entry;

          l_insert_meas_flag boolean;

      -- string manipulations for personal measure MD
          m_string1      varchar2(30);
          m_string2              varchar2(30);
          m_stringMid    number;
          m_stringRepl   varchar2(8);

          -- AW param
          p_awParam             varchar2(30);

          -- check to avoid duplicate measure md
          m_countMeas   number;

          bus_area_id_num number;

begin

   zpb_log.write('zpb_metadata_pkg.build_measure.begin',
                             'Creating metadata in ' || p_aw ||
                 ' in cube ' || p_cube ||
                                 ' for measure ' || p_meas ||
                 ' for instance '|| p_instance ||
                                 ' and template ' || p_template ||
                                 ' and approvee ' || p_approvee);


   l_schema := zpb_aw.get_schema||'.';
   l_awQual := l_schema||p_aw||'!';

   bus_area_id_num := sys_context('ZPB_CONTEXT', 'business_area_id');

   l_global_ecm := zpb_ecm.get_global_ecm(p_aw);
   zpb_aw.execute ('push '||l_awQual||'MEASURE');
   zpb_aw.execute ('lmt '||l_awQual||'MEASURE to '''||p_meas||'''');

   l_measType  := zpb_aw.interp('shw '||l_awQual||l_global_ecm.MeasTypeRel);


   -- update for personal measure MD

   if instr (p_cube, '_PRS') > 0 then
        m_stringMid := 7;
        m_string1 := substr(l_measType, 1 , m_stringMid);
        m_string2 := substr(l_measType, m_stringMid + 1, length(l_measType));
        l_measType := m_string1 || 'VIEW_' || m_string2 ;
--    dbms_output.put_line('l_measType after :' || l_measType);
   end if;

   l_measFrm   := zpb_aw.interp('shw '||l_awQual||l_global_ecm.MeasExpObjVar);

--   dbms_output.put_line('l_measFrm before :' || l_measFrm);
   -- AWName FRM.FM8713 -> FRM.SHFM8713
   if instr (p_cube, '_PRS') > 0 then
                if (instr (l_measType, '_CALC')) > 0 then
                        m_stringMid := instr(l_measFrm, '.');
                        m_string1 := substr(l_measFrm, 1 , m_stringMid); -- FRM.
                        m_string2 := substr(l_measFrm, m_stringMid+1, length(l_measFrm)); -- FM.8713
                        m_string2 := replace(m_string2, 'FM', 'FMT');
                        l_measFrm := m_string1 || 'CALC.' || m_string2;
                else
                        m_stringRepl:='SH';
                        if(instr(l_measType, 'DATA_ENTERED')> 0 or instr(l_measType, 'DATA_TRANSLATED')>0) then
                                m_stringRepl := 'SH.';
                        end if;
                        m_stringMid := instr(l_measFrm, '.');
                        m_string1 := substr(l_measFrm, 1 , m_stringMid); -- FRM.
                m_string2 := substr(l_measFrm, m_stringMid+1, length(l_measFrm)); -- FM8713
                        m_string2 := replace(m_string2, 'WSEC', 'WS');
                m_string2 := replace(m_string2, 'AN', 'ANN');
                        l_measFrm := m_string1 || m_stringRepl || m_string2;
                end if;
--      dbms_output.put_line('l_measFrm after :' || l_measFrm);
        end if;

   l_measName  := zpb_aw.interp('shw &joinchars('''||l_awQual||
                                ''' obj(property ''LDSCVAR'' ''MEASURE''))');

        m_meas_en.name := l_measName;
        m_meas_en.AWName := l_measFrm;
        m_meas_en.EPBId := p_meas;

    m_meas_en.CurrencyRel := p_currencyRel;

--    dbms_output.put_line('m_meas_en.EPBId before :' || m_meas_en.EPBId);

   -- DF8713 -> DF.SH8713 or FM8713 -> FMT.SH8713
   if instr (p_cube, '_PRS') > 0 then
                        -- for entered and translated mid point is first period
                        if(instr(p_meas, '.') > 0) then
                                m_stringMid := instr(p_meas, '.');
                        else
                                m_stringMid := instr(p_meas, p_instance);
                        end if;
                        m_string1 := substr(p_meas, 1 , m_stringMid-1); -- DF or FM
                m_string2 := substr(p_meas, m_stringMid, length(p_meas)); -- 8713
                        m_string1 := replace(m_string1, 'FM', 'FMT');
                m_string1 := replace(m_string1, 'DA', 'AN');
                        m_string1 := replace(m_string1, 'CALC', 'DF'); -- calcs
                        m_meas_en.EPBId := m_string1 || '.SH' || m_string2;
--                  dbms_output.put_line('m_meas_en.EPBId after :' || m_meas_en.EPBId);
        end if;

        m_meas_en.Type := l_measType;
        m_meas_en.InstanceId := p_instance;

        /* Bug#5766644, commented and replaced for if-else-if logic
           m_meas_en.CurrInstFlag := upper(zpb_aw.interp('shw '||l_awQual||l_global_ecm.IsCurrInstVar)); */
        if zpb_aw.interpbool ('shw '||l_awQual||l_global_ecm.IsCurrInstVar) then
             m_meas_en.CurrInstFlag := 'YES';
        else
             m_meas_en.CurrInstFlag := 'NO';
        end if;

   if (p_template is not null and l_measType <> 'PERSONAL_INPUT_LEVEL' and
                l_measType <> 'PERSONAL_WRITE_SECURITY' and l_measType <> 'PERSONAL_ENTERED_WRITE_SECURITY') then
          m_meas_en.TemplateId := to_number(p_template);
   end if;

   if (p_approvee is not null) then
          m_meas_en.ApproveeId := p_approvee;
   end if;

   if (instr (l_measType, 'SHARED_VIEW') > 0) then
      l_type := 'SHARED_VIEW';
    elsif (instr (l_measType, 'SHARED') > 0) then
      l_type := 'SHARED';
    elsif (instr (l_measType, 'PERSONAL') > 0) then
      l_type := 'PERSONAL';
    elsif (instr (l_measType, 'APPROVER') > 0) then
      l_type := 'APPROVER';
    else
      l_type := l_measType;
   end if;

   --
   -- slight HACK: changing XXX_CALC to XXX_CALC_DATA to make the
   -- following algorithm work
   --
   if (instr (l_measType, '_CALC') = length(l_measType) - 4) then
      l_measType := l_measType || '_DATA';
   end if;

   if instr (p_cube, '_PRS') > 0 then
                p_awParam := 'PRS';
   else
                p_awParam :=p_aw;
   end if;

   if (instr (l_measType, '_DATA') > 0) then
     m_cwm_name := zpb_metadata_names.get_measure_cwm2
         (p_awParam,p_instance,l_measType,p_template,p_approvee, p_currencyRel);
    elsif (instr (l_measType, '_ANNOTATION') > 0) then
     m_cwm_name := zpb_metadata_names.get_measure_annot_cwm2
         (p_awParam,p_instance,l_measType,p_template,p_approvee, p_currencyRel);
    elsif (instr (l_measType, '_TARGET_TYPE') > 0) then
     m_cwm_name := zpb_metadata_names.get_measure_targ_type_cwm2
         (p_awParam,p_instance,l_measType,p_template,p_approvee);
    elsif (instr (l_measType, '_TARGET') > 0) then
     m_cwm_name := zpb_metadata_names.get_measure_target_cwm2
         (p_awParam,p_instance,l_measType,p_template,p_approvee);
    elsif (instr (l_measType, '_INPUT_LEVEL') > 0) then
     m_cwm_name := zpb_metadata_names.get_measure_input_lvl_cwm2
         (p_awParam,p_instance,l_measType,p_template,p_approvee);
    elsif (instr (l_measType, '_WRITE_SECURITY') > 0) then

                if(instr (l_measType, 'PERSONAL_ENTERED') > 0) then
                  m_cwm_name := zpb_metadata_names.get_measure_cur_write_sec_cwm2
                        (p_awParam,p_instance,l_measType,p_template,p_approvee);
                else
          m_cwm_name := zpb_metadata_names.get_measure_write_sec_cwm2
                        (p_awParam,p_instance,l_measType,p_template,p_approvee);
                end if;

    elsif (instr (l_measType, '_FORMAT') > 0) then
     m_cwm_name := zpb_metadata_names.get_measure_format_cwm2
         (p_awParam,p_instance,l_measType,p_template,p_approvee, p_currencyRel);
   end if;

   m_meas_en.CWMName := m_cwm_name;

--   dbms_output.put_line('m_cwm_name :' || m_cwm_name);
--   dbms_output.put_line('p_cube :' || p_cube);

   -- if no metadata exists for this measures cube then something is wrong
   -- with this measures measviewrel - most likely its set to a different
   -- cube than the instance's data measure's measviewrel

   begin

        select cube_id, table_id into m_meas_en.cubeId, m_column_en.tableId
        from   zpb_cubes
        where  name = p_cube and
                           bus_area_id = bus_area_id_num;

                l_insert_meas_flag := true;

   exception
   when others then
                l_insert_meas_flag := false;

   end;

  if l_insert_meas_flag = true then

          m_column_en.columnName := p_column;
          m_column_en.columnType := 'MEASURE_COLUMN';
          m_column_en.AWName := '';

          m_meas_en.columnId := InsertColumnRecord(m_column_en);

      -- populate currency fields if this is a currency-enabled BA

          m_meas_en.SelectedCur :='NA';
          m_meas_en.CurrencyType := 'NA';

          -- if clause will be true if this is a currency-enabled business area
          -- only need to expose these currency fields for shared AWs (open-sql access)
          if (zpb_aw.interp('shw statlen(limit(SHARED!' || l_global_ecm.DimDim ||
                                            ' to SHARED!' || l_global_ecm.DimTypeRel ||
                                            ' eq ''FROM_CURRENCY''))') <> 0 and instr(p_cube, 'ZPBDATA') > 0) then

                m_meas_en.CurrencyType := zpb_aw.interp ('shw shared!instance.currency.type (shared!instance ''' || p_instance || ''')');

                -- only set selected currency field if the currency type is SPECIFIED
                if m_meas_en.CurrencyType = 'SPECIFIED' then
                        m_meas_en.SelectedCur := zpb_aw.interp ('shw shared!instance.currency (shared!instance ''' || p_instance || ''')');
                end if;
          end if;

          m_meas_en.CPRMeasure :='NO';
          -- set cpr measure flag if it is available
                if(l_type='PERSONAL' and zpb_aw.interpbool('shw exists(''' || l_awQual || 'CPRFLAG.DM'')')) then
                         if zpb_aw.interpbool('shw '||l_awQual||'CPRFLAG.DM') then
                                m_meas_en.CPRMeasure :='YES';
                         end if;
                end if;

           m_meas_id := InsertMeasureRecord(m_meas_en);

  else
           zpb_log.write_event('zpb_metadata_pkg.build_measure.error',
                             'No metadata created because no metadata for' ||
                 'cube ' || p_cube);

  end if;


  zpb_aw.execute ('pop '||l_awQual||'MEASURE');

   zpb_log.write('zpb_metadata.build_measure.end',
                             'succesfull completion');

 EXCEPTION
  WHEN OTHERS THEN
    zpb_log.write_event(G_PKG_NAME||'.'||l_api_name,to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));
    return;

end BUILD_MEASURE;

-------------------------------------------------------------------------------
-- BUILD - Exposes metadata for an AW
--
-- IN: p_aw       - The AW to build the map
--     p_sharedAW - The name of the shared AW.  May be the same as p_aw.
--     p_type     - Either PERSONAL or SHARED
--     p_doMeas   - True if measures should be (re)built
-------------------------------------------------------------------------------
procedure BUILD(p_aw       in            varchar2,
                p_sharedAW in            varchar2,
                p_type     in            varchar2,
                p_doMeas   in            varchar2,
                                p_onlySec  in                    varchar2)
   is

          l_api_name      CONSTANT VARCHAR2(30) := 'BUILD';

      l_dims            varchar2(500);
      l_dim             varchar2(32);
      l_instances       varchar2(16000);
      l_instance        varchar2(32);
      l_measures        varchar2(32);
      l_meas            varchar2(32);
      l_templ           varchar2(32);
      l_approv          varchar2(32);
      l_aw              varchar2(32);
      l_subMap          varchar2(4000);
      l_pos             number;
      l_pos2            number;
      i                 number;
      j                 number;
      hi                number;
      hj                number;
      l_gid             boolean;
      l_hiers           varchar2(1000);
      l_hier            varchar2(30);
      l_value           varchar2(30);
      nl                varchar2(1) := fnd_global.local_chr(10);
      ai                number;
      aj                number;
      done              boolean;

      l_dim_ecm         zpb_ecm.dimension_ecm;
      l_global_ecm      zpb_ecm.global_ecm;

      -- measure entry
      m_meas_en         zpb_md_records.measures_entry;
      m_meas_id         number;
      m_meas_cube_name  varchar2(128);
      m_meas_col_name   varchar2(128);
      m_column_en       zpb_md_records.columns_entry;

          -- store start time.  On completion of refresh all entries
          -- with lsat_updated before start date will be removed
          m_start_time          date;
          bus_area_id_num       number;

          -- "special" table entries
          m_table_en            zpb_md_records.tables_entry;
          m_column_id_num       number;

begin

   zpb_log.write('zpb_metadata_pkg.build.begin',
                 'Creating metadata map for '||p_aw);
--   dbms_output.put_line('Creating metadata map for '||p_aw);

   bus_area_id_num := sys_context('ZPB_CONTEXT', 'business_area_id');

   select sysdate into m_start_time from dual;

   zpb_aw.execute ('aw attach '||zpb_aw.get_schema||'.'||p_aw||' first');

   l_gid             := false;
   l_aw              := zpb_aw.get_schema||'.'||p_aw||'!';
   l_global_ecm      := zpb_ecm.get_global_ecm(p_aw);

   zpb_aw.execute('push oknullstatus '||l_global_ecm.AttrDim);
   zpb_aw.execute('oknullstatus = yes');

 if p_onlySec='N' then

   l_dims := zpb_aw.interp ('shw CM.GETDATADIMS');

   BUILD_DIMS (p_aw, p_sharedAW, p_type, l_dims);

   l_instances := zpb_aw.interp('shw CM.GETDIMVALUES('''||l_aw||'INSTANCE'')');
   if (p_doMeas = 'Y' and l_instances <> 'NA') then
          if(p_type = 'SHARED') then
                delete_shared_cubes(p_sharedAW);
          end if;
      i := 1;
      loop
         j := instr (l_instances, ' ', i);
         if (j = 0) then
            l_instance := substr (l_instances, i);
          else
            l_instance := substr (l_instances, i, j-i);
            i          := j+1;
         end if;

         if (p_type = 'SHARED') then
            BUILD_INSTANCE (p_aw, l_instance, 'SHARED');
                        BUILD_INSTANCE (p_aw, l_instance, 'SHARED_VIEW');
          else
            l_value := zpb_aw.interp ('shw CM.GETINSTOBJECT('''||l_instance||
                                      ''' ''TYPE'')');
            if (l_value = 'ANALYST_CALC') then
               BUILD_INSTANCE (p_aw, l_instance, 'PERSONAL');
             else
               --BUILD_INSTANCE (p_aw, l_instance, 'SHARED_VIEW');
               zpb_aw.execute ('lmt '||l_aw||'MEASURE to findchars('||l_aw||
                               'MEASURE ''DF'||l_instance||'.'') eq 1');
               l_measures := zpb_aw.interp ('shw CM.GETDIMVALUES ('''||l_aw||
                                            'MEASURE'' yes)');
               if (l_measures <> 'NA') then
                  hi := 1;
                  loop
                     hj := instr (l_measures, ' ', hi);
                     if (hj = 0) then
                        l_meas := substr (l_measures, hi);
                      else
                        l_meas := substr (l_measures, hi, hj-hi);
                        hi     := hj+1;
                     end if;

                     l_templ := substr(l_meas, instr(l_meas, '.') + 1);
                     BUILD_INSTANCE (p_aw, l_instance, 'PERSONAL', l_templ);
                     exit when hj=0;
                  end loop;
               end if;

               zpb_aw.execute ('lmt '||l_aw||'MEASURE to findchars('||l_aw||
                               'MEASURE ''APPDF'||l_instance||'.'') eq 1');
               l_measures := zpb_aw.interp ('shw CM.GETDIMVALUES ('''||l_aw||
                                            'MEASURE'' yes)');
               if (l_measures <> 'NA') then
                  hi := 1;
                  loop
                     hj := instr (l_measures, ' ', hi);
                     if (hj = 0) then
                        l_meas := substr (l_measures, hi);
                      else
                        l_meas := substr (l_measures, hi, hj-hi);
                        hi     := hj+1;
                     end if;

                     l_pos    := instr(l_meas, '.');
                     l_pos2   := instr(l_meas, '.', l_pos+1);
                     l_approv := substr(l_meas, l_pos+1, l_pos2-l_pos-1);
                     l_templ  := substr(l_meas, l_pos2+1);
                     BUILD_INSTANCE (p_aw, l_instance, 'APPROVER',
                                     l_templ, l_approv);
                     exit when hj=0;
                  end loop;
               end if;
            end if;
         end if;
         exit when j=0;
      end loop;
   end if;
  cleanOldEntries(m_start_time);
 end if; -- only do security flag

   --
   -- Do the security measures:
   --

   if (p_type = 'SHARED') then
      --
      -- Generate the dimension up front, since they are the same for all meas
      --
      l_dims      := zpb_aw.interp ('shw CM.GETDATADIMS');

      BUILD_CUBE(p_aw, zpb_metadata_names.get_security_view(p_aw), l_dims, 'SEC_CUBE');


      --
      -- Full scope:
      --

      m_meas_en.name := 'FULL_SCOPE';
      m_meas_en.type := 'FULL_SCOPE';
      m_meas_en.CWMName := zpb_metadata_names.get_full_scope_cwm2_name(p_aw);
      m_meas_cube_name := zpb_metadata_names.get_security_cwm2_cube(p_aw);

      m_column_en.columnName := zpb_metadata_names.get_full_scope_column;
      m_column_en.columnType := 'FULLSCOPE';
      m_column_en.AWName := '';

      m_meas_en.AWName :='NA';
      m_meas_en.EPBId :='NA';
      m_meas_en.InstanceId :=0;
      m_meas_en.CurrInstFlag :='NO';
      m_meas_en.CurrencyType := 'TempNA';
      m_meas_en.SelectedCur := 'TempNA';

        select cube_id, table_id into m_meas_en.cubeId, m_column_en.TableId
        from zpb_cubes
        where name = m_meas_cube_name and
                  bus_area_id = bus_area_id_num;

      m_meas_en.ColumnId := InsertColumnRecord(m_column_en);

      m_meas_id := InsertMeasureRecord(m_meas_en);
      --
      -- Writemap:
      --
--      m_meas_en.name := 'WRITEMAP';
--      m_meas_en.type := 'WRITEMAP';
--      m_meas_en.CWMName := zpb_metadata_names.get_writemap_cwm2_name(p_aw);
--      m_meas_cube_name := zpb_metadata_names.get_security_cwm2_cube(p_aw);
--
--      m_column_en.columnName := zpb_metadata_names.get_writemap_column;
--      m_column_en.columnType := 'WRITEMAP';
--      m_column_en.AWName := 'TempNA';

--      m_meas_en.AWName :='NA';
--      m_meas_en.EPBId :='NA';
--      m_meas_en.InstanceId :=0;
--      m_meas_en.CurrInstFlag :='NO';
--      m_meas_en.CurrencyType :='TempNA';
--      m_meas_en.SelectedCur := 'TempNA';

--      select cube_id, table_id into m_meas_en.cubeId, m_column_en.TableId
--      from zpb_cubes
--      where name = m_meas_cube_name and
--                bus_area_id = bus_area_id_num;

--      m_meas_en.columnId := InsertColumnRecord(m_column_en);

--      m_meas_id := InsertMeasureRecord(m_meas_en);

      --
      -- Redo OWNERMAP:
      --
      zpb_aw.execute ('oknullstatus=yes');
      zpb_aw.execute ('lmt '||l_aw||l_global_ecm.DimDim||' to '||
                      l_aw||l_global_ecm.IsOwnerDim||' eq yes');
      l_dims := zpb_aw.interp ('shw joinchars(joincols(values('||
                               l_aw||l_global_ecm.DimDim||') '' ''))');
      if (l_dims <> 'NA' and l_dims <> ' ') then
         l_dims := substr (l_dims, 1, length(l_dims) - 1);
         BUILD_OWNERMAP_MEASURE (p_aw, l_dims);
      end if;

    --
      -- Do the Relation view/non-cwm structures
      --
      -- All annotations table:
      --

          -- initialize ALL_ANNOTATIONS table
          m_table_en.TableName := zpb_metadata_names.get_all_annotations_view(p_aw);
          m_table_en.TableType := 'ALL_ANNOTATIONS';

          -- initialize column entry for table
          m_column_en.TableId := insertTableRecord(m_table_en);

          -- ENTRY_COLUMN
          m_column_en.ColumnType := 'ENTRY_COLUMN';
          m_column_en.ColumnName := 'ENTRY';
          m_column_en.AWName := 'ANNENTRY';
          m_column_id_num := insertColumnRecord(m_column_en);

          -- ANUSER_COLUMN
          m_column_en.ColumnType := 'ANUSER_COLUMN';
          m_column_en.ColumnName := 'ANUSER';
          m_column_en.AWName := 'ANNUSER';
          m_column_id_num := insertColumnRecord(m_column_en);

          -- TITLE_COLUMN
          m_column_en.ColumnType := 'TITLE_COLUMN';
          m_column_en.ColumnName := 'TITLE';
          m_column_en.AWName := 'TITLE.ANNOT.F';
          m_column_id_num := insertColumnRecord(m_column_en);

          -- DESCRIPTION_COLUMN
          m_column_en.ColumnType := 'DESCRIPTION_COLUMN';
          m_column_en.ColumnName := 'DESCRIPTION';
          m_column_en.AWName := 'DESC.ANNOT.F';
          m_column_id_num := insertColumnRecord(m_column_en);

          -- DATA_COLUMN
          m_column_en.ColumnType := 'DATA_COLUMN';
          m_column_en.ColumnName := 'DATA';
          m_column_en.AWName := 'CURRDATA.ANNOT.F';
          m_column_id_num := insertColumnRecord(m_column_en);

          -- ANDATE_COLUMN
          m_column_en.ColumnType := 'ANDATE_COLUMN';
          m_column_en.ColumnName := 'ANDATE';
          m_column_en.AWName := 'ANNDATE';
          m_column_id_num := insertColumnRecord(m_column_en);

          -- initialize ALL_PERS_ANNOTATIONS table
          m_table_en.TableName := zpb_metadata_names.get_all_annot_pers_view(p_aw);
          m_table_en.TableType := 'ALL_PERS_ANNOTATIONS';

          -- this table and ALL_ANNOTATIONS table have same columns

          -- initialize column entry for table
          m_column_en.TableId := insertTableRecord(m_table_en);

          -- ENTRY_COLUMN
          m_column_en.ColumnType := 'ENTRY_COLUMN';
          m_column_en.ColumnName := 'ENTRY';
          m_column_en.AWName := 'ANNENTRY';
          m_column_id_num := insertColumnRecord(m_column_en);

          -- ANUSER_COLUMN
          m_column_en.ColumnType := 'ANUSER_COLUMN';
          m_column_en.ColumnName := 'ANUSER';
          m_column_en.AWName := 'ANNUSER';
          m_column_id_num := insertColumnRecord(m_column_en);

          -- TITLE_COLUMN
          m_column_en.ColumnType := 'TITLE_COLUMN';
          m_column_en.ColumnName := 'TITLE';
          m_column_en.AWName := 'TITLE.ANNOT.F';
          m_column_id_num := insertColumnRecord(m_column_en);

          -- DESCRIPTION_COLUMN
          m_column_en.ColumnType := 'DESCRIPTION_COLUMN';
          m_column_en.ColumnName := 'DESCRIPTION';
          m_column_en.AWName := 'DESC.ANNOT.F';
          m_column_id_num := insertColumnRecord(m_column_en);

          -- DATA_COLUMN
          m_column_en.ColumnType := 'DATA_COLUMN';
          m_column_en.ColumnName := 'DATA';
          m_column_en.AWName := 'CURRDATA.ANNOT.F';
          m_column_id_num := insertColumnRecord(m_column_en);

          -- ANDATE_COLUMN
          m_column_en.ColumnType := 'ANDATE_COLUMN';
          m_column_en.ColumnName := 'ANDATE';
          m_column_en.AWName := 'ANNDATE';
          m_column_id_num := insertColumnRecord(m_column_en);

      --
      -- Security scope status table
      --

          m_table_en.TableName := zpb_metadata_names.get_scope_status_view(p_aw);
          m_table_en.TableType := 'SCOPE_STATUS';

          -- initiaize columns for SCOPE_STATUS table
          m_column_en.TableId := insertTableRecord(m_table_en);

          -- SECENTITY_COLUMN
          m_column_en.ColumnType := 'SECENTITY_COLUMN';
          m_column_en.ColumnName := 'SECENTITY';
          m_column_en.AWName := l_global_ecm.SecEntityDim;
          m_column_id_num := insertColumnRecord(m_column_en);

          -- DIMDIM_COLUMN
          m_column_en.ColumnType := 'DIMDIM_COLUMN';
          m_column_en.ColumnName := 'DIMDIM';
          m_column_en.AWName := l_global_ecm.DimDim;
          m_column_id_num := insertColumnRecord(m_column_en);

          -- SCOPESTAT_COLUMN
          m_column_en.ColumnType := 'SCOPESTAT_COLUMN';
          m_column_en.ColumnName := 'SCOPESTAT';
          m_column_en.AWName := 'SECSCPSTAT.F';
          m_column_id_num := insertColumnRecord(m_column_en);

      --
      -- Data Exception table
      --

          m_table_en.TableName := zpb_metadata_names.get_data_exception_view(p_aw);
          m_table_en.TableType := 'DATA_EXCEPTION';

          -- initiaize columns for DATA_EXCEPTION table : currently no columns
          m_column_en.TableId := insertTableRecord(m_table_en);

      --
      -- Solve Input/Output level table
      --

          m_table_en.TableName := zpb_metadata_names.get_solve_level_table(p_aw);
          m_table_en.TableType := 'SOLVE_LEVEL';

          -- initiaize columns for SOLVE_LEVEL table : currently no columns
          m_column_en.TableId := insertTableRecord(m_table_en);

      --
      -- To Currency Tables
      --

          m_table_en.TableName := zpb_metadata_names.get_to_currency_view(p_aw);
          m_table_en.TableType := 'TO_CURRENCY';

          -- initiaize columns for to currency table
          m_column_en.TableId := insertTableRecord(m_table_en);

          -- MEMBER_ID COLUMN
          m_column_en.ColumnType := 'MEMBER_ID_COLUMN';
          m_column_en.ColumnName := 'MEMBER_ID';
          m_column_en.AWName := 'NA';
          m_column_id_num := insertColumnRecord(m_column_en);

          -- MEMBER_CODE COLUMN
          m_column_en.ColumnType := 'MEMBER_CODE_COLUMN';
          m_column_en.ColumnName := 'MEMBER_CODE';
          m_column_en.AWName := 'NA';
          m_column_id_num := insertColumnRecord(m_column_en);

          -- MEMBER_NAME COLUMN
          m_column_en.ColumnType := 'MEMBER_NAME_COLUMN';
          m_column_en.ColumnName := 'MEMBER_NAME';
          m_column_en.AWName := 'NA';
          m_column_id_num := insertColumnRecord(m_column_en);

          -- MEMBER_DESC COLUMN
          m_column_en.ColumnType := 'MEMBER_DESC_COLUMN';
          m_column_en.ColumnName := 'MEMBER_DESC';
          m_column_en.AWName := 'NA';
          m_column_id_num := insertColumnRecord(m_column_en);

      --
      -- Exchange Rates View
      --

          m_table_en.TableName := zpb_metadata_names.get_exch_rates_view(p_aw);
          m_table_en.TableType := 'EXCH_RATES';

          -- initiaize columns for to currency table
          m_column_en.TableId := insertTableRecord(m_table_en);

          -- MEMBER_ID COLUMN
          m_column_en.ColumnType := 'MEMBER_ID_COLUMN';
          m_column_en.ColumnName := 'MEMBER_ID';
          m_column_en.AWName := 'NA';
          m_column_id_num := insertColumnRecord(m_column_en);

          -- MEMBER_CODE COLUMN
          m_column_en.ColumnType := 'MEMBER_CODE_COLUMN';
          m_column_en.ColumnName := 'MEMBER_CODE';
          m_column_en.AWName := 'NA';
          m_column_id_num := insertColumnRecord(m_column_en);

          -- MEMBER_NAME COLUMN
          m_column_en.ColumnType := 'MEMBER_NAME_COLUMN';
          m_column_en.ColumnName := 'MEMBER_NAME';
          m_column_en.AWName := 'NA';
          m_column_id_num := insertColumnRecord(m_column_en);

          -- MEMBER_DESC COLUMN
          m_column_en.ColumnType := 'MEMBER_DESC_COLUMN';
          m_column_en.ColumnName := 'MEMBER_DESC';
          m_column_en.AWName := 'NA';
          m_column_id_num := insertColumnRecord(m_column_en);

      --
      -- Exchange Scenario
      --

          m_table_en.TableName := zpb_metadata_names.get_exch_scenario_view(p_aw);
          m_table_en.TableType := 'EXCH_SCENARIO';

          -- initiaize columns for to currency table
          m_column_en.TableId := insertTableRecord(m_table_en);

          -- MEMBER_ID COLUMN
          m_column_en.ColumnType := 'MEMBER_ID_COLUMN';
          m_column_en.ColumnName := 'MEMBER_ID';
          m_column_en.AWName := 'NA';
          m_column_id_num := insertColumnRecord(m_column_en);

          -- MEMBER_CODE COLUMN
          m_column_en.ColumnType := 'MEMBER_CODE_COLUMN';
          m_column_en.ColumnName := 'MEMBER_CODE';
          m_column_en.AWName := 'NA';
          m_column_id_num := insertColumnRecord(m_column_en);

          -- MEMBER_NAME COLUMN
          m_column_en.ColumnType := 'MEMBER_NAME_COLUMN';
          m_column_en.ColumnName := 'MEMBER_NAME';
          m_column_en.AWName := 'NA';
          m_column_id_num := insertColumnRecord(m_column_en);

          -- MEMBER_DESC COLUMN
          m_column_en.ColumnType := 'MEMBER_DESC_COLUMN';
          m_column_en.ColumnName := 'MEMBER_DESC';
          m_column_en.AWName := 'NA';
          m_column_id_num := insertColumnRecord(m_column_en);

   end if;

   zpb_aw.execute('pop oknullstatus '||l_global_ecm.AttrDim);

   zpb_log.write('zpb_metadata_pkg.build.end',
                 'Created metadata map for '||p_aw);

 EXCEPTION
  WHEN OTHERS THEN
    zpb_log.write_event(G_PKG_NAME||'.'||l_api_name,to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));
   return;

end BUILD;

-------------------------------------------------------------------------------
-- BUILD_EXCEPTION_INST - Returns the instance_id for the "fake" excpetion
--                        instance.  The cube and measure information for
--                                                this fake instance is never committed to DB but
--                                                used only in the session in which its created.
--
-- IN: p_sharedAw - The shared AW
--     p_persAw   - The personal AW
--     p_instance - The ID of the instance
--     p_name     - The name of the measures to be created
-------------------------------------------------------------------------------
procedure BUILD_EXCEPTION_INST(p_sharedAw in            varchar2,
                              p_persAw   in            varchar2,
                              p_instance in            varchar2,
                              p_name     in            varchar2,
                                                          p_user_id      in                        varchar2,
                                                          p_bus_area_id in                 varchar2,
                                                          p_fake_flag in           boolean,
                                                      p_start_up_flag in       boolean)
   is
      l_dim        varchar2(30);
      l_cube       varchar2(60);
      l_currInst   number;
      l_hiers      varchar2(1000);
      l_hier       varchar2(30);
      hi           number;
      hj           number;
      i            number;
      j            number;
      l_gid        boolean;
      l_aw         varchar2(30);
      l_global_ecm zpb_ecm.global_ecm;
      l_dim_ecm    zpb_ecm.dimension_ecm;
      nl           varchar2(1) := fnd_global.local_chr(10);
      l_cpr_meas_cube varchar2(64);
          l_frmcpr     varchar2(16);

   -- md table entries
   m_cube_en            zpb_md_records.cubes_entry;
   m_table_en           zpb_md_records.tables_entry;
   m_cube_dims_en       zpb_md_records.cube_dims_entry;
   m_column_en          zpb_md_records.columns_entry;
   m_cube_hier_en       zpb_md_records.cube_hier_entry;
   m_meas_en        zpb_md_records.measures_entry;

   m_cube_id            number;
   m_relation_id        number;
   m_meas_id            number;

  x_return_status     varchar2(4000);
  x_msg_count         number;
  x_msg_data          varchar2(4000);

   RETCODE                      varchar2(4000);
   ERRBUF                       varchar2(4000);
   l_msg_count          number;

      cursor dims is
         select DIMENSION_NAME
            from ZPB_CYCLE_MODEL_DIMENSIONS
            where ANALYSIS_CYCLE_ID = p_instance and
                                  nvl(REMOVE_DIMENSION_FLAG, 'N') <> 'Y'
          UNION select 'CAL_PERIODS' from dual;

        bus_area_id_num number;

begin

   bus_area_id_num := p_bus_area_id;

  -- need to do this to avoid a GCC hard-coded schema warning
  l_frmcpr := 'FRM';
  l_frmcpr := l_frmcpr || '.';
  l_frmcpr := l_frmcpr || 'CPR';

        -- called at definition time - need to initialize connection as running on
        -- AM connection
        if p_fake_flag then

           ZPB_AW.INITIALIZE_USER (P_API_VERSION      => 1.0,
                                   P_INIT_MSG_LIST    => FND_API.G_FALSE,
                                                           P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
                                   X_RETURN_STATUS    => RETCODE,
                                   X_MSG_COUNT        => l_msg_count,
                                   X_MSG_DATA         => ERRBUF,
                                                           P_USER                         => to_number(p_user_id),
                                   P_BUSINESS_AREA_ID => bus_area_id_num,
                                   p_attach_readwrite => FND_API.G_FALSE,
                                   p_sync_shared      => FND_API.G_FALSE);
        end if;

        -- called at status-sql generation time - need to run full start-up as running
        -- on AM connection and shared personal instances may need to be merged
        if p_start_up_flag then

          fnd_global.apps_initialize(p_user_id, p_user_id, fnd_global.RESP_APPL_ID);
          zpb_security_context.initcontext(p_user_id, p_user_id, sys_context('ZPB_CONTEXT', 'resp_id'),
                                       sys_context('ZPB_CONTEXT', 'session_id'), to_number(p_bus_area_id));

          ZPB_PERSONAL_AW.STARTUP(p_api_version=> 1.0,
                          p_init_msg_list=> FND_API.G_FALSE,
                          p_commit => FND_API.G_FALSE,
                          p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data,
                          p_user => p_user_id,
                          p_read_only => FND_API.G_TRUE);
         end if;


   l_global_ecm := zpb_ecm.get_global_ecm (p_persAw);
   l_aw         := zpb_aw.get_schema||'.'||p_persAw||'!';
   l_gid        := false;


   select CURRENT_INSTANCE_ID
      into l_currInst
      from ZPB_ANALYSIS_CYCLES
      where ANALYSIS_CYCLE_ID = p_instance;

           l_cube := zpb_metadata_names.get_exception_meas_cube(p_sharedAw,l_currInst);

           m_cube_en.Name := l_cube;
           m_cube_en.Type := 'PRSMEASCUBE';
           m_cube_en.EpbId :='NA';


          -- if called at generate-sql or evaluation time, need to update FRM.CPR formula
          -- make sure middle-tier cube points to view of actual processing instance for
          -- status-sql generation
          if p_fake_flag = false then
                -- update FRM.CPR formula
                zpb_aw.execute('call SC.EXCEPCPRMOD(''' || p_instance || ''')');

                l_cpr_meas_cube := zpb_aw.interp ('shw ' || l_aw || 'measviewrel (' || l_aw || 'measure ''' || l_frmcpr || ''')');
                l_cpr_meas_cube := l_cpr_meas_cube || '_PRS';

                 -- cube table
                select table_name into m_table_en.TableName
                from   zpb_cubes, zpb_tables
        where  zpb_cubes.name = l_cpr_meas_cube and
                           zpb_cubes.bus_area_id = bus_area_id_num and
                           zpb_cubes.table_id = zpb_tables.table_id;

          else

                m_table_en.TableName := zpb_metadata_names.get_exception_check_tbl(p_sharedAw);

          end if;

           m_table_en.AwName :='NA';
           m_table_en.TableType := 'MEASURE';

           m_cube_en.TableId := insertTableRecord(m_table_en);
           m_cube_id := insertCubeRecord(m_cube_en);

           -- initialize cube-dim relation entry and cube-hier relation entry
           m_cube_dims_en.CubeId := m_cube_id;
           m_cube_hier_en.CubeId := m_cube_id;

           -- initialize column entry for cube table
           m_column_en.TableId :=m_cube_en.TableId;

           for each in dims loop
              l_dim := zpb_aw.interp ('shw lmt('||l_aw||l_global_ecm.DimDim||' to '||
                              l_aw||l_global_ecm.ExpObjVar||' eq '''||
                              each.DIMENSION_NAME||''')');

                  -- set dimension id for cube-dims relation
                  select dimension_id into m_cube_dims_en.dimensionId
          from zpb_dimensions
          where epb_id = l_dim and
                                bus_area_id = bus_area_id_num;

                  m_column_en.ColumnType :='MEMBER_COLUMN';
                  m_column_en.ColumnName := zpb_metadata_names.get_dimension_column(l_dim);
                  m_column_en.AwName := 'NA';

                  -- insert Column and Reference column_id in cube-dim relation
                  m_cube_dims_en.ColumnId := insertColumnRecord(m_column_en);

                  m_relation_id := insertCubeDimsRecord(m_cube_dims_en);

              l_dim_ecm := zpb_ecm.get_dimension_ecm(l_dim, p_sharedAw);

              if (zpb_aw.interp('shw obj(dimmax '''||l_aw||l_dim_ecm.HierDim||
                                ''')') <> '0') then
                 zpb_aw.execute ('lmt '||l_aw||l_dim_Ecm.HierDim||' to all');
                 l_hiers := zpb_aw.interp ('shw CM.GETDIMVALUES('''||l_aw||
                                           l_dim_Ecm.HierDim||''' yes)');
                 hi := 1;
                 loop
                    hj := instr (l_hiers, ' ', hi);
                    if (hj = 0) then
                       l_hier := substr (l_hiers, hi);
                     else
                       l_hier := substr (l_hiers, hi, hj-hi);
                       hi     := hj+1;
                    end if;

                          -- insert hierarchy columns into cube table
                          m_column_en.ColumnType :='GID_COLUMN';
                          m_column_en.ColumnName := zpb_metadata_names.get_dim_gid_column(l_dim, l_hier);
                          m_column_en.AwName := 'NA';

                          -- insert Column and Reference column_id in cube-hier relation
                          m_cube_hier_en.ColumnId :=insertColumnRecord(m_column_en);

                          -- set hierarchy id for cube-hier relation entry
                      select hierarchy_id into m_cube_hier_en.hierarchyId
                      from zpb_hierarchies
                      where epb_id = l_hier and
                                    dimension_id = m_cube_dims_en.dimensionId;

                          m_relation_id := insertCubeHierRecord(m_cube_hier_en);

                    exit when hj=0;
                 end loop;
               elsif (l_gid = false) then
                 l_gid := true;

                          m_column_en.ColumnType :='GID_COLUMN';
                          m_column_en.ColumnName := zpb_metadata_names.get_dim_gid_column;
                          m_column_en.AwName := 'NA';

                          -- insert Column and Reference column_id in cube-hier relation
                          m_cube_hier_en.ColumnId :=insertColumnRecord(m_column_en);

                          select hierarchy_id into m_cube_hier_en.hierarchyId
                          from   zpb_hierarchies
                          where  dimension_id = m_cube_dims_en.dimensionId and
                                     hier_type = 'NULL';

                          m_relation_id := insertCubeHierRecord(m_cube_hier_en);

              end if;
              exit when j=0;
           end loop;

          -- initialize measure entry
          m_meas_en.CubeId := m_cube_id;
          m_meas_en.Name := p_name;
          m_meas_en.CwmName := zpb_metadata_names.get_exception_meas_cwm2(p_persAw, l_currInst);
          m_meas_en.Type := 'EXCEPTION_DATA';
          m_meas_en.InstanceId := l_currInst;

      m_meas_en.AwName := l_frmcpr;
          m_meas_en.CurrencyType :='NA';
          m_meas_en.SelectedCur :='NA';
          m_meas_en.CurrInstFlag := 'N';
          m_meas_en.CPRMeasure :='YES';

          -- insert column entry for measure col of cube table
          m_column_en.ColumnType :='EXCEPTION_COLUMN';

          if p_fake_flag = false then
                  m_column_en.ColumnName := 'COL_DF_CPR';
          else
                  m_column_en.ColumnName := zpb_metadata_names.get_exception_column;
          end if;

          m_column_en.AwName := 'NA';

          m_meas_en.ColumnId := insertColumnRecord(m_column_en);

          -- insert Measure Entry
          m_meas_id := insertMeasureRecord(m_meas_en);
end BUILD_EXCEPTION_INST;

-------------------------------------------------------------------------------
-- BUILD_OWNERMAP_MEASURE - Exposes MD for containing cube and ownermap measure
--
-- IN: p_aw   - The AW of the ownermap measure
--     p_dims - The dimensions of the ownermap measure
-------------------------------------------------------------------------------
procedure BUILD_OWNERMAP_MEASURE(p_aw       in            varchar2,
                                 p_dims     in            varchar2)
   is
      i                 number;
      j                 number;
      hi                number;
      hj                number;
      l_gid             boolean;
      l_aw              varchar2(30);
      l_hiers           varchar2(1000);
      l_hier            varchar2(30);
      l_dim             varchar2(30);
      nl                varchar2(1) := fnd_global.local_chr(10);
      l_dim_ecm         zpb_ecm.dimension_ecm;

   -- md table entries
   m_cube_en            zpb_md_records.cubes_entry;
   m_table_en           zpb_md_records.tables_entry;
   m_cube_dims_en       zpb_md_records.cube_dims_entry;
   m_column_en          zpb_md_records.columns_entry;
   m_cube_hier_en       zpb_md_records.cube_hier_entry;
   m_meas_en        zpb_md_records.measures_entry;

   m_cube_id            number;
   m_relation_id        number;
   m_meas_id            number;
   bus_area_id_num      number;
   existing_cube        number;

begin

   bus_area_id_num := sys_context('ZPB_CONTEXT', 'business_area_id');

   -- remove existing ownermap cube
   begin

                select cube_id into existing_cube
                from zpb_cubes
                where bus_area_id = bus_area_id_num and
                          name like '%OWNERMAP%';

                deleteCubeRecord(existing_cube);

        exception
                when NO_DATA_FOUND then
                null;
        end;

   l_gid    := false;
   l_aw     := zpb_aw.get_schema||'.'||p_aw||'!';
   i := 1;

   -- initialize cube entry
   m_cube_en.Name := zpb_metadata_names.get_ownermap_cwm2_cube(p_aw);
   m_cube_en.Type := 'MEASCUBE';
   m_cube_en.EpbID :='NA';

   -- cube table
   m_table_en.TableName := zpb_metadata_names.get_ownermap_view(p_aw);
   m_table_en.AwName :='NA';
   m_table_en.TableType := 'MEASURE';

   m_cube_en.TableId := insertTableRecord(m_table_en);
   m_cube_id := insertCubeRecord(m_cube_en);

   -- initialize cube-dim relation entry and cube-hier relation entry
   m_cube_dims_en.CubeId := m_cube_id;
   m_cube_hier_en.CubeId := m_cube_id;

   -- initialize column entry for cube table
   m_column_en.TableId :=m_cube_en.TableId;

   loop
      j := instr (p_dims, ' ', i);
      if (j = 0) then
         l_dim := substr (p_dims, i);
       else
         l_dim := substr (p_dims, i, j-i);
         i     := j+1;
      end if;
      l_dim_ecm := zpb_ecm.get_dimension_ecm(l_dim, p_aw);

      -- initialize dimension entry
          m_column_en.ColumnName := zpb_metadata_names.get_dimension_column(l_dim);
          m_column_en.ColumnType := 'MEMBER_COLUMN';
          m_column_en.AWName :='NA';

          -- set dimension id for cube-dims relation
          select dimension_id into m_cube_dims_en.dimensionId
      from zpb_dimensions
      where epb_id = l_dim and
                        bus_area_id = bus_area_id_num;

          m_cube_dims_en.ColumnId := insertColumnRecord(m_column_en);

          m_relation_id := insertCubeDimsRecord(m_cube_dims_en);

      if (zpb_aw.interp('shw obj(dimmax '''||l_aw||l_dim_ecm.HierDim||''')')
          <> '0') then
         zpb_aw.execute ('lmt '||l_aw||l_dim_Ecm.HierDim||' to all');
         l_hiers := zpb_aw.interp ('shw CM.GETDIMVALUES('''||l_aw||
                                   l_dim_Ecm.HierDim||''' yes)');
         hi := 1;
         loop
            hj := instr (l_hiers, ' ', hi);
            if (hj = 0) then
               l_hier := substr (l_hiers, hi);
             else
               l_hier := substr (l_hiers, hi, hj-hi);
               hi     := hj+1;
            end if;

                  -- insert hierarchy columns into cube table
                  m_column_en.ColumnType :='GID_COLUMN';
                  m_column_en.ColumnName := zpb_metadata_names.get_dim_gid_column(l_dim, l_hier);
                  m_column_en.AwName := 'NA';

                  -- insert Column and Reference column_id in cube-hier relation
                  m_cube_hier_en.ColumnId :=insertColumnRecord(m_column_en);

                  -- set hierarchy id for cube-hier relation entry
              select hierarchy_id into m_cube_hier_en.hierarchyId
              from zpb_hierarchies
              where epb_id = l_hier and
                                dimension_id = m_cube_dims_en.dimensionId;

                  m_relation_id := insertCubeHierRecord(m_cube_hier_en);
            exit when hj=0;
         end loop;
       elsif (l_gid = false) then
         l_gid := true;

                  m_column_en.ColumnType :='GID_COLUMN';
                  m_column_en.ColumnName := zpb_metadata_names.get_dim_gid_column;
                  m_column_en.AwName := 'NA';

                  -- insert Column and Reference column_id in cube-hier relation
                  m_cube_hier_en.ColumnId :=insertColumnRecord(m_column_en);

                  select hierarchy_id into m_cube_hier_en.hierarchyId
                  from   zpb_hierarchies
                  where  dimension_id = m_cube_dims_en.dimensionId and
                             hier_type = 'NULL';

                  m_relation_id := insertCubeHierRecord(m_cube_hier_en);

      end if;
      exit when j=0;
   end loop;

          -- initialize measure entry
          m_meas_en.CubeId := m_cube_id;
          m_meas_en.Name := 'OWNERMAP';
          m_meas_en.CwmName := zpb_metadata_names.get_ownermap_cwm2_name(p_aw);
          m_meas_en.Type := 'OWNERMAP';

      m_meas_en.AwName :='NA';
          m_meas_en.CurrencyType :='NA';
          m_meas_en.SelectedCur :='NA';
          m_meas_en.CurrInstFlag := 'N';

          -- insert column entry for measure col of cube table
          m_column_en.ColumnType :='OWNERMAP';
          m_column_en.ColumnName := zpb_metadata_names.get_ownermap_column;
          m_column_en.AwName := 'NA';

          m_meas_en.ColumnId := insertColumnRecord(m_column_en);

          -- insert Measure Entry
          m_meas_id := insertMeasureRecord(m_meas_en);

end BUILD_OWNERMAP_MEASURE;

-------------------------------------------------------------------------------
-- REMOVE_INSTANCE - Removes the metadata for a given instance
--
-- IN: p_aw       - The AW to build on
--     p_instance - The ID of the instance
--     p_type     - The type of the instance (PERSONAL, SHARED_VOEW, etc)
--     p_template - The template ID. Null is not applicable
--     p_approvee - The approvee ID. Null is not applicable
-------------------------------------------------------------------------------
procedure REMOVE_INSTANCE(p_aw       in            varchar2,
                          p_instance in            varchar2,
                          p_type     in            varchar2,
                          p_template in            varchar2,
                          p_approvee in            varchar2)
   is
      l_instType    varchar2(60);
      l_objName     varchar2(60);
      l_meas        varchar2(30);
      l_names       varchar2(500);
      l_instance    number;
      l_count       number;
      l_dltWriteSec boolean;
begin

   -- right now, only delete MD for personal measures, as SHARED_VIEW
   -- MD is shared between all users
  if(instr(p_type, 'PERSONAL') > 0 or instr(p_type, 'APPROVER') > 0) then

   l_instType   := zpb_aw.interp ('shw CM.GETINSTOBJECT('''||p_instance||
                                  ''' ''TYPE'')');
   if (instr (l_instType, 'CALC') > 0) then
      l_instType := p_type||' CALC';
    else
      l_instType := p_type;
   end if;

   l_objName := 'OBJECT ID'' NA ';
   if (p_approvee is not null) then
      l_objName := l_objName||''''||p_approvee||''' ';
    else
      l_objName := l_objName||'NA ';
   end if;
   if (p_template is not null) then
      l_objName := l_objName||''''||p_template||'''';
   end if;

   l_meas := zpb_aw.interp ('shw CM.GETINSTOBJECT('''||p_instance||''' '''||
                            l_instType||' DATA '||l_objName||'''');

   delete from zpb_measures
      where measure_id in
      (select measure_id from zpb_measures, zpb_cubes
       where zpb_measures.cube_id = zpb_cubes.cube_id and
       zpb_cubes.name like '%'||p_aw||'/_%' escape '/' and
       zpb_measures.epb_id= l_meas);

   l_meas := zpb_aw.interp ('shw CM.GETINSTOBJECT('''||p_instance||''' '''||
                            l_instType||' ANNOTATION '||l_objName||'''');

   delete from zpb_measures
      where measure_id in
      (select measure_id from zpb_measures, zpb_cubes
       where zpb_measures.cube_id = zpb_cubes.cube_id and
       zpb_cubes.name like '%'||p_aw||'/_%' escape '/' and
       zpb_measures.epb_id= l_meas);

   l_meas := zpb_aw.interp ('shw CM.GETINSTOBJECT('''||p_instance||''' '''||
                            l_instType||' FORMAT '||l_objName||'''');
   delete from zpb_measures
      where measure_id in
      (select measure_id from zpb_measures, zpb_cubes
       where zpb_measures.cube_id = zpb_cubes.cube_id and
       zpb_cubes.name like '%'||p_aw||'/_%' escape '/' and
       zpb_measures.epb_id= l_meas);

   if (p_type = 'PERSONAL') then
      l_instance := to_number(zpb_aw.interp('shw CM.GETPHYSICALINSTANCE('''||
                                            p_instance||''')'));
      select count(*)
         into l_count
         from ZPB_MEASURES
         where INSTANCE_ID = l_instance
         and TYPE = 'PERSONAL_DATA'
         and CUBE_ID in (select CUBE_ID from ZPB_CUBES
                         where NAME like '%'||p_aw||'/_%' escape '/');
      if (l_count > 0) then
         l_dltWriteSec := false;
       else
         l_dltWriteSec := true;
      end if;
    else
      l_dltWriteSec := true;
   end if;

   if (l_dltWriteSec) then
      l_meas := zpb_aw.interp ('shw CM.GETINSTOBJECT('''||p_instance||''' '''||
                               l_instType||' WRITE SECURITY '||l_objName||'''');
      delete from zpb_measures
         where measure_id in
         (select measure_id from zpb_measures, zpb_cubes
          where zpb_measures.cube_id = zpb_cubes.cube_id and
          zpb_cubes.name like '%'||p_aw||'/_%' escape '/' and
          zpb_measures.epb_id= l_meas);
   end if;

   if (p_type = 'PERSONAL' or p_type = 'SHARED') then
      l_meas := zpb_aw.interp ('shw CM.GETINSTOBJECT('''||p_instance||''' '''||
                               l_instType||' TARGET '||l_objName||'''');
      delete from zpb_measures
         where measure_id in
         (select measure_id from zpb_measures, zpb_cubes
          where zpb_measures.cube_id = zpb_cubes.cube_id and
          zpb_cubes.name like '%'||p_aw||'/_%' escape '/' and
          zpb_measures.epb_id= l_meas);

      l_meas := zpb_aw.interp ('shw CM.GETINSTOBJECT('''||p_instance||''' '''||
                               l_instType||' TARGET TYPE '||l_objName||'''');
      delete from zpb_measures
         where measure_id in
         (select measure_id from zpb_measures, zpb_cubes
          where zpb_measures.cube_id = zpb_cubes.cube_id and
          zpb_cubes.name like '%'||p_aw||'/_%' escape '/' and
          zpb_measures.epb_id= l_meas);

      if (l_dltWriteSec) then
         l_meas := zpb_aw.interp ('shw CM.GETINSTOBJECT('''||p_instance||''' '''||
                                  l_instType||' INPUT LEVEL OBJECT ID''');
         delete from zpb_measures
            where measure_id in
            (select measure_id from zpb_measures, zpb_cubes
             where zpb_measures.cube_id = zpb_cubes.cube_id and
             zpb_cubes.name like '%'||p_aw||'/_%' escape '/' and
             zpb_measures.epb_id= l_meas);
      end if;
   end if;
  end if;

end REMOVE_INSTANCE;

-------------------------------------------------------------------------------
--  delete_shared_cubes -          Procedure deletes all shared and shared "personal" cubes and the
--                                                 contained measures for the specified business area
-------------------------------------------------------------------------------
procedure delete_shared_cubes(p_sharaw in varchar2) is

        bus_area_id_num number;

        cursor cubes_cursor is
                select cube_id
                from   zpb_cubes
                where  bus_area_id = bus_area_id_num and
                           name like p_sharaw || '%';

begin

--   zpb_log.write_error('zpb_metadata_pkg.delete_user',
--                 'Deleteing User '||p_user);

        bus_area_id_num := sys_context('ZPB_CONTEXT', 'business_area_id');

          for cube in cubes_cursor loop
                  deleteCubeRecord(cube.cube_id);
          end loop;

end delete_shared_cubes;
-------------------------------------------------------------------------------
--  delete_user -          Procedure deletes all personal "personal" cubes and the
--                                         contained measures for the specified user
-------------------------------------------------------------------------------
procedure delete_user(p_user varchar2) is

        l_api_name      CONSTANT VARCHAR2(30) := 'DELETE_USER';
        bus_area_id_num number;

        cursor cubes_cursor is
                select cube_id
                from   zpb_cubes
                where  bus_area_id = bus_area_id_num and
                           name like p_user || '/_%' escape '/';

begin

--   zpb_log.write_error('zpb_metadata_pkg.delete_user',
--                 'Deleteing User '||p_user);

    bus_area_id_num := sys_context('ZPB_CONTEXT', 'business_area_id');

    if (p_user is not null) then
          for cube in cubes_cursor loop
                  deleteCubeRecord(cube.cube_id);
          end loop;

        -- clean user scope tables
            delete zpb_hier_scope
        where  user_id = to_number(p_user) and
                   hierarchy_id in (select hierarchy_id
                                          from   zpb_hierarchies hier,
                                                 zpb_dimensions  dims
                                          where  hier.dimension_id = dims.dimension_id and
                                                 dims.bus_area_id = bus_area_id_num);

        delete zpb_hier_level_scope
        where  user_id = to_number(p_user) and
                   hier_id in (select hierarchy_id
                                          from   zpb_hierarchies hier,
                                                 zpb_dimensions  dims
                                          where  hier.dimension_id = dims.dimension_id and
                                                 dims.bus_area_id = bus_area_id_num);

        delete zpb_attribute_scope
        where  user_id = to_number(p_user) and
                   attribute_id in (select attribute_id
                                                    from        zpb_attributes attr,
                                                                zpb_dimensions dims
                                                        where   attr.dimension_id = dims.dimension_id and
                                                                dims.bus_area_id = bus_area_id_num);

    end if;

 EXCEPTION
  WHEN OTHERS THEN
    zpb_log.write_event(G_PKG_NAME||'.'||l_api_name,to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));
  return;

end delete_user;

-------------------------------------------------------------------------------
-- BUILD_PERSONAL_DIMS - Updates user's personal scoping for hierarchies, levels,
--                                               and attributes.  Updates user's personal levels.
--
-- IN: p_aw       - The AW to build
--     p_sharedAW - The shared AW (may be the same as p_aw)
--     p_type     - The AW type (PERSONAL or SHARED)
--     p_dims     - Space separated list of dim ID's
-------------------------------------------------------------------------------
procedure BUILD_PERSONAL_DIMS(p_aw               in   varchar2,
                                  p_sharedAw     in   varchar2,
                                  p_type         in   varchar2,
                                  p_dims         in   varchar2)
   is
          l_api_name      CONSTANT VARCHAR2(30) := 'BUILD_INSTANCE';

      l_hiers           varchar2(500);
      l_levels          varchar2(500);
      l_attrs           varchar2(500);
      l_attrId          varchar2(30);
      l_dim             varchar2(32);
      l_hier            varchar2(32);
      l_level           varchar2(32);
      l_lvlhier         varchar2(32);
      l_persLvl         boolean;
      l_attr            varchar2(32);
      l_aw              varchar2(32);
      l_viewAw          varchar2(32);
      i                 number;
      j                 number;
      hi                number;
      hj                number;
      li                number;
      lj                number;
      ai                number;
      aj                number;
      l_length          number;
      nl                varchar2(1) := fnd_global.local_chr(10);

      l_global_ecm      zpb_ecm.global_ecm;
      l_dim_data        zpb_ecm.dimension_data;
          l_range_dim_data  zpb_ecm.dimension_data;
      l_dim_ecm         zpb_ecm.dimension_ecm;
      l_dim_time_ecm    zpb_ecm.dimension_time_ecm;
      l_global_attr_ecm zpb_ecm.global_attr_ecm;
      l_attr_ecm        zpb_ecm.attr_ecm;

          bus_area_id_num               number;

          -- language looping
          l_langs                       varchar2(500);
          l_lang                        FND_LANGUAGES.LANGUAGE_CODE%type;
          htld_i                        number;
          htld_j                        number;

          l_dimension_id        number;

          l_user_id                     number;
          l_hier_scope_en   zpb_md_records.hier_scope_entry;
          l_hier_perscwm    varchar2(60);

          l_hl_scope_en         zpb_md_records.hier_level_scope_entry;

          l_level_perscwm   varchar2(60);
          l_attr_perscwm        varchar2(60);

          l_pers_hier_table_name varchar2(60);

          l_attr_scope_en   zpb_md_records.attribute_scope_entry;

          l_dummy_num           number;

          l_hr_pers_table_en    zpb_md_records.tables_entry;
          l_level_en            zpb_md_records.levels_entry;
          l_pers_column_en              zpb_md_records.columns_entry;
          l_level_tl_en             zpb_md_records.levels_tl_entry;
          l_level_or_str        varchar2(16);

          l_start_time          date;
          l_accessToAHier   boolean;
          l_nullHierCnt     number;

          -- cursor for scoping special attributes
          cursor c_special_attrs is
                select attribute_id
                from   zpb_attributes
                where  dimension_id = l_dimension_id and
                           type in ('TIMESPAN_ATTRIBUTE', 'ENDDATE_ATTRIBUTE', 'SHORT_VALUE_NAME_ATTRIBUTE', 'VALUE_NAME_ATTRIBUTE');

           -- cursor for scoping null hierarchies of range dimensions
           cursor c_range_dim_null_hiers is
                select  hier.hierarchy_id, hier.pers_table_id
                from    zpb_hierarchies hier,
                        zpb_dimensions  dims,
                        zpb_attributes  attr
                where   dims.bus_area_id = bus_area_id_num and
                        dims.dimension_id = attr.range_dim_id and
                        dims.dimension_id = hier.dimension_id;

           -- cursor for scoping level of null hierarchies of range dimensions
       cursor c_range_dim_null_hier_levels is
                select  hl.hier_id, hl.level_id, hl.pers_col_id
                from    zpb_hier_level hl,
                        zpb_dimensions dims,
                        zpb_attributes attr,
                        zpb_hierarchies hier
                where   dims.bus_area_id = bus_area_id_num and
                        dims.dimension_id = attr.range_dim_id and
                        dims.dimension_id = hier.dimension_id and
                        hl.hier_id = hier.hierarchy_id;

           -- cursor for scoping attributes of personal range dimensions
           cursor c_range_dim_attrs is
                select  attr2.attribute_id
                from    zpb_dimensions  dims,
                        zpb_attributes  attr,
                zpb_attributes  attr2
                where   dims.bus_area_id = bus_area_id_num and
                        dims.dimension_id = attr.range_dim_id and
                        dims.dimension_id = attr2.dimension_id;

begin
   l_aw              := zpb_aw.get_schema||'.'||p_aw||'!';
   l_global_ecm      := zpb_ecm.get_global_ecm (p_aw);
   l_global_attr_ecm := zpb_ecm.get_global_attr_ecm(p_aw);

   -- save start time.  At the end we will remove all scoping entries that were
   -- created prior to this time, as they are no longer valid
   select sysdate into l_start_time from dual;

   l_user_id := to_number(sys_context('ZPB_CONTEXT', 'shadow_id'));

   bus_area_id_num := sys_context('ZPB_CONTEXT', 'business_area_id');

   zpb_aw.execute('push oknullstatus');
   zpb_aw.execute('oknullstatus = yes');

   -- Loop over all dimensions
   i := 1;
   loop
      j := instr (p_dims, ' ', i);
      if (j = 0) then
         l_dim := substr (p_dims, i);
       else
         l_dim := substr (p_dims, i, j-i);
         i     := j+1;
      end if;


          -- flag tracks whether user has access to at least one hierarchy for each dimension
          l_accessToAHier:= false;

          select dimension_id into l_dimension_id
          from   zpb_dimensions
          where  epb_id = l_dim and
                         bus_area_id = bus_area_id_num;

        -- Reset all of the personal personal hierarchy table id's to the personal
        -- hierarchy tables.  In the case that the user still has personal levels
        -- they will be set appropriately back to the personal personal hierarchy tables below.
        update zpb_hier_scope hscope
        set hscope.pers_table_id = (select pers_table_id
                                                                from zpb_hierarchies hier
                                        where hscope.hierarchy_id = hier.hierarchy_id)
        where hscope.user_id = l_user_id and
                          hscope.user_id = nvl(to_number(sys_context('ZPB_CONTEXT', 'resp_id')), FND_GLOBAL.RESP_ID) and
                  hscope.hierarchy_id in (select hierarchy_id
                                          from   zpb_hierarchies hier,
                                                 zpb_dimensions  dims
                                          where  hier.dimension_id = dims.dimension_id and
                                                 dims.bus_area_id = bus_area_id_num and
                                                                                                 dims.dimension_id = l_dimension_id);

      l_dim_data := zpb_ecm.get_dimension_data (l_dim, p_aw);
      l_dim_ecm  := zpb_ecm.get_dimension_ecm (l_dim, p_aw);

          -- see if we need to later create a scope entry for null hierarchy of this dimension
          select count(hierarchy_id) into l_nullHierCnt
          from zpb_hierarchies
          where dimension_id=l_dimension_id and hier_type='NULL';

      zpb_aw.execute('push '||l_aw||l_dim_data.ExpObj);

      if (zpb_aw.interp('shw obj(dimmax '''||l_aw||l_dim_ecm.HierDim||
                        ''')') <> '0') then
         hi := 1;
         l_hiers :=zpb_aw.interp
            ('shw CM.GETDIMVALUES('''||l_aw||l_dim_ecm.HierDim||''')');

         zpb_aw.execute ('push '||l_aw||l_dim_ecm.LevelDim);
         zpb_aw.execute ('push '||l_aw||l_dim_ecm.HierDim);
         loop -- LOOP OVER ALL HIERARCHIES
            hj    := instr (l_hiers, ' ', hi);
            if (hj = 0) then
               l_hier := substr (l_hiers, hi);
             else
               l_hier := substr (l_hiers, hi, hj-hi);
               hi     := hj+1;
            end if;

            l_persLvl:=false;

            zpb_aw.execute('lmt '||l_aw||l_dim_ecm.HierDim||' to '''||
                           l_hier||'''');
--            dbms_output.put_line('looking at hierarchy ' || l_hier);

            zpb_aw.execute('lmt '||l_aw||l_dim_data.ExpObj||' to '||l_aw||
                           l_dim_ecm.HOrderVS);
            if (zpb_aw.interp('shw convert(statlen('||l_aw||l_dim_data.ExpObj||
                              ') text 0 no no)') <> 0) then

                          l_accessToAHier:=true;

                          -- add scope for this hierarchy
                          l_hier_scope_en.UserId := l_user_id;
                          l_hier_perscwm := zpb_metadata_names.get_hierarchy_cwm2_name('PRS', l_dim, l_hier);

                                select hierarchy_id, pers_table_id
                                into   l_hier_scope_en.HierarchyId, l_hier_scope_en.PersTableId
                                from   zpb_hierarchies
                                where  dimension_id = l_dimension_id and
                                           pers_cwm_name = l_hier_perscwm;

                                l_dummy_num := insertHierScopeRecord(l_hier_scope_en);

               zpb_aw.execute('lmt '||l_aw||l_dim_ecm.LevelDim||
                              ' to &joinchars ('''||l_aw||''' obj(property '''
                              ||'HIERLEVELVS'' '''||l_dim_ecm.HierDim||'''))');
               zpb_aw.execute('sort '||l_aw||l_dim_ecm.levelDim||
                              ' a &joinchars ('''||l_aw||''' obj(property '''
                            ||'LEVELDEPTHVAR'' '''||l_dim_ecm.HierDim||'''))');

                --
                -- Get the Levels:
                --
                li          := 1;
                l_levels    := zpb_aw.interp('shw CM.GETDIMVALUES('''||l_aw||
                                            l_dim_ecm.LevelDim||''', YES)');

                loop -- Loop over all levels for hierarchy
                  lj    := instr (l_levels, ' ', li);
                  if (lj = 0) then
                     l_level := substr (l_levels, li);
                   else
                     l_level := substr (l_levels, li, lj-li);
                     li      := lj+1;
                  end if;

                  zpb_aw.execute('lmt '||l_aw||l_dim_ecm.LevelDim||' to '''||
                                 l_level||'''');

--                               dbms_output.put_line('Looking at level: ' || l_level);

                  --
                  -- Check to see if any members are at this level:
                  --
                  zpb_aw.execute('lmt '||l_aw||l_dim_data.ExpObj||' to '||
                                 l_aw||l_dim_ecm.HOrderVS);

                  zpb_aw.execute ('lmt '||l_aw||l_dim_data.ExpObj||' keep '||
                                  l_aw||l_dim_ecm.LevelRel);
                  l_length := to_number(zpb_aw.interp('shw convert(statlen ('||
                                l_aw||l_dim_data.ExpObj||') text 0 no no)'));
                  if (l_length > 0) then

--                                       dbms_output.put_line('Level has members');

                     l_lvlHier := l_hier;
                     l_level_perscwm := zpb_metadata_names.get_level_cwm2_name('PRS', l_dim, l_lvlHier, l_level);

                                         -- Although we are calling the insert commands for the personal personal table and
                                         -- the personal column records, we expect them to already exist, and are just using
                                         -- the insert helper functions to get information back (ids of the table and columns)
                     l_hr_pers_table_en.TableName := zpb_metadata_names.get_dimension_view
                                                                                (p_aw, 'PERSONAL', l_dim, l_hier);
                     l_hr_pers_table_en.AwName := p_aw;
                     l_hr_pers_table_en.BusAreaId := bus_area_id_num;
                     l_hr_pers_table_en.TableType :='HIERARCHY';
                     l_pers_column_en.TableId:= insertTableRecord(l_hr_pers_table_en);

                     l_pers_column_en.columnType :='LEVEL_COLUMN';
                     l_pers_column_en.columnName := zpb_metadata_names.get_level_column(l_dim, l_level);

                     l_hl_scope_en.PersColId := insertColumnRecord(l_pers_column_en);

--                                       dbms_output.put_line('About to check personal');
                     -- Personal Level Check
                     if zpb_aw.interpbool('shw '|| l_aw||l_dim_ecm.LevelPersVar) then
--                         dbms_output.put_line('Pers Level');
                                                 -- personal level, need to create MD for the level itself and for the personal personal hierarchy table
                         l_persLvl :=true;

                            -- update the zpb_hier_scope entry for this hierarchy to use pesonal personal hierarchy table
                            update zpb_hier_scope
                            set pers_table_id = l_pers_column_en.TableId
                            where user_id = l_user_id and
                                                                  resp_id = nvl(to_number(sys_context('ZPB_CONTEXT', 'resp_id')), FND_GLOBAL.RESP_ID) and
                                  hierarchy_id = l_hier_scope_en.HierarchyId;

                          end if;

                                         -- add a scoping entry
                                         l_hl_scope_en.HierId := l_hier_scope_en.HierarchyId;

                                         select level_id into l_hl_scope_en.LevelId
                                         from   zpb_levels
                                         where  pers_cwm_name = l_level_perscwm and
                                                        dimension_id = l_dimension_id;

                                         l_hl_scope_en.UserId := l_user_id;
                                         l_dummy_num := insertHierlevelScopeRecord(l_hl_scope_en);

               end if; -- end of members at level if

             exit when lj = 0;
             end loop; -- End level loop

             -- Run Query that will update zpb_hier_level_scope pers_col_id entries
             -- for all levels of hierarchy for this user back to the pers_col_id column
             -- of zpb_hier_level if user had no personal levels for this hierarchy
             if l_persLvl = false then

              update zpb_hier_level_scope hlevscope
              set hlevscope.pers_col_id = (select pers_col_id from zpb_hier_level hlev
                                                              where hlevscope.hier_id = hlev.hier_id and
                                                                    hlevscope.level_id = hlev.level_id)
                                           where hlevscope.user_id = l_user_id and
                                                                                                 hlevscope.resp_id = nvl(to_number(sys_context('ZPB_CONTEXT', 'resp_id')), FND_GLOBAL.RESP_ID) and
                                                 hlevscope.hier_id = l_hier_scope_en.HierarchyId;
             end if;

           end if; -- Does this hierarchy have members check

           exit when hj = 0;
         end loop; -- End looping over Hierarchies

         zpb_aw.execute ('pop '||l_aw||l_dim_ecm.LevelDim);
         zpb_aw.execute ('pop '||l_aw||l_dim_ecm.HierDim);

      end if;

      -- create scope entry for null hierarchy when one exists
          if l_nullHierCnt=1  then
        zpb_aw.execute('lmt '||l_aw||l_dim_data.ExpObj||' to all');
        if (zpb_aw.interp('shw convert(statlen('||l_aw||l_dim_data.ExpObj||
                              ') text 0 no no)') <> 0) then

                        select hierarchy_id, pers_table_id
                        into   l_hier_scope_en.HierarchyId, l_hier_scope_en.PersTableId
                        from   zpb_hierarchies
                        where  dimension_id = l_dimension_id and
                                   hier_type='NULL';

                        l_hier_scope_en.UserId := l_user_id;

                        l_dummy_num := insertHierScopeRecord(l_hier_scope_en);

                        select hier_id, level_id, pers_col_id
                        into   l_hl_scope_en.HierId, l_hl_scope_en.LevelId, l_hl_scope_en.PersColId
                        from   zpb_hier_level
                        where  hier_id = l_hier_scope_en.HierarchyId;

                        l_hl_scope_en.UserId := l_user_id;

                    l_dummy_num := insertHierlevelScopeRecord(l_hl_scope_en);

                    l_accessToAHier := true;

                end if; -- any members for dim?

          end if; -- need for null hier

          -- access to at least one hierarchy
          if l_accessToAHier = false then
                ZPB_ERROR_HANDLER.REGISTER_WARNING
         (G_PKG_NAME,
          l_api_name,
          'ZPB_STARTUP_NOHIER_WARN', 'DIM', l_dim_data.Sdsc );
--             dbms_output.put_line('ZPB_STARTUP_NOHIER_WARN : ' || l_dim_data.Sdsc);
         zpb_log.write_event(G_PKG_NAME||'.'||l_api_name, 'ZPB_STARTUP_NOHIER_WARN : ' || l_dim_data.Sdsc);
          end if;


          -- give scope to user to the null hierarchies of all attribute range dimensions
      for hier in c_range_dim_null_hiers loop
                l_hier_scope_en.UserId := l_user_id;
                l_hier_scope_en.HierarchyId := hier.hierarchy_id;
                l_hier_scope_en.PersTableId := hier.pers_table_id;
                l_dummy_num := insertHierScopeRecord(l_hier_scope_en);
          end loop;

          -- give scope to user to the levels of null hierarchies of all attribute range dimensions
         for hierlev in c_range_dim_null_hier_levels loop
                l_hl_scope_en.UserId := l_user_id;
                l_hl_scope_en.HierId := hierlev.hier_id;
                l_hl_scope_en.LevelId := hierlev.level_id;
                l_hl_scope_en.PersColId := hierlev.pers_col_id;
                l_dummy_num := insertHierlevelScopeRecord(l_hl_scope_en);
         end loop;

          -- DIMENSION ATTRIBUTES
      zpb_aw.execute('lmt '||l_aw||l_global_ecm.AttrDim||' to '||l_aw||
                     l_global_attr_ecm.DomainDimRel||' eq lmt ('||l_aw||
                     l_global_ecm.DimDim||' to '''||l_dim||''')');

      l_attrs := zpb_aw.interp ('shw CM.GETDIMVALUES('''||l_aw||
                                l_global_ecm.AttrDim||''' YES)');

      if (l_attrs <> 'NA') then
         ai := 1;
         loop -- Loop over Attributes of the Dimension
            aj := instr (l_attrs, ' ', ai);
            if (aj = 0) then
               l_attr := substr (l_attrs, ai);
             else
               l_attr := substr (l_attrs, ai, aj-ai);
               ai     := aj+1;
            end if;

            zpb_aw.execute ('lmt '||l_aw||l_global_ecm.AttrDim||' to '''|| l_attr||'''');
            -- explicitly exclude timespan and non displayed attrs
                        if (instr (l_attr, 'TIMESPAN') = 0 and (zpb_aw.interpbool('shw exists(''' || l_aw || l_global_attr_ecm.AttrDisplayVar || ''')')
                 and zpb_aw.interpbool('shw '||l_aw|| l_global_attr_ecm.AttrDisplayVar))) then

                        l_attr_perscwm :=  zpb_metadata_names.get_attribute_cwm2_name('PRS',l_dim,l_attr);

                                select attribute_id into l_attr_scope_en.AttributeId
                                from zpb_attributes
                                where dimension_id = l_dimension_id and
                                          pers_cwm_name = l_attr_perscwm;

                                l_attr_scope_en.UserId := l_user_id;
                                l_dummy_num := insertAttributeScopeRecord(l_attr_scope_en);

                        end if;

            exit when aj = 0;
         end loop; -- End Looping Over Attributes
      end if;

          -- handle special attributes
         for attr in c_special_attrs loop
                l_attr_scope_en.UserId := l_user_id;
                l_attr_scope_en.AttributeId := attr.attribute_id;
            l_dummy_num := insertAttributeScopeRecord(l_attr_scope_en);
         end loop;

         for attr in c_range_dim_attrs loop
                l_attr_scope_en.UserId := l_user_id;
                l_attr_scope_en.AttributeId := attr.attribute_id;
            l_dummy_num := insertAttributeScopeRecord(l_attr_scope_en);
         end loop;

        -- delete all scoping entries for this user that have not been updated during the above looping
        -- they must have been created previously and are no longer valid
        delete zpb_hier_scope
        where  user_id = l_user_id and
                           resp_id = nvl(to_number(sys_context('ZPB_CONTEXT', 'resp_id')), FND_GLOBAL.RESP_ID) and
                   last_update_date < l_start_time and
                   hierarchy_id in (select hierarchy_id
                                          from   zpb_hierarchies hier,
                                                 zpb_dimensions  dims
                                          where  hier.dimension_id = dims.dimension_id and
                                                 dims.bus_area_id = bus_area_id_num and
                                                                                                 dims.dimension_id = l_dimension_id);

        delete zpb_hier_level_scope
        where  user_id = l_user_id and
                           resp_id = nvl(to_number(sys_context('ZPB_CONTEXT', 'resp_id')), FND_GLOBAL.RESP_ID) and
                   last_update_date < l_start_time and
                   hier_id in (select hierarchy_id
                                          from   zpb_hierarchies hier,
                                                 zpb_dimensions  dims
                                          where  hier.dimension_id = dims.dimension_id and
                                                 dims.bus_area_id = bus_area_id_num and
                                                                                                 dims.dimension_id = l_dimension_id);

        delete zpb_attribute_scope
        where  user_id = l_user_id and
                           resp_id = nvl(to_number(sys_context('ZPB_CONTEXT', 'resp_id')), FND_GLOBAL.RESP_ID) and
                   last_update_date < l_start_time and
                   attribute_id in (select attribute_id
                                                    from        zpb_attributes attr,
                                                                zpb_dimensions dims
                                                        where   attr.dimension_id = dims.dimension_id and
                                                                dims.bus_area_id = bus_area_id_num and
                                                                                                                                dims.dimension_id = l_dimension_id);

      exit when j=0;
   end loop;

   zpb_aw.execute('pop oknullstatus');

 EXCEPTION
  WHEN OTHERS THEN
    zpb_log.write_event(G_PKG_NAME||'.'||l_api_name,to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));
  return;

end BUILD_PERSONAL_DIMS;

-------------------------------------------------------------------------------
--  cleanOutBusinessArea - Procedure that deletes all md records for a
--                         particular business area.  Done before a universe
--                                              refresh.
-------------------------------------------------------------------------------
procedure cleanBusArea(p_bus_area_id in number) is

                   CURSOR c_dimensions is
         select dimension_id
         from zpb_dimensions
         where bus_area_id = p_bus_area_id;

                   v_dim         c_dimensions%ROWTYPE;

                CURSOR c_tables is
                 select table_id
                 from zpb_tables
                 where bus_area_id = p_bus_area_id;

                v_table        c_tables%ROWTYPE;

                CURSOR c_cubes is
                 select cube_id
                 from zpb_cubes
                 where bus_area_id = p_bus_area_id;

                v_cube        c_cubes%ROWTYPE;

begin

        -- loop over dimensions
        for v_dim in c_dimensions loop

                -- delete dimensions_tl
                delete zpb_dimensions_tl
                where dimension_id = v_dim.dimension_id;

                -- delete attribute_scope
                delete zpb_attribute_scope
                where attribute_id in (select attribute_id
                                                                 from zpb_attributes
                                                                 where dimension_id = v_dim.dimension_id);

                -- delete attr_table_col
                delete zpb_attr_table_col
                where attribute_id in (select attribute_id
                                                                 from zpb_attributes
                                                                 where dimension_id = v_dim.dimension_id);

                -- delete attributes_tl
                delete zpb_attributes_tl
                where attribute_id in (select attribute_id
                                                                 from zpb_attributes
                                                                 where dimension_id = v_dim.dimension_id);

                -- Finally delete attributes
                delete zpb_attributes
                where dimension_id = v_dim.dimension_id;

                -- delete hierarchies_tl
                delete zpb_hierarchies_tl
                where hierarchy_id in (select hierarchy_id
                                                                from zpb_hierarchies
                                                                where dimension_id = v_dim.dimension_id);

                -- delete hier_level
                delete zpb_hier_level
                where hier_id in (select hierarchy_id
                                                                from zpb_hierarchies
                                                                where dimension_id = v_dim.dimension_id);

                -- delete hier_level_scope
                delete zpb_hier_level_scope
                where hier_id in (select hierarchy_id
                                                                from zpb_hierarchies
                                                                where dimension_id = v_dim.dimension_id);

                -- delete hier_scope
                delete zpb_hier_scope
                where hierarchy_id in (select hierarchy_id
                                                                from zpb_hierarchies
                                                                where dimension_id = v_dim.dimension_id);

                -- Finally delete hierarchies entry
                delete zpb_hierarchies
                where dimension_id = v_dim.dimension_id;

                -- delete levels_tl
                delete zpb_levels_tl
                where level_id in (select level_id
                                                        from zpb_levels
                                                        where dimension_id = v_dim.dimension_id);

                -- Finally delete levels
                delete zpb_levels
                where dimension_id = v_dim.dimension_id;

                -- Finally delete dimension
                delete zpb_dimensions
                where dimension_id = v_dim.dimension_id;
        end loop;

        for v_table in c_tables loop

                -- delete columns
                delete zpb_columns
                where table_id = v_table.table_id;

                -- delete tables
                delete zpb_tables
                where table_id = v_table.table_id;

        end loop;

        for v_cube in c_cubes loop

                -- delete cube and its child entries
                deleteCubeRecord(v_cube.cube_id);

        end loop;


end cleanBusArea;

end ZPB_METADATA_PKG;

/
