--------------------------------------------------------
--  DDL for Package Body EGO_TEMPL_ATTRS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_TEMPL_ATTRS_PUB" AS
/* $Header: EGOTMPLB.pls 120.7.12010000.2 2009/06/10 09:47:24 ccsingh ship $ */

                ------------------------------------
                -- Global Variables and Constants --
                ------------------------------------

  G_PKG_NAME        CONSTANT VARCHAR2(30) := 'EGO_TEMPL_ATTRS_PUB';
  G_CURRENT_USER_ID          NUMBER;
  G_CURRENT_LOGIN_ID         NUMBER;

  -- For use with error-reporting --
  G_ADD_ERRORS_TO_FND_STACK  CONSTANT VARCHAR2(1) := 'Y';
  G_DUMMY_ENTITY_INDEX       NUMBER;
  G_DUMMY_ENTITY_ID          VARCHAR2(50);
  G_DUMMY_MESSAGE_TYPE       VARCHAR2(1);

----------------------
--  Set Globals
----------------------
PROCEDURE SetGlobals IS
BEGIN
  G_CURRENT_USER_ID    := FND_GLOBAL.User_Id;
  G_CURRENT_LOGIN_ID   := FND_GLOBAL.Login_Id;
END;

------------------------
-- Private Procedures --
------------------------

------------------------------------------------------------------------------
--
-- DESCRIPTION
--   Gets the data level ID for the given attribute group
--
-- AUTHOR
--   ssarnoba
--
-- RELEASE
--   R12C
--
-- NOTES
--   (-) For items coming from MTL_SYSTEM_ITEMS, the data level is always ITEM_ORG
--   (-) For attribute groups attached to items coming from MTL_SYSTEM_ITEMS, the
--       attribute group type is always EGO_MASTER_ITEMS

-------------------------------------------------------------------------------
Procedure Get_Data_Level_ID (
  p_attribute_group_id  IN         ego_obj_ag_assocs_b.attr_group_id %TYPE,
                                                                      -- NUMBER
  p_data_level_name     IN         ego_data_level_b.data_level_name  %TYPE
                                     := 'ITEM_ORG',                 -- VARCHAR2
  p_attr_group_type     IN         ego_data_level_b.attr_group_type  %TYPE
                                     := 'EGO_MASTER_ITEMS',         -- VARCHAR2
  p_application_id      IN         ego_data_level_b.application_id   %TYPE
                                     := 431,                          -- NUMBER
  x_data_level_id       OUT NOCOPY ego_data_level_b.data_level_id    %TYPE);
                                                                      -- NUMBER

------------------------------------------------------------------------------
--
--  DESCRIPTION
--    Gets the Attribute Group ID and Attribute ID for the named attribute
--
--  AUTHOR
--    ssarnoba
--
--  RELEASE
--    R12C
--
------------------------------------------------------------------------------
Procedure Get_Attr_Group_And_Attr_ID (
  p_attr_name           IN           ego_attrs_v.attr_name             %TYPE,
                                                                -- VARCHAR2(30)
  p_attr_group_type     IN           ego_data_level_b.attr_group_type  %TYPE
                                       := 'EGO_MASTER_ITEMS',       -- VARCHAR2
  p_application_id      IN           ego_data_level_b.application_id   %TYPE
                                       := 431,                        -- NUMBER
  x_attr_group_id       OUT  NOCOPY  ego_obj_ag_assocs_b.attr_group_id %TYPE,
                                                                      -- NUMBER
  x_attr_id             OUT  NOCOPY  ego_attrs_v.attr_id               %TYPE);
                                                                  -- NUMBER(15)

                 ---------------------------------
                 -- Private Debugging Procedure --
                 ---------------------------------

/* ----------------------------------------------------------------------
 * The following procedure is for debugging purposes.  Its functionality is
 * controlled by the global variable G_DEBUG_OUTPUT_LEVEL, whose values are:
 *
 * 3: LONG debug messages
 * 2: MEDIUM debug messages
 * 1: SHORT debug messages
 * 0: NO debug messages
 *
 * The procedure will only print messages at the specified level or lower.
 * When logging messages, specify their debug level or let it default to 3.
 *(You will also have to call "set serveroutput on" to see the output.)
 * ---------------------------------------------------------------------- */

