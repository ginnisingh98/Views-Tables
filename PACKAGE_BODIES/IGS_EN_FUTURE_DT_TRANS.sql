--------------------------------------------------------
--  DDL for Package Body IGS_EN_FUTURE_DT_TRANS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_FUTURE_DT_TRANS" AS
/* $Header: IGSEN83B.pls 120.8 2005/12/08 07:36:14 appldev noship $ */

g_debug_level CONSTANT NUMBER  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
e_resource_busy   EXCEPTION;
PRAGMA EXCEPTION_INIT(e_resource_busy, -54);

---------------------------------------------------------------------------------

--                      PRIVATE FUNCTIONS
---------------------------------------------------------------------------------

  FUNCTION is_career_model_enabled RETURN BOOLEAN AS
  -------------------------------------------------------------------------------------------
  --Created by  : Chandrasekhar Kasu, Oracle IDC
  --Date created: 20-Nov-2004
  -- Purpose : returns True when Career model  is  enabled  else False.
  --Change History:
  --Who         When            What

  -------------------------------------------------------------------------------------------
  BEGIN

    IF NVL(FND_PROFILE.VALUE('CAREER_MODEL_ENABLED'),'N') =  'Y' THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;

  END is_career_model_enabled;

  FUNCTION is_tranfer_across_careers(
    p_src_program_cd       IN   VARCHAR2,
    p_src_progam_ver       IN   NUMBER,
    p_dest_program_cd      IN   VARCHAR2,
    p_dest_prog_ver        IN   NUMBER,
    p_src_career_type      OUT  NOCOPY VARCHAR2
  ) RETURN BOOLEAN AS

  -------------------------------------------------------------------------------------------
  --Created by  : Chandrasekhar Kasu, Oracle IDC
  --Date created: 20-Nov-2004
  -- Purpose : This function returns when Transfer is across careers and
  --           false when transfer is with in the careers
  --Change History:
  --Who         When            What

  -------------------------------------------------------------------------------------------

    CURSOR c_get_career_type(c_program_cd VARCHAR2,c_program_ver NUMBER) IS
       SELECT course_type
       FROM   IGS_PS_VER
       WHERE  course_cd =  c_program_cd AND
              version_number = c_program_ver;
    l_src_prgm_career    IGS_PS_VER.COURSE_TYPE%TYPE;
    l_dest_prgm_career    IGS_PS_VER.COURSE_TYPE%TYPE;

  BEGIN

    OPEN c_get_career_type(p_src_program_cd,p_src_progam_ver);
    FETCH c_get_career_type INTO l_src_prgm_career;
    CLOSE c_get_career_type;
    OPEN c_get_career_type(p_dest_program_cd,p_dest_prog_ver);
    FETCH c_get_career_type INTO l_dest_prgm_career;
    CLOSE c_get_career_type;
    IF (l_src_prgm_career <> l_dest_prgm_career) THEN
        p_src_career_type := l_src_prgm_career;
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;

  END is_tranfer_across_careers;


  PROCEDURE log_err_messages(
    p_msg_count      IN NUMBER,
    p_msg_data       IN VARCHAR2
  ) AS
   -------------------------------------------------------------------------------------------
   -- Created by  : Chandrasekhar Kasu, Oracle Student Systems Oracle IDC
   -- purpose : this methos concatenates al the warning and error messages delimited by '<br>'
   --           that were recieved during program transfer.
   --Change History:
   --Who         When            What

   --------------------------------------------------------------------------------------------


    l_msg_count      NUMBER(4);
    l_msg_data       VARCHAR2(4000);
    l_enc_msg        VARCHAR2(2000);
    l_msg_index      NUMBER(4);
    l_msg_text       FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
    l_warn_and_err_msg VARCHAR2(5000);

  BEGIN

    l_msg_count := p_msg_count;
    l_msg_data := p_msg_data;
    l_warn_and_err_msg := null;

    IF l_msg_count =1 THEN
      FND_MESSAGE.SET_ENCODED(l_msg_data);
      l_msg_text := FND_MESSAGE.GET;
      FND_FILE.PUT_LINE (FND_FILE.LOG, l_msg_text);

    ELSIF l_msg_count > 1 THEN
      FOR l_index IN 1..NVL(l_msg_count,0)
      LOOP
            FND_MSG_PUB.GET(FND_MSG_PUB.G_FIRST,
                            FND_API.G_TRUE,
                            l_enc_msg,
                            l_msg_index);
            FND_MESSAGE.SET_ENCODED(l_enc_msg);
            l_msg_text := FND_MESSAGE.GET;
            FND_FILE.PUT_LINE (FND_FILE.LOG, l_msg_text);
            FND_MSG_PUB.DELETE_MSG(l_msg_index);

      END LOOP;
    END IF;

  END log_err_messages;


PROCEDURE del_gua(
  p_person_id   IGS_EN_STDNT_PS_ATT.person_id%TYPE,
  p_course_cd   IGS_EN_STDNT_PS_ATT.course_cd%TYPE)
IS
BEGIN -- del_gua
  -- Delete IGS_GR_GRADUAND_PKG records
DECLARE

  CURSOR c_gua IS
    SELECT  create_dt
    FROM  IGS_GR_GRADUAND gua
    WHERE gua.person_id = p_person_id
    AND   gua.course_cd = p_course_cd;

  CURSOR c_gua_del (
    cp_create_dt    IGS_GR_GRADUAND.create_dt%TYPE) IS
    SELECT rowid
    FROM  IGS_GR_GRADUAND   gua
    WHERE gua.person_id     = p_person_id
    AND gua.create_dt     = cp_create_dt
    FOR UPDATE OF gua.LAST_UPDATE_DATE NOWAIT ;


  CURSOR c_gach (
    cp_create_dt    IGS_GR_AWD_CRMN_HIST.create_dt%TYPE)  IS
    SELECT  gach.gach_id
    FROM  IGS_GR_AWD_CRMN_HIST gach
    WHERE gach.person_id    = p_person_id
    AND   gach.create_dt    = cp_create_dt;

  CURSOR c_gach_del (
    cp_gach_id    IGS_GR_AWD_CRMN_HIST.gach_id%TYPE) IS
    SELECT rowid
    FROM  IGS_GR_AWD_CRMN_HIST  gach
    WHERE gach.gach_id    = cp_gach_id
    FOR UPDATE OF gach.LAST_UPDATE_DATE NOWAIT ;

  CURSOR c_gac (
    cp_create_dt    IGS_GR_AWD_CRMN.create_dt%TYPE) IS
    SELECT  gac.gac_id
    FROM  IGS_GR_AWD_CRMN gac
    WHERE gac.person_id   = p_person_id
    AND   gac.create_dt     = cp_create_dt;

  CURSOR c_gac_del (
    cp_gac_id   IGS_GR_AWD_CRMN.gac_id%TYPE) IS
    SELECT rowid
    FROM  IGS_GR_AWD_CRMN   gac
    WHERE gac.gac_id    = cp_gac_id
    FOR UPDATE OF gac.LAST_UPDATE_DATE NOWAIT ;

v_gua_del_exists  c_gua_del%ROWTYPE;
l_entity_name     VARCHAR2(30);

BEGIN

  FOR v_gua_rec IN c_gua LOOP
    FOR v_gach_rec IN c_gach (v_gua_rec.create_dt) LOOP
            BEGIN
                        -- Delete unconfirmed IGS_GR_AWD_CRMN_HIST records
              FOR c_gach_del_rec in c_gach_del(v_gach_rec.gach_id)
              LOOP

                IGS_GR_AWD_CRMN_HIST_PKG.DELETE_ROW( X_ROWID => c_gach_del_rec.ROWID );

              END LOOP;

        EXCEPTION
        WHEN e_resource_busy THEN
          IF c_gach_del%ISOPEN THEN
            CLOSE c_gach_del;
          END IF;
          l_entity_name := 'IGS_GR_AWD_CRMN_HIST';
          EXIT;
      END;
    END LOOP;
    IF l_entity_name IS NOT NULL THEN
      EXIT;
    END IF;

    FOR v_gca_rec IN c_gac(v_gua_rec.create_dt) LOOP
        BEGIN
        -- Delete unconfirmed IGS_GR_AWD_CRMN records
        FOR c_gac_del_rec IN c_gac_del(
             v_gca_rec.gac_id) LOOP
        IGS_GR_AWD_CRMN_PKG.DELETE_ROW(
          X_ROWID => c_gac_del_rec.ROWID );
        END LOOP;
        EXCEPTION
        WHEN e_resource_busy THEN
          IF c_gac_del%ISOPEN THEN
            CLOSE c_gac_del;
          END IF;
          l_entity_name := 'IGS_GR_AWD_CRMN';
          EXIT;
        END;
    END LOOP;

    IF l_entity_name IS NOT NULL THEN
      EXIT;
    END IF;

    -- Delete unconfirmed IGS_GR_GRADUAND records
    FOR v_gua_del_exists IN c_gua_del(v_gua_rec.create_dt) LOOP
      IGS_GR_GRADUAND_PKG.DELETE_ROW(
        X_ROWID => v_gua_del_exists.rowid );
    END LOOP;

  END LOOP;

 EXCEPTION
  WHEN e_resource_busy THEN
    IF c_gua%ISOPEN THEN
      CLOSE c_gua;
    END IF;
    IF c_gua_del%ISOPEN THEN
      CLOSE c_gua_del;
    END IF;
    IF c_gach%ISOPEN THEN
      CLOSE c_gach;
    END IF;
    IF c_gach_del%ISOPEN THEN
      CLOSE c_gach_del;
    END IF;
    IF c_gac%ISOPEN THEN
      CLOSE c_gac;
    END IF;
    IF c_gac_del%ISOPEN THEN
      CLOSE c_gac_del;
    END IF;
 WHEN OTHERS THEN
    IF c_gua%ISOPEN THEN
      CLOSE c_gua;
    END IF;
    IF c_gua_del%ISOPEN THEN
      CLOSE c_gua_del;
    END IF;
    IF c_gach%ISOPEN THEN
      CLOSE c_gach;
    END IF;
    IF c_gach_del%ISOPEN THEN
      CLOSE c_gach_del;
    END IF;
    IF c_gac%ISOPEN THEN
      CLOSE c_gac;
    END IF;
    IF c_gac_del%ISOPEN THEN
      CLOSE c_gac_del;
    END IF;

END;
END del_gua;


PROCEDURE del_esaa(
  p_person_id   IGS_EN_STDNT_PS_ATT.person_id%TYPE,
  p_course_cd   IGS_EN_STDNT_PS_ATT.course_cd%TYPE)
IS
BEGIN -- del_esaa
  -- Delete IGS_EN_SPA_AWD_AIM records
DECLARE

  CURSOR c_esaa IS
    SELECT  award_cd
    FROM  IGS_EN_SPA_AWD_AIM esaa
    WHERE esaa.person_id = p_person_id
    AND   esaa.course_cd = p_course_cd;

  CURSOR c_esaa_del (
    cp_award_cd IGS_EN_SPA_AWD_AIM.award_cd%TYPE) IS
    SELECT rowid
    FROM  IGS_EN_SPA_AWD_AIM  esaa
    WHERE esaa.person_id = p_person_id
    AND   esaa.course_cd = p_course_cd
    AND   esaa.award_cd  = cp_award_cd
    FOR UPDATE OF esaa.LAST_UPDATE_DATE NOWAIT ;

v_esaa_del_exists c_esaa_del%ROWTYPE;

BEGIN

  FOR v_esaa_rec IN c_esaa LOOP
          -- Delete IGS_EN_SPA_AWD_AIM records
    FOR v_esaa_del_exists IN c_esaa_del(v_esaa_rec.award_cd) LOOP

      IGS_EN_SPA_AWD_AIM_PKG.DELETE_ROW(X_ROWID => v_esaa_del_exists.rowid );

    END LOOP;

  END LOOP;

EXCEPTION
  WHEN e_resource_busy THEN
    IF c_esaa%ISOPEN THEN
      CLOSE c_esaa;
    END IF;
    IF c_esaa_del%ISOPEN THEN
      CLOSE c_esaa_del;
    END IF;
  WHEN OTHERS THEN
    IF c_esaa%ISOPEN THEN
      CLOSE c_esaa;
    END IF;
    IF c_esaa_del%ISOPEN THEN
      CLOSE c_esaa_del;
     END IF;

END;
END del_esaa;

PROCEDURE del_gsa(
  p_person_id   IGS_EN_STDNT_PS_ATT.person_id%TYPE,
  p_course_cd   IGS_EN_STDNT_PS_ATT.course_cd%TYPE)
IS
BEGIN -- del_gsa
  -- (1) Delete IGS_GR_SPECIAL_AWARD records
DECLARE
  CURSOR c_gsa IS
    SELECT  award_cd,award_dt
    FROM  IGS_GR_SPECIAL_AWARD gsa
    WHERE gsa.person_id = p_person_id
    AND   gsa.course_cd = p_course_cd;

  CURSOR c_gsa_del (
    cp_award_cd     IGS_GR_SPECIAL_AWARD.award_cd%TYPE,
    cp_award_dt     IGS_GR_SPECIAL_AWARD.award_dt%TYPE) IS
    SELECT rowid
    FROM  IGS_GR_SPECIAL_AWARD  gsa
    WHERE gsa.person_id = p_person_id
    AND gsa.course_cd = p_course_cd
    AND gsa.award_cd  = cp_award_cd
    AND gsa.award_dt  = cp_award_dt
    FOR UPDATE OF gsa.LAST_UPDATE_DATE NOWAIT ;

v_gsa_del_exists  c_gsa_del%ROWTYPE;

BEGIN

  FOR v_gsa_rec IN c_gsa LOOP
    FOR v_gsa_del_exists IN c_gsa_del(v_gsa_rec.award_cd,
                                      v_gsa_rec.award_dt ) LOOP

      IGS_GR_SPECIAL_AWARD_PKG.DELETE_ROW(X_ROWID => v_gsa_del_exists.rowid );

    END LOOP;

  END LOOP;

EXCEPTION
  WHEN e_resource_busy THEN
    IF c_gsa%ISOPEN THEN
      CLOSE c_gsa;
    END IF;
    IF c_gsa_del%ISOPEN THEN
      CLOSE c_gsa_del;
    END IF;
  WHEN OTHERS THEN
    IF c_gsa%ISOPEN THEN
      CLOSE c_gsa;
    END IF;
    IF c_gsa_del%ISOPEN THEN
      CLOSE c_gsa_del;
    END IF;

END;
END del_gsa;

PROCEDURE del_hssc(
  p_person_id   IGS_EN_STDNT_PS_ATT.person_id%TYPE,
  p_course_cd   IGS_EN_STDNT_PS_ATT.course_cd%TYPE)
IS
BEGIN -- del_hssc
  -- Delete IGS_HE_ST_SPA_CC records
DECLARE

  CURSOR c_hssc IS
    SELECT  he_spa_cc_id
    FROM  IGS_HE_ST_SPA_CC hssc
    WHERE hssc.person_id = p_person_id
    AND   hssc.course_cd = p_course_cd;

  CURSOR c_hssc_del (cp_he_spa_cc_id  IGS_HE_ST_SPA_CC.he_spa_cc_id%TYPE) IS
    SELECT rowid
    FROM  IGS_HE_ST_SPA_CC  hssc
    WHERE hssc.he_spa_cc_id = cp_he_spa_cc_id
    FOR UPDATE OF hssc.LAST_UPDATE_DATE NOWAIT ;

  v_hssc_del_exists c_hssc_del%ROWTYPE;

