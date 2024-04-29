--------------------------------------------------------
--  DDL for Package Body FND_OAM_DSCRAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_DSCRAM" AS
/* $Header: AFOAMDSB.pls 120.6.12000000.3 2007/04/21 02:55:34 ssuprasa ship $ */

   ----------------------------------------
   -- Private Body Constants
   ----------------------------------------
   PKG_NAME                     CONSTANT VARCHAR2(30) := 'FND_OAM_DSCRAM.';

   -- text entered in the dscram_level of every attribute/col_priv to identify that it's from our UI.
   B_DSCRAM_LEVEL_USER_DEFINED  CONSTANT VARCHAR2(30) := 'USER_DEFINED';

   ----------------------------------------
   -- Public/Private Procedures/Functions
   ----------------------------------------

/* insert a new data scrambling policy */
procedure insert_policy
(
        policyid               OUT NOCOPY NUMBER,
        pname                  in varchar2,
        l_description          IN VARCHAR2 DEFAULT NULL,
        l_created_by           IN NUMBER,
        l_last_updated_by      IN NUMBER,
        l_last_update_login    IN NUMBER
) is

begin

  /* Get new ID */
  select FND_OAM_DS_POLICIES_S.nextval
    into policyid
    from sys.dual;

        /*insert into the base table*/

  insert into FND_OAM_DS_POLICIES_B (
         policy_id,
   CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN)
   values
        (policyid, l_created_by, sysdate,
         l_last_updated_by, sysdate, l_last_update_login);

        /*insert into the TL table*/

  insert into FND_OAM_DS_POLICIES_TL (
        policy_id,
        policy_name,
        description,
  CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        language,
        source_lang
  )
  select
    policyid,insert_policy.pname,insert_policy.l_description, insert_policy.l_created_by,
    sysdate, insert_policy.l_last_updated_by, sysdate,  insert_policy.l_last_update_login,
    l.language_code, userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_OAM_DS_POLICIES_TL T
    where T.POLICY_ID = policyid
    and T.LANGUAGE = L.LANGUAGE_CODE);

  commit;

  EXCEPTION
    when others then
      rollback;
      raise;

end insert_policy;

/* update a data scrambling policy */

procedure update_policy
(
        policyid            in number,
        pname               in varchar2,
        l_description       IN VARCHAR2 DEFAULT NULL,
        l_last_updated_by   IN NUMBER,
        l_last_update_login IN NUMBER
) is

begin

        /*update*/

  update FND_OAM_DS_POLICIES_B
        set LAST_UPDATED_BY = l_last_updated_by,
            LAST_UPDATE_DATE = sysdate,
            LAST_UPDATE_LOGIN = l_last_update_login
        where policy_id = policyid;


  /* Make sure no bad data in tl table */
  delete from FND_OAM_DS_POLICIES_TL
   where policy_id = policyid
     and language in  (select l.language_code
                       from fnd_languages l
                      where l.installed_flag in ('I', 'B'));


  insert into FND_OAM_DS_POLICIES_TL (
        policy_id,
        policy_name,
        description,
  CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        language,
        source_lang
  )
  select
    update_policy.policyid,update_policy.pname,update_policy.l_description,   update_policy.l_last_update_login,
    sysdate, update_policy.l_last_updated_by, sysdate,  update_policy.l_last_update_login,
    l.language_code, userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_OAM_DS_POLICIES_TL T
    where T.POLICY_ID = policyid
    and T.LANGUAGE = L.LANGUAGE_CODE);

/* Delete all policy elements for this policy. */

 delete from FND_OAM_DS_POLICY_ELMNTS where policy_id = policyid;
 commit;

  EXCEPTION
    when others then
      rollback;
      raise;

end update_policy;


/* insert a new data scrambling policy set */


procedure insert_policyset
(
        psetid                  OUT NOCOPY NUMBER,
        psetname                in varchar2,
        l_description           IN VARCHAR2 DEFAULT NULL,
        l_created_by            IN NUMBER,
        l_last_updated_by       IN NUMBER,
        l_last_update_login     IN NUMBER
) is

begin

  /* Get new ID */
  select FND_OAM_DS_PSETS_S.nextval
    into psetid
    from sys.dual;

        /*insert*/

  insert into FND_OAM_DS_PSETS_B (
         policyset_id,
   CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN)
   values
        (psetid, l_created_by, sysdate,
         l_last_updated_by, sysdate, l_last_update_login);


  insert into FND_OAM_DS_PSETS_TL (
        policyset_id,
        policyset_name,
        description,
  CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        language,
        source_lang
  )
  select
    psetid,insert_policyset.psetname,insert_policyset.l_description,
    insert_policyset.l_created_by,
    sysdate, insert_policyset.l_last_updated_by, sysdate,
    insert_policyset.l_last_update_login,
    l.language_code, userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_OAM_DS_PSETS_TL T
    where T.POLICYSET_ID = psetid
    and T.LANGUAGE = L.LANGUAGE_CODE);

   commit;
  EXCEPTION
    when others then
      rollback;
      raise;

