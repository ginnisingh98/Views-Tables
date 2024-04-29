--------------------------------------------------------
--  DDL for Package Body GMD_VERSION_CONTROL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_VERSION_CONTROL" AS
/* $Header: GMDVCTLB.pls 120.11.12010000.2 2008/11/12 18:38:34 rnalla ship $ */

G_PKG_NAME VARCHAR2(32);

/*======================================================================
--  PROCEDURE :
--   populate_temp_text
--
--  DESCRIPTION:
--    This PL/SQL procedure is responsible for versioning of Edit Text
--    data.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    populate_temp_text(p_text_code ,flag)
--
--  HISTORY
--    25-Nov-2003  Vipul Vaish  BUG#3258592
--      Created populate_temp_text so that the edit text versioning
--      takes place properly.
--    04-Dec-2003  Vipul Vaish  BUG#3258592
--      Removed Commit from populate_temp_text procedure.
--    02-Jan-2004  Vipul Vaish  BUG#3258592
--      Modified code that is being executed when flag = 2.
--      Added code for additional two flag values 3 and 4.
--===================================================================== */
PROCEDURE populate_temp_text(p_text_code IN number,flag IN number) IS
  x_row NUMBER := 0;
  l_rowid VARCHAR2(100);
  CURSOR Cur_edit_text(p_text_code number) IS
    SELECT *
    FROM   FM_TEXT_TBL_TL
    WHERE text_code = p_text_code;
  l_insert varchar2(1);
BEGIN

IF flag = 1 THEN

  FOR i IN 1..edit_text_tbl.count LOOP
    IF edit_text_tbl(i).text_code = p_text_code THEN
      RETURN;
        END IF;
  END LOOP;

  X_row := edit_text_tbl.count;
  FOR get_rec IN Cur_edit_text(p_text_code) LOOP
    X_row := X_row + 1;
    edit_text_tbl(X_row) := get_rec;
  END LOOP;

ELSIF flag = 2 THEN
  l_insert := 'F';
  FOR i IN 1..edit_text_tbl.count LOOP
    IF edit_text_tbl(i).text_code = p_text_code THEN
      DELETE FROM FM_TEXT_TBL_TL
      WHERE  text_code = p_text_code;
      l_insert := 'T';
      EXIT;
    END IF;
  END LOOP;

  IF l_insert = 'T' THEN
    FOR i IN 1..edit_text_tbl.count LOOP
      IF edit_text_tbl(i).text_code = p_text_code THEN
        INSERT INTO FM_TEXT_TBL_TL(
         TEXT_CODE,
         LANG_CODE,
         PARAGRAPH_CODE,
         SUB_PARACODE,
         LINE_NO,
         TEXT,
         LANGUAGE,
         SOURCE_LANG,
         LAST_UPDATED_BY,
         CREATED_BY,
         LAST_UPDATE_DATE,
         CREATION_DATE,
         LAST_UPDATE_LOGIN )
        VALUES (
        edit_text_tbl(i).text_code,
        edit_text_tbl(i).lang_code,
        edit_text_tbl(i).paragraph_code,
        edit_text_tbl(i).sub_paracode,
        edit_text_tbl(i).line_no,
        edit_text_tbl(i).text,
        edit_text_tbl(i).language,
        edit_text_tbl(i).source_lang,
        edit_text_tbl(i).last_updated_by,
        edit_text_tbl(i).created_by,
        edit_text_tbl(i).last_update_date,
        edit_text_tbl(i).creation_date,
        edit_text_tbl(i).last_update_login);

        edit_text_tbl(i).text_code := NULL;

      END IF;
    END LOOP;
    l_insert := 'F';
  END IF;

ELSIF flag = 3 THEN
  FOR i IN 1..edit_text_tbl.count LOOP
    IF edit_text_tbl(i).text_code IS NOT NULL THEN
      edit_text_tbl(i).text_code := NULL;
    END IF;
  END LOOP;

ELSIF flag = 4 THEN
  FOR i IN 1..edit_text_tbl.count LOOP
    IF edit_text_tbl(i).text_code IS NOT NULL THEN
      DELETE FROM FM_TEXT_TBL_TL
      WHERE TEXT_CODE = edit_text_tbl(i).text_code;
    END IF;
  END LOOP;
  FOR i IN 1..edit_text_tbl.count LOOP
    IF edit_text_tbl(i).text_code IS NOT NULL THEN
      INSERT INTO FM_TEXT_TBL_TL(
        TEXT_CODE,
        LANG_CODE,
        PARAGRAPH_CODE,
        SUB_PARACODE,
        LINE_NO,
        TEXT,
        LANGUAGE,
        SOURCE_LANG,
        LAST_UPDATED_BY,
        CREATED_BY,
        LAST_UPDATE_DATE,
        CREATION_DATE,
        LAST_UPDATE_LOGIN )
      VALUES (
        edit_text_tbl(i).text_code,
        edit_text_tbl(i).lang_code,
        edit_text_tbl(i).paragraph_code,
        edit_text_tbl(i).sub_paracode,
        edit_text_tbl(i).line_no,
        edit_text_tbl(i).text,
        edit_text_tbl(i).language,
        edit_text_tbl(i).source_lang,
        edit_text_tbl(i).last_updated_by,
        edit_text_tbl(i).created_by,
        edit_text_tbl(i).last_update_date,
        edit_text_tbl(i).creation_date,
        edit_text_tbl(i).last_update_login);

        edit_text_tbl(i).text_code := NULL;
    END IF;
  END LOOP;
  COMMIT;
END IF;
END populate_temp_text;

/*======================================================================
--  PROCEDURE :
--   create_routing
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for saving the
--    new routing while versioning.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    create_routing(P_routing_id, X_routing_id);
--
--  HISTORY
--    31-Jan-2003  Jeff Baird    Bug #2673008  Added call to copy_text API.
--    25-Nov-2003  Vipul Vaish   BUG#3258592
--                 Added call to procedure populate_temp_text after GMA_EDITTEXT_PKG.Copy_Text
--                 function.
--
--===================================================================== */
PROCEDURE create_routing(p_routing_id IN  NUMBER, x_routing_id OUT NOCOPY NUMBER) IS

  X_routing_vers        NUMBER;
  X_row         NUMBER := 0;
  l_rowid               VARCHAR2(32);
  l_text_code   NUMBER;
-- Bug #2673008 (JKB) Added l_text_code above.

  CURSOR Cur_routing_id IS
    SELECT gem5_routing_id_s.NEXTVAL
    FROM   FND_DUAL;
  CURSOR Cur_get_hdr IS
    SELECT *
    FROM   fm_rout_hdr
    WHERE  routing_id = p_routing_id;
  X_hdr_rec       Cur_get_hdr%ROWTYPE;
  CURSOR Cur_rout_vers IS
    SELECT MAX(routing_vers) + 1
    FROM   fm_rout_hdr
    WHERE  routing_no = X_hdr_rec.routing_no;

  CURSOR Cur_get_dtl IS
    SELECT *
    FROM   fm_rout_dtl
    WHERE  routing_id = p_routing_id;
  TYPE detail_tab IS TABLE OF Cur_get_dtl%ROWTYPE INDEX BY BINARY_INTEGER;
  X_dtl_tbl detail_tab;

  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);
  l_return_status       VARCHAR2(10);
  l_gmo_enabled         VARCHAR2(1);
  l_source_name_array   GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
  l_source_key_array    GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
  l_target_name_array   GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
  l_target_key_array    GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
BEGIN
  OPEN Cur_get_hdr;
  FETCH Cur_get_hdr INTO X_hdr_rec;
  CLOSE Cur_get_hdr;

  FOR get_rec IN Cur_get_dtl LOOP
    X_row := X_row + 1;
    X_dtl_tbl(X_row) := get_rec;
  END LOOP;

  /* Check if GMO is enabled */
  l_gmo_enabled :=  gmo_setup_grp.is_gmo_enabled;
  IF l_gmo_enabled = 'Y' THEN
    GMD_PROCESS_INSTR_UTILS.build_array (p_entity_name	=> 'ROUTING',
				         p_entity_id	=> p_routing_id,
                                         x_name_array   => l_source_name_array,
                                         x_key_array    => l_source_key_array,
			                 x_return_status => l_return_status);
  END IF;

  ROLLBACK;

  OPEN Cur_rout_vers;
  FETCH Cur_rout_vers INTO X_routing_vers;
  CLOSE Cur_rout_vers;

  OPEN Cur_routing_id;
  FETCH Cur_routing_id INTO x_routing_id;
  CLOSE Cur_routing_id;
  /* Insert header record */


  IF X_hdr_rec.TEXT_CODE IS NOT NULL THEN
     l_text_code := GMA_EDITTEXT_PKG.Copy_Text(X_hdr_rec.TEXT_CODE,
                    'FM_TEXT_TBL_TL',
                    'FM_TEXT_TBL_TL');
         populate_temp_text(X_hdr_rec.TEXT_CODE,2);--BUG#3258592
  ELSE
     l_text_code := NULL;
  END IF;
-- Bug #2673008 (JKB) Added call to copy_text above.

  GMD_ROUTINGS_PKG.INSERT_ROW(
    X_ROWID => l_ROWID,
    X_ROUTING_ID => X_ROUTING_ID,
    X_OWNER_ORGANIZATION_ID => X_HDR_rec.OWNER_ORGANIZATION_ID,
    X_ROUTING_NO => X_HDR_rec.ROUTING_NO,
    X_ROUTING_VERS => X_ROUTING_VERS,
    X_ROUTING_CLASS => X_HDR_rec.ROUTING_CLASS,
    X_ENFORCE_STEP_DEPENDENCY => X_hdr_rec.enforce_step_dependency,
    X_CONTIGUOUS_IND => X_hdr_rec.contiguous_ind,
    X_ROUTING_QTY => X_HDR_rec.ROUTING_QTY,
    X_ROUTING_UOM => X_HDR_rec.ROUTING_UOM,
    X_DELETE_MARK => 0,
    X_TEXT_CODE   => l_text_code,
    X_INACTIVE_IND => 0,
    X_IN_USE => 0,
    X_ATTRIBUTE1 => X_HDR_rec.ATTRIBUTE1,
    X_ATTRIBUTE2 => X_HDR_rec.ATTRIBUTE2,
    X_ATTRIBUTE3 => X_HDR_rec.ATTRIBUTE3,
    X_ATTRIBUTE4 => X_HDR_rec.ATTRIBUTE4,
    X_ATTRIBUTE5 => X_HDR_rec.ATTRIBUTE5,
    X_ATTRIBUTE6 => X_HDR_rec.ATTRIBUTE6,
    X_ATTRIBUTE7 => X_HDR_rec.ATTRIBUTE7,
    X_ATTRIBUTE8 => X_HDR_rec.ATTRIBUTE8,
    X_ATTRIBUTE9 => X_HDR_rec.ATTRIBUTE9,
    X_ATTRIBUTE10 => X_HDR_rec.ATTRIBUTE10,
    X_ATTRIBUTE11 => X_HDR_rec.ATTRIBUTE11,
    X_ATTRIBUTE12 => X_HDR_rec.ATTRIBUTE12,
    X_ATTRIBUTE13 => X_HDR_rec.ATTRIBUTE13,
    X_ATTRIBUTE14 => X_HDR_rec.ATTRIBUTE14,
    X_ATTRIBUTE15 => X_HDR_rec.ATTRIBUTE15,
    X_ATTRIBUTE16 => X_HDR_rec.ATTRIBUTE16,
    X_ATTRIBUTE17 => X_HDR_rec.ATTRIBUTE17,
    X_ATTRIBUTE18 => X_HDR_rec.ATTRIBUTE18,
    X_ATTRIBUTE19 => X_HDR_rec.ATTRIBUTE19,
    X_ATTRIBUTE20 => X_HDR_rec.ATTRIBUTE20,
    X_ATTRIBUTE21 => X_HDR_rec.ATTRIBUTE21,
    X_ATTRIBUTE22 => X_HDR_rec.ATTRIBUTE22,
    X_ATTRIBUTE23 => X_HDR_rec.ATTRIBUTE23,
    X_ATTRIBUTE24 => X_HDR_rec.ATTRIBUTE24,
    X_ATTRIBUTE25 => X_HDR_rec.ATTRIBUTE25,
    X_ATTRIBUTE26 => X_HDR_rec.ATTRIBUTE26,
    X_ATTRIBUTE27 => X_HDR_rec.ATTRIBUTE27,
    X_ATTRIBUTE28 => X_HDR_rec.ATTRIBUTE28,
    X_ATTRIBUTE29 => X_HDR_rec.ATTRIBUTE29,
    X_ATTRIBUTE30 => X_HDR_rec.ATTRIBUTE30,
    X_ATTRIBUTE_CATEGORY => X_HDR_rec.ATTRIBUTE_CATEGORY,
    X_EFFECTIVE_START_DATE => X_HDR_rec.EFFECTIVE_START_DATE,
    X_EFFECTIVE_END_DATE => X_HDR_rec.EFFECTIVE_END_DATE,
    X_OWNER_ID => X_HDR_rec.OWNER_ID,
    X_PROJECT_ID => X_HDR_rec.PROJECT_ID,
    X_PROCESS_LOSS => X_HDR_rec.PROCESS_LOSS,
    X_ROUTING_STATUS => 100,
    X_ROUTING_DESC => X_HDR_rec.ROUTING_DESC,
    X_CREATION_DATE => SYSDATE,
    X_CREATED_BY => P_created_by,
    X_LAST_UPDATE_DATE => SYSDATE,
    X_LAST_UPDATED_BY => P_created_by,
    X_LAST_UPDATE_LOGIN => P_login_id);


  /* Insert detail records */
  FOR i IN 1..X_dtl_tbl.count LOOP
    IF X_dtl_tbl(i).text_code IS NOT NULL THEN
       l_text_code := GMA_EDITTEXT_PKG.Copy_Text(X_dtl_tbl(i).text_code,
                      'FM_TEXT_TBL_TL',
                      'FM_TEXT_TBL_TL');
         populate_temp_text(X_dtl_tbl(i).text_code,2);--BUG#3258592
    ELSE
       l_text_code := NULL;
    END IF;