BEGIN
  FOR v_hssc_rec IN c_hssc LOOP
          -- Delete IGS_HE_ST_SPA_CC records
    FOR v_hssc_del_exists IN c_hssc_del(v_hssc_rec.he_spa_cc_id) LOOP

      IGS_HE_ST_SPA_CC_PKG.DELETE_ROW(X_ROWID => v_hssc_del_exists.ROWID );

    END LOOP;

  END LOOP;

EXCEPTION
  WHEN e_resource_busy THEN
    IF c_hssc%ISOPEN THEN
      CLOSE c_hssc;
    END IF;
    IF c_hssc_del%ISOPEN THEN
      CLOSE c_hssc_del;
    END IF;
  WHEN OTHERS THEN
    IF c_hssc%ISOPEN THEN
      CLOSE c_hssc;
    END IF;
    IF c_hssc_del%ISOPEN THEN
      CLOSE c_hssc_del;
    END IF;

END;
END del_hssc;

PROCEDURE del_hssa(
  p_person_id   IGS_EN_STDNT_PS_ATT.person_id%TYPE,
  p_course_cd   IGS_EN_STDNT_PS_ATT.course_cd%TYPE)
IS
BEGIN -- del_hssa
  -- Delete IGS_HE_ST_SPA records
DECLARE
  CURSOR c_hssa IS
    SELECT  hesa_st_spa_id,person_id,course_cd
    FROM  IGS_HE_ST_SPA hssa
    WHERE hssa.person_id = p_person_id
    AND   hssa.course_cd = p_course_cd;

  CURSOR c_hssa_del (
    cp_hesa_st_spa_id IGS_HE_ST_SPA.hesa_st_spa_id%TYPE) IS
    SELECT rowid
    FROM  IGS_HE_ST_SPA   hssa
    WHERE hssa.hesa_st_spa_id = cp_hesa_st_spa_id
    FOR UPDATE OF hssa.LAST_UPDATE_DATE NOWAIT ;


  CURSOR c_hssua (
    cp_person_id IGS_HE_ST_SPA_UT.person_id%TYPE,
    cp_course_cd IGS_HE_ST_SPA.course_cd%TYPE) IS
    SELECT  hesa_st_spau_id
    FROM  IGS_HE_ST_SPA_UT hssua
    WHERE hssua.person_id  = cp_person_id
    AND   hssua.course_cd  = cp_course_cd ;

  CURSOR c_hssua_del (
    cp_hesa_st_spau_id IGS_HE_ST_SPA_UT.hesa_st_spau_id%TYPE) IS
    SELECT rowid
    FROM  IGS_HE_ST_SPA_UT  hssua
    WHERE hssua.hesa_st_spau_id = cp_hesa_st_spau_id
    FOR UPDATE OF hssua.LAST_UPDATE_DATE NOWAIT ;

    v_hssa_del_exists c_hssa_del%ROWTYPE;
    l_entity_name     VARCHAR2(30);


BEGIN

  FOR v_hssa_rec IN c_hssa LOOP
    FOR v_hssua_rec IN c_hssua (v_hssa_rec.person_id,
                                v_hssa_rec.course_cd ) LOOP
      BEGIN
                        -- Delete unconfirmed IGS_HE_ST_SPA_UT records
        FOR v_hssua_del_rec in c_hssua_del(v_hssua_rec.hesa_st_spau_id)

        LOOP
          IGS_HE_ST_SPA_UT_ALL_PKG.DELETE_ROW(
                  X_ROWID => v_hssua_del_rec.ROWID );
        END LOOP;
        EXCEPTION
        WHEN e_resource_busy THEN
          IF c_hssua_del%ISOPEN THEN
            CLOSE c_hssua_del;
          END IF;
          l_entity_name := 'IGS_HE_ST_SPA_UT_ALL';
          EXIT;
      END;
    END LOOP;
    IF l_entity_name IS NOT NULL THEN
      EXIT;
    END IF;
          -- Delete IGS_HE_ST_SPA records
    FOR v_hssa_del_exists IN c_hssa_del(v_hssa_rec.hesa_st_spa_id) LOOP

      IGS_HE_ST_SPA_ALL_PKG.DELETE_ROW(
                      X_ROWID => v_hssa_del_exists.rowid );
    END LOOP;
  END LOOP;

 EXCEPTION
  WHEN e_resource_busy THEN
    IF c_hssa%ISOPEN THEN
      CLOSE c_hssa;
    END IF;
    IF c_hssa_del%ISOPEN THEN
      CLOSE c_hssa_del;
    END IF;
    IF c_hssua%ISOPEN THEN
           CLOSE c_hssua;
    END IF;
    IF c_hssua_del%ISOPEN THEN
       CLOSE c_hssua_del;
    END IF;
  WHEN OTHERS THEN
    IF c_hssa%ISOPEN THEN
      CLOSE c_hssa;
    END IF;
    IF c_hssa_del%ISOPEN THEN
      CLOSE c_hssa_del;
    END IF;
    IF c_hssua%ISOPEN THEN
           CLOSE c_hssua;
    END IF;
   IF c_hssua_del%ISOPEN THEN
     CLOSE c_hssua_del;
    END IF;

END;
END del_hssa;

------------------------------------------------------------------------------------------------------------
PROCEDURE del_pr_rule_appl(
  p_person_id   IGS_EN_STDNT_PS_ATT.person_id%TYPE,
  p_course_cd   IGS_EN_STDNT_PS_ATT.course_cd%TYPE)
IS
BEGIN -- del_pr_rule_appl
  -- Delete IGS_PR_RU_APPL records
DECLARE
  CURSOR c_pra IS
    SELECT  progression_rule_cat,sequence_number
    FROM  IGS_PR_RU_APPL pra
    WHERE pra.sca_person_id = p_person_id
    AND   pra.sca_course_cd = p_course_cd;

  CURSOR c_pra_del (
        cp_progression_rule_cat   IGS_PR_RU_APPL.progression_rule_cat%TYPE,
        cp_sequence_number  IGS_PR_RU_APPL.sequence_number%TYPE) IS
    SELECT  rowid,pra.*
    FROM  IGS_PR_RU_APPL  pra
    WHERE pra.progression_rule_cat = cp_progression_rule_cat
    AND   pra.sequence_number = cp_sequence_number
    FOR UPDATE OF pra.LAST_UPDATE_DATE NOWAIT ;

    v_pra_upd_exists  c_pra_del%ROWTYPE;

BEGIN

  FOR v_pra_rec IN c_pra LOOP
          -- Delete IGS_PR_RU_APPL records
    FOR v_pra_upd_exists IN c_pra_del(v_pra_rec.progression_rule_cat,
                                            v_pra_rec.sequence_number ) LOOP
-- DELETE THE RECORD
      IGS_PR_RU_APPL_PKG.DELETE_ROW (X_ROWID => v_pra_upd_exists.rowid) ;

     END LOOP;

  END LOOP;

EXCEPTION
  WHEN e_resource_busy THEN
    IF c_pra%ISOPEN THEN
      CLOSE c_pra;
    END IF;
    IF c_pra_del%ISOPEN THEN
      CLOSE c_pra_del;
    END IF;
  WHEN OTHERS THEN
    IF c_pra%ISOPEN THEN
      CLOSE c_pra;
    END IF;
    IF c_pra_del%ISOPEN THEN
      CLOSE c_pra_del;
    END IF;

END;

END del_pr_rule_appl;


PROCEDURE del_psaa(
  p_person_id   IGS_EN_STDNT_PS_ATT.person_id%TYPE,
  p_course_cd   IGS_EN_STDNT_PS_ATT.course_cd%TYPE)
IS
BEGIN -- del_psaa
  -- Delete IGS_PS_STDNT_APV_ALT records
DECLARE

  CURSOR c_psaa IS
    SELECT  exit_course_cd,exit_version_number
    FROM  IGS_PS_STDNT_APV_ALT psaa
    WHERE psaa.person_id = p_person_id
    AND   psaa.course_cd = p_course_cd;

  CURSOR c_psaa_del (
      cp_exit_course_cd   IGS_PS_STDNT_APV_ALT.exit_course_cd%TYPE,
      cp_exit_version_number  IGS_PS_STDNT_APV_ALT.exit_version_number%TYPE) IS
    SELECT rowid
    FROM  IGS_PS_STDNT_APV_ALT  psaa
    WHERE psaa.person_id = p_person_id
    AND   psaa.course_cd = p_course_cd
    AND   psaa.exit_course_cd  = cp_exit_course_cd
    AND   psaa.exit_version_number  = cp_exit_version_number
    FOR UPDATE OF psaa.LAST_UPDATE_DATE NOWAIT ;

    v_psaa_del_exists c_psaa_del%ROWTYPE;

BEGIN

  FOR v_psaa_rec IN c_psaa LOOP
          -- Delete IGS_PS_STDNT_APV_ALT records
    FOR v_psaa_del_exists IN c_psaa_del(v_psaa_rec.exit_course_cd,
                                        v_psaa_rec.exit_version_number ) LOOP

      IGS_PS_STDNT_APV_ALT_PKG.DELETE_ROW(X_ROWID => v_psaa_del_exists.rowid);

    END LOOP;
  END LOOP;

EXCEPTION
  WHEN e_resource_busy THEN
    IF c_psaa%ISOPEN THEN
      CLOSE c_psaa;
    END IF;
    IF c_psaa_del%ISOPEN THEN
      CLOSE c_psaa_del;
    END IF;
  WHEN OTHERS THEN
    IF c_psaa%ISOPEN THEN
      CLOSE c_psaa;
    END IF;
    IF c_psaa_del%ISOPEN THEN
      CLOSE c_psaa_del;
    END IF;

END;

END del_psaa;


PROCEDURE del_susa(
  p_person_id   IGS_EN_STDNT_PS_ATT.person_id%TYPE,
  p_course_cd   IGS_EN_STDNT_PS_ATT.course_cd%TYPE)
IS
BEGIN -- del_susa
  -- (2) Delete IGS_AS_SU_SETATMPT records
DECLARE
  CURSOR c_susa IS
    SELECT  susa.unit_set_cd,susa.sequence_number
    FROM  IGS_AS_SU_SETATMPT susa
    WHERE susa.person_id    = p_person_id
    AND   susa.course_cd    = p_course_cd
    START WITH
      susa.person_id    = p_person_id AND
      susa.course_cd    = p_course_cd AND
      susa.parent_unit_set_cd IS NULL
    CONNECT BY
    PRIOR susa.person_id    = p_person_id AND
    PRIOR susa.course_cd    = p_course_cd AND
    PRIOR susa.unit_set_cd  = susa.parent_unit_set_cd AND
    PRIOR susa.sequence_number  = susa.parent_sequence_number
    ORDER BY LEVEL DESC;

  CURSOR c_susa_del (
    cp_unit_set_cd    IGS_AS_SU_SETATMPT.unit_set_cd%TYPE,
    cp_sequence_number  IGS_AS_SU_SETATMPT.sequence_number%TYPE) IS
    SELECT ROWID, susa.*
    FROM  IGS_AS_SU_SETATMPT susa
    WHERE susa.person_id    = p_person_id
    AND   susa.course_cd    = p_course_cd
    AND   susa.unit_set_cd  = cp_unit_set_cd
    AND   susa.sequence_number  = cp_sequence_number
    FOR UPDATE OF
      susa.LAST_UPDATE_DATE NOWAIT;

  CURSOR c_hes ( cp_unit_set_cd   IGS_AS_SU_SETATMPT.unit_set_cd%TYPE,
     cp_sequence_number IGS_AS_SU_SETATMPT.sequence_number%TYPE) IS
    SELECT  hesa_en_susa_id
    FROM  IGS_HE_EN_SUSA hes
    WHERE hes.person_id = p_person_id
    AND   hes.course_cd = p_course_cd
    AND   hes.unit_set_cd = cp_unit_set_cd
    AND   hes.sequence_number = cp_sequence_number;

  CURSOR c_hes_del (
    cp_hesa_en_susa_id IGS_HE_EN_SUSA.hesa_en_susa_id%TYPE) IS
    SELECT rowid
    FROM  IGS_HE_EN_SUSA  hes
    WHERE hes.hesa_en_susa_id = cp_hesa_en_susa_id
    FOR UPDATE OF hes.LAST_UPDATE_DATE NOWAIT ;

  CURSOR c_hesc ( cp_unit_set_cd    IGS_AS_SU_SETATMPT.unit_set_cd%TYPE,
      cp_sequence_number  IGS_AS_SU_SETATMPT.sequence_number%TYPE) IS
    SELECT  he_susa_cc_id
    FROM  IGS_HE_EN_SUSA_CC hesc
    WHERE hesc.person_id = p_person_id
    AND   hesc.course_cd = p_course_cd
    AND   hesc.unit_set_cd = cp_unit_set_cd
    AND   hesc.sequence_number = cp_sequence_number;

  CURSOR c_hesc_del (
    cp_he_susa_cc_id IGS_HE_EN_SUSA_CC.he_susa_cc_id%TYPE) IS
    SELECT rowid
    FROM  IGS_HE_EN_SUSA_CC hesc
    WHERE hesc.he_susa_cc_id = cp_he_susa_cc_id
    FOR UPDATE OF hesc.LAST_UPDATE_DATE NOWAIT ;

  v_susa_del_exists c_susa_del%ROWTYPE;
  L_ROWID     VARCHAR2(25);
  v_error_flag      BOOLEAN DEFAULT FALSE;
  l_entity_name     VARCHAR2(30);

BEGIN
  v_error_flag := FALSE;
        -- Prevent admission application validation in database trigger
    -- Inserts a record into the s_disable_table_trigger
  -- database table.
  IGS_GE_S_DSB_TAB_TRG_PKG.INSERT_ROW(
    X_ROWID => L_ROWID ,
    X_TABLE_NAME =>'ADMP_DEL_SCA_UNCONF',
    X_SESSION_ID => userenv('SESSIONID'),
    x_mode => 'R'
    );
  FOR v_susa_rec IN c_susa LOOP
    FOR v_hes_rec IN c_hes (v_susa_rec.unit_set_cd, v_susa_rec.sequence_number )
    LOOP
      BEGIN
                      -- Delete unconfirmed IGS_HE_EN_SUSA records
        FOR v_hes_del_rec in c_hes_del(v_hes_rec.hesa_en_susa_id) LOOP

          IGS_HE_EN_SUSA_PKG.DELETE_ROW( X_ROWID => v_hes_del_rec.ROWID );

        END LOOP;
      EXCEPTION
        WHEN e_resource_busy THEN
          IF c_hes_del%ISOPEN THEN
            CLOSE c_hes_del;
          END IF;
           l_entity_name := 'IGS_HE_EN_SUSA';
          EXIT;
      END;
    END LOOP;

    FOR v_hesc_rec IN c_hesc (v_susa_rec.unit_set_cd, v_susa_rec.sequence_number )
    LOOP

      BEGIN
                        -- Delete unconfirmed IGS_HE_EN_SUSA_CC records
        FOR v_hesc_del_rec in c_hesc_del(v_hesc_rec.he_susa_cc_id) LOOP

          IGS_HE_EN_SUSA_CC_PKG.DELETE_ROW( X_ROWID => v_hesc_del_rec.ROWID );

    END LOOP;
    EXCEPTION
      WHEN e_resource_busy THEN
        IF c_hesc_del%ISOPEN THEN
            CLOSE c_hesc_del;
        END IF;
           l_entity_name := 'IGS_HE_EN_SUSA_CC';
        EXIT;
      END;
    END LOOP;
    IF l_entity_name IS NOT NULL THEN
      EXIT;
    END IF;
                -- Delete unconfirmed IGS_AS_SU_SETATMPT
    FOR v_susa_del_exists IN c_susa_del(
        v_susa_rec.unit_set_cd,
        v_susa_rec.sequence_number) LOOP

      IGS_AS_SU_SETATMPT_PKG.DELETE_ROW ( X_ROWID => V_SUSA_DEL_EXISTS.ROWID );

    END LOOP;

  END LOOP;
  IF v_error_flag THEN
    -- Must reset database trigger validation if been turned off
    IGS_GE_MNT_SDTT.genp_del_sdtt('ADMP_DEL_SCA_UNCONF');

  END IF;
  -- Must reset database trigger validation if been turned off
  IGS_GE_MNT_SDTT.genp_del_sdtt('ADMP_DEL_SCA_UNCONF');

