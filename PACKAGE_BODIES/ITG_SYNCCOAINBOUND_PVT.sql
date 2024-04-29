--------------------------------------------------------
--  DDL for Package Body ITG_SYNCCOAINBOUND_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ITG_SYNCCOAINBOUND_PVT" AS
/* ARCS: $Header: itgvscib.pls 120.3 2006/09/15 13:37:47 pvaddana noship $
 * CVS:  itgvscib.pls,v 1.17 2002/12/23 21:20:30 ecoe Exp
 */

  l_debug_level         NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));
  G_PKG_NAME            CONSTANT VARCHAR2(30) := 'ITG_SyncCOAInbound_PVT';
  g_action              VARCHAR2(100);

  /* SEE AFQUTILB.pls: FND_IP_UTIL_PKG.processFlexValue() */

  TYPE flex_val_rec_type IS RECORD (
        flex_value_id   fnd_flex_values.flex_value_id%TYPE,
        enabled_flag    fnd_flex_values.enabled_flag%TYPE
  );

  TYPE flex_val_tbl_type IS TABLE OF flex_val_rec_type INDEX BY BINARY_INTEGER;


  FUNCTION get_flex_data(
        p_flex_value      IN         VARCHAR2,
        p_vset_id         IN         NUMBER,
        x_flex_val_tbl    OUT NOCOPY flex_val_tbl_type
  ) RETURN BOOLEAN
  IS
        CURSOR flex_data_csr IS
          SELECT flex_value_id,
                 enabled_flag
          FROM   fnd_flex_values
          WHERE  flex_value        = p_flex_value
          AND    flex_value_set_id = p_vset_id;

        l_found BOOLEAN := FALSE;
  BEGIN
        x_flex_val_tbl.delete;
        FOR rec IN flex_data_csr LOOP
                  x_flex_val_tbl(flex_data_csr%ROWCOUNT) := rec;
                  l_found := TRUE;
        END LOOP;
        RETURN l_found;
  END get_flex_data;


  FUNCTION vset_is_not_valid(
        p_vset_id       NUMBER
  ) RETURN BOOLEAN
  IS
        l_count NUMBER;
  BEGIN
        SELECT count(*)
        INTO   l_count
        FROM   fnd_id_flex_segments fs,
               fnd_flex_value_sets  vs
        WHERE  fs.enabled_flag      = 'Y'
        AND    fs.application_id    = 101
        AND    fs.id_flex_code      = 'GL#'
        AND    fs.flex_value_set_id = vs.flex_value_set_id
        AND    vs.flex_value_set_id = p_vset_id;

        RETURN l_count = 0;
  END vset_is_not_valid;

