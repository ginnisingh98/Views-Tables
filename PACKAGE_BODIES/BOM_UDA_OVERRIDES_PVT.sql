--------------------------------------------------------
--  DDL for Package Body BOM_UDA_OVERRIDES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_UDA_OVERRIDES_PVT" AS
/* $Header: BOMVATOB.pls 120.0.12010000.4 2009/08/14 22:02:25 trudave noship $ */


PROCEDURE Copy_Comp_UDA_Overrides (p_old_comp_seq NUMBER, p_new_comp_seq NUMBER) IS

x_return_status VARCHAR2(240);
udab_new_base_rec    BOM_COMPONENTS_EXT_B%ROWTYPE;
udat_rec             BOM_COMPONENTS_EXT_TL%ROWTYPE;
ctx_rec              BOM_COMP_ATTR_CTX_ASSOCS_B%ROWTYPE;
new_ctx_rec          BOM_COMP_ATTR_CTX_ASSOCS_B%ROWTYPE;
l_new_ovr_b_ext_rec  BOM_COMPONENTS_EXT_B%ROWTYPE;
l_new_ovr_tl_ext_rec BOM_COMPONENTS_EXT_TL%ROWTYPE;
TYPE l_ext_b_tbl     IS TABLE OF BOM_COMPONENTS_EXT_B%ROWTYPE INDEX BY BINARY_INTEGER;
TYPE l_ext_tl_tbl    IS TABLE OF BOM_COMPONENTS_EXT_TL%ROWTYPE INDEX BY BINARY_INTEGER;
TYPE l_ct_tbl        IS TABLE OF BOM_COMP_ATTR_CTX_ASSOCS_B%ROWTYPE INDEX BY BINARY_INTEGER;
l_new_ovr_b_ext_tbl  l_ext_b_tbl;
l_new_ovr_tl_ext_tbl l_ext_tl_tbl;
l_new_ctx_tbl        l_ct_tbl;
l_ag_metadata_obj    EGO_ATTR_GROUP_METADATA_OBJ;

l_new_ctx_id               NUMBER;
l_old_ovr_ext_id           NUMBER;
l_new_ext_id               NUMBER;
l_data_level_id_comp       NUMBER;
l_data_level_id_comp_ovr   NUMBER;
l_data_level_name_comp     VARCHAR2(30) := 'COMPONENTS_LEVEL';
l_data_level_name_comp_ovr VARCHAR2(30) := 'COMPONENTS_OVR_LEVEL';
l_user_id                  NUMBER       := FND_GLOBAL.user_id;
l_login_id                 NUMBER       := FND_GLOBAL.login_id;
l_extension_id             NUMBER;
l_dynamic_sql              VARCHAR2(32767);
l_dynamic_sql_uk           VARCHAR2(32767);
l_uk_attrs_count           NUMBER       := 0;
l_uk_attrs_counter         NUMBER       := 0;
l_table_index              NUMBER       := 0;
l_db_col_name              VARCHAR2(30);
l_extension_id_multi       NUMBER;

CURSOR C_DATA_LEVEL(p_data_level_name VARCHAR2) IS
  SELECT DATA_LEVEL_ID
    FROM EGO_DATA_LEVEL_B
   WHERE DATA_LEVEL_NAME = p_data_level_name;

CURSOR C_FROM_CTX_ROWS (p_comp_seq NUMBER) IS
  SELECT *
    FROM BOM_COMP_ATTR_CTX_ASSOCS_B
   WHERE COMPONENT_SEQUENCE_ID = p_comp_seq;

CURSOR C_NEW_BASE_ROW (p_bill_seq_id NUMBER, p_comp_seq_id NUMBER, p_attr_grp_id NUMBER) IS
  SELECT *
    FROM BOM_COMPONENTS_EXT_B
   WHERE BILL_SEQUENCE_ID = p_bill_seq_id
     AND COMPONENT_SEQUENCE_ID = p_comp_seq_id
     AND ATTR_GROUP_ID = p_attr_grp_id
     AND DATA_LEVEL_ID = l_data_level_id_comp
     AND CONTEXT_ID IS NULL;

CURSOR C_NEW_BASE_ROW_MULTI (p_extension_id NUMBER) IS
  SELECT *
    FROM BOM_COMPONENTS_EXT_B
   WHERE EXTENSION_ID = p_extension_id;

