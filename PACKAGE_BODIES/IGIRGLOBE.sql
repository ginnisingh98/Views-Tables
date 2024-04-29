--------------------------------------------------------
--  DDL for Package Body IGIRGLOBE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGIRGLOBE" AS
-- $Header: igirglbb.pls 120.6.12010000.2 2008/08/04 13:05:58 sasukuma ship $

   g_user_id    NUMBER := fnd_global.user_id;
   g_date       DATE   := sysdate;
   g_login_id   NUMBER := fnd_global.login_id;



   PROCEDURE WriteToLog ( pp_mesg in varchar2 ) IS
   BEGIN
       FND_FILE.Put_line( FND_FILE.log, pp_mesg );
   END;

   PROCEDURE WriteToLog ( pp_mesg in varchar2, pp_write_log in boolean ) IS
   BEGIN
       if pp_write_log then
          WriteToLog ( pp_mesg => pp_mesg );
       end if;
   END;

   FUNCTION Get_functional_currency RETURN VARCHAR2 IS
      CURSOR c_sob (cp_sob_id in number) IS
         SELECT gsob.currency_code
         FROM   gl_sets_of_books gsob
         WHERE  set_of_books_id = cp_sob_id;
      CURSOR c_sob_id IS
         SELECT set_of_books_id
         FROM   ar_system_parameters;
   BEGIN
       FOR l_sob_id in c_sob_id LOOP
           FOR l_sob IN c_sob ( l_sob_id.set_of_books_id ) LOOP
                  RETURN l_sob.currency_code;

            END LOOP;
       end LOOP;
       RETURN NULL;
   END;

   FUNCTION Get_functional_sob_name Return VARCHAR2 IS
      CURSOR c_sob_name is
         SELECT name
         FROM   gl_sets_of_books
         where  set_of_books_id = ( select set_of_books_id from ar_system_parameters );

   BEGIN
      FOR l_sob_name in c_sob_name LOOP
          return l_sob_name.name;
      END LOOP;
      return NULL;
   EXCEPTION WHEN others THEN return null;
   END;

   PROCEDURE PopulateSystemOptions IS

      cursor c_ar_system_options is
     select set_of_books_id, org_id, accounting_method,
            sysdate creation_date, sysdate last_update_date,
             -1  last_updated_by, -1 created_by, -1 last_update_login
     from   ar_system_parameters_all aspa
     where not exists ( select 'Already set up'
                        from  igi_ar_system_options_all
                        where set_of_books_id =  aspa.set_of_books_id
                        and   org_id          =  aspa.org_id )
    ;

    BEGIN


       for l_asp in c_ar_system_options loop
        insert into igi_ar_system_options_all ( set_of_books_id
                                              , accounting_method
                                              , org_id
                                              , creation_date
                                              , created_by
                                              , last_update_date
                                              , last_updated_by
                                              , last_update_login
                                             )
        values (l_asp.set_of_books_id,
               l_asp.accounting_method
                                              , l_asp.org_id
                                              , g_date
                                              , g_user_id
                                              , g_date
                                              , g_user_id
                                              , g_login_id
             );
       end loop;

       /* Start Bug 3749634 */
       DELETE FROM igi_ar_system_options_all a
              WHERE NOT EXISTS
              (
                SELECT 'X'
                FROM ar_system_parameters_all
                WHERE org_id = a.org_id
                AND   set_of_books_id = a.set_of_books_id
              );
       /* End Bug 3749634 */


    END;