-- Bug #2673008 (JKB) Added call to copy_text above.
    INSERT INTO fm_rout_dtl
               (routing_id, routingstep_no, routingstep_id, oprn_id,
                step_qty, steprelease_type, text_code, creation_date,
                created_by, last_update_login, last_update_date,
                last_updated_by, attribute1, attribute2, attribute3, attribute4,
                attribute5, attribute6, attribute7, attribute8, attribute9,
                attribute10, attribute11, attribute12, attribute13, attribute14,
                attribute15, attribute16, attribute17, attribute18, attribute19,
                attribute20, attribute21, attribute22, attribute23, attribute24,
                attribute25, attribute26, attribute27, attribute28, attribute29,
                attribute30, attribute_category)
    VALUES     (x_routing_id, X_dtl_tbl(i).routingstep_no,
                gem5_routingstep_id_s.NEXTVAL, X_dtl_tbl(i).oprn_id,
                X_dtl_tbl(i).step_qty, X_dtl_tbl(i).steprelease_type,
                l_text_code, SYSDATE, P_created_by, P_login_id, SYSDATE,
-- Bug #2673008 (JKB) Changed above.
                P_created_by, X_dtl_tbl(i).attribute1, X_dtl_tbl(i).attribute2,
                X_dtl_tbl(i).attribute3, X_dtl_tbl(i).attribute4,
                X_dtl_tbl(i).attribute5, X_dtl_tbl(i).attribute6,
                X_dtl_tbl(i).attribute7, X_dtl_tbl(i).attribute8,
                X_dtl_tbl(i).attribute9, X_dtl_tbl(i).attribute10,
                X_dtl_tbl(i).attribute11, X_dtl_tbl(i).attribute12,
                X_dtl_tbl(i).attribute13, X_dtl_tbl(i).attribute14,
                X_dtl_tbl(i).attribute15, X_dtl_tbl(i).attribute16,
                X_dtl_tbl(i).attribute17, X_dtl_tbl(i).attribute18,
                X_dtl_tbl(i).attribute19, X_dtl_tbl(i).attribute20,
                X_dtl_tbl(i).attribute21, X_dtl_tbl(i).attribute22,
                X_dtl_tbl(i).attribute23, X_dtl_tbl(i).attribute24,
                X_dtl_tbl(i).attribute25, X_dtl_tbl(i).attribute26,
                X_dtl_tbl(i).attribute27, X_dtl_tbl(i).attribute28,
                X_dtl_tbl(i).attribute29, X_dtl_tbl(i).attribute30,
                X_dtl_tbl(i).attribute_category);
  END LOOP;

  -- If GMO is enabled, copy the new PI's from old entity to new entity
  IF l_gmo_enabled = 'Y' THEN
    GMD_PROCESS_INSTR_UTILS.build_array (p_entity_name	=> 'ROUTING',
				         p_entity_id	=> x_routing_id,
                                         x_name_array   => l_target_name_array,
                                         x_key_array    => l_target_key_array,
			                 x_return_status => l_return_status);

    GMD_PROCESS_INSTR_UTILS.Copy_Process_Instructions  (
                                p_source_name_array      => l_source_name_array,
                                p_source_key_array       => l_source_key_array,
                                p_target_name_array      => l_target_name_array,
                                p_target_key_array       => l_target_key_array,
			        x_return_status          => l_return_status);
  END IF;

END create_routing;

/*======================================================================
--  PROCEDURE :
--   create_operation
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for saving the
--    new operation while versioning.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    create_operation(P_oprn_id, X_oprn_id);
--
--  HISTORY
--    31-Jan-2003  Jeff Baird    Bug #2673008  Added call to copy_text API.
--    25-Nov-2003  Vipul Vaish   BUG#3258592
--                 Added call to procedure populate_temp_text after GMA_EDITTEXT_PKG.Copy_Text
--                 function.
--    01-Jun-2006  TDaniel       Bug # 5260696 Added Order by oprn_line_id to Cur_get_actv
--                               cursor.
--============================================================================================ */
PROCEDURE create_operation(p_oprn_id IN  NUMBER, x_oprn_id OUT NOCOPY NUMBER) IS
  CURSOR Cur_gen_oprn_id IS
    SELECT GEM5_OPRN_ID_S.NEXTVAL
    FROM   FND_DUAL;
  CURSOR Cur_gen_oprnline_id IS
    SELECT GEM5_OPRNLINE_ID_S.NEXTVAL
    FROM   FND_DUAL;

  CURSOR Cur_get_hdr IS
    SELECT *
    FROM   gmd_operations_vl
    WHERE  oprn_id = p_oprn_id;
  X_hdr_rec       Cur_get_hdr%ROWTYPE;
  CURSOR Cur_get_vers IS
    SELECT MAX(oprn_vers) + 1
    FROM   gmd_operations_vl
    WHERE  oprn_no = X_hdr_rec.oprn_no;

  /* Bug 5260696 - Added order by oprn_line_id */
  CURSOR Cur_get_actv IS
    SELECT *
    FROM   gmd_operation_activities
    WHERE  oprn_id = p_oprn_id
    ORDER BY oprn_line_id;
  TYPE actv_tab IS TABLE OF Cur_get_actv%ROWTYPE INDEX BY BINARY_INTEGER;
  X_actv_tbl       actv_tab;

  CURSOR Cur_get_rsrc(V_oprn_line_id NUMBER) IS
    SELECT *
    FROM   gmd_operation_resources
    WHERE  oprn_line_id = V_oprn_line_id;


-- KSHUKLA Added this as per as bug 4186561
-- To insert the values of the process parameters
-- In the table.
-- KSHUKLA added Order by clause
  CURSOR Cur_get_process_param(V_oprn_line_id NUMBER) IS
    SELECT *
    FROM GMD_OPRN_PROCESS_PARAMETERS_V1
    where oprn_line_id = V_oprn_line_id
    order by oprn_line_id;

  TYPE rsrc_tab IS TABLE OF Cur_get_rsrc%ROWTYPE INDEX BY BINARY_INTEGER;
  X_rsrc_tbl    rsrc_tab;

  TYPE parm_tab IS TABLE OF Cur_get_process_param%ROWTYPE INDEX BY BINARY_INTEGER;
  X_parm_tbl     parm_tab; --bug 4186561

  X_oprn_vers   NUMBER;
  X_oprn_line_id        NUMBER;
  X_row         NUMBER := 0;
  X_rsrc_cnt      NUMBER := 0;
  X_prcs_cnt      NUMBER := 0;
  l_rowid               VARCHAR2(32);
  l_text_code   NUMBER;

-- Bug #2673008 (JKB) Added l_text_code above.

  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);
  l_return_status       VARCHAR2(10);
  l_gmo_enabled         VARCHAR2(1);
  l_source_name_array   GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
  l_source_key_array    GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
  l_target_name_array   GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
  l_target_key_array    GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
BEGIN
  OPEN Cur_get_hdr;
  FETCH Cur_get_hdr INTO X_hdr_rec;
  CLOSE Cur_get_hdr;

  FOR get_actv IN Cur_get_actv LOOP
    X_row             := X_row + 1;
    X_actv_tbl(X_row) := get_actv;
    FOR get_rsrc IN Cur_get_rsrc(get_actv.oprn_line_id) LOOP
      X_rsrc_cnt             := X_rsrc_cnt + 1;
      X_rsrc_tbl(X_rsrc_cnt) := get_rsrc;
    END LOOP;
    -- KSHUKLA changed moved the record fetch out of the get_rsrc loop
    FOR get_prcs IN Cur_get_process_param(get_actv.oprn_line_id) LOOP
      X_prcs_cnt    := X_prcs_cnt+1;
      X_parm_tbl(X_prcs_cnt) := get_prcs;
    END LOOP;
  END LOOP;

  /* Check if GMO is enabled */
  l_gmo_enabled :=  gmo_setup_grp.is_gmo_enabled;
  IF l_gmo_enabled = 'Y' THEN
    GMD_PROCESS_INSTR_UTILS.build_array (p_entity_name	=> 'OPERATION',
				         p_entity_id	=> p_oprn_id,
                                         x_name_array   => l_source_name_array,
                                         x_key_array    => l_source_key_array,
			                 x_return_status => l_return_status);
  END IF;

  ROLLBACK;

  OPEN Cur_get_vers;
  FETCH Cur_get_vers INTO X_oprn_vers;
  CLOSE Cur_get_vers;
  OPEN Cur_gen_oprn_id;
  FETCH Cur_gen_oprn_id INTO x_oprn_id;
  CLOSE Cur_gen_oprn_id;


  /* Insert header record */


  IF X_hdr_rec.TEXT_CODE IS NOT NULL THEN
     l_text_code := GMA_EDITTEXT_PKG.Copy_Text(X_hdr_rec.TEXT_CODE,
                    'FM_TEXT_TBL_TL',
                    'FM_TEXT_TBL_TL');
         populate_temp_text(X_hdr_rec.TEXT_CODE,2);--BUG#3258592
  ELSE
     l_text_code := NULL;
  END IF;
