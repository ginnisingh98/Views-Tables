--------------------------------------------------------
--  DDL for Package Body GMD_SECURITY_POLICY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_SECURITY_POLICY" AS
/* $Header: GMDFSPPB.pls 120.4.12010000.4 2009/12/04 09:07:31 kannavar ship $ */

-- =======================================================================================
-- USAGE
--   Used for selection from the following tables: fm_form_mst_b
-- HISTORY
-- =======================================================================================

 FUNCTION secure_formula_sel (obj_schema IN   VARCHAR2,
                              obj_name   IN   VARCHAR2) RETURN VARCHAR2 IS
       f_predicate VARCHAR2(4000);
       v_resp_id   NUMBER;

    BEGIN
--
--     Responsibility 'Product Development Security Profile Manager'
--        has full access to all formulas
--
       SELECT responsibility_id   INTO v_resp_id
       FROM   fnd_responsibility
       WHERE  responsibility_key = 'GMD_SECURITY_PROFILE_MGR';

--
--    Context m_fs_context, variable pc_ind with value 'Yes'
--       allows Planning and Costing enginees to have access to all formulas.
--
        IF SYS_CONTEXT('m_fs_context','pc_ind') = 'Yes' or
          v_resp_id = fnd_global.resp_id
        THEN
            f_predicate := '1=1';

        ELSE

 f_predicate :=
' EXISTS ( SELECT 1 '||
         ' FROM gmd_security_profiles sp '||
         ' WHERE sp.assign_method_ind IN ( ''A'') '|| --,''M'') '|| /* Bug No.9077438 */
         ' AND (  ( sp.user_id =  fnd_profile.value(''GMD_DEFAULT_USER'') '||
                  ' OR  sp.user_id = fnd_global.user_id '||
                 ' ) '||
                ' OR ( EXISTS ( SELECT rg.responsibility_id '||
                              ' FROM FND_USER_RESP_GROUPS rg '||
                              ' WHERE rg.user_id = fnd_global.user_id '||
                              ' AND sp.responsibility_id = rg.responsibility_id '||
                              ' AND SYSDATE BETWEEN rg.start_date AND NVL(rg.end_date, SYSDATE) '||
                             ' ) '||
                    ' ) '||
              ' ) '||
         ' AND NVL(responsibility_id,fnd_global.resp_id) = fnd_global.resp_id '|| /* Bug No.9077438 */
         ' AND (  EXISTS ( SELECT NULL '||
                         ' FROM org_access a1 '||
                         ' WHERE ( ( sp.organization_id = a1.organization_id '||
                                   ' AND sp.other_organization_id IS NULL '||
                                  ' ) '||
                                  ' OR sp.other_organization_id = a1.organization_id '||
                                ' ) '||
                         ' AND NVL(a1.disable_date, SYSDATE+1) >= SYSDATE '||
                         ' AND a1.resp_application_id = fnd_global.resp_appl_id '||
                         ' AND a1.responsibility_id = fnd_global.resp_id '||
                        ' ) '||
                ' OR '||
                ' NOT EXISTS ( SELECT NULL '||
                             ' FROM org_access a2 '||
                             ' WHERE ( ( sp.organization_id = a2.organization_id '||
                                       ' AND sp.other_organization_id IS NULL '||
                                      ' ) '||
                                     ' OR sp.other_organization_id = a2.organization_id '||
                                    ' ) '||
                             ' AND NVL(a2.disable_date, SYSDATE+1) >=SYSDATE '||
                            ' ) '||
              ' ) '||
         ' AND sp.organization_id = '||obj_name||'.owner_organization_id '||
        ' ) '||