CURSOR C_OVR_B_ROWS (p_extension_id NUMBER) IS
  SELECT *
    FROM BOM_COMPONENTS_EXT_B
   WHERE EXTENSION_ID = p_extension_id
     AND DATA_LEVEL_ID = l_data_level_id_comp_ovr
     AND CONTEXT_ID IS NOT NULL;

CURSOR C_OVR_TL_ROWS (p_extension_id NUMBER) IS
  SELECT *
    FROM BOM_COMPONENTS_EXT_TL
   WHERE EXTENSION_ID = p_extension_id
     AND DATA_LEVEL_ID = l_data_level_id_comp_ovr
     AND CONTEXT_ID IS NOT NULL;

BEGIN

  --Step 1: Get all rows for this component from context table
  --Step 2: For each row in ctx, find row in ext table with BillSeq+AG from Cursor and CompSeq=NewCompSeq
  --Step 2.1: If AG is single row, then only one base row found
  --Step 2.2: If AG is multi row, then need to find the row with correct unique key
  --Step 3: Create a new Ctx Id from Sequence
  --Step 4: Copy override row from OvrExt(step1) of cursor, to a create a new row OvrExt' with new Ctx Id from step 3
  --Step 5: Copy row in cursor, and set baseExt=NewCompBaseExtId (step 2) and ovrExt = OvrExt' (Step 4)

  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  FOR c_comp_level IN C_DATA_LEVEL(l_data_level_name_comp) LOOP
    l_data_level_id_comp := c_comp_level.DATA_LEVEL_ID;
  END LOOP;

  FOR c_comp_level IN C_DATA_LEVEL(l_data_level_name_comp_ovr) LOOP
    l_data_level_id_comp_ovr := c_comp_level.DATA_LEVEL_ID;
  END LOOP;

  ctx_rec := null;
  FOR c_ctx_rec IN C_FROM_CTX_ROWS(p_old_comp_seq) LOOP
    ctx_rec := null;
    ctx_rec := c_ctx_rec ;

    --get the AG type
    l_ag_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Get_Attr_Group_Metadata(p_attr_group_id=>c_ctx_rec.ATTR_GROUP_ID);

    --If ag is single row, then only one row is found, which is desired row
    IF(l_ag_metadata_obj.MULTI_ROW_CODE = 'N') THEN
      FOR c_base_row IN C_NEW_BASE_ROW(ctx_rec.BILL_SEQUENCE_ID, p_new_comp_seq, ctx_rec.ATTR_GROUP_ID) LOOP --should be only one row
        udab_new_base_rec := c_base_row;  --new base row
      END LOOP;
    END IF;


    --If ag is multi row, then multiple rows may be present for ag, we need to filter with correct primary key
    IF(l_ag_metadata_obj.MULTI_ROW_CODE = 'Y') THEN
      --generate the common sql
      l_dynamic_sql := ' SELECT NEW.EXTENSION_ID ' ||
                       '   FROM BOM_COMPONENTS_EXT_B NEW, BOM_COMPONENTS_EXT_B OLD ' ||
                       '  WHERE OLD.EXTENSION_ID = :1 ' ||
                       '    AND NEW.BILL_SEQUENCE_ID = OLD.BILL_SEQUENCE_ID ' ||
                       '    AND NEW.ATTR_GROUP_ID = OLD.ATTR_GROUP_ID ' ||
                       '    AND NEW.COMPONENT_SEQUENCE_ID = :2 ' ||
                       '    AND NEW.DATA_LEVEL_ID = :3 ' ||
                       '    AND NEW.CONTEXT_ID IS NULL ' ;

      --now generate uk specific clause
      l_uk_attrs_count   := l_ag_metadata_obj.UNIQUE_KEY_ATTRS_COUNT;
      l_table_index      := l_ag_metadata_obj.attr_metadata_table.FIRST;
      l_uk_attrs_counter := 0;
      WHILE (l_table_index <= l_ag_metadata_obj.attr_metadata_table.LAST)
      LOOP
        EXIT WHEN (l_uk_attrs_counter = l_uk_attrs_count);
        -------------------------------------------------
        -- If we find a UK Attr, add it to our query   --
        -------------------------------------------------
        IF (l_ag_metadata_obj.attr_metadata_table(l_table_index).UNIQUE_KEY_FLAG = 'Y') THEN
          l_db_col_name := l_ag_metadata_obj.attr_metadata_table(l_table_index).DATABASE_COLUMN;
          l_dynamic_sql := l_dynamic_sql || ' AND NEW.' || l_db_col_name || ' = OLD.'|| l_db_col_name;
          l_uk_attrs_counter := l_uk_attrs_counter + 1;
        END IF;
        l_table_index := l_ag_metadata_obj.attr_metadata_table.NEXT(l_table_index);
      END LOOP;

      EXECUTE IMMEDIATE l_dynamic_sql
         INTO l_extension_id_multi
        USING ctx_rec.BASE_EXTENSION_ID, p_new_comp_seq, l_data_level_id_comp;

      --now we have the extension id for new base row, populate pl/sql record with this row
      FOR c_base_row IN C_NEW_BASE_ROW_MULTI(l_extension_id_multi) LOOP
        udab_new_base_rec := c_base_row;  --new base row
      END LOOP;

    END IF;


