--------------------------------------------------------
--  DDL for Package Body JA_CN_ITEMIZATION_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_CN_ITEMIZATION_INTERFACE" AS
  --$Header: JACNITIB.pls 120.2 2008/02/20 03:37:11 shyan noship $
  --+=======================================================================+
  --|               Copyright (c) 2006 Oracle Corporation                   |
  --|                       Redwood Shores, CA, USA                         |
  --|                         All rights reserved.                          |
  --+=======================================================================+
  --| FILENAME                                                              |
  --|      JACNITIB.pls                                                     |
  --|                                                                       |
  --| DESCRIPTION                                                           |
  --|     This package is used to import the legacy data user input in      |
  --|     interface table. It will validate the journal lines user input    |
  --|     and make the data enable to import to table ja_cn_journal_lines.  |
  --|     After import these data, call CNAO post program.                  |
  --|                                                                       |
  --|                                                                       |
  --| PROCEDURE LIST                                                        |
  --|                                                                       |
  --|      Import_Itemization_Data                                          |
  --|      Set_flag_P                                                       |
  --|      Legal_consistent_Validation                                      |
  --|      Company_Segment_Validation                                       |
  --|      Balance_Validation                                               |
  --|      Code_Combination_Validation                                      |
  --|      Validation                                                       |
  --|      Generate_Journal_Num                                             |
  --|      Generate_Code_Combination_View                                   |
  --|                                                                       |
  --| HISTORY                                                               |
  --|      07/09/2007     yanbo liu         Created                         |
  --|      28/12/2007     xiao lv           updated                         |
  --|                                                                       |
  --+======================================================================*/
 --==========================================================================
  --  FUNCTION NAME:
  --  Legal_consistent_Validation                Public
  --
  --  DESCRIPTION:
  --  check legal entity id
  --  Legal entity id of journal lines must be consistent with legal entity id
  --  defined in JA: CN Legal Entity. or else,set status as 'EL01'. The profile
  --  legal entity id is the same as the paramter legal entity id.
  --
  --  PARAMETERS:
  --      P_LEGAL_ENTITY_ID         legal entity id
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --  07/09/2007     yanbo liu        created
  --  28/12/2007     xiao lv          updated
  --===========================================================================


  PROCEDURE Legal_consistent_Validation( P_LEGAL_ENTITY_ID IN NUMBER) IS

    l_dbg_level               NUMBER        :=FND_LOG.G_Current_Runtime_Level;
    l_proc_level              NUMBER        :=FND_LOG.Level_Procedure;
    l_proc_name               VARCHAR2(100) :='Legal_consistent_Validation';

   -- l_profile_legal           NUMBER(15);

  BEGIN

    IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.begin'
                     ,'Enter procedure'
                    );

      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'Legal Entity ID '||P_LEGAL_ENTITY_ID
                    );


    END IF;  --(l_proc_level >= l_dbg_level)

   /*
   l_profile_legal:=Fnd_Profile.VALUE(NAME => 'JA_CN_LEGAL_ENTITY');

    IF l_profile_legal IS NULL
    THEN
      --Raise error message for caller

      Fnd_Message.Set_Name(Application => 'JA',
                           NAME        => 'JA_CN_NO_LEGAL_ENTITY');
      l_Error_Msg := Fnd_Message.Get;

      --Output error message
      Fnd_File.Put_Line(Fnd_File.Output, l_Error_Msg);
      return;
    END IF; -- FND_PROFILE.Value(NAME => 'JA_CN_LEGAL_ENTITY')IS NULL
    */
    --if the legal entity id of journal lines is not consistent with the legal entity id defined
    --in JA: CN Legal Entity,set status as 'EL01'(this value is same as paramter legal_entity_id).
     update ja_cn_item_interface
     set status='EL01'
     where legal_entity_id<>P_LEGAL_ENTITY_ID
     and status='P';
   --  commit;

    EXCEPTION

      WHEN OTHERS THEN
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.Other_Exception '
                         ,SQLCODE||':'||SQLERRM);
        END IF;  --(l_proc_level >= l_dbg_level)


  END Legal_consistent_Validation;

 --==========================================================================
  --  FUNCTION NAME:
  --  Legal_consistent_Validation                Public
  --
  --  DESCRIPTION:
  --  Do the check for user input. This program will check:
  --  JE_CATERGORY
  --  CURRENCY_CODE
  --  THIRD_PARTY_NUMBER
  --  PERSONNEL_NUMBER
  --  PROJECT_NUMBER
  --  PROJECT_SOURCE
  --  THIRD_PARTY_TYPE
  --  JOURNAL_CREATOR
  --  JOURNAL_APPROVER
  --  JOURNAL_POSTER
  --
  --  PARAMETERS:
  --      P_LEGAL_ENTITY_ID         legal entity id
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --  07/09/2007     yanbo liu        created
  --===========================================================================


  PROCEDURE Base_Validation IS

    l_dbg_level               NUMBER        :=FND_LOG.G_Current_Runtime_Level;
    l_proc_level              NUMBER        :=FND_LOG.Level_Procedure;
    l_proc_name               VARCHAR2(100) :='Legal_consistent_Validation';


     l_JE_CATEGORY          VARCHAR2(25);
     l_CURRENCY_CODE        VARCHAR2(15);
     l_THIRD_PARTY_NUMBER   VARCHAR2(300);
     l_PERSONNEL_ID         NUMBER;
     l_PROJECT_NUMBER       VARCHAR2(300);
     l_PROJECT_SOURCE       VARCHAR2(3);
     l_THIRD_PARTY_TYPE     VARCHAR2(1);
     l_JOURNAL_CREATOR      number;
     l_JOURNAL_APPROVER     number;
     l_JOURNAL_POSTER       number;
     l_effective_date       date;

     l_count number;
     l_error_flag varchar(1);
     l_project_flag varchar(15);
     l_history_coa varchar(25);

     l_creator    VARCHAR2(240);
     l_approver   VARCHAR2(240);
     l_poster     VARCHAR2(240);

       cursor c_journals is
       select
              JE_CATEGORY ,
              CURRENCY_CODE,
              THIRD_PARTY_NUMBER,
              PERSONNEL_ID,
              PROJECT_NUMBER,
              PROJECT_SOURCE,
              THIRD_PARTY_TYPE,
              JOURNAL_CREATOR_ID,
              JOURNAL_APPROVER_ID,
              JOURNAL_POSTER_ID,
              DEFAULT_EFFECTIVE_DATE
         from ja_cn_item_interface
         where status = 'P'
         for update;

  BEGIN

    IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.begin'
                     ,'Enter procedure'
                    );


    END IF;  --(l_proc_level >= l_dbg_level)

--fetch the journal line in interface table whose status is 'P';

    open c_journals;
    loop
      fetch c_journals into
                 l_JE_CATEGORY,
                 l_CURRENCY_CODE,
                 l_THIRD_PARTY_NUMBER,
                 l_PERSONNEL_ID,
                 l_PROJECT_NUMBER,
                 l_PROJECT_SOURCE,
                 l_THIRD_PARTY_TYPE,
                 l_JOURNAL_CREATOR,
                 l_JOURNAL_APPROVER,
                 l_JOURNAL_POSTER,
                 l_effective_date;
       exit when c_journals%notfound;

       l_error_flag:='N';

 --validate je_category.
       select count(*)
       into l_count
       from gl_je_categories_tl
       where user_je_category_name = l_JE_CATEGORY;
    --     and  LANGUAGE = userenv('LANG')
       if l_count=0 then
         update ja_cn_item_interface
            set status='ECG1'
          where current of c_journals;
          l_error_flag :='Y';
       end if;
--validate currency code.
       if l_error_flag<>'Y' then
           select count(*)
             into l_count
             from fnd_currencies
            where currency_code = l_CURRENCY_CODE;
           if l_count=0 then
             update ja_cn_item_interface
                set status='ECC1'
              where current of c_journals;
            l_error_flag :='Y';
           end if;
      end if;
--validate THIRD_PARTY_TYPE.
      if l_error_flag<>'Y' and l_THIRD_PARTY_TYPE is not null then
          select count(*)
            into l_count
            from FND_LOOKUP_VALUES
           where LANGUAGE = userenv('LANG')
             and lookup_code = l_THIRD_PARTY_TYPE
             and lookup_type = 'JA_CN_THIRDPARTY_TYPE' ;
           if l_count=0 then
             update ja_cn_item_interface
                set status='ETP1'
              where current of c_journals;
            l_error_flag :='Y';
           end if;
       end if;--l_error_flag<>'Y', for third party type
--if THIRD_PARTY_TYPE is null, but THIRD_PARTY_NUMBER is not null
--set error status as 'ETP2', third party number can't be validated.
      if l_error_flag<>'Y' then
         if l_THIRD_PARTY_TYPE is null and l_THIRD_PARTY_NUMBER is not null then
           update ja_cn_item_interface
              set status='ETP2'
            where current of c_journals;
           l_error_flag :='Y';
          end if;
          if l_THIRD_PARTY_TYPE = 'N' and l_THIRD_PARTY_NUMBER is not null then
           update ja_cn_item_interface
              set status='ETP5'
            where current of c_journals;
           l_error_flag :='Y';
          end if;
      end if;

--validate THIRD_PARTY_NUMBER.
     if l_error_flag<>'Y' then
        if l_THIRD_PARTY_TYPE = 'C' and l_THIRD_PARTY_NUMBER is not null then
            select count(*)
              into l_count
              from Hz_Parties
              where Party_Number =l_THIRD_PARTY_NUMBER;
             if l_count=0 then
               update ja_cn_item_interface
                  set status='ETP3'
                where current of c_journals;
             l_error_flag :='Y';
             end if;
         elsif l_THIRD_PARTY_TYPE = 'S' and l_THIRD_PARTY_NUMBER is not null then
               select count(*)
               into l_count
               from ap_suppliers
               where Segment1  =l_THIRD_PARTY_NUMBER;
              if l_count=0 then
               update ja_cn_item_interface
                  set status='ETP4'
                where current of c_journals;
              l_error_flag :='Y';
              end if;
        end if;--l_THIRD_PARTY_TYPE = 'C' and l_THIRD_PARTY_NUMBER is not null then
      end if;--if l_error_flag<>'Y' , for third party number check
--check personal number
-------------------------------------------------------
    if l_error_flag<>'Y' and l_PERSONNEL_ID is not null then
       select count(*)
         into l_count
         from PER_ALL_PEOPLE_F
        where PERSON_ID = l_PERSONNEL_ID
          and effective_start_date<=l_effective_date
          and effective_end_date>=l_effective_date;
        if l_count=0 then
         update ja_cn_item_interface
            set status='EPR1'
          where current of c_journals;
         l_error_flag :='Y';
        end if;
     end if;
--check project source
    if l_error_flag<>'Y' then
        select count(*)
          into l_count
        from FND_LOOKUP_VALUES
        where lookup_code = l_PROJECT_SOURCE
          and lookup_type like 'JA_CN_PROJECT_SOURCE'
          and LANGUAGE = userenv('LANG') ;
        if l_count=0 then
           update ja_cn_item_interface
              set status='EPS1'
            where current of c_journals;
           l_error_flag :='Y';
         end if;
     end if;  --l_error_flag<>'Y' ,for project source check