-- Bug #2673008 (JKB) Added call to copy_text above.

   GMD_OPERATIONS_PKG.INSERT_ROW(
    X_ROWID => l_rowid  ,
    X_OPRN_ID => x_oprn_id,
    X_ATTRIBUTE30 => X_HDR_rec.ATTRIBUTE30,
    X_ATTRIBUTE_CATEGORY => X_HDR_rec.ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE25 => X_HDR_rec.ATTRIBUTE25,
    X_ATTRIBUTE26 => X_HDR_rec.ATTRIBUTE26,
    X_ATTRIBUTE27 => X_HDR_rec.ATTRIBUTE27,
    X_ATTRIBUTE28 => X_HDR_rec.ATTRIBUTE28,
    X_ATTRIBUTE29 => X_HDR_rec.ATTRIBUTE29,
    X_ATTRIBUTE22 => X_HDR_rec.ATTRIBUTE22,
    X_ATTRIBUTE23 => X_HDR_rec.ATTRIBUTE23,
    X_ATTRIBUTE24 => X_HDR_rec.ATTRIBUTE24,
    X_OPRN_NO => X_HDR_rec.OPRN_NO,
    X_OPRN_VERS => X_OPRN_VERS,
    X_PROCESS_QTY_UOM => X_HDR_rec.PROCESS_QTY_UOM,
    X_OPRN_CLASS => X_HDR_rec.OPRN_CLASS,
    X_INACTIVE_IND => 0,
    X_EFFECTIVE_START_DATE => X_HDR_rec.EFFECTIVE_START_DATE,
    X_EFFECTIVE_END_DATE => X_HDR_rec.EFFECTIVE_END_DATE,
    X_DELETE_MARK => 0,
    X_TEXT_CODE   => l_text_code,
-- Bug #2673008 (JKB) Changed above.
    X_ATTRIBUTE1 => X_HDR_rec.ATTRIBUTE1,
    X_ATTRIBUTE2 => X_HDR_rec.ATTRIBUTE2,
    X_ATTRIBUTE3 => X_HDR_rec.ATTRIBUTE3,
    X_ATTRIBUTE4 => X_HDR_rec.ATTRIBUTE4,
    X_ATTRIBUTE5 => X_HDR_rec.ATTRIBUTE5,
    X_ATTRIBUTE6 => X_HDR_rec.ATTRIBUTE6,
    X_ATTRIBUTE7 => X_HDR_rec.ATTRIBUTE7,
    X_ATTRIBUTE8 => X_HDR_rec.ATTRIBUTE8,
    X_ATTRIBUTE9 => X_HDR_rec.ATTRIBUTE9,
    X_ATTRIBUTE10 => X_HDR_rec.ATTRIBUTE10,
    X_ATTRIBUTE11 => X_HDR_rec.ATTRIBUTE11,
    X_ATTRIBUTE12 => X_HDR_rec.ATTRIBUTE12,
    X_ATTRIBUTE13 => X_HDR_rec.ATTRIBUTE13,
    X_ATTRIBUTE14 => X_HDR_rec.ATTRIBUTE14,
    X_ATTRIBUTE15 => X_HDR_rec.ATTRIBUTE15,
    X_ATTRIBUTE16 => X_HDR_rec.ATTRIBUTE16,
    X_ATTRIBUTE17 => X_HDR_rec.ATTRIBUTE17,
    X_ATTRIBUTE18 => X_HDR_rec.ATTRIBUTE18,
    X_ATTRIBUTE19 => X_HDR_rec.ATTRIBUTE19,
    X_ATTRIBUTE20 => X_HDR_rec.ATTRIBUTE20,
    X_ATTRIBUTE21 => X_HDR_rec.ATTRIBUTE21,
    X_OPERATION_STATUS => 100,
    X_OWNER_ORGANIZATION_ID => X_HDR_rec.OWNER_ORGANIZATION_ID,
    X_OPRN_DESC => X_HDR_rec.OPRN_DESC,
    X_CREATION_DATE => SYSDATE,
    X_CREATED_BY => P_CREATED_BY,
    X_LAST_UPDATE_DATE => SYSDATE,
    X_LAST_UPDATED_BY => P_CREATED_BY,
    X_LAST_UPDATE_LOGIN => P_login_id);


  /* Insert Activities */
  X_rsrc_cnt := 0;
  X_prcs_cnt := 0; --bug 4186561
  FOR i IN 1..X_actv_tbl.count LOOP
  -- Regulating the text code here
     IF X_actv_tbl(i).text_code IS NOT NULL THEN
        l_text_code := GMA_EDITTEXT_PKG.Copy_Text(X_actv_tbl(i).text_code,
                       'FM_TEXT_TBL_TL',
                       'FM_TEXT_TBL_TL');
         populate_temp_text(X_actv_tbl(i).text_code,2);--BUG#3258592
     ELSE
        l_text_code := NULL;
     END IF;

-- Bug #2673008 (JKB) Added call to copy_text above.
    OPEN Cur_gen_oprnline_id;
    FETCH Cur_gen_oprnline_id INTO X_oprn_line_id;
    CLOSE Cur_gen_oprnline_id;

    INSERT INTO gmd_operation_activities (oprn_id, oprn_line_id, activity,
                    activity_factor, delete_mark, text_code, last_updated_by,
                    created_by, last_update_date, creation_date,
                    last_update_login, attribute1, attribute2, attribute3,
                    attribute4, attribute5, attribute6, attribute7, attribute8,
                    attribute9, attribute10, attribute11, attribute12,
                    attribute13, attribute14, attribute15, attribute16,
                    attribute17, attribute18, attribute19, attribute20,
                    attribute21, attribute22, attribute23, attribute24,
                    attribute25, attribute26, attribute27, attribute28,
                    attribute29, attribute30, attribute_category,
                    offset_interval, break_ind, max_break)
    VALUES         (x_oprn_id, X_oprn_line_id, X_actv_tbl(i).activity,
                    X_actv_tbl(i).activity_factor, 0, l_text_code, P_created_by,
-- Bug #2673008 (JKB) Changed above.
                    P_created_by, SYSDATE, SYSDATE, P_login_id,
                    X_actv_tbl(i).attribute1, X_actv_tbl(i).attribute2,
                    X_actv_tbl(i).attribute3, X_actv_tbl(i).attribute4,
                    X_actv_tbl(i).attribute5, X_actv_tbl(i).attribute6,
                    X_actv_tbl(i).attribute7, X_actv_tbl(i).attribute8,
                    X_actv_tbl(i).attribute9, X_actv_tbl(i).attribute10,
                    X_actv_tbl(i).attribute11, X_actv_tbl(i).attribute12,
                    X_actv_tbl(i).attribute13, X_actv_tbl(i).attribute14,
                    X_actv_tbl(i).attribute15, X_actv_tbl(i).attribute16,
                    X_actv_tbl(i).attribute17, X_actv_tbl(i).attribute18,
                    X_actv_tbl(i).attribute19, X_actv_tbl(i).attribute20,
                    X_actv_tbl(i).attribute21, X_actv_tbl(i).attribute22,
                    X_actv_tbl(i).attribute23, X_actv_tbl(i).attribute24,
                    X_actv_tbl(i).attribute25, X_actv_tbl(i).attribute26,
                    X_actv_tbl(i).attribute27, X_actv_tbl(i).attribute28,
                    X_actv_tbl(i).attribute29, X_actv_tbl(i).attribute30,
                    X_actv_tbl(i).attribute_category,
                    X_actv_tbl(i).offset_interval, X_actv_tbl(i).break_ind,
                    X_actv_tbl(i).max_break);
    LOOP
      X_rsrc_cnt := X_rsrc_cnt + 1;
      IF (X_rsrc_cnt > X_rsrc_tbl.count) THEN
        EXIT;
      END IF;
      IF (X_actv_tbl(i).oprn_line_id = X_rsrc_tbl(X_rsrc_cnt).oprn_line_id) THEN
     IF X_rsrc_tbl(X_rsrc_cnt).text_code IS NOT NULL THEN
        l_text_code := GMA_EDITTEXT_PKG.Copy_Text(X_rsrc_tbl(X_rsrc_cnt).text_code,
                       'FM_TEXT_TBL_TL',
                       'FM_TEXT_TBL_TL');
         populate_temp_text(X_rsrc_tbl(X_rsrc_cnt).text_code,2);--BUG#3258592
     ELSE
        l_text_code := NULL;
     END IF;
-- Bug #2673008 (JKB) Added call to copy_text above.
        INSERT INTO gmd_operation_resources (oprn_line_id, resources,
                        resource_usage, resource_count, process_qty,
                        prim_rsrc_ind, scale_type, cost_analysis_code,
                        cost_cmpntcls_id, usage_um, offset_interval,
                        delete_mark, text_code, created_by, last_updated_by,
                        last_update_date, creation_date, last_update_login,
                        attribute1, attribute2, attribute3, attribute4,
                        attribute5, attribute6, attribute7, attribute8,
                        attribute9, attribute10, attribute11, attribute12,
                        attribute13, attribute14, attribute15, attribute16,
                        attribute17, attribute18, attribute19, attribute20,
                        attribute21, attribute22, attribute23, attribute24,
                        attribute25, attribute26, attribute27, attribute28,
                        attribute29, attribute30, attribute_category,
                        process_uom, min_capacity, max_capacity, capacity_uom,
                        process_parameter_1, process_parameter_2,
                        process_parameter_3, process_parameter_4,
                        process_parameter_5,RESOURCE_USAGE_UOM,
                        RESOURCE_PROCESS_UOM ,RESOURCE_CAPACITY_UOM)--bug 4186561
        VALUES         (X_oprn_line_id, X_rsrc_tbl(X_rsrc_cnt).resources,
                        X_rsrc_tbl(X_rsrc_cnt).resource_usage,
                        X_rsrc_tbl(X_rsrc_cnt).resource_count,
                        X_rsrc_tbl(X_rsrc_cnt).process_qty,
                        X_rsrc_tbl(X_rsrc_cnt).prim_rsrc_ind,
                        X_rsrc_tbl(X_rsrc_cnt).scale_type,
                        X_rsrc_tbl(X_rsrc_cnt).cost_analysis_code,
                        X_rsrc_tbl(X_rsrc_cnt).cost_cmpntcls_id,
                        X_rsrc_tbl(X_rsrc_cnt).usage_um,
                        X_rsrc_tbl(X_rsrc_cnt).offset_interval,
                        X_rsrc_tbl(X_rsrc_cnt).delete_mark, l_text_code,
-- Bug #2673008 (JKB) Changed above.
                        P_created_by, P_created_by, SYSDATE, SYSDATE,
                        P_login_id, X_rsrc_tbl(X_rsrc_cnt).attribute1,
                        X_rsrc_tbl(X_rsrc_cnt).attribute2,
                        X_rsrc_tbl(X_rsrc_cnt).attribute3,
                        X_rsrc_tbl(X_rsrc_cnt).attribute4,
                        X_rsrc_tbl(X_rsrc_cnt).attribute5,
                        X_rsrc_tbl(X_rsrc_cnt).attribute6,
                        X_rsrc_tbl(X_rsrc_cnt).attribute7,
                        X_rsrc_tbl(X_rsrc_cnt).attribute8,
                        X_rsrc_tbl(X_rsrc_cnt).attribute9,
                        X_rsrc_tbl(X_rsrc_cnt).attribute10,
                        X_rsrc_tbl(X_rsrc_cnt).attribute11,
                        X_rsrc_tbl(X_rsrc_cnt).attribute12,
                        X_rsrc_tbl(X_rsrc_cnt).attribute13,
                        X_rsrc_tbl(X_rsrc_cnt).attribute14,
                        X_rsrc_tbl(X_rsrc_cnt).attribute15,
                        X_rsrc_tbl(X_rsrc_cnt).attribute16,
                        X_rsrc_tbl(X_rsrc_cnt).attribute17,
                        X_rsrc_tbl(X_rsrc_cnt).attribute18,
                        X_rsrc_tbl(X_rsrc_cnt).attribute19,
                        X_rsrc_tbl(X_rsrc_cnt).attribute20,
                        X_rsrc_tbl(X_rsrc_cnt).attribute21,
                        X_rsrc_tbl(X_rsrc_cnt).attribute22,
                        X_rsrc_tbl(X_rsrc_cnt).attribute23,
                        X_rsrc_tbl(X_rsrc_cnt).attribute24,
                        X_rsrc_tbl(X_rsrc_cnt).attribute25,
                        X_rsrc_tbl(X_rsrc_cnt).attribute26,
                        X_rsrc_tbl(X_rsrc_cnt).attribute27,
                        X_rsrc_tbl(X_rsrc_cnt).attribute28,
                        X_rsrc_tbl(X_rsrc_cnt).attribute29,
                        X_rsrc_tbl(X_rsrc_cnt).attribute30,
                        X_rsrc_tbl(X_rsrc_cnt).attribute_category,
                        X_rsrc_tbl(X_rsrc_cnt).process_uom,
                        X_rsrc_tbl(X_rsrc_cnt).min_capacity,
                        X_rsrc_tbl(X_rsrc_cnt).max_capacity,
                        X_rsrc_tbl(X_rsrc_cnt).capacity_uom,
                        X_rsrc_tbl(X_rsrc_cnt).process_parameter_1,
                        X_rsrc_tbl(X_rsrc_cnt).process_parameter_2,
                        X_rsrc_tbl(X_rsrc_cnt).process_parameter_3,
                        X_rsrc_tbl(X_rsrc_cnt).process_parameter_4,
                        X_rsrc_tbl(X_rsrc_cnt).process_parameter_5,
                        X_rsrc_tbl(X_rsrc_cnt).RESOURCE_USAGE_UOM,
                        X_rsrc_tbl(X_rsrc_cnt).RESOURCE_PROCESS_UOM,
                        X_rsrc_tbl(X_rsrc_cnt).RESOURCE_CAPACITY_UOM);--bug 4186561
      ELSE
        X_rsrc_cnt := X_rsrc_cnt - 1;
        EXIT;
      END IF;
    END LOOP;