EXCEPTION
  WHEN e_resource_busy THEN
    IF c_susa%ISOPEN THEN
      CLOSE c_susa;
    END IF;
    IF c_susa_del%ISOPEN THEN
      CLOSE c_susa_del;
    END IF;
    IF c_hes%ISOPEN THEN
      CLOSE c_hes;
    END IF;
    IF c_hes_del%ISOPEN THEN
      CLOSE c_hes_del;
    END IF;
    IF c_hesc%ISOPEN THEN
      CLOSE c_hesc;
    END IF;
    IF c_hesc_del%ISOPEN THEN
      CLOSE c_hesc_del;
    END IF;
    -- Must reset database trigger validation if been turned off
    IGS_GE_MNT_SDTT.genp_del_sdtt('ADMP_DEL_SCA_UNCONF');
  WHEN OTHERS THEN
    IF c_susa%ISOPEN THEN
      CLOSE c_susa;
    END IF;
    IF c_susa_del%ISOPEN THEN
      CLOSE c_susa_del;
    END IF;
    IF c_hes%ISOPEN THEN
      CLOSE c_hes;
    END IF;
    IF c_hes_del%ISOPEN THEN
      CLOSE c_hes_del;
    END IF;
    IF c_hesc%ISOPEN THEN
      CLOSE c_hesc;
    END IF;
    IF c_hesc_del%ISOPEN THEN
      CLOSE c_hesc_del;
    END IF;
    -- Must reset database trigger validation if been turned off
    IGS_GE_MNT_SDTT.genp_del_sdtt('ADMP_DEL_SCA_UNCONF');

END;
END del_susa;

PROCEDURE del_scho(
  p_person_id   IGS_EN_STDNT_PS_ATT.person_id%TYPE,
  p_course_cd   IGS_EN_STDNT_PS_ATT.course_cd%TYPE)
IS
BEGIN -- del_scho
  -- (3) Delete IGS_EN_STDNTPSHECSOP records
DECLARE
  CURSOR c_scho IS
    SELECT  scho.start_dt
    FROM  IGS_EN_STDNTPSHECSOP scho
    WHERE scho.person_id = p_person_id
    AND   scho.course_cd = p_course_cd;

  CURSOR c_scho_del (
      cp_start_dt   IGS_EN_STDNTPSHECSOP.start_dt%TYPE) IS
    SELECT ROWID, scho.*
    FROM  IGS_EN_STDNTPSHECSOP scho
    WHERE scho.person_id  = p_person_id
    AND   scho.course_cd  = p_course_cd
    AND   scho.start_dt   = cp_start_dt
    FOR UPDATE OF
      scho.LAST_UPDATE_DATE NOWAIT;

    v_scho_del_exists c_scho_del%ROWTYPE;

BEGIN

  FOR v_scho_rec IN c_scho LOOP
    -- Delete unconfirmed IGS_EN_STDNTPSHECSOP
    FOR v_scho_del_exists IN c_scho_del(v_scho_rec.start_dt) LOOP

      IGS_EN_STDNTPSHECSOP_PKG.DELETE_ROW ( X_ROWID => V_SCHO_DEL_EXISTS.ROWID );

    END LOOP;

  END LOOP;

EXCEPTION
  WHEN e_resource_busy THEN
    IF c_scho%ISOPEN THEN
      CLOSE c_scho;
    END IF;
    IF c_scho_del%ISOPEN THEN
      CLOSE c_scho_del;
    END IF;

  WHEN OTHERS THEN
    IF c_scho%ISOPEN THEN
      CLOSE c_scho;
    END IF;
    IF c_scho_del%ISOPEN THEN
      CLOSE c_scho_del;
    END IF;

END;

END del_scho;

PROCEDURE del_scae(
  p_person_id   IGS_EN_STDNT_PS_ATT.person_id%TYPE,
  p_course_cd   IGS_EN_STDNT_PS_ATT.course_cd%TYPE)
IS

BEGIN -- del_scae
  -- (4) Delete IGS_AS_SC_ATMPT_ENR scae
DECLARE
  CURSOR c_scae IS
    SELECT ROWID, scae.*
    FROM  IGS_AS_SC_ATMPT_ENR scae
    WHERE scae.person_id    = p_person_id
    AND   scae.course_cd    = p_course_cd
    FOR UPDATE OF scae.LAST_UPDATE_DATE NOWAIT;

BEGIN
  FOR v_scae_rec IN c_scae LOOP

    IGS_AS_SC_ATMPT_ENR_PKG.DELETE_ROW(v_scae_rec.rowid);

  END LOOP;

EXCEPTION
  WHEN e_resource_busy THEN
    IF c_scae%ISOPEN THEN
      CLOSE c_scae;
    END IF;

  WHEN OTHERS THEN
    IF c_scae%ISOPEN THEN
      CLOSE c_scae;
    END IF;

END;

END del_scae;

PROCEDURE del_scan(
  p_person_id   IGS_AS_SC_ATMPT_NOTE.person_id%TYPE,
  p_course_cd   IGS_AS_SC_ATMPT_NOTE.course_cd%TYPE)
IS
BEGIN -- del_scan
  -- Delete student IGS_PS_COURSE attempt notes (5)
DECLARE
  CURSOR c_scan IS
    SELECT ROWID, scan.*
    FROM  IGS_AS_SC_ATMPT_NOTE  scan
    WHERE scan.person_id    = p_person_id
    AND   scan.course_cd    = p_course_cd
    FOR UPDATE OF scan.reference_number NOWAIT;


BEGIN
  FOR v_scan_rec IN c_scan LOOP
    -- Call RI check routine for the IGS_AS_SC_ATMPT_NOTE table
    IGS_AS_SC_ATMPT_NOTE_PKG.DELETE_ROW(v_scan_rec.rowid);

  END LOOP;

EXCEPTION
  WHEN e_resource_busy THEN
    IF c_scan%ISOPEN THEN
      CLOSE c_scan;
    END IF;
  WHEN OTHERS THEN
    IF c_scan%ISOPEN THEN
      CLOSE c_scan;
    END IF;

END;

END del_scan;

PROCEDURE upd_del_re_candidature(
  p_person_id     IGS_AV_ADV_STANDING.person_id%TYPE,
  p_course_cd     IGS_AV_ADV_STANDING.course_cd%TYPE,
  p_adm_admission_appl_number IGS_RE_CANDIDATURE.acai_admission_appl_number%TYPE,
  p_adm_nominated_course_cd IGS_RE_CANDIDATURE.acai_nominated_course_cd%TYPE,
  p_adm_sequence_number   IGS_RE_CANDIDATURE.acai_sequence_number%TYPE)
IS
BEGIN -- upd_re_candidature
  -- Process IGS_RE_CANDIDATURE
DECLARE
  CURSOR c_ca IS
    SELECT  rowid, ca.*
    FROM  IGS_RE_CANDIDATURE  ca
    WHERE ca.person_id      = p_person_id
    AND   ca.sca_course_cd    = p_course_cd
    FOR UPDATE OF ca.sca_course_cd NOWAIT;

BEGIN
  FOR v_ca_rec IN c_ca LOOP

    IF (V_CA_REC.ACAI_ADMISSION_APPL_NUMBER IS NULL AND
       V_CA_REC.ACAI_NOMINATED_COURSE_CD IS NULL AND
       V_CA_REC.ACAI_SEQUENCE_NUMBER IS NULL) THEN

        IGS_RE_CANDIDATURE_PKG.DELETE_ROW(X_ROWID  => V_CA_REC.ROWID);
    ELSE

      IGS_RE_CANDIDATURE_PKG.UPDATE_ROW(
        X_ROWID       => V_CA_REC.ROWID,
        X_PERSON_ID       => V_CA_REC.PERSON_ID,
        X_SEQUENCE_NUMBER     => V_CA_REC.SEQUENCE_NUMBER,
        X_SCA_COURSE_CD     => NULL,
        X_ACAI_ADMISSION_APPL_NUMBER  => V_CA_REC.ACAI_ADMISSION_APPL_NUMBER,
        X_ACAI_NOMINATED_COURSE_CD  => V_CA_REC.ACAI_NOMINATED_COURSE_CD,
        X_ACAI_SEQUENCE_NUMBER    => V_CA_REC.ACAI_SEQUENCE_NUMBER,
        X_ATTENDANCE_PERCENTAGE   => V_CA_REC.ATTENDANCE_PERCENTAGE,
        X_GOVT_TYPE_OF_ACTIVITY_CD  => V_CA_REC.GOVT_TYPE_OF_ACTIVITY_CD,
        X_MAX_SUBMISSION_DT     => V_CA_REC.MAX_SUBMISSION_DT,
        X_MIN_SUBMISSION_DT     => V_CA_REC.MIN_SUBMISSION_DT,
        X_RESEARCH_TOPIC    => V_CA_REC.RESEARCH_TOPIC,
        X_INDUSTRY_LINKS    => V_CA_REC.INDUSTRY_LINKS
        );
    END IF;
  END LOOP;

EXCEPTION
  WHEN e_resource_busy THEN
    IF c_ca%ISOPEN THEN
      CLOSE c_ca;
    END IF;
  WHEN OTHERS THEN
    IF c_ca%ISOPEN THEN
      CLOSE c_ca;
    END IF;

END;

END upd_del_re_candidature;

PROCEDURE del_av(
  p_person_id   IGS_AV_ADV_STANDING.person_id%TYPE,
  p_course_cd   IGS_AV_ADV_STANDING.course_cd%TYPE,
  p_version_num IGS_AV_ADV_STANDING.version_number%TYPE)
IS
BEGIN -- del_av
  -- Delete IGS_AV_ADV_STANDING records
DECLARE
  CURSOR c_av IS
    SELECT  ROWID
    FROM  IGS_AV_ADV_STANDING av
    WHERE av.person_id = p_person_id
    AND   av.course_cd = p_course_cd
    AND   av.version_number = p_version_num;

  c_av_rec c_av%ROWTYPE;

BEGIN

  FOR c_av_rec IN c_av LOOP
          -- Delete IGS_AV_ADV_STANDING records
    IGS_AV_ADV_STANDING_PKG.DELETE_ROW( c_av_rec.ROWID);

  END LOOP;
  -- Return the default value

EXCEPTION
  WHEN e_resource_busy THEN
    IF c_av%ISOPEN THEN
      CLOSE c_av;
    END IF;
  WHEN OTHERS THEN
    IF c_av%ISOPEN THEN
      CLOSE c_av;
    END IF;

END;

END del_av;

-- To delete IGS_FI_FEE_AS_RT table records
PROCEDURE del_fi_fee(p_person_id   IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                  p_course_cd   IGS_EN_STDNT_PS_ATT.course_cd%TYPE)
IS

CURSOR c_del_fi_fee  IS
    SELECT rowid
    FROM IGS_FI_FEE_AS_RT  fi_fee
    WHERE fi_fee.person_id = p_person_id
    AND fi_fee.course_cd = p_course_cd;

v_del_fi_fee      c_del_fi_fee%ROWTYPE;

BEGIN
    FOR v_del_fi_fee IN  c_del_fi_fee LOOP

        IGS_FI_FEE_AS_RT_PKG.DELETE_ROW(v_del_fi_fee.rowid);

    END LOOP;

EXCEPTION
  WHEN e_resource_busy THEN
      IF c_del_fi_fee%ISOPEN THEN
        CLOSE c_del_fi_fee;
      END IF;

  WHEN OTHERS THEN
    IF c_del_fi_fee%ISOPEN THEN
      CLOSE c_del_fi_fee;
    END IF;

END del_fi_fee;


-- To delete intermission records
PROCEDURE del_ps_intm(p_person_id    IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                     p_course_cd    IGS_EN_STDNT_PS_ATT.course_cd%TYPE)
 IS

CURSOR c_del_ps_intm   IS
    SELECT rowid
    FROM IGS_EN_STDNT_PS_INTM  intm
    WHERE intm.person_id = p_person_id
    AND intm.course_cd = p_course_cd;

v_del_ps_intm      c_del_ps_intm%ROWTYPE;

BEGIN

    FOR v_del_ps_intm IN  c_del_ps_intm LOOP
        IGS_EN_STDNT_PS_INTM_PKG.DELETE_ROW(v_del_ps_intm.rowid);
    END LOOP;

EXCEPTION
  WHEN e_resource_busy THEN
      IF c_del_ps_intm%ISOPEN THEN
        CLOSE c_del_ps_intm;
      END IF;

  WHEN OTHERS THEN
    IF c_del_ps_intm%ISOPEN THEN
      CLOSE c_del_ps_intm;
    END IF;

END del_ps_intm;

PROCEDURE del_ps_trnsf(p_person_id   IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                        p_course_cd   IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                        p_term_cal_type          IGS_CA_INST.cal_type%TYPE,
                        p_term_sequence_number     IGS_CA_INST.sequence_number%TYPE)
IS

CURSOR c_del_ps_trnsf  IS
    SELECT rowid
    FROM IGS_PS_STDNT_TRN  trnsf
    WHERE trnsf.person_id = p_person_id
    AND trnsf.course_cd = p_course_cd
    AND trnsf.effective_term_cal_type = p_term_cal_type
    AND trnsf.effective_term_sequence_num = p_term_sequence_number
    AND trnsf.status_flag = 'C';

v_del_ps_trnsf      c_del_ps_trnsf%ROWTYPE;

BEGIN

    FOR v_del_ps_trnsf IN  c_del_ps_trnsf LOOP

        IGS_PS_STDNT_TRN_PKG.DELETE_ROW(v_del_ps_trnsf.rowid);

    END LOOP;

EXCEPTION
  WHEN e_resource_busy THEN
    IF c_del_ps_trnsf%ISOPEN THEN
      CLOSE c_del_ps_trnsf;
    END IF;

  WHEN OTHERS THEN

   IF c_del_ps_trnsf%ISOPEN THEN
    CLOSE c_del_ps_trnsf;
   END IF;

END del_ps_trnsf;



PROCEDURE del_pr_cohinst_rank(p_person_id    IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                             p_course_cd    IGS_EN_STDNT_PS_ATT.course_cd%TYPE)
 IS

CURSOR c_del_pr_cohinst_rank   IS
    SELECT rowid
    FROM igs_pr_cohinst_rank  pr_cohinst
    WHERE pr_cohinst.person_id = p_person_id
    AND pr_cohinst.course_cd = p_course_cd;

v_del_pr_cohinst    c_del_pr_cohinst_rank%ROWTYPE;

BEGIN
    FOR v_del_pr_cohinst IN  c_del_pr_cohinst_rank LOOP

        igs_pr_cohinst_rank_pkg.DELETE_ROW(v_del_pr_cohinst.rowid);

    END LOOP;