PROCEDURE Debug_Msg (
        p_message                       IN   VARCHAR2
       ,p_level_of_debug                IN   NUMBER       DEFAULT 3
)
IS

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
null;
-- dbms_output.put_line('EGOTMPLB - ' || p_message);
END Debug_Msg;

----------------------------------------------------------------
--Sync_Template is a procedure provided to sync up all operational attributes
--associated with the template
--in mtl_item_templ_attributes with ego_templ_attributes
--parameters:
--  p_attribute_name is the full attribute name in mtl_item_templ_attributes
----------------------------------------------------------------

Procedure Sync_Template( p_template_id     IN NUMBER,
                         p_commit          IN VARCHAR2 := FND_API.G_FALSE,
                         x_return_status  OUT NOCOPY VARCHAR2,
                         x_message_text   OUT NOCOPY VARCHAR2
                       )
IS

  r_templ_attribute   template_attribute_rec_type;
  e_sync_exception    EXCEPTION  ;
  l_api_name          VARCHAR2(30) := 'SYNC_TEMPLATE';
  l_always_insert     VARCHAR2(1);

  CURSOR c_templ_attributes IS
    SELECT
      EXT.attr_id,
      FL_CTX_EXT.attr_group_id,
      EXT.application_column_name,
      EXT.descriptive_flex_context_code as attr_group_name,
      ITA.template_id,
      ITA.enabled_flag,
      --ITA.attribute_name, --Bug8558929
      Decode (ITA.attribute_name,'MTL_SYSTEM_ITEMS.PRIMARY_UOM_CODE','MTL_SYSTEM_ITEMS.PRIMARY_UNIT_OF_MEASURE', ITA.attribute_name) AS attribute_name, --Bug8558929
      ITA.attribute_value
    FROM
      EGO_FND_DF_COL_USGS_EXT EXT,
      EGO_FND_DSC_FLX_CTX_EXT FL_CTX_EXT,
      MTL_ITEM_TEMPL_ATTRIBUTES ITA
    WHERE
      EXT.descriptive_flex_context_code = FL_CTX_EXT.descriptive_flex_context_code and
      EXT.application_id = FL_CTX_EXT.application_id     and
      EXT.descriptive_flexfield_name = FL_CTX_EXT.descriptive_flexfield_name    and
      EXT.descriptive_flexfield_name = 'EGO_MASTER_ITEMS'    and
      ITA.attribute_name = 'MTL_SYSTEM_ITEMS.'|| decode(EXT.application_column_name,'PRIMARY_UNIT_OF_MEASURE','PRIMARY_UOM_CODE',EXT.application_column_name) and --Bug8558929
      ITA.template_id = p_template_id;

BEGIN

  Debug_Msg('Sync_Template: BEGIN');

  BEGIN
    SELECT 'F' INTO l_always_insert
    FROM ego_templ_attributes
    WHERE template_id = p_template_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_always_insert := 'T';
    WHEN OTHERS THEN
      l_always_insert := 'F';
  END;

  -- sync up each attribute associated to the template
  FOR r_templ_attribute IN c_templ_attributes LOOP
    Debug_Msg('Sync_Template: Syncing ' || r_templ_attribute.attribute_name);

    Sync_Template_Attribute(
                             r_templ_attribute.template_id,
                             r_templ_attribute.attribute_name,
                             r_templ_attribute.attribute_value,
                             r_templ_attribute.enabled_flag,
                             p_commit,
                             r_templ_attribute.attr_id,
                             r_templ_attribute.attr_group_id,
                             x_return_status,
                             x_message_text,
                             l_always_insert
                           );
    IF( x_return_status <> 'S' ) THEN
      raise e_sync_exception;
    END IF;
  END LOOP;

  EXCEPTION
    WHEN e_sync_exception THEN
      rollback;

    WHEN OTHERS THEN
      x_return_status := 'U';
      x_message_text := 'Unexpected error syncing data';
      Debug_Msg(l_api_name || x_message_text);
      rollback;