-- Once all the resources are entered
-- Inserting the process parameters

  FOR j IN 1..X_parm_tbl.COUNT LOOP
     IF (X_actv_tbl(i).oprn_line_id = X_parm_tbl(j).oprn_line_id) THEN
        INSERT INTO GMD_OPRN_PROCESS_PARAMETERS(OPRN_LINE_ID      ,
                                                RESOURCES         ,
                                                PARAMETER_ID      ,
                                                TARGET_VALUE      ,
                                                MINIMUM_VALUE     ,
                                                MAXIMUM_VALUE     ,
                                                CREATION_DATE     ,
                                                LAST_UPDATE_LOGIN ,
                                                CREATED_BY        ,
                                                LAST_UPDATE_DATE  ,
                                                LAST_UPDATED_BY)
               VALUES                          (X_oprn_line_id,
                                                X_parm_tbl(j).resources,
                                                x_parm_tbl(j).parameter_id,
                                                x_parm_tbl(j).target_value,
                                                x_parm_tbl(j).minimum_value,
                                                x_parm_tbl(j).maximum_value,
                                                SYSDATE,
                                                P_created_by,
                                                P_created_by,
                                                SYSDATE,
                                                P_login_id);
    ELSE
      EXIT;
    END IF;
  END LOOP;

  END LOOP;

  -- If GMO is enabled, copy the new PI's from old entity to new entity
  IF l_gmo_enabled = 'Y' THEN
    GMD_PROCESS_INSTR_UTILS.build_array (p_entity_name	=> 'OPERATION',
				         p_entity_id	=> x_oprn_id,
                                         x_name_array   => l_target_name_array,
                                         x_key_array    => l_target_key_array,
			                 x_return_status => l_return_status);

    GMD_PROCESS_INSTR_UTILS.Copy_Process_Instructions  (
                                p_source_name_array      => l_source_name_array,
                                p_source_key_array       => l_source_key_array,
                                p_target_name_array      => l_target_name_array,
                                p_target_key_array       => l_target_key_array,
			        x_return_status          => l_return_status);
  END IF;

END create_operation;

/*======================================================================
--  PROCEDURE :
--   create_recipe
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for saving the
--    new recipe while versioning.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    create_recipe(P_recipe_id, X_recipe_id);
--
--  HISTORY
--    31-Jan-2003  Jeff Baird    Bug #2673008  Added call to copy_text API.
--    25-Nov-2003  Vipul Vaish   BUG#3258592
--                 Added call to procedure populate_temp_text after GMA_EDITTEXT_PKG.Copy_Text
--                 function.
--
--===================================================================== */
PROCEDURE create_recipe(p_recipe_id IN  NUMBER, x_recipe_id OUT NOCOPY NUMBER) IS
  l_rowid               VARCHAR2(18);
  X_recipe_vers NUMBER;
  X_row         NUMBER;
  l_text_code   NUMBER;
-- Bug #2673008 (JKB) Added l_text_code above.

  CURSOR Cur_get_hdr IS
    SELECT *
    FROM   gmd_recipes
    WHERE  recipe_id = p_recipe_id;
  X_hdr_rec            Cur_get_hdr%ROWTYPE;

  CURSOR Cur_process_loss IS
    SELECT *
    FROM   gmd_recipe_process_loss
    WHERE  recipe_id = p_recipe_id;
  TYPE proc_loss IS TABLE OF Cur_process_loss%ROWTYPE INDEX BY BINARY_INTEGER;
  X_proc_loss_tbl       proc_loss;

  CURSOR Cur_get_cust IS
    SELECT *
    FROM   gmd_recipe_customers
    WHERE  recipe_id = p_recipe_id;
  TYPE rcp_cust IS TABLE OF Cur_get_cust%ROWTYPE INDEX BY BINARY_INTEGER;
  X_cust_tbl    rcp_cust;

  CURSOR Cur_get_steps IS
    SELECT *
    FROM   gmd_recipe_routing_steps
    WHERE  recipe_id = p_recipe_id;
  TYPE rcp_steps IS TABLE OF Cur_get_steps%ROWTYPE INDEX BY BINARY_INTEGER;
  X_step_tbl    rcp_steps;

  CURSOR Cur_get_vr IS
    SELECT *
    FROM   gmd_recipe_validity_rules
    WHERE  recipe_id = p_recipe_id;
  TYPE rcp_vr IS TABLE OF Cur_get_vr%ROWTYPE INDEX BY BINARY_INTEGER;
  X_vr_tbl      rcp_vr;

  CURSOR Cur_get_actv IS
    SELECT *
    FROM   gmd_recipe_orgn_activities
    WHERE  recipe_id = p_recipe_id;
  TYPE rcp_actv IS TABLE OF Cur_get_actv%ROWTYPE INDEX BY BINARY_INTEGER;
  X_actv_tbl    rcp_actv;

  CURSOR Cur_get_rsrc IS
    SELECT *
    FROM   gmd_recipe_orgn_resources
    WHERE  recipe_id = p_recipe_id;
  TYPE rcp_rsrc IS TABLE OF Cur_get_rsrc%ROWTYPE INDEX BY BINARY_INTEGER;
  X_rsrc_tbl    rcp_rsrc;

  CURSOR Cur_step_mtl IS
    SELECT *
    FROM   gmd_recipe_step_materials
    WHERE  recipe_id = p_recipe_id;
  TYPE step_mtl IS TABLE OF Cur_step_mtl%ROWTYPE INDEX BY BINARY_INTEGER;
  X_stepmtl_tbl step_mtl;

  CURSOR Cur_recipe_vers IS
    SELECT MAX(recipe_version) + 1
    FROM   gmd_recipes
    WHERE  recipe_no = X_hdr_rec.recipe_no;
  CURSOR Cur_recipe_id IS
    SELECT gmd_recipe_id_s.NEXTVAL
    FROM   FND_DUAL;

  CURSOR Cur_get_old_recipe_det (V_recipe_id NUMBER) IS
    SELECT formula_id, routing_id
    FROM   gmd_recipes_b
    WHERE recipe_id = v_recipe_id;

  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);
  l_return_status       VARCHAR2(10);

  l_formula_id          NUMBER(15);
  l_routing_id          NUMBER(15);
  l_form_source_name_array   GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
  l_form_source_key_array    GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
  l_rout_source_name_array   GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
  l_rout_source_key_array    GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
  l_source_name_array   GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
  l_source_key_array    GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
  l_target_name_array   GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
  l_target_key_array    GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;

  j PLS_INTEGER;

BEGIN
  OPEN Cur_get_hdr;
  FETCH Cur_get_hdr INTO X_hdr_rec;
  CLOSE Cur_get_hdr;

  X_row := 0;
  FOR get_loss IN Cur_process_loss LOOP
    X_row := X_row + 1;
    X_proc_loss_tbl(X_row) := get_loss;
  END LOOP;

  X_row := 0;
  FOR get_cust IN Cur_get_cust LOOP
    X_row := X_row + 1;
    X_cust_tbl(X_row) := get_cust;
  END LOOP;

  X_row := 0;
  FOR get_steps IN Cur_get_steps LOOP
    X_row := X_row + 1;
    X_step_tbl(X_row) := get_steps;
  END LOOP;

  X_row := 0;
  FOR get_vr IN Cur_get_vr LOOP
    X_row := X_row + 1;
    X_vr_tbl(X_row) := get_vr;
  END LOOP;

  X_row := 0;
  FOR get_actv IN Cur_get_actv LOOP
    X_row := X_row + 1;
    X_actv_tbl(X_row) := get_actv;
  END LOOP;

  X_row := 0;
  FOR get_rsrc IN Cur_get_rsrc LOOP
    X_row := X_row + 1;
    X_rsrc_tbl(X_row) := get_rsrc;
  END LOOP;

  X_row := 0;
  FOR get_step_mtl IN Cur_step_mtl LOOP
    X_row := X_row + 1;
    X_stepmtl_tbl(X_row) := get_step_mtl;
  END LOOP;

  ROLLBACK;
  OPEN Cur_recipe_vers;
  FETCH Cur_recipe_vers INTO X_recipe_vers;
  CLOSE Cur_recipe_vers;
  OPEN Cur_recipe_id;
  FETCH Cur_recipe_id INTO x_recipe_id;
  CLOSE Cur_recipe_id;
  IF X_hdr_rec.TEXT_CODE IS NOT NULL THEN
     l_text_code := GMA_EDITTEXT_PKG.Copy_Text(X_hdr_rec.TEXT_CODE,
                    'FM_TEXT_TBL_TL',
                    'FM_TEXT_TBL_TL');
         populate_temp_text(X_hdr_rec.TEXT_CODE,2);--BUG#3258592
  ELSE
     l_text_code := NULL;
  END IF;
-- Bug #2673008 (JKB) Added call to copy_text above.
  gmd_recipes_mls.insert_row(X_ROWID                   => l_rowid,
                             X_RECIPE_ID               => x_recipe_id,
                             X_OWNER_ID                => X_hdr_rec.owner_id,
                             X_OWNER_LAB_TYPE          => X_hdr_rec.owner_lab_type,
                             X_DELETE_MARK             => 0,
                             X_TEXT_CODE               => l_text_code,
-- Bug #2673008 (JKB) Changed above.
                             X_RECIPE_NO               => X_hdr_rec.recipe_no,
                             X_RECIPE_VERSION          => X_recipe_vers,
                             X_OWNER_ORGANIZATION_ID         => X_hdr_rec.OWNER_ORGANIZATION_ID,
                             X_CREATION_ORGANIZATION_ID      => X_hdr_rec.creation_ORGANIZATION_ID,
                             X_FORMULA_ID              => X_hdr_rec.formula_id,
                             X_ROUTING_ID              => X_hdr_rec.routing_id,
                             X_PROJECT_ID              => X_hdr_rec.project_id,
                             X_RECIPE_STATUS           => 100,
                             X_CALCULATE_STEP_QUANTITY => X_hdr_rec.calculate_step_quantity,
                             X_CONTIGUOUS_IND          => X_hdr_rec.contiguous_ind,
                             X_PLANNED_PROCESS_LOSS    => X_hdr_rec.planned_process_loss,
                             X_RECIPE_DESCRIPTION      => X_hdr_rec.recipe_description,
                             X_ENHANCED_PI_IND         => X_hdr_rec.enhanced_pi_ind,
                             X_RECIPE_TYPE             => X_hdr_rec.recipe_type,
                             X_ATTRIBUTE_CATEGORY      => X_hdr_rec.attribute_category,
                             X_ATTRIBUTE1              => X_hdr_rec.attribute1,
                             X_ATTRIBUTE2              => X_hdr_rec.attribute2,
                             X_ATTRIBUTE3              => X_hdr_rec.attribute3,
                             X_ATTRIBUTE4              => X_hdr_rec.attribute4,
                             X_ATTRIBUTE5              => X_hdr_rec.attribute5,
                             X_ATTRIBUTE6              => X_hdr_rec.attribute6,
                             X_ATTRIBUTE7              => X_hdr_rec.attribute7,
                             X_ATTRIBUTE8              => X_hdr_rec.attribute8,
                             X_ATTRIBUTE9              => X_hdr_rec.attribute9,
                             X_ATTRIBUTE10             => X_hdr_rec.attribute10,
                             X_ATTRIBUTE11             => X_hdr_rec.attribute11,
                             X_ATTRIBUTE12             => X_hdr_rec.attribute12,
                             X_ATTRIBUTE13             => X_hdr_rec.attribute13,
                             X_ATTRIBUTE14             => X_hdr_rec.attribute14,
                             X_ATTRIBUTE15             => X_hdr_rec.attribute15,
                             X_ATTRIBUTE16             => X_hdr_rec.attribute16,
                             X_ATTRIBUTE17             => X_hdr_rec.attribute17,
                             X_ATTRIBUTE18             => X_hdr_rec.attribute18,
                             X_ATTRIBUTE19             => X_hdr_rec.attribute19,
                             X_ATTRIBUTE20             => X_hdr_rec.attribute20,
                             X_ATTRIBUTE21             => X_hdr_rec.attribute21,
                             X_ATTRIBUTE22             => X_hdr_rec.attribute22,
                             X_ATTRIBUTE23             => X_hdr_rec.attribute23,
                             X_ATTRIBUTE24             => X_hdr_rec.attribute24,
                             X_ATTRIBUTE25             => X_hdr_rec.attribute25,
                             X_ATTRIBUTE26             => X_hdr_rec.attribute26,
                             X_ATTRIBUTE27             => X_hdr_rec.attribute27,
                             X_ATTRIBUTE28             => X_hdr_rec.attribute28,
                             X_ATTRIBUTE29             => X_hdr_rec.attribute29,
                             X_ATTRIBUTE30             => X_hdr_rec.attribute30,
                             X_CREATION_DATE           => SYSDATE,
                             X_CREATED_BY              => P_created_by,
                             X_LAST_UPDATE_DATE        => SYSDATE,
                             X_LAST_UPDATED_BY         => P_created_by,
                             X_LAST_UPDATE_LOGIN       => P_login_id,
                             X_FIXED_PROCESS_LOSS    => X_hdr_rec.fixed_process_loss, /* B6811759 */
                             X_FIXED_PROCESS_LOSS_UOM  => X_hdr_rec.fixed_process_loss_uom
				);
  FOR i IN 1..X_proc_loss_tbl.count LOOP
    IF X_proc_loss_tbl(i).text_code IS NOT NULL THEN
       l_text_code := GMA_EDITTEXT_PKG.Copy_Text(X_proc_loss_tbl(i).text_code,
                      'FM_TEXT_TBL_TL',
                      'FM_TEXT_TBL_TL');
         populate_temp_text(X_proc_loss_tbl(i).text_code,2);--BUG#3258592
    ELSE
       l_text_code := NULL;
    END IF;