--check consistency
--when project source in interface table is PA and it's not consistent
--with the project flag of subsidiary account form.
   if l_error_flag<>'Y' then
       select nvl(project_source_flag,'-1'),nvl(history_coa_segment,'-1')
         into l_project_flag,l_history_coa
         from ja_cn_sub_acc_sources_all
        where chart_of_accounts_id=l_coa;

        if l_project_flag='-1' then
            update ja_cn_item_interface
              set status='EPS4'
            where current of c_journals;
            l_error_flag :='Y';
        end if;

        if l_error_flag <>'Y'and l_PROJECT_SOURCE='PA' and l_project_flag<>l_PROJECT_SOURCE then
           update ja_cn_item_interface
              set status='EPS2'
            where current of c_journals;
            l_error_flag :='Y';
        end if;
  --when project source in interface table is 'COA' and it's not consistent
  --with the project flag of subsidiary account form. And also the history
  --COA segment is null.
  --l_project_flag is 'N',l_history_coa is null
  --l_project_flag is 'N',l_history_coa is not null. this case can't happan. if happen, validated.
  --l_project_flag is 'PA',l_history_coa is null
  --l_project_flag is 'PA',l_history_coa is not null. this case can happen.
        if l_error_flag <>'Y'and l_PROJECT_SOURCE='COA' and l_project_flag<>l_PROJECT_SOURCE and l_history_coa='-1'then
           update ja_cn_item_interface
              set status='EPS3'
            where current of c_journals;
            l_error_flag :='Y';
        end if;
    end if;-- l_error_flag<>'Y', for project number check
----------------------------------------------------------
--check project number when project source is 'PA'
   if l_error_flag<>'Y' then
        if l_PROJECT_SOURCE='N' and l_PROJECT_NUMBER is not null then
             update ja_cn_item_interface
                set status='EPN3'
              where current of c_journals;
             l_error_flag :='Y';

        end if;
        if l_PROJECT_SOURCE='PA' and l_PROJECT_NUMBER is not null then
           select count(*)
             into l_count
           from PA_PROJECTS_ALL
           where SEGMENT1=l_PROJECT_NUMBER;
           if l_count=0 then
             update ja_cn_item_interface
                set status='EPN1'
              where current of c_journals;
             l_error_flag :='Y';
           end if;
        end if; --if l_PROJECT_SOURCE='PA' and l_PROJECT_NUMBER is not null then
    --check project number when project source is 'COA'
        if l_PROJECT_SOURCE='COA' and l_PROJECT_NUMBER is not null then
              select count(*)
              into l_count
              from FND_FLEX_VALUES ffv,
                   FND_ID_FLEX_SEGMENTS fifs
               where ffv.flex_value_set_id=fifs.flex_value_set_id
                 and fifs.id_flex_code='GL#'
                 and fifs.id_flex_num=l_coa
                 and (fifs.application_column_name =(select coa_segment
                                                from ja_cn_sub_acc_sources_all
                                                where chart_of_accounts_id=l_coa
                                                  and coa_segment is not null)
                  or fifs.application_column_name =(select history_coa_segment
                                                from ja_cn_sub_acc_sources_all
                                                where chart_of_accounts_id=l_coa
                                                  and history_coa_segment is not null) )
                 AND flex_value = l_PROJECT_NUMBER  ;
             if l_count=0 then
             update ja_cn_item_interface
                set status='EPN2'
              where current of c_journals;
             l_error_flag :='Y';
             end if;  --l_count=0
        end if; --l_PROJECT_SOURCE='COA' and l_PROJECT_NUMBER is not null
    end if;--l_error_flag<>'Y', for project number;
    -------------------------------------------
--check journal creator, if not null, change id to name
    if l_error_flag<>'Y' and l_JOURNAL_CREATOR is not null then
        begin
          select Last_Name || First_Name Full_Name
            into l_creator
            from Per_All_People_f
           where person_id = l_JOURNAL_CREATOR
             AND EFFECTIVE_START_DATE<=L_EFFECTIVE_DATE
             AND EFFECTIVE_END_DATE>=L_EFFECTIVE_DATE;
        /*
         update ja_cn_item_interface
            set journal_creator_id = l_creator
          where journal_creator_id = l_JOURNAL_CREATOR;        */
        exception
          when no_data_found then
             update ja_cn_item_interface
                set status='EJC1'
              where current of c_journals;
             l_error_flag :='Y';
        end;
     end if;
--check journal approver,if not null, change id to name
    if l_error_flag<>'Y' and l_JOURNAL_APPROVER is not null then
      begin
          select Last_Name || First_Name Full_Name
            into l_approver
            from Per_All_People_f
           where person_id =l_JOURNAL_APPROVER
             AND EFFECTIVE_START_DATE<=L_EFFECTIVE_DATE
             AND EFFECTIVE_END_DATE>=L_EFFECTIVE_DATE;
   /*
         update ja_cn_item_interface
            set journal_creator_id = l_approver
          where journal_creator_id = l_JOURNAL_APPROVER;   */
        exception
          when no_data_found then
             update ja_cn_item_interface
                set status='EJA1'
              where current of c_journals;
             l_error_flag :='Y';
        end;
     end if;
--check journal poster,if not null, change id to name
    if l_error_flag<>'Y' and l_JOURNAL_POSTER is not null then
        begin
          select Last_Name || First_Name Full_Name
            into l_poster
            from Per_All_People_f
           where person_id = l_JOURNAL_POSTER
             AND EFFECTIVE_START_DATE<=L_EFFECTIVE_DATE
             AND EFFECTIVE_END_DATE>=L_EFFECTIVE_DATE;
     /*
         update ja_cn_item_interface
            set journal_creator_id = l_poster
          where journal_creator_id = l_JOURNAL_POSTER;       */
        exception
          when no_data_found then
             update ja_cn_item_interface
                set status='EJP1'
              where current of c_journals;
             l_error_flag :='Y';
        end;

     end if;

    end loop;
    close c_journals;

  --  select * from  gl_je_categories_tl where user_je_category_name =


    EXCEPTION

      WHEN OTHERS THEN
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.Other_Exception '
                         ,SQLCODE||':'||SQLERRM);
        END IF;  --(l_proc_level >= l_dbg_level)


  END Base_Validation;
 --==========================================================================
  --  FUNCTION NAME:
  --  Legal_consistent_Validation                 Public
  --
  --  DESCRIPTION:
  --  check legal entity id
  --  If comany segment is not consistent with the legal and ledger
  --  set status 'ECS1'
  --
  --  PARAMETERS:
  --      P_LEGAL_ENTITY_ID       legal entity id
  --      P_LEDGER_ID             ledger id
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --  09/08/2007     yanbo liu        created
  --===========================================================================

 PROCEDURE Company_Segment_Validation( P_LEGAL_ENTITY_ID IN NUMBER,
                                       P_LEDGER_ID       IN NUMBER
                                      ) IS

    l_dbg_level               NUMBER        :=FND_LOG.G_Current_Runtime_Level;
    l_proc_level              NUMBER        :=FND_LOG.Level_Procedure;
    l_proc_name               VARCHAR2(100) :='Company_Segment_Validation';

   l_sql    varchar2(1000);

  BEGIN

    IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.begin'
                     ,'Enter procedure'
                    );

      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'Legal Entity ID '||P_LEGAL_ENTITY_ID
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'Ledger ID '||P_LEDGER_ID
                    );


    END IF;  --(l_proc_level >= l_dbg_level)

    --do prepare
    --populate BSV for current legal entity and ledger
   /*
    l_Populate_Bsv_Flag := Ja_Cn_Utility.Populate_Ledger_Le_Bsv_Gt(P_Ledger_Id,
                                                                   P_Legal_Entity_Id);
    IF l_Populate_Bsv_Flag = 'F' THEN
      IF (l_Proc_Level >= l_Dbg_Level) THEN
        Fnd_Log.STRING(l_Proc_Level,
                       l_Module_Prefix || '.' || l_Proc_Name,
                       'fail to populate BSV');
      END IF; --(l_proc_level >= l_dbg_level)
    END IF;
 */
      l_sql := 'UPDATE JA_CN_ITEM_INTERFACE
         SET status=''ECS1''
       WHERE status=''P''
         AND ' || l_Company_Column_Name ||
        ' NOT IN
             (SELECT bsv.bal_seg_value
                FROM ja_cn_ledger_le_bsv_gt bsv
               WHERE Legal_Entity_Id = '|| P_LEGAL_ENTITY_ID ||
               ' AND ledger_id = '|| P_LEDGER_ID||') ';

      execute immediate l_sql;

    EXCEPTION

      WHEN OTHERS THEN
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.Other_Exception '
                         ,SQLCODE||':'||SQLERRM);
        END IF;  --(l_proc_level >= l_dbg_level)


  END Company_Segment_Validation;

 --==========================================================================
  --  FUNCTION NAME:
  --  Balance_Validation                 Public
  --
  --  DESCRIPTION:
  --  If the DR sum and CR sum not balance in the same journal,same legal entity id
  --  and the same company segment, set status 'EB01'.
  --
  --  PARAMETERS:
  --
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --  07/09/2007     yanbo liu        created
  --===========================================================================


  PROCEDURE Balance_Validation(p_legal_entity_id IN NUMBER) IS

    l_dbg_level               NUMBER        :=FND_LOG.G_Current_Runtime_Level;
    l_proc_level              NUMBER        :=FND_LOG.Level_Procedure;
    l_proc_name               VARCHAR2(100) :='Balance_Validation';

    l_dr number(15);
    l_cr number(15);
    l_account_dr number(15);
    l_account_cr number(15);
    l_journal_group number;
    l_legal_entity_id number;
    l_Company_segment varchar2(25);
    l_sql varchar2(1000);
    l_sql1 varchar2(1000);


    TYPE BalanceCurTyp IS REF CURSOR;
    c_bl_journal                 BalanceCurTyp;

  BEGIN

    IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.begin'
                     ,'Enter procedure'
                    );


    END IF;  --(l_proc_level >= l_dbg_level)

    l_sql:='select journal_group,
                   legal_entity_id, '||
                   l_Company_Column_Name||
                   ',sum(ENTERED_DR),
                   sum(ENTERED_CR),
                   sum(ACCOUNTED_DR),
                   SUM(ACCOUNTED_cR)
              from ja_cn_item_interface
              where status=''P''
                and '|| l_Company_Column_Name||' is not null
                and legal_entity_id= '||p_legal_entity_id||
              ' group by journal_group,
                       legal_entity_id,'
                       ||l_Company_Column_Name;

    --update the status 'EB01' if not balance.
       OPEN c_bl_journal FOR l_sql;
          loop
             fetch c_bl_journal into  l_journal_group,
                                      l_legal_entity_id,
                                      l_Company_segment,
                                      l_dr,
                                      l_cr,
                                      l_account_dr,
                                      l_account_cr;
              EXIT WHEN c_bl_journal%NOTFOUND;
              if l_dr<>l_cr then
                 l_sql1:='update ja_cn_item_interface
                 set status=''EB01''
                 where status = ''P''
                 and journal_group ='|| l_journal_group||
                 ' and legal_entity_id ='|| l_legal_entity_id ||
                 ' and '|| l_Company_Column_Name||'='||l_Company_segment;
                 execute immediate l_sql1;
               --  commit;
              end if;
              if l_account_dr<>l_account_cr then
                 l_sql1:='update ja_cn_item_interface
                 set status=''EB02''
                 where status = ''P''
                 and journal_group ='|| l_journal_group||
                 ' and legal_entity_id ='|| l_legal_entity_id ||
                 ' and '|| l_Company_Column_Name||'='||l_Company_segment;
                 execute immediate l_sql1;
               --  commit;
              end if;

          end loop;
       close c_bl_journal;


    EXCEPTION

      WHEN OTHERS THEN
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.Other_Exception '
                         ,SQLCODE||':'||SQLERRM);
        END IF;  --(l_proc_level >= l_dbg_level)


  END Balance_Validation;

 --==========================================================================
  --  FUNCTION NAME:
  --  Code_Combination_Validation                 Public
  --
  --  DESCRIPTION:
  --  code combination id can't be null in table ja_cn_journal_lines.
  --  user can input it in two ways, directly the code combination id
  --  and the segment combination. So the correctness and the consistency
  --  of the two ways should be validated.
  --
  --  PARAMETERS:
  --      P_LEDGER_ID          ledger id
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --  07/09/2007     yanbo liu        created
  --===========================================================================

  PROCEDURE Code_Combination_Validation( P_LEDGER_ID       IN NUMBER) IS

    l_dbg_level               NUMBER        :=FND_LOG.G_Current_Runtime_Level;
    l_proc_level              NUMBER        :=FND_LOG.Level_Procedure;
    l_proc_name               VARCHAR2(100) :='Code_Combination_Validation';

   v_code NUMBER;
   v_errm VARCHAR2(64);

    TYPE SEGMENT_TBL IS TABLE OF gl_code_combinations.segment1%type;
    l_segments  SEGMENT_TBL;
    l_segment_index number;
    l_segment_name gl_code_combinations.segment1%type;
    l_count  number(2);
    i        number(2);
    l_sql    VARCHAR2(1000);
    TYPE SEGMENT_CONTEXT_TBL IS TABLE OF VARCHAR2(25);
    l_segment_context  SEGMENT_CONTEXT_TBL;
    l_status varchar(25);
    l_sql_segment1 varchar2(1000);
    l_sql_segment2 varchar2(1000);
    l_ccid    number;
    l_ccid1   number;
    l_status  varchar2(10);
    l_ccid_count number;
    l_Company_value varchar2(25);
    l_Account_value varchar2(25);
    l_Cost_CRT_value varchar2(25);
    l_Rowid rowid;

    TYPE InstSegCurTyp IS REF CURSOR;
    c_Inst_segments     InstSegCurTyp;

    cursor c_ccid_check is
    select code_combination_id
      from ja_cn_item_interface
     where (status = 'P1'
        or status = 'P2')
       and code_combination_id is not null
       for update ;

    cursor c_set_segment is
    select code_combination_id,
           rowid
      from ja_cn_item_interface
     where status = 'P1'
       and code_combination_id is not null
       for update;

    cursor c_segments is
    select segment1,
           segment2,
           segment3,
           segment4,
           segment5,
           segment6,
           segment7,
           segment8,
           segment9,
           segment10,
           segment11,
           segment12,
           segment13,
           segment14,
           segment15,
           segment16,
           segment17,
           segment18,
           segment19,
           segment20,
           segment21,
           segment22,
           segment23,
           segment24,
           segment25,
           segment26,
           segment27,
           segment28,
           segment29,
           segment30,
           code_combination_id
     from ja_cn_item_interface
     where status='P2'
     for update;


  --   and   code_combination_id is null;
  BEGIN

    IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.begin'
                     ,'Enter procedure'
                    );

      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'Legal Entity ID '||P_LEDGER_ID
                    );


    END IF;  --(l_proc_level >= l_dbg_level)
