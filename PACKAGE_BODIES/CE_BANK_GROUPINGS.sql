--------------------------------------------------------
--  DDL for Package Body CE_BANK_GROUPINGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_BANK_GROUPINGS" AS
/*$Header: cebugrpb.pls 120.3 2005/07/29 21:05:14 eliu noship $ */

TYPE  Num15Tab IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE  Char1Tab IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
TYPE  Char2Tab IS TABLE OF VARCHAR2(2) INDEX BY BINARY_INTEGER;
TYPE  Char4Tab IS TABLE OF VARCHAR2(4) INDEX BY BINARY_INTEGER;
TYPE  Char11Tab IS TABLE OF VARCHAR2(11) INDEX BY BINARY_INTEGER;
TYPE  Char15Tab IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;
TYPE  Char20Tab IS TABLE OF VARCHAR2(20) INDEX BY BINARY_INTEGER;
TYPE  Char25Tab IS TABLE OF VARCHAR2(25) INDEX BY BINARY_INTEGER;
TYPE  Char30Tab IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE  Char60Tab IS TABLE OF VARCHAR2(60) INDEX BY BINARY_INTEGER;
TYPE  Char80Tab IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
TYPE  Char150Tab IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE  Char240Tab IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
TYPE  Char320Tab IS TABLE OF VARCHAR2(320) INDEX BY BINARY_INTEGER;
TYPE  Char360Tab IS TABLE OF VARCHAR2(360) INDEX BY BINARY_INTEGER;