end insert_policyset;

/* update a data scrambling policy set */

procedure update_policyset
(
        psetid                  in number,
        psetname                in varchar2,
        l_description           IN VARCHAR2 DEFAULT NULL,
        l_last_updated_by       IN NUMBER,
        l_last_update_login     IN NUMBER
) is

begin

        /*update*/

  update FND_OAM_DS_PSETS_B
        set LAST_UPDATED_BY = l_last_updated_by,
            LAST_UPDATE_DATE = sysdate,
            LAST_UPDATE_LOGIN = l_last_update_login
        where policyset_id = psetid;


  /* Make sure no bad data in tl table */
  delete from FND_OAM_DS_PSETS_TL
   where policyset_id = psetid
     and language in  (select l.language_code
                       from fnd_languages l
                      where l.installed_flag in ('I', 'B'));


  insert into FND_OAM_DS_PSETS_TL (
        policyset_id,
        policyset_name,
        description,
  CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        language,
        source_lang
  )
  select
    update_policyset.psetid,update_policyset.psetname,update_policyset.l_description,
    update_policyset.l_last_update_login,
    sysdate, update_policyset.l_last_updated_by, sysdate,
    update_policyset.l_last_update_login,
    l.language_code, userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_OAM_DS_PSETS_TL T
    where T.POLICYSET_ID = psetid
    and T.LANGUAGE = L.LANGUAGE_CODE);

/* Delete all policy set elements for this policy set. */

 delete from FND_OAM_DS_PSET_ELMNTS where policyset_id = psetid;

   commit;
  EXCEPTION
    when others then
      rollback;
      raise;

end update_policyset;

/* add a new privacy attribute for a policy with policyid*/

procedure add_policy_attri_element
(
        policyid                in number,
        attribute_code          IN VARCHAR2,
        l_created_by            IN NUMBER,
        l_last_updated_by       IN NUMBER,
        l_last_update_login     IN NUMBER
) is

 elementid number;

begin

  /* Get new ID */
  select FND_OAM_DS_POLICY_ELMNTS_S.nextval
    into elementid
    from sys.dual;

        /*insert*/

  insert into FND_OAM_DS_POLICY_ELMNTS(
         policy_rel_id,
         policy_id,
   element_type,
         privacy_attribute_code,
   CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN)
   values
        (elementid, policyid, 'PII_ATTRIBUTE', attribute_code, l_created_by, sysdate,
         l_last_updated_by, sysdate, l_last_update_login);

   commit;
  EXCEPTION
    when others then
      rollback;
      raise;

end add_policy_attri_element;

/* remove all policy elements for a policy with policyid */

procedure remove_policy_elements
(
        policyid                        in number
) is


begin

   delete from FND_OAM_DS_POLICY_ELMNTS where policy_id = policyid;

   commit;
  EXCEPTION
    when others then
      rollback;
      raise;

end remove_policy_elements;


/* add a new delete element for a policy with policyid*/

procedure add_policy_del_element
(
        policyid                in number,
        deleteid                IN NUMBER,
        l_created_by            IN NUMBER,
        l_last_updated_by       IN NUMBER,
        l_last_update_login     IN NUMBER
) is

 elementid number;

begin

  /* Get new ID */
  select FND_OAM_DS_POLICY_ELMNTS_S.nextval
    into elementid
    from sys.dual;

        /*insert*/

  insert into FND_OAM_DS_POLICY_ELMNTS(
         policy_rel_id,
         policy_id,
   element_type,
         delete_id,
   CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN)
   values
        (elementid, policyid, 'DML_DELETE', deleteid, l_created_by, sysdate,
         l_last_updated_by, sysdate, l_last_update_login);

   commit;
  EXCEPTION
    when others then
      rollback;
      raise;

end add_policy_del_element;


/* add a new policy into a policy set with psetid*/

procedure add_pset_element
(
        psetid                  in number,
        policyid                in number,
        l_created_by            IN NUMBER,
        l_last_updated_by       IN NUMBER,
        l_last_update_login     IN NUMBER
) is

 elementid number;

begin

  /* Get new ID */
  select FND_OAM_DS_PSET_ELMNTS_S.nextval
    into elementid
    from sys.dual;

        /*insert*/

  insert into FND_OAM_DS_PSET_ELMNTS(
         policyset_rel_id,
         policyset_id,
         policy_id,
   CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN)
   values
        (elementid, psetid, policyid, l_created_by, sysdate,
         l_last_updated_by, sysdate, l_last_update_login);

   commit;
  EXCEPTION
    when others then
      rollback;
      raise;