--if all the segments are null, set status 'P1'
    update ja_cn_item_interface
       set status='P1'
     where segment1 is null
       and segment2 is null
       and segment3 is null
       and segment4 is null
       and segment5 is null
       and segment6 is null
       and segment7 is null
       and segment8 is null
       and segment9 is null
       and segment10 is null
       and segment11 is null
       and segment12 is null
       and segment13 is null
       and segment14 is null
       and segment15 is null
       and segment16 is null
       and segment17 is null
       and segment18 is null
       and segment19 is null
       and segment20 is null
       and segment21 is null
       and segment22 is null
       and segment23 is null
       and segment24 is null
       and segment25 is null
       and segment26 is null
       and segment27 is null
       and segment28 is null
       and segment29 is null
       and segment30 is null
       and status='P';
--others lines whose status is 'P',set status 'P2'
    update ja_cn_item_interface
       set status='P2'
     where status='P';

     update ja_cn_item_interface
        set status='EC01'
      where status='P1'
        and code_combination_id is null;

--for the journal whose status is 'P1' or 'P2', check the CCID column is right or not.
--if CCID in interface table is not defined in gl_code_combiantion table then set stats
--'EC02'
     open c_ccid_check;
     loop
        fetch c_ccid_check into l_ccid;
        exit when c_ccid_check%notfound;
        select count(*)
          into l_ccid_count
          from gl_code_combinations
         where code_combination_id=l_ccid
           and chart_of_accounts_id=l_coa;
        if l_ccid_count = 0 then
           update ja_cn_item_interface
              set status = 'EC02'
            where current of c_ccid_check;
     --       commit;
        end if;
     end loop;
     close c_ccid_check;