l_debug     varchar2(1);

  /*========================================================================+
   | PUBLIC PROCEDURE                                                       |
   |   grouping                                                             |
   |                                                                        |
   | DESCRIPTION                                                            |
   |   Main procedure of the bank grouping program.  This program can group |
   |   bank data for BANK, BRANCH, or ACCOUNT level as requested.           |
   |                                                                        |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                 |
   |                                                                        |
   | ARGUMENTS                                                              |
   |   IN:                                                                  |
   |     p_bank_entity_type    Bank entity type for this program run.       |
   |     p_display_debug       Debug message flag (Y/N)                     |
   |     p_debug_path          Debug path name if specified                 |
   |     p_debug_file          Debug file name if specified                 |
   +========================================================================*/
   PROCEDURE grouping (errbuf        OUT NOCOPY     VARCHAR2,
                       retcode       OUT NOCOPY     NUMBER,
                       p_bank_entity_type           VARCHAR2,
                       p_display_debug              VARCHAR2,
                       p_debug_path                 VARCHAR2,
                       p_debug_file                 VARCHAR2) IS

     -- Cursor to fetch bank records for grouping
     cursor bank_cur is
       select country, bank_or_branch_number, organization_name, ce_upgrade_id,
              source_application_id, to_char(creation_date,'DD/MM/YYYY')
       from   ce_upg_bank_rec
       where  group_id is null
       and    bank_entity_type = p_bank_entity_type
       order by country, bank_or_branch_number,
                decode(source_application_id, 200, 1, 185, 2),
                creation_date desc;

     -- Cursor to fetch product specific attributes from secondary banks
     cursor bank_sec is
       select group_id, ce_upgrade_id, known_as
       from   ce_upg_bank_rec
       where  secondary_flag = 'Y'
       and    source_application_id <> 200
       and    bank_entity_type = p_bank_entity_type
       order by group_id, source_application_id;

     -- Cursor to fetch primary banks for validation
     cursor bank_pri is
       select ce_upgrade_id, country, bank_or_branch_number,
              organization_name, jgzz_fiscal_code, organization_name_phonetic
       from   ce_upg_bank_rec
       where  bank_entity_type = p_bank_entity_type
       and    primary_flag = 'Y'
       order by country, bank_or_branch_number, creation_date desc;

     -- Cursor to fetch branch records for grouping
     cursor branch_cur is
       select bb.country, bb.bank_or_branch_number, bb.organization_name,
              bb.ce_upgrade_id, bb.source_application_id,
              to_char(bb.creation_date,'DD/MM/YYYY'), b.group_id
       from   ce_upg_bank_rec b, ce_upg_bank_rec bb
       where  b.ce_upgrade_id = bb.parent_upgrade_id
       and    bb.group_id is null
       and    b.bank_entity_type = 'BANK'
       and    bb.bank_entity_type = p_bank_entity_type
       order by bb.country, b.group_id, bb.bank_or_branch_number,
                decode(bb.source_application_id, 200, 1, 185, 2),
                bb.creation_date desc;

     -- Cursor to fetch product specific attributes from secondary branches
     cursor branch_sec is
       select group_id, ce_upgrade_id, known_as
       from   ce_upg_bank_rec
       where  secondary_flag = 'Y'
       and    source_application_id <> 200
       and    bank_entity_type = p_bank_entity_type
       order by group_id, source_application_id;

     -- Cursor to fetch primary branches for validation
     cursor branch_pri is
       select bb.ce_upgrade_id, bb.country, bb.bank_or_branch_number,
              b.group_id, bb.organization_name_phonetic
       from   ce_upg_bank_rec b, ce_upg_bank_rec bb
       where  b.bank_entity_type = 'BANK'
       and    b.ce_upgrade_id = bb.parent_upgrade_id
       and    bb.bank_entity_type = p_bank_entity_type
       and    bb.primary_flag = 'Y'
       order by b.group_id, bb.bank_or_branch_number, bb.creation_date desc;

     -- Cursor to fetch account records for grouping
     cursor acct_cur is
       select bb.country, ba.bank_account_name, ba.bank_account_num,
              ba.currency_code, ba.bank_account_type, ba.ce_upgrade_id,
              ba.source_application_id, to_char(ba.creation_date,'DD/MM/YYYY'),
              bb.group_id
       from   ce_upg_bank_rec bb, ce_upg_bank_accounts ba
       where  bb.ce_upgrade_id = ba.parent_upgrade_id
       and    ba.group_id is null
       and    bb.bank_entity_type = 'BRANCH'
       order by bb.group_id, ba.bank_account_name, ba.bank_account_num,
                ba.currency_code,
                decode(bb.country, 'JP', ba.bank_account_type, 'X'),
                decode(ba.source_application_id, 200, 1, 185, 2, 801, 3),
                ba.creation_date desc;

     -- Cursor to fetch product specific attributes from secondary accounts
     cursor acct_sec is
       select group_id, source_application_id, ce_upgrade_id,
              start_date, legal_account_name, description, xtr_use_allowed_flag,
              pay_use_allowed_flag, xtr_amount_tolerance, xtr_percent_tolerance,
              pay_amount_tolerance, pay_percent_tolerance,
              cashflow_display_order, target_balance
       from   ce_upg_bank_accounts
       where  secondary_acct_flag = 'Y'
       and    source_application_id <> 200
       order by group_id, source_application_id;

     -- Cursor to fetch primary accounts for validation
     cursor acct_pri is
       select ba.ce_upgrade_id, bb.country, b.bank_or_branch_number,
              bb.bank_or_branch_number, ba.bank_account_num,
              ba.secondary_account_reference, ba.bank_account_name,
              ba.check_digits, bb.group_id, ba.bank_account_type,
	      ba.account_suffix
       from   ce_upg_bank_rec b, ce_upg_bank_rec bb, ce_upg_bank_accounts ba
       where  b.bank_entity_type = 'BANK'
       and    b.ce_upgrade_id = bb.parent_upgrade_id
       and    bb.bank_entity_type = 'BRANCH'
       and    bb.ce_upgrade_id = ba.parent_upgrade_id
       and    ba.primary_acct_flag = 'Y'
       order by bb.group_id, ba.bank_account_name, ba.bank_account_num,
                ba.creation_date desc;

     -- Cursor to fetch account use records for grouping
     cursor ba_use_cur is
       select ba.group_id, bau.org_id, bau.legal_entity_id, bau.source_application_id,
              bau.ce_upgrade_id, to_char(ba.creation_date,'DD/MM/YYYY'),
              pay_use_enable_flag, payroll_bank_account_id
       from   ce_upg_bank_accounts ba, ce_upg_ba_uses_all bau
       where  ba.ce_upgrade_id = bau.parent_upgrade_id
       and    bau.group_id is null
       order by ba.group_id, bau.org_id, bau.legal_entity_id,
                decode(bau.source_application_id, 200, 1, 185, 2, 801, 3),
                ba.creation_date desc;


     c_country                 Char30Tab;
     c_bank_or_branch_number   Char60Tab;
     c_org_name	               Char360Tab;
     c_upg_id	               Num15Tab;
     c_app_id	               Num15Tab;
     c_creation_date           Char11Tab;
     c_group_id	               Num15Tab;
     c_org_name_alt            Char320Tab;
     c_jgzz_fiscal_code        Char20Tab;
     c_status                  Char30Tab;
     c_known_as                Char240Tab;
     c_start_date              Char11Tab;
     c_end_date                Char11Tab;
     c_acct_name               Char80Tab;
     c_acct_num                Char30Tab;
     c_currency                Char15Tab;
     c_acct_type               Char25Tab;
     c_legal_name              Char30Tab;
     c_bank_number             Char60Tab;
     c_description             Char240Tab;
     c_desc_code1              Char60Tab;
     c_desc_code2              Char60Tab;
     c_eft_requester           Char25Tab;
     c_acct_reference          Char30Tab;
     c_xtr_flag                Char1Tab;
     c_pay_flag                Char1Tab;
     c_xtr_amount              Num15Tab;
     c_xtr_percent             Num15Tab;
     c_pay_amount              Num15Tab;
     c_pay_percent             Num15Tab;
     c_acct_suffix             Char30Tab;
     c_comm_agreement          Num15Tab;
     c_cashflow_order          Num15Tab;
     c_target_balance          Num15Tab;
     c_cd                      Char30Tab;
     c_org_id                  Num15Tab;
     c_le_id                   Num15Tab;
     c_pay_ba_id               Num15Tab;

     c			       VARCHAR2(3);
     c_grouping_flag	       VARCHAR2(1);
     c_commit_size             NUMBER;
     tot_count	               NUMBER;
     curr_module               VARCHAR2(150);

     x_count                   NUMBER;
     x_msgdata                 VARCHAR2(2000);
     x_val_out                 VARCHAR2(2000);
     x_msg_name                VARCHAR2(2000);
     p_msg_name                VARCHAR2(2000);


   BEGIN

     -- Set debug flag and initial variable settings
     c := '0';
     l_debug := NVL(FND_PROFILE.value('CE_DEBUG'), 'N');
     c_grouping_flag := 'N';
     c_commit_size := 3000;
     curr_module := 'CE_BAND_GROUPING';

     c := '1';
     if l_debug in ('Y', 'C') then
       cep_standard.enable_debug(p_debug_path, p_debug_file);
       cep_standard.debug('>>CE_BANK_GROUPINGS.grouping '||sysdate);
       cep_standard.debug('  p_bank_entity_type    = '|| p_bank_entity_type);
       cep_standard.debug('  p_display_debug       = '|| p_display_debug);
       cep_standard.debug('  p_debug_path          = '|| p_debug_path);
       cep_standard.debug('  p_debug_file          = '|| p_debug_file);
     end if;

     --
     -- Check if the bank upgrade mode is ready for grouping
     --
     c := '2';
     select 'Y'
     into   c_grouping_flag
     from   ce_bank_upgrade_modes
     where  source_product_name = 'ALL'
     and    decode(p_bank_entity_type, 'BRANCH', bank_upgrade_mode,
              'ACCOUNT', branch_upgrade_mode,'GROUPED') in ('GROUPED','FROZEN')
     and    decode(p_bank_entity_type, 'BANK', bank_upgrade_mode,
             'BRANCH', branch_upgrade_mode, account_upgrade_mode) = 'PRE_GROUP';

     --
     -- Start processing Grouping program
     --
     c := '4';
     if (p_bank_entity_type = 'BANK') then
       open bank_cur;
       tot_count := 0;

       c := '5';
       loop
         c_country.delete;
         c_bank_or_branch_number.delete;
         c_org_name.delete;
         c_upg_id.delete;
         c_app_id.delete;
         c_creation_date.delete;

         c := '6';
         FETCH bank_cur BULK COLLECT INTO c_country, c_bank_or_branch_number,
           c_org_name, c_upg_id, c_app_id, c_creation_date
         LIMIT c_commit_size;

         c := '7';
         if c_upg_id.count > 0 then

           -- 1) Grouping bank records with bank number
           --    1.1 Set primary record for records with bank number
           c := '8';
           forall i in c_upg_id.first..c_upg_id.last
             update ce_upg_bank_rec b
             set    group_id = c_upg_id(i),
                    primary_flag = 'Y',
                    secondary_flag = 'N',
                    last_update_date = sysdate,
                    last_updated_by = nvl(FND_GLOBAL.user_id,-1)
             where bank_or_branch_number = c_bank_or_branch_number(i)
             and   bank_entity_type = p_bank_entity_type
             and   bank_or_branch_number is not null
             and   ce_upgrade_id = c_upg_id(i)
             and   not exists
                  (select null from ce_upg_bank_rec
                   where  country = b.country
                   and    bank_or_branch_number = b.bank_or_branch_number
                   and    bank_entity_type = b.bank_entity_type
                   and    primary_flag = 'Y'
                   union all
                   select null from ce_upg_bank_rec
                   where  country = b.country
                   and    bank_or_branch_number is null
                   and    organization_name = b.organization_name
                   and    bank_entity_type = b.bank_entity_type
                   and    primary_flag = 'Y');

           --    1.2 Set secondary flag for records with bank number
           c := '9';
           forall i in c_upg_id.first..c_upg_id.last
             update ce_upg_bank_rec b
             set    group_id = nvl(
                     (select group_id from ce_upg_bank_rec
                      where  country = b.country
                      and    bank_or_branch_number = b.bank_or_branch_number
                      and    bank_entity_type = b.bank_entity_type
                      and    source_application_id <> b.source_application_id
                      and    primary_flag = 'Y'
                      and    rownum = 1),
                     (select group_id from ce_upg_bank_rec
                      where  country = b.country
                      and    bank_or_branch_number is null
                      and    organization_name = b.organization_name
                      and    bank_entity_type = b.bank_entity_type
                      and    source_application_id <> b.source_application_id
                      and    primary_flag = 'Y'
                      and    rownum = 1)),
                    primary_flag = 'N',
                    secondary_flag = 'Y',
                    last_update_date = sysdate,
                    last_updated_by = nvl(FND_GLOBAL.user_id,-1)
             where bank_or_branch_number = c_bank_or_branch_number(i)
             and   bank_or_branch_number is not null
             and   bank_entity_type = p_bank_entity_type
             and   ce_upgrade_id = c_upg_id(i)
             and   group_id is null
             and   not exists
                  (select null from ce_upg_bank_rec
                   where  country = b.country
                   and    bank_or_branch_number = b.bank_or_branch_number
                   and    bank_entity_type = b.bank_entity_type
                   and    source_application_id = b.source_application_id
                   and    group_id is not null
                   union all
                   select null from ce_upg_bank_rec
                   where  country = b.country
                   and    bank_or_branch_number is null
                   and    organization_name = b.organization_name
                   and    bank_entity_type = b.bank_entity_type
                   and    source_application_id = b.source_application_id
                   and    group_id is not null)
             and   exists
                  (select null from ce_upg_bank_rec
                   where  country = b.country
                   and    bank_or_branch_number = b.bank_or_branch_number
                   and    bank_entity_type = b.bank_entity_type
                   and    primary_flag = 'Y'
                   union all
                   select null from ce_upg_bank_rec
                   where  country = b.country
                   and    bank_or_branch_number is null
                   and    organization_name = b.organization_name
                   and    bank_entity_type = b.bank_entity_type
                   and    primary_flag = 'Y');

           --    1.3 Group all other records with bank number
           c := '10';
           forall i in c_upg_id.first..c_upg_id.last
             update ce_upg_bank_rec b
             set    group_id = nvl(
                     (select group_id from ce_upg_bank_rec
                      where  country = b.country
                      and    bank_or_branch_number = b.bank_or_branch_number
                      and    bank_entity_type = b.bank_entity_type
                      and    primary_flag = 'Y'
                      and    rownum = 1),
                     (select group_id from ce_upg_bank_rec
                      where  country = b.country
                      and    bank_or_branch_number is null
                      and    organization_name = b.organization_name
                      and    bank_entity_type = b.bank_entity_type
                      and    primary_flag = 'Y'
                      and    rownum = 1)),
                    primary_flag = 'N',
                    secondary_flag = 'N',
                    last_update_date = sysdate,
                    last_updated_by = nvl(FND_GLOBAL.user_id,-1)
             where bank_or_branch_number = c_bank_or_branch_number(i)
             and   bank_or_branch_number is not null
             and   bank_entity_type = p_bank_entity_type
             and   ce_upgrade_id = c_upg_id(i)
             and   group_id is null;

           -- 2) Grouping bank reocrds with no bank number
           --    2.1 Set primary flag for records with no bank number
           c := '11';
           forall i in c_upg_id.first..c_upg_id.last
             update ce_upg_bank_rec b
             set    group_id = c_upg_id(i),
                    primary_flag = 'Y',
                    secondary_flag = 'N',
                    last_update_date = sysdate,
                    last_updated_by = nvl(FND_GLOBAL.user_id,-1)
             where bank_or_branch_number is null
             and   bank_entity_type = p_bank_entity_type
             and   ce_upgrade_id = c_upg_id(i)
             and   not exists
                  (select null from ce_upg_bank_rec b2
                   where  country = b.country
                   and    organization_name = b.organization_name
                   and    bank_entity_type = b.bank_entity_type
                   and    primary_flag = 'Y');

           --    2.2 Set secondary flag for records with no bank number
           c := '12';
           forall i in c_upg_id.first..c_upg_id.last
             update ce_upg_bank_rec b
             set    group_id =
                     (select group_id from ce_upg_bank_rec
                      where  country = b.country
                      and    organization_name = b.organization_name
                      and    bank_entity_type = b.bank_entity_type
                      and    source_application_id <> b.source_application_id
                      and    primary_flag = 'Y'
                      and    rownum = 1),
                    primary_flag = 'N',
                    secondary_flag = 'Y',
                    last_update_date = sysdate,
                    last_updated_by = nvl(FND_GLOBAL.user_id,-1)
             where bank_or_branch_number is null
             and   bank_entity_type = p_bank_entity_type
             and   ce_upgrade_id = c_upg_id(i)
             and   group_id is null
             and   organization_name = c_org_name(i)