end add_pset_element;

/* remove all elements for a policy set with psetid*/

procedure remove_pset_elements
(
        psetid                  in number
) is


begin

   delete from FND_OAM_DS_PSET_ELMNTS where policyset_id = psetid;

   commit;
  EXCEPTION
    when others then
      rollback;
      raise;

end remove_pset_elements;


/* add a new delete entry into FND_OAM_DS_DELETES */

procedure add_delete
(
        l_table_name              IN VARCHAR2,
        l_owner                   IN VARCHAR2 DEFAULT NULL,
        l_where_clause            IN VARCHAR2 DEFAULT NULL,
        l_use_truncate_flag       IN VARCHAR2 DEFAULT NULL,
        l_created_by              IN NUMBER,
        l_last_updated_by         IN NUMBER,
        l_last_update_login       IN NUMBER
) is

        deleteid number;
        v_use_truncate_flag varchar2(3);
        v_owner varchar2(30);
        v_count number;

begin

  /* Get new ID */
  select FND_OAM_DS_DELETES_S.nextval
    into deleteid
    from sys.dual;

    --truncate flag, value can be "T" or "F". the default is "F"
    v_use_truncate_flag := NVL(l_use_truncate_flag, 'F');

    v_owner := l_owner;

    if l_owner is null then
     --find owner based on table_name.
     select ou.oracle_username into v_owner
         from   fnd_tables t,
                fnd_product_installations pi,
                fnd_oracle_userid ou
         where  t.table_name = upper(l_table_name)
         and    t.application_id = pi.application_id
         and    pi.oracle_id = ou.oracle_id;
    end if;

  --before insert, check there is an existing row in fnd_oam_ds_deletes for
  -- (owner, table_name, where_cluase, use_truncate_flag)

  select count(*) into v_count from fnd_oam_ds_deletes
    where owner = v_owner
      and table_name = l_table_name
      and where_clause = l_where_clause
      and use_truncate_flag = v_use_truncate_flag;

      --insert when there is not an existing entry.
  if v_count = 0 then
   insert into FND_OAM_DS_DELETES(
         delete_id,
         table_name,
         owner,
         where_clause,
         use_truncate_flag,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN)
    values
        (deleteid, l_table_name, v_owner, l_where_clause, v_use_truncate_flag, l_created_by, sysdate,
         l_last_updated_by, sysdate, l_last_update_login);
  end if;

   commit;
  EXCEPTION
    when others then
      rollback;
      raise;

end add_delete;




/* add a new delete entry into FND_OAM_DS_DELETES */

procedure update_delete
(
        l_delete_id               IN VARCHAR2,
        l_where_clause            IN VARCHAR2 DEFAULT NULL,
        l_use_truncate_flag       IN VARCHAR2 DEFAULT NULL,
        l_last_updated_by              IN NUMBER
) is

        deleteid number;
        v_use_truncate_flag varchar2(3);
        v_owner varchar2(30);
        v_count number;

begin


    --truncate flag, value can be "T" or "F". the default is "F"
    v_use_truncate_flag := NVL(l_use_truncate_flag, 'F');

  select count(*) into v_count from fnd_oam_ds_deletes
    where delete_id=l_delete_id;

  --insert when there is not an existing entry.
  if v_count > 0 then
   update FND_OAM_DS_DELETES
     set where_clause=l_where_clause, use_truncate_flag = l_use_truncate_flag,
         last_updated_by=l_last_updated_by ,last_update_date=sysdate
	 where delete_id=l_delete_id;
  end if;

   commit;
  EXCEPTION
    when others then
      rollback;
      raise;

end update_delete;






/* remove a delete entry with deleteid from FND_OAM_DS_DELETES */

procedure remove_delete
(
        deleteid        in number
) is


begin

   delete from FND_OAM_DS_DELETES where delete_id = deleteid;

   commit;
  EXCEPTION
    when others then
      rollback;
      raise;

end remove_delete;


--syschange
/* remove an attribute */

procedure delete_pii_attribute
(
        attribute_code        in varchar2
) is

begin

   delete from FND_PRIVACY_ATTRIBUTES_B where privacy_attribute_code = attribute_code;
   delete from FND_PRIVACY_ATTRIBUTES_TL where privacy_attribute_code = attribute_code;
   delete from FND_OAM_DS_POLICY_ELMNTS where privacy_attribute_code = attribute_code;
   delete from FND_COL_PRIV_ATTRIBUTES_B where privacy_attribute_code = attribute_code;
   delete from FND_OAM_DS_PII_EXTENSIONS where privacy_attribute_code = attribute_code;
   commit;
  EXCEPTION
    when others then
      rollback;
      raise;