-- Bug #2673008 (JKB) Added call to copy_text above.
	/* B6811759 */
    INSERT INTO gmd_recipe_process_loss(recipe_id, organization_id, process_loss,
                    creation_date, created_by,
                    last_updated_by, last_update_date, last_update_login,
                    recipe_process_loss_id, text_code,fixed_process_loss,fixed_process_loss_uom)
    VALUES         (x_recipe_id, X_proc_loss_tbl(i).organization_id,
                    X_proc_loss_tbl(i).process_loss,
                    SYSDATE, P_created_by, P_created_by, SYSDATE, P_login_id,
                    gmd_recipe_process_loss_id_s.NEXTVAL, l_text_code,
		X_proc_loss_tbl(i).fixed_process_loss,
		X_proc_loss_tbl(i).fixed_process_loss_uom);
-- Bug #2673008 (JKB) Changed above.
  END LOOP;
  FOR i IN 1..X_cust_tbl.count LOOP
    IF X_cust_tbl(i).text_code IS NOT NULL THEN
       l_text_code := GMA_EDITTEXT_PKG.Copy_Text(X_cust_tbl(i).text_code,
                      'FM_TEXT_TBL_TL',
                      'FM_TEXT_TBL_TL');
         populate_temp_text(X_cust_tbl(i).text_code,2);--BUG#3258592
    ELSE
       l_text_code := NULL;
    END IF;
-- Bug #2673008 (JKB) Added call to copy_text above.
    INSERT INTO gmd_recipe_customers(recipe_id, customer_id,org_id,site_id, created_by,
                    creation_date, last_updated_by,
                    last_update_login, text_code, last_update_date)
    VALUES         (x_recipe_id, X_cust_tbl(i).customer_id,X_cust_tbl(i).org_id,
                    X_cust_tbl(i).site_id,P_created_by,
                    SYSDATE, P_created_by, P_login_id, l_text_code, SYSDATE);
-- Bug #2673008 (JKB) Changed above.
  END LOOP;
  FOR i IN 1..X_step_tbl.count LOOP
    IF X_step_tbl(i).text_code IS NOT NULL THEN
       l_text_code := GMA_EDITTEXT_PKG.Copy_Text(X_step_tbl(i).text_code,
                      'FM_TEXT_TBL_TL',
                      'FM_TEXT_TBL_TL');
         populate_temp_text(X_step_tbl(i).text_code,2);--BUG#3258592
    ELSE
       l_text_code := NULL;
    END IF;
-- Bug #2673008 (JKB) Added call to copy_text above.
    INSERT INTO gmd_recipe_routing_steps(recipe_id, routingstep_id, step_qty,
                    created_by, creation_date,
                    last_update_date, last_update_login, text_code,
                    last_updated_by, attribute1, attribute2, attribute3,
                    attribute4, attribute5, attribute6, attribute7, attribute8,
                    attribute9, attribute10, attribute11, attribute12,
                    attribute13, attribute14, attribute15, attribute16,
                    attribute17, attribute18, attribute19, attribute20,
                    attribute21, attribute22, attribute23, attribute24,
                    attribute25, attribute26, attribute27, attribute28,
                    attribute29, attribute30, attribute_category, mass_std_uom,
                    volume_std_uom, volume_qty, mass_qty)
    VALUES         (x_recipe_id, X_step_tbl(i).routingstep_id,
                    X_step_tbl(i).step_qty, P_created_by, SYSDATE, SYSDATE,
                    P_login_id, l_text_code, P_created_by,
-- Bug #2673008 (JKB) Changed above.
                    X_step_tbl(i).attribute1, X_step_tbl(i).attribute2,
                    X_step_tbl(i).attribute3, X_step_tbl(i).attribute4,
                    X_step_tbl(i).attribute5, X_step_tbl(i).attribute6,
                    X_step_tbl(i).attribute7, X_step_tbl(i).attribute8,
                    X_step_tbl(i).attribute9, X_step_tbl(i).attribute10,
                    X_step_tbl(i).attribute11, X_step_tbl(i).attribute12,
                    X_step_tbl(i).attribute13, X_step_tbl(i).attribute14,
                    X_step_tbl(i).attribute15, X_step_tbl(i).attribute16,
                    X_step_tbl(i).attribute17, X_step_tbl(i).attribute18,
                    X_step_tbl(i).attribute19, X_step_tbl(i).attribute20,
                    X_step_tbl(i).attribute21, X_step_tbl(i).attribute22,
                    X_step_tbl(i).attribute23, X_step_tbl(i).attribute24,
                    X_step_tbl(i).attribute25, X_step_tbl(i).attribute26,
                    X_step_tbl(i).attribute27, X_step_tbl(i).attribute28,
                    X_step_tbl(i).attribute29, X_step_tbl(i).attribute30,
                    X_step_tbl(i).attribute_category,
                    X_step_tbl(i).mass_std_uom, X_step_tbl(i).volume_std_uom,
                    X_step_tbl(i).volume_qty, X_step_tbl(i).mass_qty);
  END LOOP;
  FOR i IN 1..X_vr_tbl.count LOOP
    IF X_vr_tbl(i).text_code IS NOT NULL THEN
       l_text_code := GMA_EDITTEXT_PKG.Copy_Text(X_vr_tbl(i).text_code,
                      'FM_TEXT_TBL_TL',
                      'FM_TEXT_TBL_TL');
         populate_temp_text(X_vr_tbl(i).text_code,2);--BUG#3258592
    ELSE
       l_text_code := NULL;
    END IF;
-- Bug #2673008 (JKB) Added call to copy_text above.
    INSERT INTO gmd_recipe_validity_rules(recipe_validity_rule_id, recipe_id,
                    organization_id, inventory_item_id, revision, recipe_use, preference,
                    start_date, end_date, min_qty, max_qty, std_qty, detail_uom,
                    inv_min_qty, inv_max_qty, text_code, attribute_category,
                    attribute1, attribute2, attribute3, attribute4, attribute5,
                    attribute6, attribute7, attribute8, attribute9,
                    attribute10, attribute11, attribute12,  attribute13,
                    attribute14,  attribute15, attribute16, attribute17,
                    attribute18, attribute19, attribute20, attribute21,
                    attribute22, attribute23, attribute24, attribute25,
                    attribute26, attribute27, attribute28, attribute29,
                    attribute30, created_by, creation_date,
                    last_updated_by, last_update_date, last_update_login,
                    delete_mark, lab_type, validity_rule_status)
    VALUES         (gmd_recipe_validity_id_s.NEXTVAL, x_recipe_id,
                    X_vr_tbl(i).organization_id, X_vr_tbl(i).inventory_item_id,
                    X_vr_tbl(i).revision,X_vr_tbl(i).recipe_use, X_vr_tbl(i).preference,
                    X_vr_tbl(i).start_date, X_vr_tbl(i).end_date,
                    X_vr_tbl(i).min_qty, X_vr_tbl(i).max_qty,
                    X_vr_tbl(i).std_qty, X_vr_tbl(i).detail_uom,
                    X_vr_tbl(i).inv_min_qty, X_vr_tbl(i).inv_max_qty,
                    l_text_code, X_vr_tbl(i).attribute_category,
-- Bug #2673008 (JKB) Changed above.
                    X_vr_tbl(i).attribute1, X_vr_tbl(i).attribute2,
                    X_vr_tbl(i).attribute3, X_vr_tbl(i).attribute4,
                    X_vr_tbl(i).attribute5, X_vr_tbl(i).attribute6,
                    X_vr_tbl(i).attribute7, X_vr_tbl(i).attribute8,
                    X_vr_tbl(i).attribute9, X_vr_tbl(i).attribute10,
                    X_vr_tbl(i).attribute11, X_vr_tbl(i).attribute12,
                    X_vr_tbl(i).attribute13, X_vr_tbl(i).attribute14,
                    X_vr_tbl(i).attribute15, X_vr_tbl(i).attribute16,
                    X_vr_tbl(i).attribute17, X_vr_tbl(i).attribute18,
                    X_vr_tbl(i).attribute19, X_vr_tbl(i).attribute20,
                    X_vr_tbl(i).attribute21, X_vr_tbl(i).attribute22,
                    X_vr_tbl(i).attribute23, X_vr_tbl(i).attribute24,
                    X_vr_tbl(i).attribute25, X_vr_tbl(i).attribute26,
                    X_vr_tbl(i).attribute27, X_vr_tbl(i).attribute28,
                    X_vr_tbl(i).attribute29, X_vr_tbl(i).attribute30,
                    P_created_by, SYSDATE, P_created_by, SYSDATE,
                    P_login_id, 0, X_vr_tbl(i).lab_type, 100);
  END LOOP;
  FOR i IN 1..X_actv_tbl.count LOOP
    IF X_actv_tbl(i).text_code IS NOT NULL THEN
       l_text_code := GMA_EDITTEXT_PKG.Copy_Text(X_actv_tbl(i).text_code,
                      'FM_TEXT_TBL_TL',
                      'FM_TEXT_TBL_TL');
         populate_temp_text(X_actv_tbl(i).text_code,2);--BUG#3258592
    ELSE
       l_text_code := NULL;
    END IF;
-- Bug #2673008 (JKB) Added call to copy_text above.
    INSERT INTO gmd_recipe_orgn_activities(recipe_id, routingstep_id,
                    activity_factor, attribute_category, attribute1,
                    created_by, creation_date, last_updated_by,
                    last_update_date, last_update_login, organization_id, attribute2,
                    attribute3, attribute4, attribute5, attribute6, attribute7,
                    attribute8, attribute9, attribute10, attribute11,
                    attribute12, attribute13, attribute14, attribute15,
                    attribute16, attribute17, attribute18, attribute19,
                    attribute20, attribute21, attribute22, attribute23,
                    attribute24, attribute25, attribute26, attribute27,
                    attribute28, attribute29, attribute30, text_code,
                    oprn_line_id)
    VALUES         (x_recipe_id, X_actv_tbl(i).routingstep_id,
                    X_actv_tbl(i).activity_factor,
                    X_actv_tbl(i).attribute_category, X_actv_tbl(i).attribute1,
                    P_created_by, SYSDATE, P_created_by, SYSDATE, P_login_id,
                    X_actv_tbl(i).organization_id, X_actv_tbl(i).attribute2,
                    X_actv_tbl(i).attribute3, X_actv_tbl(i).attribute4,
                    X_actv_tbl(i).attribute5, X_actv_tbl(i).attribute6,
                    X_actv_tbl(i).attribute7, X_actv_tbl(i).attribute8,
                    X_actv_tbl(i).attribute9, X_actv_tbl(i).attribute10,
                    X_actv_tbl(i).attribute11, X_actv_tbl(i).attribute12,
                    X_actv_tbl(i).attribute13, X_actv_tbl(i).attribute14,
                    X_actv_tbl(i).attribute15, X_actv_tbl(i).attribute16,
                    X_actv_tbl(i).attribute17, X_actv_tbl(i).attribute18,
                    X_actv_tbl(i).attribute19, X_actv_tbl(i).attribute20,
                    X_actv_tbl(i).attribute21, X_actv_tbl(i).attribute22,
                    X_actv_tbl(i).attribute23, X_actv_tbl(i).attribute24,
                    X_actv_tbl(i).attribute25, X_actv_tbl(i).attribute26,
                    X_actv_tbl(i).attribute27, X_actv_tbl(i).attribute28,
                    X_actv_tbl(i).attribute29, X_actv_tbl(i).attribute30,
                    l_text_code, X_actv_tbl(i).oprn_line_id);