--
             and   not exists
                  (select null from ce_upg_bank_rec b2
                   where  country = b.country
                   and    organization_name = b.organization_name
                   and    bank_entity_type = b.bank_entity_type
                   and    source_application_id = b.source_application_id
                   and    group_id is not null)
--
             and   exists
                  (select null from ce_upg_bank_rec b2
                   where  country = b.country
                   and    organization_name = b.organization_name
                   and    bank_entity_type = b.bank_entity_type
                   and    primary_flag = 'Y');
/*
		   and not exists
			(select null from ce_upg_bank_rec b3
			 where  group_id = b2.group_id
		         and    country = b.country
                         and    organization_name = b.organization_name
                         and    bank_entity_type = b.bank_entity_type
                         and    source_application_id = b.source_application_id));
*/
           --    2.3 Set all other records with no bank number
           c := '13';
           forall i in c_upg_id.first..c_upg_id.last
             update ce_upg_bank_rec b
             set    group_id =
                     (select group_id from ce_upg_bank_rec
                      where  country = b.country
                      and    organization_name = b.organization_name
                      and    bank_entity_type = b.bank_entity_type
                      and    primary_flag = 'Y'
                      and    rownum = 1),
                    primary_flag = 'N',
                    secondary_flag = 'N',
                    last_update_date = sysdate,
                    last_updated_by = nvl(FND_GLOBAL.user_id,-1)
             where bank_or_branch_number is null
             and   organization_name = c_org_name(i)
             and   bank_entity_type = p_bank_entity_type
             and   ce_upgrade_id = c_upg_id(i)
             and   group_id is null;

         else
           if l_debug in ('Y', 'C') then
             cep_standard.debug('c_upg_id.count='||to_char(c_upg_id.count));
           end if;
           exit;
         end if;
         tot_count := sql%rowcount;

         c := '14';
         commit;
         exit when bank_cur%notfound;
       end loop;

       c := '15';
       close bank_cur;
       if l_debug in ('Y', 'C') then
         cep_standard.debug('Total bank count='||to_char(tot_count));
       end if;

       -- Populate secondary attributes to primary records
       c := '16';
       open bank_sec;
       c_group_id.delete;
       c_upg_id.delete;
       c_known_as.delete;

       c := '17';
       FETCH bank_sec BULK COLLECT INTO c_group_id, c_upg_id, c_known_as;

       c := '18';
       if c_group_id.count > 0 then

         c := '19';
         forall i in c_group_id.first..c_group_id.last
           update ce_upg_bank_rec
           set    known_as = nvl(c_known_as(i), known_as),
                  last_update_date = sysdate,
                  last_updated_by = nvl(FND_GLOBAL.user_id,-1)
           where ce_upgrade_id = c_group_id(i);

       end if;

       c := '20';
       close bank_sec;

       -- Validate primary records and populate validation errors if any
       c := '21';
       open bank_pri;
       c_upg_id.delete;
       c_country.delete;
       c_bank_or_branch_number.delete;
       c_org_name.delete;
       c_jgzz_fiscal_code.delete;
       c_org_name_alt.delete;
       c_status.delete;

       c := '22';
       FETCH bank_pri BULK COLLECT INTO c_upg_id, c_country,
           c_bank_or_branch_number, c_org_name, c_jgzz_fiscal_code,
	   c_org_name_alt;

       -- Append bank number to bank name if two primary banks with different
       -- bank number and same bank name under the same country.
       -- (1) Copy bank records to ce_upga_bank_rec
       c := '24';
       forall i in c_upg_id.first..c_upg_id.last
         insert into ce_upga_bank_rec
           (party_id,
            ce_upgrade_id,
            parent_upgrade_id,
            bank_entity_type,
            upgrade_status,
            primary_flag,
            secondary_flag,
            group_id,
            bank_or_branch_number,
            bank_code,
            branch_code,
            institution_type,
            country,
            branch_type,
            rfc_code,
            created_by_module,
            organization_name,
            organization_name_phonetic,
            known_as,
            jgzz_fiscal_code,
            mission_statement,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
            start_date_active,
            end_date_active,
            eft_user_num,
            clearing_house_id,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login)
         select
            party_id,
            ce_upgrade_id,
            parent_upgrade_id,
            bank_entity_type,
            upgrade_status,
            primary_flag,
            secondary_flag,
            group_id,
            bank_or_branch_number,
            bank_code,
            branch_code,
            institution_type,
            country,
            branch_type,
            rfc_code,
            curr_module,
            organization_name,
            organization_name_phonetic,
            known_as,
            jgzz_fiscal_code,
            mission_statement,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
            start_date_active,
            end_date_active,
            eft_user_num,
            clearing_house_id,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login
         from ce_upg_bank_rec b
         where ce_upgrade_id = c_upg_id(i)
         and exists
            (select null from ce_upg_bank_rec b2
             where b2.country = b.country
             and b2.bank_or_branch_number <> b.bank_or_branch_number
             and b2.organization_name = b.organization_name
             and b2.bank_entity_type = b.bank_entity_type
             and b2.primary_flag = 'Y'
             and b2.creation_date >= b.creation_date);


       -- (2) Update ce_upg_bank_rec to append bank number to bank name
       c := '25';
       forall i in c_upg_id.first..c_upg_id.last
         update ce_upg_bank_rec b
         set    organization_name =
                  organization_name || ' ' || bank_or_branch_number,
                last_update_date = sysdate,
                last_updated_by = nvl(FND_GLOBAL.user_id,-1)
         where ce_upgrade_id = c_upg_id(i)
         and exists
            (select null from ce_upg_bank_rec b2
             where b2.country = b.country
             and b2.bank_or_branch_number <> b.bank_or_branch_number
             and b2.organization_name = b.organization_name
             and b2.bank_entity_type = b.bank_entity_type
             and b2.primary_flag = 'Y'
             and b2.creation_date >= b.creation_date);


       c := '26';
       for i in c_upg_id.first..c_upg_id.last
       loop

         fnd_msg_pub.initialize;
         x_msg_name := NULL;

         c := '27';
         ce_validate_bankinfo_upg.ce_validate_bank
          (x_country_name    => c_country(i),
           x_bank_number     => c_bank_or_branch_number(i),
           x_bank_name       => c_org_name(i),
           x_bank_name_alt   => c_org_name_alt(i),
           x_tax_payer_id    => c_jgzz_fiscal_code(i),
           x_validation_type => 'ALL',
           p_init_msg_list   => 'T',
           x_msg_count       => x_count,
           x_msg_data        => x_msgdata,
           x_value_out       => x_val_out,
           x_message_name_all => x_msg_name);

         if x_count > 0 then
           c_status(i) := 'INVALID';
         else
           c_status(i) := 'NULL';
         end if;
