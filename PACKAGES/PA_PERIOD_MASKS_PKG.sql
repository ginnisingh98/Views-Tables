--------------------------------------------------------
--  DDL for Package PA_PERIOD_MASKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PERIOD_MASKS_PKG" AUTHID CURRENT_USER AS
--$Header: PAFPPMTS.pls 120.0 2005/05/29 23:18:47 appldev noship $
PROCEDURE INSERT_ROW(
         X_ROWID                   IN OUT NOCOPY rowid,
         X_PERIOD_MASK_ID          IN pa_period_masks_b.period_mask_id%type,
         X_EFFECTIVE_START_DATE    IN pa_period_masks_b.effective_start_date%type,
         X_EFFECTIVE_END_DATE      IN pa_period_masks_b.effective_end_date%type,
         X_TIME_PHASE_CODE         IN pa_period_masks_b.time_phase_code%type,
         X_CREATION_DATE           IN pa_period_masks_b.creation_date%type,
         X_CREATED_BY              IN pa_period_masks_b.created_by%type,
         X_LAST_UPDATE_LOGIN       IN pa_period_masks_b.last_update_login%type,
         X_LAST_UPDATED_BY         IN pa_period_masks_b.last_updated_by%type,
         X_LAST_UPDATE_DATE        IN pa_period_masks_b.last_update_date%type,
         X_RECORD_VERSION_NUMBER   IN pa_period_masks_b.record_version_number%type,
         X_PRE_DEFINED_FLAG        IN pa_period_masks_b.pre_defined_flag%type,
         X_NAME                    IN pa_period_masks_tl.name%type,
         X_DESCRIPTION             IN pa_period_masks_tl.description%type);

PROCEDURE LOCK_ROW(
         X_PERIOD_MASK_ID IN pa_period_masks_b.period_mask_id%type
         );

PROCEDURE UPDATE_ROW(
         X_PERIOD_MASK_ID          IN pa_period_masks_b.period_mask_id%type,
         X_EFFECTIVE_START_DATE    IN pa_period_masks_b.effective_start_date%type,
         X_EFFECTIVE_END_DATE      IN pa_period_masks_b.effective_end_date%type,
         X_TIME_PHASE_CODE         IN pa_period_masks_b.time_phase_code%type,
         X_CREATION_DATE           IN pa_period_masks_b.creation_date%type,
         X_CREATED_BY              IN pa_period_masks_b.created_by%type,
         X_LAST_UPDATE_LOGIN       IN pa_period_masks_b.last_update_login%type,
         X_LAST_UPDATED_BY         IN pa_period_masks_b.last_updated_by%type,
         X_LAST_UPDATE_DATE        IN pa_period_masks_b.last_update_date%type,
         X_RECORD_VERSION_NUMBER   IN pa_period_masks_b.record_version_number%type,
         X_PRE_DEFINED_FLAG        IN pa_period_masks_b.pre_defined_flag%type,
         X_NAME                    IN pa_period_masks_tl.name%type,
         X_DESCRIPTION             IN pa_period_masks_tl.description%type);


PROCEDURE DELETE_ROW(
         X_PERIOD_MASK_ID IN pa_period_masks_b.period_mask_id%type
         );

PROCEDURE ADD_LANGUAGE;

PROCEDURE TRANSLATE_ROW(
         X_PERIOD_MASK_ID IN pa_period_masks_b.period_mask_id%type,
         X_OWNER          IN VARCHAR2,
         X_NAME           IN pa_period_masks_tl.name%type,
         X_DESCRIPTION    IN pa_period_masks_tl.description%type
);


PROCEDURE LOAD_ROW(
         X_PERIOD_MASK_ID          IN pa_period_masks_b.period_mask_id%type,
         X_EFFECTIVE_START_DATE    IN pa_period_masks_b.effective_start_date%type,
         X_EFFECTIVE_END_DATE      IN pa_period_masks_b.effective_end_date%type,
         X_TIME_PHASE_CODE         IN pa_period_masks_b.time_phase_code%type,
         X_CREATION_DATE           IN pa_period_masks_b.creation_date%type,
         X_CREATED_BY              IN pa_period_masks_b.created_by%type,
         X_LAST_UPDATE_LOGIN       IN pa_period_masks_b.last_update_login%type,
         X_LAST_UPDATED_BY         IN pa_period_masks_b.last_updated_by%type,
         X_LAST_UPDATE_DATE        IN pa_period_masks_b.last_update_date%type,
         X_RECORD_VERSION_NUMBER   IN pa_period_masks_b.record_version_number%type,
         X_PRE_DEFINED_FLAG        IN pa_period_masks_b.pre_defined_flag%type,
         X_NAME                    IN pa_period_masks_tl.name%type,
         X_DESCRIPTION             IN pa_period_masks_tl.description%type,
         X_OWNER                   IN VARCHAR2 );

END PA_PERIOD_MASKS_PKG;

 

/