--    FOR c_base_row IN C_NEW_BASE_ROW(ctx_rec.BILL_SEQUENCE_ID, p_new_comp_seq, ctx_rec.ATTR_GROUP_ID) LOOP --should be only one row
--      udab_new_base_rec := c_base_row;  --new base row

      -- Fix for Bug: 8784328
      -- commented following declaration and replaced it with following SELECT statement
      -- l_new_ctx_id := BOM_COMP_ATTR_CTX_ASSOCS_B_S.NEXTVAL;

      SELECT BOM_COMP_ATTR_CTX_ASSOCS_B_S.NEXTVAL
      INTO l_new_ctx_id
      FROM dual;

      FOR c_ovr_b_row IN C_OVR_B_ROWS(ctx_rec.EXTENSION_ID) LOOP --should be only one row

        -- Fix for Bug: 8784328
        -- commented following declaration and replaced it with following SELECT statement

        -- l_new_ext_id := EGO_EXTFWK_S.NEXTVAL;

        SELECT EGO_EXTFWK_S.NEXTVAL
        INTO l_new_ext_id
        FROM dual;

        l_new_ovr_b_ext_rec                       := c_ovr_b_row;
        l_new_ovr_b_ext_rec.EXTENSION_ID          := l_new_ext_id;
        l_new_ovr_b_ext_rec.COMPONENT_SEQUENCE_ID := p_new_comp_seq;
        l_new_ovr_b_ext_rec.CONTEXT_ID            := l_new_ctx_id;
        l_new_ovr_b_ext_rec.DATA_LEVEL_ID         := l_data_level_id_comp_ovr;
        l_new_ovr_b_ext_rec.CREATION_DATE         := sysdate;
	    l_new_ovr_b_ext_rec.CREATED_BY            := l_user_id;
        l_new_ovr_b_ext_rec.LAST_UPDATE_DATE      := sysdate;
	    l_new_ovr_b_ext_rec.LAST_UPDATED_BY       := l_user_id;
        l_new_ovr_b_ext_rec.LAST_UPDATE_LOGIN     := l_login_id;

	    l_new_ovr_b_ext_tbl(1) := l_new_ovr_b_ext_rec;

        FORALL i in l_new_ovr_b_ext_tbl.FIRST..l_new_ovr_b_ext_tbl.LAST
	      INSERT
	      INTO BOM_COMPONENTS_EXT_B
	      VALUES l_new_ovr_b_ext_tbl(i);

        FOR c_ovr_tl_row IN C_OVR_TL_ROWS(ctx_rec.EXTENSION_ID) LOOP
          l_new_ovr_tl_ext_rec := c_ovr_tl_row;
          l_new_ovr_tl_ext_rec.EXTENSION_ID          := l_new_ext_id;
          l_new_ovr_tl_ext_rec.COMPONENT_SEQUENCE_ID := p_new_comp_seq;
          l_new_ovr_tl_ext_rec.CONTEXT_ID            := l_new_ctx_id;
          l_new_ovr_tl_ext_rec.DATA_LEVEL_ID         := l_data_level_id_comp_ovr;
          l_new_ovr_tl_ext_rec.CREATION_DATE         := sysdate;
	      l_new_ovr_tl_ext_rec.CREATED_BY            := l_user_id;
          l_new_ovr_tl_ext_rec.LAST_UPDATE_DATE      := sysdate;
	      l_new_ovr_tl_ext_rec.LAST_UPDATED_BY       := l_user_id;
          l_new_ovr_tl_ext_rec.LAST_UPDATE_LOGIN     := l_login_id;

          l_new_ovr_tl_ext_tbl(1) := l_new_ovr_tl_ext_rec;

          FORALL i in l_new_ovr_tl_ext_tbl.FIRST..l_new_ovr_tl_ext_tbl.LAST
	        INSERT
	        INTO BOM_COMPONENTS_EXT_TL
	        VALUES l_new_ovr_tl_ext_tbl(i);

	    END LOOP; --FOR c_ovr_tl_row IN C_OVR_TL_ROWS(ctx_rec.EXTENSION_ID) LOOP

      END LOOP;  --FOR c_ovr_b_row IN C_OVR_B_ROWS(ctx_rec.EXTENSION_ID) LOOP

      --now insert the context row
      new_ctx_rec := ctx_rec;
      new_ctx_rec.EXTENSION_ID          := l_new_ext_id;
      new_ctx_rec.BASE_EXTENSION_ID     := udab_new_base_rec.EXTENSION_ID;
      new_ctx_rec.COMPONENT_SEQUENCE_ID := p_new_comp_seq;
      new_ctx_rec.OBJECT_VERSION_NUMBER := 1;
      new_ctx_rec.CONTEXT_ID            := l_new_ctx_id;
      new_ctx_rec.CREATION_DATE         := sysdate;
      new_ctx_rec.CREATED_BY            := l_user_id;
      new_ctx_rec.LAST_UPDATE_DATE      := sysdate;
      new_ctx_rec.LAST_UPDATED_BY       := l_user_id;
      new_ctx_rec.LAST_UPDATE_LOGIN     := l_login_id;

      l_new_ctx_tbl(1) := new_ctx_rec;

      FORALL i in l_new_ctx_tbl.FIRST..l_new_ctx_tbl.LAST
      INSERT
        INTO BOM_COMP_ATTR_CTX_ASSOCS_B
      VALUES l_new_ctx_tbl(i);

    --END LOOP;  --FOR c_base_row IN C_NEW_BASE_ROW(ctx_rec.BILL_SEQUENCE_ID, p_new_comp_seq, ctx_rec.ATTR_GROUP_ID) LOOP

  END LOOP;  --  FOR c_ctx_rec IN C_FROM_CTX_ROWS(p_old_comp_seq) LOOP