--now if the status is 'P1', the ccid is right.
--get the segment value according to CCID.
    open c_set_segment;
    loop
        fetch c_set_segment into l_ccid,l_rowid;
        exit when c_set_segment%notfound;
        l_sql:='select '|| l_Company_Column_Name ||', '
                        || l_Account_Column_Name ||', '
                        || l_Cost_CRT_Column_Name ||
               ' from gl_code_combinations
                where code_combination_id=' || l_ccid ||
                 ' and chart_of_accounts_id='|| l_coa;
         open c_Inst_segments for l_sql;
         loop
           fetch c_Inst_segments into l_Company_value,l_Account_value,l_Cost_CRT_value;
           exit when c_Inst_segments%notfound;
         end loop;
         close c_Inst_segments;

         l_sql:='update ja_cn_item_interface set '
                 || l_Company_Column_Name ||' = ''' || l_Company_value ||''', '
                 || l_Account_Column_Name ||' = ''' || l_Account_value ||''', '
                 || l_Cost_CRT_Column_Name ||' = ''' || l_Cost_CRT_value ||'''
                  where rowid='''||l_rowid||'''';
         execute immediate l_sql;
    --    commit;
    end loop;
    close c_set_segment;

 --check the segments combination is right or not.
 --if it doesn't map a ccid in table ja_cn_item_interface
 --set status 'EC03'
    l_segment_context:=SEGMENT_CONTEXT_TBL();
    l_segment_context.extend(30);
    l_count:=0;
    i:=1;
     open c_segments;
     loop
       fetch c_segments into
             l_segment_context(1),
             l_segment_context(2),
             l_segment_context(3),
             l_segment_context(4),
             l_segment_context(5),
             l_segment_context(6),
             l_segment_context(7),
             l_segment_context(8),
             l_segment_context(9),
             l_segment_context(10),
             l_segment_context(11),
             l_segment_context(12),
             l_segment_context(13),
             l_segment_context(14),
             l_segment_context(15),
             l_segment_context(16),
             l_segment_context(17),
             l_segment_context(18),
             l_segment_context(19),
             l_segment_context(20),
             l_segment_context(21),
             l_segment_context(22),
             l_segment_context(23),
             l_segment_context(24),
             l_segment_context(25),
             l_segment_context(26),
             l_segment_context(27),
             l_segment_context(28),
             l_segment_context(29),
             l_segment_context(30),
             l_ccid;
       exit when c_segments%notfound;
       begin
            select code_combination_id
            into l_ccid1
            from gl_code_combinations
            where nvl(segment1,-1)=nvl(l_segment_context(1),-1)
              and nvl(segment2,-1)=nvl(l_segment_context(2),-1)
              and nvl(segment3,-1)=nvl(l_segment_context(3),-1)
              and nvl(segment4,-1)=nvl(l_segment_context(4),-1)
              and nvl(segment5,-1)=nvl(l_segment_context(5),-1)
              and nvl(segment6,-1)=nvl(l_segment_context(6),-1)
              and nvl(segment7,-1)=nvl(l_segment_context(7),-1)
              and nvl(segment8,-1)=nvl(l_segment_context(8),-1)
              and nvl(segment9,-1)=nvl(l_segment_context(9),-1)
              and nvl(segment10,-1)=nvl(l_segment_context(10),-1)
              and nvl(segment11,-1)=nvl(l_segment_context(11),-1)
              and nvl(segment12,-1)=nvl(l_segment_context(12),-1)
              and nvl(segment13,-1)=nvl(l_segment_context(13),-1)
              and nvl(segment14,-1)=nvl(l_segment_context(14),-1)
              and nvl(segment15,-1)=nvl(l_segment_context(15),-1)
              and nvl(segment16,-1)=nvl(l_segment_context(16),-1)
              and nvl(segment17,-1)=nvl(l_segment_context(17),-1)
              and nvl(segment18,-1)=nvl(l_segment_context(18),-1)
              and nvl(segment19,-1)=nvl(l_segment_context(19),-1)
              and nvl(segment20,-1)=nvl(l_segment_context(20),-1)
              and nvl(segment21,-1)=nvl(l_segment_context(21),-1)
              and nvl(segment12,-1)=nvl(l_segment_context(22),-1)
              and nvl(segment23,-1)=nvl(l_segment_context(23),-1)
              and nvl(segment24,-1)=nvl(l_segment_context(24),-1)
              and nvl(segment25,-1)=nvl(l_segment_context(25),-1)
              and nvl(segment26,-1)=nvl(l_segment_context(26),-1)
              and nvl(segment27,-1)=nvl(l_segment_context(27),-1)
              and nvl(segment28,-1)=nvl(l_segment_context(28),-1)
              and nvl(segment29,-1)=nvl(l_segment_context(29),-1)
              and nvl(segment30,-1)=nvl(l_segment_context(30),-1)
              and chart_of_accounts_id=l_coa;
              if l_ccid is null then
                 update ja_cn_item_interface
                    set Code_Combination_id=l_ccid1
                  where current of c_segments;
              elsif l_ccid is not null then
                  if l_ccid<>l_ccid1 then
                    update ja_cn_item_interface
                       set status='EC04'
                     where current of c_segments;
                  end if;
              end if;
          exception
          when no_data_found then
             update ja_cn_item_interface
                set status='EC03'
              where current of c_segments;
          end;
     end loop;
     close c_segments ;

     update ja_cn_item_interface
        set status='P'
      where status in('P1','P2');

--now all the segments combination is right,
--all the ccid is right if not null.
--if ccid is null, then set ccid.

---------------------------------------------------


    EXCEPTION
      WHEN OTHERS THEN
         v_code := SQLCODE;
         v_errm := SUBSTR(SQLERRM, 1 , 64);

        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.Other_Exception '
                         ,SQLCODE||':'||SQLERRM);
        END IF;  --(l_proc_level >= l_dbg_level)


  END Code_Combination_Validation;

    --==========================================================================
  --  FUNCTION NAME:
  --  Validation                 Public
  --
  --  DESCRIPTION:
  --    This procedure is used to validate the data in interface table, if the
  --    data is not reasonable, set the error status. if right, set the status
  --    as 'S'. This program will call several sub validation program.
  --
  --  PARAMETERS:
  --      P_LEDGER_ID            ledger id
  --      P_LEGAL_ENTITY_ID      legal entity id
  --      P_PERIOD_FROM          period from
  --      P_PERIOD_TO            period to
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --  07/09/2007     yanbo liu        created
  --===========================================================================
  PROCEDURE Validation( P_LEDGER_ID       IN NUMBER,
                        P_LEGAL_ENTITY_ID IN NUMBER,
                        P_PERIOD_FROM     IN VARCHAR2,
                        P_PERIOD_TO       IN VARCHAR2
                        ) IS

    l_dbg_level               NUMBER        :=FND_LOG.G_Current_Runtime_Level;
    l_proc_level              NUMBER        :=FND_LOG.Level_Procedure;
    l_proc_name               VARCHAR2(100) :='Validation';



  BEGIN

    IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.begin'
                     ,'Enter procedure'
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'Ledger ID '||P_LEDGER_ID
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'Legal Entity ID '||P_LEGAL_ENTITY_ID
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'Period From '||P_PERIOD_FROM
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'Period To '||P_PERIOD_TO
                    );

    END IF;  --(l_proc_level >= l_dbg_level)

      --first update set status is null for all journals in interface table.
     update ja_cn_item_interface
     set status = null;
    -- commit;

    --filter journals by parameter. set the status of journal which will be validated as p.
    update ja_cn_item_interface
    set status = 'P'
    where --legal_entity_id = P_LEGAL_ENTITY_ID and--this condition will be put the legal_consistent validation
         ledger_id =  P_LEDGER_ID
    and period_name in(
                  SELECT Gp.Period_Name
                FROM Gl_Periods Gp, Gl_Ledgers Led
               WHERE Led.Ledger_Id = p_Ledger_Id
                 AND Led.Period_Set_Name = Gp.Period_Set_Name
                 AND Led.Accounted_Period_Type = Gp.Period_Type
                 AND Gp.Start_Date BETWEEN
                     (SELECT Start_Date
                        FROM Gl_Periods Gp
                       WHERE Led.Period_Set_Name = Gp.Period_Set_Name
                         AND Led.Accounted_Period_Type = Gp.Period_Type
                         AND Gp.Period_Name = P_PERIOD_FROM )
                 AND (SELECT Start_Date
                        FROM Gl_Periods Gp
                       WHERE Led.Period_Set_Name = Gp.Period_Set_Name
                         AND Led.Accounted_Period_Type = Gp.Period_Type
                         AND Gp.Period_Name = P_PERIOD_TO)
                        );
      -- commit;
    -------------------------------------------------------------------
    --1, check legal entity id
    --Legal entity id of journal lines must be consistent with legal entity id
    --defined in JA: CN Legal Entity. or else,set status as 'L'.
    ---------------------------------------------------------------

    Legal_consistent_Validation(P_LEGAL_ENTITY_ID);
    --------------------------------------------------------------------
    --do base validation
    Base_Validation();

     ---------------------------------------------------------------------
     --2,check code_combination_id
     --The code combination id is option to input for user.
     --the segment combination is also option to input for user.
     -- if both of them are input, they must be consistent. if not,
     -- set status EC04
     --if one is input, but it can't be find in table gl_code_combinations
     --the status will be EC02 or EC03.
     --if only segment combination is input,set value for code combination
     --id to interface table. the status is 'p'
     --if only code combination id is input, set company segment, account
     --segment and cost center segment according to ccid. set status 'P'
     --if both of them isn't input, set status EC05.
     --before do the check described above, the segment count will be
     --checked first, if it is not consistent with segment count of
     --current ledger. set status EC01
     ----------------------------------------------------------------------
     Code_Combination_Validation(P_LEDGER_ID);

     --check whether the company segment is consistency paramter legal and ledger
     Company_Segment_Validation( P_LEGAL_ENTITY_ID,
                                 P_LEDGER_ID  );
     --check whether DR amount and CR amount equal or not
     --group by journal group, legal_entity_id , company segment.

     Balance_Validation(P_LEGAL_ENTITY_ID);

    --at last set the journal which is validated to 'S'
     update ja_cn_item_interface
        set status='S'
      where status='P';
    --  commit;

    EXCEPTION

      WHEN OTHERS THEN
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.Other_Exception '
                         ,SQLCODE||':'||SQLERRM);
        END IF;  --(l_proc_level >= l_dbg_level)


  END Validation;

  --==========================================================================
  --  FUNCTION NAME:
  --  Set_flag_P                Public
  --
  --  DESCRIPTION:
  --  set a flag 'P' for journals in table gl_je_lines to identify them as
  --  processed journal according to the paramter input.
  --
  --  PARAMETERS:
  --      P_LEDGER_ID            ledger id
  --      P_LEGAL_ENTITY_ID      legal entity id
  --      P_PERIOD_FROM          period from
  --      P_PERIOD_TO            period to
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --  07/09/2007     yanbo liu        created
  --===========================================================================
  PROCEDURE Set_flag_P( P_LEDGER_ID       IN NUMBER,
                        P_LEGAL_ENTITY_ID IN NUMBER,
                        P_PERIOD_FROM     IN VARCHAR2,
                        P_PERIOD_TO       IN VARCHAR2
                        ) IS

    l_Populate_Journal_Sql VARCHAR2(4000);
    l_Start_Period         VARCHAR2(15);
    l_End_Period           VARCHAR2(15);
    l_ledger_id            number;
    l_legal_entity_id      number;

    l_Dbg_Level         NUMBER := Fnd_Log.g_Current_Runtime_Level;
    l_Proc_Level        NUMBER := Fnd_Log.Level_Procedure;
    l_Proc_Name         VARCHAR2(100) := 'Set_flag_p';

    TYPE JECurTyp IS REF CURSOR;
    c_journal                 JECurTyp;

     l_header_id   number;
     l_line_num    number;



  BEGIN

    IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.begin'
                     ,'Enter procedure'
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'Ledger ID '||P_LEDGER_ID
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'Legal Entity ID '||P_LEGAL_ENTITY_ID
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'Period From '||P_PERIOD_FROM
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'Period To '||P_PERIOD_TO
                    );

    END IF;  --(l_proc_level >= l_dbg_level)

    l_Start_Period    := P_PERIOD_FROM ;
    l_End_Period      := P_PERIOD_TO;
    l_ledger_id       := p_ledger_id;
    l_legal_entity_id := P_legal_entity_id;
    --populate BSV for current legal entity and ledger
    /*
    l_Populate_Bsv_Flag := Ja_Cn_Utility.Populate_Ledger_Le_Bsv_Gt(l_Ledger_Id,
                                                                   l_Legal_Entity_Id);
    IF l_Populate_Bsv_Flag = 'F' THEN
      IF (l_Proc_Level >= l_Dbg_Level) THEN
        Fnd_Log.STRING(l_Proc_Level,
                       l_Module_Prefix || '.' || l_Proc_Name,
                       'fail to populate BSV');
      END IF; --(l_proc_level >= l_dbg_level)
    END IF;
    */

    --generate dynamic sql to find the journal which will be set flag p.

     l_Populate_Journal_Sql :=
                              'SELECT ' ||
                              '       jeh.je_header_id' ||
                              '      ,jel.je_line_num' ||
                  --            '      ,jeh.period_name' ||
                     --         '      ,jeh.je_category' ||
                    --          '      ,jeh.je_source' ||
                   --           '      ,bsv.legal_entity_id' || ',' ||

                  --            ',jeh.default_effective_date ' ||
                              ' FROM gl_je_headers             jeh' ||
                              '   ,gl_je_lines               jel' ||
                              '   ,gl_code_combinations      gcc' ||
                              '   ,gl_periods                gp' ||
                              '   ,gl_ledgers                 led' ||
                              '   ,ja_cn_ledger_le_bsv_gt bsv' ||
                              ' WHERE jeh.je_header_id = jel.je_header_id' ||
                              '   AND jeh.status = ''P''' ||
                              '   AND jeh.period_name = gp.period_name' ||
                              '  AND jel.code_combination_id = gcc.code_combination_id' ||
                              '   AND jeh.LEDGER_ID = ' || l_Ledger_Id ||
                              '   AND gcc.' || l_Company_Column_Name ||
                              ' = bsv.BAL_SEG_VALUE' ||
                              '   AND bsv.legal_entity_id = ' ||
                              l_Legal_Entity_Id ||
                              '   AND gp.start_date BETWEEN' ||
                              '       (SELECT start_date' ||
                              '          FROM gl_periods' ||
                              '         WHERE period_name =''' ||
                              l_Start_Period || '''' ||
                              '           AND period_set_name = led.period_set_name)' ||
                              '   AND (SELECT start_date' ||
                              '          FROM gl_periods' ||
                              '         WHERE period_name =''' ||
                              l_End_Period || '''' ||
                              '           AND period_set_name = led.period_set_name)' ||
                              '   AND gp.period_set_name = led.period_set_name' ||
                              '   AND gp.period_type = led.accounted_period_type' ||
                              '   AND led.ledger_id = jeh.ledger_id' ||
                              '   AND nvl(jel.global_attribute2' ||
                              '          ,''U'') <> ''P''';

    -- set all the journal found in gl_je_lines as processed journal lines.
      OPEN c_journal FOR l_Populate_Journal_Sql;
          loop
             fetch c_journal into l_header_id,l_line_num;
              EXIT WHEN c_journal%NOTFOUND;
             update gl_je_lines
             set global_attribute2='P'
             where je_header_id=l_header_id
             and je_line_num=l_line_num;
          end loop;
      close c_journal;


    EXCEPTION

      WHEN OTHERS THEN
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.Other_Exception '
                         ,SQLCODE||':'||SQLERRM);
        END IF;  --(l_proc_level >= l_dbg_level)


  END Set_flag_P;

  --==========================================================================
  --  FUNCTION NAME:
  --  Generate_Journal_Num                 Public
  --
  --  DESCRIPTION:
  --     This procedure is used to generate journal number based on period
  --     legal entity level, ledger and je_header_id.
  --
  --
  --  PARAMETERS:
  --   p_period_Name      period name
  --   p_ledger_id        ledger id
  --   P_legal_entity_id  legal entity id
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --  07/09/2007     yanbo liu        created
  --===========================================================================

 PROCEDURE Generate_Journal_Num(  p_period_Name IN VARCHAR2,
                                  p_ledger_id   in number,
                                  P_legal_entity_id in number) IS
    l_Period_Name     Gl_Periods.Period_Name%TYPE;
    l_Je_Header_Id    NUMBER;
    l_Journal_Number  NUMBER;
    l_Je_Appending_Id NUMBER;

    l_ledger_id       number;
    l_legal_entity_id number;
    l_Dbg_Level       NUMBER := Fnd_Log.g_Current_Runtime_Level;
    l_Proc_Level      NUMBER := Fnd_Log.Level_Procedure;
    l_Proc_Name       VARCHAR2(100) := 'generate_journal_num';

    v_code NUMBER;
    v_errm VARCHAR2(64);

    --find unpost data in table ja_cn_journal_lines.
    CURSOR c_Journal IS
      SELECT distinct Je_Header_Id
        FROM ja_cn_journal_lines
       WHERE period_name=p_Period_Name
         AND status = 'U'
        order by Je_Header_Id;

   -- for the l_Je_Header_Id, the journal number is created.
    CURSOR c_Journal_Appending IS
      SELECT DISTINCT Je_Header_Id, Journal_Number
        FROM Ja_Cn_Journal_Lines Jl
       WHERE Je_Header_Id = l_Je_Header_Id
         AND Journal_Number IS NOT NULL
         AND Company_Segment IN
             (SELECT bsv.bal_seg_value
                FROM ja_cn_ledger_le_bsv_gt bsv
               WHERE Legal_Entity_Id = l_Legal_Entity_Id
                 and ledger_id = l_ledger_id);

  BEGIN
    --log for debug
    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.begin',
                     'Enter procedure');
    END IF; --(l_proc_level >= l_dbg_level)


    l_Period_Name := p_Period_Name;
    l_legal_entity_id:=p_legal_entity_id;
    l_ledger_id:=p_ledger_id;

    OPEN c_Journal;
    LOOP
      FETCH c_Journal INTO l_Je_Header_Id;
      EXIT WHEN c_Journal%NOTFOUND;

      OPEN c_Journal_Appending;
      FETCH c_Journal_Appending
        INTO l_Je_Appending_Id, l_Journal_Number;

      IF c_Journal_Appending%FOUND THEN
        CLOSE c_Journal_Appending;
        UPDATE Ja_Cn_Journal_Lines jop
           SET Journal_Number = l_Journal_Number
         WHERE Je_Header_Id = l_Je_Header_Id
           AND Journal_Number IS NULL
           AND Company_Segment IN
               (SELECT bsv.bal_seg_value
                  FROM ja_cn_ledger_le_bsv_gt bsv
                 WHERE Legal_Entity_Id = l_Legal_Entity_Id
                   and ledger_id = l_ledger_id);
      ELSE

        CLOSE c_Journal_Appending;
      END IF; --c_journal_appending%FOUND

      --I Think this will casue some problem, maybe update the journals updated above.
      l_Journal_Number := Ja_Cn_Update_Jl_Seq_Pkg.Fetch_Jl_Seq(p_Legal_Entity_Id => l_Legal_Entity_Id,
                                                               p_ledger_id=>l_ledger_id,
                                                               p_Period_Name     => l_Period_Name);

      IF Nvl(l_Journal_Number, 0) > 0 THEN
        UPDATE Ja_Cn_Journal_Lines
           SET Journal_Number = l_Journal_Number
         WHERE Je_Header_Id = l_Je_Header_Id
           AND Company_Segment IN
               (SELECT bsv.bal_seg_value
                  FROM ja_cn_ledger_le_bsv_gt bsv
                 WHERE Legal_Entity_Id = l_Legal_Entity_Id
                   and ledger_id = l_ledger_id);
       END IF;

    END LOOP;
    CLOSE c_Journal;
   -- commit;
  EXCEPTION
    WHEN OTHERS THEN
        v_code := SQLCODE;
        v_errm := SUBSTR(SQLERRM, 1 , 64);
      IF (l_Proc_Level >= l_Dbg_Level) THEN
        Fnd_Log.STRING(l_Proc_Level,
                       l_Module_Prefix || '.' || l_Proc_Name ||
                       '. Other_Exception ',
                       SQLCODE || ':' || SQLERRM);
      END IF; --(l_proc_level >= l_dbg_level)
      RAISE;
  END Generate_Journal_Num;

   --==========================================================================
  --  PROCEDURE NAME:
  --    generate_code_combination_view                   private
  --
  --  DESCRIPTION:
  --        This procedure is used to populate account segment, company segment
  --        cost center segment and project number if project option as 'COA'
  --        into view JA_CN_CODE_COMBINATION_V
  --  PARAMETERS:
  --
  --
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      02/21/2006     Qingjun Zhao          Created
  --      04/10/2006     Qingjun Zhao          Deal with this situation which Cost
  --                                           segment is NULL in current Chart of
  --                                           account
  --===========================================================================
  PROCEDURE Generate_Code_Combination_View(p_ledger_id in number) IS

    l_Create_View_Sql       VARCHAR2(4000);
    l_Company_Column_Name   VARCHAR2(30);
    l_Account_Column_Name   VARCHAR2(30);
    l_Cost_Column_Name      VARCHAR2(30);
    l_Project_Column_Name   VARCHAR2(30);
    l_Dbg_Level             NUMBER := Fnd_Log.g_Current_Runtime_Level;
    l_Proc_Level            NUMBER := Fnd_Log.Level_Procedure;
    l_Proc_Name             VARCHAR2(100) := 'generate_code_combination_view';
    l_Second_Track_Col_Name VARCHAR2(30);
    l_Other_Cols_Name       VARCHAR2(200);
    l_ledger_id             number;
    l_Project_Option        Ja_Cn_Sub_Acc_Sources_All.Project_Source_Flag%type;

    cursor c_Project_Option is
      SELECT Project_Source_Flag
        FROM Ja_Cn_Sub_Acc_Sources_All ja,gl_ledgers gl
        where ja.chart_of_accounts_id=gl.chart_of_accounts_id
        and gl.ledger_id=l_ledger_id;


    CURSOR c_Cost_Center IS
      SELECT Fsav.Application_Column_Name
        FROM Fnd_Id_Flex_Segments         Fifs,
             Fnd_Segment_Attribute_Values Fsav,
             Gl_Ledgers                   Led
       WHERE Fifs.Id_Flex_Num = Fsav.Id_Flex_Num
         AND Fifs.Application_Column_Name = Fsav.Application_Column_Name
         AND Fsav.Segment_Attribute_Type = 'FA_COST_CTR'
         AND Fsav.Attribute_Value = 'Y'
         AND Fifs.Application_Id = 101
         and fsav.id_flex_code = fifs.id_flex_code
         and fsav.id_flex_code = 'GL#'
         AND Fifs.Application_Id = Fsav.Application_Id
         AND Led.Chart_Of_Accounts_Id = Fifs.Id_Flex_Num
         AND Led.Ledger_Id = l_Ledger_Id;

    --jogen
    CURSOR c_Segements IS
      SELECT Fsav.Application_Column_Name
        FROM Fnd_Id_Flex_Segments         Fifs,
             Fnd_Segment_Attribute_Values Fsav,
             Gl_Ledgers                   Led
       WHERE Fifs.Id_Flex_Num = Fsav.Id_Flex_Num
         AND Fifs.Application_Column_Name = Fsav.Application_Column_Name
         AND Fsav.Segment_Attribute_Type = 'GL_GLOBAL'
         AND Fsav.Attribute_Value = 'Y'
         AND Fifs.Application_Id = 101
         and fifs.id_flex_code = fsav.id_flex_code
         and fifs.id_flex_code = 'GL#'
         AND Fifs.Application_Id = Fsav.Application_Id
         AND Led.Chart_Of_Accounts_Id = Fifs.Id_Flex_Num
         AND Led.Ledger_Id = l_Ledger_Id;

    --jogen
  BEGIN

    --log for debug
    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.begin',
                     'Enter procedure');
    END IF; --(l_proc_level >= l_dbg_level)
    l_ledger_id := p_ledger_id;

   OPEN c_Project_Option;
    FETCH c_Project_Option
      INTO l_Project_Option;

    --if "Project" isn't defined,then consider "Project"
    --as "Project Not considered"--'N'
    IF (c_Project_Option%NOTFOUND) THEN
      l_Project_Option := 'N';
    END IF; --(c_project_option%NOTFOUND)
   close c_Project_Option;
    --get application column name of company segment
    SELECT led.bal_seg_column_name
      INTO l_Company_Column_Name
      from gl_ledgers led
     where Led.Ledger_Id = l_Ledger_Id;

    --get application column name of account segment
    SELECT Fsav.Application_Column_Name
      INTO l_Account_Column_Name
      FROM Fnd_Id_Flex_Segments         Fifs,
           Fnd_Segment_Attribute_Values Fsav,
           Gl_Ledgers                   Led
     WHERE Fifs.Id_Flex_Num = Fsav.Id_Flex_Num
       AND Fifs.Application_Column_Name = Fsav.Application_Column_Name
       AND Fsav.Segment_Attribute_Type = 'GL_ACCOUNT'
       AND Fsav.Attribute_Value = 'Y'
       AND Fifs.Application_Id = 101
       and fsav.id_flex_code = fifs.id_flex_code
       and fsav.id_flex_code = 'GL#'
       AND Fifs.Application_Id = Fsav.Application_Id
       AND Led.Chart_Of_Accounts_Id = Fifs.Id_Flex_Num
       AND Led.Ledger_Id = l_Ledger_Id;
    l_Create_View_Sql := 'select GCC.CODE_COMBINATION_ID,led.ledger_id,' ||
                         'gcc.' || l_Company_Column_Name ||
                         ' company_segment,';
    l_Create_View_Sql := l_Create_View_Sql || 'gcc.' ||
                         l_Account_Column_Name || ' account_segment,';

    --get application column name of cost center segment
    OPEN c_Cost_Center;
    FETCH c_Cost_Center
      INTO l_Cost_Column_Name;

    IF c_Cost_Center%NOTFOUND THEN
      CLOSE c_Cost_Center;
      l_Create_View_Sql := l_Create_View_Sql ||
                           ' to_char(null)  cost_segment,';
    ELSE
      l_Create_View_Sql := l_Create_View_Sql || 'gcc.' ||
                           l_Cost_Column_Name || ' cost_segment,';
      CLOSE c_Cost_Center;
    END IF; --c_cost_center%NOTFOUND

    IF l_Project_Option = 'COA' THEN
      --get application column name of project segment
      SELECT Coa_Segment
        INTO l_Project_Column_Name
        FROM Ja_Cn_Sub_Acc_Sources_All ja,gl_ledgers gl
       WHERE ja.Chart_Of_Accounts_Id =gl.Chart_Of_Accounts_Id
         and gl.ledger_id=l_ledger_id;
      l_Create_View_Sql := l_Create_View_Sql || 'gcc.' ||
                           l_Project_Column_Name || ' project_number,';
    ELSE
      l_Create_View_Sql := l_Create_View_Sql || 'to_char(null)' ||
                           ' project_number,';
    END IF; --l_project_option = 'COA'

    ---jogen
    BEGIN
      SELECT Fsav.Application_Column_Name
        INTO l_Second_Track_Col_Name
        FROM Fnd_Id_Flex_Segments         Fifs,
             Fnd_Segment_Attribute_Values Fsav,
             Gl_Ledgers                   Led
       WHERE Fifs.Id_Flex_Num = Fsav.Id_Flex_Num
         AND Fifs.Application_Column_Name = Fsav.Application_Column_Name
         AND Fsav.Segment_Attribute_Type = 'GL_SECONDARY_TRACKING'
         AND Fsav.Attribute_Value = 'Y'
         AND Fifs.Application_Id = 101
         and fifs.id_flex_code = fsav.id_flex_code
         and fsav.id_flex_code = 'GL#'
         AND Fifs.Application_Id = Fsav.Application_Id
         AND Led.Chart_Of_Accounts_Id = Fifs.Id_Flex_Num
         AND Led.Ledger_Id = l_Ledger_Id;
    EXCEPTION
      WHEN No_Data_Found THEN
        NULL;
    END;

    IF l_Second_Track_Col_Name IS NULL THEN
      l_Second_Track_Col_Name := 'NULL';
    END IF;

    FOR Rec_Segment IN c_Segements LOOP
      IF Rec_Segment.Application_Column_Name NOT IN
         (l_Company_Column_Name, l_Account_Column_Name, l_Cost_Column_Name,
          l_Second_Track_Col_Name) THEN
        l_Other_Cols_Name := l_Other_Cols_Name || '||''.''||' ||
                             Rec_Segment.Application_Column_Name;
      END IF;
    END LOOP;

    IF l_Other_Cols_Name IS NULL THEN
      l_Other_Cols_Name := 'NULL';
    ELSE
      l_Other_Cols_Name := Substr(l_Other_Cols_Name, 8);
    END IF;

    l_Create_View_Sql := l_Create_View_Sql || l_Second_Track_Col_Name ||
                         ' second_tracking_col,' || l_Other_Cols_Name ||
                         ' other_columns,';
    --jogen
    l_Create_View_Sql := l_Create_View_Sql ||
                         'to_number(null)  project_id from gl_code_combinations gcc,' ||
                         ' GL_LEDGERS led where led.chart_of_accounts_id ' ||
                         ' = gcc.chart_of_accounts_id';

    l_Create_View_Sql := 'create or replace view ja_cn_code_combination_v as ' ||
                         l_Create_View_Sql;

    --log for debug
    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name,
                     'l_create_view_sql:' || l_Create_View_Sql);
    END IF; --(l_proc_level >= l_dbg_level)

    EXECUTE IMMEDIATE l_Create_View_Sql;

    --log for dubug
    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.end',
                     'Enter procedure');
    END IF; --(l_proc_level >= l_dbg_level)

  EXCEPTION
    WHEN OTHERS THEN
      FND_FILE.put_line(FND_FILE.OUTPUT,SQLCODE || ':' || SQLERRM);
      --log for debug
      IF (l_Proc_Level >= l_Dbg_Level) THEN
        Fnd_Log.STRING(l_Proc_Level,
                       l_Module_Prefix || '.' || l_Proc_Name ||
                       '. Other_Exception ',
                       SQLCODE || ':' || SQLERRM);
      END IF; --(l_proc_level >= l_dbg_level)
      RAISE;
  END Generate_Code_Combination_View;

      --==========================================================================
  --  FUNCTION NAME:
  --  Import_Itemization_Data                Public
  --
  --  DESCRIPTION:
  --    This procedure is the main program of itemization interface program.
  --    It will process the data in interface table and import them into
  --    table ja_cn_journal_lines. At last post journals to ja_cn_account_balances.
  --
  --
  --  PARAMETERS:
  --      P_LEDGER_ID            ledger id
  --      P_LEGAL_ENTITY_ID      legal entity id
  --      P_PERIOD_FROM          period from
  --      P_PERIOD_TO            period to
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --  08/09/2007     yanbo liu        created
  --===========================================================================
  procedure put_xml(P_LEDGER_ID       IN NUMBER,
                    P_LEGAL_ENTITY_ID IN NUMBER,
                    P_PERIOD_FROM     IN VARCHAR2,
                    P_PERIOD_TO       IN VARCHAR2
                 )is

    l_dbg_level               NUMBER        :=FND_LOG.G_Current_Runtime_Level;
    l_proc_level              NUMBER        :=FND_LOG.Level_Procedure;
    l_proc_name               VARCHAR2(100) :='Put_xml';

    L_XML_ITEM      XMLTYPE;
    L_XML_REPORT    XMLTYPE;
    L_XML_ROOT      XMLTYPE:=null;
    L_XML_PARAMETER XMLTYPE;
    L_XML_LINE     XMLTYPE;

    L_LE_NAME            HR_ALL_ORGANIZATION_UNITS.NAME%TYPE;
    L_LEDGER_NAME        GL_LEDGERS.NAME%TYPE;
    L_JOURNAL_GROUP      JA_CN_ITEM_INTERFACE.JOURNAL_GROUP%TYPE;
    L_JE_LINE_NUM        JA_CN_ITEM_INTERFACE.JE_LINE_NUM%TYPE;
    L_STATUS_CODE        JA_CN_ITEM_INTERFACE.STATUS%TYPE;
    L_DESCRIPTION        FND_LOOKUP_VALUES.DESCRIPTION%TYPE;

    l_period_from          VARCHAR2(15);


    CURSOR C_ERROR_JOURNALS IS
    SELECT JOURNAL_GROUP,
           JE_LINE_NUM,
           STATUS,
           fnd.description
      FROM JA_CN_ITEM_INTERFACE JA,FND_LOOKUP_VALUES FND
     WHERE FND.meaning=JA.status
       AND FND.LANGUAGE = userenv('LANG')
       AND FND.lookup_type='JA_CN_ITEM_ERROR_CODE'
       AND LEDGER_ID = p_ledger_id
       AND STATUS IS NOT NULL
       AND period_name in(
                  SELECT Gp.Period_Name
                FROM Gl_Periods Gp, Gl_Ledgers Led
               WHERE Led.Ledger_Id = p_Ledger_Id
                 AND Led.Period_Set_Name = Gp.Period_Set_Name
                 AND Led.Accounted_Period_Type = Gp.Period_Type
                 AND Gp.Start_Date BETWEEN
                     (SELECT Start_Date
                        FROM Gl_Periods Gp
                       WHERE Led.Period_Set_Name = Gp.Period_Set_Name
                         AND Led.Accounted_Period_Type = Gp.Period_Type
                         AND Gp.Period_Name = L_PERIOD_FROM )
                 AND (SELECT Start_Date
                        FROM Gl_Periods Gp
                       WHERE Led.Period_Set_Name = Gp.Period_Set_Name
                         AND Led.Accounted_Period_Type = Gp.Period_Type
                         AND Gp.Period_Name = P_PERIOD_TO)
                        )
         ORDER BY JOURNAL_GROUP,JA.JE_LINE_NUM;