/*Commented due to dummy view in Dunning Letter Bug No 5905216 - Start*/
/*

 PROCEDURE PopulateLetterCurrencies IS
   cursor c_letters   is
      select dunning_letter_set_id
      from   ar_dunning_letter_sets core
      where not exists
          ( select 'x'
            from   igi_dun_letter_set_cur igi
            where  igi.dunning_letter_set_id =
                   core.dunning_letter_set_id
         )
      ;
   cursor c_default_curr is
       select currency_code
       from   gl_sets_of_books
       where  set_of_books_id in ( select set_of_books_id
                                   from   ar_system_parameters
                                  )
   ;
   cursor c_customers is
      select customer_id
      from   ra_customers
      ;
   cursor c_profiles (cp_customer_id in number) is
      select  distinct acpa.currency_code,  acp.dunning_letter_set_id
      from   ar_customer_profile_amounts acpa
      ,      ar_customer_profiles        acp
      where    acpa.customer_id = cp_customer_id
      and       acp.customer_id = acpa.customer_id
      and       acp.dunning_letter_set_id is not null
      and   exists
             (
                    select 'x'
                    from   igi_dun_letter_sets idls
                    where  idls.dunning_letter_set_id =
                      acp.dunning_letter_set_id
              )
     ;


      cursor c_delete_currency ( cp_customer_id in number,
                                 cp_letter_set_id in number) is
      select  currency_code
      from    igi_dun_letter_set_cur
      where   dunning_letter_set_id = cp_letter_set_id
      and     currency_code not in
         (
              select  currency_code
              from    ar_customer_profile_amounts
              where   customer_profile_id
              in (
                   select distinct customer_profile_id
                   from   ar_customer_profiles
                   where  customer_id = cp_customer_id
                 )
              and  currency_code is not null
              union
              select currency_code
              from   gl_sets_of_books
              where  set_of_books_id =
                     ( select set_of_books_id
                       from  ar_system_parameters
                     )
          )
       ;




 BEGIN
   WriteToLog ('----------------------------------------------');
   --
   --  Populate the Functional currency as default for all
   --  letter sets!
   --
   FOR l_dc   IN c_default_curr LOOP
       FOR l_letters in c_letters LOOP
            INSERT INTO igi_dun_letter_set_cur
                        ( dunning_letter_set_id
                        , currency_code
                        , created_by
                        , creation_date
                        , last_updated_by
                        , last_update_date
                        , last_update_login
                        )
             SELECT
                         l_letters.dunning_letter_set_id
                        , l_dc.currency_code
                        , g_user_id
                        , g_date
                        , g_user_id
                        , g_date
                        , g_login_id
             FROM SYS.DUAL
             WHERE NOT EXISTS
             (            SELECT 'x'
                          FROM   igi_dun_letter_set_cur
                          WHERE  dunning_letter_set_id =
                                 l_letters.dunning_letter_set_id
                          AND    currency_code =
                                 l_dc.currency_code
              )
              ;
       END LOOP;
   END LOOP;
   --
   -- Now verify the extra currencies set at
   -- the customer profile level and insert the new
   -- currencies if possible
   --
   FOR l_cust IN C_customers LOOP
      FOR l_prof in C_profiles ( l_cust.customer_id) LOOP
            WriteToLog( 'Letter Set id '|| l_prof.dunning_letter_set_id );

            INSERT INTO igi_dun_letter_set_cur
                        ( dunning_letter_set_id
                        , currency_code
                        , created_by
                        , creation_date
                        , last_updated_by
                        , last_update_date
                        , last_update_login
                        )
             SELECT
                         l_prof.dunning_letter_set_id
                        , l_prof.currency_code
                        , g_user_id
                        , g_date
                        , g_user_id
                        , g_date
                        , g_login_id
             FROM SYS.DUAL
             WHERE NOT EXISTS
             (            SELECT 'x'
                          FROM   igi_dun_letter_set_cur
                          WHERE  dunning_letter_set_id =
                                 l_prof.dunning_letter_set_id
                          AND    currency_code =
                                 l_prof.currency_code
              )
              ;
              WriteToLog('Inserting Currency '||l_prof.currency_code );

            END LOOP;
   END LOOP;
   WriteToLog ('----------------------------------------------');

 END;


   PROCEDURE PopulateLetterSets IS
   cursor c_ar_dunning_letter_sets is
	select dunning_letter_set_id,
		'Y' use_dunning_flag,
		'N' charge_per_invoice_flag
	from ar_dunning_letter_sets ardls
	where not exists ( select 'Already set up'
				from igi_dun_letter_sets
				where dunning_letter_set_id = ardls.dunning_letter_set_id);
    begin
	     for dlsrec in c_ar_dunning_letter_sets loop
	       insert into igi_dun_letter_sets (
		      dunning_letter_set_id,
		      use_dunning_flag,
		      charge_per_invoice_flag,
		      created_by,
		      creation_date,
		      last_updated_by,
		      last_update_date,
		      last_update_login
	       ) VALUES (
		      dlsrec.dunning_letter_set_id,
		      dlsrec.use_dunning_flag,
		      dlsrec.charge_per_invoice_flag,
		      g_user_id,
		      g_date,
		      g_user_id,
		      g_date,
		      g_login_id
	       );
	       end loop;
     exception when others then
        raise_application_error(-20001, SQLERRM );
     END PopulateLetterSets;


PROCEDURE  UpdateBlankCustLetters IS
   CURSOR C_dlsl IS
     SELECT IDLSL.*
     FROM  igi_dun_letter_Set_lines IDLSL
     ;

   CURSOR c_dlscl  ( p_dunning_letter_set_id in number
                   , p_dunning_line_num      in number
                   , p_dunning_letter_id     in number
                   , p_currency_code         in varchar2)
   IS
     SELECT IDCLSL.rowid row_id , IDCLSL.*
     FROM  igi_dun_cust_letter_set_lines IDCLSL
     WHERE IDCLSL.dunning_letter_set_id = p_dunning_letter_Set_id
     AND   IDCLSL.dunning_line_num      = p_dunning_line_num
     AND   IDCLSL.dunning_letter_id     = p_dunning_letter_id
     AND   IDCLSL.currency_code         = p_currency_code
     ;
 BEGIN
    FOR l_dlsl in c_dlsl LOOP
        FOR l_dlscl in c_dlscl ( l_dlsl.dunning_letter_set_id
                               , l_dlsl.dunning_line_num
                               , l_dlsl.dunning_letter_id
                               , l_dlsl.currency_code  ) LOOP
               IF (nvl(l_dlscl.letter_charge_amount,0) <>
                   nvl(l_dlsl.letter_charge_amount,0)) THEN
                   UPDATE igi_dun_cust_letter_set_lines
                   SET    letter_charge_amount = l_dlsl.letter_charge_amount
                   WHERE  ROWID = l_dlscl.row_id
                   ;
               END IF;
               IF nvl(l_dlscl.invoice_charge_amount,0) <>
                  nvl(l_dlsl.invoice_charge_amount,0) THEN
                   UPDATE igi_dun_cust_letter_set_lines
                   SET    invoice_charge_amount = l_dlsl.invoice_charge_amount
                   WHERE  ROWID = l_dlscl.row_id
                   ;
               END IF;
        END LOOP;
    END LOOP;
 END;


 PROCEDURE PopulateCustLetters IS


-- Cursor to retrieve all the Customer profiles ALREADY copied to the extended tables
-- This is okay as this routine is Dependedent on PopulateCustProfiles.


  cursor c_profiles IS
     SELECT acp.dunning_letter_set_id, acp.customer_id, acp.site_use_id,
            acp.customer_profile_class_id, acp.customer_profile_id
     from igi_dun_customer_profile_v        acp, igi_dun_cust_prof idcp
     where  acp.customer_profile_id = idcp.customer_profile_id
     and    acp.dunning_letter_set_id is not null
     ;

-- We need to find all the currencies associated with the Dunning Letter Set
-- (This is not the same as one used for the Customer)

    cursor c_currency (cp_dunning_letter_set_id in number) IS
     SELECT idlsc.currency_code
     from   igi_dun_letter_Set_cur idlsc
     where idlsc.dunning_letter_set_id = cp_dunning_letter_set_id
     ;


-- The letter set line level information for the dunning letter set
-- We need to filter it with currency as to make it modular


     cursor C_LettersetLines ( cp_dunning_letter_set_id   in number
                             , cp_currency_code       in varchar2
                             ) IS
      SELECT igclsl.dunning_letter_id
           , igclsl.dunning_line_num
           , igclsl.currency_code
           , igclsl.letter_charge_amount
           , igclsl.invoice_charge_amount
      from   igi_dun_letter_set_lines igclsl
      where  igclsl.dunning_letter_set_id    = cp_dunning_letter_set_id
      and    igclsl.currency_code            = cp_currency_code
      ;


-- This function tests whether dunning letter set exists in the customer table
-- and also all the currency codes in the customer letter sets table match
-- the list of currency codes at the letter set level


      FUNCTION DunningLetterSetExists (   cp_dunning_letter_set_id in number
                                      ,   cp_customer_profile_id in number)
      RETURN BOOLEAN IS
        CURSOR c_exists IS select 'x'
                           from igi_dun_cust_letter_set_lines
                           where customer_profile_id = cp_customer_profile_id
                           and   dunning_letter_set_id = cp_dunning_letter_set_id
                           and not exists
                              ( select 'x'
                                from   igi_dun_cust_letter_set_cur cls
                                where  customer_profile_id = cp_customer_profile_id
                                and    not exists
                                        ( select currency_code
                                          from   igi_dun_letter_Set_cur
                                          where  dunning_letter_set_id = cp_dunning_letter_set_id
                                          and    currency_code         = cls.currency_code
                                        )
                              )
                           ;
      BEGIN
         for l_exists in c_exists loop
             return TRUE;
         end loop;
         return FALSE;
      EXCEPTION WHEN OTHERS THEN return TRUE;
      END DunningLetterSetExists;

     begin

    ---Bug 6847295 - Performance tuning for Bug FP: 6647140       Code change starts



 delete from igi_dun_cust_letter_set_lines lines
          WHERE
	  NOT exists ( SELECT 'Y' FROM IGI_DUN_CUSTOMER_PROFILE_V PROF
	    where LINES.CUSTOMER_ID = PROF.CUSTOMER_ID
	          and LINES.CUSTOMER_PROFILE_ID = PROF.CUSTOMER_PROFILE_ID
	          and NVL(LINES.SITE_USE_ID,-1)  = NVL(PROF.SITE_USE_ID,-1)
                  and NVL(LINES.CUSTOMER_PROFILE_CLASS_ID, -1) = NVL(PROF.CUSTOMER_PROFILE_CLASS_ID,-1));

     ---Bug 6847295 - Performance tuning for Bug FP: 6647140       Code change ends

          for l_profile in c_profiles loop
             -- Check if the letter set id and currency


           --  if nvl( l_profile.dunning_letter_set_id,-1) = -1 then
                                       -- Delete Letter sets

--               delete from igi_dun_cust_letter_set_lines
--               where  customer_profile_id = l_profile.customer_profile_id;
--               delete from igi_dun_cust_letter_set_cur
--               where  customer_profile_id = l_profile.customer_profile_id;
                                -- Delete Letter sets
--             els

             if not DunningLetterSetExists ( l_profile.customer_profile_id
                                           , l_profile.dunning_letter_set_id )
             THEN

               DECLARE
                 cursor c_delete is
                   select rowid row_id
                   from   igi_dun_cust_letter_set_lines idclsl
                   where  dunning_letter_set_id = l_profile.dunning_letter_set_id
                   and    customer_profile_id   = l_profile.customer_profile_id
                   and (dunning_letter_set_id, dunning_line_num,
                       dunning_letter_id, currency_code)
                  not in (
                   select dunning_letter_set_id
                        , dunning_line_num
                        , dunning_letter_id
                        , currency_code
                   from igi_dun_letter_set_lines idlsl
                   where  idlsl.dunning_letter_set_id =
                          idclsl.dunning_letter_set_id
                    )  ;
               BEGIN
                  for l_rowid in c_delete loop
                      delete from igi_dun_cust_letter_set_lines
                      where  rowid = l_rowid.row_id
                      ;
                  end loop;
               END;

              DECLARE
                 cursor c_delete is
                   select rowid row_id
                   from   igi_dun_cust_letter_set_cur idclsl
                   where  customer_profile_id  = l_profile.customer_profile_id
                   and (customer_profile_id, currency_code)
                  not in (
                   select customer_profile_id
                        , currency_code
                   from igi_dun_cust_letter_set_lines idlsl
                   where   customer_profile_id = l_profile.customer_profile_id
                    )  ;
               BEGIN
                  for l_rowid in c_delete loop
                      delete from igi_dun_cust_letter_set_cur
                      where  rowid = l_rowid.row_id
                      ;
                  end loop;
               END;

               for l_currency in c_currency (  l_profile.dunning_letter_set_id ) loop

                  insert into  igi_dun_cust_letter_set_cur (
                         customer_profile_id,
                         currency_code,
                         created_by,
                         creation_date,
                         last_update_date,
                         last_updated_by,
                         last_update_login )
                         select
                          l_profile.customer_profile_id
                         , l_currency.currency_code
                         , g_user_id
                         , g_date
                         , g_date
                         , g_user_id
                         , g_login_id
                         from  sys.dual
                         where not exists
                         ( select 'x'
                           from  igi_dun_cust_letter_set_cur
                           where customer_profile_id = l_profile.customer_profile_id
                           and   currency_code       = l_currency.currency_code
                         )
                         ;

                  for l_lines in c_lettersetlines  (   l_profile.dunning_letter_set_id,
                                                       l_currency.currency_code )
                  loop

                     insert into igi_dun_cust_letter_set_lines (
                               customer_profile_id,
                               customer_profile_class_id,
                               customer_id,
                               site_use_id,
                               dunning_letter_set_id,
                               dunning_line_num,
                               dunning_letter_id,
                               currency_code,
                               letter_charge_amount,
                               invoice_charge_amount,
                               created_by,
                               creation_date,
                               last_update_date,
                               last_updated_by,
                               last_update_login
                               )
                   select      l_profile.customer_profile_id
                               , l_profile.customer_profile_class_id
                               , l_profile.customer_id
                               , l_profile.site_use_id
                               , l_profile.dunning_letter_set_id
                               , l_lines.dunning_line_num
                               , l_lines.dunning_letter_id
                               , l_lines.currency_code
                               , l_lines.letter_charge_amount
                               , l_lines.invoice_charge_amount
                               , g_user_id
                               , g_date
                               , g_date
                               , g_user_id
                               , g_login_id
                    from  sys.dual
                    where  not exists
                           ( select 'x'
                              from  igi_dun_cust_letter_set_lines
                              where customer_profile_id =
                                    l_profile.customer_profile_id
                              and   customer_profile_class_id = l_profile.customer_profile_class_id
                              and   dunning_letter_set_id = l_profile.dunning_letter_set_id
                              and   dunning_line_num   = l_lines.dunning_line_num
                              and   currency_code      = l_lines.currency_code
                           )
                              ;
                  end loop;
               end loop;

            end if;

          end loop;

     exception when others then
        raise_application_error(-20001, SQLERRM );

     END PopulateCustLetters;




 PROCEDURE PopulateCustProfiles IS
   cursor c_ar_customer_profiles is
	select customer_profile_id,
		'Y' use_dunning_flag,
		'A' dunning_charge_type
	from ar_customer_profiles arcp
	where not exists (select 'Already set up'
				from igi_dun_cust_prof
				where customer_profile_id = arcp.customer_profile_id);


begin
	   for arcprec in c_ar_customer_profiles loop
	       insert into igi_dun_cust_prof(
		      customer_profile_id,
		      use_dunning_flag,
		      dunning_charge_type,
		      created_by,
		      creation_date,
		      last_updated_by,
		      lasT_update_date,
		      last_update_login
	         ) SELECT
		      arcprec.customer_profile_id,
		      arcprec.use_dunning_flag,
		      arcprec.dunning_charge_type,
		      g_user_id,
		      g_date,
		      g_user_id,
		      g_date,
		      g_login_id
	          FROM SYS.DUAL
              WHERE NOT EXISTS ( SELECT 'x'
                                 FROM  igi_dun_cust_prof
                                 WHERE customer_profile_id
                                     = arcprec.customer_profile_id
                               )
             ;
	       end loop;


     exception when others then
        raise_application_error(-20001, SQLERRM );

     END PopulateCustProfiles;

     PROCEDURE PopulateLetterSetLines IS
        cursor c_ar_dunning_letter_sets is
	         select ardlsl.dunning_letter_set_id,
                   dunning_line_num,
                   dunning_letter_id,
                   igicur.currency_code,
		         'Y' use_dunning_flag,
		         'N' charge_per_invoice_flag
	         from ar_dunning_letter_set_lines ardlsl,
                 igi_dun_letter_set_cur      igicur
	         where ardlsl.dunning_letter_set_id = igicur.dunning_letter_set_id
              and exists ( select 'Already set up'
				          from igi_dun_letter_sets
				          where dunning_letter_set_id = ardlsl.dunning_letter_set_id)
              and ( ardlsl.dunning_letter_set_id, ardlsl.dunning_line_num,
                    ardlsl.dunning_letter_id, igicur.currency_code)
              not in ( select dunning_letter_set_id, dunning_line_num,
                              dunning_letter_id, currency_code
                       from   igi_dun_letter_set_lines )
            ;
    begin
           delete from igi_dun_letter_set_lines igi
           where (igi.dunning_letter_set_id,
                  igi.dunning_letter_id,
                  igi.dunning_line_num ) not in (
                          Select ar.dunning_letter_set_id,
                                 ar.dunning_letter_id,
                                 ar.dunning_line_num
                            from ar_dunning_letter_set_lines ar);

           delete from igi_dun_cust_letter_set_lines igi
           where (igi.dunning_letter_set_id,
                  igi.dunning_letter_id,
                  igi.dunning_line_num ) not in (
                          Select ar.dunning_letter_set_id,
                                 ar.dunning_letter_id,
                                 ar.dunning_line_num
                            from ar_dunning_letter_set_lines ar);

	     for dlsrec in c_ar_dunning_letter_sets loop
	       insert into igi_dun_letter_set_lines (
		      dunning_letter_set_id,
            dunning_line_num,
            dunning_letter_id,
            currency_code,
		      created_by,
		      creation_date,
		      last_updated_by,
		      last_update_date,
		      last_update_login
	       ) SELECT
		      dlsrec.dunning_letter_set_id,
            dlsrec.dunning_line_num,
            dlsrec.dunning_letter_id,
            dlsrec.currency_code,
		      g_user_id,
		      g_date,
		      g_user_id,
		      g_date,
		      g_login_id
	       FROM SYS.DUAL
           WHERE NOT EXISTS
                ( SELECT 'x'
                  FROM  igi_dun_letter_Set_lines
                  WHERE dunning_letter_set_id = dlsrec.dunning_letter_set_id
                  AND   dunning_line_num      = dlsrec.dunning_line_num
                  AND   currency_code         = dlsrec.currency_code
                );
	       end loop;
     exception when others then
        raise_application_error(-20001, SQLERRM );
     END;

     PROCEDURE PopulateCustProfileClasses IS

      cursor c_ar_profile_classes is
     select name, status, customer_profile_class_id, dunning_letters,
            sysdate creation_date, sysdate last_update_date,
             -1  last_updated_by, -1 created_by, -1 last_update_login
     from   ar_customer_profile_classes acpc
     where not exists ( select 'Already set up'
                        from  igi_dun_cust_prof_class
                        where customer_profile_class_id =  acpc.customer_profile_class_id
                      )
    ;

    BEGIN


       for l_acp in c_ar_profile_classes loop
        insert into igi_dun_cust_prof_class   (  customer_profile_class_id
                                              , creation_date
                                              , created_by
                                              , last_update_date
                                              , last_updated_by
                                              , last_update_login
                                              , dunning_charge_type
                                              , use_dunning_flag
                                             )
        values (                                l_acp.customer_profile_class_id
                                              , l_acp.creation_date
                                              , l_acp.created_by
                                              , l_acp.last_update_date
                                              , l_acp.last_updated_by
                                              , l_acp.last_update_login
                                              , 'A'
                                              , 'Y'
             );
    end loop;

   END;

*/
/*Commented due to dummy view in Dunning Letter Bug No 5905216 - End*/