EXCEPTION
  WHEN e_resource_busy THEN
      IF c_del_pr_cohinst_rank%ISOPEN THEN
        CLOSE c_del_pr_cohinst_rank;
      END IF;
  WHEN OTHERS THEN
    IF c_del_pr_cohinst_rank%ISOPEN THEN
      CLOSE c_del_pr_cohinst_rank;
    END IF;

END del_pr_cohinst_rank;


PROCEDURE del_as_anon_id_ps(p_person_id    IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                           p_course_cd    IGS_EN_STDNT_PS_ATT.course_cd%TYPE)
IS

CURSOR c_del_as_anon_id_ps   IS
    SELECT rowid
    FROM igs_as_anon_id_ps  as_anon_id_ps
    WHERE as_anon_id_ps.person_id = p_person_id
    AND as_anon_id_ps.course_cd = p_course_cd;

v_del_as_anon_id_ps     c_del_as_anon_id_ps%ROWTYPE;

BEGIN

    FOR v_del_as_anon_id_ps IN  c_del_as_anon_id_ps LOOP
        igs_as_anon_id_ps_pkg.DELETE_ROW(v_del_as_anon_id_ps.rowid);
    END LOOP;

EXCEPTION
  WHEN e_resource_busy THEN
      IF c_del_as_anon_id_ps%ISOPEN THEN
        CLOSE c_del_as_anon_id_ps;
      END IF;

  WHEN OTHERS THEN
    IF c_del_as_anon_id_ps%ISOPEN THEN
      CLOSE c_del_as_anon_id_ps;
    END IF;

END del_as_anon_id_ps;

-- procedure to delete all the unit attempt reference codes
PROCEDURE del_suar(p_person_id    IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                   p_course_cd    IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                   p_uoo_id       IGS_EN_SU_ATTEMPT.uoo_id%TYPE)
 IS

 CURSOR  cur_sua_ref_cds(cp_person_id NUMBER,
                         cp_course_cd VARCHAR2,
                         cp_uoo_id NUMBER) IS
  Select suar.rowid
  From IGS_AS_SUA_REF_CDS suar
  Where suar.person_id = cp_person_id
  And   suar.course_cd = cp_course_cd
  And   suar.uoo_id    = cp_uoo_id;

 BEGIN
  FOR v_cur_sua_ref_cds IN cur_sua_ref_cds(p_person_id,p_course_cd,p_uoo_id) LOOP
    igs_as_sua_ref_cds_pkg.delete_row(v_cur_sua_ref_cds.rowid);
  END LOOP;

  EXCEPTION
  WHEN e_resource_busy THEN
      IF cur_sua_ref_cds%ISOPEN THEN
        CLOSE cur_sua_ref_cds;
      END IF;
  WHEN OTHERS THEN
    IF cur_sua_ref_cds%ISOPEN THEN
      CLOSE cur_sua_ref_cds;
    END IF;

 END del_suar;


PROCEDURE del_as_anon_id_us(p_person_id    IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                            p_course_cd   IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                            p_uoo_id IGS_EN_SU_ATTEMPT.uoo_id%TYPE)
 IS

CURSOR c_del_as_anon_id_us   IS
    SELECT rowid
    FROM igs_as_anon_id_us  as_anon_id_us
    WHERE as_anon_id_us.person_id = p_person_id
    AND as_anon_id_us.course_cd = p_course_cd
    AND as_anon_id_us.uoo_id = p_uoo_id;
v_del_as_anon_id_us     c_del_as_anon_id_us%ROWTYPE;

BEGIN

    FOR v_del_as_anon_id_us IN  c_del_as_anon_id_us LOOP
        igs_as_anon_id_us_pkg.DELETE_ROW(v_del_as_anon_id_us.rowid);
    END LOOP;

EXCEPTION
  WHEN e_resource_busy THEN
      IF c_del_as_anon_id_us%ISOPEN THEN
        CLOSE c_del_as_anon_id_us;
      END IF;
  WHEN OTHERS THEN
    IF c_del_as_anon_id_us%ISOPEN THEN
      CLOSE c_del_as_anon_id_us;
    END IF;

END del_as_anon_id_us;


FUNCTION del_sua(
  p_person_id     IGS_EN_STDNT_PS_ATT.person_id%TYPE,
  p_dest_course_cd     IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
  p_term_cal_type          IGS_CA_INST.cal_type%TYPE,
  p_term_sequence_number     IGS_CA_INST.sequence_number%TYPE
  )
RETURN BOOLEAN
IS
BEGIN -- del_sua
  -- (1) Delete IGS_EN_SU_ATTEMPT records
DECLARE
  CURSOR c_sua IS
    SELECT  uoo_id
    FROM  IGS_EN_SU_ATTEMPT sua
    WHERE sua.person_id = p_person_id
    AND   sua.course_cd = p_dest_course_cd;

  CURSOR c_sua_del (
    cp_uoo_id     IGS_EN_SU_ATTEMPT.uoo_id%TYPE) IS
    SELECT rowid
    FROM  IGS_EN_SU_ATTEMPT   sua
    WHERE sua.person_id     = p_person_id
    AND   sua.course_cd     = p_dest_course_cd
    AND   sua.uoo_id    = cp_uoo_id
    FOR UPDATE OF sua.LAST_UPDATE_DATE NOWAIT;

  v_sua_del_exists  c_sua_del%ROWTYPE;

BEGIN

  FOR v_sua_rec IN c_sua LOOP

    FOR v_sua_del_exists IN c_sua_del(v_sua_rec.uoo_id) LOOP

      -- Delete the unit attempt only if it is in the effective and future terms
      IF  IGS_EN_GEN_010.unit_effect_or_future_term(
                                       p_person_id => p_person_id,
                                       p_dest_course_cd => p_dest_course_cd,
                                       p_uoo_id  => v_sua_rec.uoo_id,
                                       p_term_cal_type => p_term_cal_type ,
                                       p_term_seq_num => p_term_sequence_number) THEN

        del_suar(p_person_id, p_dest_course_Cd, v_sua_rec.uoo_id);

        del_as_anon_id_us( p_person_id,p_dest_course_cd,v_sua_rec.uoo_id);

        IGS_EN_SU_ATTEMPT_PKG.DELETE_ROW( X_ROWID => v_sua_del_exists.rowid );

      END IF;

    END LOOP;

  END LOOP;

RETURN TRUE;
EXCEPTION
  WHEN e_resource_busy THEN
    IF c_sua%ISOPEN THEN
      CLOSE c_sua;
    END IF;
    IF c_sua_del%ISOPEN THEN
      CLOSE c_sua_del;
    END IF;

    RETURN FALSE;

  WHEN OTHERS THEN
    IF c_sua%ISOPEN THEN
      CLOSE c_sua;
    END IF;
    IF c_sua_del%ISOPEN THEN
      CLOSE c_sua_del;
    END IF;
    RETURN FALSE;
END;
END del_sua;


PROCEDURE upd_sua(
  p_person_id     IGS_EN_STDNT_PS_ATT.person_id%TYPE,
  p_dest_course_cd     IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
  p_term_cal_type          IGS_CA_INST.cal_type%TYPE,
  p_term_sequence_number     IGS_CA_INST.sequence_number%TYPE)
IS
BEGIN -- upd_sua
  -- (1) Update IGS_EN_SU_ATTEMPT records
DECLARE

  cst_dropped       CONSTANT VARCHAR2(10) := 'DROPPED';

  CURSOR c_sua IS
    SELECT  uoo_id
    FROM  IGS_EN_SU_ATTEMPT sua
    WHERE sua.person_id = p_person_id
    AND   sua.course_cd = p_dest_course_cd;

  CURSOR c_sua_upd (
    cp_uoo_id     IGS_EN_SU_ATTEMPT.uoo_id%TYPE) IS
    SELECT rowid,sua.*
    FROM  IGS_EN_SU_ATTEMPT   sua
    WHERE sua.person_id     = p_person_id
    AND   sua.course_cd     = p_dest_course_cd
    AND   sua.uoo_id    = cp_uoo_id
    AND   sua.unit_attempt_status <> cst_dropped
    FOR UPDATE OF   sua.LAST_UPDATE_DATE NOWAIT;

  v_sua_del_exists  c_sua_upd%ROWTYPE;

BEGIN

  FOR v_sua_rec IN c_sua LOOP

    FOR v_sua_upd_exists IN c_sua_upd(v_sua_rec.uoo_id) LOOP

      -- Update the unit attempt only if it is in the effective and future terms
      IF  IGS_EN_GEN_010.unit_effect_or_future_term(
                                       p_person_id => p_person_id,
                                       p_dest_course_cd => p_dest_course_cd,
                                       p_uoo_id  => v_sua_rec.uoo_id,
                                       p_term_cal_type => p_term_cal_type ,
                                       p_term_seq_num => p_term_sequence_number) THEN

        IGS_EN_SUA_API.update_unit_attempt(
             X_ROWID                      => v_sua_upd_exists.ROWID,
             X_PERSON_ID                  => v_sua_upd_exists.PERSON_ID,
             X_COURSE_CD                  => v_sua_upd_exists.COURSE_CD ,
             X_UNIT_CD                    => v_sua_upd_exists.UNIT_CD,
             X_CAL_TYPE                   => v_sua_upd_exists.CAL_TYPE,
             X_CI_SEQUENCE_NUMBER         => v_sua_upd_exists.CI_SEQUENCE_NUMBER ,
             X_VERSION_NUMBER             => v_sua_upd_exists.VERSION_NUMBER ,
             X_LOCATION_CD                => v_sua_upd_exists.LOCATION_CD,
             X_UNIT_CLASS                 => v_sua_upd_exists.UNIT_CLASS ,
             X_CI_START_DT                => v_sua_upd_exists.CI_START_DT,
             X_CI_END_DT                  => v_sua_upd_exists.CI_END_DT,
             X_UOO_ID                     => v_sua_upd_exists.UOO_ID ,
             X_ENROLLED_DT                => v_sua_upd_exists.ENROLLED_DT,
             X_UNIT_ATTEMPT_STATUS        => cst_dropped, -- c_IGS_EN_SU_ATTEMPT_rec.UNIT_ATTEMPT_STATUS,
             X_ADMINISTRATIVE_UNIT_STATUS => v_sua_upd_exists.administrative_unit_status,
             X_ADMINISTRATIVE_PRIORITY    => v_sua_upd_exists.administrative_PRIORITY,
             X_DISCONTINUED_DT            => nvl(v_sua_upd_exists.discontinued_dt,trunc(SYSDATE)),
             X_DCNT_REASON_CD             => v_sua_upd_exists.DCNT_REASON_CD,
             X_RULE_WAIVED_DT             => v_sua_upd_exists.RULE_WAIVED_DT ,
             X_RULE_WAIVED_PERSON_ID      => v_sua_upd_exists.RULE_WAIVED_PERSON_ID ,
             X_NO_ASSESSMENT_IND          => v_sua_upd_exists.NO_ASSESSMENT_IND,
             X_SUP_UNIT_CD                => v_sua_upd_exists.SUP_UNIT_CD ,
             X_SUP_VERSION_NUMBER         => v_sua_upd_exists.SUP_VERSION_NUMBER,
             X_EXAM_LOCATION_CD           => v_sua_upd_exists.EXAM_LOCATION_CD,
             X_ALTERNATIVE_TITLE          => v_sua_upd_exists.ALTERNATIVE_TITLE,
             X_OVERRIDE_ENROLLED_CP       => v_sua_upd_exists.OVERRIDE_ENROLLED_CP,
             X_OVERRIDE_EFTSU             => v_sua_upd_exists.OVERRIDE_EFTSU ,
             X_OVERRIDE_ACHIEVABLE_CP     => v_sua_upd_exists.OVERRIDE_ACHIEVABLE_CP,
             X_OVERRIDE_OUTCOME_DUE_DT    => v_sua_upd_exists.OVERRIDE_OUTCOME_DUE_DT,
             X_OVERRIDE_CREDIT_REASON     => v_sua_upd_exists.OVERRIDE_CREDIT_REASON,
             X_WAITLIST_DT                => v_sua_upd_exists.waitlist_dt,
             X_MODE                       =>  'R',
             X_GS_VERSION_NUMBER          => v_sua_upd_exists.gs_version_number,
             X_ENR_METHOD_TYPE            => v_sua_upd_exists.enr_method_type,
             X_FAILED_UNIT_RULE           => v_sua_upd_exists.FAILED_UNIT_RULE,
             X_CART                       => v_sua_upd_exists.CART,
             X_RSV_SEAT_EXT_ID            => v_sua_upd_exists.RSV_SEAT_EXT_ID ,
             X_ORG_UNIT_CD                => v_sua_upd_exists.org_unit_cd    ,
             X_SESSION_ID                 => v_sua_upd_exists.session_id,
             X_GRADING_SCHEMA_CODE        => v_sua_upd_exists.grading_schema_code,
             X_DEG_AUD_DETAIL_ID          => v_sua_upd_exists.deg_aud_detail_id,
             X_SUBTITLE                   =>  v_sua_upd_exists.subtitle,
             X_STUDENT_CAREER_TRANSCRIPT  => v_sua_upd_exists.student_career_transcript,
             X_STUDENT_CAREER_STATISTICS  => v_sua_upd_exists.student_career_statistics,
             X_ATTRIBUTE_CATEGORY         => v_sua_upd_exists.attribute_category,
             X_ATTRIBUTE1                 => v_sua_upd_exists.attribute1,
             X_ATTRIBUTE2                 => v_sua_upd_exists.attribute2,
             X_ATTRIBUTE3                 => v_sua_upd_exists.attribute3,
             X_ATTRIBUTE4                 => v_sua_upd_exists.attribute4,
             X_ATTRIBUTE5                 => v_sua_upd_exists.attribute5,
             X_ATTRIBUTE6                 => v_sua_upd_exists.attribute6,
             X_ATTRIBUTE7                 => v_sua_upd_exists.attribute7,
             X_ATTRIBUTE8                 => v_sua_upd_exists.attribute8,
             X_ATTRIBUTE9                 => v_sua_upd_exists.attribute9,
             X_ATTRIBUTE10                => v_sua_upd_exists.attribute10,
             X_ATTRIBUTE11                => v_sua_upd_exists.attribute11,
             X_ATTRIBUTE12                => v_sua_upd_exists.attribute12,
             X_ATTRIBUTE13                => v_sua_upd_exists.attribute13,
             X_ATTRIBUTE14                => v_sua_upd_exists.attribute14,
             X_ATTRIBUTE15                => v_sua_upd_exists.attribute15,
             X_ATTRIBUTE16                => v_sua_upd_exists.attribute16,
             X_ATTRIBUTE17                => v_sua_upd_exists.attribute17,
             X_ATTRIBUTE18                => v_sua_upd_exists.attribute18,
             X_ATTRIBUTE19                => v_sua_upd_exists.attribute19,
             X_ATTRIBUTE20                => v_sua_upd_exists.attribute20,
             X_WAITLIST_MANUAL_IND        => v_sua_upd_exists.waitlist_manual_ind,
             X_WLST_PRIORITY_WEIGHT_NUM   => v_sua_upd_exists.wlst_priority_weight_num,
             X_WLST_PREFERENCE_WEIGHT_NUM => v_sua_upd_exists.wlst_preference_weight_num,
             X_CORE_INDICATOR_CODE        => v_sua_upd_exists.core_indicator_code
             );

       END IF;

    END LOOP;
  END LOOP;