/*
         begin
           delete from ce_bank_upgrade_errors
           where  ce_upgrade_id = c_upg_id(i)
           and    bank_entity_type = 'BANK';
         exception
           when no_data_found then
             null;
           when too_many_rows then
             null;
           when others then
             raise;
         end;
*/
         c := '28';
         FOR j IN 1..x_count LOOP

            if (j=x_count) then
              p_msg_name := x_msg_name;
              x_msg_name := NULL;
            else
              p_msg_name := substr(x_msg_name, 1, instr(x_msg_name,',')-1);
              x_msg_name := substr(x_msg_name, instr(x_msg_name,',')+1,
                                   length(x_msg_name)-instr(x_msg_name,','));
            end if;

            if (p_msg_name is not null) then
              insert into ce_bank_upgrade_errors
               (ce_upgrade_id, bank_entity_type, key_error_flag, application_id,
                message_name, creation_date, created_by, last_update_date,
                last_updated_by)
              values (c_upg_id(i), 'BANK', 'N', 260, p_msg_name,
                    sysdate, NVL(FND_GLOBAL.user_id,-1),
                    sysdate, NVL(FND_GLOBAL.user_id,-1));
            end if;
         END LOOP;
       end loop;

       -- Set upgrade status
       c := '29';
       forall i in c_upg_id.first..c_upg_id.last
         update ce_upg_bank_rec
         set    upgrade_status = c_status(i),
                last_update_date = sysdate,
                last_updated_by = nvl(FND_GLOBAL.user_id,-1)
         where  ce_upgrade_id = c_upg_id(i)
         and    c_status(i) = 'INVALID';

       c := '30';
       close bank_pri;

       --
       -- Update GROUPED status to ce_bank_upgrade_modes for 'BANK' level
       --
       c := '31';
       begin
         update ce_bank_upgrade_modes
         set    bank_upgrade_mode = 'GROUPED',
                last_update_date = sysdate,
                last_updated_by = nvl(FND_GLOBAL.user_id,-1);

       exception
         when too_many_rows then
           null;
         when others then
           raise;
       end;
       c := '32';

     elsif (p_bank_entity_type = 'BRANCH') then

       c := '51';
       open branch_cur;
       tot_count := 0;

       c := '52';
       loop
         c_country.delete;
         c_bank_or_branch_number.delete;
         c_org_name.delete;
         c_upg_id.delete;
         c_app_id.delete;
         c_creation_date.delete;
         c_group_id.delete;

         c := '53';
         FETCH branch_cur BULK COLLECT INTO c_country, c_bank_or_branch_number,
           c_org_name, c_upg_id, c_app_id, c_creation_date, c_group_id
         LIMIT c_commit_size;

         c := '54';
         if c_upg_id.count > 0 then

           -- 3) Grouping branch records with branch number
           --    3.1 Set primary branch records with branch number
           c := '55';
           forall i in c_upg_id.first..c_upg_id.last
             update ce_upg_bank_rec bb
             set    group_id = c_upg_id(i),
                    primary_flag = 'Y',
                    secondary_flag = 'N',
                    last_update_date = sysdate,
                    last_updated_by = nvl(FND_GLOBAL.user_id,-1)
             where  ce_upgrade_id = c_upg_id(i)
             and    bank_or_branch_number is not null
             and not exists
                (select null from ce_upg_bank_rec b, ce_upg_bank_rec bb2
                 where  b.ce_upgrade_id = bb2.parent_upgrade_id
                 and    b.group_id = c_group_id(i)
                 and    b.bank_entity_type = 'BANK'
                 and    bb2.bank_or_branch_number = bb.bank_or_branch_number
                 and    bb2.bank_entity_type = bb.bank_entity_type
                 and    bb2.primary_flag = 'Y'
                 union all
                 select null from ce_upg_bank_rec b, ce_upg_bank_rec bb2
                 where  b.ce_upgrade_id = bb2.parent_upgrade_id
                 and    b.group_id = c_group_id(i)
                 and    b.bank_entity_type = 'BANK'
                 and    bb2.bank_or_branch_number is null
                 and    bb2.organization_name = bb.organization_name
                 and    bb2.bank_entity_type = bb.bank_entity_type
                 and    bb2.primary_flag = 'Y');

           --    3.2 Set secondary flag for records with branch number
           c := '56';
           forall i in c_upg_id.first..c_upg_id.last
             update ce_upg_bank_rec bb
             set    group_id = nvl(
                     (select bb2.group_id
                      from  ce_upg_bank_rec b, ce_upg_bank_rec bb2
                      where b.group_id = c_group_id(i)
                      and   b.country = bb.country
                      and   b.bank_entity_type = 'BANK'
                      and   bb2.parent_upgrade_id = b.ce_upgrade_id
                      and   bb2.bank_or_branch_number = bb.bank_or_branch_number
                      and   bb2.bank_entity_type = bb.bank_entity_type
                      and  bb2.source_application_id <> bb.source_application_id
                      and   bb2.primary_flag = 'Y'
                      and   rownum = 1),
                     (select bb2.group_id
                      from  ce_upg_bank_rec b, ce_upg_bank_rec bb2
                      where b.group_id = c_group_id(i)
                      and   b.country = bb.country
                      and   b.bank_entity_type = 'BANK'
                      and   bb2.parent_upgrade_id = b.ce_upgrade_id
                      and   bb2.bank_or_branch_number is null
                      and   bb2.organization_name = bb.organization_name
                      and   bb2.bank_entity_type = bb.bank_entity_type
                      and  bb2.source_application_id <> bb.source_application_id
                      and   bb2.primary_flag = 'Y'
                      and   rownum = 1)),
                    primary_flag = 'N',
                    secondary_flag = 'Y',
                    last_update_date = sysdate,
                    last_updated_by = nvl(FND_GLOBAL.user_id,-1)
             where bank_or_branch_number = c_bank_or_branch_number(i)
             and   bank_or_branch_number is not null
             and   ce_upgrade_id = c_upg_id(i)
             and   bank_entity_type = p_bank_entity_type
             and   group_id is null
             and   not exists
                  (select null
                   from   ce_upg_bank_rec b, ce_upg_bank_rec bb2
                   where  b.country = bb.country
                   and    b.bank_entity_type = 'BANK'
                   and    b.group_id = c_group_id(i)
                   and    b.ce_upgrade_id = bb2.parent_upgrade_id
                   and    bb2.bank_or_branch_number = bb.bank_or_branch_number
                   and    bb2.bank_entity_type = bb.bank_entity_type
                   and    bb2.source_application_id = bb.source_application_id
                   and    bb2.group_id is not null
                   union all
                   select null
                   from   ce_upg_bank_rec b, ce_upg_bank_rec bb2
                   where  b.country = bb.country
                   and    b.bank_entity_type = 'BANK'
                   and    b.group_id = c_group_id(i)
                   and    b.ce_upgrade_id = bb2.parent_upgrade_id
                   and    bb2.bank_or_branch_number is null
                   and    bb2.organization_name = bb.organization_name
                   and    bb2.bank_entity_type = bb.bank_entity_type
                   and    bb2.source_application_id = bb.source_application_id
                   and    bb2.group_id is not null)
             and   exists
                  (select null from ce_upg_bank_rec b, ce_upg_bank_rec bb2
                   where  b.country = bb.country
                   and    b.bank_entity_type = 'BANK'
                   and    b.group_id = c_group_id(i)
                   and    b.ce_upgrade_id = bb2.parent_upgrade_id
                   and    bb2.bank_or_branch_number = bb.bank_or_branch_number
                   and    bb2.bank_entity_type = bb.bank_entity_type
                   and    bb2.primary_flag = 'Y'
                   union all
                   select null
                   from ce_upg_bank_rec b, ce_upg_bank_rec bb2
                   where  b.country = bb.country
                   and    b.bank_entity_type = 'BANK'
                   and    b.group_id = c_group_id(i)
                   and    b.ce_upgrade_id = bb2.parent_upgrade_id
                   and    bb2.bank_or_branch_number is null
                   and    bb2.organization_name = bb.organization_name
                   and    bb2.bank_entity_type = bb.bank_entity_type
                   and    bb2.primary_flag = 'Y');

           --    3.3 Group all other records with branch number
           c := '57';
           forall i in c_upg_id.first..c_upg_id.last
             update ce_upg_bank_rec bb
             set    group_id = nvl(
                     (select bb2.group_id
                      from ce_upg_bank_rec b, ce_upg_bank_rec bb2
                      where b.country = bb.country
                      and   b.group_id = c_group_id(i)
                      and   b.bank_entity_type = 'BANK'
                      and   b.ce_upgrade_id = bb2.parent_upgrade_id
                      and   bb2.bank_or_branch_number = bb.bank_or_branch_number
                      and   bb2.bank_entity_type = bb.bank_entity_type
                      and   bb2.primary_flag = 'Y'
                      and   rownum = 1),
                     (select bb2.group_id
                      from ce_upg_bank_rec b, ce_upg_bank_rec bb2
                      where b.country = bb.country
                      and   b.group_id = c_group_id(i)
                      and   b.bank_entity_type = 'BANK'
                      and   b.ce_upgrade_id = bb2.parent_upgrade_id
                      and   bb2.bank_or_branch_number is null
                      and   bb2.organization_name = bb.organization_name
                      and   bb2.bank_entity_type = bb.bank_entity_type
                      and   bb2.primary_flag = 'Y'
                      and   rownum = 1)),
                    primary_flag = 'N',
                    secondary_flag = 'N',
                    last_update_date = sysdate,
                    last_updated_by = nvl(FND_GLOBAL.user_id,-1)
             where bank_or_branch_number = c_bank_or_branch_number(i)
             and   bank_or_branch_number is not null
             and   ce_upgrade_id = c_upg_id(i)
             and   group_id is null;

           -- 4) Grouping branch reocrds with no branch number
           --    4.1 Set primary flag for records with no branch number
           c := '58';
           forall i in c_upg_id.first..c_upg_id.last
             update ce_upg_bank_rec bb
             set    group_id = c_upg_id(i),
                    primary_flag = 'Y',
                    secondary_flag = 'N',
                    last_update_date = sysdate,
                    last_updated_by = nvl(FND_GLOBAL.user_id,-1)
             where bank_or_branch_number is null
             and   ce_upgrade_id = c_upg_id(i)
             and   not exists
                  (select null
                   from   ce_upg_bank_rec b, ce_upg_bank_rec bb2
                   where  b.country = bb.country
                   and    b.group_id = c_group_id(i)
                   and    b.bank_entity_type = 'BANK'
                   and    b.ce_upgrade_id = bb2.parent_upgrade_id
                   and    bb2.organization_name = bb.organization_name
                   and    bb2.bank_entity_type = bb.bank_entity_type
                   and    bb2.primary_flag = 'Y');

           --    4.2 Set secondary flag for records with no branch number
           c := '59';
           forall i in c_upg_id.first..c_upg_id.last
             update ce_upg_bank_rec bb
             set    group_id =
                     (select bb2.group_id
                      from ce_upg_bank_rec b, ce_upg_bank_rec bb2
                      where b.country = bb.country
                      and   b.group_id = c_group_id(i)
                      and   b.bank_entity_type = 'BANK'
                      and   b.ce_upgrade_id = bb2.parent_upgrade_id
                      and  bb2.organization_name = bb.organization_name
                      and  bb2.source_application_id <> bb.source_application_id
                      and  bb2.bank_entity_type = bb.bank_entity_type
                      and  bb2.primary_flag = 'Y'
                      and  rownum = 1),
                    primary_flag = 'N',
                    secondary_flag = 'Y',
                    last_update_date = sysdate,
                    last_updated_by = nvl(FND_GLOBAL.user_id,-1)
             where bank_or_branch_number is null
             and   ce_upgrade_id = c_upg_id(i)
             and   group_id is null
             and   organization_name = c_org_name(i)
             and   not exists
                  (select null from ce_upg_bank_rec b, ce_upg_bank_rec bb2
                   where  b.country = bb.country
                   and    b.group_id = c_group_id(i)
                   and    b.bank_entity_type = 'BANK'
                   and    b.ce_upgrade_id = bb2.parent_upgrade_id
                   and    bb2.organization_name = bb.organization_name
                   and    bb2.source_application_id = bb.source_application_id
                   and    bb2.bank_entity_type = bb.bank_entity_type
                   and    bb2.group_id is not null)
             and   exists
                  (select null from ce_upg_bank_rec b, ce_upg_bank_rec bb2
                   where  b.country = bb.country
                   and    b.group_id = c_group_id(i)
                   and    b.bank_entity_type = 'BANK'
                   and    b.ce_upgrade_id = bb2.parent_upgrade_id
                   and    bb2.organization_name = bb.organization_name
                   and    bb2.bank_entity_type = bb.bank_entity_type
                   and    bb2.primary_flag = 'Y');

           --    4.3 Set all other records with no branch number
           c := '60';
           forall i in c_upg_id.first..c_upg_id.last
             update ce_upg_bank_rec bb
             set    group_id =
                     (select bb2.group_id
                      from ce_upg_bank_rec b, ce_upg_bank_rec bb2
                      where  b.country = bb.country
                      and    b.group_id = c_group_id(i)
                      and    b.bank_entity_type = 'BANK'
                      and    b.ce_upgrade_id = bb2.parent_upgrade_id
                      and    bb2.organization_name = bb.organization_name
                      and    bb2.bank_entity_type = bb.bank_entity_type
                      and    bb2.primary_flag = 'Y'
                      and    rownum = 1),
                    primary_flag = 'N',
                    secondary_flag = 'N',
                    last_update_date = sysdate,
                    last_updated_by = nvl(FND_GLOBAL.user_id,-1)
             where bank_or_branch_number is null
             and   organization_name = c_org_name(i)
             and   ce_upgrade_id = c_upg_id(i)
             and   group_id is null;

         else
           if l_debug in ('Y', 'C') then
             cep_standard.debug('c_upg_id.count='||to_char(c_upg_id.count));
           end if;
           exit;
         end if;
         tot_count := sql%rowcount;

         c := '61';
         commit;
         exit when branch_cur%notfound;
       end loop;

       c := '62';
       close branch_cur;
       if l_debug in ('Y', 'C') then
         cep_standard.debug('Total branch count='||to_char(tot_count));
       end if;

       -- Populate secondary attributes to primary records
       c := '63';
       open branch_sec;
       c_group_id.delete;
       c_upg_id.delete;
       c_known_as.delete;

       c := '64';
       FETCH branch_sec BULK COLLECT INTO c_group_id, c_upg_id, c_known_as;

       c := '65';
       if c_group_id.count > 0 then

         c := '66';
         forall i in c_group_id.first..c_group_id.last
           update ce_upg_bank_rec
           set    known_as = nvl(c_known_as(i), known_as),
                  last_update_date = sysdate,
                  last_updated_by = nvl(FND_GLOBAL.user_id,-1)
           where ce_upgrade_id = c_group_id(i);

         forall i in c_group_id.first..c_group_id.last
           insert into ce_upg_cont_point_rec
             (CE_UPGRADE_ID,
              BANK_ENTITY_TYPE,
              UPGRADE_STATUS,
              CONTACT_POINT_TYPE,
              PHONE_LINE_TYPE,
              OWNER_TABLE_NAME,
              OWNER_TABLE_ID,
              CREATED_BY_MODULE,
              PHONE_AREA_CODE,
              PHONE_NUMBER,
              ORG_PRIMARY_PHONE_FLAG,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY)
           select
              c_group_id(i),
              BANK_ENTITY_TYPE,
              UPGRADE_STATUS,
              CONTACT_POINT_TYPE,
              PHONE_LINE_TYPE,
              OWNER_TABLE_NAME,
              OWNER_TABLE_ID,
              curr_module,
              PHONE_AREA_CODE,
              PHONE_NUMBER,
              ORG_PRIMARY_PHONE_FLAG,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY
           from  ce_upg_cont_point_rec p
           where ce_upgrade_id = c_upg_id(i)
           and   CONTACT_POINT_TYPE = 'PHONE'
           and   PHONE_LINE_TYPE in ('FAX', 'PAGER')
           and   not exists
                (select null from ce_upg_cont_point_rec p2
                 where p2.ce_upgrade_id = c_group_id(i)
                 and   bank_entity_type = p.BANK_ENTITY_TYPE
                 and   CONTACT_POINT_TYPE = p.CONTACT_POINT_TYPE
                 and   PHONE_LINE_TYPE = p.PHONE_LINE_TYPE);

         forall i in c_group_id.first..c_group_id.last
           insert into ce_upg_cont_point_rec
             (CE_UPGRADE_ID,
              BANK_ENTITY_TYPE,
              UPGRADE_STATUS,
              CONTACT_POINT_TYPE,
              PHONE_LINE_TYPE,
              OWNER_TABLE_NAME,
              OWNER_TABLE_ID,
              CREATED_BY_MODULE,
              EMAIL_ADDRESS,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY)
           select
              c_group_id(i),
              BANK_ENTITY_TYPE,
              UPGRADE_STATUS,
              CONTACT_POINT_TYPE,
              PHONE_LINE_TYPE,
              OWNER_TABLE_NAME,
              OWNER_TABLE_ID,
              curr_module,
              EMAIL_ADDRESS,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY
           from  ce_upg_cont_point_rec p
           where ce_upgrade_id = c_upg_id(i)
           and   CONTACT_POINT_TYPE = 'EMAIL'
           and   not exists
                (select null from ce_upg_cont_point_rec p2
                 where p2.ce_upgrade_id = c_group_id(i)
                 and   bank_entity_type = p.BANK_ENTITY_TYPE
                 and   CONTACT_POINT_TYPE = p.CONTACT_POINT_TYPE);

         forall i in c_group_id.first..c_group_id.last
           insert into ce_upg_loc_rec l
             (CE_UPGRADE_ID,
              BANK_ENTITY_TYPE,
              UPGRADE_STATUS,
              IDENTIFYING_ADDRESS_FLAG,
              COUNTRY,
              ADDRESS1,
              ADDRESS2,
              ADDRESS3,
              ADDRESS4,
              ADDRESS_STYLE,
              CITY,
              STATE,
              PROVINCE,
              COUNTY,
              POSTAL_CODE,
              ADDRESS_LINE_PHONETIC,
              CREATED_BY_MODULE,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY)
           select
              c_group_id(i),
              BANK_ENTITY_TYPE,
              UPGRADE_STATUS,
              IDENTIFYING_ADDRESS_FLAG,
              COUNTRY,
              ADDRESS1,
              ADDRESS2,
              ADDRESS3,
              ADDRESS4,
              ADDRESS_STYLE,
              CITY,
              STATE,
              PROVINCE,
              COUNTY,
              POSTAL_CODE,
              ADDRESS_LINE_PHONETIC,
              curr_module,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY
           from  ce_upg_loc_rec l
           where ce_upgrade_id = c_upg_id(i)
           and   IDENTIFYING_ADDRESS_FLAG = 'N'
           and   not exists
                (select null from ce_upg_loc_rec
                 where ce_upgrade_id = c_group_id(i)
                 and   bank_entity_type = l.BANK_ENTITY_TYPE
                 and   IDENTIFYING_ADDRESS_FLAG = l.IDENTIFYING_ADDRESS_FLAG);

       end if;

       c := '67';
       close branch_sec;

       -- Validate primary records and populate validation errors if any
       c := '68';
       open branch_pri;
       c_upg_id.delete;
       c_country.delete;
       c_bank_or_branch_number.delete;
       c_group_id.delete;
       c_org_name_alt.delete;
       c_status.delete;

       c := '69';
       FETCH branch_pri BULK COLLECT INTO c_upg_id, c_country,
           c_bank_or_branch_number, c_group_id, c_org_name_alt;

       -- Append branch number to branch name if two primary branches with
       -- different branch number and same branch name under the same bank.
       -- (1) Copy branch records to ce_upga_bank_rec
       c := '71';
       forall i in c_upg_id.first..c_upg_id.last
         insert into ce_upga_bank_rec
           (party_id,
            ce_upgrade_id,
            parent_upgrade_id,
            bank_entity_type,
            upgrade_status,
            primary_flag,
            secondary_flag,
            group_id,
            bank_or_branch_number,
            bank_code,
            branch_code,
            institution_type,
            country,
            branch_type,
            rfc_code,
            created_by_module,
            organization_name,
            organization_name_phonetic,
            known_as,
            jgzz_fiscal_code,
            mission_statement,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
            start_date_active,
            end_date_active,
            eft_user_num,
            clearing_house_id,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login)
         select
            party_id,
            ce_upgrade_id,
            parent_upgrade_id,
            bank_entity_type,
            upgrade_status,
            primary_flag,
            secondary_flag,
            group_id,
            bank_or_branch_number,
            bank_code,
            branch_code,
            institution_type,
            country,
            branch_type,
            rfc_code,
            curr_module,
            organization_name,
            organization_name_phonetic,
            known_as,
            jgzz_fiscal_code,
            mission_statement,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
            start_date_active,
            end_date_active,
            eft_user_num,
            clearing_house_id,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login
         from ce_upg_bank_rec bb
         where ce_upgrade_id = c_upg_id(i)
         and exists
            (select null from ce_upg_bank_rec b, ce_upg_bank_rec bb2
             where b.ce_upgrade_id = bb2.parent_upgrade_id
             and   b.bank_entity_type = 'BANK'
             and   b.group_id = c_group_id(i)
             and bb2.bank_or_branch_number <> bb.bank_or_branch_number
             and bb2.organization_name = bb.organization_name
             and bb2.bank_entity_type = bb.bank_entity_type
             and bb2.primary_flag = 'Y'
             and bb2.creation_date >= bb.creation_date);


       -- (2) Update ce_upg_bank_rec to append branch number to branch name
       c := '72';
       forall i in c_upg_id.first..c_upg_id.last
         update ce_upg_bank_rec bb
         set    organization_name =
                  organization_name || ' ' || bank_or_branch_number,
                last_update_date = sysdate,
                last_updated_by = nvl(FND_GLOBAL.user_id,-1)
         where ce_upgrade_id = c_upg_id(i)
         and exists
            (select null from ce_upg_bank_rec b, ce_upg_bank_rec bb2
             where b.ce_upgrade_id = bb2.parent_upgrade_id
             and   b.bank_entity_type = 'BANK'
             and   b.group_id = c_group_id(i)
             and bb2.bank_or_branch_number <> bb.bank_or_branch_number
             and bb2.organization_name = bb.organization_name
             and bb2.bank_entity_type = bb.bank_entity_type
             and bb2.primary_flag = 'Y'
             and bb2.creation_date >= bb.creation_date);

       c := '73';
       for i in c_upg_id.first..c_upg_id.last
       loop

         fnd_msg_pub.initialize;
         x_msg_name := NULL;

         c := '74';
         ce_validate_bankinfo_upg.ce_validate_branch
          (x_country_name    => c_country(i),
           x_branch_number   => c_bank_or_branch_number(i),
           x_branch_name_alt => c_org_name_alt(i),
           x_bank_id         => c_group_id(i),
           x_validation_type => 'ALL',
           p_init_msg_list   => 'T',
           x_msg_count       => x_count,
           x_msg_data        => x_msgdata,
           x_value_out       => x_val_out,
           x_message_name_all => x_msg_name);

         if x_count > 0 then
           c_status(i) := 'INVALID';
         else
           c_status(i) := 'NULL';
         end if;
