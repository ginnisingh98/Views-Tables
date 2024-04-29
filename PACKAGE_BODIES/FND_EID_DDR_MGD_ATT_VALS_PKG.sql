--------------------------------------------------------
--  DDL for Package Body FND_EID_DDR_MGD_ATT_VALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_EID_DDR_MGD_ATT_VALS_PKG" AS
/* $Header: fndeidhierb.pls 120.0.12010000.5 2012/10/09 01:34:40 rnagaraj noship $ */

PROCEDURE load_mgd_att_row (
       X_UPLOAD_MODE                  IN VARCHAR2,
       X_EID_INST_MGD_ATT_VAL_ID      IN VARCHAR2,
       X_EID_INSTANCE_ID              IN VARCHAR2,
       X_EID_INSTANCE_MGD_ATTRIBUTE   IN VARCHAR2,
       X_EID_INSTANCE_DIM_SPEC        IN VARCHAR2,
       X_EID_INSTANCE_DIMVAL_DISPNAME IN VARCHAR2,
       X_EID_INSTANCE_DIM_PARENT_SPEC IN VARCHAR2,
       X_EID_INSTANCE_DIM_VAL_SYNONYM IN VARCHAR2,
       X_ADDITIONAL_SYNONYMS_FLAG     IN VARCHAR2,
       X_LAST_UPDATE_DATE             IN VARCHAR2,
       X_APPLICATION_SHORT_NAME       IN VARCHAR2,
       X_OWNER                        IN VARCHAR2 ) IS

  user_id  NUMBER;

procedure TRANSLATE_ROW(
       X_EID_INST_MGD_ATT_VAL_ID       IN VARCHAR2,
       X_EID_INSTANCE_ID               IN VARCHAR2,
       X_EID_INSTANCE_MGD_ATTRIBUTE    IN VARCHAR2,
       X_EID_INSTANCE_DIMVAL_DISPNAME  IN VARCHAR2,
       X_LAST_UPDATE_DATE              IN VARCHAR2,
       X_user_id                       IN NUMBER ) IS
BEGIN

   UPDATE fnd_eid_ddr_mgd_att_vals
   SET eid_instance_dim_val_disp_name = x_eid_instance_dimval_dispname,
       last_update_date = TO_DATE(X_LAST_UPDATE_DATE,'YYYY/MM/DD'),
       last_updated_by = x_user_id,
       source_lang = userenv('LANG')
   WHERE eid_inst_mgd_att_val_id = x_eid_inst_mgd_att_val_id
     AND eid_instance_id = x_eid_instance_id
     AND eid_instance_mgd_attribute = x_eid_instance_mgd_attribute
     AND userenv('LANG') IN (language, source_lang);

END TRANSLATE_ROW;