' OR EXISTS ( SELECT 1 '||
            ' FROM   gmd_formula_security fs '||
            ' WHERE ( ( fs.user_id =  fnd_profile.value(''GMD_DEFAULT_USER'') '||
                      ' OR  fs.user_id = fnd_global.user_id '||
                     ' ) '||
                    ' OR ( EXISTS ( SELECT rg.responsibility_id '||
                                  ' FROM FND_USER_RESP_GROUPS rg '||
                                  ' WHERE rg.user_id = fnd_global.user_id '||
                                  ' AND fs.responsibility_id = rg.responsibility_id '||
                                  ' AND SYSDATE BETWEEN rg.start_date '||
                                  ' AND NVL(rg.end_date, SYSDATE) '||
                                 ' ) '||
                        ' ) '||
                   ' ) '||
            ' AND NVL(responsibility_id,fnd_global.resp_id) = fnd_global.resp_id '|| /* Bug No.9077438 */
            ' AND   (EXISTS ( SELECT NULL '||
                            ' FROM org_access ou '||
                            ' WHERE ( ( fs.organization_id = ou.organization_id '||
                                      ' AND fs.other_organization_id IS NULL '||
                                     ' ) '||
                                     ' OR fs.other_organization_id = ou.organization_id '||
                                   ' ) '||
                            ' AND NVL(ou.disable_date, SYSDATE+1) >= SYSDATE '||
                            ' AND ou.resp_application_id = fnd_global.resp_appl_id '||
                            ' AND ou.responsibility_id = fnd_global.resp_id '||
                           ' ) '||
                   ' OR '||
                   ' NOT EXISTS ( SELECT NULL '||
                                ' FROM org_access ou1 '||
                                ' WHERE ( ( ou1.organization_id = fs.organization_id '||
                                          ' AND fs.other_organization_id IS NULL '||
                                         ' ) '||
                                         ' OR ou1.organization_id = fs.other_organization_id '||
                                       ' ) '||
                                ' AND   NVL(ou1.disable_date, SYSDATE+1) >=SYSDATE '||
                               ' ) '||
                   ' ) '||
            ' AND fs.formula_id = ' ||obj_name||'.formula_id '||
            ' ) ';
        END IF;
        RETURN f_predicate;

    END secure_formula_sel;

-- =======================================================================================
-- USAGE
--   Used for Insert into the following tables: fm_form_mst_b
-- HISTORY
-- =======================================================================================
    FUNCTION secure_formula_ins (obj_schema IN   VARCHAR2,
                                 obj_name   IN   VARCHAR2 )RETURN VARCHAR2 IS
      f_predicate VARCHAR2(4000);
--
--  The Insert Predicate is based on GMD_SECURITY_PROFILES table since
--      a formula must exist to base access on GMD_FORMULA_SECURITY table
--

    BEGIN
      f_predicate :=
        ' EXISTS ( SELECT 1 '||
                 ' FROM gmd_security_profiles sp '||
                 ' WHERE sp.access_type_ind = ''U'' '||
                 ' AND ( responsibility_id IN ( SELECT rg.responsibility_id '||
                                      '         FROM FND_USER_RESP_GROUPS rg '||
                                      '         WHERE rg.user_id = fnd_global.user_id '||
                                      '         AND SYSDATE BETWEEN rg.start_date '||
                                      '         AND NVL(rg.end_date, SYSDATE) '||
                                     '         ) '||
               '         OR ( sp.user_id = fnd_profile.value_specific(''GMD_DEFAULT_USER'') '||
                    '         OR sp.user_id = fnd_global.user_id '||
                   '         ) '||
              '         ) '||
         '         AND organization_id = '||obj_name||'.owner_organization_id '||
         '         AND (other_organization_id IS NULL '||
              '         OR EXISTS ( SELECT NULL '||
                          '         FROM org_access a3 '||
                          '         WHERE a3.organization_id = sp.other_organization_id '||
                          '         AND NVL(a3.disable_date, SYSDATE+1) >= SYSDATE '||
                          '         AND a3.resp_application_id = fnd_global.resp_appl_id '||
                          '         AND a3.responsibility_id = fnd_global.resp_id '||
                         '         ) '||
              '         OR NOT EXISTS ( SELECT NULL '||
                              '         FROM org_access a4 '||
                              '         WHERE a4.organization_id = sp.other_organization_id '||
                              '         AND NVL(a4.disable_date, SYSDATE+1) >=SYSDATE '||
                             '         ) '||
              '         ) '||
        '         ) ';

        RETURN f_predicate;
    END secure_formula_ins;

-- =======================================================================================
-- USAGE
--   Used for Insert into the following tables: fm_matl_dtl
-- HISTORY
-- =======================================================================================
FUNCTION secure_formula_dtl_ins (obj_schema     IN  VARCHAR2,
                                 obj_name           VARCHAR2)
