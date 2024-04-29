--------------------------------------------------------
--  DDL for Package Body ZPB_BUSAREA_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_BUSAREA_VAL" AS
/* $Header: ZPBVBAVB.pls 120.49 2007/12/04 14:37:23 mbhat noship $ */

G_PKG_NAME CONSTANT VARCHAR2(15) := 'zpb_busarea_val';
G_MAX_NAME_LENGTH CONSTANT NUMBER := 30; -- n/3 to allow for UTF 8
G_READ_RULE CONSTANT            VARCHAR2(9)  := 'READ_RULE';
G_WRITE_RULE CONSTANT           VARCHAR2(10) := 'WRITE_RULE';
G_OWNER_RULE CONSTANT           VARCHAR2(10) := 'OWNER_RULE';
G_LOCK_OUT CONSTANT             NUMBER       := 2;
G_BUS_AREA_PATH_PREFIX CONSTANT VARCHAR(23)  := 'oracle/apps/zpb/BusArea';
G_SECURITY_ADMIN_FOLDER CONSTANT VARCHAR(27)  := '/ZPBSystem/Private/Manager';

G_LINE_DIM_TABLE_NAME   VARCHAR2(60);
G_MEMBER_ID_COL         VARCHAR2(60);
G_MEMBER_NAME_COL       VARCHAR2(60);


TYPE epb_cur_type is REF CURSOR;

-----------------------------------------------------------------------------
/*

LOCK_OUT_USER

This procedure updates ZPB_ACCOUNT_STATES.READ_SCOPE
                                          WRITE_SCOPE
                                          OWNERSHIP
setting these columns to 2 (locked) as needed.

Also inserts the invalid querys name and path details into
the ZPB_VALIDATION_TEMP_DATA table for later retrieval in java layer.

--  p_baId           -- Business Area Id
--  p_user_id        -- User id pulled from query
--  p_queryName      -- The Invalid Query Object Name
--  p_queryPath      -- The Invalid Query object path
--  p_queryType      -- G_READ_RULE,G_WRITE_RULE,G_OWNER_RULE
--  p_queryErrorType -- Tells whether the query is to be fixed +
--                      marked as Invalid ("F") OR Just Refrshed ("R").
--                      "R" only if a dimension has been removed
--                   -- in which case fixing is not going to work.
--  p_init_fix       -- Flag to confirm whether MD fixing should be done or not
                     -- We do not fix for real-time validation from UI.
--  p_statusSqlId    -- Status sql id from query
*/
------------------------------------------------------------------------------
 PROCEDURE LOCK_OUT_USER(p_baId           IN NUMBER,
                         p_userid         IN FND_USER.USER_ID%type,
                         p_queryName      IN VARCHAR2,
                         p_queryPath      IN ZPB_STATUS_SQL.QUERY_PATH%type,
                         p_queryType      IN VARCHAR2,
                         p_queryErrorType IN VARCHAR2,
                         p_init_fix       IN VARCHAR2,
                         p_statusSqlId    IN ZPB_STATUS_SQL.STATUS_SQL_ID%type)
 IS

 BEGIN

  IF p_init_fix = 'Y'
  THEN
    IF p_queryType = G_READ_RULE
    THEN
      UPDATE ZPB_ACCOUNT_STATES
      SET READ_SCOPE = G_LOCK_OUT,
          LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
          LAST_UPDATE_DATE = SYSDATE,
          LAST_UPDATE_LOGIN = FND_GLOBAL.USER_ID
          WHERE USER_ID = p_userId AND
          BUSINESS_AREA_ID = p_baId;
    ELSIF p_queryType = G_WRITE_RULE
    THEN
       UPDATE ZPB_ACCOUNT_STATES
       SET WRITE_SCOPE = G_LOCK_OUT,
           LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
           LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATE_LOGIN = FND_GLOBAL.USER_ID
       WHERE USER_ID = p_userId AND
           BUSINESS_AREA_ID = p_baId;
    ELSIF p_queryType = G_OWNER_RULE
    THEN
       UPDATE ZPB_ACCOUNT_STATES
      SET OWNERSHIP = G_LOCK_OUT,
          LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
          LAST_UPDATE_DATE = SYSDATE,
          LAST_UPDATE_LOGIN = FND_GLOBAL.USER_ID
      WHERE USER_ID = p_userId AND
          BUSINESS_AREA_ID = p_baId;
    END IF;

    INSERT into ZPB_VALIDATION_TEMP_DATA
      (BUSINESS_AREA_ID,
       VALUE_TYPE,
       VALUE,
       STATUS_SQL_ID)
       VALUES (p_baId,
               p_queryErrorType,
               p_queryPath || fnd_global.newline()|| p_queryName,
               p_statusSqlId);

   COMMIT;

  END IF;
 END LOCK_OUT_USER;

-------------------------------------------------------------------------
-- This procedure attaches the given AWs
-------------------------------------------------------------------------


procedure ATTACH_AWS(p_codeAW          IN VARCHAR,
                p_sharedAW        IN VARCHAR)
   is
begin
   dbms_aw.execute ('aw attach '||p_codeAW||' ro');
   dbms_aw.execute ('aw attach '||p_sharedAW||' ro');
   dbms_aw.execute ('aw aliaslist '||p_sharedAW||' alias SHARED');
EXCEPTION
   WHEN OTHERS THEN
        null;
end ATTACH_AWS;

-------------------------------------------------------------------------
-- This procedure De-attaches the guven AWs
-------------------------------------------------------------------------

procedure DETACH_AWS(p_codeAW          IN VARCHAR,
                p_sharedAW        IN VARCHAR)
   is