Procedure      PopulateRPIFlex
                           ( pp_header_txn_context in varchar2
                            , pp_header_txn_id1     in varchar2
                            , pp_header_txn_id2     in varchar2
                            , pp_line_txn_context   in varchar2
                            , pp_line_txn_id1       in varchar2
                            , pp_line_txn_id2       in varchar2
                            , pp_line_txn_id3       in varchar2
                            , pp_line_txn_id4       in varchar2
                            , pp_language_code      in varchar2
                            )
IS
  lv_appl_short_name varchar2(10) := 'AR';
  lv_header_segment1 varchar2(30) := 'INTERFACE_HEADER_ATTRIBUTE1';
  lv_header_segment2 varchar2(30) := 'INTERFACE_HEADER_ATTRIBUTE2';
  lv_line_txn_flex   varchar2(50) := 'RA_INTERFACE_LINES';
  lv_line_segment1 varchar2(30) := 'INTERFACE_LINE_ATTRIBUTE1';
  lv_line_segment2 varchar2(30) := 'INTERFACE_LINE_ATTRIBUTE2';
  lv_line_segment3 varchar2(30) := 'INTERFACE_LINE_ATTRIBUTE3';
  lv_line_segment4 varchar2(30) := 'INTERFACE_LINE_ATTRIBUTE4';
  lv_header_txn_flex varchar2(50) := 'RA_INTERFACE_HEADER';

