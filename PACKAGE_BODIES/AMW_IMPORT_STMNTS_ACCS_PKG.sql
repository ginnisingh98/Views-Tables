--------------------------------------------------------
--  DDL for Package Body AMW_IMPORT_STMNTS_ACCS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_IMPORT_STMNTS_ACCS_PKG" AS
/* $Header: amwacimb.pls 120.0.12000000.3 2007/03/29 23:15:59 rjohnson ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMW_IMPORT_STMNTS_ACCS_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================
--G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMW_IMPORT_STMNTS_ACCS_PKG';
--G_FILE_NAME CONSTANT VARCHAR2(12) := amwacimb.pls';
 g_user_id              NUMBER        ;
 g_login_id             NUMBER        ;
 g_errbuf               VARCHAR2(2000);
 g_retcode              VARCHAR2(2)   ;
------------------ *************************************** -----------------------
PROCEDURE import_accounts(errbuf OUT NOCOPY  VARCHAR2,retcode OUT NOCOPY VARCHAR2)
is

begin
 declare
   m_fsg_or_not VARCHAR2(10);
   m_message VARCHAR2(2000) := null;

    begin
       g_errbuf      := null;
       g_retcode     :=  '0';
       g_user_id     := fnd_global.user_id;
       g_login_id    := fnd_global.conc_login_id;

     select fnd_profile.value('AMW_FIN_IMPORT_FROM_FSG') into m_fsg_or_not from dual;

     fnd_file.put_line(fnd_file.LOG,'AMW_FIN_IMPORT_FROM_FSG Profile Value' || m_fsg_or_not   );

     if  (m_fsg_or_not is null or upper(trim(m_fsg_or_not)) = 'Y' or upper(trim(m_fsg_or_not)) = 'YES') then
          IF check_account_value_set THEN
            AMW_IMPORT_STMNTS_ACCS_PKG.get_acc_from_oracle_apps;
          END IF;
     ELSE
           if AMW_IMPORT_STMNTS_ACCS_PKG.check_acc_profiles_has_value then
                AMW_IMPORT_STMNTS_ACCS_PKG.get_acc_from_external_apps;

           end if;
     END IF;
   end;

-- EXCEPTION WHEN OTHERS THEN
-- dbms_output.put_line(SQLERRM);
-- RAISE ;
-- RETURN;
  errbuf := g_errbuf    ;
  retcode := g_retcode;
 fnd_file.put_line(fnd_file.LOG,g_errbuf );


END import_accounts;
------------------------ ************************************* --------------------------
PROCEDURE import_statements(errbuf OUT NOCOPY  VARCHAR2, retcode OUT NOCOPY VARCHAR2,   P_RUN_ID in NUMBER)
is

begin
 declare
   m_fsg_or_not VARCHAR2(10);
   m_run_id number := P_RUN_ID;
   begin
       g_errbuf      := null;
       g_retcode     :=  '0';
       g_user_id     := fnd_global.user_id;
       g_login_id    := fnd_global.conc_login_id;


     select fnd_profile.value('AMW_FIN_IMPORT_FROM_FSG') into m_fsg_or_not from dual;
     fnd_file.put_line(fnd_file.LOG,'AMW_FIN_IMPORT_FROM_FSG Profile Value' || m_fsg_or_not   );

     if  (m_fsg_or_not is null or upper(trim(m_fsg_or_not)) = 'Y' or upper(trim(m_fsg_or_not)) = 'YES')  then

          if check_key_accounts_exists then
             IF check_account_value_set THEN
               AMW_IMPORT_STMNTS_ACCS_PKG.get_stmnts_from_oracle_apps(P_RUN_ID => m_run_id) ;
             end if;
           end if;

     ELSE
             if check_key_accounts_exists then
                if check_stmnt_profiles_has_value  then
                   AMW_IMPORT_STMNTS_ACCS_PKG.get_stmnts_from_external_apps(P_RUN_ID => m_run_id) ;
               end if;

            end if;
     END IF;
   end;
 errbuf := g_errbuf    ;
 retcode := g_retcode;
 fnd_file.put_line(fnd_file.LOG,g_errbuf );



END import_statements;
------------------------ ************************************* ---------------------------
PROCEDURE get_stmnts_from_external_apps(P_RUN_ID in NUMBER)  IS
begin
 declare

m_run_id number := P_RUN_ID;

M_ACCOUNT_GROUP_ID NUMBER;
M_NATURAL_ACCOUNT_ID NUMBER;
M_PARENT_FINANCIAL_ITEM_ID NUMBER;
M_STATEMENT_GROUP_ID                                 NUMBER;
M_FINANCIAL_STATEMENT_ID                             NUMBER;
M_END_DATE                                           DATE;
M_LAST_UPDATE_DATE                                   DATE;
M_LAST_UPDATED_BY                                    NUMBER;
M_LAST_UPDATE_LOGIN                                  NUMBER;
M_CREATION_DATE                                      DATE;
M_CREATED_BY                                         NUMBER;
M_ATTRIBUTE_CATEGORY                                 VARCHAR2(30);
M_ATTRIBUTE1                                         VARCHAR2(150);
M_ATTRIBUTE2                                         VARCHAR2(150);
M_ATTRIBUTE3                                         VARCHAR2(150);
M_ATTRIBUTE4                                         VARCHAR2(150);
M_ATTRIBUTE5                                         VARCHAR2(150);
M_ATTRIBUTE6                                         VARCHAR2(150);
M_ATTRIBUTE7                                         VARCHAR2(150);
M_ATTRIBUTE8                                         VARCHAR2(150);
M_ATTRIBUTE9                                         VARCHAR2(150);
M_ATTRIBUTE10                                        VARCHAR2(150);
M_ATTRIBUTE11                                        VARCHAR2(150);
M_ATTRIBUTE12                                        VARCHAR2(150);
M_ATTRIBUTE13                                        VARCHAR2(150);
M_ATTRIBUTE14                                        VARCHAR2(150);
M_ATTRIBUTE15                                        VARCHAR2(150);
M_SECURITY_GROUP_ID                                  NUMBER;
M_OBJECT_VERSION_NUMBER                              NUMBER;
M_FINANCIAL_ITEM_ID  NUMBER;
M_SEQUENCE_NUMBER NUMBER;

M_NAME  VARCHAR2(240);
M_LANGUAGE  VARCHAR2(4);
M_SOURCE_LANGUAGE  VARCHAR2(4);
M_OBJECT_TYPE VARCHAR2(10);
M_ORIG_SYSTEM_REFERENCE  VARCHAR2(150);

--- Section of code containg declaration of dynamic cursor based on profile for importing statemnts from external applications
sql_for_stmnt varchar2(2000):=
 'SELECT
    FINANCIAL_STATEMENT_ID
   from ' ||  fnd_profile.value('AMW_STMNT_SOURCE_VIEW')
    || ' where FINANCIAL_STATEMENT_ID in (select FINANCIAL_STATEMENT_ID from AMW_FIN_STMNT_SELECTION where run_id =' || to_char(P_RUN_ID) || ')';

TYPE statements_b IS RECORD (
FINANCIAL_STATEMENT_ID  NUMBER);
statements_b_record  statements_b ;

TYPE get_stmnt_cursor  IS ref CURSOR ;
Get_stmnt_from_external_apps get_stmnt_cursor  ;

--- Section of code containg declaration of dynamic cursor based on profile for importing financial iterms from external applications

sql_for_stmnt_item varchar2(2000):=
 'SELECT
       FINANCIAL_STATEMENT_ID,
       FINANCIAL_ITEM_ID,
       PARENT_FINANCIAL_ITEM_ID,
       SEQUENCE_NUMBER
   from ' ||  fnd_profile.value('AMW_FINITEM_SOURCE_VIEW')
       || ' where FINANCIAL_STATEMENT_ID in (select FINANCIAL_STATEMENT_ID from AMW_FIN_STMNT_SELECTION where run_id ='|| to_char(P_RUN_ID) || ')';


TYPE statement_item_b IS RECORD (
FINANCIAL_STATEMENT_ID                             NUMBER,
FINANCIAL_ITEM_ID                                  NUMBER,
PARENT_FINANCIAL_ITEM_ID                           NUMBER,
SEQUENCE_NUMBER                                    NUMBER);
statement_item_b_record  statement_item_b;


TYPE get_stmnt_item_cursor  IS ref CURSOR ;
Get_finitem_from_external_apps get_stmnt_item_cursor  ;

--- Section of code containg declaration of dynamic cursor based on profile for importing financial iterms and account relation from external applications

sql_for_acc_item varchar2(2000):=
 'SELECT
    FINANCIAL_STATEMENT_ID,
    FINANCIAL_ITEM_ID,
    NATURAL_ACCOUNT_ID
   from ' ||  fnd_profile.value('AMW_FIN_ITEM_ACC_RELATIONS_VIEW');

TYPE account_item_map_b IS RECORD (
FINANCIAL_STATEMENT_ID                             NUMBER,
FINANCIAL_ITEM_ID                                  NUMBER,
NATURAL_ACCOUNT_ID                                 NUMBER);
account_item_map_b_record  account_item_map_b ;

TYPE get_acc_item_cursor  IS ref CURSOR ;
Get_accitem_from_external_apps get_acc_item_cursor  ;

--- Section of code containg declaration of dynamic cursor based on profile for importing statement names/desc. from external applications

sql_for_stmnt_name varchar2(2000):=
   'SELECT
    FINANCIAL_STATEMENT_ID,
    NAME               ,
    LANGUAGE           ,
    SOURCE_LANGUAGE
  from ' ||  fnd_profile.value('AMW_STMNT_SOURCE_TL_VIEW');

TYPE statement_tl IS RECORD (
 FINANCIAL_STATEMENT_ID                             NUMBER,
 NAME                                               VARCHAR2(80),
 LANGUAGE                                           VARCHAR2(4),
 SOURCE_LANGUAGE                                    VARCHAR2(4)	);

statement_tl_record  statement_tl ;

TYPE get_stmntName_cursor  IS ref CURSOR ;
Get_stmnt_names_external_apps get_stmntName_cursor  ;

--- Section of code containg declaration of dynamic cursor based on profile for importing statement items names/desc. from external applications

sql_for_finitem_name varchar2(2000):=
   'SELECT
    FINANCIAL_STATEMENT_ID,
    FINANCIAL_ITEM_ID,
    NAME               ,
    LANGUAGE           ,
    SOURCE_LANGUAGE
  from ' ||  fnd_profile.value('AMW_FINITEM_SOURCE_TL_VIEW');

TYPE finitem_tl IS RECORD (
 FINANCIAL_STATEMENT_ID                             NUMBER,
 FINANCIAL_ITEM_ID                                  NUMBER,
 NAME                                               VARCHAR2(80),
 LANGUAGE                                           VARCHAR2(4),
 SOURCE_LANGUAGE                                    VARCHAR2(4)	);

finitem_tl_record  finitem_tl ;

TYPE get_FinItemName_cursor  IS ref CURSOR ;
Get_finitem_names_ext_apps get_FinItemName_cursor  ;

------------------ get account group id -----------------
cursor Get_acc_values_from_icm (P_NATURAL_ACCOUNT_ID  number)
is
SELECT
           distinct keyacc.ACCOUNT_GROUP_ID
           --, keyacc.NATURAL_ACCOUNT_ID
           --, NATURAL_ACCOUNT_VALUE
 from
  AMW_FIN_KEY_ACCOUNTS_B keyacc
WHERE  keyacc.End_Date is null
And   keyacc.NATURAL_ACCOUNT_ID = P_NATURAL_ACCOUNT_ID
and END_DATE is null
and ACCOUNT_GROUP_ID =
(select max(keyacc2.ACCOUNT_GROUP_ID) from AMW_FIN_KEY_ACCOUNTS_B keyacc2 where  keyacc2.End_Date is null) ;


 begin
    -- AMW_IMPORT_STMNTS_ACCS_PKG.end_date_stmnts_before_import(P_RUNID => m_run_id) ;
     select AMW_FIN_STMNT_S.nextval into M_STATEMENT_GROUP_ID from dual;

    open Get_stmnt_from_external_apps  for sql_for_stmnt ;
    loop
       fetch Get_stmnt_from_external_apps  into statements_b_record  ;
       exit when Get_stmnt_from_external_apps%notfound;

             M_FINANCIAL_STATEMENT_ID := statements_b_record.FINANCIAL_STATEMENT_ID;


          fnd_file.put_line(fnd_file.LOG, 'Processing STATEMENT_GROUP_ID =' || M_STATEMENT_GROUP_ID);
          fnd_file.put_line(fnd_file.LOG, 'Processing FINANCIAL_STATEMENT_ID =' || M_FINANCIAL_STATEMENT_ID );

                 AMW_IMPORT_STMNTS_ACCS_PKG.INSERT_STMNT_ROW (
                  X_STATEMENT_GROUP_ID  => M_STATEMENT_GROUP_ID,
                  X_FINANCIAL_STATEMENT_ID  => M_FINANCIAL_STATEMENT_ID ,
                  X_END_DATE   => NULL,
                  X_LAST_UPDATE_DATE => SYSDATE,
                  X_LAST_UPDATED_BY => g_user_id ,
                  X_LAST_UPDATE_LOGIN =>  g_login_id,
                  X_CREATION_DATE => SYSDATE,
                  X_CREATED_BY => g_user_id ,
                  X_ATTRIBUTE_CATEGORY => NULL,
                  X_ATTRIBUTE1 => NULL,
                  X_ATTRIBUTE2 => NULL,
                  X_ATTRIBUTE3 => NULL,
                  X_ATTRIBUTE4 => NULL,
                  X_ATTRIBUTE5 => NULL,
                  X_ATTRIBUTE6 => NULL,
                  X_ATTRIBUTE7 => NULL,
                  X_ATTRIBUTE8 => NULL,
                  X_ATTRIBUTE9 => NULL,
                  X_ATTRIBUTE10 => NULL,
                  X_ATTRIBUTE11 => NULL,
                  X_ATTRIBUTE12 => NULL,
                  X_ATTRIBUTE13 => NULL,
                  X_ATTRIBUTE14 => NULL,
                  X_ATTRIBUTE15 => NULL,
                  X_SECURITY_GROUP_ID => NULL,
                  X_OBJECT_VERSION_NUMBER => NULL);

     end loop;
     open Get_stmnt_names_external_apps for sql_for_stmnt_name ;
     loop
       fetch Get_stmnt_names_external_apps into statement_tl_record  ;
       exit when Get_stmnt_names_external_apps%notfound;

            M_FINANCIAL_STATEMENT_ID := statement_tl_record.FINANCIAL_STATEMENT_ID;
            M_NAME  :=  statement_tl_record.NAME;
            M_LANGUAGE  := statement_tl_record.LANGUAGE ;
            M_SOURCE_LANGUAGE  := statement_tl_record.SOURCE_LANGUAGE ;

            fnd_file.put_line(fnd_file.LOG, 'Processing TL Definition for STATEMENT_GROUP_ID =' || M_STATEMENT_GROUP_ID);
            fnd_file.put_line(fnd_file.LOG, 'Processing TL Definition for FINANCIAL_STATEMENT_ID =' || M_FINANCIAL_STATEMENT_ID );
            fnd_file.put_line(fnd_file.LOG, 'Processing TL Definition for FINANCIAL_STATEMENT_NAME   =' || M_NAME  );
            fnd_file.put_line(fnd_file.LOG, 'Processing TL Definition for LANGUAGE   =' || M_LANGUAGE  );


             AMW_IMPORT_STMNTS_ACCS_PKG.INSERT_STMNT_ROW_TL(
                                         X_STATEMENT_GROUP_ID  => M_STATEMENT_GROUP_ID,
                                         X_FINANCIAL_STATEMENT_ID  => M_FINANCIAL_STATEMENT_ID ,
                                         X_NAME => M_NAME,
                                         X_LANGUAGE => M_LANGUAGE,
                                         X_SOURCE_LANGUAGE => M_SOURCE_LANGUAGE ,
                                        -- X_OBJECT_TYPE ,
                                         X_SECURITY_GROUP_ID => M_SECURITY_GROUP_ID  ,
                                         X_OBJECT_VERSION_NUMBER => Null,
                                         X_ORIG_SYSTEM_REFERENCE => Null ,
                                         X_LAST_UPDATE_DATE => SYSDATE,
                                         X_LAST_UPDATED_BY => g_user_id ,
                                         X_LAST_UPDATE_LOGIN =>  g_login_id,
                                         X_CREATION_DATE => SYSDATE,
                                         X_CREATED_BY => g_user_id);

     end loop;

     open Get_finitem_from_external_apps for sql_for_stmnt_item ;
     loop
         fetch Get_finitem_from_external_apps into statement_item_b_record  ;
         exit when Get_finitem_from_external_apps%notfound;
          M_FINANCIAL_STATEMENT_ID := statement_item_b_record.FINANCIAL_STATEMENT_ID;
          M_FINANCIAL_ITEM_ID := statement_item_b_record.FINANCIAL_ITEM_ID;
          M_PARENT_FINANCIAL_ITEM_ID := statement_item_b_record.PARENT_FINANCIAL_ITEM_ID ;
          M_SEQUENCE_NUMBER := statement_item_b_record.SEQUENCE_NUMBER;

          fnd_file.put_line(fnd_file.LOG, 'Processing STATEMENT_GROUP_ID =' || M_STATEMENT_GROUP_ID);
          fnd_file.put_line(fnd_file.LOG, 'Processing FINANCIAL_STATEMENT_ID =' || M_FINANCIAL_STATEMENT_ID );
          fnd_file.put_line(fnd_file.LOG, 'Processing FINANCIAL_ITEM_ID =' || M_FINANCIAL_ITEM_ID );
          fnd_file.put_line(fnd_file.LOG, 'Processing PARENT_FINANCIAL_ITEM_ID =' || M_PARENT_FINANCIAL_ITEM_ID );



          AMW_IMPORT_STMNTS_ACCS_PKG.INSERT_FINITEM_ROW(
                  X_STATEMENT_GROUP_ID  => M_STATEMENT_GROUP_ID,
                  X_FINANCIAL_STATEMENT_ID  => M_FINANCIAL_STATEMENT_ID ,
                  X_FINANCIAL_ITEM_ID  => M_FINANCIAL_ITEM_ID ,
                  X_PARENT_FINANCIAL_ITEM_ID => M_PARENT_FINANCIAL_ITEM_ID ,
                  X_SEQUENCE_NUMBER  => M_SEQUENCE_NUMBER ,
                  X_LAST_UPDATE_DATE => SYSDATE,
                  X_LAST_UPDATED_BY => g_user_id ,
                  X_LAST_UPDATE_LOGIN =>  g_login_id,
                  X_CREATION_DATE => SYSDATE,
                  X_CREATED_BY => g_user_id ,
                  X_ATTRIBUTE_CATEGORY => NULL,
                  X_ATTRIBUTE1 => NULL,
                  X_ATTRIBUTE2 => NULL,
                  X_ATTRIBUTE3 => NULL,
                  X_ATTRIBUTE4 => NULL,
                  X_ATTRIBUTE5 => NULL,
                  X_ATTRIBUTE6 => NULL,
                  X_ATTRIBUTE7 => NULL,
                  X_ATTRIBUTE8 => NULL,
                  X_ATTRIBUTE9 => NULL,
                  X_ATTRIBUTE10 => NULL,
                  X_ATTRIBUTE11 => NULL,
                  X_ATTRIBUTE12 => NULL,
                  X_ATTRIBUTE13 => NULL,
                  X_ATTRIBUTE14 => NULL,
                  X_ATTRIBUTE15 => NULL,
                  X_SECURITY_GROUP_ID => NULL,
                  X_OBJECT_VERSION_NUMBER => NULL);


      end loop;
     open Get_finitem_names_ext_apps  for sql_for_finitem_name;
     loop
         fetch Get_finitem_names_ext_apps  into finitem_tl_record ;
         exit when Get_finitem_names_ext_apps%notfound;

            M_FINANCIAL_STATEMENT_ID := finitem_tl_record.FINANCIAL_STATEMENT_ID;
            M_FINANCIAL_ITEM_ID := finitem_tl_record.FINANCIAL_ITEM_ID;
            M_NAME  :=  finitem_tl_record.NAME;
            M_LANGUAGE  := finitem_tl_record.LANGUAGE ;
            M_SOURCE_LANGUAGE  := finitem_tl_record.SOURCE_LANGUAGE ;

          fnd_file.put_line(fnd_file.LOG, 'Processing STATEMENT_GROUP_ID =' || M_STATEMENT_GROUP_ID);
          fnd_file.put_line(fnd_file.LOG, 'Processing FINANCIAL_STATEMENT_ID =' || M_FINANCIAL_STATEMENT_ID );
          fnd_file.put_line(fnd_file.LOG, 'Processing FINANCIAL_ITEM_ID =' || M_FINANCIAL_ITEM_ID );
          fnd_file.put_line(fnd_file.LOG, 'Processing TL Definition for FINANCIAL_ITEM_NAME   =' || M_NAME  );
          fnd_file.put_line(fnd_file.LOG, 'Processing TL Definition for LANGUAGE   =' || M_LANGUAGE  );


             AMW_IMPORT_STMNTS_ACCS_PKG.INSERT_FINITEM_ROW_TL(
                                         X_STATEMENT_GROUP_ID  => M_STATEMENT_GROUP_ID,
                                         X_FINANCIAL_STATEMENT_ID  => M_FINANCIAL_STATEMENT_ID ,
                                         X_FINANCIAL_ITEM_ID  => M_FINANCIAL_ITEM_ID ,
                                         X_NAME => M_NAME,
                                         X_LANGUAGE => M_LANGUAGE,
                                         X_SOURCE_LANGUAGE => M_SOURCE_LANGUAGE ,
                                         X_SECURITY_GROUP_ID => M_SECURITY_GROUP_ID  ,
                                         X_OBJECT_VERSION_NUMBER => Null,
                                         X_ORIG_SYSTEM_REFERENCE => Null ,
                                         X_LAST_UPDATE_DATE => SYSDATE,
                                         X_LAST_UPDATED_BY => g_user_id ,
                                         X_LAST_UPDATE_LOGIN =>  g_login_id,
                                         X_CREATION_DATE => SYSDATE,
                                         X_CREATED_BY => g_user_id);

      end loop;

      open Get_accitem_from_external_apps for sql_for_acc_item ;
      loop
         fetch Get_accitem_from_external_apps into account_item_map_b_record  ;
         exit when Get_accitem_from_external_apps%notfound;

               -- M_ACCOUNT_GROUP_ID := get_acc_values.ACCOUNT_GROUP_ID;
               M_NATURAL_ACCOUNT_ID  := account_item_map_b_record.NATURAL_ACCOUNT_ID;
               M_FINANCIAL_STATEMENT_ID := account_item_map_b_record.FINANCIAL_STATEMENT_ID ;
               M_FINANCIAL_ITEM_ID := account_item_map_b_record.FINANCIAL_ITEM_ID  ;


               for get_account_id in Get_acc_values_from_icm(M_NATURAL_ACCOUNT_ID)
               loop
                exit when Get_acc_values_from_icm%notfound;
                    M_ACCOUNT_GROUP_ID := get_account_id.ACCOUNT_GROUP_ID;
               end loop;

               fnd_file.put_line(fnd_file.LOG, 'CALLING INSERT FINITEM_ACC_MAP FOR STATEMENT_GROUP_ID =' || M_STATEMENT_GROUP_ID);
               fnd_file.put_line(fnd_file.LOG, 'CALLING INSERT FINITEM_ACC_MAP FOR FINANCIAL_STATEMENT_ID =' || M_FINANCIAL_STATEMENT_ID );
               fnd_file.put_line(fnd_file.LOG, 'CALLING INSERT FINITEM_ACC_MAP FOR FINANCIAL_ITEM_ID =' || M_FINANCIAL_ITEM_ID );
               fnd_file.put_line(fnd_file.LOG, 'CALLING INSERT FINITEM_ACC_MAP FOR ACCOUNT_GROUP_ID=' || M_ACCOUNT_GROUP_ID);
               fnd_file.put_line(fnd_file.LOG, 'CALLING INSERT FINITEM_ACC_MAP FOR NATURAL_ACCOUNT_ID=' || M_NATURAL_ACCOUNT_ID);


               if (M_ACCOUNT_GROUP_ID is not null)     then
                      AMW_IMPORT_STMNTS_ACCS_PKG.INSERT_FINITEM_ACC_MAP(
                                   X_STATEMENT_GROUP_ID  => M_STATEMENT_GROUP_ID,
                                   X_ACCOUNT_GROUP_ID    => M_ACCOUNT_GROUP_ID ,
                                   X_FINANCIAL_STATEMENT_ID  => M_FINANCIAL_STATEMENT_ID ,
                                   X_FINANCIAL_ITEM_ID  => M_FINANCIAL_ITEM_ID ,
                                   X_NATURAL_ACCOUNT_ID =>M_NATURAL_ACCOUNT_ID ,
                                   X_LAST_UPDATE_DATE => SYSDATE,
                                   X_LAST_UPDATED_BY => g_user_id ,
                                   X_LAST_UPDATE_LOGIN =>  g_login_id,
                                   X_CREATION_DATE => SYSDATE,
                                   X_CREATED_BY => g_user_id ,
                                   X_ATTRIBUTE_CATEGORY => NULL,
                                   X_ATTRIBUTE1 => NULL,
                                   X_ATTRIBUTE2 => NULL,
                                   X_ATTRIBUTE3 => NULL,
                                   X_ATTRIBUTE4 => NULL,
                                   X_ATTRIBUTE5 => NULL,
                                   X_ATTRIBUTE6 => NULL,
                                   X_ATTRIBUTE7 => NULL,
                                   X_ATTRIBUTE8 => NULL,
                                   X_ATTRIBUTE9 => NULL,
                                   X_ATTRIBUTE10 => NULL,
                                   X_ATTRIBUTE11 => NULL,
                                   X_ATTRIBUTE12 => NULL,
                                   X_ATTRIBUTE13 => NULL,
                                   X_ATTRIBUTE14 => NULL,
                                   X_ATTRIBUTE15 => NULL,
                                   X_SECURITY_GROUP_ID => NULL,
                                   X_OBJECT_VERSION_NUMBER => NULL);
               end if;


       end loop;
         AMW_IMPORT_STMNTS_ACCS_PKG.end_date_stmnts_after_import(P_RUNID =>  m_run_id,
                 P_STATEMENT_GROUP_ID => M_STATEMENT_GROUP_ID) ;

          -- Sanket.
       amw_import_stmnts_accs_pkg.flatten_items ( x_group_id => m_statement_group_id );

       commit;
 end;
 EXCEPTION WHEN OTHERS THEN
 fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
-- dbms_output.put_line(SQLERRM);
 g_errbuf := SUBSTR (SQLERRM, 1, 2000)  ;
 g_retcode := '2';


 RAISE ;
 RETURN;


END get_stmnts_from_external_apps;

------------------------ ************************************* ---------------------------
PROCEDURE get_stmnts_from_oracle_apps(P_RUN_ID in NUMBER)  IS
begin
 declare

m_run_id number := P_RUN_ID;

M_PARENT_FINANCIAL_ITEM_ID                           NUMBER;
M_STATEMENT_GROUP_ID                                 NUMBER;
M_FINANCIAL_STATEMENT_ID                             NUMBER;
M_END_DATE                                           DATE;
M_LAST_UPDATE_DATE                                   DATE;
M_LAST_UPDATED_BY                                    NUMBER;
M_LAST_UPDATE_LOGIN                                  NUMBER;
M_CREATION_DATE                                      DATE;
M_CREATED_BY                                         NUMBER;
M_ATTRIBUTE_CATEGORY                                 VARCHAR2(30);
M_ATTRIBUTE1                                         VARCHAR2(150);
M_ATTRIBUTE2                                         VARCHAR2(150);
M_ATTRIBUTE3                                         VARCHAR2(150);
M_ATTRIBUTE4                                         VARCHAR2(150);
M_ATTRIBUTE5                                        VARCHAR2(150);
M_ATTRIBUTE6                                         VARCHAR2(150);
M_ATTRIBUTE7                                         VARCHAR2(150);
M_ATTRIBUTE8                                         VARCHAR2(150);
M_ATTRIBUTE9                                         VARCHAR2(150);
M_ATTRIBUTE10                                        VARCHAR2(150);
M_ATTRIBUTE11                                        VARCHAR2(150);
M_ATTRIBUTE12                                        VARCHAR2(150);
M_ATTRIBUTE13                                        VARCHAR2(150);
M_ATTRIBUTE14                                        VARCHAR2(150);
M_ATTRIBUTE15                                        VARCHAR2(150);
M_SECURITY_GROUP_ID                                  NUMBER;
M_OBJECT_VERSION_NUMBER                              NUMBER;
M_FINANCIAL_ITEM_ID  NUMBER;

  M_NAME  VARCHAR2(240);
  M_LANGUAGE  VARCHAR2(4);
  M_SOURCE_LANGUAGE  VARCHAR2(4);
  M_OBJECT_TYPE VARCHAR2(10);
  M_ORIG_SYSTEM_REFERENCE  VARCHAR2(150);

 cursor Get_statements_from_ora_gl
  is
 select
  FINANCIAL_STATEMENT_ID,
  NAME
 from
  AMW_STATEMENTS_V
 where FINANCIAL_STATEMENT_ID in (select FINANCIAL_STATEMENT_ID from AMW_FIN_STMNT_SELECTION where run_id = P_RUN_ID);


cursor Get_fin_items_from_ora_gl
  is
select
 FINANCIAL_STATEMENT_ID,
 FINANCIAL_ITEM_ID,
 NAME,
 trim(DESCRIPTION) DESCRIPTION,
 DISPLAY_FLAG,
 PARENT_FINANCIAL_ITEM_ID
from
 AMW_FINANCIAL_ITEMS_V
where FINANCIAL_STATEMENT_ID in (select FINANCIAL_STATEMENT_ID from AMW_FIN_STMNT_SELECTION where run_id = P_RUN_ID);

cursor Get_lang
  is
select
 LANGUAGE_CODE
from
 FND_LANGUAGES
where INSTALLED_FLAG in ('I', 'B');

 begin
  --  AMW_IMPORT_STMNTS_ACCS_PKG.end_date_stmnts_before_import(P_RUNID => m_run_id) ;
    select AMW_FIN_STMNT_S.nextval into M_STATEMENT_GROUP_ID from dual;

     for statements in Get_statements_from_ora_gl
     loop

       exit when Get_statements_from_ora_gl%notfound;
          M_FINANCIAL_STATEMENT_ID := statements.FINANCIAL_STATEMENT_ID;

          fnd_file.put_line(fnd_file.LOG, 'Processing STATEMENT_GROUP_ID = ' || M_STATEMENT_GROUP_ID);
          fnd_file.put_line(fnd_file.LOG, 'Processing FINANCIAL_STATEMENT_ID = ' || M_FINANCIAL_STATEMENT_ID);


          AMW_IMPORT_STMNTS_ACCS_PKG.INSERT_STMNT_ROW (
                  X_STATEMENT_GROUP_ID  => M_STATEMENT_GROUP_ID,
                  X_FINANCIAL_STATEMENT_ID  => M_FINANCIAL_STATEMENT_ID ,
                  X_END_DATE   => NULL,
                  X_LAST_UPDATE_DATE => SYSDATE,
                  X_LAST_UPDATED_BY => g_user_id ,
                  X_LAST_UPDATE_LOGIN =>  g_login_id,
                  X_CREATION_DATE => SYSDATE,
                  X_CREATED_BY => g_user_id ,
                  X_ATTRIBUTE_CATEGORY => NULL,
                  X_ATTRIBUTE1 => NULL,
                  X_ATTRIBUTE2 => NULL,
                  X_ATTRIBUTE3 => NULL,
                  X_ATTRIBUTE4 => NULL,
                  X_ATTRIBUTE5 => NULL,
                  X_ATTRIBUTE6 => NULL,
                  X_ATTRIBUTE7 => NULL,
                  X_ATTRIBUTE8 => NULL,
                  X_ATTRIBUTE9 => NULL,
                  X_ATTRIBUTE10 => NULL,
                  X_ATTRIBUTE11 => NULL,
                  X_ATTRIBUTE12 => NULL,
                  X_ATTRIBUTE13 => NULL,
                  X_ATTRIBUTE14 => NULL,
                  X_ATTRIBUTE15 => NULL,
                  X_SECURITY_GROUP_ID => NULL,
                  X_OBJECT_VERSION_NUMBER => NULL);

            M_NAME  :=  statements.NAME;
            M_SOURCE_LANGUAGE  := userenv('LANG');

            fnd_file.put_line(fnd_file.LOG, 'Processing TL Definition for STATEMENT_GROUP_ID = ' || M_STATEMENT_GROUP_ID);
            fnd_file.put_line(fnd_file.LOG, 'Processing TL Definition for FINANCIAL_STATEMENT_ID = ' || M_FINANCIAL_STATEMENT_ID);
            fnd_file.put_line(fnd_file.LOG, 'Processing TL Definition for FINANCIAL_STATEMENT_NAME = ' || M_NAME);

            for lang in Get_lang
            loop
              exit when Get_lang%notfound;
              M_LANGUAGE  := lang.LANGUAGE_CODE;
              fnd_file.put_line(fnd_file.LOG, 'Processing TL Definition for LANGUAGE = ' || M_LANGUAGE);

              AMW_IMPORT_STMNTS_ACCS_PKG.INSERT_STMNT_ROW_TL(
                X_STATEMENT_GROUP_ID      => M_STATEMENT_GROUP_ID,
                X_FINANCIAL_STATEMENT_ID  => M_FINANCIAL_STATEMENT_ID,
                X_NAME                    => M_NAME,
                X_LANGUAGE                => M_LANGUAGE,
                X_SOURCE_LANGUAGE         => M_SOURCE_LANGUAGE,
                -- X_OBJECT_TYPE ,
                X_SECURITY_GROUP_ID       => M_SECURITY_GROUP_ID,
                X_OBJECT_VERSION_NUMBER   => Null,
                X_ORIG_SYSTEM_REFERENCE   => Null,
                X_LAST_UPDATE_DATE        => SYSDATE,
                X_LAST_UPDATED_BY         => g_user_id ,
                X_LAST_UPDATE_LOGIN       => g_login_id,
                X_CREATION_DATE           => SYSDATE,
                X_CREATED_BY              => g_user_id);

            end loop;
     end loop;

     for fin_items in Get_fin_items_from_ora_gl
     loop

          exit when Get_fin_items_from_ora_gl%notfound;

          M_FINANCIAL_STATEMENT_ID := fin_items.FINANCIAL_STATEMENT_ID;
          M_FINANCIAL_ITEM_ID := fin_items.FINANCIAL_ITEM_ID;
          M_PARENT_FINANCIAL_ITEM_ID := fin_items.PARENT_FINANCIAL_ITEM_ID ;

          fnd_file.put_line(fnd_file.LOG, 'Processing STATEMENT_GROUP_ID = ' || M_STATEMENT_GROUP_ID);
          fnd_file.put_line(fnd_file.LOG, 'Processing FINANCIAL_STATEMENT_ID = ' || M_FINANCIAL_STATEMENT_ID);
          fnd_file.put_line(fnd_file.LOG, 'Processing FINANCIAL_ITEM_ID = ' || M_FINANCIAL_ITEM_ID);
          fnd_file.put_line(fnd_file.LOG, 'Processing PARENT_FINANCIAL_ITEM_ID = ' || M_PARENT_FINANCIAL_ITEM_ID);

          AMW_IMPORT_STMNTS_ACCS_PKG.INSERT_FINITEM_ROW(
                  X_STATEMENT_GROUP_ID  => M_STATEMENT_GROUP_ID,
                  X_FINANCIAL_STATEMENT_ID  => M_FINANCIAL_STATEMENT_ID ,
                  X_FINANCIAL_ITEM_ID  => M_FINANCIAL_ITEM_ID ,
                  X_PARENT_FINANCIAL_ITEM_ID    => M_PARENT_FINANCIAL_ITEM_ID,
                  X_SEQUENCE_NUMBER  => M_FINANCIAL_ITEM_ID ,
                  X_LAST_UPDATE_DATE => SYSDATE,
                  X_LAST_UPDATED_BY => g_user_id ,
                  X_LAST_UPDATE_LOGIN =>  g_login_id,
                  X_CREATION_DATE => SYSDATE,
                  X_CREATED_BY => g_user_id ,
                  X_ATTRIBUTE_CATEGORY => NULL,
                  X_ATTRIBUTE1 => NULL,
                  X_ATTRIBUTE2 => NULL,
                  X_ATTRIBUTE3 => NULL,
                  X_ATTRIBUTE4 => NULL,
                  X_ATTRIBUTE5 => NULL,
                  X_ATTRIBUTE6 => NULL,
                  X_ATTRIBUTE7 => NULL,
                  X_ATTRIBUTE8 => NULL,
                  X_ATTRIBUTE9 => NULL,
                  X_ATTRIBUTE10 => NULL,
                  X_ATTRIBUTE11 => NULL,
                  X_ATTRIBUTE12 => NULL,
                  X_ATTRIBUTE13 => NULL,
                  X_ATTRIBUTE14 => NULL,
                  X_ATTRIBUTE15 => NULL,
                  X_SECURITY_GROUP_ID => NULL,
                  X_OBJECT_VERSION_NUMBER => NULL);

          M_NAME  :=  fin_items.DESCRIPTION;
          M_SOURCE_LANGUAGE  := userenv('LANG');

          fnd_file.put_line(fnd_file.LOG, 'Processing STATEMENT_GROUP_ID = ' || M_STATEMENT_GROUP_ID);
          fnd_file.put_line(fnd_file.LOG, 'Processing FINANCIAL_STATEMENT_ID = ' || M_FINANCIAL_STATEMENT_ID);
          fnd_file.put_line(fnd_file.LOG, 'Processing FINANCIAL_ITEM_ID = ' || M_FINANCIAL_ITEM_ID);
          fnd_file.put_line(fnd_file.LOG, 'Processing TL Definition for FINANCIAL_ITEM_NAME = ' || M_NAME);

          for lang in Get_lang
          loop
            exit when Get_lang%notfound;
            M_LANGUAGE  := lang.LANGUAGE_CODE;
            fnd_file.put_line(fnd_file.LOG, 'Processing TL Definition for LANGUAGE = ' || M_LANGUAGE);

            AMW_IMPORT_STMNTS_ACCS_PKG.INSERT_FINITEM_ROW_TL(
                X_STATEMENT_GROUP_ID      => M_STATEMENT_GROUP_ID,
                X_FINANCIAL_STATEMENT_ID  => M_FINANCIAL_STATEMENT_ID,
                X_FINANCIAL_ITEM_ID       => M_FINANCIAL_ITEM_ID,
                X_NAME                    => M_NAME,
                X_LANGUAGE                => M_LANGUAGE,
                X_SOURCE_LANGUAGE         => M_SOURCE_LANGUAGE,
                X_SECURITY_GROUP_ID       => M_SECURITY_GROUP_ID,
                X_OBJECT_VERSION_NUMBER   => Null,
                X_ORIG_SYSTEM_REFERENCE   => Null,
                X_LAST_UPDATE_DATE        => SYSDATE,
                X_LAST_UPDATED_BY         => g_user_id,
                X_LAST_UPDATE_LOGIN       => g_login_id,
                X_CREATION_DATE           => SYSDATE,
                X_CREATED_BY              => g_user_id);

          end loop;
     end loop;

     AMW_IMPORT_STMNTS_ACCS_PKG.get_stmnts_accs_oracle_apps(P_RUN_ID =>m_run_id ,
                                  P_STATEMENT_GROUP_ID => M_STATEMENT_GROUP_ID);

     AMW_IMPORT_STMNTS_ACCS_PKG.end_date_stmnts_after_import(P_RUNID =>  m_run_id,
                 P_STATEMENT_GROUP_ID => M_STATEMENT_GROUP_ID) ;

      -- Sanket.
     amw_import_stmnts_accs_pkg.flatten_items ( x_group_id => m_statement_group_id );

     commit;
 end;

 EXCEPTION WHEN OTHERS THEN
 fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
-- dbms_output.put_line(SQLERRM);
 g_errbuf := SUBSTR (SQLERRM, 1, 2000)  ;
 g_retcode := '2';
 RAISE ;
 RETURN;

END get_stmnts_from_oracle_apps;
------------------------ ************************************* ---------------------------
PROCEDURE get_stmnts_accs_oracle_apps(P_RUN_ID in NUMBER, P_STATEMENT_GROUP_ID in NUMBER)
  IS
begin
 declare
m_run_id number := P_RUN_ID;
m_flex_value_set_id number;
default_value_set_id number;
M_CHART_OF_ACCOUNTS_ID   NUMBER;
M_SET_OF_BOOKS_ID NUMBER;
M_Low_Value  varchar2(60);
M_High_Value varchar2(60);

M_ACCOUNT_GROUP_ID NUMBER;
M_NATURAL_ACCOUNT_ID  NUMBER;
M_STATEMENT_GROUP_ID                                 NUMBER;
M_FINANCIAL_STATEMENT_ID                             NUMBER;
M_FINANCIAL_ITEM_ID                                  NUMBER;
M_END_DATE                                           DATE;
M_LAST_UPDATE_DATE                                   DATE;
M_LAST_UPDATED_BY                                    NUMBER;
M_LAST_UPDATE_LOGIN                                  NUMBER;
M_CREATION_DATE                                      DATE;
M_CREATED_BY                                         NUMBER;
M_ATTRIBUTE_CATEGORY                                 VARCHAR2(30);
M_ATTRIBUTE1                                         VARCHAR2(150);
M_ATTRIBUTE2                                         VARCHAR2(150);
M_ATTRIBUTE3                                         VARCHAR2(150);
M_ATTRIBUTE4                                         VARCHAR2(150);
M_ATTRIBUTE5                                         VARCHAR2(150);
M_ATTRIBUTE6                                         VARCHAR2(150);
M_ATTRIBUTE7                                         VARCHAR2(150);
M_ATTRIBUTE8                                         VARCHAR2(150);
M_ATTRIBUTE9                                         VARCHAR2(150);
M_ATTRIBUTE10                                        VARCHAR2(150);
M_ATTRIBUTE11                                        VARCHAR2(150);
M_ATTRIBUTE12                                        VARCHAR2(150);
M_ATTRIBUTE13                                        VARCHAR2(150);
M_ATTRIBUTE14                                        VARCHAR2(150);
M_ATTRIBUTE15                                        VARCHAR2(150);
M_SECURITY_GROUP_ID                                  NUMBER;
M_OBJECT_VERSION_NUMBER                              NUMBER;
M_DEFAULT_SETOFBOOKS_ID                              NUMBER;


cursor Get_acc_range_from_ora_gl  is
SELECT
FINANCIAL_STATEMENT_ID,
FINANCIAL_ITEM_ID     ,
SET_OF_BOOKS_ID       ,
SEGMENT1_LOW          ,
SEGMENT1_HIGH         ,
SEGMENT1_TYPE         ,
SEGMENT2_LOW          ,
SEGMENT2_HIGH         ,
SEGMENT2_TYPE         ,
SEGMENT3_LOW          ,
SEGMENT3_HIGH         ,
SEGMENT3_TYPE         ,
SEGMENT4_LOW          ,
SEGMENT4_HIGH         ,
SEGMENT4_TYPE         ,
SEGMENT5_LOW          ,
SEGMENT5_HIGH         ,
SEGMENT5_TYPE         ,
SEGMENT6_LOW          ,
SEGMENT6_HIGH         ,
SEGMENT6_TYPE         ,
SEGMENT7_LOW          ,
SEGMENT7_HIGH         ,
SEGMENT7_TYPE         ,
SEGMENT8_LOW          ,
SEGMENT8_HIGH         ,
SEGMENT8_TYPE         ,
SEGMENT9_LOW          ,
SEGMENT9_HIGH         ,
SEGMENT9_TYPE         ,
SEGMENT10_LOW         ,
SEGMENT10_HIGH        ,
SEGMENT10_TYPE        ,
SEGMENT11_LOW         ,
SEGMENT11_HIGH        ,
SEGMENT11_TYPE        ,
SEGMENT12_LOW         ,
SEGMENT12_HIGH        ,
SEGMENT12_TYPE        ,
SEGMENT13_LOW         ,
SEGMENT13_HIGH        ,
SEGMENT13_TYPE        ,
SEGMENT14_LOW         ,
SEGMENT14_HIGH        ,
SEGMENT14_TYPE        ,
SEGMENT15_LOW         ,
SEGMENT15_HIGH        ,
SEGMENT15_TYPE        ,
SEGMENT16_LOW         ,
SEGMENT16_HIGH        ,
SEGMENT16_TYPE        ,
SEGMENT17_LOW         ,
SEGMENT17_HIGH        ,
SEGMENT17_TYPE        ,
SEGMENT18_LOW         ,
SEGMENT18_HIGH        ,
SEGMENT18_TYPE        ,
SEGMENT19_LOW         ,
SEGMENT19_HIGH        ,
SEGMENT19_TYPE        ,
SEGMENT20_LOW         ,
SEGMENT20_HIGH        ,
SEGMENT20_TYPE        ,
SEGMENT21_LOW         ,
SEGMENT21_HIGH        ,
SEGMENT21_TYPE        ,
SEGMENT22_LOW         ,
SEGMENT22_HIGH        ,
SEGMENT22_TYPE        ,
SEGMENT23_LOW         ,
SEGMENT23_HIGH        ,
SEGMENT23_TYPE        ,
SEGMENT24_LOW         ,
SEGMENT24_HIGH        ,
SEGMENT24_TYPE        ,
SEGMENT25_LOW         ,
SEGMENT25_HIGH        ,
SEGMENT25_TYPE        ,
SEGMENT26_LOW         ,
SEGMENT26_HIGH        ,
SEGMENT26_TYPE        ,
SEGMENT27_LOW         ,
SEGMENT27_HIGH        ,
SEGMENT27_TYPE        ,
SEGMENT28_LOW         ,
SEGMENT28_HIGH        ,
SEGMENT28_TYPE        ,
SEGMENT29_LOW         ,
SEGMENT29_HIGH        ,
SEGMENT29_TYPE        ,
SEGMENT30_LOW         ,
SEGMENT30_HIGH        ,
SEGMENT30_TYPE
FROM
      AMW_FIN_ITEMS_ACCOUNT_RANGE_V
where  FINANCIAL_STATEMENT_ID
in (select FINANCIAL_STATEMENT_ID from AMW_FIN_STMNT_SELECTION where run_id = P_RUN_ID);

cursor Get_acc_range_column_ora_gl(P_CHART_OF_ACCOUNTS_ID number)  is
Select
      distinct v.APPLICATION_COLUMN_NAME ,
                  vs.flex_value_set_name, vs.description, vs.flex_value_set_id
from
    fnd_flex_value_sets vs, fnd_segment_attribute_Values v, fnd_id_flex_segments s
where
s.application_id=101 and s.id_flex_Code = 'GL#'
  and s.enabled_flag='Y'
 and v.application_id=s.application_id
  and v.id_flex_code=s.id_flex_code
  and v.id_flex_num=s.id_flex_num
  and v.application_column_name=s.application_column_name
  and v.segment_attribute_type='GL_ACCOUNT'
  and v.attribute_value='Y'
  and s.flex_value_set_id=vs.flex_value_set_id
  and v.id_flex_num= P_CHART_OF_ACCOUNTS_ID;

cursor Get_set_of_books_ora_gl(P_SET_OF_BOOKS_ID number)  is
Select
       CHART_OF_ACCOUNTS_ID
from
     GL_SETS_OF_BOOKS_V
Where
      SET_OF_BOOKS_ID= P_SET_OF_BOOKS_ID ;


cursor Get_acc_values_from_ora_gl (p_Low_Value  varchar2, p_High_Value varchar2 )
is
--(p_CHART_OF_ACCOUNTS_ID number)
SELECT
           distinct ACCOUNT_GROUP_ID , NATURAL_ACCOUNT_ID, NATURAL_ACCOUNT_VALUE
 from
AMW_FIN_KEY_ACCOUNTS_B
WHERE  End_Date is null
And   NATURAL_ACCOUNT_VALUE >= M_Low_Value
And NATURAL_ACCOUNT_VALUE <= M_High_Value
and END_DATE is null;



begin
     select fnd_profile.value('AMW_NATRL_ACCT_VALUE_SET') into default_value_set_id from dual ;

     fnd_file.put_line(fnd_file.LOG, 'Profile value AMW_NATRL_ACCT_VALUE_SET =' || default_value_set_id );

     select fnd_profile.value('GL_SET_OF_BKS_ID') into M_DEFAULT_SETOFBOOKS_ID from dual ;
     fnd_file.put_line(fnd_file.LOG, 'Profile value GL_SET_OF_BKS_ID (Default Set of Books)=' || M_DEFAULT_SETOFBOOKS_ID );



     for acc_range in Get_acc_range_from_ora_gl
     loop
       exit when Get_acc_range_from_ora_gl%notfound;
             M_STATEMENT_GROUP_ID  :=  P_STATEMENT_GROUP_ID;
             M_FINANCIAL_STATEMENT_ID :=  acc_range.FINANCIAL_STATEMENT_ID;
             M_FINANCIAL_ITEM_ID  := acc_range.FINANCIAL_ITEM_ID;

             M_SET_OF_BOOKS_ID  := acc_range.SET_OF_BOOKS_ID;

             if trim(M_SET_OF_BOOKS_ID)  is null then
                M_SET_OF_BOOKS_ID  := M_DEFAULT_SETOFBOOKS_ID;
                fnd_file.put_line(fnd_file.LOG, 'This Ros import will be using Default Set of Books Profile value GL_SET_OF_BKS_ID as the set of books in account range - row set definition is blank');

             end if;

          fnd_file.put_line(fnd_file.LOG, '---------------------------------------------------------------------');
          fnd_file.put_line(fnd_file.LOG, 'Processing STATEMENT_GROUP_ID =' || M_STATEMENT_GROUP_ID);
          fnd_file.put_line(fnd_file.LOG, 'Processing FINANCIAL_STATEMENT_ID =' || M_FINANCIAL_STATEMENT_ID );
          fnd_file.put_line(fnd_file.LOG, 'Processing FINANCIAL_ITEM_ID =' || M_FINANCIAL_ITEM_ID );
          fnd_file.put_line(fnd_file.LOG, 'Processing SET_OF_BOOKS_ID  =' || M_SET_OF_BOOKS_ID  );

            for chart_of_acc in Get_set_of_books_ora_gl(M_SET_OF_BOOKS_ID)
            loop
                exit when Get_set_of_books_ora_gl%notfound;

                M_CHART_OF_ACCOUNTS_ID   :=  chart_of_acc.CHART_OF_ACCOUNTS_ID;

                fnd_file.put_line(fnd_file.LOG, 'Processing M_CHART_OF_ACCOUNTS_ID     =' || M_CHART_OF_ACCOUNTS_ID);



                for acc_segment in Get_acc_range_column_ora_gl(M_CHART_OF_ACCOUNTS_ID)
                loop
                   exit when Get_acc_range_column_ora_gl%notfound;
                   --acc_segment  := acc_segment.APPLICATION_COLUMN_NAME;
                   m_flex_value_set_id := acc_segment.flex_value_set_id;

                   if m_flex_value_set_id <> default_value_set_id  then

                   FND_MESSAGE.SET_NAME ('AMW', 'AMW_STMNTS_NOT_IN_ACC_VAL_SET');
                   g_errbuf := FND_MESSAGE.GET_STRING('AMW', 'AMW_STMNTS_NOT_IN_ACC_VAL_SET');
                   --m_errMsg := FND_MESSAGE.GET_STRING('AMW', 'AMW_STMNTS_NOT_IN_ACC_VAL_SET');
                   g_retcode :='0';

                   fnd_file.put_line(fnd_file.LOG,'---------------------------!!!!!!!!!!!!---------------------------------');


                   fnd_file.put_line(fnd_file.LOG,g_errbuf );

                   fnd_file.put_line(fnd_file.LOG, 'WARNING: The Record with FINANCIAL_STATEMENT_ID (Row Set) =' || M_FINANCIAL_STATEMENT_ID  );
                   fnd_file.put_line(fnd_file.LOG, ' FINANCIAL_ITEM_ID (ROW ID) =' || M_FINANCIAL_ITEM_ID );
                   fnd_file.put_line(fnd_file.LOG, ' SET_OF_BOOKS_ID  =' || M_SET_OF_BOOKS_ID  );
                   fnd_file.put_line(fnd_file.LOG, ' M_CHART_OF_ACCOUNTS_ID   = ' || M_CHART_OF_ACCOUNTS_ID );
                   fnd_file.put_line(fnd_file.LOG, ' has a  Natural Value Set Id of ' || m_flex_value_set_id || ' which is different from ' || 'default_value_set_id');
                   fnd_file.put_line(fnd_file.LOG,'------------------------!!!!!!!!!!!!!!!!!!!!------------------------------------');



                   elsif m_flex_value_set_id = default_value_set_id  then


                      fnd_file.put_line(fnd_file.LOG, 'Natural Account Value Segment Column =' || acc_segment.APPLICATION_COLUMN_NAME );


                        if acc_segment.APPLICATION_COLUMN_NAME = 'SEGMENT1' then
                           M_Low_Value :=  acc_range.SEGMENT1_LOW   ;
                           M_High_Value := acc_range.SEGMENT1_HIGH  ;
                        elsif acc_segment.APPLICATION_COLUMN_NAME = 'SEGMENT2' then
                           M_Low_Value :=  acc_range.SEGMENT2_LOW   ;
                           M_High_Value := acc_range.SEGMENT2_HIGH  ;
                        elsif acc_segment.APPLICATION_COLUMN_NAME = 'SEGMENT3' then
                           M_Low_Value :=  acc_range.SEGMENT3_LOW   ;
                           M_High_Value := acc_range.SEGMENT3_HIGH  ;

                        elsif acc_segment.APPLICATION_COLUMN_NAME = 'SEGMENT4' then
                           M_Low_Value :=  acc_range.SEGMENT4_LOW   ;
                           M_High_Value := acc_range.SEGMENT4_HIGH  ;
                        elsif acc_segment.APPLICATION_COLUMN_NAME = 'SEGMENT5' then
                           M_Low_Value :=  acc_range.SEGMENT5_LOW   ;
                           M_High_Value := acc_range.SEGMENT5_HIGH  ;
                        elsif acc_segment.APPLICATION_COLUMN_NAME = 'SEGMENT6' then
                           M_Low_Value :=  acc_range.SEGMENT6_LOW   ;
                           M_High_Value := acc_range.SEGMENT6_HIGH  ;
                        elsif acc_segment.APPLICATION_COLUMN_NAME = 'SEGMENT7' then
                           M_Low_Value :=  acc_range.SEGMENT7_LOW   ;
                           M_High_Value := acc_range.SEGMENT7_HIGH  ;
                        elsif acc_segment.APPLICATION_COLUMN_NAME = 'SEGMENT8' then
                           M_Low_Value :=  acc_range.SEGMENT8_LOW   ;
                           M_High_Value := acc_range.SEGMENT8_HIGH  ;
                        elsif acc_segment.APPLICATION_COLUMN_NAME = 'SEGMENT9' then
                           M_Low_Value :=  acc_range.SEGMENT9_LOW   ;
                           M_High_Value := acc_range.SEGMENT9_HIGH  ;
                        elsif acc_segment.APPLICATION_COLUMN_NAME = 'SEGMENT10' then
                           M_Low_Value :=  acc_range.SEGMENT10_LOW   ;
                           M_High_Value := acc_range.SEGMENT10_HIGH  ;
                        elsif acc_segment.APPLICATION_COLUMN_NAME = 'SEGMENT11' then
                           M_Low_Value :=  acc_range.SEGMENT11_LOW   ;
                           M_High_Value := acc_range.SEGMENT11_HIGH  ;
                        elsif acc_segment.APPLICATION_COLUMN_NAME = 'SEGMENT12' then
                           M_Low_Value :=  acc_range.SEGMENT12_LOW   ;
                           M_High_Value := acc_range.SEGMENT12_HIGH  ;
                        elsif acc_segment.APPLICATION_COLUMN_NAME = 'SEGMENT13' then
                           M_Low_Value :=  acc_range.SEGMENT13_LOW   ;
                           M_High_Value := acc_range.SEGMENT13_HIGH  ;
                        elsif acc_segment.APPLICATION_COLUMN_NAME = 'SEGMENT14' then
                           M_Low_Value :=  acc_range.SEGMENT14_LOW   ;
                           M_High_Value := acc_range.SEGMENT14_HIGH  ;
                        elsif acc_segment.APPLICATION_COLUMN_NAME = 'SEGMENT15' then
                           M_Low_Value :=  acc_range.SEGMENT15_LOW   ;
                           M_High_Value := acc_range.SEGMENT15_HIGH  ;
                        elsif acc_segment.APPLICATION_COLUMN_NAME = 'SEGMENT16' then
                           M_Low_Value :=  acc_range.SEGMENT16_LOW   ;
                           M_High_Value := acc_range.SEGMENT16_HIGH  ;
                        elsif acc_segment.APPLICATION_COLUMN_NAME = 'SEGMENT17' then
                           M_Low_Value :=  acc_range.SEGMENT17_LOW   ;
                           M_High_Value := acc_range.SEGMENT17_HIGH  ;
                        elsif acc_segment.APPLICATION_COLUMN_NAME = 'SEGMENT18' then
                           M_Low_Value :=  acc_range.SEGMENT18_LOW   ;
                           M_High_Value := acc_range.SEGMENT18_HIGH  ;
                        elsif acc_segment.APPLICATION_COLUMN_NAME = 'SEGMENT19' then
                           M_Low_Value :=  acc_range.SEGMENT19_LOW   ;
                           M_High_Value := acc_range.SEGMENT19_HIGH  ;
                        elsif acc_segment.APPLICATION_COLUMN_NAME = 'SEGMENT20' then
                           M_Low_Value :=  acc_range.SEGMENT20_LOW   ;
                           M_High_Value := acc_range.SEGMENT20_HIGH  ;
                        elsif acc_segment.APPLICATION_COLUMN_NAME = 'SEGMENT21' then
                           M_Low_Value :=  acc_range.SEGMENT21_LOW   ;
                           M_High_Value := acc_range.SEGMENT21_HIGH  ;
                        elsif acc_segment.APPLICATION_COLUMN_NAME = 'SEGMENT22' then
                           M_Low_Value :=  acc_range.SEGMENT22_LOW   ;
                           M_High_Value := acc_range.SEGMENT22_HIGH  ;
                        elsif acc_segment.APPLICATION_COLUMN_NAME = 'SEGMENT23' then
                           M_Low_Value :=  acc_range.SEGMENT23_LOW   ;
                           M_High_Value := acc_range.SEGMENT23_HIGH  ;
                        elsif acc_segment.APPLICATION_COLUMN_NAME = 'SEGMENT24' then
                           M_Low_Value :=  acc_range.SEGMENT24_LOW   ;
                           M_High_Value := acc_range.SEGMENT24_HIGH  ;
                        elsif acc_segment.APPLICATION_COLUMN_NAME = 'SEGMENT25' then
                           M_Low_Value :=  acc_range.SEGMENT25_LOW   ;
                           M_High_Value := acc_range.SEGMENT25_HIGH  ;
                        elsif acc_segment.APPLICATION_COLUMN_NAME = 'SEGMENT26' then
                           M_Low_Value :=  acc_range.SEGMENT26_LOW   ;
                           M_High_Value := acc_range.SEGMENT26_HIGH  ;
                        elsif acc_segment.APPLICATION_COLUMN_NAME = 'SEGMENT27' then
                           M_Low_Value :=  acc_range.SEGMENT27_LOW   ;
                           M_High_Value := acc_range.SEGMENT27_HIGH  ;
                        elsif acc_segment.APPLICATION_COLUMN_NAME = 'SEGMENT28' then
                           M_Low_Value :=  acc_range.SEGMENT28_LOW   ;
                           M_High_Value := acc_range.SEGMENT28_HIGH  ;
                        elsif acc_segment.APPLICATION_COLUMN_NAME = 'SEGMENT29' then
                           M_Low_Value :=  acc_range.SEGMENT29_LOW   ;
                           M_High_Value := acc_range.SEGMENT29_HIGH  ;
                        elsif acc_segment.APPLICATION_COLUMN_NAME = 'SEGMENT30' then
                           M_Low_Value :=  acc_range.SEGMENT30_LOW   ;
                           M_High_Value := acc_range.SEGMENT30_HIGH  ;
                        end if;

                      -- M_Low_Value := acc_segment.APPLICATION_COLUMN_NAME || '_LOW';
                       --M_High_Value := acc_segment.APPLICATION_COLUMN_NAME || '_HIGH';

                      fnd_file.put_line(fnd_file.LOG, 'Processing Account Range Low Val=' || M_Low_Value );
                      fnd_file.put_line(fnd_file.LOG, 'Processing Account Range High Val=' || M_High_Value);


                      for get_acc_values in Get_acc_values_from_ora_gl(M_Low_Value , M_High_Value)
                      loop
                           exit when Get_acc_values_from_ora_gl%notfound;
                           M_ACCOUNT_GROUP_ID := get_acc_values.ACCOUNT_GROUP_ID;
                           M_NATURAL_ACCOUNT_ID  := get_acc_values.NATURAL_ACCOUNT_ID;

                           fnd_file.put_line(fnd_file.LOG, 'CALLING INSERT FINITEM_ACC_MAP FOR STATEMENT_GROUP_ID =' || M_STATEMENT_GROUP_ID);
                           fnd_file.put_line(fnd_file.LOG, 'CALLING INSERT FINITEM_ACC_MAP FOR FINANCIAL_STATEMENT_ID =' || M_FINANCIAL_STATEMENT_ID );
                           fnd_file.put_line(fnd_file.LOG, 'CALLING INSERT FINITEM_ACC_MAP FOR FINANCIAL_ITEM_ID =' || M_FINANCIAL_ITEM_ID );
                           fnd_file.put_line(fnd_file.LOG, 'CALLING INSERT FINITEM_ACC_MAP FOR ACCOUNT_GROUP_ID=' || M_ACCOUNT_GROUP_ID);
                           fnd_file.put_line(fnd_file.LOG, 'CALLING INSERT FINITEM_ACC_MAP FOR NATURAL_ACCOUNT_ID=' || M_NATURAL_ACCOUNT_ID);


                           AMW_IMPORT_STMNTS_ACCS_PKG.INSERT_FINITEM_ACC_MAP(
                                   X_STATEMENT_GROUP_ID  => M_STATEMENT_GROUP_ID,
                                   X_ACCOUNT_GROUP_ID    => M_ACCOUNT_GROUP_ID ,
                                   X_FINANCIAL_STATEMENT_ID  => M_FINANCIAL_STATEMENT_ID ,
                                   X_FINANCIAL_ITEM_ID  => M_FINANCIAL_ITEM_ID ,
                                   X_NATURAL_ACCOUNT_ID =>M_NATURAL_ACCOUNT_ID ,
                                   X_LAST_UPDATE_DATE => SYSDATE,
                                   X_LAST_UPDATED_BY => g_user_id ,
                                   X_LAST_UPDATE_LOGIN =>  g_login_id,
                                   X_CREATION_DATE => SYSDATE,
                                   X_CREATED_BY => g_user_id ,
                                   X_ATTRIBUTE_CATEGORY => NULL,
                                   X_ATTRIBUTE1 => NULL,
                                   X_ATTRIBUTE2 => NULL,
                                   X_ATTRIBUTE3 => NULL,
                                   X_ATTRIBUTE4 => NULL,
                                   X_ATTRIBUTE5 => NULL,
                                   X_ATTRIBUTE6 => NULL,
                                   X_ATTRIBUTE7 => NULL,
                                   X_ATTRIBUTE8 => NULL,
                                   X_ATTRIBUTE9 => NULL,
                                   X_ATTRIBUTE10 => NULL,
                                   X_ATTRIBUTE11 => NULL,
                                   X_ATTRIBUTE12 => NULL,
                                   X_ATTRIBUTE13 => NULL,
                                   X_ATTRIBUTE14 => NULL,
                                   X_ATTRIBUTE15 => NULL,
                                   X_SECURITY_GROUP_ID => NULL,
                                   X_OBJECT_VERSION_NUMBER => NULL);


                       end loop;

                   end if;

                end loop;

            end loop;


     end loop;

end;

 EXCEPTION WHEN OTHERS THEN
 fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
-- dbms_output.put_line(SQLERRM);
 g_errbuf := SUBSTR (SQLERRM, 1, 2000)  ;
 g_retcode := '2';

 RAISE ;
 RETURN;

END get_stmnts_accs_oracle_apps;

------------------------ ************************************* ---------------------------
PROCEDURE end_date_stmnts_after_import(P_RUNID NUMBER, P_STATEMENT_GROUP_ID NUMBER)IS
begin
 declare
  begin
   -- NOTE :- first update the end date if the statement structure is being re-imported and then if the end dated
   -- statements and associated records in other tables are not being used in any certifications delete them

    fnd_file.put_line(fnd_file.LOG, 'End Dating and Deleting Statements Imported previously and is also part of this import after Importing For Run ID=' || P_RUNID);


    update AMW_FIN_STMNT_B set end_date = sysdate
    where STATEMENT_GROUP_ID <> P_STATEMENT_GROUP_ID and
     FINANCIAL_STATEMENT_ID in (select FINANCIAL_STATEMENT_ID from AMW_FIN_STMNT_SELECTION where run_id = P_RUNID);

    delete AMW_FIN_STMNT_TL tl where exists(select base.STATEMENT_GROUP_ID, base.FINANCIAL_STATEMENT_ID
                   from AMW_FIN_STMNT_B base where base.STATEMENT_GROUP_ID= tl.STATEMENT_GROUP_ID
                   and  base.FINANCIAL_STATEMENT_ID = tl.FINANCIAL_STATEMENT_ID and base.end_date is not null
                   ) and  not exists (select cert.STATEMENT_GROUP_ID, cert.FINANCIAL_STATEMENT_ID
                   from amw_certification_b  cert where cert.STATEMENT_GROUP_ID= tl.STATEMENT_GROUP_ID
                   and  cert.FINANCIAL_STATEMENT_ID = tl.FINANCIAL_STATEMENT_ID and cert.OBJECT_TYPE =
                    'FIN_STMT');

     delete AMW_FIN_STMNT_ITEMS_TL tl where exists(select base.STATEMENT_GROUP_ID, base.FINANCIAL_STATEMENT_ID
                   from AMW_FIN_STMNT_B base where base.STATEMENT_GROUP_ID= tl.STATEMENT_GROUP_ID
                   and  base.FINANCIAL_STATEMENT_ID = tl.FINANCIAL_STATEMENT_ID and base.end_date is not null
                   ) and  not exists (select cert.STATEMENT_GROUP_ID, cert.FINANCIAL_STATEMENT_ID
                   from amw_certification_b  cert where cert.STATEMENT_GROUP_ID= tl.STATEMENT_GROUP_ID
                   and  cert.FINANCIAL_STATEMENT_ID = tl.FINANCIAL_STATEMENT_ID and cert.OBJECT_TYPE =
                    'FIN_STMT');

     delete AMW_FIN_STMNT_ITEMS_B tl where exists(select base.STATEMENT_GROUP_ID, base.FINANCIAL_STATEMENT_ID
                   from AMW_FIN_STMNT_B base where base.STATEMENT_GROUP_ID= tl.STATEMENT_GROUP_ID
                   and  base.FINANCIAL_STATEMENT_ID = tl.FINANCIAL_STATEMENT_ID and base.end_date is not null
                   ) and  not exists (select cert.STATEMENT_GROUP_ID, cert.FINANCIAL_STATEMENT_ID
                   from amw_certification_b  cert where cert.STATEMENT_GROUP_ID= tl.STATEMENT_GROUP_ID
                   and  cert.FINANCIAL_STATEMENT_ID = tl.FINANCIAL_STATEMENT_ID and cert.OBJECT_TYPE =
                    'FIN_STMT');

      delete AMW_FIN_ITEMS_KEY_ACC tl where exists(select base.STATEMENT_GROUP_ID, base.FINANCIAL_STATEMENT_ID
                   from AMW_FIN_STMNT_B base where base.STATEMENT_GROUP_ID= tl.STATEMENT_GROUP_ID
                   and  base.FINANCIAL_STATEMENT_ID = tl.FINANCIAL_STATEMENT_ID and base.end_date is not null
                   ) and  not exists (select cert.STATEMENT_GROUP_ID, cert.FINANCIAL_STATEMENT_ID
                   from amw_certification_b  cert where cert.STATEMENT_GROUP_ID= tl.STATEMENT_GROUP_ID
                   and  cert.FINANCIAL_STATEMENT_ID = tl.FINANCIAL_STATEMENT_ID and cert.OBJECT_TYPE =
                    'FIN_STMT');

   delete AMW_FIN_STMNT_B tl where  tl.end_date is not null
                   and  not exists (select cert.STATEMENT_GROUP_ID, cert.FINANCIAL_STATEMENT_ID
                   from amw_certification_b  cert where cert.STATEMENT_GROUP_ID= tl.STATEMENT_GROUP_ID
                   and  cert.FINANCIAL_STATEMENT_ID = tl.FINANCIAL_STATEMENT_ID and cert.OBJECT_TYPE =
                    'FIN_STMT');



   end;

 /* EXCEPTION WHEN OTHERS THEN

 fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
-- dbms_output.put_line(SQLERRM);
 g_errbuf := SUBSTR (SQLERRM, 1, 2000)  ;
 g_retcode := '2';
 RAISE ;
 RETURN;
*/
END end_date_stmnts_after_import;