/*
         begin
           delete from ce_bank_upgrade_errors
           where  ce_upgrade_id = c_upg_id(i)
           and    bank_entity_type = 'BRANCH';
         exception
           when no_data_found then
             null;
           when too_many_rows then
             null;
           when others then
             raise;
         end;
*/
         c := '75';
         FOR j IN 1..x_count LOOP

            if (j=x_count) then
              p_msg_name := x_msg_name;
              x_msg_name := NULL;
            else
              p_msg_name := substr(x_msg_name, 1, instr(x_msg_name,',')-1);
              x_msg_name := substr(x_msg_name, instr(x_msg_name,',')+1,
                                   length(x_msg_name)-instr(x_msg_name,','));
            end if;

            c := '76';
            if (p_msg_name is not null) then
              insert into ce_bank_upgrade_errors
               (ce_upgrade_id, bank_entity_type, key_error_flag, application_id,
                message_name, creation_date, created_by, last_update_date,
                last_updated_by)
              values (c_upg_id(i), 'BRANCH', 'N', 260, p_msg_name,
                    sysdate, NVL(FND_GLOBAL.user_id,-1),
                    sysdate, NVL(FND_GLOBAL.user_id,-1));
            end if;
         END LOOP;
       end loop;

       -- Set upgrade status
       c := '77';
       forall i in c_upg_id.first..c_upg_id.last
         update ce_upg_bank_rec
         set    upgrade_status = c_status(i),
                last_update_date = sysdate,
                last_updated_by = nvl(FND_GLOBAL.user_id,-1)
         where  ce_upgrade_id = c_upg_id(i)
         and    c_status(i) = 'INVALID';

       c := '78';
       close branch_pri;

       --
       -- Update GROUPED status to ce_bank_upgrade_modes for 'BRANCH' level
       --
       c := '79';
       begin
         update ce_bank_upgrade_modes
         set    branch_upgrade_mode = 'GROUPED',
                last_update_date = sysdate,
                last_updated_by = nvl(FND_GLOBAL.user_id,-1);

       exception
         when too_many_rows then
           null;
         when others then
           raise;
       end;
       c := '80';

     elsif (p_bank_entity_type = 'ACCOUNT') then
       c := '101';
       open acct_cur;
       tot_count := 0;

       c := '102';
       loop
         c_country.delete;
         c_acct_name.delete;
         c_acct_num.delete;
         c_currency.delete;
         c_acct_type.delete;
         c_upg_id.delete;
         c_app_id.delete;
         c_creation_date.delete;
         c_group_id.delete;

         c := '103';
         FETCH acct_cur BULK COLLECT INTO c_country, c_acct_name, c_acct_num,
           c_currency, c_acct_type, c_upg_id, c_app_id, c_creation_date,
           c_group_id
         LIMIT c_commit_size;

         c := '104';
         if c_upg_id.count > 0 then

           -- 5) Grouping account records
           --    5.1 Set primary account records
           c := '105';
           forall i in c_upg_id.first..c_upg_id.last
             update ce_upg_bank_accounts ba
             set    group_id = c_upg_id(i),
                    primary_acct_flag = 'Y',
                    secondary_acct_flag = 'N',
                    last_update_date = sysdate,
                    last_updated_by = nvl(FND_GLOBAL.user_id,-1)
             where  ce_upgrade_id = c_upg_id(i)
             and not exists
                (select null from ce_upg_bank_rec bb, ce_upg_bank_accounts ba2
                 where  bb.ce_upgrade_id = ba2.parent_upgrade_id
                 and    bb.group_id = c_group_id(i)
                 and    bb.bank_entity_type = 'BRANCH'
                 and    ba2.bank_account_name = ba.bank_account_name
                 and    ba2.bank_account_num = ba.bank_account_num
                 and    ba2.currency_code = ba.currency_code
                 and    decode(bb.country, 'JP', ba2.bank_account_type, 'X') =
                        decode(bb.country, 'JP', ba.bank_account_type, 'X')
                 and    ba2.primary_acct_flag = 'Y');

           --    5.2 Set secondary flag for bank account records
           c := '106';
           forall i in c_upg_id.first..c_upg_id.last
             update ce_upg_bank_accounts ba
             set    group_id =
                     (select ba2.group_id
                      from  ce_upg_bank_rec bb, ce_upg_bank_accounts ba2
                      where bb.group_id = c_group_id(i)
                      and   bb.bank_entity_type = 'BANK'
                      and   ba2.parent_upgrade_id = bb.ce_upgrade_id
                      and   ba2.bank_account_name = ba.bank_account_name
                      and   ba2.bank_account_num = ba.bank_account_num
                      and   ba2.currency_code = ba.currency_code
                      and   decode(bb.country, 'JP', ba2.bank_account_type, 'X')
                          = decode(bb.country, 'JP', ba.bank_account_type, 'X')
                      and  ba2.source_application_id <> ba.source_application_id
                      and   ba2.primary_acct_flag = 'Y'
                      and   rownum = 1),
                    primary_acct_flag = 'N',
                    secondary_acct_flag = 'Y',
                    last_update_date = sysdate,
                    last_updated_by = nvl(FND_GLOBAL.user_id,-1)
             where ce_upgrade_id = c_upg_id(i)
             and   group_id is null
             and   not exists
                  (select null
                   from   ce_upg_bank_rec bb, ce_upg_bank_accounts ba2
                   where  bb.bank_entity_type = 'BRANCH'
                   and    bb.group_id = c_group_id(i)
                   and    bb.ce_upgrade_id = ba2.parent_upgrade_id
                   and    ba2.bank_account_name = ba.bank_account_name
                   and    ba2.bank_account_num = ba.bank_account_num
                   and    ba2.currency_code = ba.currency_code
                   and    decode(bb.country, 'JP', ba2.bank_account_type, 'X') =
                          decode(bb.country, 'JP', ba.bank_account_type, 'X')
                   and    ba2.source_application_id = ba.source_application_id
                   and    ba2.group_id is not null)
             and   exists
                  (select null from ce_upg_bank_rec bb, ce_upg_bank_accounts ba2
                   where  bb.bank_entity_type = 'BRANCH'
                   and    bb.group_id = c_group_id(i)
                   and    bb.ce_upgrade_id = ba2.parent_upgrade_id
                   and    ba2.bank_account_name = ba.bank_account_name
                   and    ba2.bank_account_num = ba.bank_account_num
                   and    ba2.currency_code = ba.currency_code
                   and    decode(bb.country, 'JP', ba2.bank_account_type, 'X') =
                          decode(bb.country, 'JP', ba.bank_account_type, 'X')
                   and    ba2.primary_acct_flag = 'Y');

           --    5.3 Group all other bank account records
           c := '107';
           forall i in c_upg_id.first..c_upg_id.last
             update ce_upg_bank_accounts ba
             set    group_id =
                     (select ba2.group_id
                      from ce_upg_bank_rec bb, ce_upg_bank_accounts ba2
                      where bb.group_id = c_group_id(i)
                      and   bb.bank_entity_type = 'BRANCH'
                      and   bb.ce_upgrade_id = ba2.parent_upgrade_id
                      and   ba2.bank_account_name = ba.bank_account_name
                      and   ba2.bank_account_num = ba.bank_account_num
                      and   ba2.currency_code = ba.currency_code
                      and   decode(bb.country, 'JP', ba2.bank_account_type, 'X')
                          = decode(bb.country, 'JP', ba.bank_account_type, 'X')
                      and   ba2.primary_acct_flag = 'Y'
                      and   rownum = 1),
                    primary_acct_flag = 'N',
                    secondary_acct_flag = 'N',
                    last_update_date = sysdate,
                    last_updated_by = nvl(FND_GLOBAL.user_id,-1)
             where ce_upgrade_id = c_upg_id(i)
             and   group_id is null;

           c := '108';

         else
           if l_debug in ('Y', 'C') then
             cep_standard.debug('c_upg_id.count='||to_char(c_upg_id.count));
           end if;
           exit;
         end if;
         tot_count := sql%rowcount;

         c := '109';
         commit;
         exit when acct_cur%notfound;
       end loop;

       c := '110';
       close acct_cur;
       if l_debug in ('Y', 'C') then
         cep_standard.debug('Total account count='||to_char(tot_count));
       end if;

       -- Populate secondary attributes to primary records
       c := '111';
       open acct_sec;
       c_group_id.delete;
       c_app_id.delete;
       c_upg_id.delete;
       c_start_date.delete;
       c_legal_name.delete;
       c_description.delete;
       c_xtr_flag.delete;
       c_pay_flag.delete;
       c_xtr_amount.delete;
       c_xtr_percent.delete;
       c_pay_amount.delete;
       c_pay_percent.delete;
       c_cashflow_order.delete;
       c_target_balance.delete;

       c := '112';
       FETCH acct_sec BULK COLLECT INTO c_group_id, c_app_id, c_upg_id,
         c_start_date, c_legal_name, c_description, c_xtr_flag,
         c_pay_flag, c_xtr_amount, c_xtr_percent, c_pay_amount, c_pay_percent,
         c_cashflow_order, c_target_balance;

       c := '113';
       if c_group_id.count > 0 then

         c := '114';
         forall i in c_group_id.first..c_group_id.last
           update ce_upg_bank_accounts
           set    start_date = decode(c_app_id(i), 185, c_start_date(i)),
                  legal_account_name = decode(c_app_id(i), 185, c_legal_name(i)),
                  description = decode(source_application_id, 185, c_description(i)),
                  xtr_use_allowed_flag = decode(c_app_id(i), 185,c_xtr_flag(i)),
                  pay_use_allowed_flag = decode(c_app_id(i), 801,c_pay_flag(i)),
                  xtr_amount_tolerance = decode(c_app_id(i), 185, c_xtr_amount(i)),
                  xtr_percent_tolerance = decode(c_app_id(i), 185, c_xtr_percent(i)),
                  pay_amount_tolerance = decode(c_app_id(i), 801, c_pay_amount(i)),
                  pay_percent_tolerance = decode(c_app_id(i), 801, c_pay_percent(i)),
                  cashflow_display_order = decode(c_app_id(i), 185,c_cashflow_order(i)),
                  target_balance = decode(c_app_id(i), 185, c_target_balance(i)),
                  last_update_date = sysdate,
                  last_updated_by = nvl(FND_GLOBAL.user_id,-1)
           where ce_upgrade_id = c_group_id(i);

       end if;

       c := '115';
       close acct_sec;

       -- Validate primary records and populate validation errors if any
       c := '116';
       open acct_pri;
       c_upg_id.delete;
       c_country.delete;
       c_bank_number.delete;
       c_bank_or_branch_number.delete;
       c_acct_num.delete;
       c_acct_reference.delete;
       c_acct_name.delete;
       c_cd.delete;
       c_group_id.delete;
       c_acct_type.delete;
       c_acct_suffix.delete;
       c_status.delete;

       c := '117';
       FETCH acct_pri BULK COLLECT INTO c_upg_id, c_country, c_bank_number,
         c_bank_or_branch_number, c_acct_num, c_acct_reference, c_acct_name,
         c_cd, c_group_id, c_acct_type, c_acct_suffix;

       c := '119';
       for i in c_upg_id.first..c_upg_id.last
       loop

         c := '120';
         fnd_msg_pub.initialize;
         x_msg_name := NULL;

         ce_validate_bankinfo_upg.ce_validate_account
          (x_country_name    => c_country(i),
           x_bank_number     => c_bank_number(i),
           x_branch_number   => c_bank_or_branch_number(i),
           x_account_number  => c_acct_num(i),
           x_account_type    => c_acct_type(i),
           x_account_suffix  => c_acct_suffix(i),
           x_secondary_account_reference => c_acct_reference(i),
           x_account_name    => c_acct_name(i),
           x_cd              => c_cd(i),
           x_validation_type => 'ALL',
           p_init_msg_list   => 'T',
           x_msg_count       => x_count,
           x_msg_data        => x_msgdata,
           x_value_out       => x_val_out,
           x_message_name_all => x_msg_name);

         if x_count > 0 then
           c_status(i) := 'INVALID';
         else
           c_status(i) := 'NULL';
         end if;