END Sync_Template;

----------------------------------------------------------------
--Sync_Template_Attribute is a procedure provided to sync up operational attribute
--values in mtl_item_templ_attributes with ego_templ_attributes
--parameters:
--  p_attribute_name is the full attribute name in mtl_item_templ_attributes
----------------------------------------------------------------

Procedure Sync_Template_Attribute
      ( p_template_id       IN NUMBER,
        p_attribute_name    IN VARCHAR2,
        p_attribute_value   IN VARCHAR2,
        p_enabled_flag      IN VARCHAR2,
        p_commit            IN VARCHAR2 :=  FND_API.G_FALSE,
        p_ego_attr_id       IN NUMBER ,
        p_ego_attr_group_id IN NUMBER ,
        x_return_status     OUT NOCOPY VARCHAR2,
        x_message_text      OUT NOCOPY VARCHAR2,
        p_always_insert     IN VARCHAR2 := FND_API.G_FALSE
      )
IS

  --5101284 : Perf issues
  CURSOR c_check_template_attribute(cp_template_id    NUMBER
                                   ,cp_attribute_name VARCHAR2) IS
     SELECT 1
     FROM   fnd_descr_flex_column_usages fl_col ,
            ego_fnd_df_col_usgs_ext ext,
            ego_templ_attributes eta
     WHERE ext.application_id                 = fl_col.application_id
       AND ext.descriptive_flexfield_name     = fl_col.descriptive_flexfield_name
       AND ext.descriptive_flex_context_code  = fl_col.descriptive_flex_context_code
       AND ext.application_column_name        = fl_col.application_column_name
       AND fl_col.descriptive_flexfield_name  = 'EGO_MASTER_ITEMS'
       AND eta.attribute_id                   = ext.attr_id
       AND 'MTL_SYSTEM_ITEMS.'||fl_col.application_column_name = cp_attribute_name
       AND eta.template_id                    = cp_template_id
       AND rownum                             = 1;

  l_exists                NUMBER;
  r_inv_templ_attribute   mtl_item_templ_attributes%ROWTYPE;
  l_api_name              VARCHAR2(30) := 'SYNC_TEMPLATE_ATTRIBUTE-9: ';
  l_insert                VARCHAR2(1);
  l_attribute_group_id    NUMBER;
  l_data_level_name       VARCHAR2(30);
  l_data_level_id         NUMBER;
  l_attribute_id          ego_attrs_v.attr_id%TYPE;               -- NUMBER(15)