------------------------ ************************************* ---------------------------

PROCEDURE get_acc_from_oracle_apps IS
begin
 declare

  m_acc_value_set_id number;

  M_ACCOUNT_GROUP_ID NUMBER;
  M_NATURAL_ACCOUNT_ID  NUMBER;
  M_NATURAL_ACCOUNT_VALUE  VARCHAR2(150);
  M_END_DATE  DATE;
  M_LAST_UPDATE_DATE  DATE;
  M_LAST_UPDATED_BY   NUMBER;
  M_LAST_UPDATE_LOGIN NUMBER;
  M_CREATION_DATE DATE;
  M_CREATED_BY  NUMBER;
  M_ATTRIBUTE_CATEGORY  VARCHAR2(30);
  M_ATTRIBUTE1  VARCHAR2(150);
  M_ATTRIBUTE2  VARCHAR2(150);
  M_ATTRIBUTE3  VARCHAR2(150);
  M_ATTRIBUTE4  VARCHAR2(150);
  M_ATTRIBUTE5  VARCHAR2(150);
  M_ATTRIBUTE6  VARCHAR2(150);
  M_ATTRIBUTE7  VARCHAR2(150);
  M_ATTRIBUTE8  VARCHAR2(150);
  M_ATTRIBUTE9  VARCHAR2(150);
  M_ATTRIBUTE10 VARCHAR2(150);
  M_ATTRIBUTE11 VARCHAR2(150);
  M_ATTRIBUTE12 VARCHAR2(150);
  M_ATTRIBUTE13 VARCHAR2(150);
  M_ATTRIBUTE14 VARCHAR2(150);
  M_ATTRIBUTE15 VARCHAR2(150);
  M_PARENT_NATURAL_ACCOUNT_ID NUMBER ;

  C_NATURAL_ACCOUNT_ID  NUMBER;
  C_NATURAL_ACCOUNT_VALUE  VARCHAR2(150);

  cursor Get_accounts_from_oraapps_gl
  (m_acc_value_set_id number)
  is
  SELECT
           FLEX_VALUE_ID, FLEX_VALUE, DESCRIPTION
  from
           fnd_flex_values_vl