RETURN VARCHAR2 IS
f_predicate VARCHAR2(4000);
BEGIN
     f_predicate  :=  ' EXISTS ' ||
                      ' ( SELECT 1 '||
                        ' FROM gmd_security_profiles sp '||
                        ' WHERE sp.access_type_ind = ''U'' '||
                        ' AND ( responsibility_id IN ( SELECT rg.responsibility_id '||
                                                     ' FROM FND_USER_RESP_GROUPS rg '||
                                                     ' WHERE rg.user_id = fnd_global.user_id '||
                                                     ' AND SYSDATE BETWEEN rg.start_date '||
                                                     ' AND NVL(rg.end_date, SYSDATE) '||
                                                    ' ) '||
                              ' OR ( sp.user_id = fnd_profile.value_specific(''GMD_DEFAULT_USER'') '||
                                   ' OR sp.user_id = fnd_global.user_id '||
                                  ' ) '||
                             ' ) '||
                        ' AND organization_id = '||obj_name||'.organization_id '||
                        ' AND (other_organization_id IS NULL '||
                             ' OR EXISTS ( SELECT NULL '||
                                         ' FROM org_access a3 '||
                                         ' WHERE a3.organization_id = sp.other_organization_id '||
                                         ' AND NVL(a3.disable_date, SYSDATE+1) >= SYSDATE '||
                                         ' AND a3.resp_application_id = fnd_global.resp_appl_id '||
                                         ' AND a3.responsibility_id = fnd_global.resp_id '||
                                        ' ) '||
                             ' OR NOT EXISTS ( SELECT NULL '||
                                             ' FROM org_access a4 '||
                                             ' WHERE a4.organization_id = sp.other_organization_id '||
                                             ' AND NVL(a4.disable_date, SYSDATE+1) >=SYSDATE '||
                                            ' ) '||
                             ' ) '||
                       ' ) ';

     RETURN f_predicate;
END secure_formula_dtl_ins;

-- =======================================================================================
-- USAGE
--   Used for update to the following tables: fm_form_mst_b
-- HISTORY
-- =======================================================================================
    FUNCTION secure_formula_upd (obj_schema   IN    VARCHAR2,
                                 obj_name     IN    VARCHAR2) RETURN VARCHAR2 IS
    f_predicate VARCHAR2(4000);
     v_resp_id   NUMBER; /* Added in Bug No.8355449 */

    BEGIN
  /* Bug No.8355449 - Start*/
--     Responsibility 'Product Development Security Profile Manager'
--        has full access to all formulas
--
       SELECT responsibility_id   INTO v_resp_id
       FROM   fnd_responsibility
       WHERE  responsibility_key = 'GMD_SECURITY_PROFILE_MGR';

    --    Context m_fs_context, variable pc_ind with value 'Yes'