begin
    IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.begin'
                     ,'Enter procedure'
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'Ledger ID '||P_LEDGER_ID
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'Legal Entity ID '||P_LEGAL_ENTITY_ID
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'Period From '||P_PERIOD_FROM
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'Period To '||P_PERIOD_TO
                    );

    END IF;  --(l_proc_level >= l_dbg_level)

    l_period_from:=P_PERIOD_FROM;
    if P_PERIOD_FROM is null then
     --get the first period of current led
        SELECT Gp.Period_Name
          INTO l_period_from
          FROM Gl_Periods Gp, Gl_Ledgers Led
         WHERE Led.Ledger_Id = p_ledger_id
           AND Led.Period_Set_Name = Gp.Period_Set_Name
           AND Led.Accounted_Period_Type = Gp.Period_Type
           AND Gp.Start_Date IN
               (SELECT MIN(Start_Date)
                  FROM Gl_Periods Gp
                 WHERE Led.Period_Set_Name = Gp.Period_Set_Name
                   AND Led.Accounted_Period_Type = Gp.Period_Type);
    end if;


     SELECT name
      INTO l_le_name
      FROM XLE_ENTITY_PROFILES
     WHERE legal_entity_id=p_legal_entity_id;

     SELECT name
       INTO l_ledger_name
       FROM gl_ledgers
      WHERE ledger_id=p_ledger_id;

    --write the parameter infomation into variable l_xml_parameter and last into l_xml_report
    FND_FILE.put_line(FND_FILE.output,'<?xml version="1.0" encoding="utf-8" ?>');
    l_xml_report := NULL;
    SELECT XMLELEMENT("P_LEDGER_NAME",l_ledger_name) INTO l_xml_item FROM dual;
    l_xml_parameter := l_xml_item;
    SELECT XMLELEMENT("P_LEGAL_NAME",l_le_name ) INTO l_xml_item FROM dual;
    SELECT XMLCONCAT(l_xml_parameter,l_xml_item) INTO l_xml_parameter FROM dual;
    SELECT XMLELEMENT("PERIOD_START",P_PERIOD_FROM) INTO l_xml_item FROM dual;
    SELECT XMLCONCAT(l_xml_parameter,l_xml_item) INTO l_xml_parameter FROM dual;
    SELECT XMLELEMENT("PERIOD_END",P_PERIOD_TO) INTO l_xml_item FROM dual;
    SELECT XMLCONCAT(l_xml_parameter,l_xml_item) INTO l_xml_parameter FROM dual;
    SELECT XMLCONCAT(l_xml_report,l_xml_parameter) INTO l_xml_report FROM dual;

    OPEN C_ERROR_JOURNALS;
    LOOP
      FETCH C_ERROR_JOURNALS INTO L_JOURNAL_GROUP,L_JE_LINE_NUM,L_STATUS_CODE,L_DESCRIPTION;
      EXIT WHEN C_ERROR_JOURNALS%NOTFOUND;
      l_xml_line:=NULL;
      SELECT XMLELEMENT("JOURNAL_GROUP",L_JOURNAL_GROUP) INTO l_xml_item FROM dual;
      l_xml_line:=l_xml_item;
      SELECT XMLELEMENT("JE_LINE_NUM",L_JE_LINE_NUM) INTO l_xml_item FROM dual;
      SELECT XMLCONCAT(l_xml_line,l_xml_item) INTO l_xml_line FROM dual;
      SELECT XMLELEMENT("STATUS_CODE",L_STATUS_CODE) INTO l_xml_item FROM dual;
      SELECT XMLCONCAT(l_xml_line,l_xml_item) INTO l_xml_line FROM dual;
      SELECT XMLELEMENT("ERROR_MESSAGE",L_DESCRIPTION) INTO l_xml_item FROM dual;
      SELECT XMLCONCAT(l_xml_line,l_xml_item) INTO l_xml_line FROM dual;
      SELECT XMLELEMENT("ERROR_JOURNAL",l_xml_line) INTO l_xml_line FROM dual;
      SELECT XMLCONCAT(l_xml_report,l_xml_line) INTO l_xml_report FROM dual;
    END LOOP;
    CLOSE C_ERROR_JOURNALS;

    SELECT XMLELEMENT( "REPORT",l_xml_report) INTO l_xml_root FROM dual;
    JA_CN_UTILITY.Output_Conc(l_xml_root.getclobval());


    EXCEPTION

      WHEN OTHERS THEN
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.Other_Exception '
                         ,SQLCODE||':'||SQLERRM);
        END IF;  --(l_proc_level >= l_dbg_level)