-- 4872820 18-Oct-2006 Start-1
--WHERE  flex_value_set_id=  fnd_profile.value('AMW_NATRL_ACCT_VALUE_SET');
  WHERE FLEX_VALUE_SET_ID = m_acc_value_set_id AND ENABLED_FLAG = 'Y'
-- 4872820 18-Oct-2006 End-1
-- bug 5633695 modified by dliao on 12-18-2006
  AND (start_date_active IS NULL OR start_date_active <= SYSDATE)
  AND (end_date_active IS NULL OR end_date_active >= SYSDATE);

 -- m_default_value_set_id;


cursor Get_sub_acc_from_oraapps_gl
  (m_flex_value varchar2, m_acc_value_set_id number) is
select
 FLEX_VALUE_SET_ID ,
 PARENT_FLEX_VALUE, FLEX_VALUE as Child_Flex_Value
from
 FND_FLEX_VALUE_CHILDREN_V
Where
  FLEX_VALUE_SET_ID =  m_acc_value_set_id
and
PARENT_FLEX_VALUE =m_flex_value;


cursor Get_sub_acc_id_oraapps_gl
  (m_child_flex_value varchar2, m_acc_value_set_id number) is
SELECT
 FLEX_VALUE_ID, FLEX_VALUE, DESCRIPTION
 from