-- Bug #2673008 (JKB) Changed above.
  END LOOP;
  FOR i IN 1..X_rsrc_tbl.count LOOP
    IF X_rsrc_tbl(i).text_code IS NOT NULL THEN
       l_text_code := GMA_EDITTEXT_PKG.Copy_Text(X_rsrc_tbl(i).text_code,
                      'FM_TEXT_TBL_TL',
                      'FM_TEXT_TBL_TL');
         populate_temp_text(X_rsrc_tbl(i).text_code,2);--BUG#3258592
    ELSE
       l_text_code := NULL;
    END IF;
-- Bug #2673008 (JKB) Added call to copy_text above.
    INSERT INTO gmd_recipe_orgn_resources(recipe_id, organization_id, routingstep_id,
                    oprn_line_id, resources, creation_date, created_by,
                    last_updated_by, last_update_date, min_capacity,
                    max_capacity, last_update_login, text_code, attribute1,
                    attribute2, attribute3, attribute4, attribute5, attribute6,
                    attribute7, attribute8, attribute9, attribute10,
                    attribute11, attribute12, attribute13, attribute14,
                    attribute15, attribute16, attribute17, attribute18,
                    attribute19, attribute20, attribute21, attribute22,
                    attribute23, attribute24, attribute25, attribute26,
                    attribute27, attribute28, attribute29, attribute30,
                    attribute_category, process_parameter_5,
                    process_parameter_4, process_parameter_3,
                    process_parameter_2, process_parameter_1, process_um,
                    usage_uom, resource_usage, process_qty)
    VALUES         (x_recipe_id, X_rsrc_tbl(i).organization_id,
                    X_rsrc_tbl(i).routingstep_id, X_rsrc_tbl(i).oprn_line_id,
                    X_rsrc_tbl(i).resources, SYSDATE, P_created_by,
                    P_created_by, SYSDATE, X_rsrc_tbl(i).min_capacity,
                    X_rsrc_tbl(i).max_capacity, P_login_id, l_text_code,
-- Bug #2673008 (JKB) Changed above.
                    X_rsrc_tbl(i).attribute1, X_rsrc_tbl(i).attribute2,
                    X_rsrc_tbl(i).attribute3, X_rsrc_tbl(i).attribute4,
                    X_rsrc_tbl(i).attribute5, X_rsrc_tbl(i).attribute6,
                    X_rsrc_tbl(i).attribute7, X_rsrc_tbl(i).attribute8,
                    X_rsrc_tbl(i).attribute9, X_rsrc_tbl(i).attribute10,
                    X_rsrc_tbl(i).attribute11, X_rsrc_tbl(i).attribute12,
                    X_rsrc_tbl(i).attribute13, X_rsrc_tbl(i).attribute14,
                    X_rsrc_tbl(i).attribute15, X_rsrc_tbl(i).attribute16,
                    X_rsrc_tbl(i).attribute17, X_rsrc_tbl(i).attribute18,
                    X_rsrc_tbl(i).attribute19, X_rsrc_tbl(i).attribute20,
                    X_rsrc_tbl(i).attribute21, X_rsrc_tbl(i).attribute22,
                    X_rsrc_tbl(i).attribute23, X_rsrc_tbl(i).attribute24,
                    X_rsrc_tbl(i).attribute25, X_rsrc_tbl(i).attribute26,
                    X_rsrc_tbl(i).attribute27, X_rsrc_tbl(i).attribute28,
                    X_rsrc_tbl(i).attribute29, X_rsrc_tbl(i).attribute30,
                    X_rsrc_tbl(i).attribute_category,
                    X_rsrc_tbl(i).process_parameter_5,
                    X_rsrc_tbl(i).process_parameter_4,
                    X_rsrc_tbl(i).process_parameter_3,
                    X_rsrc_tbl(i).process_parameter_2,
                    X_rsrc_tbl(i).process_parameter_1,
                    X_rsrc_tbl(i).process_um, X_rsrc_tbl(i).usage_uom,
                    X_rsrc_tbl(i).resource_usage, X_rsrc_tbl(i).process_qty);
  END LOOP;
  FOR i IN 1..X_stepmtl_tbl.count LOOP
    IF X_stepmtl_tbl(i).text_code IS NOT NULL THEN
       l_text_code := GMA_EDITTEXT_PKG.Copy_Text(X_stepmtl_tbl(i).text_code,
                      'FM_TEXT_TBL_TL',
                      'FM_TEXT_TBL_TL');
         populate_temp_text(X_stepmtl_tbl(i).text_code,2);--BUG#3258592
    ELSE
       l_text_code := NULL;
    END IF;
-- Bug #2673008 (JKB) Added call to copy_text above.
    INSERT INTO gmd_recipe_step_materials(recipe_id, formulaline_id,
                    routingstep_id, text_code, creation_date, created_by,
-- Bug #2673008 (JKB) Changed above.
                    last_updated_by, last_update_date, last_update_login)
    VALUES         (x_recipe_id, X_stepmtl_tbl(i).formulaline_id,
                    X_stepmtl_tbl(i).routingstep_id, l_text_code, SYSDATE,
                    P_created_by, P_created_by, SYSDATE, P_login_id);
  END LOOP;

  IF gmo_setup_grp.is_gmo_enabled = 'Y' THEN
  -- If GMO is enabled, copy the new PI's from old entity to new entity
    OPEN Cur_get_old_recipe_det(p_recipe_id);
    FETCH Cur_get_old_recipe_det INTO l_formula_id, l_routing_id;
    CLOSE Cur_get_old_recipe_det;

    IF X_hdr_rec.formula_id = l_formula_id THEN
      GMD_PROCESS_INSTR_UTILS.build_array (p_entity_name   => 'FORMULA',
	  			           p_entity_id	   => l_formula_id,
                                           x_name_array    => l_form_source_name_array,
                                           x_key_array     => l_form_source_key_array,
			                   x_return_status => l_return_status);

      FOR i IN 1..l_form_source_key_array.COUNT
      LOOP
        l_source_name_array(i) := l_form_source_name_array(i);
        l_source_key_array(i) := p_recipe_id|| '$' ||l_form_source_key_array(i);
        l_target_name_array(i) := l_form_source_name_array(i);
        l_target_key_array(i) := x_recipe_id|| '$' ||l_form_source_key_array(i);
      END LOOP;
    END IF;

    IF (X_hdr_rec.routing_id IS NOT NULL) AND
       (X_hdr_rec.routing_id = l_routing_id) THEN
      GMD_PROCESS_INSTR_UTILS.build_array (p_entity_name   => 'ROUTING',
	  			           p_entity_id	   => l_routing_id,
                                           x_name_array    => l_rout_source_name_array,
                                           x_key_array     => l_rout_source_key_array,
			                   x_return_status => l_return_status);

      j := l_source_name_array.COUNT;
      FOR i IN 1..l_rout_source_key_array.COUNT
      LOOP
        j := j + 1;
        l_source_name_array(j) := l_rout_source_name_array(i);
        l_source_key_array(j) := p_recipe_id|| '$' ||l_rout_source_key_array(i);
        l_target_name_array(j) := l_rout_source_name_array(i);
        l_target_key_array(j) := x_recipe_id|| '$' ||l_rout_source_key_array(i);
      END LOOP;
    END IF;

    GMD_PROCESS_INSTR_UTILS.Copy_Process_Instructions  (
                                p_source_name_array      => l_source_name_array,
                                p_source_key_array       => l_source_key_array,
                                p_target_name_array      => l_target_name_array,
                                p_target_key_array       => l_target_key_array,
			        x_return_status          => l_return_status);
  END IF;

END create_recipe;

/*======================================================================
--  PROCEDURE :
--   create_formula
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for saving the
--    new formula while versioning.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    create_formula(P_formula_id, X_formula_id);
--
--  HISTORY
--    31-Jan-2003  Jeff Baird    Bug #2673008  Added call to copy_text API.
--    28-AUG-2003  Rameshwar     BUG#3077938
--    Added a call to procedure GMD_COMMON_VAL.calculate_total_qty to calculate the total quantity,
--    and update the formula master with the total output quantity.
--    25-Nov-2003  Vipul Vaish   BUG#3258592
--                 Added call to procedure populate_temp_text after GMA_EDITTEXT_PKG.Copy_Text
--                 function.
--
--    07-07-2004   kkillams      Bug 3738941, added new validation to copy the attachments.
--    02-20-2007   Thomas        Added Auto_Product_Calc to be passed to the insert_row.
--===================================================================== */
PROCEDURE create_formula(p_formula_id IN  NUMBER, x_formula_id OUT NOCOPY NUMBER) IS
  X_formula_vers        NUMBER;
  X_row         NUMBER := 0;
  l_rowid               VARCHAR2(18);
  l_text_code   NUMBER;
  --BEGIN BUG#3077938
  --Created new variables to retrieve the output quantity from GMD_COMMON_VAL.calculate_total_qty procedure
  x_return_status VARCHAR2(20);
  X_msg_cnt       NUMBER;
  X_msg_dat       VARCHAR2(100);
  X_status        VARCHAR2(1);
  l_product_qty   NUMBER;
  l_ing_qty       NUMBER;
  l_uom           mtl_units_of_measure.unit_of_measure%TYPE;
  --END BUG#3077938

-- Bug #2673008 (JKB) Added l_text_code above.
  CURSOR Cur_formula_id IS
    SELECT gem5_formula_id_s.NEXTVAL
    FROM   FND_DUAL;
  CURSOR Cur_get_hdr IS
    SELECT *
    FROM   fm_form_mst
    WHERE  formula_id = p_formula_id;
  X_hdr_rec       Cur_get_hdr%ROWTYPE;
  CURSOR Cur_formula_vers IS
    SELECT MAX(formula_vers) + 1
    FROM   fm_form_mst
    WHERE  formula_no = X_hdr_rec.formula_no;

  CURSOR Cur_get_dtl IS
    SELECT *
    FROM   fm_matl_dtl
    WHERE  formula_id = p_formula_id;

  --kkillams,bug 3738941
  CURSOR cur_form_att(cp_entity_name fnd_attached_documents.entity_name%TYPE,
                      cp_pk1_value   fnd_attached_documents.pk1_value%TYPE) IS
    SELECT 1
    FROM  fnd_attached_documents fad
    WHERE fad.entity_name = cp_entity_name
    AND   fad.pk1_value   = cp_pk1_value;

  l_formulaline_id   fm_matl_dtl.formulaline_id%TYPE;
  l_dummy            NUMBER;

  TYPE detail_tab IS TABLE OF Cur_get_dtl%ROWTYPE INDEX BY BINARY_INTEGER;
  X_dtl_tbl detail_tab;

  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);
  l_return_status       VARCHAR2(10);
  l_gmo_enabled         VARCHAR2(1);
  l_source_name_array   GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
  l_source_key_array    GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
  l_target_name_array   GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;
  l_target_key_array    GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255;

