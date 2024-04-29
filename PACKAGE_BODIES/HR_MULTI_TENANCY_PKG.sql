--------------------------------------------------------
--  DDL for Package Body HR_MULTI_TENANCY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_MULTI_TENANCY_PKG" AS
/* $Header: permtpkg.pkb 120.0.12010000.8 2009/11/05 06:28:19 ppentapa noship $ */

FUNCTION get_label_from_bg (p_business_group_id     IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN 'C::' || 'ENT';
END get_label_from_bg;

FUNCTION is_multi_tenant_system RETURN BOOLEAN AS
  BEGIN
    RETURN FALSE;
END is_multi_tenant_system;

FUNCTION get_system_model RETURN VARCHAR2 AS
  BEGIN
    RETURN 'N';
END get_system_model;

PROCEDURE insert_hr_name_formats ( p_enterprise_code IN varchar2) AS
  BEGIN
    NULL;
END insert_hr_name_formats;

PROCEDURE set_context (p_context_value    IN VARCHAR2) AS
  BEGIN
    NULL;
END set_context;

PROCEDURE set_context_for_person (p_person_id           IN NUMBER) AS
  BEGIN
    NULL;
END set_context_for_person;

PROCEDURE set_context_for_enterprise (p_enterprise_short_code  IN VARCHAR2) AS
  BEGIN
    NULL;
END set_context_for_enterprise;

FUNCTION is_valid_sec_group (p_security_group_id   IN NUMBER
                            ,p_business_group_id   IN NUMBER) RETURN VARCHAR2 AS
  BEGIN
    RETURN 'N';
END is_valid_sec_group;

FUNCTION get_org_id_for_person (p_person_id           IN NUMBER) RETURN NUMBER AS
  BEGIN
    RETURN -1;
END get_org_id_for_person;

FUNCTION get_org_id_for_person (p_person_id           IN NUMBER
                               ,p_business_group_id   IN NUMBER) RETURN NUMBER AS
   BEGIN
     RETURN -1;
END get_org_id_for_person;

FUNCTION get_org_id_from_bg_and_sl (p_business_group_id IN NUMBER
                                   ,p_security_label    IN VARCHAR2) RETURN NUMBER AS
   BEGIN
     RETURN p_business_group_id;
END get_org_id_from_bg_and_sl;

FUNCTION get_corporate_branding (p_organization_id VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 AS
  BEGIN
      RETURN NULL;
END get_corporate_branding;

FUNCTION get_bus_grp_from_sec_grp (p_security_group_id  IN NUMBER) RETURN NUMBER AS
  BEGIN
    RETURN NULL;
END get_bus_grp_from_sec_grp;

PROCEDURE set_security_group_id (p_security_group_id   IN NUMBER) AS
  BEGIN
    NULL;
END set_security_group_id;

PROCEDURE add_language IS
    CURSOR csr_ent_data_groups IS
    SELECT pet.enterprise_id
          ,pet.enterprise_name
          ,pet.description
          ,pet.source_lang
          ,pet.created_by
          ,pet.creation_date
      FROM per_enterprises_tl pet
     WHERE pet.language = userenv('LANG');

     CURSOR csr_ins_langs (c_enterprise_id NUMBER) IS
    SELECT l.language_code
      FROM fnd_languages l
     WHERE l.installed_flag IN ('I','B')
       AND NOT EXISTS (SELECT NULL
                         FROM per_enterprises_tl pet
                        WHERE pet.enterprise_id = c_enterprise_id
                          AND pet.language = l.language_code);
  --
  BEGIN
   --
   DELETE FROM per_enterprises_tl t
     WHERE NOT EXISTS
     (  SELECT NULL
          FROM per_enterprises b
         WHERE b.enterprise_id = t.enterprise_id
     );

   UPDATE per_enterprises_tl t
      SET ( enterprise_name,
            description ) =
             ( SELECT b.enterprise_name,
                      b.description
                 FROM per_enterprises_tl b
                WHERE b.enterprise_id = t.enterprise_id
                  AND   b.language = t.source_lang       )
     WHERE ( t.enterprise_id,
             t.language
	   ) IN
        ( SELECT subt.enterprise_id,
                 subt.language
            FROM per_enterprises_tl subb, per_enterprises_tl subt
           WHERE subb.enterprise_id = subt.enterprise_id
             AND subb.language = subt.source_lang
             AND ( subb.enterprise_name <> subt.enterprise_name
              OR    subb.description <> subt.description
              OR    (subb.description IS NULL AND subt.description IS NOT NULL)
              OR    (subb.description IS NOT NULL AND subt.description IS NULL)
		  )
	);
   --
  --
   FOR l_ent_data_group IN csr_ent_data_groups LOOP
     FOR l_lang IN csr_ins_langs(l_ent_data_group.enterprise_id) LOOP
       INSERT INTO per_enterprises_tl
           (source_lang
           ,enterprise_id
           ,enterprise_name
           ,description
           ,language
           ,created_by
           ,creation_date
           ,last_updated_by
           ,last_update_date
      ) VALUES
           (l_ent_data_group.source_lang
           ,l_ent_data_group.enterprise_id
           ,l_ent_data_group.enterprise_name
           ,l_ent_data_group.description
           ,l_lang.language_code
           ,fnd_global.user_id
           ,sysdate
           ,fnd_global.user_id
           ,sysdate
           );
      END LOOP;
    END LOOP;
  --
END add_language;

END hr_multi_tenancy_pkg;

/