fnd_flex_values_vl where
FLEX_VALUE = m_child_flex_value
-- 4872820 18-Oct-2006 Start-2
-- and FLEX_VALUE_SET_ID =  fnd_profile.value('AMW_NATRL_ACCT_VALUE_SET');
AND FLEX_VALUE_SET_ID = m_acc_value_set_id AND ENABLED_FLAG = 'Y'
-- 4872820 18-Oct-2006 End-2
-- bug 5633695 modified by dliao on 12-18-2006
  AND (start_date_active IS NULL OR start_date_active <= SYSDATE)
  AND (end_date_active IS NULL OR end_date_active >= SYSDATE);


begin

    --update AMW_FIN_KEY_ACCOUNTS_B set end_date = sysdate;

     --fix bug 5926333
     m_acc_value_set_id := to_number(fnd_profile.value('AMW_NATRL_ACCT_VALUE_SET'));

    -- select fnd_profile.value('AMW_NATRL_ACCT_VALUE_SET') into m_acc_value_set_id from dual;
    select AMW_FIN_KEY_ACCOUNTS_S.nextval into M_ACCOUNT_GROUP_ID from dual;

    for accounts in Get_accounts_from_oraapps_gl(m_acc_value_set_id)
    loop

       exit when Get_accounts_from_oraapps_gl%notfound;

       M_NATURAL_ACCOUNT_ID :=  accounts.FLEX_VALUE_ID;
       M_NATURAL_ACCOUNT_VALUE := accounts.FLEX_VALUE ;
       M_PARENT_NATURAL_ACCOUNT_ID := NULL;

      fnd_file.put_line(fnd_file.LOG, '------------------get_acc_from_oracle_apps-------------');
      fnd_file.put_line(fnd_file.LOG, 'Processing ACCOUNT_GROUP_ID=' || M_ACCOUNT_GROUP_ID);
      fnd_file.put_line(fnd_file.LOG, 'Processing NATURAL_ACCOUNT_ID=' || M_NATURAL_ACCOUNT_ID);



       AMW_IMPORT_STMNTS_ACCS_PKG.INSERT_ROW(
                  X_ACCOUNT_GROUP_ID => M_ACCOUNT_GROUP_ID,
                  X_NATURAL_ACCOUNT_ID => M_NATURAL_ACCOUNT_ID,
                  X_NATURAL_ACCOUNT_VALUE => M_NATURAL_ACCOUNT_VALUE,
                  X_END_DATE => NULL,
                  X_LAST_UPDATE_DATE => SYSDATE,
                  X_LAST_UPDATED_BY => g_user_id ,
                  X_LAST_UPDATE_LOGIN =>  g_login_id,
                  X_CREATION_DATE => SYSDATE,
                  X_CREATED_BY => g_user_id ,
                  X_ATTRIBUTE_CATEGORY => NULL,
                  X_ATTRIBUTE1 => NULL,
                  X_ATTRIBUTE2 => NULL,
                  X_ATTRIBUTE3 => NULL,
                  X_ATTRIBUTE4 => NULL,
                  X_ATTRIBUTE5 => NULL,
                  X_ATTRIBUTE6 => NULL,
                  X_ATTRIBUTE7 => NULL,
                  X_ATTRIBUTE8 => NULL,
                  X_ATTRIBUTE9 => NULL,
                  X_ATTRIBUTE10 => NULL,
                  X_ATTRIBUTE11 => NULL,
                  X_ATTRIBUTE12 => NULL,
                  X_ATTRIBUTE13 => NULL,
                  X_ATTRIBUTE14 => NULL,
                  X_ATTRIBUTE15 => NULL,
                  X_PARENT_NATURAL_ACCOUNT_ID => NULL );

            AMW_IMPORT_STMNTS_ACCS_PKG.get_acc_name_from_oracle_apps( p_group_id => M_ACCOUNT_GROUP_ID
                                                     ,p_flex_value_id => M_NATURAL_ACCOUNT_ID);

       M_PARENT_NATURAL_ACCOUNT_ID := M_NATURAL_ACCOUNT_ID;
       for sub_accounts in Get_sub_acc_from_oraapps_gl(M_NATURAL_ACCOUNT_VALUE, m_acc_value_set_id)
       loop
              exit when Get_sub_acc_from_oraapps_gl%notfound;

           C_NATURAL_ACCOUNT_VALUE := sub_accounts.Child_Flex_Value;

           for sub_accounts_id in Get_sub_acc_id_oraapps_gl(C_NATURAL_ACCOUNT_VALUE, m_acc_value_set_id)
           loop
              exit when Get_sub_acc_id_oraapps_gl%notfound;

              C_NATURAL_ACCOUNT_ID :=  sub_accounts_id.FLEX_VALUE_ID;
           end loop;


         fnd_file.put_line(fnd_file.LOG, '------------------ Processing Account - Parent Child Relationship -------------');
         fnd_file.put_line(fnd_file.LOG, 'Processing ACCOUNT_GROUP_ID=' || M_ACCOUNT_GROUP_ID);
         fnd_file.put_line(fnd_file.LOG, 'Processing NATURAL_ACCOUNT_ID=' || M_NATURAL_ACCOUNT_ID);
         fnd_file.put_line(fnd_file.LOG, 'Processing PARENT_NATURAL_ACCOUNT_ID=' || M_PARENT_NATURAL_ACCOUNT_ID);



            AMW_IMPORT_STMNTS_ACCS_PKG.INSERT_ROW(
                  X_ACCOUNT_GROUP_ID => M_ACCOUNT_GROUP_ID,
                  X_NATURAL_ACCOUNT_ID => C_NATURAL_ACCOUNT_ID,
                  X_NATURAL_ACCOUNT_VALUE => C_NATURAL_ACCOUNT_VALUE ,
                  X_END_DATE => NULL,
                  X_LAST_UPDATE_DATE => SYSDATE,
                  X_LAST_UPDATED_BY => g_user_id ,
                  X_LAST_UPDATE_LOGIN =>  g_login_id,
                  X_CREATION_DATE => SYSDATE,
                  X_CREATED_BY => g_user_id ,
                  X_ATTRIBUTE_CATEGORY => NULL,
                  X_ATTRIBUTE1 => NULL,
                  X_ATTRIBUTE2 => NULL,
                  X_ATTRIBUTE3 => NULL,
                  X_ATTRIBUTE4 => NULL,
                  X_ATTRIBUTE5 => NULL,
                  X_ATTRIBUTE6 => NULL,
                  X_ATTRIBUTE7 => NULL,
                  X_ATTRIBUTE8 => NULL,
                  X_ATTRIBUTE9 => NULL,
                  X_ATTRIBUTE10 => NULL,
                  X_ATTRIBUTE11 => NULL,
                  X_ATTRIBUTE12 => NULL,
                  X_ATTRIBUTE13 => NULL,
                  X_ATTRIBUTE14 => NULL,
                  X_ATTRIBUTE15 => NULL,
                  X_PARENT_NATURAL_ACCOUNT_ID => M_PARENT_NATURAL_ACCOUNT_ID);

          --  AMW_IMPORT_STMNTS_ACCS_PKG.get_acc_name_from_oracle_apps( p_group_id => M_ACCOUNT_GROUP_ID ,p_flex_value_id => C_NATURAL_ACCOUNT_ID);

       end loop;

    end loop;
          update AMW_FIN_KEY_ACCOUNTS_B set end_date = sysdate
                   where  ACCOUNT_GROUP_ID<>M_ACCOUNT_GROUP_ID;

    -- Sanket.
    amw_import_stmnts_accs_pkg.flatten_accounts ( x_group_id => m_account_group_id );

    commit;
 END;
  EXCEPTION WHEN OTHERS THEN
 fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