BEGIN
  OPEN Cur_get_hdr;
  FETCH Cur_get_hdr INTO X_hdr_rec;
  CLOSE Cur_get_hdr;

  FOR get_rec IN Cur_get_dtl LOOP
    X_row := X_row + 1;
    X_dtl_tbl(X_row) := get_rec;
  END LOOP;

  /* Check if GMO is enabled */
  l_gmo_enabled :=  gmo_setup_grp.is_gmo_enabled;
  IF l_gmo_enabled = 'Y' THEN
    GMD_PROCESS_INSTR_UTILS.build_array (p_entity_name	=> 'FORMULA',
				         p_entity_id	=> p_formula_id,
                                         x_name_array   => l_source_name_array,
                                         x_key_array    => l_source_key_array,
			                 x_return_status => l_return_status);
  END IF;

  ROLLBACK;

  OPEN Cur_formula_vers;
  FETCH Cur_formula_vers INTO X_formula_vers;
  CLOSE Cur_formula_vers;

  OPEN Cur_formula_id;
  FETCH Cur_formula_id INTO x_formula_id;
  CLOSE Cur_formula_id;
  IF X_hdr_rec.TEXT_CODE IS NOT NULL THEN
     l_text_code := GMA_EDITTEXT_PKG.Copy_Text(X_hdr_rec.TEXT_CODE,
                    'FM_TEXT_TBL_TL',
                    'FM_TEXT_TBL_TL');
         populate_temp_text(X_hdr_rec.TEXT_CODE,2);--BUG#3258592
  ELSE
     l_text_code := NULL;
  END IF;
-- Bug #2673008 (JKB) Added call to copy_text above.
  FM_FORM_MST_MLS.INSERT_ROW(
                  X_ROWID               => l_rowid,
                  X_FORMULA_ID          => X_formula_id,
                  X_MASTER_FORMULA_ID => Null,
                  X_OWNER_ORGANIZATION_ID => x_hdr_rec.OWNER_ORGANIZATION_ID,
                  X_TOTAL_INPUT_QTY     => 0,
                  X_TOTAL_OUTPUT_QTY    => 0,
                  X_YIELD_UOM           => NULL,
                  X_FORMULA_STATUS      => 100,
                  X_OWNER_ID            => X_hdr_rec.created_by,
                  X_PROJECT_ID          => NULL,
                  X_TEXT_CODE           => l_text_code,
                  X_DELETE_MARK         => X_hdr_rec.DELETE_MARK,
                  X_FORMULA_NO          => X_hdr_rec.formula_no,
                  X_FORMULA_VERS        => X_formula_vers,
                  X_FORMULA_TYPE        => X_hdr_rec.FORMULA_TYPE,
                  X_IN_USE              => 0,
                  X_INACTIVE_IND        => 0,
                  X_SCALE_TYPE          => X_hdr_rec.SCALE_TYPE,
                  X_FORMULA_CLASS       => X_hdr_rec.FORMULA_CLASS,
                  X_FMCONTROL_CLASS     => X_hdr_rec.FMCONTROL_CLASS,
                  X_ATTRIBUTE_CATEGORY  => X_hdr_rec.ATTRIBUTE_CATEGORY,
                  X_ATTRIBUTE1          => X_hdr_rec.ATTRIBUTE1,
                  X_ATTRIBUTE2          => X_hdr_rec.ATTRIBUTE2,
                  X_ATTRIBUTE3          => X_hdr_rec.ATTRIBUTE3,
                  X_ATTRIBUTE4          => X_hdr_rec.ATTRIBUTE4,
                  X_ATTRIBUTE5          => X_hdr_rec.ATTRIBUTE5,
                  X_ATTRIBUTE6          => X_hdr_rec.ATTRIBUTE6,
                  X_ATTRIBUTE7          => X_hdr_rec.ATTRIBUTE7,
                  X_ATTRIBUTE8          => X_hdr_rec.ATTRIBUTE8,
                  X_ATTRIBUTE9          => X_hdr_rec.ATTRIBUTE9,
                  X_ATTRIBUTE10          => X_hdr_rec.ATTRIBUTE10,
                  X_ATTRIBUTE11          => X_hdr_rec.ATTRIBUTE11,
                  X_ATTRIBUTE12          => X_hdr_rec.ATTRIBUTE12,
                  X_ATTRIBUTE13          => X_hdr_rec.ATTRIBUTE13,
                  X_ATTRIBUTE14          => X_hdr_rec.ATTRIBUTE14,
                  X_ATTRIBUTE15          => X_hdr_rec.ATTRIBUTE15,
                  X_ATTRIBUTE16          => X_hdr_rec.ATTRIBUTE16,
                  X_ATTRIBUTE17          => X_hdr_rec.ATTRIBUTE17,
                  X_ATTRIBUTE18          => X_hdr_rec.ATTRIBUTE18,
                  X_ATTRIBUTE19          => X_hdr_rec.ATTRIBUTE19,
                  X_ATTRIBUTE20          => X_hdr_rec.ATTRIBUTE20,
                  X_ATTRIBUTE21          => X_hdr_rec.ATTRIBUTE21,
                  X_ATTRIBUTE22          => X_hdr_rec.ATTRIBUTE22,
                  X_ATTRIBUTE23          => X_hdr_rec.ATTRIBUTE23,
                  X_ATTRIBUTE24          => X_hdr_rec.ATTRIBUTE24,
                  X_ATTRIBUTE25          => X_hdr_rec.ATTRIBUTE25,
                  X_ATTRIBUTE26          => X_hdr_rec.ATTRIBUTE26,
                  X_ATTRIBUTE27          => X_hdr_rec.ATTRIBUTE27,
                  X_ATTRIBUTE28          => X_hdr_rec.ATTRIBUTE28,
                  X_ATTRIBUTE29          => X_hdr_rec.ATTRIBUTE29,
                  X_ATTRIBUTE30          => X_hdr_rec.ATTRIBUTE30,
                  X_FORMULA_DESC1        => X_hdr_rec.FORMULA_DESC1,
                  X_FORMULA_DESC2        => X_hdr_rec.FORMULA_DESC2,
                  X_CREATION_DATE        => SYSDATE,
                  X_CREATED_BY           => P_created_by,
                  X_LAST_UPDATE_DATE     => SYSDATE,
                  X_LAST_UPDATED_BY      => P_created_by,
                  X_LAST_UPDATE_LOGIN    => P_login_id,
                  X_AUTO_PRODUCT_CALC    => X_hdr_rec.auto_product_calc);

     --kkillams, Bug 3738941
     --Added following validation to copy the attachments
     OPEN cur_form_att('FM_FORM_MST_B',to_char(p_formula_id));
     FETCH cur_form_att INTO l_dummy;
     IF cur_form_att%FOUND THEN
        FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(
          X_from_entity_name              => 'FM_FORM_MST_B',
          X_from_pk1_value                => TO_CHAR(p_formula_id),
          X_from_pk2_value                => NULL,
          X_from_pk3_value                => NULL,
          X_from_pk4_value                => NULL,
          X_from_pk5_value                => NULL,
          X_to_entity_name                => 'FM_FORM_MST_B',
          X_to_pk1_value                  => TO_CHAR(X_formula_id),
          X_to_pk2_value                  => NULL,
          X_to_pk3_value                  => NULL,
          X_to_pk4_value                  => NULL,
          X_to_pk5_value                  => NULL,
          X_created_by                    => FND_GLOBAL.USER_ID,
          X_last_update_login             => FND_GLOBAL.LOGIN_ID,
          X_program_application_id        => NULL,
          X_program_id                    => NULL,
          X_request_id                    => NULL );
       END IF;
       CLOSE cur_form_att;


  FOR i IN 1..X_dtl_tbl.count LOOP
     IF X_dtl_tbl(i).text_code IS NOT NULL THEN
        l_text_code := GMA_EDITTEXT_PKG.Copy_Text(X_dtl_tbl(i).text_code,
                       'FM_TEXT_TBL_TL',
                       'FM_TEXT_TBL_TL');
         populate_temp_text(X_dtl_tbl(i).text_code,2);--BUG#3258592
     ELSE
        l_text_code := NULL;
     END IF;
--
-- Bug #2673008 (JKB) Added call to copy_text above.
    INSERT INTO fm_matl_dtl(formulaline_id, formula_id, line_type, line_no,
                   inventory_item_id, qty, detail_uom,revision, release_type, scrap_factor,
                   scale_type, cost_alloc, phantom_type, rework_type, text_code,
                   organization_id,last_updated_by, created_by, last_update_date, creation_date,
                   last_update_login, attribute1, attribute2, attribute3,
                   attribute4, attribute5, attribute6, attribute7, attribute8,
                   attribute9, attribute10, attribute11, attribute12,
                   attribute13, attribute14, attribute15, attribute16,
                   attribute17, attribute18, attribute19, attribute20,
                   attribute21, attribute22, attribute23, attribute24,
                   attribute25, attribute26, attribute27, attribute28,
                   attribute29, attribute30, attribute_category, tpformula_id,
                   scale_multiple, contribute_yield_ind, scale_uom,
                   contribute_step_qty_ind, scale_rounding_variance)
    VALUES        (gem5_formulaline_id_s.NEXTVAL, X_formula_id,
                   X_dtl_tbl(i).line_type, X_dtl_tbl(i).line_no,
                   X_dtl_tbl(i).inventory_item_id, X_dtl_tbl(i).qty,
                   X_dtl_tbl(i).detail_uom, X_dtl_tbl(i).revision, X_dtl_tbl(i).release_type,
                   X_dtl_tbl(i).scrap_factor, X_dtl_tbl(i).scale_type,
                   X_dtl_tbl(i).cost_alloc, X_dtl_tbl(i).phantom_type,
                   X_dtl_tbl(i).rework_type, l_text_code,X_dtl_tbl(i).organization_id,
-- Bug #2673008 (JKB) Changed above.
                   P_created_by, P_created_by, SYSDATE, SYSDATE, P_login_id,
                   X_dtl_tbl(i).attribute1, X_dtl_tbl(i).attribute2,
                   X_dtl_tbl(i).attribute3, X_dtl_tbl(i).attribute4,
                   X_dtl_tbl(i).attribute5, X_dtl_tbl(i).attribute6,
                   X_dtl_tbl(i).attribute7, X_dtl_tbl(i).attribute8,
                   X_dtl_tbl(i).attribute9, X_dtl_tbl(i).attribute10,
                   X_dtl_tbl(i).attribute11, X_dtl_tbl(i).attribute12,
                   X_dtl_tbl(i).attribute13, X_dtl_tbl(i).attribute14,
                   X_dtl_tbl(i).attribute15, X_dtl_tbl(i).attribute16,
                   X_dtl_tbl(i).attribute17, X_dtl_tbl(i).attribute18,
                   X_dtl_tbl(i).attribute19, X_dtl_tbl(i).attribute20,
                   X_dtl_tbl(i).attribute21, X_dtl_tbl(i).attribute22,
                   X_dtl_tbl(i).attribute23, X_dtl_tbl(i).attribute24,
                   X_dtl_tbl(i).attribute25, X_dtl_tbl(i).attribute26,
                   X_dtl_tbl(i).attribute27, X_dtl_tbl(i).attribute28,
                   X_dtl_tbl(i).attribute29, X_dtl_tbl(i).attribute30,
                   X_dtl_tbl(i).attribute_category, X_dtl_tbl(i).tpformula_id,
                   X_dtl_tbl(i).scale_multiple,
                   X_dtl_tbl(i).contribute_yield_ind, X_dtl_tbl(i).scale_uom,
                   X_dtl_tbl(i).contribute_step_qty_ind,
                   X_dtl_tbl(i).scale_rounding_variance)
                   RETURNING formulaline_id INTO l_formulaline_id;
             --BEGIN BUG#3077938
             /* Added a new procedure to calculate the total quantity and update the
                formula master with the total output quantity. */

             GMD_COMMON_VAL.calculate_total_qty(
                  formula_id       => X_formula_id,
                  x_product_qty    => l_product_qty ,
                  x_ingredient_qty => l_ing_qty ,
                  x_uom            => l_uom ,
                  x_return_status  => x_return_status ,
                  x_msg_count      => X_msg_cnt ,
                  x_msg_data       => x_msg_dat );


             /* Update formula header table with TOQ and TIQ */
             UPDATE fm_form_mst_b
             SET total_output_qty = l_product_qty,
                 total_input_qty  = l_ing_qty,
                 yield_uom        = l_uom
             WHERE formula_id     = X_formula_id;
             --END BUG#3077938
     --kkillams, Bug 3738941
     --Added following validation to copy the attachments
     OPEN cur_form_att('FM_MATL_DTL',to_char(X_dtl_tbl(i).formulaline_id));
     FETCH cur_form_att INTO l_dummy;
     IF cur_form_att%FOUND THEN
        FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(
          X_from_entity_name              => 'FM_MATL_DTL',
          X_from_pk1_value                => TO_CHAR(X_dtl_tbl(i).formulaline_id),
          X_from_pk2_value                => NULL,
          X_from_pk3_value                => NULL,
          X_from_pk4_value                => NULL,
          X_from_pk5_value                => NULL,
          X_to_entity_name                => 'FM_MATL_DTL',
          X_to_pk1_value                  => TO_CHAR(l_formulaline_id),
          X_to_pk2_value                  => NULL,
          X_to_pk3_value                  => NULL,
          X_to_pk4_value                  => NULL,
          X_to_pk5_value                  => NULL,
          X_created_by                    => FND_GLOBAL.USER_ID,
          X_last_update_login             => FND_GLOBAL.LOGIN_ID,
          X_program_application_id        => NULL,
          X_program_id                    => NULL,
          X_request_id                    => NULL );
       END IF;
       CLOSE cur_form_att;
  END LOOP;

  -- If GMO is enabled, copy the new PI's from old entity to new entity
  IF l_gmo_enabled = 'Y' THEN
    GMD_PROCESS_INSTR_UTILS.build_array (p_entity_name	=> 'FORMULA',
				         p_entity_id	=> x_formula_id,
                                         x_name_array   => l_target_name_array,
                                         x_key_array    => l_target_key_array,
			                 x_return_status => l_return_status);

    GMD_PROCESS_INSTR_UTILS.Copy_Process_Instructions  (
                                p_source_name_array      => l_source_name_array,
                                p_source_key_array       => l_source_key_array,
                                p_target_name_array      => l_target_name_array,
                                p_target_key_array       => l_target_key_array,
			        x_return_status          => l_return_status);
  END IF;