--       allows Planning and Costing enginees to have access to all formulas.
--
        IF SYS_CONTEXT('m_fs_context','pc_ind') = 'Yes' or v_resp_id = fnd_global.resp_id
        THEN
            f_predicate := '1=1';
      /* Bug No.8355449 - End */
        ELSE
           f_predicate := ' EXISTS ' ||
                           ' ( SELECT 1 '||
                             ' FROM gmd_security_profiles sp '||
                             ' WHERE sp.assign_method_ind IN ( ''A'') '|| --,''M'') '|| /* Bug No.9077438 */
                             ' AND sp.access_type_ind = ''U'' '||
                             ' AND (responsibility_id IN ( SELECT rg.responsibility_id '||
                                                         ' FROM FND_USER_RESP_GROUPS rg '||
                                                         ' WHERE rg.user_id = fnd_global.user_id '||
                                                         ' AND SYSDATE BETWEEN rg.start_date AND NVL(rg.end_date, SYSDATE) '||
                                                        ' ) '||
                                  ' OR ( sp.user_id = fnd_profile.value_specific(''GMD_DEFAULT_USER'') '||
                                       ' OR sp.user_id = fnd_global.user_id '||
                                      ' ) '||
                                  ' ) '||
                             ' AND NVL(responsibility_id,fnd_global.resp_id) = fnd_global.resp_id '|| /* Bug No.9077438 */
                             ' AND (  EXISTS ( SELECT NULL '||
                                             ' FROM org_access a1 '||
                                             ' WHERE ( ( sp.organization_id = a1.organization_id '||
                                                       ' AND sp.other_organization_id IS NULL '||
                                                      ' ) '||
                                                     ' OR sp.other_organization_id = a1.organization_id '||
                                                    ' ) '||
                                             ' AND NVL(a1.disable_date, SYSDATE+1) >= SYSDATE '||
                                             ' AND a1.resp_application_id = fnd_global.resp_appl_id '||
                                             ' AND a1.responsibility_id = fnd_global.resp_id '||
                                            ' ) '||
                                    ' OR '||
                                    ' NOT EXISTS ( SELECT NULL '||
                                                 ' FROM org_access a2 '||
                                                 ' WHERE ( ( sp.organization_id = a2.organization_id '||
                                                           ' AND sp.other_organization_id IS NULL '||
                                                          ' ) '||
                                                          ' OR sp.other_organization_id = a2.organization_id '||
                                                        ' ) '||
                                                 ' AND NVL(a2.disable_date, SYSDATE+1) >=SYSDATE '||
                                                ' ) '||
                                  ' ) '||
                             ' AND sp.organization_id = '||obj_name||'.owner_organization_id '||
                            ' ) '||
                           ' OR '||
                           ' EXISTS '||
                           ' ( SELECT 1 '||
                             ' FROM   gmd_formula_security fs '||
                             ' WHERE  fs.access_type_ind = ''U'' '||
                             ' AND NVL(responsibility_id,fnd_global.resp_id) = fnd_global.resp_id '|| /* Bug No.9077438 */
                             ' AND    ( ( fs.user_id =  fnd_profile.value(''GMD_DEFAULT_USER'') '||
                                        ' OR  fs.user_id = fnd_global.user_id '||
                                       ' ) '||
                                      ' OR ( EXISTS ( SELECT rg.responsibility_id '||
                                                    ' FROM FND_USER_RESP_GROUPS rg '||
                                                    ' WHERE rg.user_id = fnd_global.user_id '||
                                                    ' AND fs.responsibility_id = rg.responsibility_id '||
                                                    ' AND SYSDATE BETWEEN rg.start_date AND NVL(rg.end_date, SYSDATE) '||
                                                   ' ) '||
                                          ' ) '||
                                     ' ) '||
                             ' AND    ( EXISTS ( SELECT NULL '||
                                               ' FROM org_access ou '||
                                               ' WHERE ( ( fs.organization_id = ou.organization_id '||
                                                         ' AND fs.other_organization_id IS NULL '||
                                                        ' ) '||
                                                       ' OR fs.other_organization_id = ou.organization_id '||
                                                      ' ) '||
                                               ' AND NVL(ou.disable_date, SYSDATE+1) >= SYSDATE '||
                                               ' AND ou.resp_application_id = fnd_global.resp_appl_id '||
                                               ' AND ou.responsibility_id = fnd_global.resp_id '||
                                              ' ) '||
                                      ' OR '||
                                      ' NOT EXISTS ( SELECT NULL '||
                                                   ' FROM org_access ou1 '||
                                                   ' WHERE ( ( ou1.organization_id = fs.organization_id '||
                                                             ' AND fs.other_organization_id IS NULL '||
                                                            ' ) '||
                                                           ' OR ou1.organization_id = fs.other_organization_id '||
                                                          ' ) '||
                                                   ' AND   NVL(ou1.disable_date, SYSDATE+1) >=SYSDATE '||
                                                  ' ) '||
                                     ' ) '||
                             ' AND fs.formula_id = '||obj_name||'.formula_id '||
                            ' ) ';
        END IF;
        RETURN f_predicate;
    END secure_formula_upd;

-- =======================================================================================
-- USAGE
--   Used for update to the following tables: fm_matl_dtl
-- HISTORY
-- =======================================================================================
   FUNCTION secure_formula_dtl_sel (obj_schema IN   VARCHAR2,
                                    obj_name   IN   VARCHAR2) RETURN VARCHAR2 IS
       f_predicate VARCHAR2(4000);
    BEGIN
--
--    Context m_fs_context, variable pc_ind with value 'Yes'
--       allows Planning and Costing enginees to have access to all formulas.
--
        IF SYS_CONTEXT('m_fs_context','pc_ind') = 'Yes'  THEN
            f_predicate := '1=1';
        ELSE
            f_predicate :=  ' EXISTS ( SELECT 1 '||
                                     ' FROM fm_form_mst_b fm WHERE fm.formula_id = ' ||obj_name||'.formula_id )';
         END IF;
         RETURN f_predicate;
    END secure_formula_dtl_sel;

-- =======================================================================================
-- USAGE
--   Used for selection and update of the following tables: gmd_recipe_step_materials
--                                                          gmd_recipes_validity_rules
-- HISTORY
-- =======================================================================================

FUNCTION secure_recipe_sel (obj_schema   IN   VARCHAR2,
                            obj_name     IN   VARCHAR2) RETURN VARCHAR2 IS

    f_predicate VARCHAR2(4000);
    BEGIN
      If SYS_CONTEXT('m_fs_context','pc_ind') = 'Yes'
        THEN
            f_predicate := '1=1';

        ELSE
           f_predicate := ' EXISTS (SELECT 1 FROM gmd_recipes_b WHERE recipe_id = '||obj_name||'.recipe_id)';
        END IF;
        RETURN f_predicate;
    END secure_recipe_sel;

 end gmd_security_policy;



/