-- dbms_output.put_line(SQLERRM);
 g_errbuf := SUBSTR (SQLERRM, 1, 2000)  ;
 g_retcode := '2';

 RAISE ;
 RETURN;

END get_acc_from_oracle_apps;
----------------------***************************************** -------------------------
PROCEDURE get_acc_name_from_oracle_apps(p_group_id in number, p_flex_value_id in number) IS
begin
 declare
  M_NAME  VARCHAR2(240);
  M_LANGUAGE  VARCHAR2(4);
  M_SOURCE_LANGUAGE  VARCHAR2(4);
  M_OBJECT_TYPE VARCHAR2(10);
  M_SECURITY_GROUP_ID NUMBER;
  M_OBJECT_VERSION_NUMBER  NUMBER;
  M_ORIG_SYSTEM_REFERENCE  VARCHAR2(150);

  P_ACCOUNT_GROUP_ID NUMBER :=p_group_id;
  P_NATURAL_ACCOUNT_ID  NUMBER := p_flex_value_id;

  cursor Get_acc_names_from_oraapps_gl
  (m_flex_value_id NUMBER)
  is
  Select
    FLEX_VALUE_ID,
    LANGUAGE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    SOURCE_LANG,
    FLEX_VALUE_MEANING
   -- SECURITY_GROUP_ID      commented as prd environments did not have this field
  from
    FND_FLEX_VALUES_TL
  where
  FLEX_VALUE_ID= m_flex_value_id;


 begin
       for accounts_tl in Get_acc_names_from_oraapps_gl(p_flex_value_id)
       loop

              exit when Get_acc_names_from_oraapps_gl%notfound;
                  -- accounts_tl.FLEX_VALUE_ID;
                  M_LANGUAGE := accounts_tl.LANGUAGE;
                  M_NAME := accounts_tl.DESCRIPTION;
                  M_SOURCE_LANGUAGE := accounts_tl.SOURCE_LANG;
                  M_SECURITY_GROUP_ID := null ; -- commented as prd environments did not have this field accounts_tl.SECURITY_GROUP_ID;

          fnd_file.put_line(fnd_file.LOG, '------------------ Get_acc_names_from_oraapps_gl -------------');
          fnd_file.put_line(fnd_file.LOG, 'Processing ACCOUNT_GROUP_ID=' || P_ACCOUNT_GROUP_ID);
          fnd_file.put_line(fnd_file.LOG, 'Processing NATURAL_ACCOUNT_ID=' || P_NATURAL_ACCOUNT_ID);
          fnd_file.put_line(fnd_file.LOG, 'Processing LANGUAGE=' || M_LANGUAGE);
          fnd_file.put_line(fnd_file.LOG, 'Processing NAME=' || M_NAME);


              AMW_IMPORT_STMNTS_ACCS_PKG.INSERT_ROW_TL(
                                         X_ACCOUNT_GROUP_ID => P_ACCOUNT_GROUP_ID,
                                         X_NATURAL_ACCOUNT_ID => P_NATURAL_ACCOUNT_ID,
                                         X_NAME => M_NAME,
                                         X_LANGUAGE => M_LANGUAGE,
                                         X_SOURCE_LANGUAGE => M_SOURCE_LANGUAGE ,
                                        -- X_OBJECT_TYPE ,
                                         X_SECURITY_GROUP_ID => M_SECURITY_GROUP_ID  ,
                                         X_OBJECT_VERSION_NUMBER => Null,
                                         X_ORIG_SYSTEM_REFERENCE => Null ,
                                         X_LAST_UPDATE_DATE => SYSDATE,
                                         X_LAST_UPDATED_BY => g_user_id ,
                                         X_LAST_UPDATE_LOGIN =>  g_login_id,
                                         X_CREATION_DATE => SYSDATE,
                                         X_CREATED_BY => g_user_id);
       end loop;


 END;
 EXCEPTION WHEN OTHERS THEN
 fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
-- dbms_output.put_line(SQLERRM);
 g_errbuf := SUBSTR (SQLERRM, 1, 2000)  ;
 g_retcode := '2';

 RAISE ;
 RETURN;

END get_acc_name_from_oracle_apps ;

------------------------ ************************************* --------------------------
PROCEDURE get_acc_from_external_apps IS
begin
 declare

  m_acc_value_set_id number;
  m_external_view_name VARCHAR2(150);

  M_ACCOUNT_GROUP_ID NUMBER;
  M_NATURAL_ACCOUNT_ID  NUMBER;
  M_NATURAL_ACCOUNT_VALUE  VARCHAR2(150);
  M_END_DATE  DATE;
  M_LAST_UPDATE_DATE  DATE;
  M_LAST_UPDATED_BY   NUMBER;
  M_LAST_UPDATE_LOGIN NUMBER;
  M_CREATION_DATE DATE;
  M_CREATED_BY  NUMBER;
  M_ATTRIBUTE_CATEGORY  VARCHAR2(30);
  M_ATTRIBUTE1  VARCHAR2(150);
  M_ATTRIBUTE2  VARCHAR2(150);
  M_ATTRIBUTE3  VARCHAR2(150);
  M_ATTRIBUTE4  VARCHAR2(150);
  M_ATTRIBUTE5  VARCHAR2(150);
  M_ATTRIBUTE6  VARCHAR2(150);
  M_ATTRIBUTE7  VARCHAR2(150);
  M_ATTRIBUTE8  VARCHAR2(150);
  M_ATTRIBUTE9  VARCHAR2(150);
  M_ATTRIBUTE10 VARCHAR2(150);
  M_ATTRIBUTE11 VARCHAR2(150);
  M_ATTRIBUTE12 VARCHAR2(150);
  M_ATTRIBUTE13 VARCHAR2(150);
  M_ATTRIBUTE14 VARCHAR2(150);
  M_ATTRIBUTE15 VARCHAR2(150);
  M_PARENT_NATURAL_ACCOUNT_ID NUMBER ;

  M_NAME  VARCHAR2(240);
  M_LANGUAGE  VARCHAR2(4);
  M_SOURCE_LANGUAGE  VARCHAR2(4);
  M_OBJECT_TYPE VARCHAR2(10);
  M_SECURITY_GROUP_ID NUMBER;
  M_OBJECT_VERSION_NUMBER  NUMBER;
  M_ORIG_SYSTEM_REFERENCE  VARCHAR2(150);


/* cursor Get_acc_from_external_apps
 (external_view_name VARCHAR2)
 is
*/

/* ---------- commented used for testing only can be removed
sql_for_acc varchar2(2000):=
   'SELECT
 NATURAL_ACCOUNT_ID,
 NATURAL_ACCOUNT_VALUE,
 PARENT_NATURAL_ACCOUNT_ID,
 ATTRIBUTE_CATEGORY,
 ATTRIBUTE1 ,
 ATTRIBUTE2 ,
 ATTRIBUTE3 ,
 ATTRIBUTE4 ,
 ATTRIBUTE5 ,
 ATTRIBUTE6 ,
 ATTRIBUTE7 ,
 ATTRIBUTE8 ,
 ATTRIBUTE9 ,
 ATTRIBUTE10,
 ATTRIBUTE11,
 ATTRIBUTE12,
 ATTRIBUTE13,
 ATTRIBUTE14,
 ATTRIBUTE15,
 SECURITY_GROUP_ID,
 OBJECT_VERSION_NUMBER
  from ' ||  fnd_profile.value('AMW_ACCOUNT_SOURCE_VIEW');
------------------------------------------------------
*/

 sql_for_acc varchar2(2000):=
   'SELECT
 NATURAL_ACCOUNT_ID,
 NATURAL_ACCOUNT_VALUE,
 PARENT_NATURAL_ACCOUNT_ID
 from ' ||  fnd_profile.value('AMW_ACCOUNT_SOURCE_VIEW') ;