BEGIN

  IF ( x_owner IS NOT NULL ) THEN
    user_id := fnd_load_util.owner_id(x_owner);
  ELSE
    user_id := -1;
  END IF;

  IF ( user_id > 0 ) THEN
     IF ( x_upload_mode = 'NLS' ) THEN
       /* FND_EID_DDR_MGD_ATT_VALS_PKG */
          TRANSLATE_ROW(
                     X_EID_INST_MGD_ATT_VAL_ID ,
                     X_EID_INSTANCE_ID ,
                     X_EID_INSTANCE_MGD_ATTRIBUTE ,
                     X_EID_INSTANCE_DIMVAL_DISPNAME  ,
                     X_LAST_UPDATE_DATE  ,
                     user_id );
     ELSE

       UPDATE fnd_eid_ddr_mgd_att_vals
          SET eid_instance_dim_spec = x_eid_instance_dim_spec,
              eid_instance_dim_val_disp_name = x_eid_instance_dimval_dispname,
              eid_instance_dim_parent_spec = x_eid_instance_dim_parent_spec,
              eid_instance_dim_val_synonym = x_eid_instance_dim_val_synonym,
              additional_synonyms_flag = x_additional_synonyms_flag,
              last_update_date = TO_DATE(X_LAST_UPDATE_DATE,'YYYY/MM/DD'),
              last_updated_by = user_id
        WHERE eid_inst_mgd_att_val_id = X_EID_INST_MGD_ATT_VAL_ID
          AND eid_instance_id = X_EID_INSTANCE_ID
          AND eid_instance_mgd_attribute = X_EID_INSTANCE_MGD_ATTRIBUTE;

        IF ( SQL%NOTFOUND ) THEN
          INSERT INTO fnd_eid_ddr_mgd_att_vals (
                    EID_INST_MGD_ATT_VAL_ID,
                    EID_INSTANCE_ID,
                    EID_INSTANCE_MGD_ATTRIBUTE,
                    LANGUAGE,
                    SOURCE_LANG,
                    EID_INSTANCE_DIM_SPEC,
                    EID_INSTANCE_DIM_VAL_DISP_NAME,
                    EID_INSTANCE_DIM_PARENT_SPEC,
                    EID_INSTANCE_DIM_VAL_SYNONYM,
                    ADDITIONAL_SYNONYMS_FLAG,
                    CREATED_BY,
                    CREATION_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_DATE
           ) SELECT
               X_EID_INST_MGD_ATT_VAL_ID,
               X_EID_INSTANCE_ID,
               X_EID_INSTANCE_MGD_ATTRIBUTE,
               l.LANGUAGE_CODE,
               userenv('LANG'),
               X_EID_INSTANCE_DIM_SPEC,
               X_EID_INSTANCE_DIMVAL_DISPNAME,
               X_EID_INSTANCE_DIM_PARENT_SPEC,
               X_EID_INSTANCE_DIM_VAL_SYNONYM,
               X_ADDITIONAL_SYNONYMS_FLAG,
               user_id,
               TO_DATE(X_LAST_UPDATE_DATE,'YYYY/MM/DD'),
               user_id,
               TO_DATE(X_LAST_UPDATE_DATE,'YYYY/MM/DD')
             FROM FND_LANGUAGES l
             WHERE l.installed_flag IN ('I','B')
               AND NOT EXISTS
                  ( SELECT NULL
                      FROM fnd_eid_ddr_mgd_att_vals t
                     WHERE t.eid_inst_mgd_att_val_id = x_eid_inst_mgd_att_val_id
                       AND t.eid_instance_id = x_eid_instance_id
                       AND t.eid_instance_mgd_attribute = x_eid_instance_mgd_attribute
                       AND t.language = l.language_code);
        END IF;
     END IF;
  END IF;

END load_mgd_att_row;



PROCEDURE load_syns_row (
      X_EID_INST_MGD_ATT_VAL_ID  IN VARCHAR2,
      X_ADDITIONAL_SYNONYM       IN VARCHAR2,
      X_SYNONYM_SOURCE           IN VARCHAR2,
      X_LAST_UPDATE_DATE         IN VARCHAR2,
      X_APPLICATION_SHORT_NAME   IN VARCHAR2,
      X_OWNER                    IN VARCHAR2) IS

  user_id  NUMBER;
BEGIN

   IF ( x_owner IS NOT NULL ) THEN
     user_id := fnd_load_util.owner_id(x_owner);
   ELSE
     user_id := -1;
   END IF;

   IF ( user_id > 0 ) THEN

       UPDATE fnd_eid_mgd_at_val_adl_syns
          SET additional_synonym = x_additional_synonym,
              synonym_source = x_synonym_source,
              last_update_date = TO_DATE(X_LAST_UPDATE_DATE,'YYYY/MM/DD'),
              last_updated_by = user_id
        WHERE eid_inst_mgd_att_val_id = x_eid_inst_mgd_att_val_id;

        IF ( SQL%NOTFOUND ) THEN
          INSERT INTO fnd_eid_mgd_at_val_adl_syns (
             EID_INST_MGD_ATT_VAL_ID ,
             ADDITIONAL_SYNONYM,
             SYNONYM_SOURCE,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN
          ) VALUES (
            X_EID_INST_MGD_ATT_VAL_ID,
            X_ADDITIONAL_SYNONYM,
            X_SYNONYM_SOURCE,
            user_id,
            TO_DATE(X_LAST_UPDATE_DATE,'YYYY/MM/DD'),
            user_id,
            TO_DATE(X_LAST_UPDATE_DATE,'YYYY/MM/DD'),
            0);
        END IF;

   END IF;

END load_syns_row;

END FND_EID_DDR_MGD_ATT_VALS_PKG;

/
