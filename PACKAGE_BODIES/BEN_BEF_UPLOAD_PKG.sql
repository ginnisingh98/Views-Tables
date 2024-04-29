--------------------------------------------------------
--  DDL for Package Body BEN_BEF_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BEF_UPLOAD_PKG" AS
/* $Header: bexflupd.pkb 120.2 2006/02/13 16:44 tjesumic noship $ */

PROCEDURE load_bef_row (
          p_short_name		VARCHAR2
	, p_decd_flag		VARCHAR2
	, p_name        	VARCHAR2
	, p_frmt_mask_typ_cd	VARCHAR2
	, p_csr_cd              VARCHAR2
	, p_lvl_cd              VARCHAR2
	, p_alwd_in_rcd_cd	VARCHAR2
	, p_Group_lvl_cd	VARCHAR2 default null
	, p_custom_mode  	VARCHAR2 ) IS

l_ext_fld_id            ben_ext_fld.ext_fld_id%TYPE;
l_ovn			ben_ext_fld.object_version_number%TYPE;
l_owner			VARCHAR2(6);

l_rowid rowid;

BEGIN

BEGIN

	SELECT	ext_fld_id
	,	object_version_number
	,	DECODE( NVL(last_updated_by,-1), 1, 'SEED', 'CUSTOM')
	INTO	l_ext_fld_id
	,	l_ovn
	,	l_owner
	FROM	ben_ext_fld
	WHERE	short_name	= P_SHORT_NAME;


--	IF ( p_custom_mode = 'FORCE' OR l_owner = 'SEED' ) THEN

		BEN_EXT_FLD_PKG.UPDATE_ROW (
                                 P_EXT_FLD_ID => l_ext_fld_id
                               , P_DECD_FLAG => p_decd_flag
                               , P_SHORT_NAME => p_short_name
                               , P_FRMT_MASK_TYP_CD => p_frmt_mask_typ_cd
                               , P_CSR_CD => p_csr_cd
                               , P_LVL_CD => p_lvl_cd
                               , P_ALWD_IN_RCD_CD => p_alwd_in_rcd_cd
                               , P_group_lvl_cd   => p_group_lvl_cd
                               , P_BUSINESS_GROUP_ID => NULL
                               , P_OBJECT_VERSION_NUMBER => l_ovn+1
                               , P_NAME => p_name
                               , P_LAST_UPDATE_DATE => sysdate
                               , P_LAST_UPDATED_BY => 1
                               , P_LAST_UPDATE_LOGIN => 1 );

--	END IF;

EXCEPTION WHEN NO_DATA_FOUND
THEN

       if l_ext_fld_id is null then
        	select ben_ext_fld_s.nextval
        	into   l_ext_fld_id
        	from   dual;
       end if ;

	ben_ext_fld_pkg.insert_row (
                         P_ROWID => l_rowid
                       , P_EXT_FLD_ID => l_ext_fld_id
                       , P_DECD_FLAG => p_decd_flag
                       , P_SHORT_NAME => p_short_name
                       , P_FRMT_MASK_TYP_CD => p_frmt_mask_typ_cd
                       , P_CSR_CD => p_csr_cd
                       , P_LVL_CD => p_lvl_cd
                       , P_ALWD_IN_RCD_CD => p_alwd_in_rcd_cd
                       , P_group_lvl_cd   => p_group_lvl_cd
                       , P_BUSINESS_GROUP_ID => NULL
                       , P_OBJECT_VERSION_NUMBER => 1
                       , P_NAME => p_name
                       , P_CREATION_DATE => sysdate
                       , P_CREATED_BY => 1
                       , P_LAST_UPDATE_DATE => sysdate
                       , P_LAST_UPDATED_BY => 1
                       , P_LAST_UPDATE_LOGIN => 1 );

END;

END load_bef_row;

END ben_bef_upload_pkg;

/