TYPE accounts_b IS RECORD (
 NATURAL_ACCOUNT_ID                                 NUMBER,
 NATURAL_ACCOUNT_VALUE                              VARCHAR2(150),
 PARENT_NATURAL_ACCOUNT_ID                          NUMBER	);

--TYPE accounts_b_record IS TABLE OF
--SITE_RECORD;

accounts_b_record  accounts_b;

--accounts_b_record AMW_FIN_KEY_ACCOUNTS_B%rowtype;
TYPE get_acc_cursor  IS ref CURSOR ;
Get_acc_from_external_apps get_acc_cursor;


/*  cursor Get_acc_names_external_apps(external_view_name VARCHAR2) is

SELECT
*
 from
           DUAL;

*/

 sql_for_acc_name varchar2(2000):=
   'SELECT
  NATURAL_ACCOUNT_ID,
 NAME               ,
 LANGUAGE           ,
 SOURCE_LANGUAGE
   from ' ||  fnd_profile.value('AMW_ACCOUNT_NAMES_VIEW');

TYPE accounts_tl IS RECORD (
 NATURAL_ACCOUNT_ID                                 NUMBER,
 NAME                                               VARCHAR2(80),
 LANGUAGE                                           VARCHAR2(4),
 SOURCE_LANGUAGE                                    VARCHAR2(4)	);

accounts_tl_record  accounts_tl;

--accounts_tl_record AMW_FIN_KEY_ACCOUNTS_TL%rowtype;
TYPE get_accdesc_cursor  IS ref CURSOR ;
Get_acc_names_external_apps get_accdesc_cursor;


begin

    --update AMW_FIN_KEY_ACCOUNTS_B set end_date = sysdate;
    select AMW_FIN_KEY_ACCOUNTS_S.nextval into M_ACCOUNT_GROUP_ID from dual;


    open Get_acc_from_external_apps for sql_for_acc;
    loop
       fetch Get_acc_from_external_apps into accounts_b_record;
       exit when Get_acc_from_external_apps%notfound;

       M_NATURAL_ACCOUNT_ID:=  accounts_b_record.NATURAL_ACCOUNT_ID;
       M_NATURAL_ACCOUNT_VALUE := accounts_b_record.NATURAL_ACCOUNT_VALUE;
       M_PARENT_NATURAL_ACCOUNT_ID  := accounts_b_record.PARENT_NATURAL_ACCOUNT_ID;

         fnd_file.put_line(fnd_file.LOG, '------------------ Get_acc_from_external_apps -------------');
         fnd_file.put_line(fnd_file.LOG, 'Processing ACCOUNT_GROUP_ID=' || M_ACCOUNT_GROUP_ID);
         fnd_file.put_line(fnd_file.LOG, 'Processing NATURAL_ACCOUNT_ID=' || M_NATURAL_ACCOUNT_ID);
         fnd_file.put_line(fnd_file.LOG, 'Processing PARENT_NATURAL_ACCOUNT_ID=' || M_PARENT_NATURAL_ACCOUNT_ID);


       AMW_IMPORT_STMNTS_ACCS_PKG.INSERT_ROW(
                  X_ACCOUNT_GROUP_ID => M_ACCOUNT_GROUP_ID,
                  X_NATURAL_ACCOUNT_ID => M_NATURAL_ACCOUNT_ID,
                  X_NATURAL_ACCOUNT_VALUE => M_NATURAL_ACCOUNT_VALUE,
                  X_END_DATE => NULL,
                  X_LAST_UPDATE_DATE => SYSDATE,
                  X_LAST_UPDATED_BY => g_user_id ,
                  X_LAST_UPDATE_LOGIN =>  g_login_id,
                  X_CREATION_DATE => SYSDATE,
                  X_CREATED_BY => g_user_id ,
                  X_ATTRIBUTE_CATEGORY => NULL,
                  X_ATTRIBUTE1 => NULL,
                  X_ATTRIBUTE2 => NULL,
                  X_ATTRIBUTE3 => NULL,
                  X_ATTRIBUTE4 => NULL,
                  X_ATTRIBUTE5 => NULL,
                  X_ATTRIBUTE6 => NULL,
                  X_ATTRIBUTE7 => NULL,
                  X_ATTRIBUTE8 => NULL,
                  X_ATTRIBUTE9 => NULL,
                  X_ATTRIBUTE10 => NULL,
                  X_ATTRIBUTE11 => NULL,
                  X_ATTRIBUTE12 => NULL,
                  X_ATTRIBUTE13 => NULL,
                  X_ATTRIBUTE14 => NULL,
                  X_ATTRIBUTE15 => NULL,
                  X_PARENT_NATURAL_ACCOUNT_ID => M_PARENT_NATURAL_ACCOUNT_ID);

    end loop;

       open Get_acc_names_external_apps  for sql_for_acc_name;
       loop
            fetch Get_acc_names_external_apps into accounts_tl_record;
            exit when Get_acc_names_external_apps%notfound;

            M_NATURAL_ACCOUNT_ID:=  accounts_tl_record.NATURAL_ACCOUNT_ID;
            M_NAME  :=  accounts_tl_record.NAME;
            M_LANGUAGE  := accounts_tl_record.LANGUAGE;
            M_SOURCE_LANGUAGE  := accounts_tl_record.SOURCE_LANGUAGE;

          fnd_file.put_line(fnd_file.LOG, '------------------ Get_acc_names_external_apps -------------');
          fnd_file.put_line(fnd_file.LOG, 'Processing ACCOUNT_GROUP_ID=' || M_ACCOUNT_GROUP_ID);
          fnd_file.put_line(fnd_file.LOG, 'Processing NATURAL_ACCOUNT_ID=' || M_NATURAL_ACCOUNT_ID);
          fnd_file.put_line(fnd_file.LOG, 'Processing LANGUAGE=' || M_LANGUAGE);
          fnd_file.put_line(fnd_file.LOG, 'Processing NAME=' || M_NAME);



             AMW_IMPORT_STMNTS_ACCS_PKG.INSERT_ROW_TL(
                                         X_ACCOUNT_GROUP_ID => M_ACCOUNT_GROUP_ID,
                                         X_NATURAL_ACCOUNT_ID  => M_NATURAL_ACCOUNT_ID ,
                                         X_NAME => M_NAME,
                                         X_LANGUAGE => M_LANGUAGE,
                                         X_SOURCE_LANGUAGE => M_SOURCE_LANGUAGE ,
                                        -- X_OBJECT_TYPE ,
                                         X_SECURITY_GROUP_ID => M_SECURITY_GROUP_ID  ,
                                         X_OBJECT_VERSION_NUMBER => Null,
                                         X_ORIG_SYSTEM_REFERENCE => Null ,
                                         X_LAST_UPDATE_DATE => SYSDATE,
                                         X_LAST_UPDATED_BY => g_user_id ,
                                         X_LAST_UPDATE_LOGIN =>  g_login_id,
                                         X_CREATION_DATE => SYSDATE,
                                         X_CREATED_BY => g_user_id);

        end loop;
          update AMW_FIN_KEY_ACCOUNTS_B set end_date = sysdate
                   where  ACCOUNT_GROUP_ID<>M_ACCOUNT_GROUP_ID;


           -- Sanket.
        amw_import_stmnts_accs_pkg.flatten_accounts ( x_group_id => m_account_group_id );

        commit;
  END;

  EXCEPTION WHEN OTHERS THEN
  fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
-- dbms_output.put_line(SQLERRM);
  g_errbuf := SUBSTR (SQLERRM, 1, 2000)  ;
  g_retcode := '2';

 RAISE ;
 RETURN;

END get_acc_from_external_apps;

-------------------------------------------------------------------------------------
procedure INSERT_ROW (
  X_ACCOUNT_GROUP_ID in out NOCOPY NUMBER,
  X_NATURAL_ACCOUNT_ID in NUMBER,
  X_NATURAL_ACCOUNT_VALUE in VARCHAR2,
  X_END_DATE in DATE,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_CREATION_DATE IN DATE,
  X_CREATED_BY in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_PARENT_NATURAL_ACCOUNT_ID in NUMBER) is

--  cursor C is select NATURAL_ACCOUNT_ID from AMW_FIN_KEY_ACCOUNTS_B
--    where ACCOUNT_GROUP_ID = X_ACCOUNT_GROUP_ID;

var_NATURAL_ACCOUNT_ID number;

begin
select
      NATURAL_ACCOUNT_ID into var_NATURAL_ACCOUNT_ID
from AMW_FIN_KEY_ACCOUNTS_B
where ACCOUNT_GROUP_ID = X_ACCOUNT_GROUP_ID AND
     NATURAL_ACCOUNT_ID = X_NATURAL_ACCOUNT_ID AND
     NVL(PARENT_NATURAL_ACCOUNT_ID,-1)= NVL(X_PARENT_NATURAL_ACCOUNT_ID,-1);
EXCEPTION
WHEN NO_DATA_FOUND THEN

  insert into AMW_FIN_KEY_ACCOUNTS_B (
      ACCOUNT_GROUP_ID,
      NATURAL_ACCOUNT_ID,
      NATURAL_ACCOUNT_VALUE,
      END_DATE,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATION_DATE,
      CREATED_BY,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      PARENT_NATURAL_ACCOUNT_ID
  ) values (
X_ACCOUNT_GROUP_ID ,
  X_NATURAL_ACCOUNT_ID ,
  X_NATURAL_ACCOUNT_VALUE,
  X_END_DATE ,
  X_LAST_UPDATE_DATE ,
  X_LAST_UPDATED_BY ,
  X_LAST_UPDATE_LOGIN ,
  X_CREATION_DATE ,
  X_CREATED_BY ,
  X_ATTRIBUTE_CATEGORY,
  X_ATTRIBUTE1,
  X_ATTRIBUTE2,
  X_ATTRIBUTE3,
  X_ATTRIBUTE4,
  X_ATTRIBUTE5,
  X_ATTRIBUTE6,
  X_ATTRIBUTE7,
  X_ATTRIBUTE8,
  X_ATTRIBUTE9,
  X_ATTRIBUTE10,
  X_ATTRIBUTE11,
  X_ATTRIBUTE12,
  X_ATTRIBUTE13,
  X_ATTRIBUTE14,
  X_ATTRIBUTE15,
  X_PARENT_NATURAL_ACCOUNT_ID
  );

/*  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
*/
 WHEN OTHERS THEN
 fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
-- dbms_output.put_line(SQLERRM);
 fnd_file.put_line(fnd_file.LOG, 'ACCOUNT_GROUP_ID' || X_ACCOUNT_GROUP_ID  );
 fnd_file.put_line(fnd_file.LOG,  'NATURAL_ACCOUNT_ID ' || X_NATURAL_ACCOUNT_ID  );
 fnd_file.put_line(fnd_file.LOG,  'PARENT_NATURAL_ACCOUNT_ID' || X_PARENT_NATURAL_ACCOUNT_ID );

 g_errbuf := SUBSTR (SQLERRM, 1, 2000)  ;
 g_retcode := '2';

 RAISE ;
 RETURN;

end INSERT_ROW;
-----------------------------------------------------------------------------------------------------
procedure INSERT_ROW_TL (

  X_ACCOUNT_GROUP_ID in out NOCOPY NUMBER,
  X_NATURAL_ACCOUNT_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_LANGUAGE in VARCHAR2,
  X_SOURCE_LANGUAGE in VARCHAR2,
--  X_OBJECT_TYPE VARCHAR2,
  X_SECURITY_GROUP_ID  in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ORIG_SYSTEM_REFERENCE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_CREATION_DATE DATE,
  X_CREATED_BY in NUMBER
) is
--  cursor C is select NATURAL_ACCOUNT_ID from AMW_FIN_KEY_ACCOUNTS_TL
--    where ACCOUNT_GROUP_ID = X_ACCOUNT_GROUP_ID   ;
var_NATURAL_ACCOUNT_ID number;
begin

select
      NATURAL_ACCOUNT_ID into var_NATURAL_ACCOUNT_ID
from AMW_FIN_KEY_ACCOUNTS_TL
where ACCOUNT_GROUP_ID = X_ACCOUNT_GROUP_ID AND
      NATURAL_ACCOUNT_ID = X_NATURAL_ACCOUNT_ID AND
      LANGUAGE = X_LANGUAGE;
EXCEPTION
WHEN NO_DATA_FOUND THEN

  insert into AMW_FIN_KEY_ACCOUNTS_TL (
  ACCOUNT_GROUP_ID,
  NATURAL_ACCOUNT_ID,
  NAME,
  LANGUAGE,
  SOURCE_LANGUAGE,
  --OBJECT_TYPE
  CREATED_BY,
  CREATION_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_DATE,
  LAST_UPDATE_LOGIN,
  SECURITY_GROUP_ID,
  OBJECT_VERSION_NUMBER,
  SOURCE_LANG
--  ORIG_SYSTEM_REFERENCE
  ) values (
X_ACCOUNT_GROUP_ID,
X_NATURAL_ACCOUNT_ID,
X_NAME,
X_LANGUAGE,
X_SOURCE_LANGUAGE,
--X_OBJECT_TYPE,
X_CREATED_BY,
X_CREATION_DATE,
X_LAST_UPDATED_BY,
X_LAST_UPDATE_DATE,
X_LAST_UPDATE_LOGIN,
X_SECURITY_GROUP_ID,
X_OBJECT_VERSION_NUMBER,
X_SOURCE_LANGUAGE
--X_ORIG_SYSTEM_REFERENCE
--    userenv('LANG')
);
/*  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
*/
WHEN OTHERS THEN
 fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
-- dbms_output.put_line(SQLERRM);
 g_errbuf := SUBSTR (SQLERRM, 1, 2000)  ;
 g_retcode := '2';
 fnd_file.put_line(fnd_file.LOG, 'ACCOUNT_GROUP_ID=' || X_ACCOUNT_GROUP_ID  );
 fnd_file.put_line(fnd_file.LOG,  'NATURAL_ACCOUNT_ID=' || X_NATURAL_ACCOUNT_ID  );
 fnd_file.put_line(fnd_file.LOG,  'LANGUAGE=' || X_LANGUAGE);


 RAISE ;
 RETURN;

end INSERT_ROW_TL;
------------------------------------- ************************************ --------------------------------
procedure INSERT_STMNT_ROW (
X_STATEMENT_GROUP_ID         in      NUMBER,
X_FINANCIAL_STATEMENT_ID     in      NUMBER,
X_END_DATE                   in      DATE,
X_LAST_UPDATE_DATE           in      DATE,
X_LAST_UPDATED_BY            in      NUMBER,
X_LAST_UPDATE_LOGIN          in      NUMBER,
X_CREATION_DATE              in      DATE,
X_CREATED_BY                 in    NUMBER,
X_ATTRIBUTE_CATEGORY           in     VARCHAR2,
X_ATTRIBUTE1                   in             VARCHAR2,
X_ATTRIBUTE2                   in             VARCHAR2,
X_ATTRIBUTE3                   in             VARCHAR2,
X_ATTRIBUTE4                   in             VARCHAR2,
X_ATTRIBUTE5                   in             VARCHAR2,
X_ATTRIBUTE6                   in             VARCHAR2,
X_ATTRIBUTE7                   in             VARCHAR2,
X_ATTRIBUTE8                   in             VARCHAR2,
X_ATTRIBUTE9                   in             VARCHAR2,
X_ATTRIBUTE10                   in            VARCHAR2,
X_ATTRIBUTE11                   in            VARCHAR2,
X_ATTRIBUTE12                   in            VARCHAR2,
X_ATTRIBUTE13                   in            VARCHAR2,
X_ATTRIBUTE14                   in            VARCHAR2,
X_ATTRIBUTE15                   in            VARCHAR2,
X_SECURITY_GROUP_ID                   in      NUMBER,
X_OBJECT_VERSION_NUMBER                   in  NUMBER)
is

var_STATEMENT_ID number ;
begin

select
     FINANCIAL_STATEMENT_ID into var_STATEMENT_ID
from
   AMW_FIN_STMNT_B
where
 STATEMENT_GROUP_ID = X_STATEMENT_GROUP_ID and
 FINANCIAL_STATEMENT_ID = X_FINANCIAL_STATEMENT_ID;
EXCEPTION
WHEN NO_DATA_FOUND THEN
   insert into AMW_FIN_STMNT_B(
   STATEMENT_GROUP_ID,
   FINANCIAL_STATEMENT_ID,
   END_DATE              ,
   LAST_UPDATE_DATE      ,
   LAST_UPDATED_BY       ,
   LAST_UPDATE_LOGIN     ,
   CREATION_DATE         ,
   CREATED_BY            ,
   ATTRIBUTE_CATEGORY    ,
   ATTRIBUTE1            ,
   ATTRIBUTE2            ,
   ATTRIBUTE3            ,
   ATTRIBUTE4            ,
   ATTRIBUTE5            ,
   ATTRIBUTE6            ,
   ATTRIBUTE7            ,
   ATTRIBUTE8            ,
   ATTRIBUTE9            ,
   ATTRIBUTE10           ,
   ATTRIBUTE11           ,
   ATTRIBUTE12           ,
   ATTRIBUTE13           ,
   ATTRIBUTE14           ,
   ATTRIBUTE15           ,
   SECURITY_GROUP_ID     ,
   OBJECT_VERSION_NUMBER)