begin
  fnd_flex_dsc_api.set_session_mode ( 'seed_data' );


--    ***************************  HEADER  ********************************************
/*
-- Assumption : Descriptive flexfield with title 'Invoice Transaction Flexfield'
--              already exists!
--
-- 1. If context exists delete it!
-- 2. Add the context
-- 3.
--
*/

  if  fnd_flex_dsc_api.context_exists ( p_appl_short_name => lv_appl_short_name
                                  , p_flexfield_name  => lv_header_txn_flex
                                  , p_context_code    =>  pp_header_txn_context
                                  )  THEN
       fnd_flex_dsc_api.delete_context( appl_short_name => lv_appl_short_name
                             , flexfield_name  => lv_header_txn_flex
                             , context    =>  pp_header_txn_context
                             );
  end if;

  fnd_flex_dsc_api.create_context( appl_short_name => lv_appl_short_name
                             , flexfield_name  => lv_header_txn_flex
                             , context_code    =>  pp_header_txn_context
                             , context_name    =>  pp_header_txn_context
                             , description     =>  pp_header_txn_context
                             , enabled         =>  'Y'
                             );
  /*
  -- First Segment
  */
  fnd_flex_dsc_api.create_segment ( appl_short_name => lv_appl_short_name
                              , flexfield_name  => lv_header_txn_flex
                              , context_name    => pp_header_txn_context
                              , name            => pp_header_txn_id1
                              , column          => lv_header_segment1
                              , description     => pp_header_txn_id1
                              , sequence_number => 1
                              , enabled         => 'Y'
                              , displayed       => 'Y'
                              , value_set       => ''
                              , default_type    => ''
                              , default_value   => ''
                              , required        => 'Y'
                              , security_enabled => 'N'
                              , display_size     => 30
                              , description_size => 50
                              , concatenated_description_size => 25
                              , list_of_values_prompt => 'N'
                              , window_prompt    => pp_header_txn_id1
                              );

  /*
  -- Second Segment
  */
   fnd_flex_dsc_api.create_segment ( appl_short_name => lv_appl_short_name
                              , flexfield_name  => lv_header_txn_flex
                              , context_name    => pp_header_txn_context
                              , name            => pp_header_txn_id2
                              , column          => lv_header_segment2
                              , description     => pp_header_txn_id2
                              , sequence_number => 2
                              , enabled         => 'Y'
                              , displayed       => 'Y'
                              , value_set       => ''
                              , default_type    => ''
                              , default_value   => ''
                              , required        => 'Y'
                              , security_enabled => 'N'
                              , display_size     => 30
                              , description_size => 50
                              , concatenated_description_size => 25
                              , list_of_values_prompt => 'N'
                              , window_prompt    => pp_header_txn_id2
                              );

      fnd_flex_dsc_api.freeze ( appl_short_name =>  lv_appl_short_name
                          , flexfield_name  =>  lv_header_txn_flex
                          );
