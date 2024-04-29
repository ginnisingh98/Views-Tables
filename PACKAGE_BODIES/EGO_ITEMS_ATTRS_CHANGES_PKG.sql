--------------------------------------------------------
--  DDL for Package Body EGO_ITEMS_ATTRS_CHANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_ITEMS_ATTRS_CHANGES_PKG" AS
/* $Header: EGOIUACB.pls 115.1 2004/07/09 05:08:09 srajapar noship $ */

----------------------------------------------------------------------
G_PKG_NAME   CONSTANT  VARCHAR2(50) := 'EGO_ITEMS_ATTRS_CHANGES_PKG';

PROCEDURE code_debug(msg VARCHAR2) IS
BEGIN
--  sri_debug( G_PKG_NAME ||'  '|| msg);
  null;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END code_debug;

PROCEDURE ADD_LANGUAGE
IS
BEGIN
  delete from EGO_ITEMS_ATTRS_CHANGES_TL T
  where not exists
    (select NULL
    from EGO_ITEMS_ATTRS_CHANGES_B B
    where B.EXTENSION_ID = T.EXTENSION_ID
    and B.ACD_TYPE = T.ACD_TYPE
    and B.CHANGE_LINE_ID = T.CHANGE_LINE_ID
    );

  update EGO_ITEMS_ATTRS_CHANGES_TL T set (
      TL_EXT_ATTR1,
      TL_EXT_ATTR2,
      TL_EXT_ATTR3,
      TL_EXT_ATTR4,
      TL_EXT_ATTR5,
      TL_EXT_ATTR6,
      TL_EXT_ATTR7,
      TL_EXT_ATTR8,
      TL_EXT_ATTR9,
      TL_EXT_ATTR10,
      TL_EXT_ATTR11,
      TL_EXT_ATTR12,
      TL_EXT_ATTR13,
      TL_EXT_ATTR14,
      TL_EXT_ATTR15,
      TL_EXT_ATTR16,
      TL_EXT_ATTR17,
      TL_EXT_ATTR18,
      TL_EXT_ATTR19,
      TL_EXT_ATTR20,
      TL_EXT_ATTR21,
      TL_EXT_ATTR22,
      TL_EXT_ATTR23,
      TL_EXT_ATTR24,
      TL_EXT_ATTR25,
      TL_EXT_ATTR26,
      TL_EXT_ATTR27,
      TL_EXT_ATTR28,
      TL_EXT_ATTR29,
      TL_EXT_ATTR30,
      TL_EXT_ATTR31,
      TL_EXT_ATTR32,
      TL_EXT_ATTR33,
      TL_EXT_ATTR34,
      TL_EXT_ATTR35,
      TL_EXT_ATTR36,
      TL_EXT_ATTR37,
      TL_EXT_ATTR38,
      TL_EXT_ATTR39,
      TL_EXT_ATTR40
    ) =
    (select
      B.TL_EXT_ATTR1,
      B.TL_EXT_ATTR2,
      B.TL_EXT_ATTR3,
      B.TL_EXT_ATTR4,
      B.TL_EXT_ATTR5,
      B.TL_EXT_ATTR6,
      B.TL_EXT_ATTR7,
      B.TL_EXT_ATTR8,
      B.TL_EXT_ATTR9,
      B.TL_EXT_ATTR10,
      B.TL_EXT_ATTR11,
      B.TL_EXT_ATTR12,
      B.TL_EXT_ATTR13,
      B.TL_EXT_ATTR14,
      B.TL_EXT_ATTR15,
      B.TL_EXT_ATTR16,
      B.TL_EXT_ATTR17,
      B.TL_EXT_ATTR18,
      B.TL_EXT_ATTR19,
      B.TL_EXT_ATTR20,
      B.TL_EXT_ATTR21,
      B.TL_EXT_ATTR22,
      B.TL_EXT_ATTR23,
      B.TL_EXT_ATTR24,
      B.TL_EXT_ATTR25,
      B.TL_EXT_ATTR26,
      B.TL_EXT_ATTR27,
      B.TL_EXT_ATTR28,
      B.TL_EXT_ATTR29,
      B.TL_EXT_ATTR30,
      B.TL_EXT_ATTR31,
      B.TL_EXT_ATTR32,
      B.TL_EXT_ATTR33,
      B.TL_EXT_ATTR34,
      B.TL_EXT_ATTR35,
      B.TL_EXT_ATTR36,
      B.TL_EXT_ATTR37,
      B.TL_EXT_ATTR38,
      B.TL_EXT_ATTR39,
      B.TL_EXT_ATTR40
    from EGO_ITEMS_ATTRS_CHANGES_TL B
    where B.EXTENSION_ID = T.EXTENSION_ID
    and B.ACD_TYPE = T.ACD_TYPE
    and B.CHANGE_LINE_ID = T.CHANGE_LINE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.EXTENSION_ID,
      T.ACD_TYPE,
      T.CHANGE_LINE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.EXTENSION_ID,
      SUBT.ACD_TYPE,
      SUBT.CHANGE_LINE_ID,
      SUBT.LANGUAGE
    from EGO_ITEMS_ATTRS_CHANGES_TL SUBB, EGO_ITEMS_ATTRS_CHANGES_TL SUBT
    where SUBB.EXTENSION_ID = SUBT.EXTENSION_ID
    and SUBB.ACD_TYPE = SUBT.ACD_TYPE
    and SUBB.CHANGE_LINE_ID = SUBT.CHANGE_LINE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TL_EXT_ATTR1 <> SUBT.TL_EXT_ATTR1
      or (SUBB.TL_EXT_ATTR1 is null and SUBT.TL_EXT_ATTR1 is not null)
      or (SUBB.TL_EXT_ATTR1 is not null and SUBT.TL_EXT_ATTR1 is null)
      or SUBB.TL_EXT_ATTR2 <> SUBT.TL_EXT_ATTR2
      or (SUBB.TL_EXT_ATTR2 is null and SUBT.TL_EXT_ATTR2 is not null)
      or (SUBB.TL_EXT_ATTR2 is not null and SUBT.TL_EXT_ATTR2 is null)
      or SUBB.TL_EXT_ATTR3 <> SUBT.TL_EXT_ATTR3
      or (SUBB.TL_EXT_ATTR3 is null and SUBT.TL_EXT_ATTR3 is not null)
      or (SUBB.TL_EXT_ATTR3 is not null and SUBT.TL_EXT_ATTR3 is null)
      or SUBB.TL_EXT_ATTR4 <> SUBT.TL_EXT_ATTR4
      or (SUBB.TL_EXT_ATTR4 is null and SUBT.TL_EXT_ATTR4 is not null)
      or (SUBB.TL_EXT_ATTR4 is not null and SUBT.TL_EXT_ATTR4 is null)
      or SUBB.TL_EXT_ATTR5 <> SUBT.TL_EXT_ATTR5
      or (SUBB.TL_EXT_ATTR5 is null and SUBT.TL_EXT_ATTR5 is not null)
      or (SUBB.TL_EXT_ATTR5 is not null and SUBT.TL_EXT_ATTR5 is null)
      or SUBB.TL_EXT_ATTR6 <> SUBT.TL_EXT_ATTR6
      or (SUBB.TL_EXT_ATTR6 is null and SUBT.TL_EXT_ATTR6 is not null)
      or (SUBB.TL_EXT_ATTR6 is not null and SUBT.TL_EXT_ATTR6 is null)
      or SUBB.TL_EXT_ATTR7 <> SUBT.TL_EXT_ATTR7
      or (SUBB.TL_EXT_ATTR7 is null and SUBT.TL_EXT_ATTR7 is not null)
      or (SUBB.TL_EXT_ATTR7 is not null and SUBT.TL_EXT_ATTR7 is null)
      or SUBB.TL_EXT_ATTR8 <> SUBT.TL_EXT_ATTR8
      or (SUBB.TL_EXT_ATTR8 is null and SUBT.TL_EXT_ATTR8 is not null)
      or (SUBB.TL_EXT_ATTR8 is not null and SUBT.TL_EXT_ATTR8 is null)
      or SUBB.TL_EXT_ATTR9 <> SUBT.TL_EXT_ATTR9
      or (SUBB.TL_EXT_ATTR9 is null and SUBT.TL_EXT_ATTR9 is not null)
      or (SUBB.TL_EXT_ATTR9 is not null and SUBT.TL_EXT_ATTR9 is null)
      or SUBB.TL_EXT_ATTR10 <> SUBT.TL_EXT_ATTR10
      or (SUBB.TL_EXT_ATTR10 is null and SUBT.TL_EXT_ATTR10 is not null)
      or (SUBB.TL_EXT_ATTR10 is not null and SUBT.TL_EXT_ATTR10 is null)
      or SUBB.TL_EXT_ATTR11 <> SUBT.TL_EXT_ATTR11
      or (SUBB.TL_EXT_ATTR11 is null and SUBT.TL_EXT_ATTR11 is not null)
      or (SUBB.TL_EXT_ATTR11 is not null and SUBT.TL_EXT_ATTR11 is null)
      or SUBB.TL_EXT_ATTR12 <> SUBT.TL_EXT_ATTR12
      or (SUBB.TL_EXT_ATTR12 is null and SUBT.TL_EXT_ATTR12 is not null)
      or (SUBB.TL_EXT_ATTR12 is not null and SUBT.TL_EXT_ATTR12 is null)
      or SUBB.TL_EXT_ATTR13 <> SUBT.TL_EXT_ATTR13
      or (SUBB.TL_EXT_ATTR13 is null and SUBT.TL_EXT_ATTR13 is not null)
      or (SUBB.TL_EXT_ATTR13 is not null and SUBT.TL_EXT_ATTR13 is null)
      or SUBB.TL_EXT_ATTR14 <> SUBT.TL_EXT_ATTR14
      or (SUBB.TL_EXT_ATTR14 is null and SUBT.TL_EXT_ATTR14 is not null)
      or (SUBB.TL_EXT_ATTR14 is not null and SUBT.TL_EXT_ATTR14 is null)
      or SUBB.TL_EXT_ATTR15 <> SUBT.TL_EXT_ATTR15
      or (SUBB.TL_EXT_ATTR15 is null and SUBT.TL_EXT_ATTR15 is not null)
      or (SUBB.TL_EXT_ATTR15 is not null and SUBT.TL_EXT_ATTR15 is null)
      or SUBB.TL_EXT_ATTR16 <> SUBT.TL_EXT_ATTR16
      or (SUBB.TL_EXT_ATTR16 is null and SUBT.TL_EXT_ATTR16 is not null)
      or (SUBB.TL_EXT_ATTR16 is not null and SUBT.TL_EXT_ATTR16 is null)
      or SUBB.TL_EXT_ATTR17 <> SUBT.TL_EXT_ATTR17
      or (SUBB.TL_EXT_ATTR17 is null and SUBT.TL_EXT_ATTR17 is not null)
      or (SUBB.TL_EXT_ATTR17 is not null and SUBT.TL_EXT_ATTR17 is null)
      or SUBB.TL_EXT_ATTR18 <> SUBT.TL_EXT_ATTR18
      or (SUBB.TL_EXT_ATTR18 is null and SUBT.TL_EXT_ATTR18 is not null)
      or (SUBB.TL_EXT_ATTR18 is not null and SUBT.TL_EXT_ATTR18 is null)
      or SUBB.TL_EXT_ATTR19 <> SUBT.TL_EXT_ATTR19
      or (SUBB.TL_EXT_ATTR19 is null and SUBT.TL_EXT_ATTR19 is not null)
      or (SUBB.TL_EXT_ATTR19 is not null and SUBT.TL_EXT_ATTR19 is null)
      or SUBB.TL_EXT_ATTR20 <> SUBT.TL_EXT_ATTR20
      or (SUBB.TL_EXT_ATTR20 is null and SUBT.TL_EXT_ATTR20 is not null)
      or (SUBB.TL_EXT_ATTR20 is not null and SUBT.TL_EXT_ATTR20 is null)
      or SUBB.TL_EXT_ATTR21 <> SUBT.TL_EXT_ATTR21
      or (SUBB.TL_EXT_ATTR21 is null and SUBT.TL_EXT_ATTR21 is not null)
      or (SUBB.TL_EXT_ATTR21 is not null and SUBT.TL_EXT_ATTR21 is null)
      or SUBB.TL_EXT_ATTR22 <> SUBT.TL_EXT_ATTR22
      or (SUBB.TL_EXT_ATTR22 is null and SUBT.TL_EXT_ATTR22 is not null)
      or (SUBB.TL_EXT_ATTR22 is not null and SUBT.TL_EXT_ATTR22 is null)
      or SUBB.TL_EXT_ATTR23 <> SUBT.TL_EXT_ATTR23
      or (SUBB.TL_EXT_ATTR23 is null and SUBT.TL_EXT_ATTR23 is not null)
      or (SUBB.TL_EXT_ATTR23 is not null and SUBT.TL_EXT_ATTR23 is null)
      or SUBB.TL_EXT_ATTR24 <> SUBT.TL_EXT_ATTR24
      or (SUBB.TL_EXT_ATTR24 is null and SUBT.TL_EXT_ATTR24 is not null)
      or (SUBB.TL_EXT_ATTR24 is not null and SUBT.TL_EXT_ATTR24 is null)
      or SUBB.TL_EXT_ATTR25 <> SUBT.TL_EXT_ATTR25
      or (SUBB.TL_EXT_ATTR25 is null and SUBT.TL_EXT_ATTR25 is not null)
      or (SUBB.TL_EXT_ATTR25 is not null and SUBT.TL_EXT_ATTR25 is null)
      or SUBB.TL_EXT_ATTR26 <> SUBT.TL_EXT_ATTR26
      or (SUBB.TL_EXT_ATTR26 is null and SUBT.TL_EXT_ATTR26 is not null)
      or (SUBB.TL_EXT_ATTR26 is not null and SUBT.TL_EXT_ATTR26 is null)
      or SUBB.TL_EXT_ATTR27 <> SUBT.TL_EXT_ATTR27
      or (SUBB.TL_EXT_ATTR27 is null and SUBT.TL_EXT_ATTR27 is not null)
      or (SUBB.TL_EXT_ATTR27 is not null and SUBT.TL_EXT_ATTR27 is null)
      or SUBB.TL_EXT_ATTR28 <> SUBT.TL_EXT_ATTR28
      or (SUBB.TL_EXT_ATTR28 is null and SUBT.TL_EXT_ATTR28 is not null)
      or (SUBB.TL_EXT_ATTR28 is not null and SUBT.TL_EXT_ATTR28 is null)
      or SUBB.TL_EXT_ATTR29 <> SUBT.TL_EXT_ATTR29
      or (SUBB.TL_EXT_ATTR29 is null and SUBT.TL_EXT_ATTR29 is not null)
      or (SUBB.TL_EXT_ATTR29 is not null and SUBT.TL_EXT_ATTR29 is null)
      or SUBB.TL_EXT_ATTR30 <> SUBT.TL_EXT_ATTR30
      or (SUBB.TL_EXT_ATTR30 is null and SUBT.TL_EXT_ATTR30 is not null)
      or (SUBB.TL_EXT_ATTR30 is not null and SUBT.TL_EXT_ATTR30 is null)
      or SUBB.TL_EXT_ATTR31 <> SUBT.TL_EXT_ATTR31
      or (SUBB.TL_EXT_ATTR31 is null and SUBT.TL_EXT_ATTR31 is not null)
      or (SUBB.TL_EXT_ATTR31 is not null and SUBT.TL_EXT_ATTR31 is null)
      or SUBB.TL_EXT_ATTR32 <> SUBT.TL_EXT_ATTR32
      or (SUBB.TL_EXT_ATTR32 is null and SUBT.TL_EXT_ATTR32 is not null)
      or (SUBB.TL_EXT_ATTR32 is not null and SUBT.TL_EXT_ATTR32 is null)
      or SUBB.TL_EXT_ATTR33 <> SUBT.TL_EXT_ATTR33
      or (SUBB.TL_EXT_ATTR33 is null and SUBT.TL_EXT_ATTR33 is not null)
      or (SUBB.TL_EXT_ATTR33 is not null and SUBT.TL_EXT_ATTR33 is null)
      or SUBB.TL_EXT_ATTR34 <> SUBT.TL_EXT_ATTR34
      or (SUBB.TL_EXT_ATTR34 is null and SUBT.TL_EXT_ATTR34 is not null)
      or (SUBB.TL_EXT_ATTR34 is not null and SUBT.TL_EXT_ATTR34 is null)
      or SUBB.TL_EXT_ATTR35 <> SUBT.TL_EXT_ATTR35
      or (SUBB.TL_EXT_ATTR35 is null and SUBT.TL_EXT_ATTR35 is not null)
      or (SUBB.TL_EXT_ATTR35 is not null and SUBT.TL_EXT_ATTR35 is null)
      or SUBB.TL_EXT_ATTR36 <> SUBT.TL_EXT_ATTR36
      or (SUBB.TL_EXT_ATTR36 is null and SUBT.TL_EXT_ATTR36 is not null)
      or (SUBB.TL_EXT_ATTR36 is not null and SUBT.TL_EXT_ATTR36 is null)
      or SUBB.TL_EXT_ATTR37 <> SUBT.TL_EXT_ATTR37
      or (SUBB.TL_EXT_ATTR37 is null and SUBT.TL_EXT_ATTR37 is not null)
      or (SUBB.TL_EXT_ATTR37 is not null and SUBT.TL_EXT_ATTR37 is null)
      or SUBB.TL_EXT_ATTR38 <> SUBT.TL_EXT_ATTR38
      or (SUBB.TL_EXT_ATTR38 is null and SUBT.TL_EXT_ATTR38 is not null)
      or (SUBB.TL_EXT_ATTR38 is not null and SUBT.TL_EXT_ATTR38 is null)
      or SUBB.TL_EXT_ATTR39 <> SUBT.TL_EXT_ATTR39
      or (SUBB.TL_EXT_ATTR39 is null and SUBT.TL_EXT_ATTR39 is not null)
      or (SUBB.TL_EXT_ATTR39 is not null and SUBT.TL_EXT_ATTR39 is null)
      or SUBB.TL_EXT_ATTR40 <> SUBT.TL_EXT_ATTR40
      or (SUBB.TL_EXT_ATTR40 is null and SUBT.TL_EXT_ATTR40 is not null)
      or (SUBB.TL_EXT_ATTR40 is not null and SUBT.TL_EXT_ATTR40 is null)
  ));

  insert into EGO_ITEMS_ATTRS_CHANGES_TL (
    TL_EXT_ATTR23,
    TL_EXT_ATTR24,
    TL_EXT_ATTR25,
    TL_EXT_ATTR26,
    TL_EXT_ATTR27,
    TL_EXT_ATTR28,
    TL_EXT_ATTR29,
    TL_EXT_ATTR30,
    TL_EXT_ATTR31,
    TL_EXT_ATTR32,
    TL_EXT_ATTR33,
    TL_EXT_ATTR34,
    TL_EXT_ATTR35,
    TL_EXT_ATTR36,
    TL_EXT_ATTR37,
    TL_EXT_ATTR38,
    TL_EXT_ATTR39,
    TL_EXT_ATTR40,
    EXTENSION_ID,
    ORGANIZATION_ID,
    INVENTORY_ITEM_ID,
    REVISION_ID,
    ITEM_CATALOG_GROUP_ID,
    ATTR_GROUP_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    ACD_TYPE,
    CHANGE_ID,
    CHANGE_LINE_ID,
    IMPLEMENTATION_DATE,
    TL_EXT_ATTR1,
    TL_EXT_ATTR2,
    TL_EXT_ATTR3,
    TL_EXT_ATTR4,
    TL_EXT_ATTR5,
    TL_EXT_ATTR6,
    TL_EXT_ATTR7,
    TL_EXT_ATTR8,
    TL_EXT_ATTR9,
    TL_EXT_ATTR10,
    TL_EXT_ATTR11,
    TL_EXT_ATTR12,
    TL_EXT_ATTR13,
    TL_EXT_ATTR14,
    TL_EXT_ATTR15,
    TL_EXT_ATTR16,
    TL_EXT_ATTR17,
    TL_EXT_ATTR18,
    TL_EXT_ATTR19,
    TL_EXT_ATTR20,
    TL_EXT_ATTR21,
    TL_EXT_ATTR22,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.TL_EXT_ATTR23,
    B.TL_EXT_ATTR24,
    B.TL_EXT_ATTR25,
    B.TL_EXT_ATTR26,
    B.TL_EXT_ATTR27,
    B.TL_EXT_ATTR28,
    B.TL_EXT_ATTR29,
    B.TL_EXT_ATTR30,
    B.TL_EXT_ATTR31,
    B.TL_EXT_ATTR32,
    B.TL_EXT_ATTR33,
    B.TL_EXT_ATTR34,
    B.TL_EXT_ATTR35,
    B.TL_EXT_ATTR36,
    B.TL_EXT_ATTR37,
    B.TL_EXT_ATTR38,
    B.TL_EXT_ATTR39,
    B.TL_EXT_ATTR40,
    B.EXTENSION_ID,
    B.ORGANIZATION_ID,
    B.INVENTORY_ITEM_ID,
    B.REVISION_ID,
    B.ITEM_CATALOG_GROUP_ID,
    B.ATTR_GROUP_ID,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.ACD_TYPE,
    B.CHANGE_ID,
    B.CHANGE_LINE_ID,
    B.IMPLEMENTATION_DATE,
    B.TL_EXT_ATTR1,
    B.TL_EXT_ATTR2,
    B.TL_EXT_ATTR3,
    B.TL_EXT_ATTR4,
    B.TL_EXT_ATTR5,
    B.TL_EXT_ATTR6,
    B.TL_EXT_ATTR7,
    B.TL_EXT_ATTR8,
    B.TL_EXT_ATTR9,
    B.TL_EXT_ATTR10,
    B.TL_EXT_ATTR11,
    B.TL_EXT_ATTR12,
    B.TL_EXT_ATTR13,
    B.TL_EXT_ATTR14,
    B.TL_EXT_ATTR15,
    B.TL_EXT_ATTR16,
    B.TL_EXT_ATTR17,
    B.TL_EXT_ATTR18,
    B.TL_EXT_ATTR19,
    B.TL_EXT_ATTR20,
    B.TL_EXT_ATTR21,
    B.TL_EXT_ATTR22,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from EGO_ITEMS_ATTRS_CHANGES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from EGO_ITEMS_ATTRS_CHANGES_TL T
    where T.EXTENSION_ID = B.EXTENSION_ID
    and T.ACD_TYPE = B.ACD_TYPE
    and T.CHANGE_LINE_ID = B.CHANGE_LINE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
END ADD_LANGUAGE;

----------------------------------------------------------------------
  PROCEDURE Deleting_Obj_Pending_Changes
  (p_api_version        IN  NUMBER
  ,p_object_name        IN  VARCHAR2
  ,p_instance_pk1_value IN  VARCHAR2
  ,p_instance_pk2_value IN  VARCHAR2
  ,p_instance_pk3_value IN  VARCHAR2
  ,p_instance_pk4_value IN  VARCHAR2
  ,p_instance_pk5_value IN  VARCHAR2
  ,p_change_id          IN  NUMBER
  ,p_change_line_id     IN  NUMBER
  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2
  ) IS
  ----------------------------------------------------------------------------
  -- Start of Comments
  -- API name  : Deleting_Pending_Changes
  -- TYPE      : Public
  -- Pre-reqs  : None
  -- FUNCTION  : Delete the pending changes from EGO_ITEMS_ATTRS_CHANGES_B
  --
  -- Parameters:
  --     IN    : p_api_version           NUMBER
  --           : p_object_name           VARCHAR2
  --           : p_instance_pk1_value    VARCHAR2
  --           : p_instance_pk2_value    VARCHAR2
  --           : p_instance_pk3_value    VARCHAR2
  --           : p_instance_pk4_value    VARCHAR2
  --           : p_instance_pk5_value    VARCHAR2
  --           : p_change_id             NUMBER
  --           : p_change_line_id        NUMBER
  --
  --    OUT    : x_return_status    VARCHAR2
  --             x_msg_count        NUMBER
  --             x_msg_data         VARCHAR2
  --
  ----------------------------------------------------------------------------
  l_api_version    NUMBER;
  l_api_name       VARCHAR2(50);

  l_object_row       FND_OBJECTS%ROWTYPE;
  l_delete_table_b   tab.tname%TYPE;
  l_delete_table_tl  tab.tname%TYPE;

  l_dynamic_sql        VARCHAR2(4000);
  l_dynamic_sql_b   VARCHAR2(4000);
  l_dynamic_sql_tl     VARCHAR2(4000);

  CURSOR get_obj_row (cp_object_name IN VARCHAR2) IS
  SELECT *
  FROM fnd_objects
  WHERE obj_name = cp_object_name;

  BEGIN
    code_debug(' Start ');
    code_debug(' params  p_object_name ' ||p_object_name||' p_change_id '||p_change_id||' p_change_line_id '||p_change_line_id);
    code_debug(' params  p_instance_pk1_value ' ||p_instance_pk1_value||' p_instance_pk2_value '||p_instance_pk2_value||' p_instance_pk3_value '||p_instance_pk3_value);
    l_api_version    := 1.0;
    l_api_name       := 'DELETE_OBJ_PENDING_CHANGES';
    x_return_status  := FND_API.G_RET_STS_ERROR;
    l_dynamic_sql_b  := NULL;
    l_dynamic_sql_tl := NULL;
    -- standard check for API validation
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)  THEN
      code_debug(' Invalid Params Passed ');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF  ( p_object_name IS NULL
       OR
         (p_change_line_id IS NULL AND p_change_id IS NULL)
        ) THEN
      -- what are you planning to delete?
      fnd_message.set_name('EGO', 'EGO_IPI_INSUFFICIENT_PARAMS');
      fnd_message.set_token('PROG_NAME', G_PKG_NAME||'.'||l_api_name);
      x_msg_data    := fnd_message.get;
      x_msg_count   := 1;
      code_debug(x_msg_data );
      RETURN;
    END IF;

    OPEN  get_obj_row (cp_object_name => p_object_name);
    FETCH get_obj_row INTO l_object_row;
    IF get_obj_row%NOTFOUND THEN
      CLOSE get_obj_row;
      x_msg_count := 1;
      x_msg_data  := 'Invalid Object passed '||p_object_name;
      RETURN;
    ELSE
      CLOSE get_obj_row;
    END IF;

    IF l_object_row.obj_name IN ('EGO_ITEM', 'EGO_ITEM_REVISION') THEN
      l_delete_table_b  := 'EGO_ITEMS_ATTRS_CHANGES_B';
      l_delete_table_tl := 'EGO_ITEMS_ATTRS_CHANGES_TL';
      IF p_change_id IS NULL THEN
        IF p_change_line_id IS NULL THEN
          -- you will never come here
          l_dynamic_sql := ' WHERE 1 = 1 ';
        ELSE
          l_dynamic_sql := ' WHERE change_line_id = '||p_change_line_id;
        END IF;
      ELSE
        l_dynamic_sql := ' WHERE change_id = '||p_change_id;
        IF p_change_id IS NULL THEN
          -- do nothing
          NULL;
        ELSE
          l_dynamic_sql := l_dynamic_sql || ' AND change_line_id = '||p_change_line_id;
        END IF;
      END IF;
    ELSE
      -- todo
      -- other objects not yet considered
      x_msg_count := 1;
      x_msg_data  := 'Contact EXTFWK dev team to include your object case';
      code_debug(' Invalid obj type '||x_msg_data);
      RETURN;
    END IF;

    IF (p_instance_pk1_value IS NOT NULL
        OR
        p_instance_pk2_value IS NOT NULL
        OR
        p_instance_pk3_value IS NOT NULL
        OR
        p_instance_pk4_value IS NOT NULL
        OR
        p_instance_pk5_value IS NOT NULL
       ) THEN
      code_debug(' Binding Pk Values ');
      --
      -- assumed that the delete table column names are same as that primary column names.
      --
      IF p_instance_pk1_value IS NOT NULL THEN
         l_dynamic_sql := l_dynamic_sql ||' AND '||l_object_row.pk1_column_name||' IS NULL';
      ELSE
         l_dynamic_sql := l_dynamic_sql ||' AND '||l_object_row.pk1_column_name||' = ' ||p_instance_pk1_value;
      END IF;
      IF l_object_row.pk2_column_name IS NOT NULL THEN
        IF p_instance_pk2_value IS NULL THEN
           l_dynamic_sql := l_dynamic_sql ||' AND '||l_object_row.pk2_column_name||' IS NULL';
        ELSE
           l_dynamic_sql := l_dynamic_sql ||' AND '||l_object_row.pk2_column_name||' = ' ||p_instance_pk2_value;
        END IF;
      END IF;
      IF l_object_row.pk3_column_name IS NOT NULL THEN
        IF p_instance_pk3_value IS NULL THEN
           l_dynamic_sql := l_dynamic_sql ||' AND '||l_object_row.pk3_column_name||' IS NULL';
        ELSE
           l_dynamic_sql := l_dynamic_sql ||' AND '||l_object_row.pk3_column_name||' = ' ||p_instance_pk3_value;
        END IF;
      END IF;
      IF l_object_row.pk4_column_name IS NOT NULL THEN
        IF p_instance_pk4_value IS NULL THEN
           l_dynamic_sql := l_dynamic_sql ||' AND '||l_object_row.pk4_column_name||' IS NULL';
        ELSE
           l_dynamic_sql := l_dynamic_sql ||' AND '||l_object_row.pk4_column_name||' = ' ||p_instance_pk4_value;
        END IF;
      END IF;
      IF l_object_row.pk5_column_name IS NOT NULL THEN
        IF p_instance_pk5_value IS NULL THEN
           l_dynamic_sql := l_dynamic_sql ||' AND '||l_object_row.pk5_column_name||' IS NULL';
        ELSE
           l_dynamic_sql := l_dynamic_sql ||' AND '||l_object_row.pk5_column_name||' = ' ||p_instance_pk5_value;
        END IF;
      END IF;
    END IF;

    l_dynamic_sql_tl := 'DELETE '||l_delete_table_tl||l_dynamic_sql;
    code_debug(' Deleting from the TL table ');
    EXECUTE IMMEDIATE l_dynamic_sql_tl;
    l_dynamic_sql_b := 'DELETE '||l_delete_table_b||l_dynamic_sql;
    code_debug(' Deleting from the base table ');
    EXECUTE IMMEDIATE l_dynamic_sql_b;
    x_return_status  := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      code_debug( 'EXCEPTION why this ');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      code_debug( 'EXCEPTION others ');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_message.set_name('EGO', 'EGO_PLSQL_ERR');
      fnd_message.set_token('PKG_NAME', G_PKG_NAME);
      fnd_message.set_token('API_NAME', l_api_name);
      fnd_message.set_token('SQL_ERR_MSG', SQLERRM);
      x_msg_data     := fnd_message.get;
      x_msg_count     := 1;
END Deleting_Obj_Pending_Changes;
----------------------------------------------------------------------


END EGO_ITEMS_ATTRS_CHANGES_PKG;


/