end put_xml;

    --==========================================================================
  --  FUNCTION NAME:
  --  Import_Itemization_Data                Public
  --
  --  DESCRIPTION:
  --    This procedure is the main program of itemization interface program.
  --    It will process the data in interface table and import them into
  --    table ja_cn_journal_lines. At last post journals to ja_cn_account_balances.
  --
  --
  --  PARAMETERS:
  --      P_LEDGER_ID            ledger id
  --      P_LEGAL_ENTITY_ID      legal entity id
  --      P_PERIOD_FROM          period from
  --      P_PERIOD_TO            period to
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --  08/09/2007     yanbo liu        created
  --===========================================================================

  PROCEDURE Import_Itemization_Data(Errbuf            OUT NOCOPY VARCHAR2,
                                    Retcode           OUT NOCOPY VARCHAR2,
                                    P_LEGAL_ENTITY_ID IN NUMBER,
                                    P_LEDGER_ID       IN NUMBER,
                                    P_PERIOD_FROM     IN VARCHAR2,
                                    P_PERIOD_TO       IN VARCHAR2
                                    ) IS

    l_dbg_level               NUMBER        :=FND_LOG.G_Current_Runtime_Level;
    l_proc_level              NUMBER        :=FND_LOG.Level_Procedure;
    l_proc_name               VARCHAR2(100) :='Import_Itemization_Data';

     l_Populate_Bsv_Flag        VARCHAR2(1);

    v_code NUMBER;
    v_errm VARCHAR2(64);

    l_Phase                 VARCHAR2(100);
    l_Status                VARCHAR2(100);
    l_Dev_Phase             VARCHAR2(100);
    l_Dev_Status            VARCHAR2(100);
    l_Message               VARCHAR2(100);

    l_period_start          VARCHAR2(15);
    l_period_end            VARCHAR2(15);
    invalid_period_num      number;
    l_Error_Msg             VARCHAR2(2000);

    l_period_from          VARCHAR2(15);
    l_period_to            VARCHAR2(15);
    l_ledger_id            number;
    l_legal_entity_id      number;

    l_journal_group number(15);
    l_header_id     number(15);
    l_sql           varchar2(4000);
    l_Period_Name   varchar(25);

    l_Post_Con_Req_Id number(15):=0;
    l_Result          boolean;
    l_Conc_Succ       BOOLEAN;
    l_Post_Fail EXCEPTION;
 --   l_Phase_Code            Fnd_Lookup_Values.Lookup_Code%TYPE;
 --   l_Status_Code           Fnd_Lookup_Values.Lookup_Code%TYPE;
   l_third_party_number  ja_cn_journal_lines.third_party_number%type;
   l_third_party_id      ja_cn_journal_lines.third_party_id%type;
   l_third_party_type    ja_cn_journal_lines.third_party_type%type;
   l_project_number     ja_cn_journal_lines.project_number%type;
   l_project_id         ja_cn_journal_lines.project_id%type;
   l_project_source     ja_cn_journal_lines.project_source%type;

   l_PERSONNEL_id       ja_cn_journal_lines.personnel_id%type;
   l_PERSONNEL_NUMBER   ja_cn_journal_lines.PERSONNEL_NUMBER%type;

   l_creator            ja_cn_journal_lines.journal_creator%type;
   l_creator_id         ja_cn_journal_lines.journal_creator%type;
   l_APPROVER           ja_cn_journal_lines.journal_APPROVER%type;
   l_APPROVER_id        ja_cn_journal_lines.journal_creator%type;
   l_POSTER             ja_cn_journal_lines.journal_POSTER%type;
   l_POSTER_id          ja_cn_journal_lines.journal_creator%type;

   L_EFFECTIVE_DATE DATE;
   L_START_DATE DATE;
   L_END_DATA DATE;


    cursor c_journal_group is
    select distinct je_header_id
    from ja_cn_journal_lines
    where status='U';

    CURSOR c_Period_Name IS
      SELECT Gp.Period_Name
        FROM Gl_Periods Gp, Gl_Ledgers Led
       WHERE Led.Ledger_Id = l_Ledger_Id
         AND Led.Period_Set_Name = Gp.Period_Set_Name
         AND Led.Accounted_Period_Type = Gp.Period_Type
         AND Gp.Start_Date BETWEEN
             (SELECT Start_Date
                FROM Gl_Periods Gp
               WHERE Led.Period_Set_Name = Gp.Period_Set_Name
                 AND Led.Accounted_Period_Type = Gp.Period_Type
                 AND Gp.Period_Name = l_period_from )
         AND (SELECT Start_Date
                FROM Gl_Periods Gp
               WHERE Led.Period_Set_Name = Gp.Period_Set_Name
                 AND Led.Accounted_Period_Type = Gp.Period_Type
                 AND Gp.Period_Name = l_period_to)
       ORDER BY Gp.Start_Date;

       cursor c_third_party is
       select third_party_number,third_party_type
         from ja_cn_journal_lines
        where status='U'
          and third_party_number is not null
          for update;

       cursor c_project is
       select project_number,project_source
         from ja_cn_journal_lines
        where status='U'
          and project_number is not null
          for update;

       cursor c_PERSONNEL is
       select PERSONNEL_ID, DEFAULT_EFFECTIVE_DATE
         from ja_cn_journal_lines
        where status='U'
          and PERSONNEL_ID is not null;

        cursor c_creator is
         select journal_creator, DEFAULT_EFFECTIVE_DATE
           from ja_cn_journal_lines
          where status='U'
            and journal_creator is not null;

        cursor c_approver is
        select journal_approver, DEFAULT_EFFECTIVE_DATE
          from ja_cn_journal_lines
         where status='U'
           and journal_approver is not null;

        cursor c_poster is
        select journal_poster, DEFAULT_EFFECTIVE_DATE
          from ja_cn_journal_lines
         where status='U'
           and journal_poster is not null;

  BEGIN

    IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.begin'
                     ,'Enter procedure'
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'Ledger ID '||P_LEDGER_ID
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'Legal Entity ID '||P_LEGAL_ENTITY_ID
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'Period From '||P_PERIOD_FROM
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'Period To '||P_PERIOD_TO
                    );

    END IF;  --(l_proc_level >= l_dbg_level)

    l_period_from    := P_PERIOD_FROM ;
    l_period_to     := P_PERIOD_TO;
    l_ledger_id       := p_ledger_id;
    l_legal_entity_id := P_legal_entity_id;