BEGIN

  Debug_Msg(l_api_name || 'BEGIN');
  Debug_Msg(l_api_name || 'Syncing template ' || p_template_id ||
           ' for attribute ' || p_attribute_name);

  ----------------------------------------------------------------------------
  -- Get the attribute ID and the attribute group ID for the attribute      --
  -- whose name is specified by p_attribute_name                            --
  ----------------------------------------------------------------------------

  Get_Attr_Group_And_Attr_ID (
      p_attr_name               => p_attribute_name
    , x_attr_group_id           => l_attribute_group_id
    , x_attr_id                 => l_attribute_id          -- we never use this
  );

  ----------------------------------------------------------------------------
  -- Get the Data Level ID at which this attribute group applies to the     --
  -- item. This will become the data level at which the template values     --
  -- apply for the attribute group too.                                     --
  ----------------------------------------------------------------------------

  Get_Data_Level_ID (
    p_attribute_group_id  => l_attribute_group_id,
    x_data_level_id       => l_data_level_id
  );

  Debug_Msg(l_api_name || 'Data level ID is ' || l_data_level_id);

  ----------------------------------------------------------------------------
  --         Determine whether an INSERT or UPDATE is required              --
  ----------------------------------------------------------------------------

  IF FND_API.TO_BOOLEAN(p_always_insert) THEN
    l_insert  := p_always_insert;
  ELSE
    --5101284 : Perf issues
    OPEN  c_check_template_attribute(p_template_id,p_attribute_name);
    FETCH c_check_template_attribute INTO l_exists;
    CLOSE c_check_template_attribute;
    /*--5101284 : Perf issues
      BEGIN
      SELECT
        1 into l_exists
      FROM
        dual
      WHERE
         exists  (  select    attr_id    from ego_templ_attributes eta, ego_attrs_v av
                    where 'MTL_SYSTEM_ITEMS.'||av.database_column = p_attribute_name
                    and    eta.attribute_id = av.attr_id
                    and     av.attr_group_type = 'EGO_MASTER_ITEMS'
                    and      template_id = p_template_id);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_exists := 0;
      WHEN OTHERS THEN
        l_exists := 0;
    END;
    */

    l_exists := NVL(l_exists,0);
    IF( l_exists = 0 ) THEN
      l_insert  := FND_API.G_TRUE;
    ELSE
      l_insert := FND_API.G_FALSE;
    END IF;
  END IF;

  ----------------------------------------------------------------------------
  --           Carry out the necessary DML operation                        --
  ----------------------------------------------------------------------------

  IF FND_API.TO_BOOLEAN(l_insert) THEN
    Insert_Template_Attribute( p_template_id,
                               p_ego_attr_group_id,
                               p_ego_attr_id,
                               l_data_level_id,
                               p_enabled_flag,
                               p_attribute_value,
                               p_commit,
                               x_return_status,
                               x_message_text
                             );
  ELSE
    -- update the row in ego_templ_attributes for this attribute
    Update_Template_Attribute( p_template_id,
                               p_ego_attr_group_id,
                               p_ego_attr_id,
                               l_data_level_id,
                               p_enabled_flag,
                               p_attribute_value,
                               p_commit,
                               x_return_status,
                               x_message_text
                             );
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := 'U';
      x_message_text := 'Unexpected error syncing data';
      Debug_Msg(l_api_name || x_message_text);
      rollback;
END Sync_Template_Attribute;

----------------------------------------------------------------
--Sync_Template_Attribute is a procedure provided to sync up operational attribute
--values in mtl_item_templ_attributes with ego_templ_attributes
--parameters:
--  p_attribute_name is the full attribute name in mtl_item_templ_attributes
----------------------------------------------------------------

Procedure Sync_Template_Attribute
  ( p_template_id      IN NUMBER,
    p_attribute_name   IN VARCHAR2,
    p_commit           IN   VARCHAR2   :=  FND_API.G_FALSE,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_message_text     OUT NOCOPY VARCHAR2,
    p_always_insert     IN VARCHAR2 := FND_API.G_FALSE
  )
IS

  --5101284 : Perf issues
  CURSOR c_check_template_attribute(cp_template_id    NUMBER
                                   ,cp_attribute_name VARCHAR2) IS
     SELECT 1
     FROM   fnd_descr_flex_column_usages fl_col ,
            ego_fnd_df_col_usgs_ext ext,
            ego_templ_attributes eta
     WHERE ext.application_id                 = fl_col.application_id
       AND ext.descriptive_flexfield_name     = fl_col.descriptive_flexfield_name
       AND ext.descriptive_flex_context_code  = fl_col.descriptive_flex_context_code
       AND ext.application_column_name        = fl_col.application_column_name
       AND fl_col.descriptive_flexfield_name  = 'EGO_MASTER_ITEMS'
       AND eta.attribute_id                   = ext.attr_id
       AND 'MTL_SYSTEM_ITEMS.'||fl_col.application_column_name = decode(cp_attribute_name,'MTL_SYSTEM_ITEMS.PRIMARY_UOM_CODE','MTL_SYSTEM_ITEMS.PRIMARY_UNIT_OF_MEASURE',cp_attribute_name)-- bug8558929
       AND eta.template_id                    = cp_template_id
       AND rownum                             = 1;

  l_exists NUMBER;
  r_inv_templ_attribute     mtl_item_templ_attributes%ROWTYPE;
  l_attribute_group_id      NUMBER;
  l_attribute_id            NUMBER;
  l_insert                  VARCHAR2(1);
  l_data_level_id           NUMBER;
  l_data_level_name         VARCHAR2(30);
  l_api_name                VARCHAR2(30) := 'SYNC_TEMPLATE_ATTRIBUTE: ';