values
(
X_STATEMENT_GROUP_ID         ,
X_FINANCIAL_STATEMENT_ID     ,
X_END_DATE                   ,
X_LAST_UPDATE_DATE           ,
X_LAST_UPDATED_BY            ,
X_LAST_UPDATE_LOGIN          ,
X_CREATION_DATE              ,
X_CREATED_BY                 ,
X_ATTRIBUTE_CATEGORY         ,
X_ATTRIBUTE1                 ,
X_ATTRIBUTE2                 ,
X_ATTRIBUTE3                 ,
X_ATTRIBUTE4                 ,
X_ATTRIBUTE5                 ,
X_ATTRIBUTE6                 ,
X_ATTRIBUTE7                 ,
X_ATTRIBUTE8                 ,
X_ATTRIBUTE9                 ,
X_ATTRIBUTE10                ,
X_ATTRIBUTE11                ,
X_ATTRIBUTE12                ,
X_ATTRIBUTE13                ,
X_ATTRIBUTE14                ,
X_ATTRIBUTE15                ,
X_SECURITY_GROUP_ID          ,
X_OBJECT_VERSION_NUMBER );

WHEN OTHERS THEN
 fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
-- dbms_output.put_line(SQLERRM);
 g_errbuf := SUBSTR (SQLERRM, 1, 2000)  ;
 g_retcode := '2';
 fnd_file.put_line(fnd_file.LOG, 'STATEMENT_GROUP_ID =' || X_STATEMENT_GROUP_ID );
 fnd_file.put_line(fnd_file.LOG, 'FINANCIAL_STATEMENT_ID =' || X_FINANCIAL_STATEMENT_ID);

 RAISE ;
 RETURN;

END INSERT_STMNT_ROW;
--------------------------------------- ********************************************* ----------------------------
procedure INSERT_STMNT_ROW_TL (
  X_STATEMENT_GROUP_ID         in      NUMBER,
  X_FINANCIAL_STATEMENT_ID     in      NUMBER,
  X_NAME in VARCHAR2,
  X_LANGUAGE in VARCHAR2,
  X_SOURCE_LANGUAGE in VARCHAR2,
  X_SECURITY_GROUP_ID  in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ORIG_SYSTEM_REFERENCE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_CREATION_DATE DATE,
  X_CREATED_BY in NUMBER
) is
  --cursor C is select NATURAL_ACCOUNT_ID from AMW_FIN_KEY_ACCOUNTS_TL
   -- where ACCOUNT_GROUP_ID = X_ACCOUNT_GROUP_ID;

var_STATEMENT_ID number ;
begin
select
  FINANCIAL_STATEMENT_ID into var_STATEMENT_ID
from
AMW_FIN_STMNT_tl where
  STATEMENT_GROUP_ID =   X_STATEMENT_GROUP_ID  and
  FINANCIAL_STATEMENT_ID =  X_FINANCIAL_STATEMENT_ID     and
  LANGUAGE =X_LANGUAGE ;
EXCEPTION
WHEN NO_DATA_FOUND THEN

  insert into AMW_FIN_STMNT_tl(
  STATEMENT_GROUP_ID,
  FINANCIAL_STATEMENT_ID,
  NAME,
  LANGUAGE,
  SOURCE_LANGUAGE,
  CREATED_BY,
  CREATION_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_DATE,
  LAST_UPDATE_LOGIN,
  SECURITY_GROUP_ID,
  OBJECT_VERSION_NUMBER,
  SOURCE_LANG
  ) values (
X_STATEMENT_GROUP_ID         ,
X_FINANCIAL_STATEMENT_ID     ,
X_NAME,
X_LANGUAGE,
X_SOURCE_LANGUAGE,
X_CREATED_BY,
X_CREATION_DATE,
X_LAST_UPDATED_BY,
X_LAST_UPDATE_DATE,
X_LAST_UPDATE_LOGIN,
X_SECURITY_GROUP_ID,
X_OBJECT_VERSION_NUMBER,
X_SOURCE_LANGUAGE
--X_ORIG_SYSTEM_REFERENCE
--    userenv('LANG')
);
/*  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
*/
WHEN OTHERS THEN
 fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
-- dbms_output.put_line(SQLERRM);
 g_errbuf := SUBSTR (SQLERRM, 1, 2000)  ;
 g_retcode := '2';
 fnd_file.put_line(fnd_file.LOG, 'STATEMENT_GROUP_ID =' || X_STATEMENT_GROUP_ID );
 fnd_file.put_line(fnd_file.LOG, 'FINANCIAL_STATEMENT_ID =' || X_FINANCIAL_STATEMENT_ID);
 fnd_file.put_line(fnd_file.LOG,  'LANGUAGE=' || X_LANGUAGE);


 RAISE ;
 RETURN;

end INSERT_STMNT_ROW_TL;
------------------------------------- ************************************ --------------------------------
procedure INSERT_FINITEM_ROW (
X_STATEMENT_GROUP_ID         in            NUMBER,
X_FINANCIAL_STATEMENT_ID     in            NUMBER,
X_FINANCIAL_ITEM_ID          IN            NUMBER,
X_PARENT_FINANCIAL_ITEM_ID   IN            NUMBER,
X_SEQUENCE_NUMBER            in            NUMBER,
X_LAST_UPDATE_DATE           in            DATE,
X_LAST_UPDATED_BY            in            NUMBER,
X_LAST_UPDATE_LOGIN          in            NUMBER,
X_CREATION_DATE              in            DATE,
X_CREATED_BY                 in            NUMBER,
X_ATTRIBUTE_CATEGORY         in            VARCHAR2,
X_ATTRIBUTE1                 in            VARCHAR2,
X_ATTRIBUTE2                 in            VARCHAR2,
X_ATTRIBUTE3                 in            VARCHAR2,
X_ATTRIBUTE4                 in            VARCHAR2,
X_ATTRIBUTE5                 in            VARCHAR2,
X_ATTRIBUTE6                 in            VARCHAR2,
X_ATTRIBUTE7                 in            VARCHAR2,
X_ATTRIBUTE8                 in            VARCHAR2,
X_ATTRIBUTE9                 in            VARCHAR2,
X_ATTRIBUTE10                in            VARCHAR2,
X_ATTRIBUTE11                in            VARCHAR2,
X_ATTRIBUTE12                in            VARCHAR2,
X_ATTRIBUTE13                in            VARCHAR2,
X_ATTRIBUTE14                in            VARCHAR2,
X_ATTRIBUTE15                in            VARCHAR2,
X_SECURITY_GROUP_ID          in            NUMBER,
X_OBJECT_VERSION_NUMBER      in            NUMBER)
is
var_ITEM_ID number;
begin
select
     FINANCIAL_ITEM_ID INTO var_ITEM_ID
from
   AMW_FIN_STMNT_ITEMS_B
where
 STATEMENT_GROUP_ID = X_STATEMENT_GROUP_ID and
 FINANCIAL_STATEMENT_ID = X_FINANCIAL_STATEMENT_ID and
FINANCIAL_ITEM_ID = X_FINANCIAL_ITEM_ID and
nvl(PARENT_FINANCIAL_ITEM_ID,-1) = nvl(X_PARENT_FINANCIAL_ITEM_ID,-1);

EXCEPTION
WHEN NO_DATA_FOUND THEN

insert into AMW_FIN_STMNT_ITEMS_B(
STATEMENT_GROUP_ID,
FINANCIAL_STATEMENT_ID,
FINANCIAL_ITEM_ID,
PARENT_FINANCIAL_ITEM_ID,
SEQUENCE_NUMBER      ,
LAST_UPDATE_DATE      ,
LAST_UPDATED_BY       ,
LAST_UPDATE_LOGIN     ,
CREATION_DATE         ,
CREATED_BY            ,
ATTRIBUTE_CATEGORY    ,
ATTRIBUTE1            ,
ATTRIBUTE2            ,
ATTRIBUTE3            ,
ATTRIBUTE4            ,
ATTRIBUTE5            ,
ATTRIBUTE6            ,
ATTRIBUTE7            ,
ATTRIBUTE8            ,
ATTRIBUTE9            ,
ATTRIBUTE10           ,
ATTRIBUTE11           ,
ATTRIBUTE12           ,
ATTRIBUTE13           ,
ATTRIBUTE14           ,
ATTRIBUTE15           ,
SECURITY_GROUP_ID     ,
OBJECT_VERSION_NUMBER)
values
(
X_STATEMENT_GROUP_ID         ,
X_FINANCIAL_STATEMENT_ID     ,
X_FINANCIAL_ITEM_ID          ,
X_PARENT_FINANCIAL_ITEM_ID   ,
X_SEQUENCE_NUMBER            ,
X_LAST_UPDATE_DATE           ,
X_LAST_UPDATED_BY            ,
X_LAST_UPDATE_LOGIN          ,
X_CREATION_DATE              ,
X_CREATED_BY                 ,
X_ATTRIBUTE_CATEGORY         ,
X_ATTRIBUTE1                 ,
X_ATTRIBUTE2                 ,
X_ATTRIBUTE3                 ,
X_ATTRIBUTE4                 ,
X_ATTRIBUTE5                 ,
X_ATTRIBUTE6                 ,
X_ATTRIBUTE7                 ,
X_ATTRIBUTE8                 ,
X_ATTRIBUTE9                 ,
X_ATTRIBUTE10                ,
X_ATTRIBUTE11                ,
X_ATTRIBUTE12                ,
X_ATTRIBUTE13                ,
X_ATTRIBUTE14                ,
X_ATTRIBUTE15                ,
X_SECURITY_GROUP_ID          ,
X_OBJECT_VERSION_NUMBER );

 WHEN OTHERS THEN
 fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
-- dbms_output.put_line(SQLERRM);
 g_errbuf := SUBSTR (SQLERRM, 1, 2000)  ;
 g_retcode := '2';
 fnd_file.put_line(fnd_file.LOG, 'STATEMENT_GROUP_ID =' || X_STATEMENT_GROUP_ID );
 fnd_file.put_line(fnd_file.LOG, 'FINANCIAL_STATEMENT_ID =' || X_FINANCIAL_STATEMENT_ID);
 fnd_file.put_line(fnd_file.LOG,  'FINANCIAL_ITEM_ID=' || X_FINANCIAL_ITEM_ID);
 fnd_file.put_line(fnd_file.LOG,  'PARENT_FINANCIAL_ITEM_ID   =' || X_PARENT_FINANCIAL_ITEM_ID   );


 RAISE ;
 RETURN;

END INSERT_FINITEM_ROW ;
--------------------------------------- ********************************************* ----------------------------
procedure INSERT_FINITEM_ROW_TL (
  X_STATEMENT_GROUP_ID         in      NUMBER,
  X_FINANCIAL_STATEMENT_ID     in      NUMBER,
  X_FINANCIAL_ITEM_ID           IN      NUMBER,
  X_NAME in VARCHAR2,
  X_LANGUAGE in VARCHAR2,
  X_SOURCE_LANGUAGE in VARCHAR2,
  X_SECURITY_GROUP_ID  in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ORIG_SYSTEM_REFERENCE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_CREATION_DATE DATE,
  X_CREATED_BY in NUMBER
) is
  --cursor C is select NATURAL_ACCOUNT_ID from AMW_FIN_KEY_ACCOUNTS_TL
   -- where ACCOUNT_GROUP_ID = X_ACCOUNT_GROUP_ID;

var_ITEM_ID NUMBER;
begin

select  FINANCIAL_ITEM_ID   INTO var_ITEM_ID
from
   AMW_FIN_STMNT_ITEMS_tl
where
 STATEMENT_GROUP_ID = X_STATEMENT_GROUP_ID and
 FINANCIAL_STATEMENT_ID = X_FINANCIAL_STATEMENT_ID and
 FINANCIAL_ITEM_ID = X_FINANCIAL_ITEM_ID and
 LANGUAGE=X_LANGUAGE ;
EXCEPTION
WHEN NO_DATA_FOUND THEN

  insert into AMW_FIN_STMNT_ITEMS_TL(
  STATEMENT_GROUP_ID,
  FINANCIAL_STATEMENT_ID,
  FINANCIAL_ITEM_ID,
  NAME,
  LANGUAGE,
  SOURCE_LANGUAGE,
  CREATED_BY,
  CREATION_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_DATE,
  LAST_UPDATE_LOGIN,
  SECURITY_GROUP_ID,
  OBJECT_VERSION_NUMBER,
  SOURCE_LANG
  ) values (
X_STATEMENT_GROUP_ID         ,
X_FINANCIAL_STATEMENT_ID     ,
X_FINANCIAL_ITEM_ID         ,
X_NAME,
X_LANGUAGE,
X_SOURCE_LANGUAGE,
X_CREATED_BY,
X_CREATION_DATE,
X_LAST_UPDATED_BY,
X_LAST_UPDATE_DATE,
X_LAST_UPDATE_LOGIN,
X_SECURITY_GROUP_ID,
X_OBJECT_VERSION_NUMBER,
X_SOURCE_LANGUAGE
--X_ORIG_SYSTEM_REFERENCE
--    userenv('LANG')
);
/*  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
*/
  WHEN OTHERS THEN
 fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
-- dbms_output.put_line(SQLERRM);
 g_errbuf := SUBSTR (SQLERRM, 1, 2000)  ;
 g_retcode := '2';
 fnd_file.put_line(fnd_file.LOG, 'STATEMENT_GROUP_ID =' || X_STATEMENT_GROUP_ID );
 fnd_file.put_line(fnd_file.LOG, 'FINANCIAL_STATEMENT_ID =' || X_FINANCIAL_STATEMENT_ID);
 fnd_file.put_line(fnd_file.LOG,  'FINANCIAL_ITEM_ID=' || X_FINANCIAL_ITEM_ID);
 fnd_file.put_line(fnd_file.LOG,  'LANGUAGE=' || X_LANGUAGE);


 RAISE ;
 RETURN;

end INSERT_FINITEM_ROW_TL ;

---------------------------------------***************************************------------------------------
procedure INSERT_FINITEM_ACC_MAP (
X_STATEMENT_GROUP_ID         in      NUMBER,
X_ACCOUNT_GROUP_ID        in      NUMBER,
X_FINANCIAL_STATEMENT_ID     in      NUMBER,
X_FINANCIAL_ITEM_ID           IN      NUMBER,
X_NATURAL_ACCOUNT_ID     in      NUMBER,
X_LAST_UPDATE_DATE           in      DATE,
X_LAST_UPDATED_BY            in      NUMBER,
X_LAST_UPDATE_LOGIN          in      NUMBER,
X_CREATION_DATE              in      DATE,
X_CREATED_BY                 in    NUMBER,
X_ATTRIBUTE_CATEGORY           in     VARCHAR2,
X_ATTRIBUTE1                   in             VARCHAR2,
X_ATTRIBUTE2                   in             VARCHAR2,
X_ATTRIBUTE3                   in             VARCHAR2,
X_ATTRIBUTE4                   in             VARCHAR2,
X_ATTRIBUTE5                   in             VARCHAR2,
X_ATTRIBUTE6                   in             VARCHAR2,
X_ATTRIBUTE7                   in             VARCHAR2,
X_ATTRIBUTE8                   in             VARCHAR2,
X_ATTRIBUTE9                   in             VARCHAR2,
X_ATTRIBUTE10                   in            VARCHAR2,
X_ATTRIBUTE11                   in            VARCHAR2,
X_ATTRIBUTE12                   in            VARCHAR2,
X_ATTRIBUTE13                   in            VARCHAR2,
X_ATTRIBUTE14                   in            VARCHAR2,
X_ATTRIBUTE15                   in            VARCHAR2,
X_SECURITY_GROUP_ID                   in      NUMBER,
X_OBJECT_VERSION_NUMBER                   in  NUMBER)
is
begin
DECLARE
itmacc_count NUMBER :=0;

BEGIN
select count(1) into itmacc_count
from
 AMW_FIN_ITEMS_KEY_ACC
where
 STATEMENT_GROUP_ID =X_STATEMENT_GROUP_ID     and
 ACCOUNT_GROUP_ID  = X_ACCOUNT_GROUP_ID       and
 FINANCIAL_STATEMENT_ID = X_FINANCIAL_STATEMENT_ID  and
 FINANCIAL_ITEM_ID = X_FINANCIAL_ITEM_ID       and
 NATURAL_ACCOUNT_ID = X_NATURAL_ACCOUNT_ID        ;

 if itmacc_count <> 0 then

   fnd_file.put_line(fnd_file.LOG, 'Warning :- Duplicate Account '|| X_ACCOUNT_GROUP_ID   ||' found for Financial Item ' ||  X_FINANCIAL_ITEM_ID  || 'for Statement ' || X_STATEMENT_GROUP_ID    );