EXCEPTION
  WHEN e_resource_busy THEN
    IF c_sua%ISOPEN THEN
      CLOSE c_sua;
    END IF;
    IF c_sua_upd%ISOPEN THEN
      CLOSE c_sua_upd;
    END IF;

  WHEN OTHERS THEN
    IF c_sua%ISOPEN THEN
      CLOSE c_sua;
    END IF;
    IF c_sua_upd%ISOPEN THEN
      CLOSE c_sua_upd;
    END IF;

END;
END upd_sua;

PROCEDURE del_as_stmptout(p_person_id    IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                            p_course_cd   IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                            p_uoo_id IGS_EN_SU_ATTEMPT.uoo_id%TYPE)
 IS

CURSOR c_del_as_stmptout(cp_person_id IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                             cp_course_cd   IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                             cp_uoo_id IGS_EN_SU_ATTEMPT.uoo_id%TYPE)
    IS
    SELECT rowid
    FROM igs_as_su_stmptout_all  stmptout
    WHERE stmptout.person_id = cp_person_id
    AND stmptout.course_cd = cp_course_cd
    AND stmptout.uoo_id = cp_uoo_id;
v_del_as_stmptout     c_del_as_stmptout%ROWTYPE;

BEGIN

    FOR v_del_as_stmptout IN  c_del_as_stmptout(p_person_id,p_course_cd,p_uoo_id) LOOP
        IGS_AS_SU_STMPTOUT_PKG.DELETE_ROW(v_del_as_stmptout.rowid);
    END LOOP;

EXCEPTION
  WHEN e_resource_busy THEN
      IF c_del_as_stmptout%ISOPEN THEN
        CLOSE c_del_as_stmptout;
      END IF;
  WHEN OTHERS THEN
    IF c_del_as_stmptout%ISOPEN THEN
      CLOSE c_del_as_stmptout;
    END IF;

END del_as_stmptout;

PROCEDURE del_ps_stdnt_unt_trn(p_person_id    IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                            p_course_cd   IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                            p_uoo_id IGS_EN_SU_ATTEMPT.uoo_id%TYPE)
 IS

CURSOR c_del_ps_stdnt_unt_trn(cp_person_id IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                             cp_course_cd   IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                             cp_uoo_id IGS_EN_SU_ATTEMPT.uoo_id%TYPE)
    IS
    SELECT rowid
    FROM IGS_PS_STDNT_UNT_TRN  unttrn
    WHERE unttrn.person_id = cp_person_id
    AND unttrn.course_cd = cp_course_cd
    AND unttrn.uoo_id = cp_uoo_id;
v_del_ps_stdnt_unt_trn     c_del_ps_stdnt_unt_trn%ROWTYPE;

BEGIN

    FOR v_del_ps_stdnt_unt_trn IN  c_del_ps_stdnt_unt_trn(p_person_id,p_course_cd,p_uoo_id) LOOP
        IGS_PS_STDNT_UNT_TRN_PKG.DELETE_ROW(v_del_ps_stdnt_unt_trn.rowid);
    END LOOP;

EXCEPTION
  WHEN e_resource_busy THEN
      IF c_del_ps_stdnt_unt_trn%ISOPEN THEN
        CLOSE c_del_ps_stdnt_unt_trn;
      END IF;
  WHEN OTHERS THEN
    IF c_del_ps_stdnt_unt_trn%ISOPEN THEN
      CLOSE c_del_ps_stdnt_unt_trn;
    END IF;

END del_ps_stdnt_unt_trn;

PROCEDURE del_as_sua_ses_atts(p_person_id    IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                            p_course_cd   IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                            p_uoo_id IGS_EN_SU_ATTEMPT.uoo_id%TYPE)
 IS

CURSOR c_del_as_sua_ses_atts(cp_person_id IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                             cp_course_cd   IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                             cp_uoo_id IGS_EN_SU_ATTEMPT.uoo_id%TYPE)
    IS
    SELECT rowid
    FROM igs_as_sua_ses_atts  sua_ses_atts
    WHERE sua_ses_atts.person_id = cp_person_id
    AND sua_ses_atts.course_cd = cp_course_cd
    AND sua_ses_atts.uoo_id = cp_uoo_id;
v_del_as_sua_ses_atts     c_del_as_sua_ses_atts%ROWTYPE;
v_RETURN_STATUS  VARCHAR2(255) ;
v_MSG_DATA     VARCHAR2(4000);
v_MSG_COUNT      NUMBER ;
BEGIN

    FOR v_del_as_sua_ses_atts IN  c_del_as_sua_ses_atts(p_person_id,p_course_cd,p_uoo_id) LOOP
        IGS_AS_SUA_SES_ATTS_pkg.DELETE_ROW(v_del_as_sua_ses_atts.rowid,
                                           'R' ,
                                          v_RETURN_STATUS,
                                          v_MSG_DATA,
                                          v_MSG_COUNT
                                         );

    END LOOP;



EXCEPTION
  WHEN e_resource_busy THEN
      IF c_del_as_sua_ses_atts%ISOPEN THEN
        CLOSE c_del_as_sua_ses_atts;
      END IF;
  WHEN OTHERS THEN
    IF c_del_as_sua_ses_atts%ISOPEN THEN
      CLOSE c_del_as_sua_ses_atts;
    END IF;

END del_as_sua_ses_atts;

PROCEDURE del_as_msht_su_atmpt(p_person_id    IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                            p_course_cd   IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                            p_uoo_id IGS_EN_SU_ATTEMPT.uoo_id%TYPE)
 IS

CURSOR c_del_as_msht_su_atmpt(cp_person_id IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                             cp_course_cd   IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                             cp_uoo_id IGS_EN_SU_ATTEMPT.uoo_id%TYPE)
    IS
    SELECT rowid
    FROM IGS_AS_MSHT_SU_ATMPT  as_msht_su_atmpt
    WHERE as_msht_su_atmpt.person_id = cp_person_id
    AND as_msht_su_atmpt.course_cd = cp_course_cd
    AND as_msht_su_atmpt.uoo_id = cp_uoo_id;
v_del_as_msht_su_atmpt     c_del_as_msht_su_atmpt%ROWTYPE;

BEGIN

    FOR v_del_as_msht_su_atmpt IN  c_del_as_msht_su_atmpt(p_person_id,p_course_cd,p_uoo_id) LOOP
        IGS_AS_MSHT_SU_ATMPT_PKG.DELETE_ROW(v_del_as_msht_su_atmpt.rowid);

    END LOOP;

EXCEPTION
  WHEN e_resource_busy THEN
      IF c_del_as_msht_su_atmpt%ISOPEN THEN
        CLOSE c_del_as_msht_su_atmpt;
      END IF;
  WHEN OTHERS THEN
    IF c_del_as_msht_su_atmpt%ISOPEN THEN
      CLOSE c_del_as_msht_su_atmpt;
    END IF;

END del_as_msht_su_atmpt;




---- END OF PRIVATE FUNCTIONS

/*----------------------------------------------------------------------------
  ||  Created By : bdeviset
  ||  Created On : 18-NOV-2004
  ||  Purpose : Processing future dated transfer records in cleanup/delete mode.
  ||  In cleanup mode deletes most of the child records for destination program
  ||  and unconfirms it.It also updates the term records against destination
  ||  program with source program details.
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  stutta        30-Dec-2004    Creating/deleting/updating term records while
  ||                               cleanup and resetting globals.
  ||  somasekar   13-apr-2005	bug# 4179106 modified to set the future date
  ||                                 transfer Cancelles status  to 'C'
  ------------------------------------------------------------------------------*/

PROCEDURE cleanup_dest_program(p_person_id      IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                               p_dest_course_cd         IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                               p_term_cal_type          IGS_CA_INST.cal_type%TYPE,
                               p_term_sequence_number     IGS_CA_INST.sequence_number%TYPE,
                               p_mode                 VARCHAR2)

IS
Type term_rec IS RECORD
(
  term_cal_type igs_en_spa_terms.term_cal_type%TYPE,
    term_seq_num igs_en_spa_terms.term_sequence_number%TYPE,
    key_program_flag igs_en_spa_terms.key_program_flag%TYPE

);
CURSOR c_spa_clnup(cp_term_cal_type          IGS_CA_INST.cal_type%TYPE,
                   cp_term_sequence_number   IGS_CA_INST.sequence_number%TYPE,
                   cp_person_id              IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                   cp_dest_course_cd         IGS_EN_STDNT_PS_ATT.course_cd%TYPE) IS
  SELECT rowid,sct.*
  FROM IGS_PS_STDNT_TRN sct
  WHERE sct.effective_term_cal_type = cp_term_cal_type
  AND sct.effective_term_sequence_num = cp_term_sequence_number
  AND sct.person_id = cp_person_id
  AND sct.course_cd = cp_dest_course_cd
  AND ( sct.status_flag = 'U' and p_mode IN ('CLEANUP')
       OR sct.status_flag = 'C' and p_mode IN ('DELETE'));

-- cursor for fetching the source program details
CURSOR c_sca (cp_person_id    IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                cp_course_cd   IGS_EN_STDNT_PS_ATT.course_cd%TYPE) IS
  SELECT   sca.rowid,sca.*
  FROM     IGS_EN_STDNT_PS_ATT  sca
  WHERE    sca.person_id = cp_person_id
  AND      sca.course_cd = cp_course_cd;

-- cursor for fetching the student unit attempt details having status other than dropped or uncofirmed
CURSOR c_sua (cp_person_id    IGS_EN_STDNT_PS_ATT.person_id%TYPE,
              cp_course_cd   IGS_EN_STDNT_PS_ATT.course_cd%TYPE) IS
  SELECT  'X'
  FROM  IGS_EN_SU_ATTEMPT sua
  WHERE sua.person_id = cp_person_id
  AND   sua.course_cd = cp_course_cd
  AND   sua.unit_attempt_status NOT IN  ('DROPPED','UNCONFIRM');

-- cursor for fetching the student unit attempt details having status as dropped
CURSOR c_sua_drop (cp_person_id    IGS_EN_STDNT_PS_ATT.person_id%TYPE,
              cp_course_cd   IGS_EN_STDNT_PS_ATT.course_cd%TYPE) IS
  SELECT  'X'
  FROM  IGS_EN_SU_ATTEMPT sua
  WHERE sua.person_id = cp_person_id
  AND   sua.course_cd = cp_course_cd
  AND   sua.unit_attempt_status = 'DROPPED';

-- cursor to get the future term records of the destination program
CURSOR c_spat (cp_person_id IGS_EN_SPA_TERMS.PERSON_ID%TYPE,
        cp_program_cd IGS_EN_SPA_TERMS.PROGRAM_CD%TYPE,
        cp_cal_type IGS_CA_INST.CAL_TYPE%TYPE,
        cp_sequence_number IGS_CA_INST.SEQUENCE_NUMBER%TYPE) IS
  SELECT spat.rowid, spat.key_program_flag, spat.term_cal_type,
            spat.term_sequence_number
  FROM IGS_EN_SPA_TERMS spat, IGS_CA_INST ci1, IGS_CA_INST ci2
  WHERE spat.person_id = cp_person_id
  AND spat.program_cd = cp_program_cd
  AND spat.term_cal_type = ci2.cal_type
  AND spat.term_sequence_number = ci2.sequence_number
  AND ci1.cal_type = cp_cal_type
  AND ci1.sequence_number = cp_sequence_number
  AND ci1.start_dt <= ci2.start_dt
  ORDER BY ci2.start_dt;

-- cursor to get the any past term records of the source program
  CURSOR c_spat_src (cp_person_id IGS_EN_SPA_TERMS.PERSON_ID%TYPE,
        cp_program_cd IGS_EN_SPA_TERMS.PROGRAM_CD%TYPE,
        cp_cal_type IGS_CA_INST.CAL_TYPE%TYPE,
        cp_sequence_number IGS_CA_INST.SEQUENCE_NUMBER%TYPE) IS
  SELECT spat.key_program_flag
  FROM IGS_EN_SPA_TERMS spat, IGS_CA_INST ci1, IGS_CA_INST ci2
  WHERE spat.person_id = cp_person_id
  AND spat.program_cd = cp_program_cd
  AND spat.term_cal_type = ci2.cal_type
  AND spat.term_sequence_number = ci2.sequence_number
  AND ci1.cal_type = cp_cal_type
  AND ci1.sequence_number = cp_sequence_number
  AND ci1.start_dt > ci2.start_dt
  ORDER BY ci2.start_dt DESC;

 CURSOR c_term_acad_rel(cp_acad IGS_CA_INST.CAL_TYPE%TYPE, cp_term IGS_CA_INST.CAL_TYPE%TYPE,
			cp_term_seq IGS_CA_INST.SEQUENCE_NUMBER%TYPE) IS
 SELECT 'x'
 FROM igs_ca_inst_rel
 WHERE sup_cal_type = cp_acad
 AND   sub_cal_type = cp_term
 AND   sub_ci_sequence_number = cp_term_seq;


 -- Get the details of
 CURSOR c_src_eff_term(cp_src_course_cd IGS_PS_VER.COURSE_CD%TYPE) IS
   SELECT term_cal_type, term_sequence_number
     FROM igs_en_spa_terms spat, igs_ca_inst ca1, igs_ca_inst ca2
    WHERE ca1.cal_type = p_term_cal_type
      AND ca1.sequence_number = p_term_sequence_number
      AND spat.person_id = p_person_id
      AND spat.program_cd = cp_src_course_cd
      AND ca2.cal_type = spat.term_cal_type
      AND ca2.sequence_number = spat.term_sequence_number
      AND ca2.start_dt >= ca1.start_dt
      ORDER BY ca2.start_dt ASC;


l_acad_cal IGS_EN_SPA_TERMS.ACAD_CAL_TYPE%TYPE;
l_dummy VARCHAR2(1);
cst_unconfirm   CONSTANT VARCHAR2(10) := 'UNCONFIRM';
v_del               BOOLEAN;
v_sca_src_rec       c_sca%ROWTYPE;
v_sca_dest_rec      c_sca%ROWTYPE;
v_spa_clnup_rec     c_spa_clnup%ROWTYPE;
v_spa_del_rec       c_spa_clnup%ROWTYPE;
v_rec_exists        VARCHAR2(1);
v_message_name      VARCHAR2(30);
v_src_course_cd     IGS_EN_STDNT_PS_ATT.course_cd%TYPE;
l_src_career_type   IGS_PS_VER.COURSE_TYPE%TYPE;
l_status_date       IGS_PS_STDNT_TRN.status_date%TYPE;
l_trans_status      IGS_PS_STDNT_TRN.status_flag%TYPE;
l_tran_across_careers BOOLEAN;
l_trans_within_careers BOOLEAN;
l_stdnt_conf_ind    IGS_EN_STDNT_PS_ATT.STUDENT_CONFIRMED_IND%TYPE;
l_comm_date         IGS_EN_STDNT_PS_ATT.COMMENCEMENT_DT%TYPE;
l_course_att_status IGS_EN_STDNT_PS_ATT.COURSE_ATTEMPT_STATUS%TYPE;
v_src_career_type igs_ps_ver.course_type%TYPE;
v_spat_rec c_spat_src%ROWTYPE;
TYPE terms_tab IS TABLE OF term_rec INDEX BY BINARY_INTEGER;
terms terms_tab;
terms_ind NUMBER;
v_ripple BOOLEAN;
l_key_program_flag IGS_EN_SPA_TERMS.key_program_flag%TYPE;
l_term_cal_type IGS_EN_SPA_TERMS.TERM_CAL_TYPE%TYPE;
l_term_seq_num IGS_EN_SPA_TERMS.TERM_SEQUENCE_NUMBER%TYPE;
BEGIN -----------------Begining of cleanup/delete