END create_formula;

PROCEDURE create_substitution(p_substitution_id IN  NUMBER, x_substitution_id OUT NOCOPY NUMBER) AS
-- Bug number 4252212
/*======================================================================
--  PROCEDURE :
--   create_substitution
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for saving the
--    new substitution while versioning.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    create_substitution(p_substitution_id, x_substitution_id);
--
--  HISTORY
--
--===================================================================== */
  l_rowid               VARCHAR2(18);
  X_recipe_vers NUMBER;
  X_row         NUMBER;
  l_substitution_line_id    gmd_item_substitution_dtl.substitution_line_id%type;
  l_formula_substitution_id gmd_formula_substitution.formula_substitution_id%type;

  CURSOR cur_hdr_s IS
    SELECT gmd_item_substitution_hdr_s.nextval
    FROM DUAL;
  CURSOR cur_dtl_s IS
    SELECT gmd_item_substitution_dtl_s.nextval
    FROM DUAL;
  CURSOR cur_frsb_s IS
    SELECT gmd_formula_substitution_s.nextval
    FROM DUAL;

  CURSOR Cur_get_hdr IS
    SELECT *
    FROM   GMD_ITEM_SUBSTITUTION_HDR_VL
    WHERE  substitution_id = p_substitution_id;
  X_hdr_rec            Cur_get_hdr%ROWTYPE;

  CURSOR cur_hdr_ver IS
    SELECT MAX(SUBSTITUTION_VERSION) + 1 FROM GMD_ITEM_SUBSTITUTION_HDR_B
     WHERE SUBSTITUTION_NAME = X_hdr_rec.SUBSTITUTION_NAME;
  CURSOR cur_hdr_per IS
     SELECT MAX(preference) + 1 FROM GMD_ITEM_SUBSTITUTION_HDR_B
     WHERE ORIGINAL_INVENTORY_ITEM_ID = X_hdr_rec.ORIGINAL_INVENTORY_ITEM_ID
     AND   OWNER_ORGANIZATION_ID      = X_hdr_rec.OWNER_ORGANIZATION_ID;

  CURSOR Cur_get_det IS
    SELECT *
    FROM   GMD_ITEM_SUBSTITUTION_DTL
    WHERE  substitution_id = p_substitution_id;

  TYPE get_det IS TABLE OF Cur_get_det%ROWTYPE INDEX BY BINARY_INTEGER;
  X_get_det_tbl         get_det;

  CURSOR Cur_formula_sub IS
    SELECT *
    FROM   GMD_FORMULA_SUBSTITUTION
    WHERE  substitution_id = p_substitution_id;

  TYPE formula_sub IS TABLE OF Cur_formula_sub%ROWTYPE INDEX BY BINARY_INTEGER;
  X_formula_sub_tbl     formula_sub;
BEGIN
  OPEN Cur_get_hdr;
  FETCH Cur_get_hdr into X_hdr_rec;
  CLOSE Cur_get_hdr;

  X_row := 0;
  FOR get_rec IN Cur_get_det LOOP
    X_row := X_row + 1;
    X_get_det_tbl(X_row) := get_rec;
  END LOOP;

  X_row := 0;
  FOR get_form IN Cur_formula_sub LOOP
    X_row := X_row + 1;
    X_formula_sub_tbl(X_row) := get_form;
  END LOOP;

  ROLLBACK;

  l_rowid :=NULL;
  OPEN cur_hdr_s;
  FETCH cur_hdr_s INTO x_substitution_id;
  CLOSE cur_hdr_s;
  OPEN cur_hdr_ver;
  FETCH cur_hdr_ver INTO X_hdr_rec.substitution_version;
  CLOSE cur_hdr_ver;
  OPEN cur_hdr_per;
  FETCH cur_hdr_per INTO X_hdr_rec.PREFERENCE;
  CLOSE cur_hdr_per;

  GMD_ITEM_SUBSTITUTION_HDR_PKG.INSERT_ROW(
    X_ROWID                       => l_rowid,
    X_SUBSTITUTION_ID             => x_substitution_id,
    X_SUBSTITUTION_NAME           => X_hdr_rec.SUBSTITUTION_NAME,
    X_SUBSTITUTION_VERSION        => X_hdr_rec.SUBSTITUTION_VERSION,
    X_SUBSTITUTION_STATUS         => 100,
    X_ORIGINAL_INVENTORY_ITEM_ID  => X_hdr_rec.ORIGINAL_INVENTORY_ITEM_ID,
    X_ORIGINAL_UOM                => X_hdr_rec.ORIGINAL_UOM,
    X_ORIGINAL_QTY                => X_hdr_rec.ORIGINAL_QTY,
    X_PREFERENCE                  => X_hdr_rec.PREFERENCE,
    X_START_DATE                  => X_hdr_rec.START_DATE,
    X_END_DATE                    => X_hdr_rec.END_DATE,
    X_OWNER_ORGANIZATION_ID       => X_hdr_rec.OWNER_ORGANIZATION_ID,
    X_REPLACEMENT_UOM_TYPE        => X_hdr_rec.REPLACEMENT_UOM_TYPE,
    X_ATTRIBUTE_CATEGORY          => X_hdr_rec.ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1                  => X_hdr_rec.ATTRIBUTE1,
    X_ATTRIBUTE2                  => X_hdr_rec.ATTRIBUTE2,
    X_ATTRIBUTE3                  => X_hdr_rec.ATTRIBUTE3,
    X_ATTRIBUTE4                  => X_hdr_rec.ATTRIBUTE4,
    X_ATTRIBUTE5                  => X_hdr_rec.ATTRIBUTE5,
    X_ATTRIBUTE6                  => X_hdr_rec.ATTRIBUTE6,
    X_ATTRIBUTE7                  => X_hdr_rec.ATTRIBUTE7,
    X_ATTRIBUTE8                  => X_hdr_rec.ATTRIBUTE8,
    X_ATTRIBUTE9                  => X_hdr_rec.ATTRIBUTE9,
    X_ATTRIBUTE10                 => X_hdr_rec.ATTRIBUTE10,
    X_ATTRIBUTE11                 => X_hdr_rec.ATTRIBUTE11,
    X_ATTRIBUTE12                 => X_hdr_rec.ATTRIBUTE12,
    X_ATTRIBUTE13                 => X_hdr_rec.ATTRIBUTE13,
    X_ATTRIBUTE14                 => X_hdr_rec.ATTRIBUTE14,
    X_ATTRIBUTE15                 => X_hdr_rec.ATTRIBUTE15,
    X_ATTRIBUTE16                 => X_hdr_rec.ATTRIBUTE16,
    X_ATTRIBUTE17                 => X_hdr_rec.ATTRIBUTE17,
    X_ATTRIBUTE18                 => X_hdr_rec.ATTRIBUTE18,
    X_ATTRIBUTE19                 => X_hdr_rec.ATTRIBUTE19,
    X_ATTRIBUTE20                 => X_hdr_rec.ATTRIBUTE20,
    X_ATTRIBUTE21                 => X_hdr_rec.ATTRIBUTE21,
    X_ATTRIBUTE22                 => X_hdr_rec.ATTRIBUTE22,
    X_ATTRIBUTE23                 => X_hdr_rec.ATTRIBUTE23,
    X_ATTRIBUTE24                 => X_hdr_rec.ATTRIBUTE24,
    X_ATTRIBUTE25                 => X_hdr_rec.ATTRIBUTE25,
    X_ATTRIBUTE26                 => X_hdr_rec.ATTRIBUTE26,
    X_ATTRIBUTE27                 => X_hdr_rec.ATTRIBUTE27,
    X_ATTRIBUTE28                 => X_hdr_rec.ATTRIBUTE28,
    X_ATTRIBUTE29                 => X_hdr_rec.ATTRIBUTE29,
    X_ATTRIBUTE30                 => X_hdr_rec.ATTRIBUTE30,
    X_SUBSTITUTION_DESCRIPTION    => X_hdr_rec.SUBSTITUTION_DESCRIPTION,
    X_CREATION_DATE               => sysdate,
    X_CREATED_BY                  => P_created_by,
    X_LAST_UPDATE_DATE            => sysdate,
    X_LAST_UPDATED_BY             => P_created_by,
    X_LAST_UPDATE_LOGIN           => P_login_id);
 IF X_formula_sub_tbl.last IS NOT NULL THEN
         FOR I IN 1 .. X_formula_sub_tbl.last
         LOOP
             OPEN cur_frsb_s;
             FETCH cur_frsb_s INTO l_formula_substitution_id;
             CLOSE cur_frsb_s;
             l_rowid :=NULL;
             GMD_FORMULA_SUBSTITUTION_PKG.INSERT_ROW(
                    X_ROWID                   => l_rowid,
                    X_FORMULA_SUBSTITUTION_ID => l_formula_substitution_id,
                    X_SUBSTITUTION_ID         => x_substitution_id,
                    X_FORMULA_ID              => X_formula_sub_tbl(i).FORMULA_ID,
                    X_ASSOCIATED_FLAG         => 'N',
                    X_CREATION_DATE           => sysdate,
                    X_CREATED_BY              => P_created_by,
                    X_LAST_UPDATE_DATE        => sysdate,
                    X_LAST_UPDATED_BY         => P_created_by,
                    X_LAST_UPDATE_LOGIN       => P_login_id);
        END LOOP;
 END IF;
 FOR I IN 1 .. X_get_det_tbl.last
 LOOP
          l_rowid :=NULL;
          OPEN cur_dtl_s;
          FETCH cur_dtl_s INTO l_substitution_line_id;
          CLOSE cur_dtl_s;
          GMD_ITEM_SUBSTITUTION_DTL_PKG.INSERT_ROW(
            X_ROWID =>              l_rowid,
            X_SUBSTITUTION_LINE_ID => l_substitution_line_id,
            X_SUBSTITUTION_ID      => x_substitution_id,
            X_INVENTORY_ITEM_ID    => X_get_det_tbl(i).INVENTORY_ITEM_ID,
            X_UNIT_QTY             => X_get_det_tbl(i).UNIT_QTY,
            X_DETAIL_UOM           => X_get_det_tbl(i).DETAIL_UOM,
            X_CREATION_DATE        => sysdate,
            X_CREATED_BY           => P_created_by,
            X_LAST_UPDATE_DATE     => sysdate,
            X_LAST_UPDATED_BY      => P_created_by,
            X_LAST_UPDATE_LOGIN    => P_login_id);
 END LOOP;
END create_substitution;

END gmd_version_control;

/