--    ***************************  LINE  ********************************************
  if  fnd_flex_dsc_api.context_exists ( p_appl_short_name => lv_appl_short_name
                                  , p_flexfield_name  => lv_line_txn_flex
                                  , p_context_code    =>  pp_line_txn_context
                                  )  THEN
       fnd_flex_dsc_api.delete_context( appl_short_name => lv_appl_short_name
                             , flexfield_name  => lv_line_txn_flex
                             , context    =>  pp_line_txn_context
                             );
  end if;

  fnd_flex_dsc_api.create_context( appl_short_name => lv_appl_short_name
                             , flexfield_name  => lv_line_txn_flex
                             , context_code    =>  pp_line_txn_context
                             , context_name    =>  pp_line_txn_context
                             , description     =>  pp_line_txn_context
                             , enabled         =>  'Y'
                             );

  /*
  -- First Segment
  */
  fnd_flex_dsc_api.create_segment ( appl_short_name => lv_appl_short_name
                              , flexfield_name  => lv_line_txn_flex
                              , context_name    => pp_line_txn_context
                              , name            => pp_line_txn_id1
                              , column          => lv_line_segment1
                              , description     => pp_line_txn_id1
                              , sequence_number => 1
                              , enabled         => 'Y'
                              , displayed       => 'Y'
                              , value_set       => ''
                              , default_type    => ''
                              , default_value   => ''
                              , required        => 'Y'
                              , security_enabled => 'N'
                              , display_size     => 30
                              , description_size => 50
                              , concatenated_description_size => 25
                              , list_of_values_prompt => 'N'
                              , window_prompt    => pp_line_txn_id1
                              );

  /*
  -- Second Segment
  */
   fnd_flex_dsc_api.create_segment ( appl_short_name => lv_appl_short_name
                              , flexfield_name  => lv_line_txn_flex
                              , context_name    => pp_line_txn_context
                              , name            => pp_line_txn_id2
                              , column          => lv_line_segment2
                              , description     => pp_line_txn_id2
                              , sequence_number => 2
                              , enabled         => 'Y'
                              , displayed       => 'Y'
                              , value_set       => ''
                              , default_type    => ''
                              , default_value   => ''
                              , required        => 'Y'
                              , security_enabled => 'N'
                              , display_size     => 30
                              , description_size => 50
                              , concatenated_description_size => 25
                              , list_of_values_prompt => 'N'
                              , window_prompt    => pp_line_txn_id2
                              );

 /*
  -- Third Segment
  */
     fnd_flex_dsc_api.create_segment ( appl_short_name => lv_appl_short_name
                              , flexfield_name  => lv_line_txn_flex
                              , context_name    => pp_line_txn_context
                              , name            => pp_line_txn_id3
                              , column          => lv_line_segment3
                              , description     => pp_line_txn_id3
                              , sequence_number => 3
                              , enabled         => 'Y'
                              , displayed       => 'Y'
                              , value_set       => ''
                              , default_type    => ''
                              , default_value   => ''
                              , required        => 'Y'
                              , security_enabled => 'N'
                              , display_size     => 30
                              , description_size => 50
                              , concatenated_description_size => 25
                              , list_of_values_prompt => 'N'
                              , window_prompt    => pp_line_txn_id3
                              );
  /*
  -- Fourth Segment
  */

   fnd_flex_dsc_api.create_segment ( appl_short_name => lv_appl_short_name
                              , flexfield_name  => lv_line_txn_flex
                              , context_name    => pp_line_txn_context
                              , name            => pp_line_txn_id4
                              , column          => lv_line_segment4
                              , description     => pp_line_txn_id4
                              , sequence_number => 4
                              , enabled         => 'Y'
                              , displayed       => 'Y'
                              , value_set       => ''
                              , default_type    => ''
                              , default_value   => ''
                              , required        => 'Y'
                              , security_enabled => 'N'
                              , display_size     => 30
                              , description_size => 50
                              , concatenated_description_size => 25
                              , list_of_values_prompt => 'N'
                              , window_prompt    => pp_line_txn_id4
                              );


      fnd_flex_dsc_api.freeze ( appl_short_name =>  lv_appl_short_name
                          , flexfield_name  =>  lv_line_txn_flex
                          );


  commit;