end delete_pii_attribute;


/* remove an policy */
--FIXME
procedure delete_policy
(
        p_policy_id        in NUMBER
) is

begin

   delete from FND_OAM_DS_POLICIES_B where policy_id = p_policy_id;
   delete from FND_OAM_DS_POLICIES_TL where policy_id = p_policy_id;
   delete from FND_OAM_DS_PSET_ELMNTS where policy_id = p_policy_id;
   delete from FND_OAM_DS_POLICY_ELMNTS where policy_id = p_policy_id;

   commit;
  EXCEPTION
    when others then
      rollback;
      raise;

end delete_policy;

/* remove the policy set*/
--FIXME
procedure delete_pset
(
        pset_id        in NUMBER
) is

begin

   delete from FND_OAM_DS_PSETS_B where policyset_id = pset_id;
   delete from FND_OAM_DS_PSETS_TL where policyset_id = pset_id;
   delete from FND_OAM_DS_PSET_ELMNTS where policyset_id = pset_id;

   commit;
  EXCEPTION
    when others then
      rollback;
      raise;

end delete_pset;



/* remove an policy */
--FIXME
procedure delete_tbl_to_purge
(
        deleteid        in NUMBER
) is

begin

   delete from FND_OAM_DS_DELETES where delete_id = deleteid;
   delete from FND_OAM_DS_POLICY_ELMNTS where delete_id = deleteid;
   commit;
  EXCEPTION
    when others then
      rollback;
      raise;

end delete_tbl_to_purge;


/* insert a new PII privacy attribute */

procedure insert_pii_attribute
(
        attribute_code          OUT NOCOPY VARCHAR2,
        attribute_name          IN VARCHAR2,
        l_algorithm             IN VARCHAR2 DEFAULT NULL,
        l_description           IN VARCHAR2 DEFAULT NULL,
        l_created_by            IN NUMBER,
        l_last_updated_by       IN NUMBER,
        l_last_update_login     IN NUMBER
) is
    aid number;
    algoid number := NULL;

begin


        /*get algorithm id */
  IF l_algorithm IS NOT NULL THEN
     algoid := FND_OAM_DS_ALGOS_PKG.GET_ALGO_ID(l_algorithm);
  END IF;

        /* Get new ID */
  select FND_OAM_DS_ATTRI_S.nextval
    into aid
    from sys.dual;

        /*construct the attribute code */
   attribute_code := 'DSCRAM_'||to_char(aid);


   --create the attribute
   insert into FND_PRIVACY_ATTRIBUTES_B (PRIVACY_ATTRIBUTE_CODE,
                                         PRIVACY_ATTRIBUTE_TYPE,
                                         SENSITIVITY,
                                         PII_FLAG,
                                         LOCKED_FLAG,
                                         OBJECT_VERSION_NUMBER,
                                         DSCRAM_LEVEL,
                                         DSCRAM_ALGO_ID,
                                         CREATED_BY,
                                         CREATION_DATE,
                                         LAST_UPDATED_BY,
                                         LAST_UPDATE_DATE,
                                         LAST_UPDATE_LOGIN)
      VALUES (attribute_code,
              'Base',
              'Private',
              'N',
              'N',
              0,
              B_DSCRAM_LEVEL_USER_DEFINED,
              algoid,
              l_created_by,
              sysdate,
              l_last_updated_by,
              sysdate,
              l_last_update_login);

   insert into FND_PRIVACY_ATTRIBUTES_TL (PRIVACY_ATTRIBUTE_CODE,
                                          PRIVACY_ATTRIBUTE_NAME,
                                          DESCRIPTION,
                                          CREATED_BY,
                                          CREATION_DATE,
                                          LAST_UPDATED_BY,
                                          LAST_UPDATE_DATE,
                                          LAST_UPDATE_LOGIN,
                                          language,
                                          source_lang
                                          )
  select
        attribute_code,
        insert_pii_attribute.attribute_name,
        insert_pii_attribute.l_description,
        insert_pii_attribute.l_created_by,
        sysdate,
        insert_pii_attribute.l_last_updated_by,
        sysdate,
        insert_pii_attribute.l_last_update_login,
        l.language_code,
        userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_PRIVACY_ATTRIBUTES_TL T
    where T.PRIVACY_ATTRIBUTE_CODE = attribute_code
    and T.LANGUAGE = L.LANGUAGE_CODE);

   commit;
  EXCEPTION
    when others then
      rollback;
      raise;

end insert_pii_attribute;