BEGIN

  Debug_Msg(l_api_name || 'BEGIN');
  Debug_Msg(l_api_name || 'Syncing template ' || p_template_id ||
           ' for attribute ' || p_attribute_name);

  ----------------------------------------------------------------------------
  --    Collect the template data relevant to the specified attribute       --
  ----------------------------------------------------------------------------

  Debug_Msg(l_api_name || 'About to collect template data for attribute');

  SELECT *
  INTO  r_inv_templ_attribute
  FROM  mtl_item_templ_attributes mta
  WHERE mta.ATTRIBUTE_NAME = p_attribute_name
  AND   mta.template_id    = p_template_id;

  Debug_Msg(l_api_name || 'Collected template data for attribute');

  ----------------------------------------------------------------------------
  -- Get the attribute ID and the attribute group ID for the attribute      --
  -- whose name is specified by p_attribute_name                            --
  ----------------------------------------------------------------------------

  Get_Attr_Group_And_Attr_ID (
      p_attr_name               => p_attribute_name
    , x_attr_group_id           => l_attribute_group_id
    , x_attr_id                 => l_attribute_id
  );

  ----------------------------------------------------------------------------
  -- Get the Data Level ID at which this attribute group applies to the     --
  -- item. This will become the data level at which the template values     --
  -- apply for the attribute group too.                                     --
  ----------------------------------------------------------------------------

  Get_Data_Level_ID (
    p_attribute_group_id  => l_attribute_group_id,
    x_data_level_id       => l_data_level_id);

  ----------------------------------------------------------------------------
  --         Determine whether an INSERT or UPDATE is required              --
  ----------------------------------------------------------------------------

  IF( l_attribute_id IS NOT null AND l_attribute_group_id IS NOT null ) THEN

    IF FND_API.TO_BOOLEAN(p_always_insert) THEN
      l_insert  := p_always_insert;
    ELSE
      --5101284 : Perf issues
      OPEN  c_check_template_attribute(p_template_id,p_attribute_name);
      FETCH c_check_template_attribute INTO l_exists;
      CLOSE c_check_template_attribute;
      /*--5101284 : Perf issues
      BEGIN
        SELECT
          1 into l_exists
        FROM
          dual
        WHERE
           exists  (  select    attr_id    from ego_templ_attributes eta, ego_attrs_v av
                      where 'MTL_SYSTEM_ITEMS.'||av.database_column = p_attribute_name
                      and   eta.attribute_id = av.attr_id
                      and   av.attr_group_type = 'EGO_MASTER_ITEMS'
                      and   template_id = p_template_id);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_exists := 0;
        WHEN OTHERS THEN
          l_exists := 0;
      END;
      */
      l_exists := NVL(l_exists,0);
      IF( l_exists = 0 ) THEN
        l_insert  := FND_API.G_TRUE;
      ELSE
        l_insert := FND_API.G_FALSE;
      END IF;
    END IF;

    --------------------------------------------------------------------------
    --           Carry out the necessary DML operation                      --
    --------------------------------------------------------------------------

    IF FND_API.TO_BOOLEAN(l_insert) THEN
      Debug_Msg(l_api_name || 'Performing insert.');
      Insert_Template_Attribute( r_inv_templ_attribute.template_id,
                                 l_attribute_group_id,
                                 l_attribute_id,
                                 l_data_level_id,
                                 r_inv_templ_attribute.enabled_flag,
                                 r_inv_templ_attribute.attribute_value,
                                 p_commit,
                                 x_return_status,
                                 x_message_text
                               );

    ELSE
      Debug_Msg(l_api_name || 'Performing update.');

      -- update the row in ego_templ_attributes for this attribute
      Update_Template_Attribute( r_inv_templ_attribute.template_id,
                                 l_attribute_group_id,
                                 l_attribute_id,
                                 l_data_level_id,
                                 r_inv_templ_attribute.enabled_flag,
                                 r_inv_templ_attribute.attribute_value,
                                 p_commit,
                                 x_return_status,
                                 x_message_text
                               );
    END IF;
  END IF; -- if attribute is defined as base attribute

  Debug_Msg(l_api_name || 'Return status from DML operation: ' || x_return_status );

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := 'U';
      x_message_text := 'Unexpected error syncing data';
      Debug_Msg(l_api_name || x_message_text);
      rollback;

