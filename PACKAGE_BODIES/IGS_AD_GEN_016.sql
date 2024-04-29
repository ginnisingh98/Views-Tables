--------------------------------------------------------
--  DDL for Package Body IGS_AD_GEN_016
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_GEN_016" AS
/* $Header: IGSAD99B.pls 120.1 2005/09/30 04:45:35 appldev ship $ */
/* ------------------------------------------------------------------------------------------------------------------------
||Created By : knag
||Date Created By : 05-NOV-2003
||Purpose:
||Known limitations,enhancements,remarks:
||Change History
||Who        When          What
  rbezawad   30-Oct-2004   Added check_security_exception procedure to verity if there is any Security Policy error
                           IGS_SC_POLICY_EXCEPTION or IGS_SC_POLICY_UPD_DEL_EXCEP is set in message stack w.r.t. bug fix 3919112.
||-----------------------------------------------------------------------------------------------------------------------*/

  l_language VARCHAR2(2000);
  l_security_group_id NUMBER := 0;

  -- Lookups
  FUNCTION get_lookup (p_lookup_type     IN VARCHAR2,
                       p_lookup_code     IN VARCHAR2,
                       p_application_id  IN NUMBER,
                       p_enabled_flag    IN VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2 -- Returns TRUE/FALSE
  IS
    lv_ret_success      VARCHAR2(5);
    ln_hash_lkcode_idx  NUMBER;
    ln_hash_lktype_idx  NUMBER;
    lb_is_lktype_cached BOOLEAN;

    CURSOR c_lookup (lv_lookup_type VARCHAR2, ln_appl_id NUMBER)
    IS
    SELECT lookup_code, enabled_flag, meaning
    FROM   fnd_lookup_values
    WHERE  lookup_type = lv_lookup_type
    AND    view_application_id = ln_appl_id
    AND    language = l_language
    AND    security_group_id = l_security_group_id;

    lr_fetched_lkcode   c_lookup%ROWTYPE;

  BEGIN
    IF l_language IS NULL THEN
      SELECT USERENV('LANG') INTO l_language FROM DUAL;
    END IF;

    -- If parameters are not valid return
    IF (p_lookup_code IS NULL OR p_lookup_type IS NULL OR p_application_id IS NULL) THEN
      RETURN ('FALSE');

    ELSE
      lv_ret_success := 'FALSE';
      -- Get the hash value of the Type + Code + View Appl ID
      ln_hash_lkcode_idx := DBMS_UTILITY.get_hash_value (
                                         p_lookup_type||'@*?'||p_lookup_code||'@*?'||igs_ge_number.to_cann(p_application_id)
                                         ||'@*?'||l_language||'@*?'||igs_ge_number.to_cann(l_security_group_id),
                                         1000,
                                         25000);

      IF g_hash_lookup_code_tab.EXISTS(ln_hash_lkcode_idx) THEN
        lv_ret_success := 'TRUE';
        IF p_enabled_flag IS NOT NULL AND
           p_enabled_flag <> g_hash_lookup_code_tab(ln_hash_lkcode_idx).enabled_flag THEN
          lv_ret_success := 'FALSE';
        END IF;
        RETURN (lv_ret_success);

      ELSE
        -- Check if the Type is already cached
        -- Get the hash value of the Type + View Appl ID
        ln_hash_lktype_idx := DBMS_UTILITY.get_hash_value (
                                           p_lookup_type||'@*?'||igs_ge_number.to_cann(p_application_id)
                                           ||'@*?'||igs_ge_number.to_cann(l_security_group_id),
                                           1000,
                                           25000);

        IF g_hash_lookup_type_tab.EXISTS(ln_hash_lktype_idx) THEN
          -- Since all lookup codes are already hashed,
          -- so the parameter one is invalid
          RETURN ('FALSE');

        ELSE
          -- Type is not cached so cache it.
          lb_is_lktype_cached := FALSE;

          lv_ret_success := 'FALSE';
          OPEN c_lookup (p_lookup_type, p_application_id);
          LOOP
            FETCH c_lookup into lr_fetched_lkcode;
            EXIT WHEN c_lookup%NOTFOUND;

            -- Cache the Lookup Type only once
            IF NOT lb_is_lktype_cached THEN
              lb_is_lktype_cached := TRUE;
              g_hash_lookup_type_tab(ln_hash_lktype_idx) := p_lookup_type;
            END IF;

            ln_hash_lkcode_idx := DBMS_UTILITY.get_hash_value (
                                               p_lookup_type||'@*?'||lr_fetched_lkcode.lookup_code||'@*?'||igs_ge_number.to_cann(p_application_id)
                                               ||'@*?'||l_language||'@*?'||igs_ge_number.to_cann(l_security_group_id),
                                               1000,
                                               25000);

            g_hash_lookup_code_tab(ln_hash_lkcode_idx).lookup_code := lr_fetched_lkcode.lookup_code;
            g_hash_lookup_code_tab(ln_hash_lkcode_idx).enabled_flag := lr_fetched_lkcode.enabled_flag;
            g_hash_lookup_code_tab(ln_hash_lkcode_idx).meaning := lr_fetched_lkcode.meaning;


            IF p_lookup_code = lr_fetched_lkcode.lookup_code THEN
              lv_ret_success := 'TRUE';
              IF p_enabled_flag IS NOT NULL AND
                 p_enabled_flag <> lr_fetched_lkcode.enabled_flag THEN
                lv_ret_success := 'FALSE';
              END IF;
            END IF;

          END LOOP;
          CLOSE c_lookup;

          RETURN (lv_ret_success);

        END IF;
      END IF;
    END IF;
  END get_lookup;

  FUNCTION get_lkup_meaning (p_lookup_type     IN VARCHAR2,
                             p_lookup_code     IN VARCHAR2,
                             p_application_id  IN NUMBER)
  RETURN VARCHAR2 -- Returns meaning
  IS
    lv_ret_success      VARCHAR2(5);
    ln_hash_lkcode_idx  NUMBER;
    ln_hash_lktype_idx  NUMBER;
    lb_is_lktype_cached BOOLEAN;

    CURSOR c_lookup (lv_lookup_type VARCHAR2, ln_appl_id NUMBER)
    IS
    SELECT lookup_code, enabled_flag, meaning
    FROM   fnd_lookup_values
    WHERE  lookup_type = lv_lookup_type
    AND    view_application_id = ln_appl_id
    AND    language = l_language
    AND    security_group_id = l_security_group_id;

    lr_fetched_lkcode   c_lookup%ROWTYPE;

  BEGIN
    IF l_language IS NULL THEN
      SELECT USERENV('LANG') INTO l_language FROM DUAL;
    END IF;

    -- If parameters are not valid return
    IF (p_lookup_code IS NULL OR p_lookup_type IS NULL OR p_application_id IS NULL) THEN
      RETURN ('FALSE');

    ELSE
      IF get_lookup (p_lookup_type    => p_lookup_type,
                     p_lookup_code    => p_lookup_code,
                     p_application_id => p_application_id) = 'TRUE' THEN

        -- Get the hash value of the Type + Code + View Appl ID
        ln_hash_lkcode_idx := DBMS_UTILITY.get_hash_value (
                                           p_lookup_type||'@*?'||p_lookup_code||'@*?'||igs_ge_number.to_cann(p_application_id)
                                           ||'@*?'||l_language||'@*?'||igs_ge_number.to_cann(l_security_group_id),
                                           1000,
                                           25000);

        RETURN (g_hash_lookup_code_tab(ln_hash_lkcode_idx).meaning);
      END IF;
      RETURN (NULL);
    END IF;
  END get_lkup_meaning;

  -- Messages
  FUNCTION is_err_msg (p_message_name            IN VARCHAR2,
                       p_application_short_name  IN VARCHAR2)
  RETURN VARCHAR2 -- Returns TRUE/FALSE
  IS
    lv_ret_success        VARCHAR2(5);
    ln_hash_msg_type_idx  NUMBER;

    CURSOR c_appl_id (lv_appl_short_name VARCHAR2)
    IS
    SELECT application_id
    FROM   fnd_application
    WHERE  application_short_name = lv_appl_short_name;

    ln_application_id fnd_application.application_id%TYPE;

    CURSOR c_msg_type (lv_message_name VARCHAR2, ln_appl_id NUMBER)
    IS
    SELECT NVL(type,'ERROR') type
    FROM   fnd_new_messages
    WHERE  message_name = lv_message_name
    AND    application_id = ln_appl_id
    AND    language_code = l_language;

    lr_fetched_msg_type c_msg_type%ROWTYPE;

  BEGIN
    IF l_language IS NULL THEN
      SELECT USERENV('LANG') INTO l_language FROM DUAL;
    END IF;

    OPEN c_appl_id (p_application_short_name);
    FETCH c_appl_id INTO ln_application_id;
    CLOSE c_appl_id;

    -- If parameters are not valid return
    IF (p_message_name IS NULL OR ln_application_id IS NULL) THEN
      RETURN ('FALSE');

    ELSE
      lv_ret_success := 'FALSE';
      -- Get the hash value of the Type + Code + View Appl ID
      ln_hash_msg_type_idx := DBMS_UTILITY.get_hash_value (
                                           p_message_name||'@*?'||igs_ge_number.to_cann(ln_application_id)||'@*?'||l_language,
                                           1000,
                                           25000);

      IF g_hash_msg_type_tab.EXISTS(ln_hash_msg_type_idx) THEN
        lv_ret_success := 'TRUE';
        IF NVL(g_hash_msg_type_tab(ln_hash_msg_type_idx),'@*?') <> 'ERROR' THEN
          lv_ret_success := 'FALSE';
        END IF;
        RETURN (lv_ret_success);

      ELSE
        lv_ret_success := 'FALSE';
        OPEN c_msg_type (p_message_name, ln_application_id);
        LOOP
          FETCH c_msg_type into lr_fetched_msg_type;
          EXIT WHEN c_msg_type%NOTFOUND;

          ln_hash_msg_type_idx := DBMS_UTILITY.get_hash_value (
                                               p_message_name||'@*?'||igs_ge_number.to_cann(ln_application_id)||'@*?'||l_language,
                                               1000,
                                               25000);

          g_hash_msg_type_tab(ln_hash_msg_type_idx) := lr_fetched_msg_type.type;

          lv_ret_success := 'TRUE';
          IF NVL(lr_fetched_msg_type.type,'@*?') <> 'ERROR' THEN
            lv_ret_success := 'FALSE';
          END IF;
        END LOOP;
        CLOSE c_msg_type;

        RETURN (lv_ret_success);
      END IF;
    END IF;
  END is_err_msg;

  -- Import process source categories
  FUNCTION  chk_src_cat (p_source_type_id IN NUMBER,
                         p_category       IN VARCHAR2)
  RETURN BOOLEAN
  IS
    lv_ret_success          VARCHAR2(5);
    lv_include_ind          igs_ad_source_cat_all.include_ind%TYPE;
    lv_detail_level_ind     igs_ad_source_cat_all.detail_level_ind%TYPE;
    lv_discrepancy_rule_cd  igs_ad_source_cat_all.discrepancy_rule_cd%TYPE;
  BEGIN
    lv_include_ind := 'Y';
    lv_ret_success := get_srccat (p_source_type_id      => p_source_type_id,
                                  p_category_name       => p_category,
                                  p_include_ind         => lv_include_ind,
                                  p_detail_level_ind    => lv_detail_level_ind,
                                  p_discrepancy_rule_cd => lv_discrepancy_rule_cd);

    IF lv_ret_success = 'TRUE' THEN
      RETURN (TRUE);
    ELSE
      RETURN (FALSE);
    END IF;
  END chk_src_cat;

  FUNCTION find_source_cat_rule (p_source_type_id IN NUMBER,
                                 p_category       IN VARCHAR2)
  RETURN VARCHAR2
  IS
    lv_ret_success          VARCHAR2(5);
    lv_include_ind          igs_ad_source_cat_all.include_ind%TYPE;
    lv_detail_level_ind     igs_ad_source_cat_all.detail_level_ind%TYPE;
    lv_discrepancy_rule_cd  igs_ad_source_cat_all.discrepancy_rule_cd%TYPE;
  BEGIN
    lv_ret_success := get_srccat (p_source_type_id      => p_source_type_id,
                                  p_category_name       => p_category,
                                  p_include_ind         => lv_include_ind,
                                  p_detail_level_ind    => lv_detail_level_ind,
                                  p_discrepancy_rule_cd => lv_discrepancy_rule_cd);

    RETURN (lv_discrepancy_rule_cd);
  END find_source_cat_rule;

  FUNCTION get_srccat (p_source_type_id       IN NUMBER,
                       p_category_name        IN VARCHAR2,
                       p_include_ind          IN VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2 -- Returns TRUE/FALSE
  IS
    lv_detail_level_ind     igs_ad_source_cat_all.detail_level_ind%TYPE;
    lv_discrepancy_rule_cd  igs_ad_source_cat_all.discrepancy_rule_cd%TYPE;
  BEGIN
    RETURN (get_srccat (p_source_type_id      => p_source_type_id,
                        p_category_name       => p_category_name,
                        p_include_ind         => p_include_ind,
                        p_detail_level_ind    => lv_detail_level_ind,
                        p_discrepancy_rule_cd => lv_discrepancy_rule_cd));
  END get_srccat;

  FUNCTION get_srccat (p_source_type_id       IN NUMBER,
                       p_category_name        IN VARCHAR2,
                       p_include_ind          IN VARCHAR2 DEFAULT NULL,
                       p_detail_level_ind     IN OUT NOCOPY VARCHAR2,
                       p_discrepancy_rule_cd  OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2 -- Returns TRUE/FALSE
  IS
    lv_ret_success       VARCHAR2(5);
    ln_hash_srccat_idx   NUMBER;
    ln_hash_stypeid_idx  NUMBER;
    lb_is_stypeid_cached BOOLEAN;

    CURSOR c_srccat (ln_source_type_id NUMBER)
    IS
    SELECT category_name, include_ind, detail_level_ind, discrepancy_rule_cd
    FROM   igs_ad_source_cat_all
    WHERE  source_type_id = ln_source_type_id;

    lr_fetched_srccat   c_srccat%ROWTYPE;

  BEGIN
    -- If parameters are not valid return
    IF (p_source_type_id IS NULL OR p_category_name IS NULL) THEN
      RETURN ('FALSE');

    ELSE
      lv_ret_success := 'FALSE';
      -- Get the hash value of the Source Type ID + Category
      ln_hash_srccat_idx := DBMS_UTILITY.get_hash_value (
                                         igs_ge_number.to_cann(p_source_type_id)||'@*?'||p_category_name,
                                         1000,
                                         25000);

      IF g_hash_srccat_tab.EXISTS(ln_hash_srccat_idx) THEN
        lv_ret_success := 'TRUE';
        IF p_include_ind IS NOT NULL AND
           p_include_ind <> g_hash_srccat_tab(ln_hash_srccat_idx).include_ind THEN
          lv_ret_success := 'FALSE';
        END IF;

        IF p_detail_level_ind IS NOT NULL AND
           p_detail_level_ind <> NVL(g_hash_srccat_tab(ln_hash_srccat_idx).detail_level_ind,'@*?') THEN
          lv_ret_success := 'FALSE';
        END IF;

        IF lv_ret_success = 'TRUE' THEN
          IF p_detail_level_ind IS NULL THEN
            p_detail_level_ind := g_hash_srccat_tab(ln_hash_srccat_idx).detail_level_ind;
          END IF;

          IF p_detail_level_ind = 'Y' THEN
            -- Get discrepancy rule from attribute level discrepancy rule
            p_discrepancy_rule_cd := 'D';
          ELSE
            -- Get discrepancy rule for the entity (category)
            p_discrepancy_rule_cd := g_hash_srccat_tab(ln_hash_srccat_idx).discrepancy_rule_cd;
          END IF;
        END IF;
        RETURN (lv_ret_success);

      ELSE
        -- Check if the Source Type ID is already cached
        -- Get the hash value of the Source Type ID
        ln_hash_stypeid_idx := DBMS_UTILITY.get_hash_value (
                                           igs_ge_number.to_cann(p_source_type_id),
                                           1000,
                                           25000);

        IF g_hash_stypeid_tab.EXISTS(ln_hash_stypeid_idx) THEN
          -- Since all categories are already hashed,
          -- so the parameter one is invalid
          RETURN ('FALSE');

        ELSE
          -- Source Type ID is not cached so cache it.
          lb_is_stypeid_cached := FALSE;

          lv_ret_success := 'FALSE';
          OPEN c_srccat (p_source_type_id);
          LOOP
            FETCH c_srccat into lr_fetched_srccat;
            EXIT WHEN c_srccat%NOTFOUND;

            -- Cache the Source Type ID only once
            IF NOT lb_is_stypeid_cached THEN
              lb_is_stypeid_cached := TRUE;
              g_hash_stypeid_tab(ln_hash_stypeid_idx) := p_source_type_id;
            END IF;

            ln_hash_srccat_idx := DBMS_UTILITY.get_hash_value (
                                               igs_ge_number.to_cann(p_source_type_id)||'@*?'||lr_fetched_srccat.category_name,
                                               1000,
                                               25000);

            g_hash_srccat_tab(ln_hash_srccat_idx).category_name := lr_fetched_srccat.category_name;
            g_hash_srccat_tab(ln_hash_srccat_idx).include_ind := lr_fetched_srccat.include_ind;
            g_hash_srccat_tab(ln_hash_srccat_idx).detail_level_ind := lr_fetched_srccat.detail_level_ind;
            g_hash_srccat_tab(ln_hash_srccat_idx).discrepancy_rule_cd := lr_fetched_srccat.discrepancy_rule_cd;

            IF p_category_name = g_hash_srccat_tab(ln_hash_srccat_idx).category_name THEN
              lv_ret_success := 'TRUE';

              IF p_include_ind IS NOT NULL AND
                 p_include_ind <> g_hash_srccat_tab(ln_hash_srccat_idx).include_ind THEN
                lv_ret_success := 'FALSE';
              END IF;

              IF p_detail_level_ind IS NOT NULL AND
                 p_detail_level_ind <> NVL(g_hash_srccat_tab(ln_hash_srccat_idx).detail_level_ind,'@*?') THEN
                lv_ret_success := 'FALSE';
              END IF;

              IF lv_ret_success = 'TRUE' THEN
                IF p_detail_level_ind IS NULL THEN
                  p_detail_level_ind := g_hash_srccat_tab(ln_hash_srccat_idx).detail_level_ind;
                END IF;

                IF p_detail_level_ind = 'Y' THEN
                  -- Get discrepancy rule from attribute level discrepancy rule
                  p_discrepancy_rule_cd := 'D';
                ELSE
                  -- Get discrepancy rule for the entity (category)
                  p_discrepancy_rule_cd := g_hash_srccat_tab(ln_hash_srccat_idx).discrepancy_rule_cd;
                END IF;
              END IF;
            END IF;

          END LOOP;
          CLOSE c_srccat;

          RETURN (lv_ret_success);
        END IF;
      END IF;
    END IF;
  END get_srccat;

  -- Code Classes
  FUNCTION get_codeclass (p_class           IN VARCHAR2,
                          p_code_id         IN NUMBER)
  RETURN VARCHAR2 -- Returns TRUE/FALSE
  IS
    ln_code_id       igs_ad_code_classes.code_id%TYPE;
    lv_name          igs_ad_code_classes.name%TYPE;
    lv_system_status igs_ad_code_classes.system_status%TYPE;
    lv_closed_ind    igs_ad_code_classes.closed_ind%TYPE;
  BEGIN
    ln_code_id := p_code_id;
    lv_closed_ind := 'N';
    RETURN (get_codeclass (p_class         => p_class,
                           p_code_id       => ln_code_id,
                           p_name          => lv_name,
                           p_system_status => lv_system_status,
                           p_closed_ind    => lv_closed_ind));
  END get_codeclass;

  FUNCTION get_codeclass (p_class           IN VARCHAR2,
                          p_name            IN VARCHAR2)
  RETURN VARCHAR2 -- Returns TRUE/FALSE
  IS
    ln_code_id       igs_ad_code_classes.code_id%TYPE;
    lv_name          igs_ad_code_classes.name%TYPE;
    lv_system_status igs_ad_code_classes.system_status%TYPE;
    lv_closed_ind    igs_ad_code_classes.closed_ind%TYPE;
  BEGIN
    lv_name := p_name;
    lv_closed_ind := 'N';
    RETURN (get_codeclass (p_class         => p_class,
                           p_code_id       => ln_code_id,
                           p_name          => lv_name,
                           p_system_status => lv_system_status,
                           p_closed_ind    => lv_closed_ind));
  END get_codeclass;

  FUNCTION get_codeclass (p_class           IN VARCHAR2,
                          p_code_id         IN OUT NOCOPY NUMBER,
                          p_name            IN OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2 -- Returns TRUE/FALSE
  IS
    lv_system_status igs_ad_code_classes.system_status%TYPE;
    lv_closed_ind    igs_ad_code_classes.closed_ind%TYPE;
  BEGIN
    lv_closed_ind := 'N';
    RETURN (get_codeclass (p_class         => p_class,
                           p_code_id       => p_code_id,
                           p_name          => p_name,
                           p_system_status => lv_system_status,
                           p_closed_ind    => lv_closed_ind));
  END get_codeclass;

  FUNCTION get_def_code (p_class           IN VARCHAR2,
                         p_code_id         OUT NOCOPY NUMBER,
                         p_name            OUT NOCOPY VARCHAR2,
                         p_system_status   IN VARCHAR2)
  RETURN VARCHAR2 -- Returns TRUE/FALSE
  IS
    lv_ret_success                 VARCHAR2(5);
    ln_code_id                     igs_ad_code_classes.code_id%TYPE;
    lv_name                        igs_ad_code_classes.name%TYPE;
    lv_system_status               igs_ad_code_classes.system_status%TYPE;
    lv_closed_ind                  igs_ad_code_classes.closed_ind%TYPE;
    ln_hash_dflt_cc_id_hashidx_idx NUMBER;
    ln_hash_ccode_idx              NUMBER;
  BEGIN
    -- If parameters are not valid return
    IF (p_class IS NULL OR p_system_status IS NULL) THEN
      RETURN ('FALSE');

    ELSE
      ln_hash_dflt_cc_id_hashidx_idx := DBMS_UTILITY.get_hash_value (
                                                     p_class||'@*?'||p_system_status||'@*?'||'Y',
                                                     1000,
                                                     25000);

      IF g_hash_dflt_cc_id_hashidx_tab.EXISTS(ln_hash_dflt_cc_id_hashidx_idx) THEN
        ln_hash_ccode_idx := g_hash_dflt_cc_id_hashidx_tab(ln_hash_dflt_cc_id_hashidx_idx);
        ln_code_id := g_hash_ccode_tab(ln_hash_ccode_idx).code_id;
        lv_name := g_hash_ccode_tab(ln_hash_ccode_idx).name;
        lv_ret_success := 'TRUE';
      END IF;

      IF ln_code_id IS NULL THEN
        lv_system_status := p_system_status;
        lv_closed_ind := 'N';
        lv_ret_success  := get_codeclass (p_class         => p_class,
                                          p_code_id       => ln_code_id,
                                          p_name          => lv_name,
                                          p_system_status => lv_system_status,
                                          p_closed_ind    => lv_closed_ind);
      END IF;
      p_code_id := ln_code_id;
      p_name    := lv_name;
      RETURN (lv_ret_success);
    END IF;
  END get_def_code;

  FUNCTION get_codeclass (p_class           IN VARCHAR2,
                          p_code_id         IN OUT NOCOPY NUMBER,
                          p_name            IN OUT NOCOPY VARCHAR2,
                          p_system_status   IN OUT NOCOPY VARCHAR2,
                          p_closed_ind      IN VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2 -- Returns TRUE/FALSE
  IS
    lv_ret_success                 VARCHAR2(5);
    ln_hash_name_cc_id_hashidx_idx NUMBER;
    ln_hash_dflt_cc_id_hashidx_idx NUMBER;
    ln_hash_ccode_idx              NUMBER;
    ln_hash_cclass_idx             NUMBER;
    lb_is_cclass_cached            BOOLEAN;

    CURSOR c_ccode (lv_class VARCHAR2)
    IS
    SELECT code_id, name, system_status, closed_ind, system_default
    FROM   igs_ad_code_classes
    WHERE  class = lv_class
    AND CLASS_TYPE_CODE='ADM_CODE_CLASSES';

    lr_fetched_ccode   c_ccode%ROWTYPE;

  BEGIN
    -- If parameters are not valid return
    IF (p_class IS NULL OR (p_code_id IS NULL AND p_name IS NULL)) AND
       (p_class IS NULL OR p_system_status IS NULL) THEN
      RETURN ('FALSE');

    ELSE
      -- Code name has been passed
      IF p_name IS NOT NULL THEN
        -- Get the hash value of the Class + Code Name
        ln_hash_name_cc_id_hashidx_idx := DBMS_UTILITY.get_hash_value (
                                                       p_class||'@*?'||p_name,
                                                       1000,
                                                       25000);

        IF g_hash_name_cc_id_hashidx_tab.EXISTS(ln_hash_name_cc_id_hashidx_idx) THEN
          ln_hash_ccode_idx := g_hash_name_cc_id_hashidx_tab(ln_hash_name_cc_id_hashidx_idx);
        END IF;

      ELSIF p_code_id IS NOT NULL THEN
        -- Get the hash value of the Type + Code ID
        ln_hash_ccode_idx := DBMS_UTILITY.get_hash_value (
                                           p_class||'@*?'||igs_ge_number.to_cann(p_code_id),
                                           1000,
                                           25000);
      END IF;

      lv_ret_success := 'TRUE';

      IF ln_hash_ccode_idx IS NOT NULL AND
         g_hash_ccode_tab.EXISTS(ln_hash_ccode_idx) THEN
        IF p_code_id IS NOT NULL AND
           p_code_id <> g_hash_ccode_tab(ln_hash_ccode_idx).code_id THEN
          lv_ret_success := 'FALSE';
        END IF;

        IF p_name IS NOT NULL AND
           p_name <> g_hash_ccode_tab(ln_hash_ccode_idx).name THEN
          lv_ret_success := 'FALSE';
        END IF;

        IF p_system_status IS NOT NULL AND
           p_system_status <> NVL(g_hash_ccode_tab(ln_hash_ccode_idx).system_status,'@*?') THEN
          lv_ret_success := 'FALSE';
        END IF;

        IF p_closed_ind IS NOT NULL AND
           p_closed_ind <> g_hash_ccode_tab(ln_hash_ccode_idx).closed_ind THEN
          lv_ret_success := 'FALSE';
        END IF;

        IF lv_ret_success = 'TRUE' THEN
          IF p_code_id IS NULL THEN
            p_code_id := g_hash_ccode_tab(ln_hash_ccode_idx).code_id;
          END IF;

          IF p_name IS NULL THEN
            p_name := g_hash_ccode_tab(ln_hash_ccode_idx).name;
          END IF;

          IF p_system_status IS NULL THEN
            p_system_status := g_hash_ccode_tab(ln_hash_ccode_idx).system_status;
          END IF;
        END IF;
        RETURN (lv_ret_success);

      ELSE
        -- Check if the Class is already cached
        -- Get the hash value of the Class
        ln_hash_cclass_idx := DBMS_UTILITY.get_hash_value (
                                           p_class,
                                           1000,
                                           25000);

        IF g_hash_cclass_tab.EXISTS(ln_hash_cclass_idx) THEN
          -- Since all codes are already hashed,
          -- so the parameter one is invalid
          RETURN ('FALSE');

        ELSE
          -- Class is not cached so cache it.
          lb_is_cclass_cached := FALSE;

          lv_ret_success := 'FALSE';
          OPEN c_ccode (p_class);
          LOOP
            FETCH c_ccode into lr_fetched_ccode;
            EXIT WHEN c_ccode%NOTFOUND;

            -- Cache the Class only once
            IF NOT lb_is_cclass_cached THEN
              lb_is_cclass_cached := TRUE;
              g_hash_cclass_tab(ln_hash_cclass_idx) := p_class;
            END IF;

            ln_hash_ccode_idx := DBMS_UTILITY.get_hash_value (
                                              p_class||'@*?'||igs_ge_number.to_cann(lr_fetched_ccode.code_id),
                                              1000,
                                              25000);

            g_hash_ccode_tab(ln_hash_ccode_idx).code_id := lr_fetched_ccode.code_id;
            g_hash_ccode_tab(ln_hash_ccode_idx).name := lr_fetched_ccode.name;
            g_hash_ccode_tab(ln_hash_ccode_idx).system_status := lr_fetched_ccode.system_status;
            g_hash_ccode_tab(ln_hash_ccode_idx).closed_ind := lr_fetched_ccode.closed_ind;
            g_hash_ccode_tab(ln_hash_ccode_idx).system_default := lr_fetched_ccode.system_default;

            ln_hash_name_cc_id_hashidx_idx := DBMS_UTILITY.get_hash_value (
                                                           p_class||'@*?'||lr_fetched_ccode.name,
                                                           1000,
                                                           25000);

            g_hash_name_cc_id_hashidx_tab(ln_hash_name_cc_id_hashidx_idx) := ln_hash_ccode_idx;

            IF lr_fetched_ccode.closed_ind = 'N' AND
               NVL(lr_fetched_ccode.system_default,'N') = 'Y' AND
               lr_fetched_ccode.system_status IS NOT NULL THEN
              ln_hash_dflt_cc_id_hashidx_idx := DBMS_UTILITY.get_hash_value (
                                                             p_class||'@*?'||lr_fetched_ccode.system_status||'@*?'||'Y',
                                                             1000,
                                                             25000);

              g_hash_dflt_cc_id_hashidx_tab(ln_hash_dflt_cc_id_hashidx_idx) := ln_hash_ccode_idx;
            END IF;

            IF (NVL(p_code_id,-1) = g_hash_ccode_tab(ln_hash_ccode_idx).code_id) OR
               (NVL(p_name,'@*?') = g_hash_ccode_tab(ln_hash_ccode_idx).name) OR
               (NVL(p_system_status,'@*?') = NVL(g_hash_ccode_tab(ln_hash_ccode_idx).system_status,'?*@') AND
                p_code_id IS NULL AND p_name IS NULL) THEN
              lv_ret_success := 'TRUE';

              IF p_code_id IS NOT NULL AND
                 p_code_id <> g_hash_ccode_tab(ln_hash_ccode_idx).code_id THEN
                lv_ret_success := 'FALSE';
              END IF;

              IF p_name IS NOT NULL AND
                 p_name <> g_hash_ccode_tab(ln_hash_ccode_idx).name THEN
                lv_ret_success := 'FALSE';
              END IF;

              IF p_system_status IS NOT NULL AND
                 p_system_status <> NVL(g_hash_ccode_tab(ln_hash_ccode_idx).system_status,'@*?') THEN
                lv_ret_success := 'FALSE';
              END IF;

              IF p_closed_ind IS NOT NULL AND
                 p_closed_ind <> g_hash_ccode_tab(ln_hash_ccode_idx).closed_ind THEN
                lv_ret_success := 'FALSE';
              END IF;

              IF lv_ret_success = 'TRUE' THEN
                IF p_code_id IS NULL THEN
                  p_code_id := g_hash_ccode_tab(ln_hash_ccode_idx).code_id;
                END IF;

                IF p_name IS NULL THEN
                  p_name := g_hash_ccode_tab(ln_hash_ccode_idx).name;
                END IF;

                IF p_system_status IS NULL THEN
                  p_system_status := g_hash_ccode_tab(ln_hash_ccode_idx).system_status;
                END IF;
              END IF;
            END IF;

          END LOOP;
          CLOSE c_ccode;

          RETURN (lv_ret_success);
        END IF;
      END IF;
    END IF;
  END get_codeclass;

  -- Application Type to Admission Process Category
  FUNCTION get_appl_type_apc (p_application_type           IN VARCHAR2)
  RETURN VARCHAR2 -- Returns TRUE/FALSE
  IS
    lv_admission_cat            igs_ad_prcs_cat.admission_cat%TYPE;
    lv_s_admission_process_type igs_ad_prcs_cat.s_admission_process_type%TYPE;
  BEGIN
    RETURN (get_appl_type_apc (p_application_type         => p_application_type,
                               p_admission_cat            => lv_admission_cat,
                               p_s_admission_process_type => lv_s_admission_process_type));
  END get_appl_type_apc;

  FUNCTION get_appl_type_apc (p_application_type           IN VARCHAR2,
                              p_admission_cat              OUT NOCOPY VARCHAR2,
                              p_s_admission_process_type   OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2 -- Returns TRUE/FALSE
  IS
    lv_ret_success             VARCHAR2(5);
    ln_hash_appl_type_apc_idx  NUMBER;

    CURSOR c_appl_type_apc
    IS
    SELECT admission_application_type, admission_cat, s_admission_process_type
    FROM   igs_ad_ss_appl_typ;

    lr_fetched_appl_type_apc   c_appl_type_apc%ROWTYPE;

  BEGIN

    -- If parameters are not valid return
    IF (p_application_type IS NULL) THEN
      RETURN ('FALSE');

    ELSE
      -- Get the hash value of the Application Type
      ln_hash_appl_type_apc_idx := DBMS_UTILITY.get_hash_value (
                                                p_application_type,
                                                1000,
                                                25000);

      IF g_hash_appl_type_apc_tab.EXISTS(ln_hash_appl_type_apc_idx) THEN
        p_admission_cat := g_hash_appl_type_apc_tab(ln_hash_appl_type_apc_idx).admission_cat;
        p_s_admission_process_type := g_hash_appl_type_apc_tab(ln_hash_appl_type_apc_idx).s_admission_process_type;
        RETURN ('TRUE');

      ELSE
        IF g_hash_appl_type_apc_tab.COUNT > 0 THEN
          RETURN ('FALSE');

        ELSE
          lv_ret_success := 'FALSE';

          OPEN c_appl_type_apc;
          LOOP
            FETCH c_appl_type_apc into lr_fetched_appl_type_apc;
            EXIT WHEN c_appl_type_apc%NOTFOUND;

            ln_hash_appl_type_apc_idx := DBMS_UTILITY.get_hash_value (
                                                      lr_fetched_appl_type_apc.admission_application_type,
                                                      1000,
                                                      25000);

            g_hash_appl_type_apc_tab(ln_hash_appl_type_apc_idx).admission_cat := lr_fetched_appl_type_apc.admission_cat;
            g_hash_appl_type_apc_tab(ln_hash_appl_type_apc_idx).s_admission_process_type := lr_fetched_appl_type_apc.s_admission_process_type;

            IF p_application_type = lr_fetched_appl_type_apc.admission_application_type THEN
              p_admission_cat := lr_fetched_appl_type_apc.admission_cat;
              p_s_admission_process_type := lr_fetched_appl_type_apc.s_admission_process_type;
              lv_ret_success := 'TRUE';
            END IF;

          END LOOP;
          CLOSE c_appl_type_apc;

          RETURN (lv_ret_success);

        END IF;
      END IF;
    END IF;
  END get_appl_type_apc;

  -- Admission Process Category Steps
  FUNCTION get_apcs (p_admission_cat              IN VARCHAR2,
                     p_s_admission_process_type   IN VARCHAR2,
                     p_s_admission_step_type      IN VARCHAR2)
  RETURN VARCHAR2 -- Returns TRUE/FALSE
  IS
    lv_mandatory_step_ind         igs_ad_prcs_cat_step_all.mandatory_step_ind%TYPE;
    ln_step_type_restriction_num  igs_ad_prcs_cat_step_all.step_type_restriction_num%TYPE;
  BEGIN
    RETURN (get_apcs (p_admission_cat             => p_admission_cat,
                      p_s_admission_process_type  => p_s_admission_process_type,
                      p_s_admission_step_type     => p_s_admission_step_type,
                      p_mandatory_step_ind        => lv_mandatory_step_ind,
                      p_step_type_restriction_num => ln_step_type_restriction_num));
  END get_apcs;

  FUNCTION get_apcs_mnd (p_admission_cat              IN VARCHAR2,
                         p_s_admission_process_type   IN VARCHAR2,
                         p_s_admission_step_type      IN VARCHAR2)
  RETURN VARCHAR2 -- Returns TRUE/FALSE
  IS
    lv_mandatory_step_ind         igs_ad_prcs_cat_step_all.mandatory_step_ind%TYPE;
    ln_step_type_restriction_num  igs_ad_prcs_cat_step_all.step_type_restriction_num%TYPE;
  BEGIN
    lv_mandatory_step_ind := 'Y';
    RETURN (get_apcs (p_admission_cat             => p_admission_cat,
                      p_s_admission_process_type  => p_s_admission_process_type,
                      p_s_admission_step_type     => p_s_admission_step_type,
                      p_mandatory_step_ind        => lv_mandatory_step_ind,
                      p_step_type_restriction_num => ln_step_type_restriction_num));
  END get_apcs_mnd;

  FUNCTION get_apcs (p_admission_cat              IN VARCHAR2,
                     p_s_admission_process_type   IN VARCHAR2,
                     p_s_admission_step_type      IN VARCHAR2,
                     p_mandatory_step_ind         IN OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2 -- Returns TRUE/FALSE
  IS
    ln_step_type_restriction_num  igs_ad_prcs_cat_step_all.step_type_restriction_num%TYPE;
  BEGIN
    RETURN (get_apcs (p_admission_cat             => p_admission_cat,
                      p_s_admission_process_type  => p_s_admission_process_type,
                      p_s_admission_step_type     => p_s_admission_step_type,
                      p_mandatory_step_ind        => p_mandatory_step_ind,
                      p_step_type_restriction_num => ln_step_type_restriction_num));
  END get_apcs;

  FUNCTION get_apcs (p_admission_cat              IN VARCHAR2,
                     p_s_admission_process_type   IN VARCHAR2,
                     p_s_admission_step_type      IN VARCHAR2,
                     p_mandatory_step_ind         IN OUT NOCOPY VARCHAR2,
                     p_step_type_restriction_num  OUT NOCOPY NUMBER)
  RETURN VARCHAR2 -- Returns TRUE/FALSE
  IS
    lv_ret_success          VARCHAR2(5);
    ln_hash_apcs_idx        NUMBER;
    ln_hash_apc_idx         NUMBER;
    lb_is_apc_cached        BOOLEAN;
    lv_step_group_type_excl igs_ad_prcs_cat_step_all.step_group_type%TYPE;

    CURSOR c_apcs (lv_admission_cat VARCHAR2, lv_s_admission_process_type VARCHAR2)
    IS
    SELECT s_admission_step_type, mandatory_step_ind, step_type_restriction_num
    FROM   igs_ad_prcs_cat_step_all
    WHERE  admission_cat = lv_admission_cat
    AND    s_admission_process_type = lv_s_admission_process_type
    AND    step_group_type <> lv_step_group_type_excl;

    lr_fetched_apcs   c_apcs%ROWTYPE;

  BEGIN

    lv_step_group_type_excl  := 'TRACK';
    -- If parameters are not valid return
    IF (p_admission_cat IS NULL OR p_s_admission_process_type IS NULL OR p_s_admission_step_type IS NULL) THEN
      RETURN ('FALSE');

    ELSE
      -- Get the hash value of the Admission Category + System Process Type + System Step
      ln_hash_apcs_idx := DBMS_UTILITY.get_hash_value (
                                       p_admission_cat||'@*?'||p_s_admission_process_type||'@*?'||p_s_admission_step_type,
                                       1000,
                                       25000);

      lv_ret_success := 'TRUE';

      IF g_hash_apcs_tab.EXISTS(ln_hash_apcs_idx) THEN
        IF p_mandatory_step_ind IS NOT NULL AND
           p_mandatory_step_ind <> g_hash_apcs_tab(ln_hash_apcs_idx).mandatory_step_ind THEN
          lv_ret_success := 'FALSE';
        END IF;

        IF lv_ret_success = 'TRUE' THEN
          IF p_mandatory_step_ind IS NULL THEN
            p_mandatory_step_ind := g_hash_apcs_tab(ln_hash_apcs_idx).mandatory_step_ind;
          END IF;

          p_step_type_restriction_num := g_hash_apcs_tab(ln_hash_apcs_idx).step_type_restriction_num;
        END IF;

        RETURN (lv_ret_success);

      ELSE
        -- Check if the Admission Category + System Process Type is already cached
        -- Get the hash value of the Admission Category + System Process Type
        ln_hash_apc_idx := DBMS_UTILITY.get_hash_value (
                                        p_admission_cat||'@*?'||p_s_admission_process_type,
                                        1000,
                                        25000);

        IF g_hash_apc_tab.EXISTS(ln_hash_apc_idx) THEN
          -- Since all codes are already hashed,
          -- so the parameter one is invalid
          RETURN ('FALSE');

        ELSE
          -- Admission Category + System Process Type is not cached so cache it.
          lb_is_apc_cached := FALSE;

          lv_ret_success := 'FALSE';
          OPEN c_apcs (p_admission_cat, p_s_admission_process_type);
          LOOP
            FETCH c_apcs into lr_fetched_apcs;
            EXIT WHEN c_apcs%NOTFOUND;

            -- Cache the Admission Category + System Process Type only once
            IF NOT lb_is_apc_cached THEN
              lb_is_apc_cached := TRUE;
              g_hash_apc_tab(ln_hash_apc_idx).admission_cat := p_admission_cat;
              g_hash_apc_tab(ln_hash_apc_idx).s_admission_process_type := p_s_admission_process_type;
            END IF;

            ln_hash_apcs_idx := DBMS_UTILITY.get_hash_value (
                                             p_admission_cat||'@*?'||p_s_admission_process_type||'@*?'||lr_fetched_apcs.s_admission_step_type,
                                             1000,
                                             25000);

            g_hash_apcs_tab(ln_hash_apcs_idx).s_admission_step_type := lr_fetched_apcs.s_admission_step_type;
            g_hash_apcs_tab(ln_hash_apcs_idx).mandatory_step_ind := lr_fetched_apcs.mandatory_step_ind;
            g_hash_apcs_tab(ln_hash_apcs_idx).step_type_restriction_num := lr_fetched_apcs.step_type_restriction_num;

            IF (p_s_admission_step_type = g_hash_apcs_tab(ln_hash_apcs_idx).s_admission_step_type) THEN
              lv_ret_success := 'TRUE';

              IF p_mandatory_step_ind IS NOT NULL AND
                 p_mandatory_step_ind <> g_hash_apcs_tab(ln_hash_apcs_idx).mandatory_step_ind THEN
                lv_ret_success := 'FALSE';
              END IF;

              IF lv_ret_success = 'TRUE' THEN
                IF p_mandatory_step_ind IS NULL THEN
                  p_mandatory_step_ind := g_hash_apcs_tab(ln_hash_apcs_idx).mandatory_step_ind;
                END IF;

                p_step_type_restriction_num := g_hash_apcs_tab(ln_hash_apcs_idx).step_type_restriction_num;
              END IF;
            END IF;

          END LOOP;
          CLOSE c_apcs;

          RETURN (lv_ret_success);
        END IF;
      END IF;
    END IF;
  END get_apcs;

 -- Extract message from stack
  PROCEDURE extract_msg_from_stack (p_msg_at_index                NUMBER,
                                    p_return_status               OUT NOCOPY VARCHAR2,
                                    p_msg_count                   OUT NOCOPY NUMBER,
                                    p_msg_data                    OUT NOCOPY VARCHAR2,
                                    p_hash_msg_name_text_type_tab OUT NOCOPY igs_ad_gen_016.g_msg_name_text_type_table)
  IS
    l_old_msg_count               NUMBER;
    l_new_msg_count               NUMBER;
    l_msg_inc_factr               NUMBER := 1;
    l_msg_idx_start               NUMBER;
    l_msg_txt                     fnd_new_messages.message_text%TYPE;
    l_app_nme                     varchar2(1000);
    l_msg_nme                     varchar2(2000);
    l_err_msg_logged              varchar2(5);
    l_hash_msg_name_text_type_tab g_msg_name_text_type_table;
    l_table_index                 binary_integer := 0;
    l_msg_ret                     fnd_new_messages.message_text%TYPE;
    l_msg_sqlerrm                 VARCHAR2(4000);
  BEGIN
    l_old_msg_count := p_msg_at_index;
    l_new_msg_count := igs_ge_msg_stack.count_msg;
    --dbms_output.put_line('upper bound message level - '||to_char(l_new_msg_count));

    p_msg_count := l_new_msg_count - l_old_msg_count;

    WHILE (l_new_msg_count - l_old_msg_count) > 0
    LOOP
      --igs_ge_msg_stack.get(l_old_msg_count+l_msg_inc_factr,'F',l_msg_txt,l_msg_idx_start);
      igs_ge_msg_stack.get(l_old_msg_count+l_msg_inc_factr,'T',l_msg_txt,l_msg_idx_start);

      --dbms_output.put_line('message read from stack index - '||to_char(l_msg_idx_start));

      igs_ge_msg_stack.delete_msg(l_msg_idx_start);
      l_new_msg_count := l_new_msg_count -1;

      fnd_message.parse_encoded (l_msg_txt, l_app_nme, l_msg_nme);
      fnd_message.set_encoded (l_msg_txt);
      l_msg_txt := fnd_message.get;

      --dbms_output.put_line(fnd_global.tab||l_app_nme||' '||l_msg_nme||' '||l_msg_txt);

      IF NVL(l_err_msg_logged,'@*?') <> 'TRUE' THEN
        l_err_msg_logged := igs_ad_gen_016.is_err_msg (l_msg_nme, l_app_nme);
        IF NVL(l_err_msg_logged,'@*?') <> 'TRUE' THEN
          IF l_msg_ret IS NULL THEN
            IF SUBSTR(l_msg_txt,1,4) <> 'ORA-' THEN
              l_msg_ret := l_msg_txt;
            ELSE
              l_msg_ret := SUBSTR(l_msg_txt,12,LENGTH(l_msg_txt));
            END IF;
            p_return_status := 'S';
          END IF;
        ELSE
          IF SUBSTR(l_msg_txt,1,4) <> 'ORA-' THEN
            l_msg_ret := l_msg_txt;
          ELSE
            l_msg_ret := SUBSTR(l_msg_txt,12,LENGTH(l_msg_txt));
          END IF;
          p_return_status := 'E';
        END IF;
      END IF;

      l_hash_msg_name_text_type_tab(l_table_index).appl := l_app_nme;
      IF igs_ad_gen_016.is_err_msg (l_msg_nme, l_app_nme) = 'TRUE' THEN
        l_hash_msg_name_text_type_tab(l_table_index).type := 'E';
      ELSE
        l_hash_msg_name_text_type_tab(l_table_index).type := 'S';
      END IF;
      l_hash_msg_name_text_type_tab(l_table_index).name := l_msg_nme;
      l_hash_msg_name_text_type_tab(l_table_index).text := l_msg_txt;
      l_table_index := l_table_index + 1;
    END LOOP;

    l_msg_sqlerrm := SQLERRM;
    IF SQLCODE <> 0 THEN
      IF ABS(TO_CHAR(SQLCODE)) > 20000 THEN
        p_return_status := 'E';
      ELSE
        p_return_status := 'U';
        p_msg_count := l_hash_msg_name_text_type_tab.COUNT + 1;
        l_hash_msg_name_text_type_tab(l_table_index).appl := 'ORA';
        l_hash_msg_name_text_type_tab(l_table_index).type := 'U';
        l_hash_msg_name_text_type_tab(l_table_index).name := 'ORA';
        l_hash_msg_name_text_type_tab(l_table_index).text := l_msg_sqlerrm;
        l_msg_ret := l_msg_sqlerrm;
      END IF;
    END IF;

    p_msg_data := l_msg_ret;
    p_hash_msg_name_text_type_tab := l_hash_msg_name_text_type_tab;

    --dbms_output.put_line('returned message - '||l_msg_ret);
    --dbms_output.put_line('returned SQLERR message - '||l_msg_sqlerrm);
    --dbms_output.put_line('message level when done - '||to_char(igs_ge_msg_stack.count_msg));
    --dbms_output.put_line('return status - '||p_return_status||' message count - '||to_char(p_msg_count)||' message data - '||p_msg_data);
  END extract_msg_from_stack;



  PROCEDURE check_security_exception
  IS
  /* ------------------------------------------------------------------------------------------------------------------------
    Created By : rbezawad
    Date Created By : 30-Oct-04
    Purpose: This procedure will be called from Library(pld) to check if there are any error messages set in the stack
             which are related to Security Policies (IGS_SC_POLICY_EXCEPTION, IGS_SC_POLICY_UPD_DEL_EXCEP).  And it again sets
             Security Policy error on top, so that this can be shown to the user on form.  It also clears the Message stack so that
             user won't see the same error message again and again when some other operation is performed from the same form
             i.e., in same session.
    Known limitations,enhancements,remarks:
    Change History
     Who        When          What
  -----------------------------------------------------------------------------------------------------------------------*/
    l_encoded_text   VARCHAR2(4000);
    l_msg_count NUMBER;
    l_msg_index NUMBER;
    l_app_short_name VARCHAR2(50);
    l_message_name   VARCHAR2(50);

  BEGIN

    l_msg_count := IGS_GE_MSG_STACK.COUNT_MSG;
    WHILE l_msg_count <> 0 loop
      IGS_GE_MSG_STACK.GET(l_msg_count, 'T', l_encoded_text, l_msg_index);
      IGS_GE_MSG_STACK.DELETE_MSG(l_msg_index);
      fnd_message.parse_encoded(l_encoded_text, l_app_short_name, l_message_name);
      IF l_message_name = 'IGS_SC_POLICY_EXCEPTION' OR l_message_name = 'IGS_SC_POLICY_UPD_DEL_EXCEP' THEN
         fnd_message.set_encoded(l_encoded_text);
      END IF;
      l_msg_count := l_msg_count -1;
    END LOOP;

  END check_security_exception;

END igs_ad_gen_016;

/