procedure update_pii_attribute
(
        attribute_code          IN VARCHAR2,
        attribute_name          IN VARCHAR2,
        l_algorithm             IN VARCHAR2 DEFAULT NULL,
        l_description           IN VARCHAR2 DEFAULT NULL,
        l_created_by            IN NUMBER,
        l_last_updated_by       IN NUMBER,
        l_last_update_login     IN NUMBER
) is
    aid number;
    algoid number := NULL;

begin


        /*get algorithm id */
  IF l_algorithm IS NOT NULL THEN
     algoid := FND_OAM_DS_ALGOS_PKG.GET_ALGO_ID(l_algorithm);
  END IF;


   --create the attribute

  UPDATE  FND_PRIVACY_ATTRIBUTES_B
  SET DSCRAM_ALGO_ID = algoid,
  LAST_UPDATED_BY = l_last_updated_by,
  LAST_UPDATE_DATE = sysdate
  where PRIVACY_ATTRIBUTE_CODE = attribute_code ;




  /* insert into FND_PRIVACY_ATTRIBUTES_B (PRIVACY_ATTRIBUTE_CODE,
                                         PRIVACY_ATTRIBUTE_TYPE,
                                         SENSITIVITY,
                                         PII_FLAG,
                                         LOCKED_FLAG,
                                         OBJECT_VERSION_NUMBER,
                                         DSCRAM_LEVEL,
                                         DSCRAM_ALGO_ID,
                                         CREATED_BY,
                                         CREATION_DATE,
                                         LAST_UPDATED_BY,
                                         LAST_UPDATE_DATE,
                                         LAST_UPDATE_LOGIN)
      VALUES (attribute_code,
              'Base',
              'Private',
              'N',
              'N',
              0,
              B_DSCRAM_LEVEL_USER_DEFINED,
              algoid,
              l_created_by,
              sysdate,
              l_last_updated_by,
              sysdate,
              l_last_update_login); */

   insert into FND_PRIVACY_ATTRIBUTES_TL (PRIVACY_ATTRIBUTE_CODE,
                                          PRIVACY_ATTRIBUTE_NAME,
                                          DESCRIPTION,
                                          CREATED_BY,
                                          CREATION_DATE,
                                          LAST_UPDATED_BY,
                                          LAST_UPDATE_DATE,
                                          LAST_UPDATE_LOGIN,
                                          language,
                                          source_lang
                                          )
  select
        attribute_code,
        update_pii_attribute.attribute_name,
        update_pii_attribute.l_description,
        update_pii_attribute.l_created_by,
        sysdate,
        update_pii_attribute.l_last_updated_by,
        sysdate,
        update_pii_attribute.l_last_update_login,
        l.language_code,
        userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_PRIVACY_ATTRIBUTES_TL T
    where T.PRIVACY_ATTRIBUTE_CODE = attribute_code
    and T.LANGUAGE = L.LANGUAGE_CODE);

   commit;
  EXCEPTION
    when others then
      rollback;
      raise;

end update_pii_attribute;



/* update a PII privacy attribute */

procedure pre_update_pii_attribute
(
        attribute_code          IN VARCHAR2
) is
        algoid number := NULL;

begin

   --delete from FND_PRIVACY_ATTRIBUTES_B where privacy_attribute_code = attribute_code;
   delete from FND_PRIVACY_ATTRIBUTES_TL where privacy_attribute_code = attribute_code;
   delete from FND_COL_PRIV_ATTRIBUTES_B where privacy_attribute_code = attribute_code;
   delete from FND_OAM_DS_PII_EXTENSIONS where privacy_attribute_code = attribute_code;
  EXCEPTION
    when others then
      rollback;
      raise;

end pre_update_pii_attribute;


/* add a new PII privacy attribute column for a privacy attribute with attribute_code*/

procedure add_attribute_col
(
        attribute_code          IN VARCHAR2,
        l_table_name            IN VARCHAR2,
        l_column_name           IN VARCHAR2,
        l_where_clause          IN VARCHAR2 DEFAULT NULL,
        l_algorithm             IN VARCHAR2 DEFAULT NULL,
        l_created_by            IN NUMBER,
        l_last_updated_by       IN NUMBER,
        l_last_update_login     IN NUMBER
) is

   l_algo_id            NUMBER := NULL;
   l_application_id     NUMBER;
   l_table_id           NUMBER;
   l_column_id          NUMBER;
   l_column_seq         NUMBER;

   l_extension_id       NUMBER;