SAVEPOINT sp_unable_to_clnup_del;

OPEN c_spa_clnup(p_term_cal_type,
                 p_term_sequence_number,
                 p_person_id,
                 p_dest_course_cd
                 );
  FETCH c_spa_clnup INTO v_spa_clnup_rec;

  IF c_spa_clnup%NOTFOUND THEN
    CLOSE c_spa_clnup;
    RETURN;
  END IF;

CLOSE c_spa_clnup;

OPEN c_sca(p_person_id,p_dest_course_cd);
FETCH c_sca INTO v_sca_dest_rec;
CLOSE c_sca;

v_src_course_cd := v_spa_clnup_rec.transfer_course_cd;

OPEN c_sca(p_person_id,v_src_course_cd);
FETCH c_sca INTO v_sca_src_rec;
CLOSE c_sca;


IF p_mode = 'CLEANUP' THEN

-- Since the cleanup mode is done in a different way in intra career transfer
-- check if the transfer is within careers
  IF  is_career_model_enabled THEN

      IF  is_tranfer_across_careers(
                  v_sca_dest_rec.course_cd,
                  v_sca_dest_rec.version_number,
                  v_sca_src_rec.course_cd,
                  v_sca_src_rec.version_number,
                  v_src_career_type
                  ) = FALSE THEN

        l_trans_within_careers := TRUE;

      END IF;

  END IF;


  l_status_date := SYSDATE;
  l_trans_status := 'C';
  l_stdnt_conf_ind := v_sca_dest_rec.student_confirmed_ind;
  l_comm_date := v_sca_dest_rec.commencement_dt;
  l_course_att_status := v_sca_dest_rec.course_attempt_status;

  -- If it is within career
  IF l_trans_within_careers THEN

     -- Delete unit attempts existing in the effective and future terms against destination program.
    IF NOT del_sua(
                   p_person_id,
                   p_dest_course_cd,
                   p_term_cal_type,
                   p_term_sequence_number
                   ) THEN

      ----IF not able to delete then update unit attempt status as 'DROPPED'
        upd_sua(
                p_person_id,
                p_dest_course_cd,
                p_term_cal_type,
                p_term_sequence_number
                );

    END IF;

    OPEN c_sua ( p_person_id,p_dest_course_cd);
    FETCH c_sua INTO v_rec_exists;

    -- if there are no unit attempts with status other than dropped/unconfirmed
    -- then delete child records and set the status of destination program
    -- as unconfirmed
    IF c_sua%NOTFOUND THEN

      -- setting the commencement date,student confirmed indicator
      -- as  course attempt status is unconfirmed.
      l_stdnt_conf_ind := 'N';
      l_comm_date := NULL;
      l_course_att_status := cst_unconfirm;

      --- Delete all the child records of the destination program

      del_gua( p_person_id,p_dest_course_cd);

      del_esaa( p_person_id,p_dest_course_cd);

      del_gsa( p_person_id,p_dest_course_cd);

      del_hssc( p_person_id,p_dest_course_cd);

      del_hssa( p_person_id,p_dest_course_cd);

      del_pr_rule_appl( p_person_id, p_dest_course_cd);

      del_psaa( p_person_id,p_dest_course_cd);

      del_scho( p_person_id,p_dest_course_cd);

      del_scae( p_person_id,p_dest_course_cd);

      del_scan( p_person_id,p_dest_course_cd);

      del_fi_fee( p_person_id,p_dest_course_cd);

      del_ps_intm( p_person_id,p_dest_course_cd);

      del_pr_cohinst_rank( p_person_id,p_dest_course_cd);

      del_as_anon_id_ps( p_person_id,p_dest_course_cd);

    END IF; -- End of IF c_sua%NOTFOUND
    CLOSE c_sua;

  END IF; -- End of IF l_trans_within_careers


  -- 	Update the transfer record set status_flag = 'C' and status_date = SYSDATE
  IGS_PS_STDNT_TRN_PKG.update_row(
            X_ROWID => v_spa_clnup_rec.rowid,
            X_PERSON_ID => v_spa_clnup_rec.person_id,
            X_COURSE_CD => v_spa_clnup_rec.course_cd,
            X_TRANSFER_COURSE_CD => v_spa_clnup_rec.transfer_course_cd,
            X_TRANSFER_DT =>  v_spa_clnup_rec.transfer_dt,
            X_COMMENTS => v_spa_clnup_rec.comments,
            X_APPROVED_DATE => v_spa_clnup_rec.approved_date,
            X_EFFECTIVE_TERM_CAL_TYPE => v_spa_clnup_rec.effective_term_cal_type,
            X_EFFECTIVE_TERM_SEQUENCE_NUM => v_spa_clnup_rec.effective_term_sequence_num,
            X_DISCONTINUE_SOURCE_FLAG => v_spa_clnup_rec.discontinue_source_flag,
            X_UOOIDS_TO_TRANSFER => v_spa_clnup_rec.uooids_to_transfer,
            X_SUSA_TO_TRANSFER => v_spa_clnup_rec.susa_to_transfer,
            X_TRANSFER_ADV_STAND_FLAG => v_spa_clnup_rec.transfer_adv_stand_flag,
            X_STATUS_DATE => l_status_date,
            X_STATUS_FLAG => l_trans_status
            );

  -- Start of deletion and updation/creation of term records
  IF  is_career_model_enabled THEN
--
  l_tran_across_careers := is_tranfer_across_careers(
            v_sca_dest_rec.course_cd,
            v_sca_dest_rec.version_number,
            v_sca_src_rec.course_cd,
            v_sca_src_rec.version_number,
            v_src_career_type
            );
  ELSE
--        If in program mode, consider it as across career transfer
      l_tran_across_careers := TRUE;
  END IF;

  IF NOT l_tran_across_careers OR (l_tran_across_careers AND v_sca_src_rec.key_program = 'Y') THEN
   -- if within career or across career with source key.
    terms_ind := 0;
    -- Loop to delete destination term records in the terms in which future dated transfer was
    -- effective. Delete of term records is only valid for within career transfers.
    FOR v_spat_recd IN c_spat(p_person_id, p_dest_course_cd, p_term_cal_type,p_term_sequence_number)
    LOOP

        terms(terms_ind).term_cal_type :=v_spat_recd.term_cal_type;
        terms(terms_ind).term_seq_num :=v_spat_recd.term_sequence_number;
        terms(terms_ind).key_program_flag := v_spat_recd.key_program_flag;
        -- Delete the term records against the destination program
        IF NOT l_tran_across_careers THEN
            IGS_EN_SPA_TERMS_PKG.DELETE_ROW(v_spat_recd.rowid);
        END IF;
                    terms_ind := terms_ind + 1;
    END LOOP;
       v_ripple := TRUE;
    FOR i IN terms.FIRST.. terms.LAST LOOP
        -- create term records against source program

      l_acad_cal := igs_en_spa_terms_api.get_spat_acad_cal_type(p_person_id,
								v_src_course_cd,
								terms(i).term_cal_type,
								terms(i).term_seq_num);
       OPEN c_term_acad_rel(l_acad_cal,terms(i).term_cal_type,terms(i).term_seq_num);
       FETCH c_term_acad_rel INTO l_dummy;

	OPEN c_spat_src(p_person_id, v_src_course_cd, terms(i).term_cal_type,terms(i).term_seq_num);
        FETCH c_spat_src INTO v_spat_rec;


	IF v_spat_rec.key_program_flag = 'Y' AND v_ripple THEN
	-- if Source was key and this is the first time entering into loop send key as changing to terms api
		l_key_program_flag := 'Y';
		IF  c_term_acad_rel%NOTFOUND THEN

			OPEN c_src_eff_term(v_src_course_cd);
			FETCH c_src_eff_term INTO l_term_cal_type, l_term_seq_num;
			IF (c_src_eff_term%FOUND) THEN
			 igs_en_spa_terms_api.CREATE_UPDATE_TERM_REC(
			    P_PERSON_ID             => p_person_id,
			    P_PROGRAM_CD            => v_src_course_cd,
			    P_TERM_CAL_TYPE         => l_term_cal_type,
			    P_TERM_SEQUENCE_NUMBER  => l_term_seq_num,
			    P_KEY_PROGRAM_FLAG      => l_key_program_flag, -- using key flag from terms table
			    p_ripple_frwrd          => v_ripple,
			    p_message_name          => v_message_name,
			    p_update_rec            => TRUE
			    );
			END IF;

		END IF;

	ELSE
		l_key_program_flag := FND_API.G_MISS_CHAR;
	END IF;


       IF  (c_term_acad_rel%FOUND)THEN


       -- Terms api called as key changed if source is key and with ripple forward as TRUE only for the first time in loop
       igs_en_spa_terms_api.CREATE_UPDATE_TERM_REC(
            P_PERSON_ID             => p_person_id,
            P_PROGRAM_CD            => v_src_course_cd,
            P_TERM_CAL_TYPE         => terms(i).term_cal_type,
            P_TERM_SEQUENCE_NUMBER  => terms(i).term_seq_num,
            P_KEY_PROGRAM_FLAG      => l_key_program_flag, -- using key flag from terms table
            p_ripple_frwrd          => v_ripple,
            p_message_name          => v_message_name,
            p_update_rec            => TRUE
            );
	END IF;
	CLOSE c_term_acad_rel;

            v_ripple := FALSE;
            -- create_update_term_rec should be called with p_ripple_frwrd as TRUE only for the first
            -- run. The first record selected by the cursor c_spat is latest term for which the term
            -- record has to be created. Ripple forward has to be passed as TRUE, inorder to ripple
            -- the changes for any future terms that are existing for the source.
            CLOSE c_spat_src;

    END LOOP;

  END IF;
  --  End of deletion and updation/creation of term records



     -- update the destination program attempt with the values of l_stdnt_conf_ind,l_comm_date,l_course_att_status
     -- and set the future dated transfer flag to 'N'
        IGS_EN_STDNT_PS_ATT_PKG.UPDATE_ROW(
           X_ROWID                      => v_sca_dest_rec.ROWID,
           X_PERSON_ID                  => v_sca_dest_rec.PERSON_ID,
           X_COURSE_CD                  => v_sca_dest_rec.COURSE_CD,
           X_VERSION_NUMBER             => v_sca_dest_rec.VERSION_NUMBER,
           X_CAL_TYPE                   => v_sca_dest_rec.CAL_TYPE,
           X_LOCATION_CD                => v_sca_dest_rec.LOCATION_CD,
           X_ATTENDANCE_MODE            => v_sca_dest_rec.ATTENDANCE_MODE,
           X_ATTENDANCE_TYPE            => v_sca_dest_rec.ATTENDANCE_TYPE,
           X_COO_ID                     => v_sca_dest_rec.COO_ID,
           X_STUDENT_CONFIRMED_IND      => l_stdnt_conf_ind,
           X_COMMENCEMENT_DT            => l_comm_date,
           X_COURSE_ATTEMPT_STATUS      => l_course_att_status,
           X_PROGRESSION_STATUS         => v_sca_dest_rec.PROGRESSION_STATUS,
           X_DERIVED_ATT_TYPE           => v_sca_dest_rec.DERIVED_ATT_TYPE,
           X_DERIVED_ATT_MODE           => v_sca_dest_rec.DERIVED_ATT_MODE,
           X_PROVISIONAL_IND            => v_sca_dest_rec.PROVISIONAL_IND,
           X_DISCONTINUED_DT            => v_sca_dest_rec.DISCONTINUED_DT,
           X_DISCONTINUATION_REASON_CD  => v_sca_dest_rec.DISCONTINUATION_REASON_CD,
           X_LAPSED_DT                  => v_sca_dest_rec.LAPSED_DT,
           X_FUNDING_SOURCE             => v_sca_dest_rec.FUNDING_SOURCE,
           X_EXAM_LOCATION_CD           => v_sca_dest_rec.EXAM_LOCATION_CD,
           X_DERIVED_COMPLETION_YR      => v_sca_dest_rec.DERIVED_COMPLETION_YR,
           X_DERIVED_COMPLETION_PERD    => v_sca_dest_rec.DERIVED_COMPLETION_PERD,
           X_NOMINATED_COMPLETION_YR    => v_sca_dest_rec.NOMINATED_COMPLETION_YR,
           X_NOMINATED_COMPLETION_PERD  => v_sca_dest_rec.NOMINATED_COMPLETION_PERD,
           X_RULE_CHECK_IND             => v_sca_dest_rec.RULE_CHECK_IND,
           X_WAIVE_OPTION_CHECK_IND     => v_sca_dest_rec.WAIVE_OPTION_CHECK_IND,
           X_LAST_RULE_CHECK_DT         => v_sca_dest_rec.LAST_RULE_CHECK_DT,
           X_PUBLISH_OUTCOMES_IND       => v_sca_dest_rec.PUBLISH_OUTCOMES_IND,
           X_COURSE_RQRMNT_COMPLETE_IND => v_sca_dest_rec.COURSE_RQRMNT_COMPLETE_IND,
           X_COURSE_RQRMNTS_COMPLETE_DT => v_sca_dest_rec.COURSE_RQRMNTS_COMPLETE_DT,
           X_S_COMPLETED_SOURCE_TYPE    => v_sca_dest_rec.S_COMPLETED_SOURCE_TYPE,
           X_OVERRIDE_TIME_LIMITATION   => v_sca_dest_rec.OVERRIDE_TIME_LIMITATION,
           X_ADVANCED_STANDING_IND      => v_sca_dest_rec.ADVANCED_STANDING_IND,
           X_FEE_CAT                    => v_sca_dest_rec.FEE_CAT,
           X_CORRESPONDENCE_CAT         => v_sca_dest_rec.CORRESPONDENCE_CAT,
           X_SELF_HELP_GROUP_IND        => v_sca_dest_rec.SELF_HELP_GROUP_IND,
           X_LOGICAL_DELETE_DT          => v_sca_dest_rec.LOGICAL_DELETE_DT,
           X_ADM_ADMISSION_APPL_NUMBER  => v_sca_dest_rec.ADM_ADMISSION_APPL_NUMBER,
           X_ADM_NOMINATED_COURSE_CD    => v_sca_dest_rec.ADM_NOMINATED_COURSE_CD,
           X_ADM_SEQUENCE_NUMBER        => v_sca_dest_rec.ADM_SEQUENCE_NUMBER,
           X_LAST_DATE_OF_ATTENDANCE    => v_sca_dest_rec.LAST_DATE_OF_ATTENDANCE,
           X_DROPPED_BY                 => v_sca_dest_rec.DROPPED_BY,
           X_IGS_PR_CLASS_STD_ID        => v_sca_dest_rec.IGS_PR_CLASS_STD_ID ,
           X_PRIMARY_PROGRAM_TYPE       => v_sca_dest_rec.primary_program_type,
           X_PRIMARY_PROG_TYPE_SOURCE   => v_sca_dest_rec.PRIMARY_PROG_TYPE_SOURCE,
           X_CATALOG_CAL_TYPE           => v_sca_dest_rec.CATALOG_CAL_TYPE,
           X_CATALOG_SEQ_NUM            => v_sca_dest_rec.CATALOG_SEQ_NUM,
           X_KEY_PROGRAM                => v_sca_dest_rec.key_program,
           X_MANUAL_OVR_CMPL_DT_IND     => v_sca_dest_rec.MANUAL_OVR_CMPL_DT_IND,
           X_OVERRIDE_CMPL_DT           => v_sca_dest_rec.OVERRIDE_CMPL_DT,
           X_MODE           => 'R' ,
           X_ATTRIBUTE_CATEGORY         => v_sca_dest_rec.ATTRIBUTE_CATEGORY,
           X_FUTURE_DATED_TRANS_FLAG    => 'C',
           X_ATTRIBUTE1                 => v_sca_dest_rec.ATTRIBUTE1,
           X_ATTRIBUTE2                 => v_sca_dest_rec.ATTRIBUTE2,
           X_ATTRIBUTE3                 => v_sca_dest_rec.ATTRIBUTE3,
           X_ATTRIBUTE4                 => v_sca_dest_rec.ATTRIBUTE4,
           X_ATTRIBUTE5                 => v_sca_dest_rec.ATTRIBUTE5,
           X_ATTRIBUTE6                 => v_sca_dest_rec.ATTRIBUTE6,
           X_ATTRIBUTE7                 => v_sca_dest_rec.ATTRIBUTE7,
           X_ATTRIBUTE8                 => v_sca_dest_rec.ATTRIBUTE8,
           X_ATTRIBUTE9                 => v_sca_dest_rec.ATTRIBUTE9,
           X_ATTRIBUTE10                => v_sca_dest_rec.ATTRIBUTE10,
           X_ATTRIBUTE11                => v_sca_dest_rec.ATTRIBUTE11,
           X_ATTRIBUTE12                => v_sca_dest_rec.ATTRIBUTE12,
           X_ATTRIBUTE13                => v_sca_dest_rec.ATTRIBUTE13,
           X_ATTRIBUTE14                => v_sca_dest_rec.ATTRIBUTE14,
           X_ATTRIBUTE15                => v_sca_dest_rec.ATTRIBUTE15,
           X_ATTRIBUTE16                => v_sca_dest_rec.ATTRIBUTE16,
           X_ATTRIBUTE17                => v_sca_dest_rec.ATTRIBUTE17,
           X_ATTRIBUTE18                => v_sca_dest_rec.ATTRIBUTE18,
           X_ATTRIBUTE19                => v_sca_dest_rec.ATTRIBUTE19,
           X_ATTRIBUTE20                => v_sca_dest_rec.ATTRIBUTE20);