/*Decfined Private Function to check MAX size of flex value against the value defined in  Setup : Flexfields : Validation : Sets  to fix bug : 5533589
All Flex values are constrained to their value-set defined validations in the above form */
   FUNCTION flex_value_is_not_valid(
           p_vset_id      IN   NUMBER,
           p_flex_value   IN   VARCHAR2
    ) RETURN BOOLEAN
   IS
          l_vset_max_size    NUMBER;
  BEGIN

          SELECT MAXIMUM_SIZE
          INTO  l_vset_max_size
          FROM FND_FLEX_VALUE_SETS
          WHERE FLEX_VALUE_SET_ID =p_vset_id;
          RETURN LENGTH(p_flex_value)  > l_vset_max_size;

  END flex_value_is_not_valid;

  FUNCTION acct_type_required(
        p_vset_id       IN NUMBER
  ) RETURN BOOLEAN
  IS
        l_count NUMBER;
  BEGIN
        SELECT count(*)
        INTO   l_count
        FROM   fnd_id_flex_segments         s,
               fnd_segment_attribute_values sav,
               fnd_segment_attribute_types  sat
        WHERE  s.application_id           = sav.application_id
        AND    s.id_flex_code             = sav.id_flex_code
        AND    s.id_flex_num              = sav.id_flex_num
        AND    s.enabled_flag             = 'Y'
        AND    s.flex_value_set_id        = p_vset_id
        AND    s.application_column_name  = sav.application_column_name
        AND    sav.application_id         = sat.application_id
        AND    sav.id_flex_code           = sat.id_flex_code
        AND    sav.attribute_value        = 'Y'
        AND    sav.segment_attribute_type = sat.segment_attribute_type
        AND    sat.application_id         = 101
        AND    sat.id_flex_code           = 'GL#'
        AND    sat.unique_flag            = 'Y'
        AND    sat.segment_attribute_type = 'GL_ACCOUNT';

        RETURN l_count > 0;
    END acct_type_required;

  /* Public procs */

  PROCEDURE Add_FlexValue(
        x_return_status    OUT NOCOPY VARCHAR2,           /* VARCHAR2(1) */
        x_msg_count        OUT NOCOPY NUMBER,
        x_msg_data         OUT NOCOPY VARCHAR2,           /* VARCHAR2(2000) */
        p_flex_value       IN         VARCHAR2,
        p_vset_id          IN         NUMBER,
        p_flex_desc        IN         VARCHAR2,
        p_creation_date    IN         DATE     := NULL,
        p_effective_date   IN         DATE,
        p_expiration_date  IN         DATE,
        p_acct_type        IN         VARCHAR2,
        p_enabled_flag     IN         VARCHAR2
        )
  IS
        l_api_name             CONSTANT VARCHAR2(30) := 'Add_FlexValue';
        l_api_version          CONSTANT NUMBER       := 1.0;
        l_flex_val_tbl         flex_val_tbl_type;
        l_comp_attrs           FND_FLEX_VALUES.compiled_value_attributes%TYPE;
        l_next_id              NUMBER;
        l_rowid                VARCHAR2(100);
        l_creation_date        DATE;

  BEGIN
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF (l_Debug_Level <= 2) THEN
              itg_debug_pub.Add('ENTERING Add_FlexValue',2);
        END IF;

        BEGIN
                ITG_Debug.setup(
                        p_reset     => TRUE,
                        p_pkg_name  => G_PKG_NAME,
                        p_proc_name => l_api_name);

                g_action := 'Flex-value Insert';

                IF (l_Debug_Level <= 1) THEN
                      itg_debug_pub.Add('AFV -  Top of procedure.' ,1);
                      itg_debug_pub.Add('AFV -  p_flex_value'           ||p_flex_value     ,1);
                      itg_debug_pub.Add('AFV -  p_vset_id'              ||p_vset_id        ,1);
                      itg_debug_pub.Add('AFV -  p_flex_desc'            ||p_flex_desc      ,1);
                      itg_debug_pub.Add('AFV -  p_creation_date'        ||p_creation_date  ,1);
                      itg_debug_pub.Add('AFV -  p_effective_date'       ||p_effective_date ,1);
                      itg_debug_pub.Add('AFV -  p_expiration_date'      ||p_expiration_date,1);
                      itg_debug_pub.Add('AFV -  p_acct_type'            ||p_acct_type      ,1);
                      itg_debug_pub.Add('AFV -  p_enabled_flag'         ||p_enabled_flag   ,1);
                END IF;

                DECLARE
                        l_param_name    VARCHAR2(30)   := NULL;
                        l_param_value   VARCHAR2(2000) := 'NULL';
                BEGIN
                        g_action := 'Flex-parameters validation';

                        IF p_flex_value IS NULL THEN
                                l_param_name  := 'ORACLEITG.FIELDVALUE';
                        ElSIF p_vset_id IS NULL THEN
                                l_param_name  := 'ORACLEITG.FIELDID';
                        ELSIF p_effective_date IS NULL THEN
                                l_param_name  := 'DATETIME(EFFECTIVE)';
                        ELSIF p_expiration_date IS NULL THEN
                                l_param_name  := 'DATETIME(EXPIRATION)';
                        ELSIF nvl(upper(p_enabled_flag), 'z') NOT IN ('Y', 'N') THEN
                                l_param_name  := 'ORACLEITG.ACTIVE';
                                l_param_value := p_enabled_flag;
                        ELSIF vset_is_not_valid(p_vset_id) THEN
                                itg_msg.no_vset(p_vset_id);
                                RAISE FND_API.G_EXC_ERROR;
                        ELSIF  flex_value_is_not_valid( p_vset_id,p_flex_value )  THEN --Added below elsif branch to validate flex-val max size to fix bug :5533589
                                ITG_MSG.INVALID_FLEXVAL_LENGTH(p_vset_id,p_flex_value);
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;

                        IF l_param_name IS NOT NULL THEN
                                ITG_MSG.missing_element_value(l_param_name, l_param_value);
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;

                        IF get_flex_data(p_flex_value, p_vset_id, l_flex_val_tbl) THEN
                                ITG_MSG.existing_flex_value(p_flex_value, p_vset_id);
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;

                        IF acct_type_required(p_vset_id)  AND (nvl(p_acct_type, 'z') NOT IN ('A', 'L', 'O', 'R', 'E')) THEN
                                ITG_MSG.invalid_account_type(p_acct_type);
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;
                END;

                g_action := 'Flex-value insert';

                IF acct_type_required(p_vset_id) THEN
                        /* Key:
                         *   Allow Budgeting = Y,
                         *   Allow Posting   = Y,
                         *   Account Type    = value,
                         *   Reconciliation  = N
                         */
                         l_comp_attrs := 'Y'||fnd_global.local_chr(10)||'Y'||
                                         fnd_global.local_chr(10)||p_acct_type||
                                         fnd_global.local_chr(10)||'N';
                ELSE
                        /* Key:
                         *   Allow Budgeting = Y,
                         *   Allow Posting   = Y,
                         */
                         l_comp_attrs := 'Y'||fnd_global.local_chr(10)||'Y';
                END IF;

                /* next flex value id. */
                SELECT fnd_flex_values_s.nextval
                INTO   l_next_id
                FROM   dual;

                l_creation_date := nvl(p_creation_date, SYSDATE);

                BEGIN
                        IF (l_Debug_Level <= 1) THEN
                                itg_debug_pub.Add('Inserting flex value row.' ,1);
                        END IF;

                        g_action := 'Flex-value insert';
                        FND_FLEX_VALUES_PKG.insert_row(
                            x_rowid                       => l_rowid,
                            x_flex_value_id               => l_next_id,
                            x_flex_value_set_id           => p_vset_id,
                            x_flex_value                  => p_flex_value,
                            x_enabled_flag                => p_enabled_flag,
                            x_summary_flag                => 'N',
                            x_start_date_active           => p_effective_date,
                            x_end_date_active             => p_expiration_date,
                            x_parent_flex_value_low       => NULL,
                            x_parent_flex_value_high      => NULL,
                            x_structured_hierarchy_level  => NULL,
                            x_hierarchy_level             => NULL,
                            x_compiled_value_attributes   => l_comp_attrs,
                            x_value_category              => NULL,
                            x_flex_value_meaning          => p_flex_value,
                            x_description                 => p_flex_desc,
                            x_creation_date               => l_creation_date,
                            x_created_by                  => FND_GLOBAL.user_id,
                            x_last_update_date            => l_creation_date,
                            x_last_updated_by             => FND_GLOBAL.user_id,
                            x_last_update_login           => FND_GLOBAL.login_id,
                            x_attribute_sort_order        => NULL,
                            /* Why didn't the flex people default these to NULL??? */
                            x_attribute1  => NULL, x_attribute2  => NULL, x_attribute3  => NULL,
                            x_attribute4  => NULL, x_attribute5  => NULL, x_attribute6  => NULL,
                            x_attribute7  => NULL, x_attribute8  => NULL, x_attribute9  => NULL,
                            x_attribute10 => NULL, x_attribute11 => NULL, x_attribute12 => NULL,
                            x_attribute13 => NULL, x_attribute14 => NULL, x_attribute15 => NULL,
                            x_attribute16 => NULL, x_attribute17 => NULL, x_attribute18 => NULL,
                            x_attribute19 => NULL, x_attribute20 => NULL, x_attribute21 => NULL,
                            x_attribute22 => NULL, x_attribute23 => NULL, x_attribute24 => NULL,
                            x_attribute25 => NULL, x_attribute26 => NULL, x_attribute27 => NULL,
                            x_attribute28 => NULL, x_attribute29 => NULL, x_attribute30 => NULL,
                            x_attribute31 => NULL, x_attribute32 => NULL, x_attribute33 => NULL,
                            x_attribute34 => NULL, x_attribute35 => NULL, x_attribute36 => NULL,
                            x_attribute37 => NULL, x_attribute38 => NULL, x_attribute39 => NULL,
                            x_attribute40 => NULL, x_attribute41 => NULL, x_attribute42 => NULL,
                            x_attribute43 => NULL, x_attribute44 => NULL, x_attribute45 => NULL,
                            x_attribute46 => NULL, x_attribute47 => NULL, x_attribute48 => NULL,
                            x_attribute49 => NULL, x_attribute50 => NULL
                         );
                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                ITG_MSG.flex_insert_fail(p_flex_value);
                                IF (l_Debug_Level <= 5) THEN
                                      itg_debug_pub.Add('EXITING Add_FlexValue :NO_DATA_FOUND ' ,5);
                                END IF;

                                RAISE FND_API.G_EXC_ERROR;
                END;

                IF (l_Debug_Level <= 2) THEN
                        itg_debug_pub.Add('EXITING Add_FlexValue' ,2);
                END IF;
        END;
  END Add_FlexValue;



  PROCEDURE Change_FlexValue(
        x_return_status    OUT NOCOPY VARCHAR2,           /* VARCHAR2(1) */
        x_msg_count        OUT NOCOPY NUMBER,
        x_msg_data         OUT NOCOPY VARCHAR2,           /* VARCHAR2(2000) */
        p_flex_value       IN         VARCHAR2,
        p_vset_id          IN         NUMBER,
        p_flex_desc        IN         VARCHAR2,
        p_update_date      IN         DATE     := NULL,
        p_effective_date   IN         DATE,
        p_expiration_date  IN         DATE,
        p_enabled_flag     IN         VARCHAR2
  )
  IS
        l_api_name    CONSTANT VARCHAR2(30) := 'Change_FlexValue';
        l_api_version CONSTANT NUMBER       := 1.0;

        l_flex_val_tbl         flex_val_tbl_type;
        l_next_id              NUMBER;
        l_value_id             NUMBER;
        l_update_date          DATE;
  BEGIN

        IF (l_Debug_Level <= 2) THEN
              itg_debug_pub.Add('ENTERING Change_FlexValue' ,2);
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        g_action := 'Flex-value update';

        BEGIN
                ITG_Debug.setup(
                        p_reset     => TRUE,
                        p_pkg_name  => G_PKG_NAME,
                        p_proc_name => l_api_name);

                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('CFV  - Top of procedure.' ,1);
                        itg_debug_pub.Add('CFV  - p_flex_value'     ||p_flex_value      ,1);
                        itg_debug_pub.Add('CFV  - p_vset_id'        ||p_vset_id         ,1);
                        itg_debug_pub.Add('CFV  - p_flex_desc'      ||p_flex_desc       ,1);
                        itg_debug_pub.Add('CFV  - p_update_date'    ||p_update_date     ,1);
                        itg_debug_pub.Add('CFV  - p_effective_date' ||p_effective_date  ,1);
                        itg_debug_pub.Add('CFV  - p_expiration_date'||p_expiration_date ,1);
                        itg_debug_pub.Add('CFV  - p_enabled_flag'   ||p_enabled_flag    ,1);
                END IF;

                /* I am not sure about the value of preventing these validations. */
                DECLARE
                        l_param_name  VARCHAR2(30)   := NULL;
                        l_param_value VARCHAR2(2000) := 'NULL';
                BEGIN
                        g_action := 'Flex-parameters validation';
                        IF p_flex_value IS NULL THEN
                          l_param_name  := 'ORACLEITG.FIELDVALUE';
                        ElSIF p_vset_id IS NULL THEN
                          l_param_name  := 'ORACLEITG.FIELDID';
                        ELSIF p_effective_date IS NULL THEN
                          l_param_name  := 'DATETIME(EFFECTIVE)';
                        ELSIF p_expiration_date IS NULL THEN
                          l_param_name  := 'DATETIME(EXPIRATION)';
                        ELSIF nvl(upper(p_enabled_flag), 'z') NOT IN ('Y', 'N') THEN
                          l_param_name  := 'ORACLEITG.ACTIVE';
                          l_param_value := p_enabled_flag;
                        ELSIF vset_is_not_valid(p_vset_id) THEN
                              itg_msg.no_vset(p_vset_id);
                              RAISE FND_API.G_EXC_ERROR;
                        END IF;

                        IF l_param_name IS NOT NULL THEN
                                ITG_MSG.missing_element_value(l_param_name, l_param_value);
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;

                        IF NOT get_flex_data(p_flex_value, p_vset_id, l_flex_val_tbl) THEN
                                ITG_MSG.flex_update_fail_novalue(p_flex_value);
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;
                END;

                g_action := 'Flex-value update';
                l_update_date := nvl(p_update_date, SYSDATE);
                l_next_id     := l_flex_val_tbl.FIRST;

                WHILE l_next_id IS NOT NULL LOOP
                        l_value_id := l_flex_val_tbl(l_next_id).flex_value_id;
                        /* Do the flex_value... */
                        UPDATE fnd_flex_values
                        SET    start_date_active = nvl(p_effective_date,  start_date_active),
                               end_date_active   = nvl(p_expiration_date, end_date_active),
                               enabled_flag      = p_enabled_flag,
                               last_update_date  = l_update_date,
                               last_updated_by   = FND_GLOBAL.user_id
                        WHERE  flex_value_id     = l_value_id;

                        IF SQL%ROWCOUNT = 0 THEN
                                ITG_MSG.flex_update_fail_novalue(p_flex_value);
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;

                        /* ...and the translated description */
                        UPDATE fnd_flex_values_tl
                        SET     description       = p_flex_desc,
                                last_update_date  = l_update_date,
                                last_updated_by   = FND_GLOBAL.user_id
                        WHERE  flex_value_id     = l_value_id
                        AND    userenv('LANG') in (LANGUAGE, SOURCE_LANG);

                        IF SQL%ROWCOUNT = 0 THEN
                                ITG_MSG.flex_update_fail_notl(p_flex_value);
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;

                        /* Iterate */
                        l_next_id := l_flex_val_tbl.NEXT(l_next_id);
                END LOOP;

                IF (l_Debug_Level <= 2) THEN
                      itg_debug_pub.Add('EXITING Change_FlexValue' ,2);
                END IF;
        END;
  END Change_FlexValue;


  PROCEDURE Sync_FlexValue(
        x_return_status    OUT NOCOPY VARCHAR2,           /* VARCHAR2(1) */
        x_msg_count        OUT NOCOPY NUMBER,
        x_msg_data         OUT NOCOPY VARCHAR2,           /* VARCHAR2(2000) */
        p_syncind          IN         VARCHAR2,            /* 'A'dd or 'C'hange */
        p_flex_value       IN         VARCHAR2,
        p_vset_id          IN         NUMBER,
        p_flex_desc        IN         VARCHAR2,
        p_action_date      IN         DATE     := NULL,
        p_effective_date   IN         DATE,
        p_expiration_date  IN         DATE,
        p_acct_type        IN         VARCHAR2,
        p_enabled_flag     IN         VARCHAR2
  )
  IS
        l_api_name    CONSTANT VARCHAR2(30) := 'Sync_FlexValue';
        l_api_version CONSTANT NUMBER       := 1.0;
  BEGIN
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF (l_Debug_Level <= 2) THEN
              itg_debug_pub.Add('ENTERING Sync_FlexValue' ,2);
        END IF;

        BEGIN
                SAVEPOINT Sync_FlexValue_PVT;
                ITG_Debug.setup(
                        p_reset     => TRUE,
                        p_pkg_name  => G_PKG_NAME,
                        p_proc_name => l_api_name);


                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('SFV - Top of procedure.' ,1);
                        itg_debug_pub.Add('SFV - p_syncind'||p_syncind ,1);
                END IF;

                g_action := 'Flex-value sync';

                IF    UPPER(p_syncind) = 'A' THEN
                      Add_FlexValue(
                                x_return_status    => x_return_status,
                                x_msg_count        => x_msg_count,
                                x_msg_data         => x_msg_data,
                                p_flex_value       => p_flex_value,
                                p_vset_id          => p_vset_id,
                                p_flex_desc        => p_flex_desc,
                                p_creation_date    => p_action_date,
                                p_effective_date   => p_effective_date,
                                p_expiration_date  => p_expiration_date,
                                p_acct_type        => p_acct_type,
                                p_enabled_flag     => p_enabled_flag);
                ELSIF UPPER(p_syncind) = 'C' THEN
                      Change_FlexValue(
                                  x_return_status    => x_return_status,
                                  x_msg_count        => x_msg_count,
                                  x_msg_data         => x_msg_data,
                                  p_flex_value       => p_flex_value,
                                  p_vset_id          => p_vset_id,
                                  p_flex_desc        => p_flex_desc,
                                  p_update_date      => p_action_date,
                                  p_effective_date   => p_effective_date,
                                  p_expiration_date  => p_expiration_date,
                                  p_enabled_flag     => p_enabled_flag);
                ELSE
                      g_action := 'Flex-parameters validation';
                      ITG_MSG.missing_element_value('SYNCIND', p_syncind);
                      RAISE FND_API.G_EXC_ERROR;
                END IF;

                COMMIT WORK;

                IF (l_Debug_Level <= 2) THEN
                        itg_debug_pub.Add('SFV - Done. EXITING Sync_FlexValue' ,2);
                END IF;
        EXCEPTION
                WHEN FND_API.G_EXC_ERROR THEN
                        ROLLBACK TO Sync_FlexValue_PVT;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        ITG_msg.checked_error(g_action);
                        IF (l_Debug_Level <= 6) THEN
                              itg_debug_pub.Add('SFV - Done. EXITING Sync_FlexValue with ERROR' ,6);
                        END IF;

                WHEN OTHERS THEN
                        ROLLBACK TO Sync_FlexValue_PVT;
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        itg_debug.msg('Unexpected error (COA sync) - ' || substr(SQLERRM,1,255),true);
                        ITG_msg.unexpected_error(g_action);
                        IF (l_Debug_Level <= 6) THEN
                               itg_debug_pub.Add('SFV - Done. EXITING Sync_FlexValue with OTHER ERROR' ,6);
                        END IF;

        END;
  END Sync_FlexValue;

END ITG_SyncCOAInbound_PVT;

/