exception when others then
  declare
   lv_message varchar2(300);
  begin
   lv_message := FND_FLEX_DSC_API.message();
   raise_application_error(-20000, to_char(sqlcode)||' '||lv_message );
  end;
END; -- Procedure


PROCEDURE PopulateRPIFlexforCurrSOb IS
    CURSOR c_rpi IS
          SELECT rpi_header_context_code
          ,      rpi_header_charge_id
          ,      rpi_header_generate_seq
          ,      rpi_line_context_code
          ,      rpi_line_charge_id
          ,      rpi_line_generate_seq
          ,      rpi_line_charge_line_num
          ,      rpi_line_price_break_num
          ,      USERENV('LANG') language
          from   igi_ar_system_options;
BEGIN
    FOR l_rpi in C_rpi LOOP
         PopulateRPIFlex
                           ( pp_header_txn_context => l_rpi.rpi_header_context_code
                            , pp_header_txn_id1    => l_rpi.rpi_header_charge_id
                            , pp_header_txn_id2    => l_rpi.rpi_header_generate_seq
                            , pp_line_txn_context  => l_rpi.rpi_line_context_code
                            , pp_line_txn_id1      => l_rpi.rpi_line_charge_id
                            , pp_line_txn_id2      => l_rpi.rpi_line_generate_seq
                            , pp_line_txn_id3      => l_rpi.rpi_line_charge_line_num
                            , pp_line_txn_id4      => l_rpi.rpi_line_price_break_num
                            , pp_language_code     => l_rpi.language
                            )  ;
    END LOOP;