END Sync_Template_Attribute;

---------------------------------------
--  Insert_Template_Attribute
---------------------------------------
Procedure Insert_Template_Attribute
      ( p_template_id         IN NUMBER,
        p_attribute_group_id  IN NUMBER,
        p_attribute_id        IN NUMBER,
        p_data_level_id       IN NUMBER,
        p_enabled_flag        IN VARCHAR2,
        p_attribute_value     IN VARCHAR2,
        p_commit              IN VARCHAR2   :=  FND_API.G_FALSE,
        x_return_status       OUT NOCOPY VARCHAR2,
        x_message_text        OUT NOCOPY VARCHAR2
      )
IS
    l_row_num               NUMBER;
    l_attr_string_value     VARCHAR2(150);
    l_attr_date_value       DATE;
    l_attr_number_value     NUMBER;
    l_attr_translated_value VARCHAR2(1000);
    l_classification_code   VARCHAR2(150);
    l_data_type_code        VARCHAR2(1);
    e_data_type_missing     EXCEPTION;
    l_api_name              VARCHAR2(50) := 'INSERT_TEMPLATE_ATTRIBUTE';

BEGIN

    SetGlobals();
    -- all base attribute groups have single row attributes
    l_row_num := 1;

    -- having classification_code = -1 will mark all operational attribute groups in EGO_TEMPL_ATTRIBUTES
    l_classification_code := '-1';

    -- get data type code
    select eav.data_type_code into l_data_type_code
    from ego_attrs_v eav
    where attr_id = p_attribute_id;

    IF( l_data_type_code = G_CHAR_DATA_TYPE ) THEN
      l_attr_string_value := p_attribute_value;
    ELSIF( l_data_type_code = G_NUMBER_DATA_TYPE ) THEN
      -- convert attribute value to number
      select to_number(p_attribute_value) into l_attr_number_value from dual;
    ELSIF( l_data_type_code = G_DATE_DATA_TYPE  ) THEN
      -- convert attribute value to date
      select to_date(p_attribute_value, 'DD/MM/YYYY') into l_attr_date_value from dual;
    ELSIF( l_data_type_code = G_DATE_TIME_DATA_TYPE ) THEN
      -- convert attribute value to date time
      select to_date(p_attribute_value, 'DD/MM/YYYY HH:MM:SS AM') into l_attr_date_value from dual;
    ELSIF( l_data_type_code = G_TRANS_TEXT_DATA_TYPE ) THEN
      l_attr_translated_value := p_attribute_value;
    ELSE
      RAISE e_data_type_missing;
    END IF;

    insert into ego_templ_attributes(template_id,
                                     attribute_group_id,
                                     attribute_id,
                                     enabled_flag,
                                     last_update_date,
                                     last_updated_by,
                                     creation_date,
                                     created_by,
                                     row_number,
                                     attribute_string_value,
                                     attribute_date_value,
                                     attribute_number_value,
                                     attribute_translated_value,
                                     classification_code,
                                     data_level_id
                                    )
    values( p_template_id,
            p_attribute_group_id,
            p_attribute_id,
            p_enabled_flag,
            sysdate,
            g_current_user_id,
            sysdate,
            g_current_user_id,
            l_row_num,
            l_attr_string_value,
            l_attr_date_value,
            l_attr_number_value,
            l_attr_translated_value,
            l_classification_code,
            p_data_level_id
          );

     x_return_status := 'S';
    IF( p_commit = fnd_api.g_TRUE ) THEN
      commit;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := 'U';
      x_message_text := 'Failure to insert new row for template attribute';
      rollback;
END Insert_Template_Attribute;

---------------------------------------
--  Update_Template_Attribute
---------------------------------------
Procedure Update_Template_Attribute
      ( p_template_id           IN NUMBER,
        p_attribute_group_id    IN NUMBER,
        p_attribute_id          IN NUMBER,
        p_data_level_id         IN NUMBER,
        p_enabled_flag          IN VARCHAR2,
        p_attribute_value       IN VARCHAR2,
        p_commit                IN VARCHAR2   :=  FND_API.G_FALSE,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_message_text          OUT NOCOPY VARCHAR2
      )