EXCEPTION WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Copy_Comp_UDA_Overrides;


PROCEDURE Delete_Comp_UDA_Overrides (p_del_comp_seq NUMBER,
                                     x_return_status OUT NOCOPY VARCHAR2) IS
l_data_level_id_comp_ovr   NUMBER;
l_data_level_name_comp_ovr VARCHAR2(30) := 'COMPONENTS_OVR_LEVEL';

CURSOR C_DATA_LEVEL(p_data_level_name VARCHAR2) IS
  SELECT DATA_LEVEL_ID
    FROM EGO_DATA_LEVEL_B
   WHERE DATA_LEVEL_NAME = p_data_level_name;

BEGIN

  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  FOR c_comp_level IN C_DATA_LEVEL(l_data_level_name_comp_ovr) LOOP
    l_data_level_id_comp_ovr := c_comp_level.DATA_LEVEL_ID;
  END LOOP;

  DELETE
    FROM BOM_COMPONENTS_EXT_B
   WHERE COMPONENT_SEQUENCE_ID = p_del_comp_seq
     AND DATA_LEVEL_ID = l_data_level_id_comp_ovr;

  DELETE
    FROM BOM_COMPONENTS_EXT_TL
   WHERE COMPONENT_SEQUENCE_ID = p_del_comp_seq
     AND DATA_LEVEL_ID = l_data_level_id_comp_ovr;

  DELETE
    FROM BOM_COMP_ATTR_CTX_ASSOCS_B
   WHERE COMPONENT_SEQUENCE_ID = p_del_comp_seq;

  EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Delete_Comp_UDA_Overrides;



END BOM_UDA_OVERRIDES_PVT;


/