BEGIN
   --if the user specified an algorithm, get its ID
   IF l_algorithm IS NOT NULL THEN
      l_algo_id := FND_OAM_DS_ALGOS_PKG.GET_ALGO_ID(l_algorithm);
   END IF;

   --query the application_id, table_id and column_id once so we don't have to do the
   --ugly fnd_columns full table scan twice and we can check for a single entry
   SELECT T.application_id, T.table_id, C.column_id, C.column_sequence
      INTO l_application_id, l_table_id, l_column_id, l_column_seq
      FROM FND_TABLES T, FND_COLUMNS C
      WHERE T.TABLE_NAME = upper(l_table_name)
      AND T.TABLE_ID = C.TABLE_ID
      AND C.COLUMN_NAME = upper(l_column_name);

   --insert into fnd_col_priv_attributes_b
   INSERT INTO FND_COL_PRIV_ATTRIBUTES_B (PRIVACY_ATTRIBUTE_CODE,
                                          APPLICATION_ID,
                                          TABLE_ID,
                                          COLUMN_ID,
                                          COLUMN_SEQUENCE,
                                          OBJECT_VERSION_NUMBER,
                                          DSCRAM_LEVEL,
                                          DSCRAM_ALGO_ID,
                                          CREATED_BY,
                                          CREATION_DATE,
                                          LAST_UPDATED_BY,
                                          LAST_UPDATE_DATE,
                                          LAST_UPDATE_LOGIN
                                          )
      VALUES (attribute_code,
              l_application_id,
              l_table_id,
              l_column_id,
              l_column_seq,
              0,
              B_DSCRAM_LEVEL_USER_DEFINED,
              l_algo_id,
              l_created_by,
              SYSDATE,
              l_last_updated_by,
              SYSDATE,
              l_last_update_login);

   --if it has a where clause, insert a pii_extensions row
   IF l_where_clause IS NOT NULL THEN
      INSERT INTO FND_OAM_DS_PII_EXTENSIONS (PII_EXTENSION_ID,
                                             PRIVACY_ATTRIBUTE_CODE,
                                             APPLICATION_ID,
                                             TABLE_ID,
                                             COLUMN_ID,
                                             WHERE_CLAUSE,
                                             CREATED_BY,
                                             CREATION_DATE,
                                             LAST_UPDATED_BY,
                                             LAST_UPDATE_DATE,
                                             LAST_UPDATE_LOGIN
                                             )
         VALUES (FND_OAM_DS_PII_EXTENSIONS_S.NEXTVAL,
                 attribute_code,
                 l_application_id,
                 l_table_id,
                 l_column_id,
                 l_where_clause,
                 l_created_by,
                 SYSDATE,
                 l_last_updated_by,
                 SYSDATE,
                 l_last_update_login)
         RETURNING pii_extension_id INTO l_extension_id;
   END IF;

   --submit the changes
   COMMIT;

  EXCEPTION
     when others then
        rollback;
        raise;
end add_attribute_col;


/*
   -- remove a PII privacy attribute column for a privacy attribute with attribute_code
procedure remove_attribute_col
(
        attribute_code    IN VARCHAR2,
        l_table_name      IN VARCHAR2,
        l_column_name     IN VARCHAR2
) is
begin

   --FIXME: this incurs an unnecessary full table scan of fnd_columns when we should be deleting using the
   --known attribute_code, application_id, table_id, column_id to get the index.
  delete from FND_COL_PRIV_ATTRIBUTES_B where
        PRIVACY_ATTRIBUTE_CODE = attribute_code
        and table_id = (select table_id from fnd_tables
                where table_name = upper(l_table_name))
        and column_id = (select column_id from fnd_columns c, fnd_tables t where
                c.table_id = t.table_id
                and t.table_name = upper(l_table_name)
                and c.column_name = upper(l_column_name));

   commit;
  EXCEPTION
    when others then
      rollback;
      raise;

end remove_attribute_col;
*/