else -- if no recrods exists for the unique key
 insert into AMW_FIN_ITEMS_KEY_ACC(
STATEMENT_GROUP_ID,
ACCOUNT_GROUP_ID  ,
FINANCIAL_STATEMENT_ID,
FINANCIAL_ITEM_ID,
NATURAL_ACCOUNT_ID    ,
LAST_UPDATE_DATE      ,
LAST_UPDATED_BY       ,
LAST_UPDATE_LOGIN     ,
CREATION_DATE         ,
CREATED_BY            ,
ATTRIBUTE_CATEGORY    ,
ATTRIBUTE1            ,
ATTRIBUTE2            ,
ATTRIBUTE3            ,
ATTRIBUTE4            ,
ATTRIBUTE5            ,
ATTRIBUTE6            ,
ATTRIBUTE7            ,
ATTRIBUTE8            ,
ATTRIBUTE9            ,
ATTRIBUTE10           ,
ATTRIBUTE11           ,
ATTRIBUTE12           ,
ATTRIBUTE13           ,
ATTRIBUTE14           ,
ATTRIBUTE15           ,
SECURITY_GROUP_ID     ,
OBJECT_VERSION_NUMBER)
values
(
X_STATEMENT_GROUP_ID     ,
X_ACCOUNT_GROUP_ID       ,
X_FINANCIAL_STATEMENT_ID ,
X_FINANCIAL_ITEM_ID      ,
X_NATURAL_ACCOUNT_ID     ,
X_LAST_UPDATE_DATE           ,
X_LAST_UPDATED_BY            ,
X_LAST_UPDATE_LOGIN          ,
X_CREATION_DATE              ,
X_CREATED_BY                 ,
X_ATTRIBUTE_CATEGORY         ,
X_ATTRIBUTE1                 ,
X_ATTRIBUTE2                 ,
X_ATTRIBUTE3                 ,
X_ATTRIBUTE4                 ,
X_ATTRIBUTE5                 ,
X_ATTRIBUTE6                 ,
X_ATTRIBUTE7                 ,
X_ATTRIBUTE8                 ,
X_ATTRIBUTE9                 ,
X_ATTRIBUTE10                ,
X_ATTRIBUTE11                ,
X_ATTRIBUTE12                ,
X_ATTRIBUTE13                ,
X_ATTRIBUTE14                ,
X_ATTRIBUTE15                ,
X_SECURITY_GROUP_ID          ,
X_OBJECT_VERSION_NUMBER );
END IF;
end;
 EXCEPTION WHEN OTHERS THEN
 fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
-- dbms_output.put_line(SQLERRM);
 g_errbuf := SUBSTR (SQLERRM, 1, 2000)  ;
 g_retcode := '2';

 RAISE ;
 RETURN;

END INSERT_FINITEM_ACC_MAP;
--------------------------------------- ********************************************* ----------------------------
Function check_acc_profiles_has_value
return boolean is
begin
 declare
   M_AMW_ACCOUNT_SOURCE_VIEW varchar2(2000) := null;
   M_AMW_ACCOUNT_NAMES_VIEW  varchar2(2000) := null;
   m_errMsg varchar2(2000);

  begin
   select fnd_profile.value('AMW_ACCOUNT_SOURCE_VIEW') into  M_AMW_ACCOUNT_SOURCE_VIEW from dual;
   select fnd_profile.value('AMW_ACCOUNT_NAMES_VIEW' ) into  M_AMW_ACCOUNT_NAMES_VIEW   from dual;
   if  (trim(M_AMW_ACCOUNT_SOURCE_VIEW) is null) then

 --        FND_MESSAGE.SET_NAME ('AMW', 'AMW_FINIMPORT_PROFILE_NO_VALUE');

         FND_MESSAGE.SET_NAME ('AMW', 'AMW_ACCIMPORT_PROFILE_NO_VALUE');
         g_errbuf := FND_MESSAGE.GET_STRING('AMW', 'AMW_FINIMPORT_PROFILE_NO_VALUE');
         m_errMsg := FND_MESSAGE.GET_STRING('AMW', 'AMW_FINIMPORT_PROFILE_NO_VALUE');
         fnd_file.put_line(fnd_file.LOG,g_errbuf );

       -- fnd_file.put_line(fnd_file.LOG, SUBSTR ('Run Aborted. No value for Profile AMW_ACCOUNT_SOURCE_VIEW. Make sure that value exists for AMW_ACCOUNT_SOURCE_VIEW and AMW_ACCOUNT_NAMES_VIEW', 1, 200));
       -- g_errbuf := 'Run Aborted. No value for Profile AMW_ACCOUNT_SOURCE_VIEW. Make sure that value exists for AMW_ACCOUNT_SOURCE_VIEW and AMW_ACCOUNT_NAMES_VIEW';

         g_retcode := '2';

       return False;
   end if;
   if  (trim(M_AMW_ACCOUNT_SOURCE_VIEW) is null) then

         FND_MESSAGE.SET_NAME ('AMW', 'AMW_ACCIMPORT_PROFILE_NO_VALUE');
         g_errbuf := FND_MESSAGE.GET_STRING('AMW', 'AMW_FINIMPORT_PROFILE_NO_VALUE');
         m_errMsg := FND_MESSAGE.GET_STRING('AMW', 'AMW_FINIMPORT_PROFILE_NO_VALUE');
         fnd_file.put_line(fnd_file.LOG,g_errbuf );


    --    fnd_file.put_line(fnd_file.LOG, SUBSTR ('Run Aborted. No value for Profile AMW_ACCOUNT_NAMES_VIEW Make sure that value exists for AMW_ACCOUNT_SOURCE_VIEW and AMW_ACCOUNT_NAMES_VIEW', 1, 200));
    --    g_errbuf := 'Run Aborted. No value for Profile AMW_ACCOUNT_NAMES_VIEW Make sure that value exists for AMW_ACCOUNT_SOURCE_VIEW and AMW_ACCOUNT_NAMES_VIEW';
        g_retcode := '2';


        return False;
   end if;
  return True;
  end;

END check_acc_profiles_has_value;
--------------------------------------- ********************************************* ----------------------------
Function check_stmnt_profiles_has_value
return boolean is
begin
 declare

   M_AMW_STMNT_SOURCE_VIEW varchar2(2000) := null;
   M_AMW_FINITEM_SOURCE_VIEW  varchar2(2000) := null;
   M_AMW_FIN_ITEM_ACC_MAP_VIEW   varchar2(2000) := null;
   M_AMW_STMNT_SOURCE_TL_VIEW  varchar2(2000) := null;
   M_AMW_FINITEM_SOURCE_TL_VIEW  varchar2(2000) := null;

  begin
   select fnd_profile.value('AMW_STMNT_SOURCE_VIEW') into  M_AMW_STMNT_SOURCE_VIEW from dual;
   select fnd_profile.value('AMW_FINITEM_SOURCE_VIEW' ) into  M_AMW_FINITEM_SOURCE_VIEW from dual;
   select fnd_profile.value('AMW_FIN_ITEM_ACC_RELATIONS_VIEW' ) into  M_AMW_FIN_ITEM_ACC_MAP_VIEW   from dual;
   select fnd_profile.value('AMW_STMNT_SOURCE_TL_VIEW' ) into  M_AMW_STMNT_SOURCE_TL_VIEW  from dual;
   select fnd_profile.value('AMW_FINITEM_SOURCE_TL_VIEW' ) into  M_AMW_FINITEM_SOURCE_TL_VIEW  from dual;


   if  (trim(M_AMW_STMNT_SOURCE_VIEW)  is null) then

         FND_MESSAGE.SET_NAME ('AMW', 'AMW_FINIMPORT_PROFILE_NO_VALUE');
         g_errbuf := FND_MESSAGE.GET_STRING('AMW', 'AMW_FINIMPORT_PROFILE_NO_VALUE');
         fnd_file.put_line(fnd_file.LOG,g_errbuf );
         g_retcode := '2';

      /*   fnd_file.put_line(fnd_file.LOG, SUBSTR ('Run Aborted. No value for Profile AMW_STMNT_SOURCE_VIEW . Make sure that value exists for AMW_STMNT_SOURCE_VIEW', 1, 200));

         g_errbuf := 'Run Aborted. No value for Profile AMW_STMNT_SOURCE_VIEW . Make sure that value exists for AMW_STMNT_SOURCE_VIEW';
         g_retcode := '2';
       */
       return False;
   end if;
   if  (trim(M_AMW_FINITEM_SOURCE_VIEW)  is null) then

        FND_MESSAGE.SET_NAME ('AMW', 'AMW_FINIMPORT_PROFILE_NO_VALUE');
         g_errbuf := FND_MESSAGE.GET_STRING('AMW', 'AMW_FINIMPORT_PROFILE_NO_VALUE');
          fnd_file.put_line(fnd_file.LOG,g_errbuf );
         g_retcode := '2';


  /*      fnd_file.put_line(fnd_file.LOG, SUBSTR ('Run Aborted. No value for Profile AMW_FINITEM_SOURCE_VIEW. Make sure that value exists for AMW_FINITEM_SOURCE_VIEW ', 1, 200));
        g_errbuf := 'Run Aborted. No value for Profile AMW_FINITEM_SOURCE_VIEW. Make sure that value exists for AMW_FINITEM_SOURCE_VIEW ';
        g_retcode := '2';
  */
        return False;
   end if;

   if  (trim(M_AMW_FIN_ITEM_ACC_MAP_VIEW)   is null) then

        FND_MESSAGE.SET_NAME ('AMW', 'AMW_FINIMPORT_PROFILE_NO_VALUE');
         g_errbuf := FND_MESSAGE.GET_STRING('AMW', 'AMW_FINIMPORT_PROFILE_NO_VALUE');
          fnd_file.put_line(fnd_file.LOG,g_errbuf );
         g_retcode := '2';

        /*
        fnd_file.put_line(fnd_file.LOG, SUBSTR ('Run Aborted. No value for Profile AMW_FIN_ITEM_ACC_RELATIONS_VIEW. Make sure that value exists for AMW_FIN_ITEM_ACC_RELATIONS_VIEW ', 1, 200));
        g_errbuf := 'Run Aborted. No value for Profile AMW_FIN_ITEM_ACC_RELATIONS_VIEW. Make sure that value exists for AMW_FIN_ITEM_ACC_RELATIONS_VIEW ';
        g_retcode := '2';
        */
        return False;
   end if;
   if  (trim(M_AMW_STMNT_SOURCE_TL_VIEW)    is null) then

         FND_MESSAGE.SET_NAME ('AMW', 'AMW_FINIMPORT_PROFILE_NO_VALUE');
         g_errbuf := FND_MESSAGE.GET_STRING('AMW', 'AMW_FINIMPORT_PROFILE_NO_VALUE');
          fnd_file.put_line(fnd_file.LOG,g_errbuf );
         g_retcode := '2';

        /*
        fnd_file.put_line(fnd_file.LOG, SUBSTR ('Run Aborted. No value for Profile AMW_STMNT_SOURCE_TL_VIEW. Make sure that value exists for AMW_STMNT_SOURCE_TL_VIEW', 1, 200));
        g_errbuf := 'Run Aborted. No value for Profile AMW_STMNT_SOURCE_TL_VIEW. Make sure that value exists for AMW_STMNT_SOURCE_TL_VIEW';
        g_retcode := '2';
        */

        return False;
   end if;

   if  (trim(M_AMW_FINITEM_SOURCE_TL_VIEW)     is null) then

         FND_MESSAGE.SET_NAME ('AMW', 'AMW_FINIMPORT_PROFILE_NO_VALUE');
         g_errbuf := FND_MESSAGE.GET_STRING('AMW', 'AMW_FINIMPORT_PROFILE_NO_VALUE');
          fnd_file.put_line(fnd_file.LOG,g_errbuf );
         g_retcode := '2';

        /*
        fnd_file.put_line(fnd_file.LOG, SUBSTR ('Run Aborted. No value for Profile AMW_FINITEM_SOURCE_TL_VIEW. Make sure that value exists for AMW_FINITEM_SOURCE_TL_VIEW', 1, 200));
        g_errbuf := 'Run Aborted. No value for Profile AMW_FINITEM_SOURCE_TL_VIEW. Make sure that value exists for AMW_FINITEM_SOURCE_TL_VIEW';
        g_retcode := '2';
        */

        return False;
   end if;

  return True;
  end;

END check_stmnt_profiles_has_value;
--------------------------------------- ********************************************* ----------------------------

Function check_key_accounts_exists
return boolean is
begin
 declare

 m_errMsg varchar2(2000);
 M_acct_count number := 0;
 begin
   select count(account_group_id) into  M_acct_count from  amw_fin_key_Accounts_b where  END_DATE is null;

   if  M_acct_count = 0 then
       FND_MESSAGE.SET_NAME ('AMW', 'AMW_KEY_ACCOUNTS_NOT_IMPORTED');
       g_errbuf := FND_MESSAGE.GET_STRING('AMW', 'AMW_KEY_ACCOUNTS_NOT_IMPORTED');
       --m_errMsg := FND_MESSAGE.GET_STRING('AMW', 'AMW_KEY_ACCOUNTS_NOT_IMPORTED');
       g_retcode :=2;
       fnd_file.put_line(fnd_file.LOG,g_errbuf );
       return False;
   end if;
   return True;
 end;

END check_key_accounts_exists;
-------------------------------------------------------------------------------------------------------------------
Function check_account_value_set
return boolean is
begin
 declare

 acc_value_set_id number := NULL;
 begin
     select fnd_profile.value('AMW_NATRL_ACCT_VALUE_SET') into acc_value_set_id from dual ;

   if  acc_value_set_id IS NULL then
       FND_MESSAGE.SET_NAME ('AMW', 'AMW_ACCT_VALUE_SET_NOT_DEFINED');
       g_errbuf := FND_MESSAGE.GET_STRING('AMW', 'AMW_ACCT_VALUE_SET_NOT_DEFINED');
       --m_errMsg := FND_MESSAGE.GET_STRING('AMW', 'AMW_ACCT_VALUE_SET_NOT_DEFINED');
       g_retcode :=2;
       fnd_file.put_line(fnd_file.LOG,g_errbuf );
       return False;
   end if;
   return True;
 end;

END check_account_value_set;

-------------------------------------------------------------------------
-- Procedure that flattens the accounts table (Sanket).
--
-- For every parent - child relationship in amw_fin_key_accounts_b table,
-- we insert one record in the flat table. This implies that given a
-- particular account group id g, for a root
-- account id x, we will not have a row in the flat table with child =
-- x. Similarly, for a leaf acct y, we will not have a row with parent =
-- y. A standalone acct id z (a node with no parent or children) will not
-- appear in the flat table.
-------------------------------------------------------------------------

procedure flatten_accounts ( x_group_id in number ) is

    cursor acct_cursor is
        select distinct natural_account_id acct_id, account_group_id group_id
        from amw_fin_key_accounts_b
        where account_group_id = x_group_id ;

    cursor nested_cursor ( p_acct_id number, p_group_id number ) is

        select  p_acct_id parent_id,
        acct.natural_account_id child_id,
        acct.account_group_id group_id
        from AMW_FIN_KEY_ACCOUNTS_B acct
        start with account_group_id = p_group_id
        and parent_natural_account_id = p_acct_id
        connect by prior natural_account_id = parent_natural_account_id
        and account_group_id = p_group_id;

begin

    g_user_id := fnd_global.user_id;
    g_login_id := fnd_global.conc_login_id;

    for acct_rec in acct_cursor loop

	for nested_rec in nested_cursor ( acct_rec.acct_id, acct_rec.group_id ) loop
	    insert into amw_fin_key_acct_flat
                ( parent_natural_account_id,
                  child_natural_account_id,
                  account_group_id,
                  CREATED_BY,
                  CREATION_DATE,
                  LAST_UPDATED_BY,
                  LAST_UPDATE_DATE,
                  LAST_UPDATE_LOGIN,
                  SECURITY_GROUP_ID,
                  OBJECT_VERSION_NUMBER
                )
            values
		( nested_rec.parent_id,
		  nested_rec.child_id,
		  nested_rec.group_id,
		  g_user_id,
		  sysdate,
		  g_user_id,
		  sysdate,
		  g_login_id,
		  null,
		  null
		);
        end loop;

    end loop;

end flatten_accounts;

-------------------------------------------------------------------------
-- Procedure that flattens the items table (Sanket).
--
-- This is similar to the above procedure. Please refer above for
-- details.
-------------------------------------------------------------------------

procedure flatten_items ( x_group_id in number ) is

    cursor item_cursor is
        select distinct items.financial_item_id item_id,
        items.statement_group_id group_id,
        items.financial_statement_id stmt_id
        from amw_fin_stmnt_items_b items
        where items.statement_group_id = x_group_id;

    cursor nested_cursor ( p_stmt_id number, p_group_id number, p_item_id number ) is

        select p_item_id parent_id,
        items.financial_item_id child_id,
        items.statement_group_id group_id,
        items.financial_statement_id stmt_id
        from amw_fin_stmnt_items_b items
        start with items.statement_group_id = p_group_id
        and items.parent_financial_item_id = p_item_id
        and items.financial_statement_id = p_stmt_id
        connect by prior items.financial_item_id = items.parent_financial_item_id
        and items.statement_group_id = p_group_id
        and items.financial_statement_id = p_stmt_id;

begin

    g_user_id := fnd_global.user_id;
    g_login_id := fnd_global.conc_login_id;

    for item_rec in item_cursor loop

    	for nested_rec in nested_cursor ( item_rec.stmt_id, item_rec.group_id, item_rec.item_id ) loop
	       insert into amw_fin_item_flat
                   ( parent_financial_item_id,
                     child_financial_item_id,
                     statement_group_id,
                     financial_statement_id,
                     CREATED_BY,
                     CREATION_DATE,
                     LAST_UPDATED_BY,
                     LAST_UPDATE_DATE,
                     LAST_UPDATE_LOGIN,
                     SECURITY_GROUP_ID,
                     OBJECT_VERSION_NUMBER
                   )
               values
	           ( nested_rec.parent_id,
		     nested_rec.child_id,
		     nested_rec.group_id,
		     nested_rec.stmt_id,
		     g_user_id, sysdate, g_user_id, sysdate, g_login_id, null, null
		   );
        end loop;

    end loop;

end flatten_items;
-------------------------------------------------------------------------------------------------------------------


END   AMW_IMPORT_STMNTS_ACCS_PKG;

/