IS

    l_attr_string_value     VARCHAR2(150);
    l_attr_date_value       DATE;
    l_attr_number_value     NUMBER;
    l_attr_translated_value VARCHAR2(1000);
    l_data_type_code        VARCHAR2(1);

    e_data_type_missing     EXCEPTION;
    l_api_name              VARCHAR2(50) := 'UPDATE_TEMPLATE_ATTRIBUTE';

BEGIN

    Debug_Msg(l_api_name || '  p_template_id               => ' || p_template_id);
    Debug_Msg(l_api_name || '  p_attribute_group_id        => ' || p_attribute_group_id);
    Debug_Msg(l_api_name || '  p_attribute_id              => ' || p_attribute_id);
    Debug_Msg(l_api_name || '  p_data_level_id             => ' || p_data_level_id);
    Debug_Msg(l_api_name || '  p_enabled_flag              => ' || p_enabled_flag);
    Debug_Msg(l_api_name || '  p_attribute_value           => ' || p_attribute_value);
    Debug_Msg(l_api_name || '  p_commit                    => ' || p_commit);

    SetGlobals();
    -- get data type code
    select eav.data_type_code into l_data_type_code
    from ego_attrs_v eav
    where attr_id = p_attribute_id;

    IF( l_data_type_code = G_CHAR_DATA_TYPE ) THEN
      l_attr_string_value := p_attribute_value;

    ELSIF( l_data_type_code = G_NUMBER_DATA_TYPE ) THEN
      -- convert attribute value to number
      select to_number(p_attribute_value) into l_attr_number_value from dual;

    ELSIF( l_data_type_code = G_DATE_DATA_TYPE  ) THEN
      -- convert attribute value to date
      select to_date(p_attribute_value, 'DD/MM/YYYY') into l_attr_date_value from dual;

    ELSIF(  l_data_type_code = G_DATE_TIME_DATA_TYPE ) THEN
      select to_date(p_attribute_value, 'DD/MM/YYYY HH:MM:SS AM') into l_attr_date_value from dual;

    ELSIF( l_data_type_code = G_TRANS_TEXT_DATA_TYPE ) THEN
      l_attr_translated_value := p_attribute_value;

    ELSE
      RAISE e_data_type_missing;
    END IF;

    update ego_templ_attributes
    set attribute_string_value     = l_attr_string_value,
        attribute_number_value     = l_attr_number_value,
        attribute_date_value       = l_attr_date_value,
        attribute_translated_value = l_attr_translated_value,
        enabled_flag               = p_enabled_flag,
        created_by                 = g_current_user_id,
        creation_date              = sysdate,
        last_updated_by            = g_current_user_id,
        last_update_date           = sysdate,
        last_update_login          = g_current_login_id,
        data_level_id              = p_data_level_id
    where classification_code = '-1'
    and attribute_id = p_attribute_id
    and attribute_group_id = p_attribute_group_id
    and template_id = p_template_id;

    x_return_status := 'S';

    IF( p_commit = fnd_api.g_TRUE ) THEN
      commit;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := 'U';
      x_message_text := 'Failure to update EGO_TEMPL_ATTRIBUTES';
      rollback;

END Update_Template_Attribute;

------------------------------------------------------------------------------
--
-- DESCRIPTION
--   Gets the data level ID for the given attribute group
--
-- AUTHOR
--   ssarnoba
--
-- RELEASE
--   R12C
--
-- NOTES
--   (-) For items coming from MTL_SYSTEM_ITEMS, the data level is always ITEM_ORG
--   (-) For attribute groups attached to items coming from MTL_SYSTEM_ITEMS, the
--       attribute group type is always EGO_MASTER_ITEMS