/*
         begin
           delete from ce_bank_upgrade_errors
           where  ce_upgrade_id = c_upg_id(i)
           and    bank_entity_type = 'ACCOUNT';
         exception
           when no_data_found then
             null;
           when too_many_rows then
             null;
           when others then
             raise;
         end;
*/
         c := '121';
         FOR j IN 1..x_count LOOP

            if (j=x_count) then
              p_msg_name := x_msg_name;
              x_msg_name := NULL;
            else
              p_msg_name := substr(x_msg_name, 1, instr(x_msg_name,',')-1);
              x_msg_name := substr(x_msg_name, instr(x_msg_name,',')+1,
                                   length(x_msg_name)-instr(x_msg_name,','));
            end if;

            if (p_msg_name is not null) then
              insert into ce_bank_upgrade_errors
               (ce_upgrade_id, bank_entity_type, key_error_flag, application_id,
                message_name, creation_date, created_by, last_update_date,
                last_updated_by)
              values (c_upg_id(i), 'ACCOUNT', 'N', 260, p_msg_name,
                    sysdate, NVL(FND_GLOBAL.user_id,-1),
                    sysdate, NVL(FND_GLOBAL.user_id,-1));
            end if;
         END LOOP;
       end loop;

       -- Set upgrade status
       c := '122';
       forall i in c_upg_id.first..c_upg_id.last
         update ce_upg_bank_accounts
         set    upgrade_status = c_status(i),
                last_update_date = sysdate,
                last_updated_by = nvl(FND_GLOBAL.user_id,-1)
         where  ce_upgrade_id = c_upg_id(i)
         and    c_status(i) = 'INVALID';

       c := '123';
       close acct_pri;

       c := '124';
       open ba_use_cur;
       tot_count := 0;

       c := '125';
       loop
         c_upg_id.delete;
         c_app_id.delete;
         c_creation_date.delete;
         c_group_id.delete;
         c_org_id.delete;
         c_le_id.delete;
         c_pay_flag.delete;
         c_pay_ba_id.delete;

         c := '126';
         FETCH ba_use_cur BULK COLLECT INTO c_group_id, c_org_id, c_le_id, c_app_id,
           c_upg_id, c_creation_date, c_pay_flag, c_pay_ba_id
         LIMIT c_commit_size;

         c := '127';
         if c_upg_id.count > 0 then

           -- 6) Grouping account use records
           --    6.1 Set primary account records
           c := '128';
           forall i in c_upg_id.first..c_upg_id.last
             update ce_upg_ba_uses_all bau
             set    group_id = c_upg_id(i),
                    primary_acct_use_flag = 'Y',
                    secondary_acct_use_flag = 'N',
                    last_update_date = sysdate,
                    last_updated_by = nvl(FND_GLOBAL.user_id,-1)
             where  ce_upgrade_id = c_upg_id(i)
             and not exists
                (select null
                 from   ce_upg_bank_accounts ba, ce_upg_ba_uses_all bau2
                 where  ba.ce_upgrade_id = bau2.parent_upgrade_id
                 and    ba.group_id = c_group_id(i)
                 and    nvl(bau2.org_id, -1) = nvl(bau.org_id, -1)
                 and    nvl(bau2.legal_entity_id, -1) = nvl(bau.legal_entity_id, -1)
                 and    bau2.source_application_id = bau.source_application_id
                 and    bau2.primary_acct_use_flag = 'Y');

           --    6.2 Set secondary account records (dummy Payroll only)
            forall i in c_upg_id.first..c_upg_id.last
             update ce_upg_ba_uses_all bau
             set    group_id =
                     (select bau2.group_id
                      from   ce_upg_bank_accounts ba, ce_upg_ba_uses_all bau2
                      where  ba.ce_upgrade_id = bau2.parent_upgrade_id
                      and    ba.group_id = c_group_id(i)
                      and    bau2.org_id = bau.org_id
                      and    bau2.source_application_id = 200
                      and    bau2.primary_acct_use_flag = 'Y'),
                    primary_acct_use_flag = 'N',
                    secondary_acct_use_flag = 'Y',
                    last_update_date = sysdate,
                    last_updated_by = nvl(FND_GLOBAL.user_id,-1)
             where  ce_upgrade_id = c_upg_id(i)
             and    group_id is null
             and    source_application_id = 801
             and not exists
                (select null
                 from   ce_upg_bank_accounts ba, ce_upg_ba_uses_all bau2
                 where  ba.ce_upgrade_id = bau2.parent_upgrade_id
                 and    ba.group_id = c_group_id(i)
                 and    bau2.org_id = bau.org_id
                 and    bau2.source_application_id = bau.source_application_id
                 and    bau2.group_id is not null)
             and exists
                (select null
                 from   ce_upg_bank_accounts ba, ce_upg_ba_uses_all bau2
                 where  ba.ce_upgrade_id = bau2.parent_upgrade_id
                 and    ba.group_id = c_group_id(i)
                 and    bau2.org_id = bau.org_id
                 and    bau2.primary_acct_use_flag = 'Y');

           --    6.3 Group all other bank account use records
           c := '129';
           forall i in c_upg_id.first..c_upg_id.last
             update ce_upg_ba_uses_all bau
             set    group_id =
                     (select bau2.group_id
                      from   ce_upg_bank_accounts ba, ce_upg_ba_uses_all bau2
                      where  ba.group_id = c_group_id(i)
                      and    ba.ce_upgrade_id = bau2.parent_upgrade_id
                      and    bau2.org_id = bau.org_id
                      and    bau2.source_application_id =
                             bau.source_application_id
                      and    bau2.primary_flag = 'Y'
                      and    rownum = 1),
                    primary_acct_use_flag = 'N',
                    secondary_acct_use_flag = 'N',
                    last_update_date = sysdate,
                    last_updated_by = nvl(FND_GLOBAL.user_id,-1)
             where ce_upgrade_id = c_upg_id(i)
             and   group_id is null;

           c := '130';
           -- 6.4 Populate secondary attributes to primary records
           forall i in c_upg_id.first..c_upg_id.last
             update ce_upg_ba_uses_all bau
             set    pay_use_enable_flag = c_pay_flag(i),
                    payroll_bank_account_id = c_pay_ba_id(i),
                    last_update_date = sysdate,
                    last_updated_by = nvl(FND_GLOBAL.user_id,-1)
             where  source_application_id = 200
             and    primary_acct_use_flag = 'Y'
             and exists
                (select null
                 from ce_upg_ba_uses_all bau2
                 where  bau2.group_id = bau.ce_upgrade_id
                 and    bau2.ce_upgrade_id = c_upg_id(i)
                 and    bau2.source_application_id = 801
                 and    bau2.secondary_acct_use_flag = 'Y');

         else
           if l_debug in ('Y', 'C') then
             cep_standard.debug('c_upg_id.count='||to_char(c_upg_id.count));
           end if;
           exit;
         end if;
         tot_count := sql%rowcount;

         c := '131';
         commit;
         exit when ba_use_cur%notfound;
       end loop;

       c := '132';
       close ba_use_cur;
       if l_debug in ('Y', 'C') then
         cep_standard.debug('Total account count='||to_char(tot_count));
       end if;

       --
       -- Update GROUPED status to ce_bank_upgrade_modes for 'ACCOUNT' level
       --
       c := '133';
       begin
         update ce_bank_upgrade_modes
         set    account_upgrade_mode = 'GROUPED',
                last_update_date = sysdate,
                last_updated_by = nvl(FND_GLOBAL.user_id,-1);

       exception
         when too_many_rows then
           null;
         when others then
           raise;
       end;

     end if;

     c := '134';
     if l_debug in ('Y', 'C') then
       cep_standard.debug('<<CE_BANK_GROUPINGS.grouping '||sysdate);
       cep_standard.disable_debug(p_display_debug);
     end if;

     c := '135';

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       if (c_grouping_flag = 'N') then
         cep_standard.debug('c='||c||', the '||p_bank_entity_type||
           ' upgrade mode is not ready for grouping.');
       end if;
     WHEN OTHERS THEN
       rollback;
       cep_standard.debug('sqlerrm='||sqlerrm);
       cep_standard.debug('EXCEPTION: CE_BANK_GROUPINGS.grouping c=' || c);
       RAISE;

   END;     /* grouping */

END CE_BANK_GROUPINGS;

/