begin
    if (zpb_aw.interpbool('shw aw(attached ''' || p_codeAW || ''')')) then
      zpb_aw.execute ('aw detach '||p_codeAW);
    end if;
    if (zpb_aw.interpbool('shw aw(attached ''' || p_sharedAW || ''')')) then
      zpb_aw.execute ('aw detach '||p_sharedAW);
    end if;
EXCEPTION
   WHEN OTHERS THEN
        null;
end DETACH_AWS;

-------------------------------------------------------------------------
-- Function which gets the Line member name given the member ID
-------------------------------------------------------------------------

 FUNCTION  GET_LINE_MEMBER_DESC(p_memberID           IN VARCHAR)
    RETURN VARCHAR IS
        l_num            NUMBER;
        l_command        VARCHAR2(300);
        l_memberVal      VARCHAR2(255);
 BEGIN

       l_command := 'SELECT '||G_MEMBER_NAME_COL||' FROM '
            ||G_LINE_DIM_TABLE_NAME||' WHERE '||G_MEMBER_ID_COL|| ' = ''' ||p_memberID||'''';

       EXECUTE IMMEDIATE l_command INTO l_memberVal;

       return l_memberVal;
 EXCEPTION
    WHEN OTHERS THEN
        return p_memberID;
 END GET_LINE_MEMBER_DESC;
------------------------------------------------------------------------------
/*

 This procedure updates the invalid Published BP definition's status_code as
    'INVALID_BP' and Inserts the invalid query's name and path details into
    the ZPB_VALIDATION_TEMP_DATA table for later retrieval in java layer.
--  p_queryName      -- The Invalid Query Object Name
--  p_queryPath      -- The Invalid Query object path
--  p_queryErrorType -- Tells whether the query is to be fixed +
--                      marked as Invalid ("F") OR Just Refrshed ("R")
--  p_acID           -- ANALYSIS_CYCLE_ID
--  p_init_fix       -- Flag to confirm whether MD fixing should be done
--                      fixed or not
*/
------------------------------------------------------------------------------
 PROCEDURE DISABLE_BP(p_baId IN NUMBER,
    p_queryName IN VARCHAR,
    p_queryPath  IN VARCHAR,
        p_queryErrorType IN VARCHAR,
        p_acID           IN zpb_analysis_cycles.analysis_cycle_id%TYPE := NULL,
    p_init_fix      IN VARCHAR2)
 IS
        l_num            NUMBER;

 BEGIN
  IF(p_init_fix = 'Y') THEN
        l_num := 0;
        INSERT into ZPB_VALIDATION_TEMP_DATA
          (BUSINESS_AREA_ID,
           VALUE_TYPE,
           VALUE,
           ANALYSIS_CYCLE_ID)
    VALUES (p_baId,
                p_queryErrorType ,
                p_queryPath || fnd_global.newline()|| p_queryName,
            p_acID);

        IF (p_AcID IS NOT NULL) THEN
            BEGIN
                SELECT nvl(published_ac_id, 0)
                INTO l_num
                FROM zpb_cycle_relationships
                WHERE published_ac_id = p_acID;
            EXCEPTION
                WHEN no_data_found THEN
                l_num := 0;
            END;
            -- Mark the BP as Invalid only if it is Published
                IF(l_num <> 0) THEN
                        UPDATE zpb_analysis_cycles
                            SET STATUS_CODE = 'INVALID_BP'
                        WHERE analysis_cycle_id = p_acID
                        AND business_area_id = p_baID;
                END IF;
            END IF;
    COMMIT;
  END IF;
 END DISABLE_BP;

-------------------------------------------------------------------------
-- REGISTER_ERROR - Code to distplay a error or warning message to the
--                  user
--
--
-------------------------------------------------------------------------
PROCEDURE REGISTER_ERROR (p_val_type     IN   VARCHAR2,
                          p_err_type     IN   VARCHAR2,
                          p_error_msg    IN   VARCHAR2,
                          p_token_name1  IN   VARCHAR2 := null,
                          p_token_val1   IN   VARCHAR2 := null,
                          p_translate1   IN   VARCHAR2 := 'N',
                          p_token_name2  IN   VARCHAR2 := null,
                          p_token_val2   IN   VARCHAR2 := null,
                          p_translate2   IN   VARCHAR2 := 'N',
                          p_token_name3  IN   VARCHAR2 := null,
                          p_token_val3   IN   VARCHAR2 := null,
                          p_translate3   IN   VARCHAR2 := 'N')
   is
      l_token1 VARCHAR2(255);
      l_token2 VARCHAR2(255);
      l_token3 VARCHAR2(255);
begin
   if (p_token_name1 is not null) then
      if (p_translate1 = 'Y') then
         FND_MESSAGE.SET_NAME('ZPB', p_token_val1);
         l_token1 := FND_MESSAGE.GET;
       else
         l_token1 := p_token_val1;
      end if;
   end if;
   if (p_token_name2 is not null) then
      if (p_translate2 = 'Y') then
         FND_MESSAGE.CLEAR;
         FND_MESSAGE.SET_NAME('ZPB', p_token_val2);
         l_token2 := FND_MESSAGE.GET;
       else
         l_token2 := p_token_val2;
      end if;
   end if;
   if (p_token_name3 is not null) then
      if (p_translate3 = 'Y') then
         FND_MESSAGE.CLEAR;
         FND_MESSAGE.SET_NAME('ZPB', p_token_val3);
         l_token3 := FND_MESSAGE.GET;
       else
         l_token3 := p_token_val3;
      end if;
   end if;

   FND_MESSAGE.CLEAR;
   FND_MESSAGE.SET_NAME('ZPB', p_error_msg);
   if (p_token_name1 is not null) then
      FND_MESSAGE.SET_TOKEN(p_token_name1, l_token1);
      if (p_token_name2 is not null) then
         FND_MESSAGE.SET_TOKEN(p_token_name2, l_token2);
         if (p_token_name3 is not null) then
            FND_MESSAGE.SET_TOKEN(p_token_name3, l_token3);
         end if;
      end if;
   end if;

   insert into ZPB_BUSAREA_VALIDATIONS
      (VALIDATION_TYPE,
       ERROR_TYPE,
       MESSAGE)
      values (p_val_type,
              p_err_type,
              FND_MESSAGE.GET);
   FND_MESSAGE.CLEAR;
end REGISTER_ERROR;

-------------------------------------------------------------------------
-- Validates the existence in the business area of all the dimensions
--  required based on the BA's datasets
--
-------------------------------------------------------------------------
PROCEDURE VALIDATE_DATASET_DIMS(p_version_id   IN      NUMBER)
   is
     l_spec_dim_list       VARCHAR2(512);
     l_dataset_id          ZPB_BUSAREA_DATASETS.DATASET_ID%type;
     l_currency            ZPB_BUSAREA_VERSIONS.CURRENCY_ENABLED%type;
     l_dimension_id        ZPB_BUSAREA_DIMENSIONS.DIMENSION_ID%type;
     l_cursor              epb_cur_type;
     l_datatable_dim_list  VARCHAR2(1000);
     l_dataset_dim_list    VARCHAR2(1000);
     l_missing_dim_list    VARCHAR2(1000);
     l_dim_list            VARCHAR2(1000);
     l_dimension_name      FEM_DIMENSIONS_VL.DIMENSION_NAME%type;
     l_command             VARCHAR2(3000);
     i                     NUMBER;
     j                     NUMBER;

     cursor c_dataset_tables is
        select distinct(TABLE_NAME)
           from FEM_DATA_LOCATIONS
           where dataset_code = l_dataset_id;

     cursor c_datasets is
         select A.DATASET_ID
            from ZPB_BUSAREA_DATASETS A
            where A.VERSION_ID = p_version_id
            and A.DATASET_ID in
            (select DATASET_CODE
             from FEM_DATASETS_B
             where ENABLED_FLAG = 'Y');

  begin
   --
   -- Check for datasets that have had one or more dimensions removed
   --
   -- is the BA currency enabled
   select CURRENCY_ENABLED
      into l_currency
      from ZPB_BUSAREA_VERSIONS
      where VERSION_ID = p_version_id;

   -- loop over each dataset
   l_dataset_dim_list := '';
   for each in c_datasets loop
      l_dataset_id := each.DATASET_ID;
      -- get the comma separated list of specifically defined
      --  dimension IDs for the given dataset
      begin
        select varchar_assign_value
           into l_spec_dim_list
           from fem_datasets_attr fdat, fem_dim_attributes_b fatt
           where fdat.attribute_id = fatt.attribute_id
           AND fatt.attribute_varchar_label = 'ZPB_DIMENSION_LIST'
           AND fdat.dataset_code = l_dataset_id;

        exception when NO_DATA_FOUND then
          l_spec_dim_list := '';
      end;

      -- find the data table that the dataset resides, if any
      -- create a list of dimension IDs that are a union of all the dimensions
      --  in all the dataset tables
      l_datatable_dim_list := '';
      for each in c_dataset_tables loop
        -- get the dimensions that are in the data table
        --  excluding the ledger dimension,
        --   the currency dimension,
        --   and any other dimensions in your list already
        l_command :=
         'select distinct(fem_xdims.dimension_id)
            from fem_tab_column_prop fem_tab, fem_xdim_dimensions fem_xdims, fem_dimensions_b fem_dims
            where fem_xdims.member_col = fem_tab.column_name
            AND (fem_tab.table_name = '''||each.TABLE_NAME||''')
            AND (fem_tab.column_property_code) = ''PROCESSING_KEY''
            AND fem_dims.DIMENSION_ID = fem_xdims.DIMENSION_ID
            AND fem_dims.DIMENSION_VARCHAR_LABEL <> ''LEDGER''
            AND fem_dims.DIMENSION_VARCHAR_LABEL <> ''DATASET''
            AND fem_dims.DIMENSION_VARCHAR_LABEL <> ''SOURCE_SYSTEM''
            AND fem_dims.DIMENSION_VARCHAR_LABEL <> ''CURRENCY_TYPE''
            AND fem_dims.DIMENSION_VARCHAR_LABEL <> ''NATURAL_ACCOUNT''
            AND fem_xdims.DIMENSION_TYPE_CODE <> ''LINE'' ';
        if (length(l_dataset_dim_list) > 0 ) then
            l_command := l_command ||
             ' AND fem_xdims.dimension_id not in ('||l_dataset_dim_list ||')';
        end if;
        -- remove the currency dimension if the BA is currency enabled
        if (l_currency = 'Y') then
            l_command := l_command ||
               ' AND fem_dims.DIMENSION_VARCHAR_LABEL <> ''CURRENCY'' ';
        end if;
        -- if l_spec_dim_list has nothing in it, ignore it
        -- if it has something in it, only get the intersection of dimensions
        --    with l_spec_dim and what is in the dataset table
        if (length(l_spec_dim_list) > 0 ) then
            l_command := l_command ||
             ' AND fem_xdims.dimension_id in ('||l_spec_dim_list ||')';
        end if;

        open l_cursor for l_command;
        l_datatable_dim_list := '';
        loop
           fetch l_cursor into l_dimension_id;

           exit when l_cursor%NOTFOUND;
           if (length(l_datatable_dim_list) > 0) then
             l_datatable_dim_list := l_datatable_dim_list || ',' || l_dimension_id;
           else
             l_datatable_dim_list := l_dimension_id;
           end if;
        end loop;

        if (length(l_datatable_dim_list) > 0) then
          if (length(l_dataset_dim_list) > 0) then
            l_dataset_dim_list := l_dataset_dim_list || ',' || l_datatable_dim_list;
          else
            l_dataset_dim_list := l_datatable_dim_list;
          end if;
        end if;
      end loop;

      -- assemble a select statement to figure out which dimensions are in the dataset tables
      --  but not in the business area
      l_command := '';
      if (length(l_dataset_dim_list) > 0 ) then
        l_command := 'select dimension_id from ( ';
        i := 1;
        loop
           j := instr (l_dataset_dim_list , ',', i);
           if (j = 0) then
              l_dimension_id := substr (l_dataset_dim_list, i);
           else
              l_dimension_id := substr (l_dataset_dim_list, i, j-i);
              i     := j+1;
           end if;
           l_command := l_command || ' select ' || l_dimension_id || ' dimension_id from dual ';
           exit when j=0;
           l_command := l_command || ' union ';
        end loop;
        l_command := l_command || ')';

        l_command := l_command ||
          ' where dimension_id not in (
              select dimension_id
                from ZPB_BUSAREA_DIMENSIONS
                where version_id = ' || p_version_id;
        -- only get those dimensions that haven't been added previously
        if (length(l_missing_dim_list) > 0) then
          if (substr(l_missing_dim_list, length(l_missing_dim_list)) = ',') then
            l_dim_list := substr(l_missing_dim_list, 1, length(l_missing_dim_list)-1);
           end if;
           l_command := l_command || 'AND dimension_id not in(' || l_dim_list || ')';
        end if;
        l_command := l_command || ')';

        open l_cursor for l_command;
        loop
           fetch l_cursor into l_dimension_id;
           exit when l_cursor%NOTFOUND;
           l_missing_dim_list := l_missing_dim_list || l_dimension_id || ',';
        end loop;
      end if;

   end loop;

   -- if there are missing dimensions, register an error
   if (length(l_missing_dim_list) > 0) then
      -- if the last character of list of dimensions is a comma, get rid of it
     if (substr(l_missing_dim_list, length(l_missing_dim_list)) = ',') then
       l_missing_dim_list := substr(l_missing_dim_list, 1, length(l_missing_dim_list)-1);
     end if;
     l_command := 'select DIMENSION_NAME
                    from FEM_DIMENSIONS_VL
                    where DIMENSION_ID in ('||l_missing_dim_list||')';
     l_missing_dim_list := '';
     open l_cursor for l_command;
     loop
       fetch l_cursor into l_dimension_name;
       exit when l_cursor%NOTFOUND;
       if (length(l_missing_dim_list) > 0) then
         l_missing_dim_list := l_missing_dim_list||', '|| l_dimension_name;
       else
         l_missing_dim_list := l_dimension_name;
       end if;
     end loop;

     -- Bug#4641094: Changed this to a WARNING (instead of an ERROR)
     REGISTER_ERROR('S', 'W', 'ZPB_BUSAREA_VAL_DSDIMS_MISSING',
                      'DIM_NAMES', l_missing_dim_list, 'N');
   end if;
end VALIDATE_DATASET_DIMS;


-------------------------------------------------------------------------
-- VAL_AGAINST_EPF - Validates the Business Area version against EPF, to
--                   ensure all metadata exists and is enabled in EPF
--
-- IN: p_version_id    - The Version ID to validate
--     p_init_msg_list - Whether to initialize the message list
--
-- OUT: x_return_status - The return status
--      x_msg_count     - The message count
--      x_msg_data      - The message data
-------------------------------------------------------------------------
PROCEDURE VAL_AGAINST_EPF (p_version_id    IN         NUMBER)
   is
      l_proc_name CONSTANT VARCHAR2(33) := G_PKG_NAME||'.val_against_epf';


      l_dim_table          FEM_XDIM_DIMENSIONS.MEMBER_B_TABLE_NAME%type;
      l_hier_table         FEM_XDIM_DIMENSIONS.HIERARCHY_TABLE_NAME%type;
      l_col                FEM_XDIM_DIMENSIONS.MEMBER_COL%type;
      l_vset_required      FEM_XDIM_DIMENSIONS.VALUE_SET_REQUIRED_FLAG%type;

      l_hierarchy          ZPB_BUSAREA_HIER_MEMBERS.HIERARCHY_ID%type;
      l_member_id          ZPB_BUSAREA_HIER_MEMBERS.MEMBER_ID%type;
      l_value_set_id       ZPB_BUSAREA_HIER_MEMBERS.VALUE_SET_ID%type;
      l_logical_dim_id     ZPB_BUSAREA_HIER_MEMBERS.LOGICAL_DIM_ID%type;

      l_command            VARCHAR2(3000);
      l_count              NUMBER;
      l_cursor             epb_cur_type;

      cursor c_hierarchies is
         select A.HIERARCHY_ID,
                A.LOGICAL_DIM_ID
            from ZPB_BUSAREA_HIERARCHIES A
            where A.VERSION_ID = p_version_id
            and A.HIERARCHY_ID not in
             (select HIERARCHY_OBJ_ID
              from FEM_HIERARCHIES
              where PERSONAL_FLAG = 'N');

      cursor c_def_hierarchies is
         select A.DIMENSION_ID,
                A.DEFAULT_HIERARCHY_ID,
                A.LOGICAL_DIM_ID
            from ZPB_BUSAREA_DIMENSIONS A
            where A.VERSION_ID = p_version_id
            and A.DEFAULT_HIERARCHY_ID not in
             (select HIERARCHY_OBJ_ID
              from FEM_HIERARCHIES
              where PERSONAL_FLAG = 'N');

      cursor c_hier_versions is
         select A.VERSION_ID,
                A.HIERARCHY_ID,
                A.HIER_VERSION_ID,
                A.LOGICAL_DIM_ID
            from ZPB_BUSAREA_HIER_VERSIONS A
            where A.VERSION_ID = p_version_id
            and A.HIER_VERSION_ID not in
             (select B.OBJECT_DEFINITION_ID
              from FEM_OBJECT_DEFINITION_B B
              where A.HIERARCHY_ID = B.OBJECT_ID);

      cursor c_levels is
         select A.LEVEL_ID,
                A.HIERARCHY_ID,
                A.LOGICAL_DIM_ID
            from ZPB_BUSAREA_LEVELS A
            where A.VERSION_ID = p_version_id
            and A.LEVEL_ID not in
            (select B.DIMENSION_GROUP_ID
             from FEM_DIMENSION_GRPS_B B,
                FEM_HIER_DIMENSION_GRPS C
             where B.DIMENSION_GROUP_ID = C.DIMENSION_GROUP_ID
             and C.HIERARCHY_OBJ_ID = A.HIERARCHY_ID
             and B.PERSONAL_FLAG = 'N');

      cursor c_attributes is
         select A.ATTRIBUTE_ID,
                A.LOGICAL_DIM_ID
            from ZPB_BUSAREA_ATTRIBUTES A
            where A.VERSION_ID = p_version_id
            and A.ATTRIBUTE_ID not in
            (select ATTRIBUTE_ID
             from FEM_DIM_ATTRIBUTES_B
             where PERSONAL_FLAG = 'N');

      cursor c_ledgers is
         select A.LEDGER_ID
            from ZPB_BUSAREA_LEDGERS A
            where A.VERSION_ID = p_version_id
            and A.LEDGER_ID not in
            (select LEDGER_ID
             from FEM_LEDGERS_B
             where ENABLED_FLAG = 'Y');

      cursor c_datasets is
         select A.DATASET_ID
            from ZPB_BUSAREA_DATASETS A
            where A.VERSION_ID = p_version_id
            and A.DATASET_ID not in
            (select DATASET_CODE
             from FEM_DATASETS_B
             where ENABLED_FLAG = 'Y');

      cursor c_dimensions is
         select A.DIMENSION_ID, B.HIER_EDITOR_MANAGED_FLAG,
                A.LOGICAL_DIM_ID
            from ZPB_BUSAREA_DIMENSIONS A, FEM_XDIM_DIMENSIONS B
            where A.VERSION_ID = p_version_id
            and A.DIMENSION_ID = B.DIMENSION_ID;

begin
   FND_MSG_PUB.INITIALIZE;

   ZPB_LOG.WRITE (l_proc_name||'.begin', 'Begin validation against EPF');

   --
   -- Check for removed hierarchies
   --
   for each in c_hierarchies loop
      REGISTER_ERROR('S', 'W', 'ZPB_BUSAREA_VAL_REMOVED',
                     'OBJ_TYPE', 'ZPB_HIERARCHY', 'Y');
      ZPB_BUSAREA_MAINT.REMOVE_HIERARCHY(p_version_id,
                                         each.LOGICAL_DIM_ID,
                                         each.HIERARCHY_ID);
   end loop;

   --
   -- Check for removed default hierarchies
   --
   for each in c_def_hierarchies loop
      REGISTER_ERROR('S', 'W', 'ZPB_BUSAREA_VAL_REMOVED',
                     'OBJ_TYPE', 'ZPB_DEFAULT_HIERARCHY', 'Y');
      update ZPB_BUSAREA_DIMENSIONS
         set DEFAULT_HIERARCHY_ID = null,
             LAST_UPDATE_DATE = sysdate,
             LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
             LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
         where VERSION_ID = p_version_id
         and LOGICAL_DIM_ID = each.LOGICAL_DIM_ID
         and DIMENSION_ID = each.DIMENSION_ID;
   end loop;

   --
   -- Check for removed hierarchy versions
   --
   for each in c_hier_versions loop
      REGISTER_ERROR('S', 'W', 'ZPB_BUSAREA_VAL_REMOVED',
                     'OBJ_TYPE', 'ZPB_HIERARCHY_VERSION', 'Y');
      ZPB_BUSAREA_MAINT.REMOVE_HIERARCHY_VERSION(p_version_id,
                                                 each.LOGICAL_DIM_ID,
                                                 each.HIERARCHY_ID,
                                                 each.HIER_VERSION_ID);
   end loop;

   --
   -- Check for removed levels within hierarchies
   --
   for each in c_levels loop
      REGISTER_ERROR('S', 'W', 'ZPB_BUSAREA_VAL_REMOVED',
                     'OBJ_TYPE', 'ZPB_LEVEL', 'Y');
      ZPB_BUSAREA_MAINT.REMOVE_LEVEL(p_version_id,
                                     each.LOGICAL_DIM_ID,
                                     each.HIERARCHY_ID,
                                     each.LEVEL_ID);
   end loop;

   --
   -- Check for removed attributes
   --
   for each in c_attributes loop
      REGISTER_ERROR('S', 'W', 'ZPB_BUSAREA_VAL_REMOVED',
                     'OBJ_TYPE', 'ZPB_ATTRIBUTE', 'Y');
      ZPB_BUSAREA_MAINT.REMOVE_ATTRIBUTE(p_version_id,
                                         each.LOGICAL_DIM_ID,
                                         each.ATTRIBUTE_ID);
   end loop;

   --
   -- Check for removed ledgers
   --
   for each in c_ledgers loop
      REGISTER_ERROR('S', 'W', 'ZPB_BUSAREA_VAL_REMOVED',
                     'OBJ_TYPE', 'ZPB_LEDGER', 'Y');
      delete from ZPB_BUSAREA_LEDGERS
         where VERSION_ID = p_version_id
         and LEDGER_ID = each.LEDGER_ID;
   end loop;

   --
   -- Check for removed datasets
   --
   for each in c_datasets loop
      REGISTER_ERROR('S', 'W', 'ZPB_BUSAREA_VAL_REMOVED',
                     'OBJ_TYPE', 'ZPB_DATASET', 'Y');
      delete from ZPB_BUSAREA_DATASETS
         where VERSION_ID = p_version_id
         and DATASET_ID = each.DATASET_ID;
   end loop;

   for each in c_dimensions loop
      select A.MEMBER_B_TABLE_NAME,
         A.HIERARCHY_TABLE_NAME,
         A.MEMBER_COL,
         A.VALUE_SET_REQUIRED_FLAG
        into l_dim_table, l_hier_table, l_col, l_vset_required
        from FEM_XDIM_DIMENSIONS A,
             ZPB_BUSAREA_DIMENSIONS B
        where B.DIMENSION_ID = each.DIMENSION_ID
        and B.VERSION_ID = p_version_id
        and B.LOGICAL_DIM_ID = each.LOGICAL_DIM_ID
        AND A.DIMENSION_ID   = B.DIMENSION_ID;

      --
      -- Check for removed top level members of hierarchies
      --
      if (l_hier_table is not null) then
         l_command :=
            'select A.HIERARCHY_ID, A.MEMBER_ID, A.VALUE_SET_ID,
                    A.LOGICAL_DIM_ID
            from ZPB_BUSAREA_HIER_MEMBERS A,
               FEM_HIERARCHIES B
            where A.HIERARCHY_ID = B.HIERARCHY_OBJ_ID
               and A.LOGICAL_DIM_ID = '||each.LOGICAL_DIM_ID||'
               and B.DIMENSION_ID = '||each.DIMENSION_ID||'
               and A.VERSION_ID = '||p_version_id||'
               and A.MEMBER_ID not in
            (select distinct C.CHILD_ID
             from '||l_hier_table||' C,
             FEM_OBJECT_DEFINITION_B D,
             '||l_dim_table||' E
             where C.HIERARCHY_OBJ_DEF_ID = D.OBJECT_DEFINITION_ID
             and D.OBJECT_ID = A.HIERARCHY_ID
             and D.OBJECT_DEFINITION_ID = nvl(A.HIER_VERSION_ID,
                                              D.OBJECT_DEFINITION_ID)
             and C.CHILD_ID = E.'||l_col||'
             and C.CHILD_ID = C.PARENT_ID
             and C.CHILD_DEPTH_NUM = 1';
          if (each.HIER_EDITOR_MANAGED_FLAG = 'Y') then
             l_command := l_command||'
             and E.ENABLED_FLAG = ''Y''
             and E.PERSONAL_FLAG = ''N''';
          end if;
          if (l_vset_required = 'Y') then
             l_command := l_command||
                ' and A.VALUE_SET_ID = C.CHILD_VALUE_SET_ID
                and A.VALUE_SET_ID = E.VALUE_SET_ID)';
           else
             l_command := l_command||')';
          end if;

          open l_cursor for l_command;
          loop
             fetch l_cursor into l_hierarchy, l_member_id, l_value_set_id,l_logical_dim_id;
             exit when l_cursor%NOTFOUND;

             REGISTER_ERROR('S', 'W', 'ZPB_BUSAREA_VAL_REMOVED',
                            'OBJ_TYPE', 'ZPB_TOP_LEVEL_MEMBER', 'Y');
             delete from ZPB_BUSAREA_HIER_MEMBERS
                where VERSION_ID = p_version_id
                and LOGICAL_DIM_ID = l_logical_dim_id
                and HIERARCHY_ID = l_hierarchy
                and MEMBER_ID = l_member_id
                and VALUE_SET_ID = l_value_set_id;
          end loop;
          close l_cursor;
      end if;
   end loop;

   ZPB_LOG.WRITE (l_proc_name||'.end', 'End validation against EPF');

end VAL_AGAINST_EPF;

-------------------------------------------------------------------------
-- VAL_DEFINITION - Validates the Business Area version against itself, to
--                  ensure there are no internal inconsistencies
--
-- IN: p_version_id    - The Version ID to validate
--     p_init_msg_list - Whether to initialize the message list
--
-- OUT: x_return_status - The return status
--      x_msg_count     - The message count
--      x_msg_data      - The message data
-------------------------------------------------------------------------
PROCEDURE VAL_DEFINITION (p_version_id    IN      NUMBER)
   is
      l_proc_name CONSTANT VARCHAR2(32) := G_PKG_NAME||'.val_definition';

      l_dim_table          FEM_XDIM_DIMENSIONS.MEMBER_B_TABLE_NAME%type;
      l_hier_table         FEM_XDIM_DIMENSIONS.HIERARCHY_TABLE_NAME%type;
      l_attr_table         FEM_XDIM_DIMENSIONS.ATTRIBUTE_TABLE_NAME%type;
      l_col                FEM_XDIM_DIMENSIONS.MEMBER_COL%type;
      l_vset_required      FEM_XDIM_DIMENSIONS.VALUE_SET_REQUIRED_FLAG%type;
      l_dim_type           FEM_XDIM_DIMENSIONS.DIMENSION_TYPE_CODE%type;
      l_curr_attr_id       FEM_DIM_ATTRIBUTES_B.ATTRIBUTE_ID%type;
      l_org_dim_id         FEM_DIM_ATTRIBUTES_B.DIMENSION_ID%type;

      l_hierarchy          ZPB_BUSAREA_HIER_MEMBERS.HIERARCHY_ID%type;
      l_value_set_id       ZPB_BUSAREA_HIER_MEMBERS.VALUE_SET_ID%type;
      l_logical_dim_id     ZPB_BUSAREA_HIER_MEMBERS.LOGICAL_DIM_ID%type;
      l_org_logical_dim_id ZPB_BUSAREA_HIER_MEMBERS.LOGICAL_DIM_ID%type;

      l_ba_id              ZPB_BUSAREA_VERSIONS.BUSINESS_AREA_ID%type;
      l_vers_type          ZPB_BUSAREA_VERSIONS.VERSION_TYPE%type;
      l_currency           ZPB_BUSAREA_VERSIONS.CURRENCY_ENABLED%type;
      l_intercompany       ZPB_BUSAREA_VERSIONS.INTERCOMPANY_ENABLED%type;

      l_vs_combo_id        FEM_GLOBAL_VS_COMBO_DEFS.GLOBAL_VS_COMBO_ID%type;

      l_owner_dim          ZPB_DIMENSIONS.IS_OWNER_DIM%type;
      l_def_hier           ZPB_DIMENSIONS.DEFAULT_HIER%type;

      l_dim_name           FEM_DIMENSIONS_VL.DIMENSION_NAME%type;
      l_attr_name          FEM_DIM_ATTRIBUTES_VL.ATTRIBUTE_NAME%type;

      l_hier_id            NUMBER;
      l_hier_vers_id       NUMBER;
      l_hier_name          VARCHAR2(150);
      l_no_hierarchies     VARCHAR2(1);
      l_curr_vers          VARCHAR2(1);

      l_command            VARCHAR2(2000);
      l_buffer1            VARCHAR2(1000);
      l_buffer2            VARCHAR2(1000);
      l_fdr_desc           VARCHAR2(150);
      l_count              NUMBER;
      l_fdr_id             NUMBER;
      l_cursor             epb_cur_type;
      l_cursor2            epb_cur_type;

      l_attr_monetary_col
                          FEM_DIM_ATTRIBUTES_B.ATTRIBUTE_VALUE_COLUMN_NAME%type;
      l_attr_ex_acc_col
                          FEM_DIM_ATTRIBUTES_B.ATTRIBUTE_VALUE_COLUMN_NAME%type;

      l_ext_acct_type     VARCHAR2(30);
      l_monetary_stat     VARCHAR2(30);
      l_token             VARCHAR2(4000) := null;
      l_sql_stmt          VARCHAR2(4000);
      l_member_id         VARCHAR2(34);
      l_mem_desc          VARCHAR2(255);


      cursor c_dimensions is
         select A.DIMENSION_ID,
            A.DEFAULT_HIERARCHY_ID,
            A.USE_MEMBER_CONDITIONS,
            A.EPB_LINE_DIMENSION,
            A.LOGICAL_DIM_ID,
            A.AW_DIM_NAME,
            A.AW_DIM_PREFIX,
            DECODE(nvl(FDR.FUNC_DIM_SET_NAME, '-99'), '-99',
                   B.DIMENSION_NAME,FDR.FUNC_DIM_SET_NAME) AS DIMENSION_NAME,
            X.MEMBER_COL
          from ZPB_BUSAREA_DIMENSIONS A,
               FEM_FUNC_DIM_SETS_VL FDR,
            FEM_DIMENSIONS_VL B,
            FEM_XDIM_DIMENSIONS X
          where A.VERSION_ID = p_version_id
            and FDR.FUNC_DIM_SET_ID (+) = A.FUNC_DIM_SET_ID
            and A.DIMENSION_ID = B.DIMENSION_ID
            AND X.DIMENSION_ID = A.DIMENSION_ID;

      cursor c_attributes(p_logical_dim_id number) is
         select A.ATTRIBUTE_ID, B.VERSION_ID, A.NAME
            from ZPB_BUSAREA_ATTRIBUTES_VL A,
              FEM_DIM_ATTR_VERSIONS_B B
            where A.LOGICAL_DIM_ID = p_logical_dim_id
            and A.VERSION_ID = p_version_id
            and A.ATTRIBUTE_ID = B.ATTRIBUTE_ID
            and B.DEFAULT_VERSION_FLAG = 'Y'
            and B.AW_SNAPSHOT_FLAG = 'N';


      cursor c_conditions_vset(p_logical_dim_id number) is
         select A.ATTRIBUTE_ID, A.VALUE, A.VALUE_SET_ID
            from ZPB_BUSAREA_CONDITIONS_V A
            where A.VERSION_ID = p_version_id
            and   A.LOGICAL_DIM_ID = p_logical_dim_id
         MINUS
         select A.ATTRIBUTE_ID, A.VALUE, A.VALUE_SET_ID
            from ZPB_BUSAREA_CONDITIONS_V A,
            FEM_VALUE_SETS_B C,
            FEM_GLOBAL_VS_COMBO_DEFS D
            where A.VERSION_ID = p_version_id
            and A.LOGICAL_DIM_ID = p_logical_dim_id
            and A.VALUE_SET_ID is not null
            and C.VALUE_SET_ID = A.VALUE_SET_ID
            and C.DIMENSION_ID = A.DIMENSION_ID
            and D.DIMENSION_ID = A.DIMENSION_ID
            and D.VALUE_SET_ID = C.VALUE_SET_ID
            and D.GLOBAL_VS_COMBO_ID = l_vs_combo_id;


      cursor c_levels is
        select name from ZPB_BUSAREA_LEVELS_VL
        where version_id = p_version_id
        order by logical_dim_id, hierarchy_id;

      cursor c_hiers is
        select hierarchy_id, name from ZPB_BUSAREA_HIERARCHIES_VL
        where version_id = p_version_id
        order by logical_dim_id;

begin
   FND_MSG_PUB.INITIALIZE;

   ZPB_LOG.WRITE (l_proc_name||'.begin', 'Begin BA '||p_version_id||
                  ' validation');

   select BUSINESS_AREA_ID, VERSION_TYPE, CURRENCY_ENABLED,
      INTERCOMPANY_ENABLED
      into l_ba_id, l_vers_type, l_currency, l_intercompany
      from ZPB_BUSAREA_VERSIONS
      where VERSION_ID = p_version_id;

   -------------------------------------------------------------------------
   -- Validate Level and Hieracrchy names:
   -------------------------------------------------------------------------

  -- Check for level name length
  for each_level in c_levels
  loop
    if length(each_level.name) > G_MAX_NAME_LENGTH then
      REGISTER_ERROR('S', 'W', 'ZPB_BUSAREA_VAL_LONG_NAME',
        'NAME', each_level.NAME, 'N',
        'OBJECTTYPE', 'ZPB_LEVEL', 'Y',
        'MAX_NAME_LENGTH', G_MAX_NAME_LENGTH, 'N');
    end if;
  end loop;
  -- end check for name length

  -- Check for hierarchy name length
  for each_hier in c_hiers
  loop
    if length(each_hier.name) > G_MAX_NAME_LENGTH then
      REGISTER_ERROR('S', 'W', 'ZPB_BUSAREA_VAL_LONG_NAME',
        'NAME', each_hier.NAME, 'N',
        'OBJECTTYPE', 'ZPB_HIERARCHY', 'Y',
        'MAX_NAME_LENGTH', to_char(G_MAX_NAME_LENGTH), 'N');
    end if;
  end loop;
  -- end check for hierarchy name length

  -- Check for hierarchies with no current version
  for each_hier in c_hiers
  loop
    select count(*)
      into l_count
      from FEM_OBJECT_DEFINITION_B
      where OBJECT_ID = each_hier.HIERARCHY_ID
        and effective_start_date <= sysdate
        and effective_end_date >= sysdate;
    if (l_count = 0) then
      REGISTER_ERROR('S', 'E', 'ZPB_BUSAREA_VAL_HIER_NOCURR',
                              'NAME', each_hier.NAME, 'N');
    end if;
  end loop;

  -- end check for hierarchies with no current version

   -------------------------------------------------------------------------
   -- Validate users:
   -------------------------------------------------------------------------
   select count(*)
     into l_count
     from ZPB_BUSAREA_USERS A,
      FND_USER_RESP_GROUPS B,
      FND_RESPONSIBILITY C,
      FND_USER D
     where A.BUSINESS_AREA_ID = l_ba_id
      and A.USER_ID = B.USER_ID
      and B.RESPONSIBILITY_APPLICATION_ID = 210
      and nvl(B.END_DATE, sysdate) >= sysdate
      and nvl(B.START_DATE, sysdate) <= sysdate
      and B.RESPONSIBILITY_ID = C.RESPONSIBILITY_ID
      and C.APPLICATION_ID = 210
      and C.RESPONSIBILITY_KEY = 'ZPB_MANAGER_RESP'
      and A.USER_ID = D.USER_ID
      and nvl(D.END_DATE, sysdate) >= sysdate
      and D.START_DATE <= sysdate;
   if (l_count = 0) then
      REGISTER_ERROR('S', 'W', 'ZPB_BUSAREA_VAL_NO_SEC_USER');
   end if;

   -------------------------------------------------------------------------
   -- Validate # of ledgers, dimensions, etc
   -------------------------------------------------------------------------
   select count(*)
      into l_count
      from ZPB_BUSAREA_DIMENSIONS A, FEM_XDIM_DIMENSIONS B
      where A.VERSION_ID = p_version_id
      and A.DIMENSION_ID = B.DIMENSION_ID
      and B.DIMENSION_TYPE_CODE = 'TIME';
   if (l_count = 0) then
      REGISTER_ERROR('S', 'E', 'ZPB_BUSAREA_VAL_MISSING',
                     'OBJ_TYPE', 'ZPB_TIME_DIMENSION', 'Y');
   end if;

   select count(*)
      into l_count
      from ZPB_BUSAREA_DIMENSIONS
      where VERSION_ID = p_version_id
      and EPB_LINE_DIMENSION = 'Y';
   if (l_count = 0) then
      REGISTER_ERROR('S', 'E', 'ZPB_BUSAREA_VAL_MISSING',
                     'OBJ_TYPE', 'ZPB_LINE_DIMENSION', 'Y');
   end if;

   if (l_currency = 'Y') then
      select count(*)
         into l_count
         from ZPB_BUSAREA_DIMENSIONS A,
         FEM_XDIM_DIMENSIONS B
         where A.VERSION_ID = p_version_id
         and A.DIMENSION_ID = B.DIMENSION_ID
         and B.MEMBER_B_TABLE_NAME = 'FEM_CURRENCIES_VL';
      if (l_count = 0) then
         REGISTER_ERROR('S', 'E', 'ZPB_BUSAREA_VAL_NO_CURR_DIM');
      end if;
   end if;

   select count(*)
      into l_count
      from ZPB_BUSAREA_LEDGERS
      where VERSION_ID = p_version_id;
   if (l_count = 0) then
      REGISTER_ERROR('S', 'E', 'ZPB_BUSAREA_VAL_MISSING',
                     'OBJ_TYPE', 'ZPB_LEDGER', 'Y');
      --
      -- Abort check of dims.  Need ledger to check dims
      --
      return;
   end if;

   -----------------------------------------------------------------------
   -- Validate that all dataset dimensions are included
   -----------------------------------------------------------------------
   VALIDATE_DATASET_DIMS(p_version_id);

   -----------------------------------------------------------------------
   -- Validate all ledgers in same valueset combo:
   --  NOTE: Different validation if the BA contains an FDR
   -----------------------------------------------------------------------
   -- check to see if the BA has an FDR
   select nvl(FUNC_DIM_SET_OBJ_DEF_ID, -99)
    into l_fdr_id
    from ZPB_BUSAREA_VERSIONS
    where VERSION_ID = p_version_id;

   if (l_fdr_id = -99) then
     select count(distinct (C.DIM_ATTRIBUTE_NUMERIC_MEMBER))
       into l_count
       from ZPB_BUSAREA_LEDGERS B,
       FEM_LEDGERS_ATTR C, FEM_DIM_ATTRIBUTES_B D,
       FEM_DIM_ATTR_VERSIONS_B E
       where D.ATTRIBUTE_VARCHAR_LABEL = 'GLOBAL_VS_COMBO'
       and D.ATTRIBUTE_ID = E.ATTRIBUTE_ID
       and E.DEFAULT_VERSION_FLAG = 'Y'
       and E.AW_SNAPSHOT_FLAG = 'N'
       and C.VERSION_ID = E.VERSION_ID
       and C.ATTRIBUTE_ID = D.ATTRIBUTE_ID
       and B.LEDGER_ID = C.LEDGER_ID
       and B.VERSION_ID = p_version_id;
   else
     select count(distinct (C.DIM_ATTRIBUTE_NUMERIC_MEMBER))
       into l_count
       from ZPB_BUSAREA_LEDGERS B,
            FEM_LEDGERS_ATTR C, FEM_DIM_ATTRIBUTES_B D,
            FEM_DIM_ATTR_VERSIONS_B E,
            fem_object_definition_b objdef,fem_object_catalog_b  obj
       where D.ATTRIBUTE_VARCHAR_LABEL = 'GLOBAL_VS_COMBO'
         and D.ATTRIBUTE_ID = E.ATTRIBUTE_ID
         and E.DEFAULT_VERSION_FLAG = 'Y'
         and E.AW_SNAPSHOT_FLAG = 'N'
         and C.VERSION_ID = E.VERSION_ID
         and C.ATTRIBUTE_ID = D.ATTRIBUTE_ID
         and B.LEDGER_ID = C.LEDGER_ID
         and B.VERSION_ID = p_version_id
         and objdef.object_definition_id=l_fdr_id
         and objdef.object_id=obj.object_id
         and C.DIM_ATTRIBUTE_NUMERIC_MEMBER<>obj.LOCAL_VS_COMBO_ID;
   end if;

   if (l_count > 1) then
      if (l_fdr_id = -99) then
        REGISTER_ERROR('S', 'E', 'ZPB_BUSAREA_VAL_LEDGERVS');
      else
        SELECT A.DISPLAY_NAME
          into l_fdr_desc
          FROM FEM_OBJECT_DEFINITION_VL A, FEM_FUNC_DIM_SETS_B B,
               ZPB_BUSAREA_VERSIONS C
          WHERE C.VERSION_ID = p_version_id
            and A.OBJECT_DEFINITION_ID = C.FUNC_DIM_SET_OBJ_DEF_ID;

         REGISTER_ERROR('S', 'E', 'ZPB_BA_INV_FDR_GSVC',
                      'ZPB_BUSAREA_FDR_NAME_TOKEN', l_fdr_desc, 'N');
      end if;
      --
      -- NEED TO ABORT REST OF CHECK
      --
      return;
   end if;

   --
   -- Check the currency-org attribute
   --
   if (l_currency = 'Y') then
      begin
         select count(*)
          into l_count
          from FEM_DIM_ATTRIBUTES_B A,
            ZPB_BUSAREA_DIMENSIONS B
          where A.ATTRIBUTE_VARCHAR_LABEL = 'ZPB_ORG_CURRENCY'
            and A.DIMENSION_ID = B.DIMENSION_ID
            and B.VERSION_ID = p_version_id;
          if (l_count > 1) then
             select count(distinct B.DIMENSION_ID)
               into l_count
               from FEM_DIM_ATTRIBUTES_B A,
                    ZPB_BUSAREA_DIMENSIONS B
               where A.ATTRIBUTE_VARCHAR_LABEL = 'ZPB_ORG_CURRENCY'
                 and A.DIMENSION_ID = B.DIMENSION_ID
                 and B.VERSION_ID = p_version_id;

             if (l_count > 1) then
                REGISTER_ERROR('S', 'E', 'ZPB_BUSAREA_VAL_INV_ORG_CURR');
              else
               begin
                 select A.ATTRIBUTE_ID, A.DIMENSION_ID, B.LOGICAL_DIM_ID
                   into l_curr_attr_id, l_org_dim_id, l_org_logical_dim_id
                   from FEM_DIM_ATTRIBUTES_B A,
                        ZPB_BUSAREA_DIMENSIONS B,
                        ZPB_BUSAREA_ATTRIBUTES C
                   where ATTRIBUTE_VARCHAR_LABEL = 'ZPB_ORG_CURRENCY'
                     and A.DIMENSION_ID = B.DIMENSION_ID
                     and B.LOGICAL_DIM_ID = C.LOGICAL_DIM_ID
                     and B.VERSION_ID = p_version_id
                     and C.VERSION_ID = B.VERSION_ID;
                 exception
                  when others then
                     REGISTER_ERROR('S', 'E', 'ZPB_BUSAREA_VAL_INV_ORG_CURR');
               end;
             end if;
          else
           begin
             select A.ATTRIBUTE_ID, A.DIMENSION_ID, B.LOGICAL_DIM_ID
                 into l_curr_attr_id, l_org_dim_id, l_org_logical_dim_id
                 from FEM_DIM_ATTRIBUTES_B A,
                      ZPB_BUSAREA_DIMENSIONS B
                 where ATTRIBUTE_VARCHAR_LABEL = 'ZPB_ORG_CURRENCY'
                   and A.DIMENSION_ID = B.DIMENSION_ID
                   and B.VERSION_ID = p_version_id;
             exception
              when others then
                REGISTER_ERROR('S', 'E', 'ZPB_BUSAREA_VAL_INV_ORG_CURR');
            end;
         end if;
         exception
            when no_data_found then
               REGISTER_ERROR('S', 'E', 'ZPB_BUSAREA_VAL_NO_CURR_ATTR');
      end;
   end if;

   if (l_intercompany = 'Y') then
     select count(*)
        into l_count
        from ZPB_BUSAREA_DIMENSIONS A,
        FEM_TAB_COLUMNS_B B
        where A.VERSION_ID = p_version_id
        and A.DIMENSION_ID = B.DIMENSION_ID
        and B.COLUMN_NAME = 'INTERCOMPANY_ID'
        and B.TABLE_NAME = 'FEM_BALANCES';
     if (l_count <> 1) then
        REGISTER_ERROR('S', 'E', 'ZPB_BUSAREA_VAL_INV_INTERCOMP');
     end if;
   end if;

   select distinct (C.DIM_ATTRIBUTE_NUMERIC_MEMBER)
      into l_vs_combo_id
      from ZPB_BUSAREA_LEDGERS B,
      FEM_LEDGERS_ATTR C, FEM_DIM_ATTRIBUTES_B D,
      FEM_DIM_ATTR_VERSIONS_B E
      where D.ATTRIBUTE_VARCHAR_LABEL = 'GLOBAL_VS_COMBO'
      and D.ATTRIBUTE_ID = E.ATTRIBUTE_ID
      and E.DEFAULT_VERSION_FLAG = 'Y'
      and E.AW_SNAPSHOT_FLAG = 'N'
      and C.VERSION_ID = E.VERSION_ID
      and C.ATTRIBUTE_ID = D.ATTRIBUTE_ID
      and B.LEDGER_ID = C.LEDGER_ID
      and B.VERSION_ID = p_version_id;

   --
   -- Check to ensure line type attribute exists on the line dimension
   --
   select count(*)
      into l_count
     from ZPB_BUSAREA_DIMENSIONS A,
      FEM_DIM_ATTRIBUTES_B B
     where A.DIMENSION_ID = B.DIMENSION_ID
      and B.ATTRIBUTE_VARCHAR_LABEL = 'EXTENDED_ACCOUNT_TYPE'
      and A.EPB_LINE_DIMENSION = 'Y'
      and A.VERSION_ID = p_version_id;
   if (l_count = 0) then
      REGISTER_ERROR('S', 'E', 'ZPB_BUSAREA_VAL_EXT_ACT_TYPE');
   end if;


   ZPB_FEM_UTILS_PKG.INIT_HIER_MEMBER_CACHE(l_ba_id, l_vers_type);

   for each in c_dimensions loop
      -- Check for dimension name length
      if length(each.dimension_name) > G_MAX_NAME_LENGTH then
        REGISTER_ERROR('S', 'W', 'ZPB_BUSAREA_VAL_LONG_NAME',
                              'NAME', each.DIMENSION_NAME, 'N',
                              'OBJECTTYPE', 'ZPB_DIMENSION', 'Y',
                              'MAX_NAME_LENGTH', G_MAX_NAME_LENGTH, 'N');
      end if;
      -- end check for dimension name length
      ---------------------------------------------------------------------
      -- See if there are any members in the dimension
      ---------------------------------------------------------------------
      l_command := 'select count(*)
         from table(ZPB_FEM_UTILS_PKG.GET_LIST_DIM_MEMBERS
           ('||each.DIMENSION_ID||', '||each.LOGICAL_DIM_ID||','||l_ba_id||', '''||l_vers_type||'''))';

      open l_cursor for l_command;
      fetch l_cursor into l_count;
      close l_cursor;

      if (l_count = 0) then
         REGISTER_ERROR('S', 'E', 'ZPB_BUSAREA_VAL_NOMEMBERS',
                        'NAME', each.DIMENSION_NAME, 'N',
                        'OBJECTTYPE', 'ZPB_DIMENSION', 'Y');
      end if;

      select A.MEMBER_B_TABLE_NAME,
         A.HIERARCHY_TABLE_NAME,
         A.ATTRIBUTE_TABLE_NAME,
         A.MEMBER_COL,
         A.VALUE_SET_REQUIRED_FLAG,
         A.DIMENSION_TYPE_CODE
        into l_dim_table, l_hier_table, l_attr_table,
         l_col, l_vset_required, l_dim_type
        from FEM_XDIM_DIMENSIONS A,
             ZPB_BUSAREA_DIMENSIONS B
        where B.DIMENSION_ID = each.DIMENSION_ID
        AND B.LOGICAL_DIM_ID = each.LOGICAL_DIM_ID
        AND B.VERSION_ID     = p_version_id
        AND A.DIMENSION_ID = B.DIMENSION_ID;

      ---------------------------------------------------------------------
      -- Validate that all conditions have the right value set ID
      ---------------------------------------------------------------------
      --if (each.USE_MEMBER_CONDITIONS = 'Y') then
      --   for each_cond_vset in c_conditions_vset(each.LOGICAL_DIM_ID) loop
      --      null;
      --   end loop;
      --end if;

      select count(*), decode(count(*), 0, 'Y', 'N')
         into l_count, l_no_hierarchies
         from ZPB_BUSAREA_HIERARCHIES_VL
         where DIMENSION_ID = each.DIMENSION_ID
         and LOGICAL_DIM_ID = each.LOGICAL_DIM_ID
         and VERSION_ID = p_version_id;


      if (l_count = 0) then
         --
         -- Test to see if any members of attribute exists in B table
         -- can maybe use same command as would be used in SQ refresh code
         --
         null;

         ---------------------------------------------------------------------
         -- Verify that the current dimension without hierarchies
         --  is not an ownership dim
         ---------------------------------------------------------------------
        begin
            select IS_OWNER_DIM
               into l_owner_dim
               from ZPB_DIMENSIONS
               where BUS_AREA_ID = l_ba_id
               and EPB_ID = each.AW_DIM_PREFIX;
            if (l_owner_dim = 'YES') then
               REGISTER_ERROR('S', 'E', 'ZPB_BUSAREA_VAL_OWNER_NO_HIER',
                              'NAME', each.DIMENSION_NAME, 'N');
            end if;
         exception
            when no_data_found then
               null;
         end;

         ---------------------------------------------------------------------
         -- Time dimension must include a hierarchy
         ---------------------------------------------------------------------
         if (l_dim_type = 'TIME') then
            REGISTER_ERROR('S', 'E', 'ZPB_BUSAREA_VAL_TIME_HIER');
         end if;

         ---------------------------------------------------------------------
         -- Check to see if all attributes added have members associated
         ---------------------------------------------------------------------
         for each_attr in c_attributes(each.LOGICAL_DIM_ID) loop

            -- Check for attribute name length
            if length(each.dimension_name) > G_MAX_NAME_LENGTH then
               REGISTER_ERROR('S', 'W', 'ZPB_BUSAREA_VAL_LONG_NAME',
                              'NAME', each.DIMENSION_NAME, 'N',
                              'OBJECTTYPE', 'ZPB_ATTRIBUTE', 'Y',
                              'MAX_NAME_LENGTH', G_MAX_NAME_LENGTH, 'N');
            end if;
            -- end check for attribute name length

            l_command := 'select count(*)
               from table(ZPB_FEM_UTILS_PKG.GET_LIST_DIM_MEMBERS
                   ('||each.DIMENSION_ID||','||each.LOGICAL_DIM_ID||', '||l_ba_id||', '''||l_vers_type||
                           ''')) A, '||l_attr_table||' B ';
            if (l_vset_required = 'Y') then
               l_command := l_command||'
                    where A.MEMBER_ID = to_char(B.'||l_col||
                     ') and A.VALUE_SET_ID = B.VALUE_SET_ID';
             else
               l_command := l_command||'
                  where A.MEMBER_ID = to_char(B.'||l_col||')';
            end if;
            l_command := l_command||'
               and B.ATTRIBUTE_ID = '||each_attr.ATTRIBUTE_ID||'
               and B.VERSION_ID = '||each_attr.VERSION_ID||'
               and B.AW_SNAPSHOT_FLAG = ''N''';

            open l_cursor for l_command;
            fetch l_cursor into l_count;
            close l_cursor;

            if (l_count = 0) then
               REGISTER_ERROR('S', 'W', 'ZPB_BUSAREA_VAL_NOATTRASSOC',
                              'NAME', each_attr.NAME, 'N',
                              'DIMNAME', each.DIMENSION_NAME, 'N');
            end if;
         end loop;

       else
         ---------------------------------------------------------------------
         -- Check if default hier set
         ---------------------------------------------------------------------
         if (each.DEFAULT_HIERARCHY_ID is null) then
            REGISTER_ERROR('S', 'E', 'ZPB_BUSAREA_VAL_DEFINE',
                           'OBJ_TYPE', 'ZPB_DEFAULT_HIERARCHY', 'Y',
                           'DIM', each.DIMENSION_NAME, 'N');
          else
            ------------------------------------------------------------------
            -- Check if default hierarchy in the BA
            ------------------------------------------------------------------
            select count(*)
               into l_count
               from ZPB_BUSAREA_HIERARCHIES
               where VERSION_ID = p_version_id
               and LOGICAL_DIM_ID = each.LOGICAL_DIM_ID
               and HIERARCHY_ID = each.DEFAULT_HIERARCHY_ID;
            if (l_count = 0) then
               REGISTER_ERROR('S', 'E', 'ZPB_BUSAREA_VAL_BAD_DEFHIER',
                              'DIM', each.DIMENSION_NAME, 'N');
            end if;
         end if;
         -------------------------------------------------------------------
         -- Check if any hierarchies have no members:
         -------------------------------------------------------------------
         l_command := 'select distinct HIERARCHY_ID, VERSION_ID, LOGICAL_DIM_ID
            from table(ZPB_FEM_UTILS_PKG.GET_HIERARCHY_MEMBERS
                       ('||each.LOGICAL_DIM_ID||', '||l_ba_id||', '''||
                        l_vers_type||'''))';

         l_buffer1 := null;
         l_buffer2 := null;
         open l_cursor for l_command;
         loop
            fetch l_cursor into l_hier_id, l_hier_vers_id, l_logical_dim_id;
            exit when l_cursor%NOTFOUND;

            if (l_hier_vers_id is not null and l_hier_vers_id <> '') then
               if (l_buffer1 is not null) then
                  l_buffer1 := l_buffer1||', '||l_hier_vers_id;
                else
                  l_buffer1 := l_hier_vers_id;
               end if;
             else
               if (l_buffer2 is not null) then
                  l_buffer2 := l_buffer2||', '||l_hier_id;
                else
                  l_buffer2 := l_hier_id;
               end if;
            end if;
         end loop;
         close l_cursor;

         l_command := 'select A.HIERARCHY_ID, A.VERSION_ID, A.CURRENT_VERSION
            from table(ZPB_FEM_UTILS_PKG.GET_BUSAREA_HIERARCHIES
                          ('||l_ba_id||','''||l_vers_type||''')) A,
            ZPB_BUSAREA_HIERARCHIES_VL B
            where A.HIERARCHY_ID = B.HIERARCHY_ID
            and A.LOGICAL_DIM_ID = B.LOGICAL_DIM_ID
            and B.VERSION_ID = '||p_version_id||'
            and B.LOGICAL_DIM_ID = '||each.LOGICAL_DIM_ID||'
            and B.DIMENSION_ID = '||each.DIMENSION_ID;
         if (l_buffer2 is not null) then
            l_command := l_command||' and ';
            if (l_buffer1 is not null) then
               l_command := l_command||'((A.VERSION_ID not in ('||l_buffer1||
                  ') and A.CURRENT_VERSION = ''N'') OR ';
            end if;
            l_command := l_command||'(A.HIERARCHY_ID not in ('||l_buffer2||
               ') and A.CURRENT_VERSION = ''Y'')';
            if (l_buffer1 is not null) then
               l_command := l_command||')';
            end if;
         end if;
         open l_cursor for l_command;
         loop
            fetch l_cursor into l_hier_id, l_hier_vers_id, l_curr_vers;
            exit when l_cursor%NOTFOUND;

            if (l_curr_vers = 'Y') then
               select OBJECT_NAME
                  into l_hier_name
                  from FEM_OBJECT_CATALOG_VL
                  where OBJECT_ID = l_hier_id;
             else
               select DISPLAY_NAME
                  into l_hier_name
                  from FEM_OBJECT_DEFINITION_VL
                  where OBJECT_DEFINITION_ID = l_hier_vers_id;
            end if;

            if (l_hier_id = each.DEFAULT_HIERARCHY_ID and
                l_curr_vers = 'Y') then
               REGISTER_ERROR('S', 'E', 'ZPB_BUSAREA_VAL_NOMEMBERS',
                              'NAME', l_hier_name, 'N',
                              'OBJECTTYPE', 'ZPB_DEFAULT_HIERARCHY', 'Y');
             else
               REGISTER_ERROR('S', 'W', 'ZPB_BUSAREA_VAL_NOMEMBERS',
                              'NAME', l_hier_name, 'N',
                              'OBJECTTYPE', 'ZPB_HIERARCHY', 'Y');
            end if;
         end loop;
         close l_cursor;

         ---------------------------------------------------------------------
         -- Check for bad time hierarchies
         ---------------------------------------------------------------------
         if (l_dim_type = 'TIME') then
            l_command :=
             'select distinct Y.HIERARCHY_ID, Y.VERSION_ID from
              FEM_HIER_DIMENSION_GRPS X,
              (select distinct A.HIERARCHY_ID, A.VERSION_ID,
                B.RELATIVE_DIMENSION_GROUP_SEQ PARENT_SEQ,
                C.RELATIVE_DIMENSION_GROUP_SEQ CHILD_SEQ
               from (table(ZPB_FEM_UTILS_PKG.GET_HIERARCHY_MEMBERS
                 ('||each.LOGICAL_DIM_ID||', '||l_ba_id||', '''||
                     l_vers_type||'''))) A,
                  FEM_HIER_DIMENSION_GRPS B, FEM_HIER_DIMENSION_GRPS C,
                  '||l_dim_table||' D, '||l_dim_table||' E
               where A.PARENT_ID = D.'||l_col||'
                  and D.DIMENSION_GROUP_ID = B.DIMENSION_GROUP_ID
                  and B.HIERARCHY_OBJ_ID = A.HIERARCHY_ID
                  and A.CHILD_ID = E.'||l_col||'
                  and E.DIMENSION_GROUP_ID = C.DIMENSION_GROUP_ID
                  and C.HIERARCHY_OBJ_ID = A.HIERARCHY_ID) Y
              where X.HIERARCHY_OBJ_ID = Y.HIERARCHY_ID
                and X.RELATIVE_DIMENSION_GROUP_SEQ > Y.PARENT_SEQ
                and X.RELATIVE_DIMENSION_GROUP_SEQ < Y.CHILD_SEQ';

            open l_cursor for l_command;
            loop
               fetch l_cursor into l_hier_id, l_hier_vers_id;
               exit when l_cursor%NOTFOUND;

               if (l_hier_vers_id is null) then
                  select OBJECT_NAME
                     into l_hier_name
                     from FEM_OBJECT_CATALOG_VL
                     where OBJECT_ID = l_hier_id;
               else
                  select DISPLAY_NAME
                     into l_hier_name
                     from FEM_OBJECT_DEFINITION_VL
                     where OBJECT_DEFINITION_ID = l_hier_vers_id;
               end if;

               REGISTER_ERROR('S', 'E', 'ZPB_BUSAREA_VAL_SKIP_LVL_TIME',
                              'HIER_NAME', l_hier_name, 'N');
            end loop;
         end if;
         ---------------------------------------------------------------------
         -- Check if any levels have no members
         ---------------------------------------------------------------------
         -- TODO:
         --

         ---------------------------------------------------------------------
         -- Check to see if all attributes added have members associated
         ---------------------------------------------------------------------
         for each_attr in c_attributes(each.DIMENSION_ID) loop

            -- Check for attribute name length
            if length(each_attr.name) > G_MAX_NAME_LENGTH then
              REGISTER_ERROR('S', 'W', 'ZPB_BUSAREA_VAL_LONG_NAME',
                              'NAME', each_attr.NAME, 'N',
                              'OBJECTTYPE', 'ZPB_ATTRIBUTE', 'Y',
                              'MAX_NAME_LENGTH', G_MAX_NAME_LENGTH, 'N');
            end if;
            -- end check for atribute name length

            l_command := 'select count(*)
               from table(ZPB_FEM_UTILS_PKG.GET_HIERARCHY_MEMBERS
                   ('||each.LOGICAL_DIM_ID||', '||l_ba_id||', '''||l_vers_type||
                           ''')) A, '||l_attr_table||' B ';
            if (l_vset_required = 'Y') then
               l_command := l_command||'
                  where substr(A.CHILD_ID, instr(A.CHILD_ID, ''_'')+1) = B.'||
                    l_col||' and substr(A.CHILD_ID, 1, '||
                     'instr(A.CHILD_ID, ''_'')-1) = B.VALUE_SET_ID';
             else
               l_command := l_command||'
                  where A.CHILD_ID = B.'||l_col;
            end if;
            l_command := l_command||'
               and B.ATTRIBUTE_ID = '||each_attr.ATTRIBUTE_ID||'
               and B.VERSION_ID = '||each_attr.VERSION_ID||'
               and B.AW_SNAPSHOT_FLAG = ''N''';

            open l_cursor for l_command;
            fetch l_cursor into l_count;
            close l_cursor;

            if (l_count = 0) then
               REGISTER_ERROR('S', 'W', 'ZPB_BUSAREA_VAL_NOATTRASSOC',
                              'NAME', each_attr.NAME, 'N',
                              'DIMNAME', each.DIMENSION_NAME, 'N');
            end if;
         end loop;

         -------------------------------------------------------------------
         -- Check to see if changing def hier on ownership dim
         -------------------------------------------------------------------
         begin
            select DEFAULT_HIER, IS_OWNER_DIM
               into l_def_hier, l_owner_dim
               from ZPB_DIMENSIONS
               where BUS_AREA_ID = l_ba_id
               and EPB_ID = each.AW_DIM_PREFIX;

            if (l_owner_dim = 'YES' and
                l_def_hier <> to_char(each.DEFAULT_HIERARCHY_ID)) then
               REGISTER_ERROR('S', 'W', 'ZPB_BUSAREA_VAL_OWNER_DEF_HIER',
                              'NAME', each.DIMENSION_NAME, 'N');
            end if;
         exception
            when no_data_found then
               null;
         end;

         -------------------------------------------------------------------
         -- Check to see no missing org-currency attribute relations
         -------------------------------------------------------------------
         if ((each.DIMENSION_ID = l_org_dim_id) AND
             (each.LOGICAL_DIM_ID = l_org_logical_dim_id)) then
            l_command :=
               'select count(*) '||
               'from table(ZPB_FEM_UTILS_PKG.GET_HIERARCHY_MEMBERS('||
               each.LOGICAL_DIM_ID||', '||l_ba_id||', '''||l_vers_type||
               ''')) A, '||l_attr_table||' B, FEM_DIM_ATTR_VERSIONS_B C';
            if (l_vset_required = 'Y') then
               l_command := l_command||'
                  where substr(A.CHILD_ID, instr(A.CHILD_ID, ''_'')+1) = B.'||
                  l_col||' and substr(A.CHILD_ID, 1, '||
                  'instr(A.CHILD_ID, ''_'')-1) = B.VALUE_SET_ID';
             else
               l_command := l_command||'where A.CHILD_ID = B.'||l_col;
            end if;
            l_command := l_command||'
               and B.ATTRIBUTE_ID = '||l_curr_attr_id||'
               and B.VERSION_ID = C.VERSION_ID
               and C.ATTRIBUTE_ID = '||l_curr_attr_id||'
               and C.DEFAULT_VERSION_FLAG = ''Y''
               and C.AW_SNAPSHOT_FLAG = ''N''
               and B.AW_SNAPSHOT_FLAG = ''N''
               and B.DIM_ATTRIBUTE_VARCHAR_MEMBER is null';

            open l_cursor for l_command;
            fetch l_cursor into l_count;
            close l_cursor;
            if (l_count > 0) then
               REGISTER_ERROR('S', 'E', 'ZPB_BUSAREA_VAL_CURR_ATTR_MISS');
            end if;
          end if;
      end if;

      --
      --  Verify no org is missing the currency attribute
      --   if the BA is currency enabled
      --
      if ((l_currency = 'Y') and
          (each.LOGICAL_DIM_ID = l_org_logical_dim_id) and
          (each.DIMENSION_ID = l_org_dim_id)) then

        l_command := 'select decode(count(*), 0, 0, 1)';
        if (l_no_hierarchies = 'Y') then
          if (l_vset_required = 'Y') then
            l_command := l_command || ' from (SELECT DISTINCT(to_number(substr(A.MEMBER_ID, instr(A.MEMBER_ID, ''_'')+1))) from table(ZPB_FEM_UTILS_PKG.GET_LIST_DIM_MEMBERS(';
          else
            l_command := l_command || ' from (SELECT DISTINCT(to_number(A.MEMBER_ID)) from table(ZPB_FEM_UTILS_PKG.GET_LIST_DIM_MEMBERS(';
          end if;
          l_command := l_command ||  ' '||l_org_dim_id||', '||l_org_logical_dim_id||', '||l_ba_id||', ''P'')) A,';
        else
          if (l_vset_required = 'Y') then
            l_command := l_command || ' from (SELECT DISTINCT(to_number(substr(A.CHILD_ID, instr(A.CHILD_ID, ''_'')+1))) ';
          else
            l_command := l_command || ' from (SELECT DISTINCT(to_number(A.CHILD_ID))';
          end if;
          l_command := l_command || ' from table(ZPB_FEM_UTILS_PKG.GET_HIERARCHY_MEMBERS(';
          l_command := l_command ||  ' '||l_org_logical_dim_id||', '||l_ba_id||', ''P'')) A,';
        end if;
        l_command := l_command ||
          ' FEM_DIM_ATTR_GRPS B,' ||
          ' '||l_dim_table||' C ';
        if (l_no_hierarchies = 'N') then
          l_command := l_command || ', FEM_HIERARCHIES D';
        end if;
        l_command := l_command || ' where ';
        if (l_no_hierarchies = 'N')
          then
            if (l_vset_required = 'Y') then
              l_command := l_command ||
               'to_number(substr(A.CHILD_ID, instr(A.CHILD_ID, ''_'')+1))  = C.'||l_col||' AND ';
            else
              l_command := l_command || 'to_number(A.CHILD_ID)  = C.'||l_col||' AND ';
          end if;
        end if;
        l_command := l_command ||
          ' B.DIMENSION_GROUP_ID = C.DIMENSION_GROUP_ID ';
        if (l_no_hierarchies = 'N') then
          l_command := l_command ||
            ' AND D.HIERARCHY_OBJ_ID = A.HIERARCHY_ID ' ||
            ' AND D.GROUP_SEQUENCE_ENFORCED_CODE <> ''NO_GROUPS''';
        end if;
        l_command := l_command ||
          ' MINUS select B.'||l_col||
          ' from FEM_DIM_ATTRIBUTES_B A,' ||
          ' '||l_dim_table||' B,' ||
          ' '||l_attr_table||' C,' ||
          ' FEM_DIM_ATTR_GRPS D,' ||
          ' FEM_DIM_ATTR_VERSIONS_B E,';
        if (l_no_hierarchies = 'Y') then
          l_command := l_command ||
           ' table(ZPB_FEM_UTILS_PKG.GET_LIST_DIM_MEMBERS(';
          l_command := l_command ||  ' '||l_org_dim_id||', '||l_org_logical_dim_id||', '||l_ba_id||', ''P'')) F';
        else
          l_command := l_command ||
           ' table(ZPB_FEM_UTILS_PKG.GET_HIERARCHY_MEMBERS(';
          l_command := l_command ||  ' '||l_org_logical_dim_id||', '||l_ba_id||', ''P'')) F';
          l_command := l_command || ', FEM_HIERARCHIES G ';
        end if;

        l_command := l_command ||
           '  where A.ATTRIBUTE_VARCHAR_LABEL = ''ZPB_ORG_CURRENCY'' ' ||
           '     AND C.ATTRIBUTE_ID = A.ATTRIBUTE_ID' ||
           '     AND B.'||l_col||' = C.'||l_col;
        if (l_no_hierarchies = 'N')
          then
            if (l_vset_required = 'Y') then
              l_command := l_command ||
               ' AND B.'||l_col||' = to_number(substr(F.CHILD_ID, instr(F.CHILD_ID, ''_'')+1)) ';
            else
              l_command := l_command ||
               ' AND B.'||l_col||' = to_number(F.CHILD_ID) ';
          end if;
        end if;
        l_command := l_command ||
           ' AND A.ATTRIBUTE_ID = D.ATTRIBUTE_ID ' ||
           ' AND C.ATTRIBUTE_ID = D.ATTRIBUTE_ID ' ||
           ' AND E.ATTRIBUTE_ID = A.ATTRIBUTE_ID ' ||
           ' AND E.DEFAULT_VERSION_FLAG = ''Y'' ' ||
           ' AND E.AW_SNAPSHOT_FLAG = ''N'' ';
        if (l_no_hierarchies = 'N') then
          l_command := l_command ||
           ' AND F.HIERARCHY_ID = G.HIERARCHY_OBJ_ID ' ||
           ' AND G.GROUP_SEQUENCE_ENFORCED_CODE <> ''NO_GROUPS'' ';
        end if;
        l_command := l_command || ') ';

        open l_cursor for l_command;
        fetch l_cursor into l_count;
        close l_cursor;
        if (l_count > 0) then

          select DECODE(nvl(FDR.FUNC_DIM_SET_NAME, '-99'), '-99',
                        A.DIMENSION_NAME,FDR.FUNC_DIM_SET_NAME) AS DIMENSION_NAME
            into l_dim_name
            from FEM_DIMENSIONS_VL A,
                 ZPB_BUSAREA_DIMENSIONS B,
                 FEM_FUNC_DIM_SETS_VL FDR
            where B.DIMENSION_ID = l_org_dim_id
            and B.LOGICAL_DIM_ID = l_org_logical_dim_id
            and B.VERSION_ID = p_version_id
            and A.DIMENSION_ID = B.DIMENSION_ID
            and FDR.FUNC_DIM_SET_ID (+) = B.FUNC_DIM_SET_ID ;

          select ATTRIBUTE_NAME
            into l_attr_name
            from FEM_DIM_ATTRIBUTES_VL
            where ATTRIBUTE_VARCHAR_LABEL = 'ZPB_ORG_CURRENCY'
              and DIMENSION_ID = l_org_dim_id;

         REGISTER_ERROR('S', 'W', 'ZPB_BUSAREA_VAL_ORG_NOCURRATTR',
                'ATTRNAME', l_attr_name, 'N', 'DIMNAME', l_dim_name, 'N');
        else
          l_command := 'select decode(count(*), 0, 0, 1)';
          if (l_no_hierarchies = 'Y') then
            if (l_vset_required = 'Y') then
              l_command := l_command || ' from (SELECT DISTINCT(to_number(substr(A.MEMBER_ID, instr(A.MEMBER_ID, ''_'')+1))) from table(ZPB_FEM_UTILS_PKG.GET_LIST_DIM_MEMBERS(';
            else
              l_command := l_command || ' from (SELECT DISTINCT(to_number(A.MEMBER_ID)) from table(ZPB_FEM_UTILS_PKG.GET_LIST_DIM_MEMBERS(';
            end if;
            l_command := l_command ||  ' '||l_org_dim_id||', '||l_org_logical_dim_id||', '||l_ba_id||', ''P'')) A,';
          else
            if (l_vset_required = 'Y') then
              l_command := l_command || '  from (SELECT DISTINCT(to_number(substr(A.CHILD_ID, instr(A.CHILD_ID, ''_'')+1)))';
            else
              l_command := l_command || '  from (SELECT DISTINCT(to_number(A.CHILD_ID))';
            end if;
            l_command := l_command || ' from table(ZPB_FEM_UTILS_PKG.GET_HIERARCHY_MEMBERS(';
            l_command := l_command ||  ' '||l_org_logical_dim_id||', '||l_ba_id||', ''P'')) A,';
          end if;
          l_command := l_command ||
            ' '||l_dim_table||' C ';
          if (l_no_hierarchies = 'N') then
            l_command := l_command || ', FEM_HIERARCHIES D';
            l_command := l_command || ' where ';
            if (l_vset_required = 'Y') then
              l_command := l_command ||
               'to_number(substr(A.CHILD_ID, instr(A.CHILD_ID, ''_'')+1))  = C.'||l_col||' AND ';
            else
               l_command := l_command || 'to_number(A.CHILD_ID)  = C.'||l_col||' AND ';
            end if;
            l_command := l_command ||
              ' D.HIERARCHY_OBJ_ID = A.HIERARCHY_ID ' ||
              ' AND D.GROUP_SEQUENCE_ENFORCED_CODE = ''NO_GROUPS''';
          end if;
          l_command := l_command ||
            ' MINUS select B.'||l_col||
            ' from FEM_DIM_ATTRIBUTES_B A,' ||
            ' '||l_dim_table||' B,' ||
            ' '||l_attr_table||' C,' ||
            ' FEM_DIM_ATTR_VERSIONS_B E,';
          if (l_no_hierarchies = 'Y') then
            l_command := l_command ||
             ' table(ZPB_FEM_UTILS_PKG.GET_LIST_DIM_MEMBERS(';
            l_command := l_command ||  ' '||l_org_dim_id||', '||l_org_logical_dim_id||', '||l_ba_id||', ''P'')) F';
          else
            l_command := l_command ||
             ' table(ZPB_FEM_UTILS_PKG.GET_HIERARCHY_MEMBERS(';
            l_command := l_command ||  ' '||l_org_logical_dim_id||', '||l_ba_id||', ''P'')) F';

            l_command := l_command || ', FEM_HIERARCHIES G ';
          end if;

          l_command := l_command ||
             '  where A.ATTRIBUTE_VARCHAR_LABEL = ''ZPB_ORG_CURRENCY'' ' ||
             '     AND C.ATTRIBUTE_ID = A.ATTRIBUTE_ID' ||
             '     AND B.'||l_col||' = C.'||l_col;
          if (l_no_hierarchies = 'N')
            then
              if (l_vset_required = 'Y') then
                l_command := l_command ||
                 ' AND B.'||l_col||' = to_number(substr(F.CHILD_ID, instr(F.CHILD_ID, ''_'')+1)) ';
              else
                l_command := l_command ||
                 ' AND B.'||l_col||' = to_number(F.CHILD_ID) ';
            end if;
          end if;
          l_command := l_command ||
             ' AND E.ATTRIBUTE_ID = A.ATTRIBUTE_ID ' ||
             ' AND E.DEFAULT_VERSION_FLAG = ''Y'' ' ||
             ' AND E.AW_SNAPSHOT_FLAG = ''N'' ';
          if (l_no_hierarchies = 'N') then
            l_command := l_command ||
             ' AND F.HIERARCHY_ID = G.HIERARCHY_OBJ_ID ' ||
             ' AND G.GROUP_SEQUENCE_ENFORCED_CODE = ''NO_GROUPS'' ';
           end if;
          l_command := l_command || ') ';
          open l_cursor for l_command;
          fetch l_cursor into l_count;
          close l_cursor;
          if (l_count > 0) then

          select DECODE(nvl(FDR.FUNC_DIM_SET_NAME, '-99'), '-99',
                        A.DIMENSION_NAME,FDR.FUNC_DIM_SET_NAME) AS DIMENSION_NAME
            into l_dim_name
            from FEM_DIMENSIONS_VL A,
                 ZPB_BUSAREA_DIMENSIONS B,
                 FEM_FUNC_DIM_SETS_VL FDR
            where B.DIMENSION_ID = l_org_dim_id
            and B.LOGICAL_DIM_ID = l_org_logical_dim_id
            and B.VERSION_ID = p_version_id
            and A.DIMENSION_ID = B.DIMENSION_ID
            and FDR.FUNC_DIM_SET_ID (+) = B.FUNC_DIM_SET_ID ;

            select ATTRIBUTE_NAME
              into l_attr_name
              from FEM_DIM_ATTRIBUTES_VL
              where ATTRIBUTE_VARCHAR_LABEL = 'ZPB_ORG_CURRENCY'
              and DIMENSION_ID = l_org_dim_id;

           REGISTER_ERROR('S', 'W', 'ZPB_BUSAREA_VAL_ORG_NOCURRATTR',
                  'ATTRNAME', l_attr_name, 'N', 'DIMNAME', l_dim_name, 'N');
         end if;
       end if;
     end if;

  end loop;


  ZPB_LOG.WRITE (l_proc_name||'.end', 'End BA validation');
end VAL_DEFINITION;

-------------------------------------------------------------------------
-- FIND_IN_REPOS - Finds objects in the repository dependent on the
--                 given object
--
-- p_init_fix   : Flag to confirm whether MD fixing should be done fixed or not
-------------------------------------------------------------------------
PROCEDURE FIND_IN_REPOS (p_business_area IN NUMBER,
                         p_version_id    IN NUMBER,
                         p_object_id     IN VARCHAR2,
                         p_object_type   IN VARCHAR2, -- Not used
                         p_object_name   IN VARCHAR2, -- Not used
                         p_init_fix      IN VARCHAR2)
   IS
      l_str      VARCHAR2(300);
      l_str2     VARCHAR2(256);
      l_num      NUMBER;
      l_taskID   NUMBER;
      l_user     FND_USER.USER_NAME%type;
      l_user_id  FND_USER.USER_ID%type;
      l_xml      BISM_OBJECTS.XML%type;
      l_line_dim VARCHAR2(150);
      l_folder   BISM_OBJECTS.FOLDER_ID%type;
      l_queryPath ZPB_STATUS_SQL.QUERY_PATH%type;
      l_queryErrorType varchar2(1);
      l_dim      ZPB_CYCLE_MODEL_DIMENSIONS.DIMENSION_NAME%type;
      l_dimName  ZPB_CYCLE_MODEL_DIMENSIONS.DIMENSION_NAME%type;
      l_acID     ZPB_ANALYSIS_CYCLES.ANALYSIS_CYCLE_ID%type;
      l_bpName   ZPB_ANALYSIS_CYCLES.NAME%type;
      l_memberID ZPB_LINE_DIMENSIONALITY.MEMBER%type;
      l_memberName VARCHAR2(255);
      l_secFoldPath ZPB_STATUS_SQL.QUERY_PATH%type;
      l_statusSqlId ZPB_STATUS_SQL.STATUS_SQL_ID%type;
      l_command  VARCHAR2(2000);
      l_cursor              epb_cur_type;

      CURSOR l_objs(p_search_str VARCHAR2,
                    l_folder BISM_OBJECTS.FOLDER_ID%type) is
         SELECT distinct A.OBJECT_ID,
            A.OBJECT_NAME,
            B.OBJECT_TYPE_NAME,
            C.OBJECT_NAME FOLDER_NAME,
            A.FOLDER_ID
          FROM BISM_OBJECTS A,
            BISM_OBJECT_TYPES B,
            BISM_OBJECTS C,
            (select C.CONTAINER_ID
             from BISM_OBJECTS C,
             BISM_OBJECT_TYPES D
             where C.OBJECT_TYPE_ID = D.OBJECT_TYPE_ID
             and D.OBJECT_TYPE_NAME = 'Selection'
             and C.XML like p_search_str
             and C.FOLDER_ID IN
             (select OBJECT_ID
              from BISM_OBJECTS
              where OBJECT_TYPE_ID = 100
              start with OBJECT_ID = l_folder
              connect by FOLDER_ID = prior OBJECT_ID)) D
          WHERE A.OBJECT_TYPE_ID = B.OBJECT_TYPE_ID
            and A.FOLDER_ID = C.OBJECT_ID
            and A.OBJECT_ID = D.CONTAINER_ID
            and B.OBJECT_TYPE_NAME <> 'Selection';

      cursor l_dc_tg_objs(p_search_str VARCHAR2, p_baID NUMBER) is
         select TEMPLATE_NAME, OBJECT_TYPE, A.ANALYSIS_CYCLE_ID, TARGET_OBJ_PATH
            into l_str2, l_str, l_acID, l_queryPath
            from ZPB_DC_OBJECTS A, ZPB_ANALYSIS_CYCLES B
            where A.ANALYSIS_CYCLE_ID = B.ANALYSIS_CYCLE_ID
            AND B.STATUS_CODE <> 'MARKED_FOR_DELETION'
            AND B.BUSINESS_AREA_ID = p_baID
            AND TARGET_OBJ_NAME = p_search_str;

      cursor l_dc_data_objs(p_search_str VARCHAR2, p_baID NUMBER) is
         select TEMPLATE_NAME, OBJECT_TYPE, A.ANALYSIS_CYCLE_ID, TARGET_OBJ_PATH
            into l_str2, l_str, l_acID, l_queryPath
            from ZPB_DC_OBJECTS A, ZPB_ANALYSIS_CYCLES B
            where A.ANALYSIS_CYCLE_ID = B.ANALYSIS_CYCLE_ID
            AND B.STATUS_CODE <> 'MARKED_FOR_DELETION'
            AND B.BUSINESS_AREA_ID = p_baID
            AND DATAENTRY_OBJ_NAME = p_search_str;

      cursor l_input_sel(p_search_str VARCHAR2, p_baID NUMBER) is
         select SELECTION_NAME, SELECTION_PATH, A.ANALYSIS_CYCLE_ID, B.NAME
            into l_str, l_queryPath, l_acID, l_bpName
            from ZPB_SOLVE_INPUT_SELECTIONS A, ZPB_ANALYSIS_CYCLES B
            where A.ANALYSIS_CYCLE_ID = B.ANALYSIS_CYCLE_ID
            AND B.STATUS_CODE <> 'MARKED_FOR_DELETION'
            AND B.BUSINESS_AREA_ID = p_baID
            AND SELECTION_NAME = p_search_str;

      cursor l_output_sel(p_search_str VARCHAR2, p_baID NUMBER) is
         select SELECTION_NAME, SELECTION_PATH, A.ANALYSIS_CYCLE_ID, B.NAME
            into l_str, l_queryPath, l_acID, l_bpName
            from ZPB_SOLVE_OUTPUT_SELECTIONS A, ZPB_ANALYSIS_CYCLES B
            where A.ANALYSIS_CYCLE_ID = B.ANALYSIS_CYCLE_ID
            AND B.STATUS_CODE <> 'MARKED_FOR_DELETION'
            AND B.BUSINESS_AREA_ID = p_baID
            AND SELECTION_NAME = p_search_str;

      cursor l_init_source(p_search_str VARCHAR2, p_baID NUMBER) is
         select SOURCE_QUERY_NAME, QUERY_PATH, MEMBER, A.ANALYSIS_CYCLE_ID
            into l_str, l_queryPath, l_memberID, l_acID
            from ZPB_DATA_INITIALIZATION_DEFS A, ZPB_ANALYSIS_CYCLES B
            where A.ANALYSIS_CYCLE_ID = B.ANALYSIS_CYCLE_ID
            AND B.STATUS_CODE <> 'MARKED_FOR_DELETION'
            AND B.BUSINESS_AREA_ID = p_baID
            AND SOURCE_QUERY_NAME = p_search_str;

      cursor l_init_target(p_search_str VARCHAR2, p_baID NUMBER) is
         select TARGET_QUERY_NAME, QUERY_PATH, MEMBER, A.ANALYSIS_CYCLE_ID
            into l_str, l_queryPath, l_memberID, l_acID
            from ZPB_DATA_INITIALIZATION_DEFS A, ZPB_ANALYSIS_CYCLES B
            where A.ANALYSIS_CYCLE_ID = B.ANALYSIS_CYCLE_ID
            AND B.STATUS_CODE <> 'MARKED_FOR_DELETION'
            AND B.BUSINESS_AREA_ID = p_baID
            AND TARGET_QUERY_NAME = p_search_str;

      cursor l_sum_sel1(p_search_str VARCHAR2, p_baID NUMBER) is
         select SUM_SELECTION_NAME, SUM_SELECTION_PATH, DIMENSION_NAME, A.ANALYSIS_CYCLE_ID
            into l_str, l_queryPath, l_dim, l_acID
            from zpb_cycle_model_dimensions A, ZPB_ANALYSIS_CYCLES B
            where A.ANALYSIS_CYCLE_ID = B.ANALYSIS_CYCLE_ID
            AND B.STATUS_CODE <> 'MARKED_FOR_DELETION'
            AND B.BUSINESS_AREA_ID = p_baID
            AND SUM_SELECTION_NAME = p_search_str;

      cursor l_sum_sel2(p_search_str VARCHAR2, p_baID NUMBER) is
         select SUM_SELECTION_NAME, SUM_SELECTION_PATH, MEMBER, DIMENSION, A.ANALYSIS_CYCLE_ID
            into l_str, l_queryPath, l_memberID, l_dim, l_acID
            from ZPB_LINE_DIMENSIONALITY A, ZPB_ANALYSIS_CYCLES B
            where A.ANALYSIS_CYCLE_ID = B.ANALYSIS_CYCLE_ID
            AND B.STATUS_CODE <> 'MARKED_FOR_DELETION'
            AND B.BUSINESS_AREA_ID = p_baID
            AND SUM_SELECTION_NAME = p_search_str;

      CURSOR l_get_status_sql_id(p_query_path VARCHAR2) IS
        SELECT status_sql_id
        FROM zpb_status_sql
        WHERE query_path = p_query_path;

      cursor query_objects(p_object_name varchar2, p_folder_name varchar2) is
        select distinct A.NAME, A.ANALYSIS_CYCLE_ID, B.QUERY_OBJECT_PATH
          from ZPB_ANALYSIS_CYCLES A,
               ZPB_CYCLE_MODEL_DIMENSIONS B
          where B.QUERY_OBJECT_NAME = p_object_name
            and B.QUERY_OBJECT_PATH like '%'||p_folder_name
            and A.ANALYSIS_CYCLE_ID = B.ANALYSIS_CYCLE_ID
            and A.STATUS_CODE <> 'MARKED_FOR_DELETION'
            and A.BUSINESS_AREA_ID = p_business_area
            and not exists
              (select B.ANALYSIS_CYCLE_ID
               from ZPB_ANALYSIS_CYCLE_INSTANCES B
               where B.INSTANCE_AC_ID = A.ANALYSIS_CYCLE_ID);
begin
    BEGIN
        select BUSAREA.OBJECT_ID
        into l_folder
        from BISM_OBJECTS ORCL,
        BISM_OBJECTS APPS,
        BISM_OBJECTS ZPB,
        BISM_OBJECTS BUSAREA
        where ORCL.USER_VISIBLE = 'Y'
        and APPS.USER_VISIBLE = 'Y'
        and ZPB.USER_VISIBLE = 'Y'
        and BUSAREA.USER_VISIBLE = 'Y'
        and ORCL.OBJECT_NAME = 'oracle'
        and APPS.OBJECT_NAME = 'apps'
        and ZPB.OBJECT_NAME = 'zpb'
        and BUSAREA.OBJECT_NAME = 'BusArea'||p_business_area
        and ORCL.FOLDER_ID = HEXTORAW('31')
        and APPS.FOLDER_ID = ORCL.OBJECT_ID
        and ZPB.FOLDER_ID = APPS.OBJECT_ID
        and BUSAREA.FOLDER_ID = ZPB.OBJECT_ID;
    EXCEPTION
        WHEN no_data_found THEN
            null;
    END;

   l_secFoldPath := G_BUS_AREA_PATH_PREFIX || p_business_area || G_SECURITY_ADMIN_FOLDER;

   if (p_object_id = '%') then
       l_queryErrorType := 'R';
   else
       l_queryErrorType := 'F';
   end if;

   for each in l_objs('%'||p_object_id||'%', l_folder) loop
    begin
      if (instr (each.object_name, 'MODEL_QUERY') > 0) then
         if (l_line_dim is null) then
            select NAME
               into l_line_dim
               from ZPB_BUSAREA_DIMENSIONS_VL
               where VERSION_ID = p_version_id
               and DIMENSION_ID = (select MIN(DIMENSION_ID)
                                   from ZPB_BUSAREA_DIMENSIONS
                                   where VERSION_ID = p_version_id
                                   and EPB_LINE_DIMENSION = 'Y');
         end if;

         for each_query in query_objects(each.object_name,each.folder_name)
           loop
             l_queryPath := each_query.QUERY_OBJECT_PATH;
             l_acID := each_query.ANALYSIS_CYCLE_ID;
             l_str := each_query.NAME;
             DISABLE_BP(p_business_area , each.object_name, l_queryPath,
                              l_queryErrorType, l_acID, p_init_fix);
             if(l_queryErrorType = 'F') then
                REGISTER_ERROR ('O', 'W', 'ZPB_BUSAREA_VAL_INV_MOD_QUERY',
                          'LINEDIM', l_line_dim, 'N',
                          'NAME', l_str, 'N');
             end if;
           end loop;

       elsif (instr (each.object_name, 'LOAD_DATA') > 0 or
              instr (each.object_name, 'EXCEPTION_') > 0) then
         begin
            l_num := to_number(substr(each.folder_name, 3));
            select A.TASK_NAME, A.TASK_ID, A.ANALYSIS_CYCLE_ID,
               nvl (D.INSTANCE_DESCRIPTION, B.NAME) NAME
               into l_str2, l_taskID, l_acID, l_str
               from ZPB_ANALYSIS_CYCLE_TASKS A,
               ZPB_ANALYSIS_CYCLES B,
               ZPB_TASK_PARAMETERS C,
               ZPB_ANALYSIS_CYCLE_INSTANCES D
               where A.ANALYSIS_CYCLE_ID = B.ANALYSIS_CYCLE_ID
               and B.STATUS_CODE <> 'MARKED_FOR_DELETION'
               and B.BUSINESS_AREA_ID = p_business_area
               and A.ANALYSIS_CYCLE_ID = l_num
               and A.TASK_ID = C.TASK_ID
               and C.NAME = 'QUERY_OBJECT_NAME'
               and C.VALUE = each.object_name
               and A.ANALYSIS_CYCLE_ID = D.INSTANCE_AC_ID(+);

            SELECT value
            INTO l_queryPath
            FROM ZPB_TASK_PARAMETERS
            WHERE name = 'QUERY_OBJECT_PATH'
            AND TASK_ID = l_taskID;

            IF(l_queryErrorType = 'F') THEN
             IF (instr (each.object_name, 'LOAD_DATA') > 0) then
               REGISTER_ERROR('O', 'W', 'ZPB_BUSAREA_VAL_INV_BP_TASK',
                              'TASK_NAME', l_str2, 'N',
                              'TASK_TYPE', 'ZPB_TASK_NAME_LOAD_DATA_MSG', 'Y',
                              'NAME', l_str, 'N');
             ELSE
               REGISTER_ERROR('O', 'W', 'ZPB_BUSAREA_VAL_INV_BP_TASK',
                              'TASK_NAME', l_str2, 'N',
                              'TASK_TYPE','ZPB_TASK_NAME_EXCEPT_CHECK_MSG','Y',
                              'NAME', l_str, 'N');
             END IF;
            END IF;
            DISABLE_BP(p_business_area ,each.object_name, l_queryPath,
                       l_queryErrorType, l_acID, p_init_fix);
         EXCEPTION
            WHEN no_data_found THEN
               null; -- Bug 4214272
         END;

      ELSIF (instr (each.object_name, 'CD_SOURCE') > 0) THEN
         FOR each_init_source in l_init_source(each.object_name, p_business_area) loop
            DISABLE_BP(p_business_area ,each.object_name,
                        each_init_source.QUERY_PATH, l_queryErrorType,
                        each_init_source.ANALYSIS_CYCLE_ID, p_init_fix);

            l_memberName := GET_LINE_MEMBER_DESC(each_init_source.MEMBER);

            IF(l_queryErrorType = 'F') THEN
            REGISTER_ERROR('O', 'W', 'ZPB_BUSAREA_INV_INIT_QUERY',
                       'LINE_ITEM', l_memberName, 'N');
            END IF;
         END LOOP;

      ELSIF (instr (each.object_name, 'CD_TARGET') > 0) THEN
         FOR each_init_target in l_init_target(each.object_name, p_business_area) loop
            DISABLE_BP(p_business_area ,each.object_name,
                        each_init_target.QUERY_PATH, l_queryErrorType,
                        each_init_target.ANALYSIS_CYCLE_ID, p_init_fix);

            l_memberName := GET_LINE_MEMBER_DESC(each_init_target.MEMBER);

            IF(l_queryErrorType = 'F') THEN
            REGISTER_ERROR('O', 'W', 'ZPB_BUSAREA_INV_INIT_QUERY',
                       'LINE_ITEM', l_memberName, 'N');
            END IF;
         END LOOP;

       ELSIF (instr (each.object_name, 'TARGET') > 0) then
         FOR each_dc_obj in l_dc_tg_objs(each.object_name, p_business_area) loop
            IF (instr(each.object_name, 'GEN_TEMPL') > 0) then
               l_str := 'ZPB_GENERATE_TEMPL_TASK_TARGET';
             ELSE
               l_str := 'ZPB_TARGET_MASTER';
            END IF;

            IF(l_queryErrorType = 'F') THEN
            REGISTER_ERROR('O', 'W', 'ZPB_BUSAREA_VAL_INV_QUERY',
                           'QUERY', l_str, 'Y',
                           'NAME', each_dc_obj.TEMPLATE_NAME, 'N');
            END IF;

            DISABLE_BP(p_business_area ,each.object_name,
                       each_dc_obj.TARGET_OBJ_PATH, l_queryErrorType,
                       each_dc_obj.ANALYSIS_CYCLE_ID, p_init_fix);
         END LOOP;

       ELSIF (instr (each.object_name, '_DATA_') > 0) then
         FOR each_dc_obj in l_dc_data_objs(each.object_name, p_business_area) loop
            IF (instr(each.object_name, 'GEN_TEMPL') > 0) then
               l_str := 'ZPB_GENERATE_TEMPL_TASK_DATA';
             ELSE
               l_str := 'ZPB_DATA_MASTER';
            END IF;

            IF(l_queryErrorType = 'F') THEN
            REGISTER_ERROR('O', 'W', 'ZPB_BUSAREA_VAL_INV_QUERY',
                           'QUERY', l_str, 'Y',
                           'NAME', each_dc_obj.TEMPLATE_NAME, 'N');
            END IF;

            DISABLE_BP(p_business_area ,each.object_name,
                       each_dc_obj.TARGET_OBJ_PATH, l_queryErrorType,
                       each_dc_obj.ANALYSIS_CYCLE_ID,p_init_fix);
         END LOOP;

       ELSIF (instr (each.object_name, 'ReadAccess') > 0) THEN
         l_str := substr(each.object_name, 1,
                         instr(each.object_name, 'ReadAccess')+9);
         SELECT xml
            INTO l_xml
            FROM BISM_OBJECTS
            WHERE OBJECT_NAME = l_str
            AND FOLDER_ID = each.FOLDER_ID;

         l_user_id := to_number(substr(l_str, 1, instr(l_str, '_')-1));

         SELECT USER_NAME
            INTO l_user
            FROM FND_USER
            WHERE USER_ID = l_user_id;

         l_num := instr(l_xml, 'Description="')+13;
         l_str := substr(l_xml, l_num, instr(l_xml, '"', l_num)-l_num);

         IF(l_queryErrorType = 'F') THEN
         REGISTER_ERROR('O', 'W', 'ZPB_BUSAREA_VAL_INV_SEC_RULE',
                        'OBJ_TYPE', 'ZPB_MGR_READACCESS_DESCRIPTION', 'Y',
                        'NAME', l_str, 'N',
                        'USER', l_user, 'N');
         END IF;

         for lock_user in
           l_get_status_sql_id(l_secFoldPath || '/' || each.object_name)
         loop

           LOCK_OUT_USER(p_business_area,
                         l_user_id,
                         each.object_name,
                         l_secFoldPath,
                         G_READ_RULE,
                         l_queryErrorType,
                         p_init_fix,
                         lock_user.status_sql_id);
         end loop;

       ELSIF (instr (each.object_name, 'WriteAccess') > 0) THEN
         l_str := substr(each.object_name, 1,
                         instr(each.object_name, 'WriteAccess')+10);
         SELECT xml
            INTO l_xml
            FROM BISM_OBJECTS
            WHERE OBJECT_NAME = l_str
            AND FOLDER_ID = each.FOLDER_ID;

         l_user_id := to_number(substr(l_str, 1, instr(l_str, '_')-1));

         SELECT USER_NAME
            INTO l_user
            FROM FND_USER
            WHERE USER_ID = l_user_id;


         l_num := instr(l_xml, 'Description="')+13;
         l_str := substr(l_xml, l_num, instr(l_xml, '"', l_num)-l_num);

         REGISTER_ERROR('O', 'W', 'ZPB_BUSAREA_VAL_INV_SEC_RULE',
                        'OBJ_TYPE', 'ZPB_MGR_WRITEACC_DESCRIPTION', 'Y',
                        'NAME', l_str, 'N',
                        'USER', l_user, 'N');

         for lock_user
           in l_get_status_sql_id(l_secFoldPath || '/' || each.object_name)
         loop

           LOCK_OUT_USER(p_business_area,
                         l_user_id,
                         each.object_name,
                         l_secFoldPath,
                         G_WRITE_RULE,
                         l_queryErrorType,
                         p_init_fix,
                         lock_user.status_sql_id);
         end loop;

        ELSIF (instr (each.object_name, 'Ownership') > 0) THEN
         l_str := substr(each.object_name, 1,
                         instr(each.object_name, 'Ownership')+8);
         SELECT xml
            INTO l_xml
            FROM BISM_OBJECTS
            WHERE OBJECT_NAME = l_str
            AND FOLDER_ID = each.FOLDER_ID;

         l_user_id := to_number(substr(l_str, 1, instr(l_str, '_')-1));

         SELECT USER_NAME
            INTO l_user
            FROM FND_USER
            WHERE USER_ID = l_user_id;

         l_num := instr(l_xml, 'Description="')+13;
         l_str := substr(l_xml, l_num, instr(l_xml, '"', l_num)-l_num);

         -- Bug#5052923: Fixed message name.
         REGISTER_ERROR('O', 'W', 'ZPB_BUSAREA_VAL_INV_SEC_RULE',
                        'OBJ_TYPE', 'ZPB_MGR_WRITEACC_DESCRIPTION', 'Y',
                        'NAME', l_str, 'N',
                        'USER', l_user, 'N');

         for lock_user in
           l_get_status_sql_id(l_secFoldPath || '/' || each.object_name)
         loop

           LOCK_OUT_USER(p_business_area,
                         l_user_id,
                         each.object_name,
                         l_secFoldPath,
                         G_OWNER_RULE,
                         l_queryErrorType,
                         p_init_fix,
                         lock_user.status_sql_id);
         end loop;

      ELSIF (instr (each.object_name, 'INPUT') > 0) THEN
         FOR each_input_sel in l_input_sel(each.object_name, p_business_area) loop
            IF(l_queryErrorType = 'F') THEN
            REGISTER_ERROR('O', 'W', 'ZPB_BUSAREA_VAL_INV_SOLVE',
                           'NAME', each_input_sel.NAME, 'N');
            END IF;
            DISABLE_BP(p_business_area ,each.object_name,
                       each_input_sel.SELECTION_PATH, l_queryErrorType,
                       each_input_sel.ANALYSIS_CYCLE_ID, p_init_fix);
         END LOOP;

      ELSIF (instr (each.object_name, 'OUTPUT') > 0) THEN
         FOR each_output_sel in l_output_sel(each.object_name, p_business_area) loop
            IF(l_queryErrorType = 'F') THEN
            REGISTER_ERROR('O', 'W', 'ZPB_BUSAREA_VAL_INV_SOLVE',
                           'NAME', each_output_sel.NAME, 'N');
            END IF;
            DISABLE_BP(p_business_area ,each.object_name,
                       each_output_sel.SELECTION_PATH, l_queryErrorType,
                       each_output_sel.ANALYSIS_CYCLE_ID, p_init_fix);
         END LOOP;

      ELSIF (instr (each.object_name, 'SUM') > 0) THEN
            IF (instr(each.object_name, 'SUM_') > 0) THEN
                 FOR each_sum_sel in l_sum_sel2(each.object_name, p_business_area) LOOP
                    DISABLE_BP(p_business_area ,each.object_name,
                           each_sum_sel.SUM_SELECTION_PATH, l_queryErrorType,
                           each_sum_sel.ANALYSIS_CYCLE_ID, p_init_fix);

                    SELECT name INTO l_dimName FROM zpb_dimensions_vl
                    WHERE  bus_area_id = p_business_area
                    AND aw_name = each_sum_sel.DIMENSION;

                    l_memberName := GET_LINE_MEMBER_DESC(each_sum_sel.MEMBER);
                    IF(l_queryErrorType = 'F') THEN
                    REGISTER_ERROR('O', 'W', 'ZPB_BUSAREA_INV_SUM_MEM_QUERY',
                        'DIM_NAME', l_dimName, 'N',
                        'LINE_ITEM', l_memberName, 'N');
                    END IF;
                 END LOOP;
            ELSE
                 FOR each_sum_sel in l_sum_sel1(each.object_name, p_business_area) LOOP
                    SELECT name INTO l_dimName FROM zpb_dimensions_vl
                    WHERE  bus_area_id = p_business_area
                    AND aw_name = each_sum_sel.DIMENSION_NAME;

                    DISABLE_BP(p_business_area ,each.object_name,
                           each_sum_sel.SUM_SELECTION_PATH, l_queryErrorType,
                           each_sum_sel.ANALYSIS_CYCLE_ID, p_init_fix);

                    IF(l_queryErrorType = 'F') THEN
                    REGISTER_ERROR('O', 'W', 'ZPB_BUSAREA_INV_REM_DIM_QUERY',
                        'DIM_NAME', l_dimName, 'N');
                    END IF;

                 END LOOP;
            END IF;
      END IF;
    EXCEPTION
       WHEN no_data_found THEN
          null;
    END;
   END LOOP;
END FIND_IN_REPOS;


-------------------------------------------------------------------------
-- FIND_DEF_HIER_IN_REPOS - Finds objects in the repository dependent on the
--                 DEFAULT HIERARCHY
-- Here we fix all the dependent queries but mark only those whose dimension
-- is same as removed default hier's dimension
--
-- p_init_fix   : Flag to confirm whether MD fixing should be done fixed or not
-------------------------------------------------------------------------
PROCEDURE FIND_DEF_HIER_IN_REPOS (p_business_area IN NUMBER,
                         p_version_id    IN NUMBER,
                         p_object_id     IN VARCHAR2,
                         p_object_type   IN VARCHAR2, -- Not used
                         p_object_name   IN VARCHAR2, -- Not used
                         p_init_fix      IN VARCHAR2)
   IS
        l_str      VARCHAR2(300);
        l_str2     VARCHAR2(256);
        l_num      NUMBER;
        l_taskID   NUMBER;
        l_user     FND_USER.USER_NAME%type;
        l_user_id  FND_USER.USER_ID%type;
        l_xml      BISM_OBJECTS.XML%type;
        l_line_dim VARCHAR2(150);
        l_line_dimID VARCHAR2(30);
        l_folder   BISM_OBJECTS.FOLDER_ID%type;
        l_queryPath ZPB_STATUS_SQL.QUERY_PATH%type;
        l_queryErrorType varchar2(1);
        l_dim      ZPB_CYCLE_MODEL_DIMENSIONS.DIMENSION_NAME%type;
        l_dimName  ZPB_CYCLE_MODEL_DIMENSIONS.DIMENSION_NAME%type;
        l_acID     ZPB_ANALYSIS_CYCLES.ANALYSIS_CYCLE_ID%type;
        l_bpName   ZPB_ANALYSIS_CYCLES.NAME%type;
        l_memberID ZPB_LINE_DIMENSIONALITY.MEMBER%type;
        l_memberName VARCHAR2(255);
        l_rem_def_hier_dim VARCHAR2(30);
        l_current_dim VARCHAR2(30);
        l_secFoldPath ZPB_STATUS_SQL.QUERY_PATH%type;
        l_statusSqlId ZPB_STATUS_SQL.STATUS_SQL_ID%type;
        l_command  VARCHAR2(1000);
        l_cursor              epb_cur_type;

      CURSOR l_objs(p_search_str VARCHAR2,
                    l_folder BISM_OBJECTS.FOLDER_ID%type) is
         SELECT distinct A.OBJECT_ID,
            A.OBJECT_NAME,
            B.OBJECT_TYPE_NAME,
            C.OBJECT_NAME FOLDER_NAME,
            A.FOLDER_ID
          FROM BISM_OBJECTS A,
            BISM_OBJECT_TYPES B,
            BISM_OBJECTS C,
            (select C.CONTAINER_ID
             from BISM_OBJECTS C,
             BISM_OBJECT_TYPES D
             where C.OBJECT_TYPE_ID = D.OBJECT_TYPE_ID
             and D.OBJECT_TYPE_NAME = 'Selection'
             and C.XML like p_search_str
             and C.FOLDER_ID IN
             (select OBJECT_ID
              from BISM_OBJECTS
              where OBJECT_TYPE_ID = 100
              start with OBJECT_ID = l_folder
              connect by FOLDER_ID = prior OBJECT_ID)) D
          WHERE A.OBJECT_TYPE_ID = B.OBJECT_TYPE_ID
            and A.FOLDER_ID = C.OBJECT_ID
            and A.OBJECT_ID = D.CONTAINER_ID
            and B.OBJECT_TYPE_NAME <> 'Selection';

      cursor l_dc_tg_objs(p_search_str VARCHAR2, p_baID NUMBER) is
         select TEMPLATE_NAME, OBJECT_TYPE, A.ANALYSIS_CYCLE_ID, TARGET_OBJ_PATH
            into l_str2, l_str, l_acID, l_queryPath
            from ZPB_DC_OBJECTS A, ZPB_ANALYSIS_CYCLES B
            where A.ANALYSIS_CYCLE_ID = B.ANALYSIS_CYCLE_ID
            AND B.STATUS_CODE <> 'MARKED_FOR_DELETION'
            AND B.BUSINESS_AREA_ID = p_baID
            AND TARGET_OBJ_NAME = p_search_str;

      cursor l_dc_data_objs(p_search_str VARCHAR2, p_baID NUMBER) is
         select TEMPLATE_NAME, OBJECT_TYPE, A.ANALYSIS_CYCLE_ID, TARGET_OBJ_PATH
            into l_str2, l_str, l_acID, l_queryPath
            from ZPB_DC_OBJECTS A, ZPB_ANALYSIS_CYCLES B
            where A.ANALYSIS_CYCLE_ID = B.ANALYSIS_CYCLE_ID
            AND B.STATUS_CODE <> 'MARKED_FOR_DELETION'
            AND B.BUSINESS_AREA_ID = p_baID
            AND DATAENTRY_OBJ_NAME = p_search_str;

      cursor l_input_sel(p_search_str VARCHAR2, p_baID NUMBER) is
         select SELECTION_NAME, SELECTION_PATH, A.ANALYSIS_CYCLE_ID, DIMENSION, B.NAME
            into l_str, l_queryPath, l_acID, l_current_dim, l_bpName
            from ZPB_SOLVE_INPUT_SELECTIONS A, ZPB_ANALYSIS_CYCLES B
            where A.ANALYSIS_CYCLE_ID = B.ANALYSIS_CYCLE_ID
            AND B.STATUS_CODE <> 'MARKED_FOR_DELETION'
            AND B.BUSINESS_AREA_ID = p_baID
            AND SELECTION_NAME = p_search_str;

      cursor l_output_sel(p_search_str VARCHAR2, p_baID NUMBER) is
         select SELECTION_NAME, SELECTION_PATH, A.ANALYSIS_CYCLE_ID, DIMENSION, B.NAME
            into l_str, l_queryPath, l_acID, l_current_dim, l_bpName
            from ZPB_SOLVE_OUTPUT_SELECTIONS A, ZPB_ANALYSIS_CYCLES B
            where A.ANALYSIS_CYCLE_ID = B.ANALYSIS_CYCLE_ID
            AND B.STATUS_CODE <> 'MARKED_FOR_DELETION'
            AND B.BUSINESS_AREA_ID = p_baID
            AND SELECTION_NAME = p_search_str;

      cursor l_init_source(p_search_str VARCHAR2, p_baID NUMBER) is
         select SOURCE_QUERY_NAME, QUERY_PATH, MEMBER, A.ANALYSIS_CYCLE_ID
            into l_str, l_queryPath, l_memberID, l_acID
            from ZPB_DATA_INITIALIZATION_DEFS A, ZPB_ANALYSIS_CYCLES B
            where A.ANALYSIS_CYCLE_ID = B.ANALYSIS_CYCLE_ID
            AND B.STATUS_CODE <> 'MARKED_FOR_DELETION'
            AND B.BUSINESS_AREA_ID = p_baID
            AND SOURCE_QUERY_NAME = p_search_str;

      cursor l_init_target(p_search_str VARCHAR2, p_baID NUMBER) is
         select TARGET_QUERY_NAME, QUERY_PATH, MEMBER, A.ANALYSIS_CYCLE_ID
            into l_str, l_queryPath, l_memberID, l_acID
            from ZPB_DATA_INITIALIZATION_DEFS A, ZPB_ANALYSIS_CYCLES B
            where A.ANALYSIS_CYCLE_ID = B.ANALYSIS_CYCLE_ID
            AND B.STATUS_CODE <> 'MARKED_FOR_DELETION'
            AND B.BUSINESS_AREA_ID = p_baID
            AND TARGET_QUERY_NAME = p_search_str;

      cursor l_sum_sel1(p_search_str VARCHAR2, p_baID NUMBER) is
         select SUM_SELECTION_NAME, SUM_SELECTION_PATH, DIMENSION_NAME, A.ANALYSIS_CYCLE_ID
            into l_str, l_queryPath, l_dim, l_acID
            from zpb_cycle_model_dimensions A, ZPB_ANALYSIS_CYCLES B
            where A.ANALYSIS_CYCLE_ID = B.ANALYSIS_CYCLE_ID
            AND B.STATUS_CODE <> 'MARKED_FOR_DELETION'
            AND B.BUSINESS_AREA_ID = p_baID
            AND SUM_SELECTION_NAME = p_search_str;

      cursor l_sum_sel2(p_search_str VARCHAR2, p_baID NUMBER) is
         select SUM_SELECTION_NAME, SUM_SELECTION_PATH, MEMBER, DIMENSION, A.ANALYSIS_CYCLE_ID
            into l_str, l_queryPath, l_memberID, l_dim, l_acID
            from ZPB_LINE_DIMENSIONALITY A, ZPB_ANALYSIS_CYCLES B
            where A.ANALYSIS_CYCLE_ID = B.ANALYSIS_CYCLE_ID
            AND B.STATUS_CODE <> 'MARKED_FOR_DELETION'
            AND B.BUSINESS_AREA_ID = p_baID
            AND SUM_SELECTION_NAME = p_search_str;

  cursor l_source_dims(p_memberID VARCHAR2, p_acId NUMBER) is
         SELECT DIM SOURCE_DIMENSION
            INTO l_current_dim
            FROM ZPB_COPY_DIM_MEMBERS
            WHERE LINE_MEMBER_ID = p_memberID
            AND analysis_cycle_id = p_acId
            AND SOURCE_NUM_MEMBERS IS NOT NULL;

      cursor l_target_dims(p_memberID VARCHAR2, p_acId NUMBER) is
         SELECT DIM TARGET_DIM
            INTO l_current_dim
            FROM ZPB_COPY_DIM_MEMBERS
            WHERE LINE_MEMBER_ID = p_memberID
            AND ANALYSIS_CYCLE_ID = p_acId
            AND TARGET_NUM_MEMBERS IS NOT NULL;

      CURSOR l_get_status_sql_id(p_query_path VARCHAR2) IS
        SELECT status_sql_id
        FROM zpb_status_sql
        WHERE query_path = p_query_path;

      cursor query_objects(p_object_name varchar2, p_folder_name varchar2) is
        select distinct A.NAME, A.ANALYSIS_CYCLE_ID, B.QUERY_OBJECT_PATH
          from ZPB_ANALYSIS_CYCLES A,
               ZPB_CYCLE_MODEL_DIMENSIONS B
          where B.QUERY_OBJECT_NAME = p_object_name
            and B.QUERY_OBJECT_PATH like '%'||p_folder_name
            and A.ANALYSIS_CYCLE_ID = B.ANALYSIS_CYCLE_ID
            and A.STATUS_CODE <> 'MARKED_FOR_DELETION'
            and A.BUSINESS_AREA_ID = p_business_area
            and not exists
              (select B.ANALYSIS_CYCLE_ID
               from ZPB_ANALYSIS_CYCLE_INSTANCES B
               where B.INSTANCE_AC_ID = A.ANALYSIS_CYCLE_ID);

begin
    BEGIN
        select BUSAREA.OBJECT_ID
        into l_folder
        from BISM_OBJECTS ORCL,
        BISM_OBJECTS APPS,
        BISM_OBJECTS ZPB,
        BISM_OBJECTS BUSAREA
        where ORCL.USER_VISIBLE = 'Y'
        and APPS.USER_VISIBLE = 'Y'
        and ZPB.USER_VISIBLE = 'Y'
        and BUSAREA.USER_VISIBLE = 'Y'
        and ORCL.OBJECT_NAME = 'oracle'
        and APPS.OBJECT_NAME = 'apps'
        and ZPB.OBJECT_NAME = 'zpb'
        and BUSAREA.OBJECT_NAME = 'BusArea'||p_business_area
        and ORCL.FOLDER_ID = HEXTORAW('31')
        and APPS.FOLDER_ID = ORCL.OBJECT_ID
        and ZPB.FOLDER_ID = APPS.OBJECT_ID
        and BUSAREA.FOLDER_ID = ZPB.OBJECT_ID;

    EXCEPTION
        WHEN no_data_found THEN
            null;
    END;
    --get the removed Default Hier's Dimension ID
    SELECT AW_NAME INTO l_rem_def_hier_dim FROM ZPB_DIMENSIONS_VL
    WHERE BUS_AREA_ID = p_business_area
    AND DEFAULT_HIER = SUBSTR(p_object_id, INSTR(p_object_id, '_', -1, 1) + 1);

    --get the ID for Line Dimension
    SELECT AW_NAME INTO l_line_dimID FROM ZPB_DIMENSIONS_VL
    WHERE BUS_AREA_ID = p_business_area
    AND DIM_TYPE = 'LINE';

    l_secFoldPath := G_BUS_AREA_PATH_PREFIX || p_business_area || G_SECURITY_ADMIN_FOLDER;

    for each in l_objs('%'||p_object_id||'%', l_folder) loop
    begin
      if (instr (each.object_name, 'MODEL_QUERY') > 0) then
         if (l_line_dim is null) then
            select NAME
               into l_line_dim
               from ZPB_BUSAREA_DIMENSIONS_VL
               where VERSION_ID = p_version_id
               and DIMENSION_ID = (select MIN(DIMENSION_ID)
                                   from ZPB_BUSAREA_DIMENSIONS
                                   where VERSION_ID = p_version_id
                                   and EPB_LINE_DIMENSION = 'Y');
         end if;
         for each_query in query_objects(each.object_name,each.folder_name)
           loop
             l_queryPath := each_query.QUERY_OBJECT_PATH;
             l_acID := each_query.ANALYSIS_CYCLE_ID;
             l_str := each_query.NAME;
             if (l_rem_def_hier_dim = l_line_dimID) then
                l_queryErrorType := 'F';
                REGISTER_ERROR ('O', 'W', 'ZPB_BUSAREA_VAL_INV_MOD_QUERY',
                         'LINEDIM', l_line_dim, 'N',
                         'NAME', l_str, 'N');
             else
                l_queryErrorType := 'R';
             end if;

             DISABLE_BP(p_business_area , each.object_name, l_queryPath,
                  l_queryErrorType, l_acID, p_init_fix);
            end loop;

       elsif (instr (each.object_name, 'LOAD_DATA') > 0 or
              instr (each.object_name, 'EXCEPTION_') > 0) then
         begin
            l_num := to_number(substr(each.folder_name, 3));
            select A.TASK_NAME, A.TASK_ID, A.ANALYSIS_CYCLE_ID,
               nvl (D.INSTANCE_DESCRIPTION, B.NAME) NAME
               into l_str2, l_taskID, l_acID, l_str
               from ZPB_ANALYSIS_CYCLE_TASKS A,
               ZPB_ANALYSIS_CYCLES B,
               ZPB_TASK_PARAMETERS C,
               ZPB_ANALYSIS_CYCLE_INSTANCES D
               where A.ANALYSIS_CYCLE_ID = B.ANALYSIS_CYCLE_ID
               and B.STATUS_CODE <> 'MARKED_FOR_DELETION'
               and B.BUSINESS_AREA_ID = p_business_area
               and A.ANALYSIS_CYCLE_ID = l_num
               and A.TASK_ID = C.TASK_ID
               and C.NAME = 'QUERY_OBJECT_NAME'
               and C.VALUE = each.object_name
               and A.ANALYSIS_CYCLE_ID = D.INSTANCE_AC_ID(+);

            SELECT value
            INTO l_queryPath
            FROM ZPB_TASK_PARAMETERS
            WHERE name = 'QUERY_OBJECT_PATH'
            AND TASK_ID = l_taskID;

            IF (instr (each.object_name, 'LOAD_DATA') > 0) then
            if(l_rem_def_hier_dim = l_line_dimID) then
                 l_queryErrorType := 'F';
                        REGISTER_ERROR('O', 'W', 'ZPB_BUSAREA_VAL_INV_BP_TASK',
                              'TASK_NAME', l_str2, 'N',
                              'TASK_TYPE', 'ZPB_TASK_NAME_LOAD_DATA_MSG', 'Y',
                              'NAME', l_str, 'N');
            else
                 l_queryErrorType := 'R';
            end if;

            ELSE
                SELECT value
                INTO l_current_dim
                FROM ZPB_TASK_PARAMETERS
                WHERE name = 'EXCEPTION_DIMENSION'
                AND TASK_ID = l_taskID;
                if(l_rem_def_hier_dim = l_current_dim) then
                    l_queryErrorType := 'F';
                    REGISTER_ERROR('O', 'W', 'ZPB_BUSAREA_VAL_INV_BP_TASK',
                              'TASK_NAME', l_str2, 'N',
                              'TASK_TYPE','ZPB_TASK_NAME_EXCEPT_CHECK_MSG','Y',
                              'NAME', l_str, 'N');
                else
                    l_queryErrorType := 'R';
                end if;
            END IF;
            DISABLE_BP(p_business_area , each.object_name, l_queryPath,
                l_queryErrorType, l_acID, p_init_fix);
             EXCEPTION
            WHEN no_data_found THEN
               null; -- Bug 4214272
         END;

      ELSIF (instr (each.object_name, 'CD_SOURCE') > 0) THEN
         FOR each_init_source in l_init_source(each.object_name, p_business_area) loop
            l_memberName := GET_LINE_MEMBER_DESC(each_init_source.MEMBER);
            l_queryErrorType := 'R';
            FOR each_source_dims in
            l_source_dims(each_init_source.MEMBER, each_init_source.ANALYSIS_CYCLE_ID) LOOP
                if(each_source_dims.SOURCE_DIMENSION = l_rem_def_hier_dim) then
                    l_queryErrorType := 'F';
                    REGISTER_ERROR('O', 'W', 'ZPB_BUSAREA_INV_INIT_QUERY',
                               'LINE_ITEM', l_memberName, 'N');
                    exit;
                end if;
            END LOOP;
            DISABLE_BP(p_business_area ,each.object_name,
                    each_init_source.QUERY_PATH, l_queryErrorType,
                    each_init_source.ANALYSIS_CYCLE_ID, p_init_fix);

         END LOOP;

      ELSIF (instr (each.object_name, 'CD_TARGET') > 0) THEN
         FOR each_init_target in l_init_target(each.object_name, p_business_area) loop
            l_memberName := GET_LINE_MEMBER_DESC(each_init_target.MEMBER);
            l_queryErrorType := 'R';
            FOR each_target_dims in
            l_target_dims(each_init_target.MEMBER, each_init_target.ANALYSIS_CYCLE_ID) LOOP
                if(each_target_dims.TARGET_DIM = l_rem_def_hier_dim) then
                    l_queryErrorType := 'F';
                    REGISTER_ERROR('O', 'W', 'ZPB_BUSAREA_INV_INIT_QUERY',
                               'LINE_ITEM', l_memberName, 'N');
                    exit;
                end if;
            END LOOP;
            DISABLE_BP(p_business_area ,each.object_name,
                        each_init_target.QUERY_PATH, l_queryErrorType,
                        each_init_target.ANALYSIS_CYCLE_ID, p_init_fix);
         END LOOP;

       ELSIF (instr (each.object_name, 'TARGET') > 0) then
         FOR each_dc_obj in l_dc_tg_objs(each.object_name, p_business_area) loop
            IF (instr(each.object_name, 'GEN_TEMPL') > 0) then
               l_str := 'ZPB_GENERATE_TEMPL_TASK_TARGET'; -- generate template task target query
             ELSE
               l_str := 'ZPB_TARGET_MASTER'; -- target master query
            END IF;

            if(l_rem_def_hier_dim = l_line_dimID) then
                 l_queryErrorType := 'F';
                 REGISTER_ERROR('O', 'W', 'ZPB_BUSAREA_VAL_INV_QUERY',
                           'QUERY', l_str, 'Y',
                           'NAME', each_dc_obj.TEMPLATE_NAME, 'N');
            else
                 l_queryErrorType := 'R';
            end if;
            DISABLE_BP(p_business_area ,each.object_name,

                       each_dc_obj.TARGET_OBJ_PATH, l_queryErrorType,
                       each_dc_obj.ANALYSIS_CYCLE_ID, p_init_fix);
         END LOOP;

       ELSIF (instr (each.object_name, '_DATA_') > 0) then
         FOR each_dc_obj in l_dc_data_objs(each.object_name, p_business_area) loop
            IF (instr(each.object_name, 'GEN_TEMPL') > 0) then
               l_str := 'ZPB_GENERATE_TEMPL_TASK_DATA'; -- generate template task data query
             ELSE
               l_str := 'ZPB_DATA_MASTER'; -- data master query
            END IF;
            if(l_rem_def_hier_dim = l_line_dimID) then
                 l_queryErrorType := 'F';
                 REGISTER_ERROR('O', 'W', 'ZPB_BUSAREA_VAL_INV_QUERY',
                           'QUERY', l_str, 'Y',
                           'NAME', each_dc_obj.TEMPLATE_NAME, 'N');
            else
                 l_queryErrorType := 'R';
            end if;

            DISABLE_BP(p_business_area ,each.object_name,
                       each_dc_obj.TARGET_OBJ_PATH, l_queryErrorType,
                       each_dc_obj.ANALYSIS_CYCLE_ID,p_init_fix);
         END LOOP;

       ELSIF (instr (each.object_name, 'ReadAccess') > 0) THEN
         l_str := substr(each.object_name, 1,
                         instr(each.object_name, 'ReadAccess')+9);
         SELECT xml
            INTO l_xml
            FROM BISM_OBJECTS
            WHERE OBJECT_NAME = l_str
            AND FOLDER_ID = each.FOLDER_ID;

         l_user_id := to_number(substr(l_str, 1, instr(l_str, '_')-1));

         SELECT USER_NAME
            INTO l_user
            FROM FND_USER
            WHERE USER_ID = l_user_id;

         l_num := instr(l_xml, 'Description="')+13;
         l_str := substr(l_xml, l_num, instr(l_xml, '"', l_num)-l_num);

         REGISTER_ERROR('O', 'W', 'ZPB_BUSAREA_VAL_INV_SEC_RULE',
                        'OBJ_TYPE', 'ZPB_MGR_READACCESS_DESCRIPTION', 'Y',
                        'NAME', l_str, 'N',
                        'USER', l_user, 'N');

         for lock_user in
           l_get_status_sql_id(l_secFoldPath || '/' || each.object_name)
         loop

           LOCK_OUT_USER(p_business_area,
                         l_user_id,
                         each.object_name,
                         l_secFoldPath,
                         G_READ_RULE,
                         l_queryErrorType,
                         p_init_fix,
                         lock_user.status_sql_id);
         end loop;

       ELSIF (instr (each.object_name, 'WriteAccess') > 0) THEN
         l_str := substr(each.object_name, 1,
                         instr(each.object_name, 'WriteAccess')+10);
         SELECT xml
            INTO l_xml
            FROM BISM_OBJECTS
            WHERE OBJECT_NAME = l_str
            AND FOLDER_ID = each.FOLDER_ID;

         l_user_id := to_number(substr(l_str, 1, instr(l_str, '_')-1));

         SELECT USER_NAME
            INTO l_user
            FROM FND_USER
            WHERE USER_ID = l_user_id;

         l_num := instr(l_xml, 'Description="')+13;
         l_str := substr(l_xml, l_num, instr(l_xml, '"', l_num)-l_num);

         REGISTER_ERROR('O', 'W', 'ZPB_BUSAREA_VAL_INV_SEC_RULE',
                        'OBJ_TYPE', 'ZPB_MGR_WRITEACC_DESCRIPTION', 'Y',
                        'NAME', l_str, 'N',
                        'USER', l_user, 'N');

         for lock_user in
           l_get_status_sql_id(l_secFoldPath || '/' || each.object_name)
         loop

           LOCK_OUT_USER(p_business_area,
                         l_user_id,
                         each.object_name,
                         l_secFoldPath,
                         G_WRITE_RULE,
                         l_queryErrorType,
                         p_init_fix,
                         lock_user.status_sql_id);
           end loop;

         ELSIF (instr (each.object_name, 'Ownership') > 0) THEN
         l_str := substr(each.object_name, 1,
                         instr(each.object_name, 'Ownership')+8);
         SELECT xml
            INTO l_xml
            FROM BISM_OBJECTS
            WHERE OBJECT_NAME = l_str
            AND FOLDER_ID = each.FOLDER_ID;

         l_user_id := to_number(substr(l_str, 1, instr(l_str, '_')-1));

         SELECT USER_NAME
            INTO l_user
            FROM FND_USER
            WHERE USER_ID = l_user_id;

         l_num := instr(l_xml, 'Description="')+13;
         l_str := substr(l_xml, l_num, instr(l_xml, '"', l_num)-l_num);

         REGISTER_ERROR('O', 'W', 'ZPB_BUSAREA_VAL_INV_SEC_RULE',
                        'OBJ_TYPE', 'ZPB_MGR_WRITEACC_DESCRIPTION', 'Y',
                        'NAME', l_str, 'N',
                        'USER', l_user, 'N');


         for lock_user in
           l_get_status_sql_id(l_secFoldPath || '/' || each.object_name)
         loop

           LOCK_OUT_USER(p_business_area,
                         l_user_id,
                         each.object_name,
                         l_secFoldPath,
                         G_OWNER_RULE,
                         l_queryErrorType,
                         p_init_fix,
                         lock_user.status_sql_id);
         end loop;

      ELSIF (instr (each.object_name, 'INPUT') > 0) THEN
         FOR each_input_sel in l_input_sel(each.object_name, p_business_area) loop
            IF(l_rem_def_hier_dim = each_input_sel.DIMENSION) then
                l_queryErrorType := 'F';
                REGISTER_ERROR('O', 'W', 'ZPB_BUSAREA_VAL_INV_SOLVE',
                           'NAME', each_input_sel.NAME, 'N');
            else
                l_queryErrorType := 'R';
            end if;
            DISABLE_BP(p_business_area ,each.object_name,
                       each_input_sel.SELECTION_PATH, l_queryErrorType,
                       each_input_sel.ANALYSIS_CYCLE_ID, p_init_fix);
         END LOOP;

      ELSIF (instr (each.object_name, 'OUTPUT') > 0) THEN
         FOR each_output_sel in l_output_sel(each.object_name, p_business_area) loop
            IF(l_rem_def_hier_dim = each_output_sel.DIMENSION) then
                l_queryErrorType := 'F';
                REGISTER_ERROR('O', 'W', 'ZPB_BUSAREA_VAL_INV_SOLVE',
                           'NAME', each_output_sel.NAME, 'N');
            else
                l_queryErrorType := 'R';
            end if;
            DISABLE_BP(p_business_area ,each.object_name,
                       each_output_sel.SELECTION_PATH, l_queryErrorType,
                       each_output_sel.ANALYSIS_CYCLE_ID, p_init_fix);
         END LOOP;

      ELSIF (instr (each.object_name, 'SUM') > 0) THEN
         IF (instr(each.object_name, 'SUM_') > 0) THEN
            FOR each_sum_sel in l_sum_sel2(each.object_name, p_business_area) LOOP
                 SELECT name INTO l_dimName FROM zpb_dimensions_vl
                 WHERE  bus_area_id = p_business_area
                 AND aw_name = each_sum_sel.DIMENSION;

                 l_memberName := GET_LINE_MEMBER_DESC(each_sum_sel.MEMBER);
                IF(l_rem_def_hier_dim = each_sum_sel.DIMENSION) then
                    l_queryErrorType := 'F';
                    REGISTER_ERROR('O', 'W', 'ZPB_BUSAREA_INV_SUM_MEM_QUERY',
                        'DIM_NAME', l_dimName, 'N',
                        'LINE_ITEM', l_memberName, 'N');
                else
                    l_queryErrorType := 'R';
                end if;
                DISABLE_BP(p_business_area ,each.object_name,
                           each_sum_sel.SUM_SELECTION_PATH, l_queryErrorType,
                           each_sum_sel.ANALYSIS_CYCLE_ID, p_init_fix);
             END LOOP;
         ELSE
             FOR each_sum_sel in l_sum_sel1(each.object_name, p_business_area) LOOP
                SELECT name INTO l_dimName FROM zpb_dimensions_vl
                    WHERE  bus_area_id = p_business_area
                    AND aw_name = each_sum_sel.DIMENSION_NAME;
                IF(l_rem_def_hier_dim = each_sum_sel.DIMENSION_NAME) then
                    l_queryErrorType := 'F';
                    REGISTER_ERROR('O', 'W', 'ZPB_BUSAREA_INV_REM_DIM_QUERY',
                        'DIM_NAME', l_dimName, 'N');
                else
                    l_queryErrorType := 'R';
                end if;
                DISABLE_BP(p_business_area ,each.object_name,
                           each_sum_sel.SUM_SELECTION_PATH, l_queryErrorType,
                           each_sum_sel.ANALYSIS_CYCLE_ID, p_init_fix);

             END LOOP;
        END IF;
      END IF;
    EXCEPTION
       WHEN no_data_found THEN
          null;
    END;
   END LOOP;
END FIND_DEF_HIER_IN_REPOS;


-------------------------------------------------------------------------
-- VAL_AGAINST_EPB - Validates the Business Area version against EPB, to
--                   find any places where EPB will be adversely affected
--
-- IN: p_version_id    - The Version ID to validate
--     p_init_fix      - Flag to confirm whether MD fixing should be done fixed or not
--
-------------------------------------------------------------------------
PROCEDURE VAL_AGAINST_EPB (p_version_id    IN    NUMBER,
                           p_init_fix      IN    VARCHAR2 DEFAULT 'N')
   is
      l_proc_name CONSTANT VARCHAR2(33) := G_PKG_NAME||'.val_against_epb';

      l_refr_vers     ZPB_BUSAREA_VERSIONS.VERSION_ID%type;
      l_vers_type     ZPB_BUSAREA_VERSIONS.VERSION_TYPE%type;
      l_ba_id         ZPB_BUSINESS_AREAS.BUSINESS_AREA_ID%type;
      l_aw            ZPB_BUSINESS_AREAS.DATA_AW%type;
      l_name          ZPB_ANALYSIS_CYCLES.NAME%type;
      l_folder        BISM_OBJECTS.FOLDER_ID%type;
      l_num           NUMBER;
      l_id            VARCHAR2(60);
      l_view          VARCHAR2(60);
      l_val           VARCHAR2(300);
      l_codeAW        VARCHAR2(30);
      l_sharedAW            VARCHAR2(30);
      l_tableID  NUMBER;


      -- For Removed dimensions
      cursor l_dims is
         select A.DIMENSION_ID,
                DECODE(nvl(FDR.FUNC_DIM_SET_NAME, '-99'), '-99',
                       C.DIMENSION_NAME,FDR.FUNC_DIM_SET_NAME) AS DIMENSION_NAME,
                A.LOGICAL_DIM_ID
         from ZPB_BUSAREA_DIMENSIONS A,
           FEM_DIMENSIONS_VL C,
           FEM_FUNC_DIM_SETS_VL FDR
         where A.VERSION_ID = l_refr_vers
         and A.DIMENSION_ID = C.DIMENSION_ID
         AND FDR.FUNC_DIM_SET_ID (+) = A.FUNC_DIM_SET_ID
         and A.DIMENSION_ID not in
         (select B.DIMENSION_ID
          from ZPB_BUSAREA_DIMENSIONS B
          where B.VERSION_ID = p_version_id);

      -- For Added dimensions
      cursor l_add_dims is
         select A.DIMENSION_ID
         from ZPB_BUSAREA_DIMENSIONS A,
           FEM_DIMENSIONS_VL C
         where A.VERSION_ID = p_version_id
         and A.DIMENSION_ID = C.DIMENSION_ID
         and A.DIMENSION_ID not in
         (select B.DIMENSION_ID
          from ZPB_BUSAREA_DIMENSIONS B
          where B.VERSION_ID = l_refr_vers);

      cursor l_line_dims is
         select A.DIMENSION_ID,
                DECODE(nvl(FDR.FUNC_DIM_SET_NAME, '-99'), '-99',
                       C.DIMENSION_NAME,FDR.FUNC_DIM_SET_NAME) AS DIMENSION_NAME,
                A.EPB_LINE_DIMENSION,
                A.LOGICAL_DIM_ID
            from ZPB_BUSAREA_DIMENSIONS A,
            ZPB_BUSAREA_DIMENSIONS B,
            FEM_DIMENSIONS_VL C,
            FEM_FUNC_DIM_SETS_VL FDR
            where A.DIMENSION_ID = B.DIMENSION_ID
            and A.DIMENSION_ID = C.DIMENSION_ID
            and A.VERSION_ID = p_version_id
            and A.VERSION_ID = l_refr_vers
            AND FDR.FUNC_DIM_SET_ID (+) = A.FUNC_DIM_SET_ID
            and (A.EPB_LINE_DIMENSION = 'Y' and B.EPB_LINE_DIMENSION = 'N' or
                 A.EPB_LINE_DIMENSION = 'N' and B.EPB_LINE_DIMENSION = 'Y');

      cursor l_hiers is
         select decode (A.CURRENT_VERSION, 'Y', to_char(A.HIERARCHY_ID),
                        A.HIERARCHY_ID||'V'||A.VERSION_ID) HIERARCHY_ID,
            C.OBJECT_NAME,
            E.AW_DIM_PREFIX AS DIMENSION_ID,
            D.DIMENSION_ID FEM_DIMENSION_ID, E.DEFAULT_HIERARCHY_ID,
            E.LOGICAL_DIM_ID,
            nvl(E.FUNC_DIM_SET_ID, -99) AS FUNC_DIM_SET_ID
          from table(ZPB_FEM_UTILS_PKG.GET_BUSAREA_HIERARCHIES(l_ba_id,
                                                               'R')) A,
            FEM_HIERARCHIES D,
            FEM_OBJECT_CATALOG_VL C,
            ZPB_BUSAREA_DIMENSIONS E
         where A.HIERARCHY_ID = C.OBJECT_ID
            and A.HIERARCHY_ID = D.HIERARCHY_OBJ_ID
            and A.LOGICAL_DIM_ID = E.LOGICAL_DIM_ID
            and D.DIMENSION_ID = E.DIMENSION_ID
            and E.VERSION_ID = l_refr_vers
            and decode (A.CURRENT_VERSION, 'Y', to_char(A.HIERARCHY_ID),
                        A.HIERARCHY_ID||'V'||A.VERSION_ID) not in
            (select decode (B.CURRENT_VERSION, 'Y', to_char(B.HIERARCHY_ID),
                            B.HIERARCHY_ID||'V'||B.VERSION_ID) HIERARCHY_ID
             from table(ZPB_FEM_UTILS_PKG.GET_BUSAREA_HIERARCHIES(l_ba_id,
                                                            l_vers_type)) B);
      cursor l_levels is
         select B.LEVEL_ID,
            B.HIERARCHY_ID,
            A.DIMENSION_GROUP_NAME,
            C.AW_DIM_PREFIX AS DIMENSION_ID,
            A.DIMENSION_ID FEM_DIMENSION_ID,
            C.LOGICAL_DIM_ID,
            nvl(C.FUNC_DIM_SET_ID, -99) AS FUNC_DIM_SET_ID
          from FEM_DIMENSION_GRPS_VL A,
            ZPB_BUSAREA_LEVELS B,
            ZPB_BUSAREA_DIMENSIONS C
          where A.DIMENSION_GROUP_ID = B.LEVEL_ID
            and B.VERSION_ID = l_refr_vers
            and C.VERSION_ID = l_refr_vers
            and C.LOGICAL_DIM_ID = B.LOGICAL_DIM_ID
            and C.DIMENSION_ID = A.DIMENSION_ID
            and B.LEVEL_ID not in
            (select C.LEVEL_ID
             from ZPB_BUSAREA_LEVELS C
             where C.VERSION_ID = p_version_id);

      cursor l_datasets is
         select A.DATASET_ID, A.NAME
            from ZPB_BUSAREA_DATASETS_VL A
            where A.VERSION_ID = l_refr_vers
            and A.DATASET_ID not in
            (select B.DATASET_ID
             from ZPB_BUSAREA_DATASETS B
             where B.VERSION_ID = p_version_id);

      cursor l_attrs is
         select A.ATTRIBUTE_ID, C.ATTRIBUTE_NAME,
            D.AW_DIM_PREFIX AS DIMENSION_ID,
            C.DIMENSION_ID FEM_DIMENSION_ID,
            D.LOGICAL_DIM_ID,
            nvl(D.FUNC_DIM_SET_ID, -99) AS FUNC_DIM_SET_ID
         from ZPB_BUSAREA_ATTRIBUTES A,
            FEM_DIM_ATTRIBUTES_VL C,
            ZPB_BUSAREA_DIMENSIONS D
         where A.VERSION_ID = l_refr_vers
            and A.ATTRIBUTE_ID = C.ATTRIBUTE_ID
            and C.DIMENSION_ID = D.DIMENSION_ID
            and A.LOGICAL_DIM_ID = D.LOGICAL_DIM_ID
            and D.VERSION_ID   = l_refr_vers
          and A.ATTRIBUTE_ID not in
          (select B.ATTRIBUTE_ID
           from ZPB_BUSAREA_ATTRIBUTES B
           where B.VERSION_ID = p_version_id);

       cursor l_ac_datasets(p_ba NUMBER, p_dataset NUMBER) is
          select distinct nvl (C.INSTANCE_DESCRIPTION, A.NAME) NAME
           from ZPB_ANALYSIS_CYCLES A, ZPB_CYCLE_DATASETS B,
             ZPB_ANALYSIS_CYCLE_INSTANCES C
           where A.BUSINESS_AREA_ID = p_ba
             and A.STATUS_CODE <> 'MARKED_FOR_DELETION'
             and A.ANALYSIS_CYCLE_ID = B.ANALYSIS_CYCLE_ID
             and B.DATASET_CODE = p_dataset
             and A.ANALYSIS_CYCLE_ID = C.INSTANCE_AC_ID(+);

 begin
   FND_MSG_PUB.INITIALIZE;

   ZPB_LOG.WRITE (l_proc_name||'.begin', 'Begin EPB validation of '||
                  p_version_id);
   begin
       select A.BUSINESS_AREA_ID, A.VERSION_ID, C.DATA_AW, B.VERSION_TYPE
         into l_ba_id, l_refr_vers, l_aw, l_vers_type
         from ZPB_BUSAREA_VERSIONS A,
           ZPB_BUSAREA_VERSIONS B,
           ZPB_BUSINESS_AREAS C
         where A.BUSINESS_AREA_ID = B.BUSINESS_AREA_ID
         and A.VERSION_TYPE = 'R'
         and B.VERSION_ID = p_version_id
         and C.BUSINESS_AREA_ID = A.BUSINESS_AREA_ID;
   exception
      when no_data_found then
         l_refr_vers := null;
   end;


   BEGIN
        l_codeAW   := zpb_aw.get_schema||'.'||zpb_aw.get_code_aw(FND_GLOBAL.USER_ID);
        l_sharedAW := 'ZPB.ZPBDATA'||l_ba_id;
      ATTACH_AWS(l_codeAW, l_sharedAW);

      SELECT SHAR_TABLE_ID INTO l_tableID FROM zpb_dimensions
      WHERE BUS_AREA_ID = l_ba_id
      AND dim_type = 'LINE';

      SELECT table_name INTO G_LINE_DIM_TABLE_NAME FROM zpb_tables
      WHERE TABLE_ID = l_tableID;

      SELECT COLUMN_NAME INTO G_MEMBER_ID_COL FROM ZPB_COLUMNS
      WHERE COLUMN_TYPE = 'MEMBER_COLUMN' AND  TABLE_ID = l_tableID;

      SELECT COLUMN_NAME INTO G_MEMBER_NAME_COL FROM ZPB_COLUMNS
      WHERE COLUMN_TYPE = 'LNAME_COLUMN' AND  TABLE_ID = l_tableID;
   EXCEPTION
      WHEN no_data_found THEN
                null;
   END;


   --
   -- No refreshed version, then nothing to compare to (first time)
   --
   if (l_refr_vers is not null) then
      --
      -- Check for removed datasets in a BP
      --
      for each_dataset in l_datasets loop
         for each_ac in l_ac_datasets(l_ba_id, each_dataset.DATASET_ID) loop
            REGISTER_ERROR ('O', 'W', 'ZPB_BUSAREA_VAL_INV_DATASET',
                            'BP_NAME', each_ac.NAME, 'N',
                            'DATASET', each_dataset.NAME, 'N');
         end loop;
      end loop;
      --
      -- Check for any missing dimensions
      --
      for each_dim in l_dims loop
         REGISTER_ERROR ('S', 'E', 'ZPB_BUSAREA_VAL_INV_REM_DIM',
                         'NAME', each_dim.DIMENSION_NAME, 'N');
         l_refr_vers := null;
      end loop;

      if (l_refr_vers is not null) then
         for each_line_dim in l_line_dims loop
            REGISTER_ERROR ('S', 'E', 'ZPB_BUSAREA_VAL_INV_LINE_DIM',
                            'NAME', each_line_dim.DIMENSION_NAME, 'N');
            l_refr_vers := null;
         end loop;
      end if;
   end if;

   --
   -- IF missing dimensions, no need to validate rest, will result in
   -- many irroneous errors
   --
   if (l_refr_vers is not null) then
      --
      -- If Any Dimension is added, need to refresh all queries
      --
    --For Add Dimension case we need not validate and show warning/error msgs
    --as all query fixing process would only be backend, and unrelated to the user.
    if(p_init_fix = 'Y') then

      IF NOT l_add_dims%ISOPEN THEN
        OPEN l_add_dims;
      END IF;
      FETCH l_add_dims INTO l_num;

      IF l_add_dims%FOUND THEN
         FIND_IN_REPOS(l_ba_id, p_version_id, '%', NULL, NULL, p_init_fix);
      END IF;
    end if;
      --
      -- Hierarchies:
      --
      for each_hier in l_hiers loop
         l_id := each_hier.DIMENSION_ID ||'H_'|| nvl(each_hier.HIERARCHY_ID,0);

         if (each_hier.FUNC_DIM_SET_ID = -99) then
         select DIMENSION_NAME
            into l_val
            from FEM_DIMENSIONS_VL
            where DIMENSION_ID = each_hier.FEM_DIMENSION_ID;
         else
           select FUNC_DIM_SET_NAME
           into l_val
           from FEM_FUNC_DIM_SETS_VL
           where FUNC_DIM_SET_ID = each_hier.FUNC_DIM_SET_ID;
         end if;

         REGISTER_ERROR ('S', 'W', 'ZPB_BUSAREA_VAL_REMOVE_META',
                         'OBJ_TYPE', 'ZPB_HIERARCHY', 'Y',
                         'NAME', each_hier.OBJECT_NAME, 'N',
                         'DIM_NAME', l_val, 'N');

         IF(each_hier.HIERARCHY_ID = each_hier.DEFAULT_HIERARCHY_ID) THEN
             FIND_DEF_HIER_IN_REPOS(l_ba_id, p_version_id, l_id,
                       'DEFAULT_HIERARCHY', each_hier.OBJECT_NAME, p_init_fix);
         ELSE
             FIND_IN_REPOS(l_ba_id, p_version_id, l_id,
                       'HIERARCHY', each_hier.OBJECT_NAME, p_init_fix);
         END IF;
      end loop;

      --
      -- Levels:
      --
      for each_level in l_levels loop
         l_id := each_level.DIMENSION_ID
                ||'H0LV'||nvl(each_level.LEVEL_ID,0);

         if (each_level.FUNC_DIM_SET_ID = -99) then
         select DIMENSION_NAME
            into l_val
            from FEM_DIMENSIONS_VL
            where DIMENSION_ID = each_level.FEM_DIMENSION_ID;
         else
           select FUNC_DIM_SET_NAME
           into l_val
           from FEM_FUNC_DIM_SETS_VL
           where FUNC_DIM_SET_ID = each_level.FUNC_DIM_SET_ID;
         end if;

         REGISTER_ERROR ('S', 'W', 'ZPB_BUSAREA_VAL_REMOVE_META',
                         'OBJ_TYPE', 'ZPB_LEVEL', 'Y',
                         'NAME', each_level.DIMENSION_GROUP_NAME, 'N',
                         'DIM_NAME', l_val, 'N');

         FIND_IN_REPOS(l_ba_id, p_version_id, l_id,
                       'LEVEL', each_level.DIMENSION_GROUP_NAME, p_init_fix);
      end loop;

      --
      -- Attributes:
      --
      for each_attr in l_attrs loop
         l_id := each_attr.DIMENSION_ID || 'A' || nvl(each_attr.ATTRIBUTE_ID,0);

         if (each_attr.FUNC_DIM_SET_ID = -99) then
         select DIMENSION_NAME
            into l_val
            from FEM_DIMENSIONS_VL
            where DIMENSION_ID = each_attr.FEM_DIMENSION_ID;
         else
           select FUNC_DIM_SET_NAME
           into l_val
           from FEM_FUNC_DIM_SETS_VL
           where FUNC_DIM_SET_ID = each_attr.FUNC_DIM_SET_ID;
         end if;

         REGISTER_ERROR ('S', 'W', 'ZPB_BUSAREA_VAL_REMOVE_META',
                         'OBJ_TYPE', 'ZPB_ATTRIBUTE', 'Y',
                         'NAME', each_attr.ATTRIBUTE_NAME, 'N',
                         'DIM_NAME', l_val, 'N');

         FIND_IN_REPOS(l_ba_id, p_version_id, l_id, 'ATTRIBUTE',
                       each_attr.ATTRIBUTE_NAME, p_init_fix);
      end loop;
   end if;
   DETACH_AWS(l_codeAW, l_sharedAW);

   ZPB_LOG.WRITE(l_proc_name||'.end', 'End EPB validation of '||p_version_id);

EXCEPTION
        WHEN OTHERS THEN
           DETACH_AWS(l_codeAW, l_sharedAW);
end VAL_AGAINST_EPB;


END ZPB_BUSAREA_VAL;

/