-------------------------------------------------------------------------------
Procedure Get_Data_Level_ID (
  p_attribute_group_id  IN         ego_obj_ag_assocs_b.attr_group_id %TYPE,
                                                                      -- NUMBER
  p_data_level_name     IN         ego_data_level_b.data_level_name  %TYPE,
                                                                    -- VARCHAR2
  p_attr_group_type     IN         ego_data_level_b.attr_group_type  %TYPE,
                                                                    -- VARCHAR2
  p_application_id      IN         ego_data_level_b.application_id   %TYPE,
                                                                      -- NUMBER
  x_data_level_id       OUT NOCOPY ego_data_level_b.data_level_id    %TYPE)
                                                                      -- NUMBER
IS
  l_api_name                VARCHAR2(30) := 'Get_Data_Level_ID: ';

BEGIN

  Debug_Msg(l_api_name || '  p_attribute_group_id  => ' || p_attribute_group_id);
  Debug_Msg(l_api_name || '  p_data_level_name     => ' || p_data_level_name);
  Debug_Msg(l_api_name || '  p_attr_group_type     => ' || p_attr_group_type);
  Debug_Msg(l_api_name || '  p_application_id      => ' || p_application_id);

  SELECT data_level_id
  INTO   x_data_level_id
  FROM   ego_data_level_b
  WHERE  application_id  = p_application_id  AND
         attr_group_type = p_attr_group_type AND
         data_level_name = p_data_level_name;

END Get_Data_Level_ID;


------------------------------------------------------------------------------
--
--  DESCRIPTION
--    Gets the Attribute Group ID and Attribute ID for the named attribute
--
--  AUTHOR
--    ssarnoba
--
--  RELEASE
--    R12C
--
------------------------------------------------------------------------------
Procedure Get_Attr_Group_And_Attr_ID (
  p_attr_name           IN          ego_attrs_v.attr_name             %TYPE,
                                                                -- VARCHAR2(30)
  p_attr_group_type     IN          ego_data_level_b.attr_group_type  %TYPE,
                                                                    -- VARCHAR2
  p_application_id      IN          ego_data_level_b.application_id   %TYPE,
                                                                      -- NUMBER
  x_attr_group_id       OUT NOCOPY  ego_obj_ag_assocs_b.attr_group_id %TYPE,
                                                                      -- NUMBER
  x_attr_id             OUT NOCOPY  ego_attrs_v.attr_id               %TYPE)
                                                                  -- NUMBER(15)
IS
  l_api_name            VARCHAR2(30) := 'Get_Attr_Group_And_Attr_ID: ';
BEGIN

  Debug_Msg(l_api_name || '  p_attr_name                => ' || p_attr_name);
  Debug_Msg(l_api_name || '  p_attr_group_type          => ' || p_attr_group_type);
  Debug_Msg(l_api_name || '  p_application_id           => ' || p_application_id);

  SELECT eav.attr_id, eagv.attr_group_id
  INTO   x_attr_id, x_attr_group_id
  FROM   ego_attrs_v eav, ego_attr_groups_v eagv
  WHERE  'MTL_SYSTEM_ITEMS.'||eav.database_column = Decode (p_attr_name,'MTL_SYSTEM_ITEMS.PRIMARY_UOM_CODE','MTL_SYSTEM_ITEMS.PRIMARY_UNIT_OF_MEASURE',p_attr_name) --bug8558929
  AND    eav.attr_group_type                      = eagv.attr_group_type
  AND    eav.attr_group_name                      = eagv.attr_group_name
  AND    eav.application_id                       = p_application_id
                                 -- This filtering is added to Supply the Index
                            -- and thus eliminating full table scan Bug 4926750
  AND    eav.application_id                       = eagv.application_id
  AND    eav.attr_group_type                      = p_attr_group_type;

  Debug_Msg(l_api_name || 'Attribute Group ID is ' || x_attr_group_id);
  Debug_Msg(l_api_name || 'Attribute ID is ' || x_attr_id);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_attr_id       := null;
      x_attr_group_id := null;
      Debug_Msg(l_api_name || 'ERROR - NO DATA FOUND' );
    WHEN OTHERS THEN
      x_attr_id := null;
      x_attr_group_id := null;
      Debug_Msg(l_api_name || 'ERROR' );
END Get_Attr_Group_And_Attr_ID;


END EGO_TEMPL_ATTRS_PUB;

/