END IF;  -- END OF  CLean Up

IF p_mode = 'DELETE' THEN

      -- Delete transfer record
 del_ps_trnsf( p_person_id,
               p_dest_course_cd,
               p_term_cal_type,
               p_term_sequence_number);

  -- if the destination program is unconfirmed then only
  -- delete other child records and if no dropped unit
  -- attempts exists then drop the program attempt.
  IF v_sca_dest_rec.course_attempt_status = cst_unconfirm THEN

       -- Delete unit set attempts
    del_susa( p_person_id,p_dest_course_cd);

    -- update/delete research candidature details
    upd_del_re_candidature(
                           p_person_id,
                           p_dest_course_cd,
                           v_sca_dest_rec.adm_admission_appl_number,
                           v_sca_dest_rec.adm_nominated_course_cd,
                           v_sca_dest_rec.adm_sequence_number
                           );

      -- Delete advanced standing details
    del_av(
           p_person_id,
           p_dest_course_cd,
           v_sca_dest_rec.version_number
           );

    OPEN c_sua_drop ( p_person_id,p_dest_course_cd);
    FETCH c_sua_drop INTO v_rec_exists;

      --- If dropped unit attempts doesnot exists then delete program attempt.
    IF (c_sua_drop%NOTFOUND) THEN

       IGS_EN_STDNT_PS_ATT_PKG.DELETE_ROW(v_sca_dest_rec.rowid);

    END IF;

    CLOSE c_sua_drop;

  END IF; --End of IF v_sca_dest_rec.course_attempt_status = cst_unconfirm

END IF; -- End of Delete mode

EXCEPTION
  WHEN OTHERS THEN

    IF c_spa_clnup%ISOPEN THEN
      CLOSE c_spa_clnup;
    END IF;
    IF c_sca%ISOPEN THEN
      CLOSE c_sca;
    END IF;
    IF c_sua_drop%ISOPEN THEN
      CLOSE c_sua_drop;
    END IF;
    ROLLBACK TO sp_unable_to_clnup_del;
    App_Exception.Raise_Exception;

END cleanup_dest_program;


/*----------------------------------------------------------------------------
  ||  Created By : bdeviset
  ||  Created On : 18-NOV-2004
  ||  Purpose : Processing future dated transfer records in process/cleanup/delete mode.
  ||  In cleanup/delete modes it calls cleanup_dest_program.
  ||  In process mode it discontinues the source program including the units
  ||  and unsets the future dated transfer flag for destination program
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||
  ------------------------------------------------------------------------------*/

PROCEDURE process_fut_dt_trans(
         errbuf             OUT NOCOPY  VARCHAR2,
         retcode            OUT NOCOPY NUMBER,
         p_term_cal_comb    IN  VARCHAR2,
         p_mode             IN VARCHAR2,
         p_ignore_warnings  IN  VARCHAR2,
         p_drop_enrolled    IN VARCHAR2
         )
IS

-- Cursor to fetch the records to process
CURSOR c_spa_clnup(cp_term_cal_type      IGS_CA_INST.cal_type%TYPE,
                   cp_term_sequence_number   IGS_CA_INST.sequence_number%TYPE) IS
  SELECT sct.*
  FROM IGS_PS_STDNT_TRN sct
  WHERE effective_term_cal_type = cp_term_cal_type
  AND effective_term_sequence_num = cp_term_sequence_number
  AND ( sct.status_flag = 'U' and p_mode IN ('PROCESS','CLEANUP')
       OR sct.status_flag = 'C' and p_mode IN ('DELETE'));

-- cursor to fetch student program details
CURSOR c_sca (cp_person_id    IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                cp_course_cd   IGS_EN_STDNT_PS_ATT.course_cd%TYPE) IS
  SELECT   sca.rowid,sca.*
  FROM     IGS_EN_STDNT_PS_ATT  sca
  WHERE    sca.person_id = cp_person_id
  AND      sca.course_cd = cp_course_cd;

-- To fetch the date aliases set up in calendar configuration table
CURSOR c_enr_cal_conf IS
  SELECT BEGIN_TRANS_DT_ALIAS,CLEAN_TRANS_DT_ALIAS
  FROM IGS_EN_CAL_CONF
  WHERE s_control_num = 1;

-- cursor to get the clean up date alias value
CURSOR c_cln_up_dt_alias_val(cp_term_cal_type          IGS_CA_INST.cal_type%TYPE,
                             cp_term_sequence_number   IGS_CA_INST.sequence_number%TYPE,
                             cp_cleanup_dt_alias       IGS_CA_DA_INST_V.dt_alias%TYPE ) IS
  SELECT alias_val
  FROM   igs_ca_da_inst_v
  WHERE  cal_type           = cp_term_cal_type
  AND    ci_sequence_number = cp_term_sequence_number
  AND    dt_alias           = cp_cleanup_dt_alias;

-- cursor to get the begin program transfer details
CURSOR c_begin_pt_dt_alias_val(cp_term_cal_type      IGS_CA_INST.cal_type%TYPE,
                               cp_term_sequence_number   IGS_CA_INST.sequence_number%TYPE,
                               cp_begin_pt_dt_alias       IGS_CA_DA_INST_V.dt_alias%TYPE) IS
  SELECT alias_val
  FROM   igs_ca_da_inst_v
  WHERE  cal_type           = cp_term_cal_type
  AND    ci_sequence_number = cp_term_sequence_number
  AND    dt_alias           = cp_begin_pt_dt_alias;

-- cursor to get the person number
CURSOR c_person_num(cp_person_id        IGS_EN_STDNT_PS_ATT.person_id%TYPE) IS
    SELECT party_number
    FROM HZ_PARTIES
    WHERE party_id = cp_person_id;

-- cursor to get the load calendar end date
CURSOR c_load_cal_end_dt(cp_term_cal     IGS_CA_INST.cal_type%TYPE,
                         cp_term_seq_num IGS_CA_INST.sequence_number%TYPE) IS
  SELECT end_dt
  FROM igs_ca_inst
  WHERE cal_type = cp_term_cal
  AND sequence_number = cp_term_seq_num;


-- Cursor to know if the destination program is primary in any of the  prev terms
-- whose start date is greater than transfer date
CURSOR c_prim_in_prev_terms(cp_person_id        IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                            cp_dest_course_cd   IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                            cp_cur_term_cal     IGS_CA_INST.cal_type%TYPE,
                            cp_cur_term_seq_num IGS_CA_INST.sequence_number%TYPE,
                            cp_acad_cal_type    IGS_CA_INST_REL.sup_cal_type%TYPE,
                            cp_transfer_dt      IGS_PS_STDNT_TRN.transfer_dt%TYPE ) IS
 SELECT 'x'
  FROM igs_ca_inst ci2,
      igs_ca_inst_rel cir,
      igs_ca_type ct,
      igs_ca_inst ci1,
      igs_ca_stat cs
  WHERE
  ci2.cal_type        = cir.sub_cal_type AND
  ci2.sequence_number = cir.sub_ci_sequence_number AND
  cir.sup_cal_type    = cp_acad_cal_type AND
  ci2.cal_type        = ct.cal_type AND
  ct.s_cal_cat        = 'LOAD' AND
  cs.cal_status       = ci1.cal_status AND
  cs.s_cal_status     = 'ACTIVE' AND
  ci1.cal_type        = cp_cur_term_cal AND
  ci1.sequence_number = cp_cur_term_seq_num AND
  ci2.start_dt        < ci1.start_dt AND
  ci2.start_dt        > cp_transfer_dt
  AND EXISTS (SELECT 'x' from igs_en_spa_terms spat
               WHERE spat.person_id = cp_person_id
               AND spat.program_cd = cp_dest_course_cd
               AND spat.term_cal_type = ci2.cal_type
               AND spat.term_sequence_number = ci2.sequence_number)
  ORDER BY  ci2.start_dt DESC;


-- Cursor to get uoo details to be transferred
CURSOR c_uoo (cp_person_id        IGS_EN_STDNT_PS_ATT.person_id%TYPE,
              cp_src_course_cd    IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
              cp_dest_course_cd    IGS_EN_STDNT_PS_ATT.course_cd%TYPE) IS
    SELECT uoo_id,core_indicator_code,unit_attempt_status
    FROM IGS_EN_SU_ATTEMPT sua
    WHERE person_id = cp_person_id
    AND course_cd = cp_src_course_cd
    AND not exists (SELECT 'x'
                    FROM igs_en_su_attempt sua2
                    WHERE person_id = cp_person_id
                    AND course_cd=  cp_dest_course_cd
                    AND unit_attempt_status <> 'DROPPED'
                    AND sua.uoo_id = sua2.uoo_id)
    AND unit_Attempt_status not in ('DROPPED','UNCONFIRM');


CURSOR c_sct(cp_term_cal_type      IGS_CA_INST.cal_type%TYPE,
             cp_term_sequence_number   IGS_CA_INST.sequence_number%TYPE,
             cp_person_id        IGS_EN_STDNT_PS_ATT.person_id%TYPE,
             cp_dest_course_cd    IGS_EN_STDNT_PS_ATT.course_cd%TYPE
             ) IS
  SELECT 'X'
  FROM IGS_PS_STDNT_TRN sct
  WHERE effective_term_cal_type = cp_term_cal_type
  AND effective_term_sequence_num = cp_term_sequence_number
  AND sct.person_id = cp_person_id
  AND sct.course_cd = cp_dest_course_cd
  AND sct.status_flag = 'C';




cst_unconfirm     CONSTANT  VARCHAR2(10) := 'UNCONFIRM';
cst_prog_trans    CONSTANT  VARCHAR2(20) := 'PROGRAM_TRANSFER';
v_begin_pt_dt_alias         IGS_CA_DA_INST_V.dt_alias%TYPE;
v_begin_pt_dt_alias_val     IGS_CA_DA_INST_V.alias_val%TYPE;
v_cleanup_dt_alias          IGS_CA_DA_INST_V.dt_alias%TYPE;
v_cleanup_dt_alias_val      IGS_CA_DA_INST_V.alias_val%TYPE;
is_prim_in_prev_term        VARCHAR2(1);
v_sca_src_rec               c_sca%ROWTYPE;
v_sca_dest_rec              c_sca%ROWTYPE;
l_term_cal_type             IGS_CA_DA_INST.cal_type%TYPE;
l_term_sequence_number      IGS_CA_DA_INST.sequence_number%TYPE;
l_end_dt                    IGS_CA_INST.end_dt%TYPE;
v_del                       BOOLEAN;
v_person_num                HZ_PARTIES.party_number%TYPE;
l_acad_cal_seq_num          IGS_CA_DA_INST.sequence_number%TYPE;
l_acad_cal_type             IGS_CA_DA_INST.cal_type%TYPE;
l_message_name              VARCHAR2(30);
l_show_warning              VARCHAR2(1);
l_rec_exists                BOOLEAN;
l_tran_across_careers       BOOLEAN;
l_src_career_type           IGS_PS_VER.COURSE_TYPE%TYPE;
l_new_dest_key_prgm_flag    IGS_EN_STDNT_PS_ATT.KEY_PROGRAM%TYPE;
l_msg                       VARCHAR2(4000);
l_unit_sets_having_errors       VARCHAR2(4000);
l_uoo_ids_having_errors     VARCHAR2(4000);
l_return_status             VARCHAR2(1);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(6000);
l_process_mode              VARCHAR2(10);
v_rec_exists                VARCHAR2(1);