/*
   --ilawler: Removed these procedures because enabling will occur via a sql script shipped to
   --customers.

   -- This procedure enables the data scrambling configuration UI display.
   -- It changes profile OAM_DSCRAM_ENABLED value to be 'YES'

procedure enable_dscram_ui
 is
begin

   --incurs full table scan without application_id also in where clause
   update fnd_profile_option_values set profile_option_value = 'YES'
        where profile_option_id =
        (select profile_option_id from fnd_profile_options f, fnd_application a
                where  f.application_id=a.application_id
                and a.application_short_name='FND'
                and f.profile_option_name='OAM_DSCRAM_ENABLED');

   commit;
  EXCEPTION
    when others then
      rollback;
      raise;

end enable_dscram_ui;


-- This procedure disables the data scrambling configuration UI display.
-- It changes profile OAM_DSCRAM_ENABLED value to be 'NO'

procedure disable_dscram_ui
 is
begin

update fnd_profile_option_values set profile_option_value = 'NO'
        where profile_option_id =
        (select profile_option_id from fnd_profile_options f, fnd_application a
                where  f.application_id=a.application_id
                and a.application_short_name='FND'
                and f.profile_option_name='OAM_DSCRAM_ENABLED');

   commit;
  EXCEPTION
    when others then
      rollback;
      raise;

end disable_dscram_ui;
*/

   -- Public
   PROCEDURE IMPORT_POLICY_SET_TO_DSCFG
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'IMPORT_POLICY_SET_TO_DSCFG';

      --cursor to query policies for a policy set
      CURSOR pset_policy_c (v_psetid fnd_oam_ds_psets_b.policyset_id%TYPE) IS
         select policy_id
         from   fnd_oam_ds_pset_elmnts
         where  policyset_id = v_psetid;
      policy_rec       pset_policy_c%ROWTYPE;

      --CURSOR policy_c (v_policyid fnd_oam_ds_policies_b.policy_id%TYPE) IS
        -- select element_type, PRIVACY_ATTRIBUTE_CODE, DELETE_ID
        -- from fnd_oam_ds_policy_elmnts
        -- where        policy_id = v_policyid;

      --cursor to query pii attributes for a policy, assumes that the pii_extensions table
      --has only 0 or 1 corresponding rows for an attribute.
      CURSOR policy_attri_c (v_policyid fnd_oam_ds_policies_b.policy_id%TYPE) IS
         select pe.privacy_attribute_code privacy_attribute_code,
                ou.oracle_username owner,
                t.table_name table_name,
                c.column_name column_name,
                decode(c.column_type,
                      'V', 'VARCHAR2',
                      'D', 'DATE',
                      'N', 'NUMBER', c.column_type) column_type,
                pa.dscram_algo_id attri_algo,
                pc.dscram_algo_id col_algo,
                dpe2.algo_id ext_attri_algo,
                dpe.algo_id ext_col_algo,
                dpe.where_clause where_clause
         from   fnd_oam_ds_policy_elmnts pe,
                fnd_privacy_attributes_b pa,
                fnd_col_priv_attributes_b pc,
                fnd_tables t,
                fnd_columns c,
                fnd_oam_ds_pii_extensions dpe,
                fnd_oam_ds_pii_extensions dpe2,
                fnd_product_installations pi,
                fnd_oracle_userid ou
         where  pe.policy_id = v_policyid
         and    pe.element_type = 'PII_ATTRIBUTE'
         and    pe.privacy_attribute_code = pa.privacy_attribute_code
         and    pa.privacy_attribute_code = pc.privacy_attribute_code
         and    pc.application_id = t.application_id
         and    pc.table_id = t.table_id
         and    pc.application_id = c.application_id
         and    pc.table_id = c.table_id
         and    pc.column_id = c.column_id
         and    pc.privacy_attribute_code = dpe.privacy_attribute_code(+)
         and    pc.application_id = dpe.application_id(+)
         and    pc.table_id = dpe.table_id(+)
         and    pc.column_id = dpe.column_id(+)
         and    pc.privacy_attribute_code = dpe2.privacy_attribute_code(+)
         and    dpe2.table_id(+) IS NULL
         and    pc.application_id = pi.application_id
         and    pi.oracle_id = ou.oracle_id;
      attri_rec       policy_attri_c%ROWTYPE;

      --cursor to query deletes/truncates for a policy
      CURSOR policy_delete_c (v_policyid fnd_oam_ds_policies_b.policy_id%TYPE) IS
         select d.delete_id, d.owner, d.table_name, d.where_clause, d.use_truncate_flag
         from   fnd_oam_ds_deletes d, fnd_oam_ds_policy_elmnts pe
         where  pe.policy_id = v_policyid
         and    upper(pe.element_type) = 'DML_DELETE'
         and    d.delete_id = pe.delete_id;
      delete_rec       policy_delete_c%ROWTYPE;

      l_pset_id         NUMBER;
      l_algo_id         NUMBER;
      l_algo_text       VARCHAR2(4000);
      l_algo_weight     NUMBER;
      l_object_id       NUMBER;
   begin

      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --    pset_id := 3022;
      --    OPEN pset_policy_c(pset_id);

      fnd_oam_debug.log(1, l_ctxt, 'Obtaining Policy Set ID...');
      l_pset_id := FND_OAM_DSCFG_API_PKG.GET_CURRENT_POLICYSET_ID;

      fnd_oam_debug.log(1, l_ctxt, 'Querying Policies for Policy Set ID:'||l_pset_id);
      OPEN pset_policy_c(l_pset_id);

      --loop over the policies of the policy set
      LOOP
         FETCH pset_policy_c INTO policy_rec;
         EXIT WHEN pset_policy_c%NOTFOUND;
         fnd_oam_debug.log(1, l_ctxt, 'Processing Policy ID: '||policy_rec.policy_id);

         --fetch the PII_ATTRIBUTEs of the policy
         OPEN policy_attri_c(policy_rec.policy_id);

         LOOP
            --for each PII_ATTRIBUTE element,
            --if there is no attribute for this policy, exit this loop
            FETCH policy_attri_c INTO attri_rec;
            EXIT WHEN policy_attri_c%NOTFOUND;
            fnd_oam_debug.log(1, l_ctxt, 'Processing Attribute Code: '||attri_rec.privacy_attribute_code);

            --algo_id resolution is in the following order, higher is more specific:
            -- 1)fnd_oam_ds_pii_extensions for col_priv
            -- 2)fnd_col_priv_attributes_b
            -- 3)fnd_oam_ds_pii_extensions for attri (privacy_attribute_code set, table_id NULL)
            -- 3)fnd_privacy_attributes_b
            l_algo_id := NVL(attri_rec.ext_col_algo, NVL(attri_rec.col_algo, NVL(attri_rec.ext_attri_algo, attri_rec.attri_algo)));

            --if there is no algo id specified, use the default algo for this datatype
            IF l_algo_id IS NULL THEN
               fnd_oam_debug.log(1, l_ctxt, 'Fetching default algo for datatype: '||attri_rec.column_type);
               FND_OAM_DS_ALGOS_PKG.GET_DEFAULT_ALGO_FOR_DATATYPE(P_DATATYPE    => attri_rec.column_type,
                                                                  X_ALGO_ID     => l_algo_id);
            END IF;

            --convert the algo_id to the new_column_value sql
            fnd_oam_debug.log(1, l_ctxt, 'Resolving Algo ID: '||l_algo_id);
            FND_OAM_DS_ALGOS_PKG.RESOLVE_ALGO_ID(p_algo_id                => l_algo_id,
                                                 p_table_owner            => attri_rec.owner,
                                                 p_table_name             => attri_rec.table_name,
                                                 p_column_name            => attri_rec.column_name,
                                                 x_new_column_value       => l_algo_text,
                                                 X_WEIGHT_MODIFIER        => l_algo_weight);

            --add a dml_update_segment object to the intermediate config
            FND_OAM_DSCFG_API_PKG.ADD_DML_UPDATE_SEGMENT(P_TABLE_OWNER            => attri_rec.owner,
                                                         P_TABLE_NAME             => attri_rec.table_name,
                                                         P_COLUMN_NAME            => attri_rec.column_name,
                                                         P_NEW_COLUMN_VALUE       => l_algo_text,
                                                         P_WHERE_CLAUSE           => attri_rec.where_clause,
                                                         P_WEIGHT_MODIFIER        => l_algo_weight,
                                                         X_OBJECT_ID              => l_object_id);

         END LOOP;
         CLOSE policy_attri_c;

         -- query out the delete/truncate statements for the policy
         fnd_oam_debug.log(1, l_ctxt, 'Querying Deletes/Truncates for Policy...');
         OPEN policy_delete_c(policy_rec.policy_id);

         LOOP
            --for each DML_DELETE element
            --if there is no deletes for this policy, exit this loop
            FETCH policy_delete_c INTO delete_rec;
            EXIT WHEN policy_delete_c%NOTFOUND;
            fnd_oam_debug.log(1, l_ctxt, 'Processing Delete ID: '||delete_rec.delete_id);
            --see if the delete's a truncate
            IF delete_rec.use_truncate_flag IS NOT NULL AND delete_rec.USE_TRUNCATE_FLAG = FND_API.G_TRUE THEN
               FND_OAM_DSCFG_API_PKG.ADD_DML_TRUNCATE_STMT(P_TABLE_OWNER  => delete_rec.owner,
                                                           P_TABLE_NAME   => delete_rec.table_name,
                                                           x_object_id    => l_object_id);
            ELSE
               FND_OAM_DSCFG_API_PKG.ADD_DML_DELETE_STMT(P_TABLE_OWNER    => delete_rec.owner,
                                                         P_TABLE_NAME     => delete_rec.table_name,
                                                         P_WHERE_CLAUSE   => delete_rec.where_clause,
                                                         x_object_id      => l_object_id);
            END IF;

         END LOOP;
         CLOSE policy_delete_c;

         --commit after every policy
         COMMIT;

      END LOOP;
      CLOSE pset_policy_c;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         ROLLBACK;
         fnd_oam_debug.log(6, l_ctxt, 'Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         ROLLBACK;
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
 end;

end fnd_oam_dscram;

/