END;

   /*
   -- Called By a SRS Routine to Initially Populate the data from AR tables to
   -- the 'extended' IGI AR Tables
   */

    PROCEDURE PopulateExtendedData (
                       errbuf      out NOCOPY  varchar2
                      ,retcode     out NOCOPY  number
                      ,pp_source   in   varchar2
                      ,pp_commit   in   boolean
                      ) IS
            PROCEDURE do_commit IS
            BEGIN
                if pp_commit then
                   commit work;
                else
                   null;
                end if;
            END;

            PROCEDURE do_rollback IS
            BEGIN
                if pp_commit then
                   rollback work;
                else
                   null;
                end if;
            ENd;
    BEGIN
    /*
    -- The pp_source refers to the LOOKUP_CODE in IGI_LOOKUPS
    -- Where lookup_type = 'IGI_AR_POPULATE_SOURCE'
    */
           IF pp_source = 'COMBINED_BASIS_ACCTG' AND
                 igi_gen.is_req_installed('ARC') THEN
              WriteToLog ( 'Copying Combined Basis Set Up information', true);
              PopulateSystemOptions;
           ELSIF pp_source = 'SYSTEM_OPTIONS'  THEN
              WriteToLog ( 'Copying System Options information', true);
              PopulateSystemOptions;

/*Commented due to dummy view in Dunning Letter Bug No 5905216 - Start*/
/*

           ELSIF pp_source = 'DUNNING_PROFILES'    AND
                   igi_gen.is_req_installed('DUN')
           THEN
              WriteToLog ( '>> Synchronizing Customer Profile Classes information', true);
              PopulateCustProfileClasses;
              WriteToLog ( '>> Synchronizing Customer Profiles information', true);
              PopulatecustProfiles;
              WriteToLog ( '>> Synchronizing Customer letter set information', true);
              PopulateCustLetters;
              WriteToLog ( '>> Synchronization Complete.', true);
           ELSIF pp_source = 'DUNNING_LETTERS'    AND
                   igi_gen.is_req_installed('DUN')
           THEN
              WriteToLog ( '>> Synchronizing Dunning Letter Sets information', true);
              PopulateLetterSets;
              WriteToLog ( '>> Synchronizing Dunning Letter Set currency and lines information', true);
              PopulateLetterCurrencies;
              PopulateLetterSetLines;
              WriteToLog ( '>> Synchronizing Customer letter set information', true);
              PopulateCustLetters;
              PopulateExtendedData(errbuf, retcode, 'DUNNING_PROFILES');
              UpdateBlankCustLetters ;
           ELSIF pp_source = 'DUNNING_EXTENSIONS' AND
                 igi_gen.is_req_installed('DUN')
           THEN
              WriteToLog ( 'Begin Synchronization of Data for Dunning Extensions.', true);
              WriteToLog ( ' ***  MULTI ORG COMPLIANT *** ');
              WriteToLog ( '>> Synchronizing Customer Profile Classes information', true);
              PopulateCustProfileClasses;
              WriteToLog ( '>> Synchronizing Customer Profiles information', true);
              PopulatecustProfiles;
              WriteToLog ( '>> Synchronizing Dunning Letter Sets information', true);
              PopulateLetterSets;
              WriteToLog ( '>> Synchronizing Dunning Letter Set currency and lines information', true);
              PopulateLetterCurrencies;
              PopulateLetterSetLines;
              WriteToLog ( '>> Synchronizing Customer letter set information', true);
              PopulateCustLetters;
              WriteToLog ( 'End Synchronization of Data for Dunning Extensions.', true);
*/
/*Commented due to dummy view in Dunning Letter Bug No 5905216 - End*/

           ELSIF pp_source = 'RPI_FLEX_FOR_CURR_SOB' AND
                 igi_gen.is_req_installed ('RPI')
           THEN
               WriteToLog ( 'Begin Creation of AutoInvoice Descriptive Flexfields', true);
               WriteToLog ( ' *** THIS SET UP IS INDEPENDENT OF MULTI-ORG *** ', true);
               PopulateRPIFlexforCurrSOb;
               WriteToLog ( 'Begin Creation of AutoInvoice Descriptive Flexfields', true);
          ELSE
              NULL;
           END IF;

           do_COMMIT; -- Mandatory for a concurrent program
           retcode := 0;
           errbuf  := '';
     EXCEPTION WHEN OTHERS THEN
            do_rollback;
            retcode := 2;
            errbuf  := SQLERRM;
    END;



  END;

/