BEGIN
  retcode := 0;
  l_msg := NULL;
  l_acad_cal_seq_num := NULL;
  l_term_cal_type := RTRIM(SUBSTR(P_TERM_CAL_COMB,101,10));
  l_term_sequence_number := TO_NUMBER(RTRIM(SUBSTR(P_TERM_CAL_COMB,112,6)));
  l_rec_exists := FALSE;

  IF p_ignore_warnings = 'Y' THEN

    l_show_warning := 'N';

  ELSE

    l_show_warning := 'Y';

  END IF;

  IF p_drop_enrolled = 'Y' THEN

    l_process_mode := 'DROP';

  ELSE

    l_process_mode := NULL;

  END IF;

  FND_FILE.PUT_LINE (FND_FILE.LOG, ' ');
  FND_FILE.PUT_LINE (FND_FILE.LOG, ' ');
  FND_FILE.PUT_LINE (FND_FILE.LOG, 'Term Calendar :'||l_term_cal_type||', Term Calendar Sequence Number :'||l_term_sequence_number||', Ignore warnings :'||p_ignore_warnings||', Drop Enrolled :'||p_drop_enrolled);
  FND_FILE.PUT_LINE (FND_FILE.LOG, ' ');

  OPEN c_enr_cal_conf;
  FETCH c_enr_cal_conf INTO v_begin_pt_dt_alias,v_cleanup_dt_alias;

  IF c_enr_cal_conf%FOUND THEN

    CLOSE c_enr_cal_conf;
    IF p_mode = 'PROCESS' AND v_begin_pt_dt_alias IS NULL THEN

      FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_BEG_PT_DAV_LT_SYSDATE');
      FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET);
      RETURN;

    END IF;

    IF p_mode = 'CLEANUP' AND v_cleanup_dt_alias IS NULL THEN

      FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_CLNUP_DAV_GE_SYSDATE');
      FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET);
      RETURN;

    END IF;

  ELSE

    CLOSE c_enr_cal_conf;
    RETURN;

  END IF;

  IF p_mode = 'CLEANUP' THEN
    -- If cleanup date alias is not set then OR
    -- if cleanup date alias is set and is greater than or equal to sysdate then return
    OPEN c_cln_up_dt_alias_val(l_term_cal_type,l_term_sequence_number,v_cleanup_dt_alias);
    FETCH c_cln_up_dt_alias_val INTO v_cleanup_dt_alias_val;

    IF c_cln_up_dt_alias_val%NOTFOUND  OR
       (c_cln_up_dt_alias_val%FOUND AND (v_cleanup_dt_alias_val >= SYSDATE)) THEN

        FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_CLNUP_DAV_GE_SYSDATE');
        FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET);

        CLOSE c_cln_up_dt_alias_val;
        RETURN;

    ELSE

       CLOSE c_cln_up_dt_alias_val;

    END IF;

  END IF;


   -- Get the load calendar end date
   IF   p_mode = 'PROCESS' THEN

    OPEN c_load_cal_end_dt(l_term_cal_type,l_term_sequence_number);
    FETCH c_load_cal_end_dt INTO l_end_dt;
    CLOSE c_load_cal_end_dt;

    -- If begin program transfer date alias is found and
    -- ( sysdate is not between  begin program date alias and loadcalendar end date ) return
    -- or if it is not found then exit
    OPEN c_begin_pt_dt_alias_val(l_term_cal_type,l_term_sequence_number,v_begin_pt_dt_alias);
    FETCH c_begin_pt_dt_alias_val INTO v_begin_pt_dt_alias_val;

    IF c_begin_pt_dt_alias_val%NOTFOUND OR
       (c_begin_pt_dt_alias_val%FOUND AND (SYSDATE NOT BETWEEN v_begin_pt_dt_alias_val AND l_end_dt) ) THEN

        FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_BEG_PT_DAV_LT_SYSDATE');
        FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET);

        CLOSE c_begin_pt_dt_alias_val;
        RETURN;

    END IF;

    CLOSE c_begin_pt_dt_alias_val;

  END IF;

  FOR v_clnup_rec IN  c_spa_clnup(l_term_cal_type,l_term_sequence_number) LOOP

        BEGIN
            l_rec_exists := TRUE;

            OPEN c_person_num(v_clnup_rec.person_id);
            FETCH c_person_num INTO v_person_num;
            CLOSE c_person_num;

            FND_FILE.PUT_LINE (FND_FILE.LOG, '-----------------------------------------------------------------------------');
            FND_FILE.PUT_LINE (FND_FILE.LOG, 'Person :'||v_person_num||'    Source Course :'||v_clnup_rec.transfer_course_cd||'    Destination Course :'||v_clnup_rec.course_cd);
            FND_FILE.PUT_LINE (FND_FILE.LOG, '-----------------------------------------------------------------------------');
            FND_FILE.PUT_LINE (FND_FILE.LOG, ' ');

            IF p_mode IN ('CLEANUP','DELETE') THEN

              BEGIN
               -- Call the cleanup destination program with p_mode as cleanup/delete
                IGS_EN_FUTURE_DT_TRANS.cleanup_dest_program(
                                                            p_person_id =>  v_clnup_rec.person_id,
                                                            p_dest_course_cd  =>  v_clnup_rec.course_cd,
                                                            p_term_cal_type =>  l_term_cal_type,
                                                            p_term_sequence_number  =>  l_term_sequence_number,
                                                            p_mode  =>  p_mode
                                                            );

                OPEN c_sct(l_term_cal_type,
                           l_term_sequence_number,
                           v_clnup_rec.person_id,
                           v_clnup_rec.course_cd);
                FETCH c_sct INTO v_rec_exists;

                IF p_mode = 'DELETE' THEN

                    -- If no transfer record is found then log the delete successful message
                    IF c_sct%NOTFOUND THEN

                      FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_DEL_DEST_PROG');
                      FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET);

                    ELSE
                      -- If destination program attempt  record is found log the cant delete message
                      FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_CANT_DEL_DEST_PROG');
                      FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET);

                    END IF;

                END IF;
                CLOSE c_sct;


                OPEN c_sca (v_clnup_rec.person_id,v_clnup_rec.course_cd);
                FETCH c_sca INTO v_sca_dest_rec;
                -- If the mode is cleanup and future dated transfer flag of
                -- of destination program attempt is set to 'N'
                -- then log success message
                IF p_mode = 'CLEANUP' AND c_sca%FOUND
                AND v_sca_dest_rec.future_dated_trans_flag = 'C' THEN

                  FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_UNCONF_DEST_PROG');
                  FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET);

                END IF;

                CLOSE c_sca;


             EXCEPTION
             WHEN OTHERS THEN

               FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET);

               IF p_mode = 'CLEANUP' THEN

                 FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_CANT_UNCONF_DEST_PROG');
                 FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET);

               END IF;


             END;

            -- Process Mode
            ELSE

                OPEN c_sca (v_clnup_rec.person_id,v_clnup_rec.transfer_course_cd);
                FETCH c_sca INTO v_sca_dest_rec;
                CLOSE c_sca;

                --- If destination program attempt is intermitted/lapsed/discontinued/unconfirme
                --- then dont allow the transfer
                IF v_sca_dest_rec.course_attempt_status = 'INTERMITTED' THEN

                  FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_TRN_DEST_INTM');
                  FND_MESSAGE.SET_TOKEN('SOURCE_PROGRAM', v_clnup_rec.transfer_course_cd);
                  FND_MESSAGE.SET_TOKEN('DEST_PROGRAM', v_clnup_rec.course_cd);
                  FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET);

                ELSIF v_sca_dest_rec.course_attempt_status = 'LAPSED'  THEN

                  FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_TRN_DEST_LAPSE');
                  FND_MESSAGE.SET_TOKEN('SOURCE_PROGRAM', v_clnup_rec.transfer_course_cd);
                  FND_MESSAGE.SET_TOKEN('DEST_PROGRAM', v_clnup_rec.course_cd);
                  FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET);

                ELSIF v_sca_dest_rec.course_attempt_status = 'DISCONTIN' THEN

                    FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_TRN_DEST_DISCON');
                    FND_MESSAGE.SET_TOKEN('SOURCE_PROGRAM', v_clnup_rec.transfer_course_cd);
                    FND_MESSAGE.SET_TOKEN('DEST_PROGRAM', v_clnup_rec.course_cd);
                    FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET);

                ELSIF v_sca_dest_rec.course_attempt_status = 'UNCONFIRM' THEN

                    FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_TRN_DEST_UNCONF');
                    FND_MESSAGE.SET_TOKEN('SOURCE_PROGRAM', v_clnup_rec.transfer_course_cd);
                    FND_MESSAGE.SET_TOKEN('DEST_PROGRAM', v_clnup_rec.course_cd);
                    FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET);


                ELSE

                  OPEN c_sca (v_clnup_rec.person_id,v_clnup_rec.transfer_course_cd);
                  FETCH c_sca INTO v_sca_src_rec;
                  CLOSE c_sca;

                  IF is_career_model_enabled THEN

                    l_tran_across_careers := is_tranfer_across_careers(
                                                                        v_sca_src_rec.course_cd,
                                                                        v_sca_src_rec.version_number,
                                                                        v_sca_dest_rec.COURSE_CD,
                                                                        v_sca_dest_rec.version_number,
                                                                        l_src_career_type
                                                                        );
                     -- if the transfer is across careers and destination program is secoondary
                     -- then dont allow the transfer
                    IF  l_tran_across_careers AND v_sca_dest_rec.primary_program_type = 'SECONDARY' THEN

                          FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_TRN_SEC_DEST_INTER_CAR');
                          FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET);
                          App_Exception.Raise_Exception;

                    END IF;
                    -- If the transfer  is within careers
                    IF NOT l_tran_across_careers THEN

                      -- Check If destination program is primary in the previous term
                      -- if so dont transfer
                      OPEN  c_prim_in_prev_terms(v_clnup_rec.person_id,
                                                 v_clnup_rec.course_cd,
                                                 l_term_cal_type,
                                                 l_term_sequence_number,
                                                 v_sca_dest_rec.cal_type,
                                                 v_clnup_rec.transfer_dt
                                                 );
                      FETCH c_prim_in_prev_terms INTO is_prim_in_prev_term;

                      IF (c_prim_in_prev_terms%FOUND) THEN

                        CLOSE c_prim_in_prev_terms;

                        FND_MESSAGE.SET_NAME('IGS', 'IGS_EN_PRIMARY_IN_PRIOR_TERM');
                        FND_MESSAGE.SET_TOKEN('DEST_PROGRAM', v_clnup_rec.course_cd);
                        FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET);
                        EXIT;

                      END IF;
                      CLOSE c_prim_in_prev_terms;

                    END IF; -- if condition to check whether the transfer is within careers

                  END IF; -- if condition to check if career model is enabled


                  -- Get academic calendar details
                  IGS_EN_GEN_015.get_academic_cal(
                                                  p_person_id => v_sca_src_rec.person_id,
                                                  p_course_cd => v_sca_src_rec.course_cd,
                                                  p_effective_dt => SYSDATE,
                                                  p_acad_cal_type => l_acad_cal_type, -- OUT parameter
                                                  p_acad_ci_sequence_number => l_acad_cal_seq_num, -- OUT parameter
                                                  p_message => l_message_name
                                                  );
                  IF l_message_name IS NOT NULL -- AND l_acad_cal_seq_num IS NULL
                  THEN

                    FND_FILE.PUT_LINE(FND_FILE.LOG,l_message_name);

                  ELSE
                     -- Call the transfer api to carry out the transfer
                     -- set the research details flag to 'N' as it has already been transferred
                     -- when the future dated transfer is created
                     IGS_EN_TRANSFER_APIS.program_transfer_api(
                                        p_person_id               =>   v_clnup_rec.person_id,
                                        p_source_program_cd       =>   v_sca_src_rec.course_cd,
                                        p_source_prog_ver         =>   v_sca_src_rec.version_number,
                                        p_term_cal_type           =>   l_term_cal_type,
                                        p_term_seq_num            =>   l_term_sequence_number,
                                        p_acad_cal_type           =>   l_acad_cal_type,
                                        p_acad_seq_num            =>   l_acad_cal_seq_num,
                                        p_trans_approval_dt       =>   v_clnup_rec.APPROVED_DATE,
                                        p_trans_actual_dt        =>   v_clnup_rec.transfer_dt,
                                        -- Transfer date should be passed. This parameter is used while unit transfer records are created.
                                        p_dest_program_cd         =>   v_clnup_rec.course_cd,
                                        p_dest_prog_ver           =>   v_sca_dest_rec.version_number,
                                        p_dest_coo_id             =>   v_sca_dest_rec.coo_id,
                                        p_uoo_ids_to_transfer     =>   v_clnup_rec.UOOIDS_TO_TRANSFER,
                                        p_uoo_ids_not_selected    =>   NULL,
                                        p_uoo_ids_having_errors   =>   l_uoo_ids_having_errors,
                                        p_unit_sets_to_transfer   =>   v_clnup_rec.SUSA_TO_TRANSFER,
                                        p_unit_sets_not_selected  =>   NULL,
                                        p_unit_sets_having_errors =>   l_uoo_ids_having_errors,
                                        p_transfer_av             =>   v_clnup_rec.TRANSFER_ADV_STAND_FLAG,
                                        p_transfer_re             =>   'N',
                                        p_discontinue_source      =>   v_clnup_rec.DISCONTINUE_SOURCE_FLAG,
                                        p_show_warning            =>   l_show_warning,
                                        p_call_from               =>   'PROCESS',
                                        p_process_mode            =>   l_process_mode,
                                        p_return_status           =>   l_return_status,
                                        p_msg_data                =>   l_msg_data,
                                        p_msg_count               =>   l_msg_count
                                        );


                    log_err_messages(l_msg_count, l_msg_data);

                    IF l_return_status = 'U' THEN

                       retcode := 2;

                    ELSIF l_return_status = 'E'  THEN

                       FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_FUT_DT_TRANSF_FAIL');
                       FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET);

                    ELSIF l_return_status = 'S' AND l_show_warning = 'Y' AND l_msg_count > 0 THEN

                       FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_FUT_DT_TRANSF_WARN');
                       FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET);

                    ELSE

                       FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_FUT_DT_TRANSF');
                       FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET);

                    END IF;

                  END IF; -- if condition for academic calendar details

                END IF; -- If the dest prog is not intermitted/disc/lapsed

        END IF; -- If condition for cleanup/delete process modes

        EXCEPTION
          WHEN OTHERS THEN

            IF p_mode = 'PROCESS' THEN

              l_msg := FND_MESSAGE.GET;

              IF l_msg IS NULL THEN
                 l_msg := sqlerrm;
              END IF;

              FND_FILE.PUT_LINE (FND_FILE.LOG, l_msg);
              FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_FUT_DT_TRANSF_FAIL');
              FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET);

            END IF;

          END;

    END LOOP;

     --- No Data is found
    IF NOT l_rec_exists THEN

      FND_MESSAGE.SET_NAME ('IGS', 'IGS_GE_NO_DATA_FOUND');
      FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET);

    END IF;

EXCEPTION

  WHEN OTHERS THEN
    retcode:=2;
    ERRBUF := FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');

END process_fut_dt_trans;

/*----------------------------------------------------------------------------
  ||  Created By : ctyagi
  ||  Created On : 30-AUG-2005
  ||  Purpose : Deleting unconfirm  unit as  impact of Re-Open
  ||            Admission Appication
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||
  ------------------------------------------------------------------------------*/

FUNCTION del_sua_for_reopen(
  p_person_id  IN   IGS_EN_STDNT_PS_ATT.person_id%TYPE,
  p_course_cd   IN  IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
  p_uoo_id      IN  IGS_EN_SU_ATTEMPT.uoo_id%TYPE
 )
RETURN BOOLEAN
AS
  CURSOR c_sua_del (
    cp_person_id  IGS_EN_STDNT_PS_ATT.person_id%TYPE,
    cp_course_cd  IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
    cp_uoo_id     IGS_EN_SU_ATTEMPT.uoo_id%TYPE
    ) IS
    SELECT rowid
    FROM  IGS_EN_SU_ATTEMPT   sua
    WHERE sua.person_id     = cp_person_id
    AND   sua.course_cd     = cp_course_cd
    AND   sua.uoo_id    = cp_uoo_id
    FOR UPDATE OF sua.LAST_UPDATE_DATE NOWAIT;

  v_sua_del_exists  c_sua_del%ROWTYPE;

BEGIN



    FOR v_sua_del_exists IN c_sua_del(p_person_id,p_course_cd,p_uoo_id) LOOP



        del_suar(p_person_id, p_course_cd, p_uoo_id);

        del_as_msht_su_atmpt( p_person_id,p_course_cd,p_uoo_id);

        del_as_stmptout( p_person_id,p_course_cd,p_uoo_id);

        del_ps_stdnt_unt_trn( p_person_id,p_course_cd,p_uoo_id);

        del_as_anon_id_us( p_person_id,p_course_cd,p_uoo_id);

        del_as_sua_ses_atts( p_person_id,p_course_cd,p_uoo_id);


        IGS_EN_SU_ATTEMPT_PKG.DELETE_ROW( X_ROWID => v_sua_del_exists.rowid );



    END LOOP;
    RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
      IF c_sua_del%ISOPEN THEN
         CLOSE c_sua_del;
      END IF;
      RETURN FALSE;

END del_sua_for_reopen;



END IGS_EN_FUTURE_DT_TRANS;

/