-- If parameter P_PERIOD_FROM is null then set it as the first period of current ledger.
    if P_PERIOD_FROM is null then
     --get the first period of current led
        SELECT Gp.Period_Name
          INTO l_period_from
          FROM Gl_Periods Gp, Gl_Ledgers Led
         WHERE Led.Ledger_Id = l_ledger_id
           AND Led.Period_Set_Name = Gp.Period_Set_Name
           AND Led.Accounted_Period_Type = Gp.Period_Type
           AND Gp.Start_Date IN
               (SELECT MIN(Start_Date)
                  FROM Gl_Periods Gp
                 WHERE Led.Period_Set_Name = Gp.Period_Set_Name
                   AND Led.Accounted_Period_Type = Gp.Period_Type);
    end if;





 --prepare for the program, set value for global variable.
   fnd_file.PUT_LINE(fnd_file.LOG,l_legal_entity_id);
   fnd_file.PUT_LINE(fnd_file.LOG,l_ledger_id );
   fnd_file.PUT_LINE(fnd_file.LOG,l_period_from);
   fnd_file.PUT_LINE(fnd_file.LOG,l_period_to);

 --=======================================================================
 --the following piece of code is to check if the periods are all closed periods.
    l_period_start    := P_PERIOD_FROM ;
    l_period_end      := P_PERIOD_TO;

    SELECT COUNT(*)
      INTO invalid_period_num
      FROM Gl_Period_Statuses GP
     WHERE GP.application_id = 101
       AND GP.ledger_id = p_ledger_id
       AND GP.start_date >=
           (SELECT START_DATE
               FROM Gl_Period_Statuses
              WHERE LEDGER_ID = l_ledger_id
                AND PERIOD_NAME = l_period_start
                AND APPLICATION_ID = 101)
       AND GP.end_date   <=
           (SELECT END_DATE
               FROM Gl_Period_Statuses
              WHERE LEDGER_ID = l_ledger_id
                AND PERIOD_NAME = l_period_end
                AND APPLICATION_ID = 101)
       AND (GP.closing_status <> 'P'
           OR GP.closing_status <> 'C');

    IF ( invalid_period_num > 0 )
    THEN
      --Raise error message
      Fnd_Message.Set_Name(Application => 'JA',
                           NAME        => 'JA_CN_INTERFACE_OPEN_PERIOD');
      l_Error_Msg := Fnd_Message.Get;

      --Output error message
      Fnd_File.Put_Line(Fnd_File.LOG, l_Error_Msg);
      RETURN;
    END IF;

 --=======================================================================



   --get coa of parameter ledger id.
    SELECT chart_of_accounts_id
      INTO l_coa
      FROM gl_ledgers
     WHERE ledger_id = P_LEDGER_ID;

  --get application column name of Company segment
    SELECT Fsav.Application_Column_Name
      INTO l_Company_Column_Name
      FROM Fnd_Id_Flex_Segments         Fifs,
           Fnd_Segment_Attribute_Values Fsav,
           Gl_Ledgers                   Led
     WHERE Fifs.Id_Flex_Num = Fsav.Id_Flex_Num
       AND Fifs.Application_Column_Name = Fsav.Application_Column_Name
       AND Fsav.Segment_Attribute_Type = 'GL_BALANCING'
       AND Fsav.Attribute_Value = 'Y'
       AND Fifs.Application_Id = 101
       and fsav.id_flex_code = fifs.id_flex_code
       and fsav.id_flex_code = 'GL#'
       AND Fifs.Application_Id = Fsav.Application_Id
       AND Led.Chart_Of_Accounts_Id = Fifs.Id_Flex_Num
       AND Led.Ledger_Id = l_ledger_id;
    --get application column name of account segment
    SELECT Fsav.Application_Column_Name
      INTO l_Account_Column_Name
      FROM Fnd_Id_Flex_Segments         Fifs,
           Fnd_Segment_Attribute_Values Fsav,
           Gl_Ledgers                   Led
     WHERE Fifs.Id_Flex_Num = Fsav.Id_Flex_Num
       AND Fifs.Application_Column_Name = Fsav.Application_Column_Name
       AND Fsav.Segment_Attribute_Type = 'GL_ACCOUNT'
       AND Fsav.Attribute_Value = 'Y'
       AND Fifs.Application_Id = 101
       and fsav.id_flex_code = fifs.id_flex_code
       and fsav.id_flex_code = 'GL#'
       AND Fifs.Application_Id = Fsav.Application_Id
       AND Led.Chart_Of_Accounts_Id = Fifs.Id_Flex_Num
       AND Led.Ledger_Id = l_ledger_id;
    --get application column name of cost center segment
      SELECT Fsav.Application_Column_Name
      into l_Cost_CRT_Column_Name
        FROM Fnd_Id_Flex_Segments         Fifs,
             Fnd_Segment_Attribute_Values Fsav,
             Gl_Ledgers                   Led
       WHERE Fifs.Id_Flex_Num = Fsav.Id_Flex_Num
         AND Fifs.Application_Column_Name = Fsav.Application_Column_Name
         AND Fsav.Segment_Attribute_Type = 'FA_COST_CTR'
         AND Fsav.Attribute_Value = 'Y'
         AND Fifs.Application_Id = 101
         and fsav.id_flex_code = fifs.id_flex_code
         and fsav.id_flex_code = 'GL#'
         AND Fifs.Application_Id = Fsav.Application_Id
         AND Led.Chart_Of_Accounts_Id = Fifs.Id_Flex_Num
         AND Led.Ledger_Id = l_Ledger_Id;

  l_Populate_Bsv_Flag := Ja_Cn_Utility.Populate_Ledger_Le_Bsv_Gt(P_Ledger_Id,
                                                                   P_Legal_Entity_Id);
    IF l_Populate_Bsv_Flag = 'F' THEN
      IF (l_Proc_Level >= l_Dbg_Level) THEN
        Fnd_Log.STRING(l_Proc_Level,
                       l_Module_Prefix || '.' || l_Proc_Name,
                       'fail to populate BSV');
      END IF; --(l_proc_level >= l_dbg_level)
    END IF;

 --set a flag 'P' for journals in table gl_je_lines to identify them as processed journal.

    set_flag_p( l_ledger_id ,
                l_legal_entity_id,
                l_period_from,
                l_period_to );



  --validation the lines in interface table, if the lines is validated, the staus
  --is set to 'S' . if not the status code will be set in interface table.
       Validation(l_LEDGER_ID,
                  l_LEGAL_ENTITY_ID,
                  L_PERIOD_FROM,
                  L_PERIOD_TO)      ;

  --after validation the data is prepared. for example the ccid, company segment
  --account segment is prepared. for the je_header_id column in table
  --ja_cn_journal_lines will be set journal group provisionally.
  --import the data which status is 'S' to table ja_cn_journal_lines.


  l_sql:='insert into ja_cn_journal_lines
               (je_header_id,
                SET_OF_BOOKS_ID,
                legal_entity_id,
                JOURNAL_NUMBER,
                JE_CATEGORY,
                DEFAULT_EFFECTIVE_DATE,
                PERIOD_NAME ,
                CURRENCY_CODE,
                CURRENCY_CONVERSION_RATE,
                JE_LINE_NUM ,
                DESCRIPTION ,
                COMPANY_SEGMENT ,
                CODE_COMBINATION_ID ,
                COST_CENTER,
                THIRD_PARTY_NUMBER ,
                PERSONNEL_ID,
                PROJECT_NUMBER ,
                ACCOUNT_SEGMENT ,
                ENTERED_DR,
                ENTERED_CR,
                ACCOUNTED_DR,
                ACCOUNTED_CR,
                STATUS,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATE_LOGIN,
                PROJECT_SOURCE,
                POPULATE_CODE ,
                THIRD_PARTY_TYPE ,
                JOURNAL_CREATOR ,
                JOURNAL_APPROVER,
                JOURNAL_POSTER,
                LEDGER_ID
                )
         select journal_group,
                 ledger_id,
                 LEGAL_ENTITY_ID,
                 null,
                 JE_CATEGORY,
                 DEFAULT_EFFECTIVE_DATE,
                 PERIOD_NAME ,
                 CURRENCY_CODE,
                 CURRENCY_CONVERSION_RATE,
                 JE_LINE_NUM ,
                 DESCRIPTION ,'||
                 l_Company_Column_Name ||
                 ',CODE_COMBINATION_ID,'||
                 l_Cost_CRT_Column_Name ||
                 ',THIRD_PARTY_NUMBER
                 ,PERSONNEL_ID
                 ,PROJECT_NUMBER,'||
                 l_Account_Column_Name||
                 ',ENTERED_DR,
                 ENTERED_CR,
                 ACCOUNTED_DR,
                 ACCOUNTED_CR,
                 ''U'',
                 Fnd_Global.User_Id,
                 SYSDATE,
                 Fnd_Global.User_Id,
                 SYSDATE,
                 Fnd_Global.Login_Id,
                 PROJECT_SOURCE,
                 ''IMPORT'',
                 THIRD_PARTY_TYPE ,
                 JOURNAL_CREATOR_ID ,
                 JOURNAL_APPROVER_ID,
                 JOURNAL_POSTER_ID,
                 LEDGER_ID
         from  ja_cn_item_interface
         where status =''S''';

         execute immediate l_sql;
       --  commit;

         --after import, delete the journal which is successful
       --  delete from ja_cn_item_interface
       --  where status='S';
       --  commit;
       --get PERSONNEL_ID
       --according to PERSONNEL_ID,get personal number
       open c_PERSONNEL;
       loop
         fetch c_PERSONNEL into l_PERSONNEL_id,L_EFFECTIVE_DATE;
         exit when c_PERSONNEL%notfound;
          select employee_number--, Last_Name || First_Name Full_Name
            into l_PERSONNEL_NUMBER
            from Per_All_People_f
           where person_id = l_PERSONNEL_id
             AND EFFECTIVE_START_DATE<=L_EFFECTIVE_DATE
             AND EFFECTIVE_END_DATE>=L_EFFECTIVE_DATE;
         update ja_cn_journal_lines
            set personnel_number = l_PERSONNEL_NUMBER
          where personnel_id = l_PERSONNEL_id ;

       end loop;
       close c_PERSONNEL;

      open c_creator;
      loop
        fetch c_creator into l_creator_id, L_EFFECTIVE_DATE;
         exit when c_creator%notfound;
         select Last_Name || First_Name Full_Name
           into l_creator
            from Per_All_People_f
           where person_id = to_number(l_creator_id)
             AND EFFECTIVE_START_DATE<=L_EFFECTIVE_DATE
             AND EFFECTIVE_END_DATE>=L_EFFECTIVE_DATE;

         update ja_cn_journal_lines
            set journal_creator = l_creator
          where journal_creator = l_creator_id;

      end loop;
      close c_creator;

      open c_approver;
      loop
        fetch c_approver into l_approver_id,L_EFFECTIVE_DATE;
        exit when c_approver%notfound;
        select Last_Name || First_Name Full_Name
          into l_approver
          from Per_All_People_f
         where person_id = to_number(l_approver_id )
           AND EFFECTIVE_START_DATE<=L_EFFECTIVE_DATE
           AND EFFECTIVE_END_DATE>=L_EFFECTIVE_DATE;

        update ja_cn_journal_lines
           set journal_approver = l_approver
         where journal_approver = l_APPROVER_id;
      end loop;
      close c_approver;

      open c_poster;
      loop
        fetch c_poster into l_poster_id, L_EFFECTIVE_DATE;
         exit when c_poster%notfound;
        select Last_Name || First_Name Full_Name
          into l_poster
          from Per_All_People_f
         where person_id = to_number(l_poster_id)
           AND EFFECTIVE_START_DATE<=L_EFFECTIVE_DATE
           AND EFFECTIVE_END_DATE>=L_EFFECTIVE_DATE;

         update ja_cn_journal_lines
            set journal_poster = l_poster
          where journal_poster = l_poster_id;
      end loop;
      close c_poster;

        --set je_header_id according to the journal group
        open c_journal_group;
        loop
          fetch c_journal_group into l_journal_group;
          exit when c_journal_group%notfound;
          SELECT ja_cn_item_interface_s.NEXTVAL into l_header_id FROM Dual;
          update ja_cn_journal_lines
          set je_header_id = l_header_id
          where status = 'U'
          and je_header_id = l_journal_group;
        end loop;
        close c_journal_group;
       -- commit;
       --get id according to number user input.
       --get third party id.
       open c_third_party;
       loop
          fetch c_third_party into l_third_party_number,l_third_party_type;
          exit when c_third_party%notfound;
          if l_third_party_type='C' then
            select party_id
              into l_third_party_id
              from Hz_Parties
             where Party_Number =l_THIRD_PARTY_NUMBER;
          elsif l_third_party_type='S' then
             select vendor_id
               into l_third_party_id
               from ap_suppliers
               where Segment1  =l_THIRD_PARTY_NUMBER;
          end if;
          update ja_cn_journal_lines
             set third_party_id=l_third_party_id
           where current of c_third_party;
       end loop;
       close c_third_party;
       --get project id
       open c_project;
       loop
         fetch c_project into l_project_number,l_project_source;
         exit when c_project%notfound;
         if l_project_source='PA' then
           select project_id
             into l_project_id
             from PA_PROJECTS_ALL
            where SEGMENT1=l_PROJECT_NUMBER;
         elsif l_project_source='COA'then
              select flex_value_id
              into l_project_id
              from FND_FLEX_VALUES ffv,
                   FND_ID_FLEX_SEGMENTS fifs
               where ffv.flex_value_set_id=fifs.flex_value_set_id
                 and fifs.id_flex_code='GL#'
                 and fifs.id_flex_num=l_coa
                 and (fifs.application_column_name =(select coa_segment
                                                from ja_cn_sub_acc_sources_all
                                                where chart_of_accounts_id=l_coa
                                                  and coa_segment is not null)
                  or fifs.application_column_name =(select history_coa_segment
                                                from ja_cn_sub_acc_sources_all
                                                where chart_of_accounts_id=l_coa
                                                  and history_coa_segment is not null) )
                 AND flex_value = l_PROJECT_NUMBER ;
         end if;
         update ja_cn_journal_lines
           set  project_id=l_project_id
          where current of c_project;
       end loop;
       close c_project;

       --generate journal number for each line in table ja_cn_journal_lines.
        OPEN c_Period_Name;
        LOOP
          FETCH c_Period_Name
            INTO l_Period_Name;
          EXIT WHEN c_Period_Name%NOTFOUND;
       -- generate journal number and journal line number
          Generate_Journal_Num(p_Period_Name => l_Period_Name,
                               p_ledger_id   =>p_ledger_id,
                               p_legal_entity_id =>p_legal_entity_id);

        END LOOP;
        close c_Period_Name;

   --    l_Period_Name:='Dec-07';
      --prepare for the post program.
        Generate_Code_Combination_View(l_ledger_id);
    --call post program to post these journals itemized
        Ja_Cn_Post_Utility_Pkg.Post_Journal_Itemized(p_Period_Name     =>l_Period_Name,
                                             p_ledger_Id       => l_Ledger_Id,
                                             p_Legal_Entity_Id => l_Legal_Entity_Id);

        commit;

        put_xml(p_LEDGER_ID,
                p_LEGAL_ENTITY_ID,
                p_PERIOD_FROM,
                p_PERIOD_TO );



    EXCEPTION

      WHEN OTHERS THEN
        v_code := SQLCODE;
        v_errm := SUBSTR(SQLERRM, 1 , 64);

        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.Other_Exception '
                         ,SQLCODE||':'||SQLERRM);
        END IF;  --(l_proc_level >= l_dbg_level)


  END Import_Itemization_Data;


BEGIN
  NULL;
  -- Initialization
--  <Statement>;
end JA_CN_ITEMIZATION_INTERFACE;





/
