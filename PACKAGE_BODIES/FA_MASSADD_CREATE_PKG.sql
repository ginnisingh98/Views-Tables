--------------------------------------------------------
--  DDL for Package Body FA_MASSADD_CREATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MASSADD_CREATE_PKG" as
/* $Header: FAMADCB.pls 120.14.12010000.17 2010/03/30 16:01:12 bridgway ship $ */


   --*********************** Global constants ******************************--

   G_PKG_NAME      CONSTANT   varchar2(30) := 'FA_MASSADD_CREATE_PKG';
   G_API_NAME      CONSTANT   varchar2(30) := 'Create_lines';
   G_API_VERSION   CONSTANT   number       := 1.0;

   type num_tbl_type   is table of number index by binary_integer;
   type rowid_tbl_type is table of rowid index by binary_integer;
   type char_tbl_type  is table of varchar2(15) index by binary_integer;

   g_log_level_rec               fa_api_types.log_level_rec_type;

   G_child_iteration_count       number := 0; -- used to track recursion level

   G_batch_size                  number := 1000;

   --------------------------------------------------------------------------------

   FUNCTION Get_Account_Segment
               (P_segment_num    IN   NUMBER
               ,P_base_ccid      IN   NUMBER
               ,P_coa_id         IN   VARCHAR2
               ,P_calling_fn     IN   VARCHAR2   DEFAULT NULL
               ,p_log_level_rec  IN   FA_API_TYPES.log_level_rec_type default null
               ) RETURN VARCHAR2 IS

      l_result              BOOLEAN;
      l_num_of_segments     NUMBER;
      l_base_segments       FND_FLEX_EXT.SEGMENTARRAY;
      l_debug_info          VARCHAR2(240);
      l_calling_fn          VARCHAR2(200) := 'FA_MASS_ADDITIONS_PKG.Get_Account_Segment';

   BEGIN

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn
                         ,'Calling FND_FLEX_EXT.Get_segments'
                         ,p_coa_id
                         ,p_log_level_rec => g_log_level_rec);
      end if;

      l_result :=  FND_FLEX_EXT.GET_SEGMENTS
                       ('SQLGL'
                       ,'GL#'
                       ,P_coa_id
                       ,P_base_ccid
                       ,l_num_of_segments
                       ,l_base_segments);

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn
                         ,'Segment Number'
                         ,l_base_segments(P_segment_num)
                         ,p_log_level_rec => g_log_level_rec);
      end if;

      return (l_base_segments(P_segment_num));

   EXCEPTION
      WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_calling_fn);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info );
              FND_MESSAGE.SET_TOKEN('PARAMETERS','P_base_ccid: '
                              ||TO_CHAR(P_base_ccid)
                              ||',P_coa_id: '
                              ||P_coa_id );

           END IF;

           fa_srvr_msg.add_sql_error
              (calling_fn => l_calling_fn
              ,p_log_level_rec => g_log_level_rec);

           APP_EXCEPTION.RAISE_EXCEPTION;


   END Get_Account_Segment;

   --------------------------------------------------------------------------------

   FUNCTION Prepare_Clearing_GT
               (p_ledger_id      number
               ,p_book_type_code varchar2
               ,p_coa_id         number
               ,p_segment_num    number
               ) return boolean is

      l_calling_fn   VARCHAR2(200) := 'FA_MASS_ADDITIONS_PKG.Prepare_Clearing_GT';

      l_count        number;
      error_found    exception;

   BEGIN

      select count(*)
        into l_count
        from fa_book_controls
       where set_of_books_id = p_ledger_id
         and book_class = 'CORPORATE';

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn
                         ,'number of book for this ledger'
                         ,to_char(l_count)
                         ,p_log_level_rec => g_log_level_rec);

         fa_debug_pkg.add(l_calling_fn
                         ,'inserting'
                         ,'category accounts into GT'
                         ,p_log_level_rec => g_log_level_rec);
      end if;

      -- load the category gt
      if (l_count = 1) then

         insert into fa_category_accounts_gt
                     (clearing_acct
                     ,book_type_code
                     ,asset_type)
         select clearing_acct
               ,book_type_code
               ,decode(max(acct_type),
                       1, 'CIP',
                      'CAPITALIZED')
           from (select asset_clearing_acct clearing_acct
                       ,book_type_code
                       , 2 acct_type
                   from fa_category_books
                  where book_type_code = p_book_type_code
                  UNION
                 select cip_clearing_acct , book_type_code, 1
                   from fa_category_books
                  where cip_clearing_acct is not null
                    and book_type_code = p_book_type_code)
          group by clearing_acct, book_type_code;

      else

         insert into fa_category_accounts_gt
                     (clearing_acct
                     ,book_type_code
                     ,asset_type)
         select clearing_acct
               ,book_type_code
               ,decode(max(acct_type),
                        1, 'CIP',
                        'CAPITALIZED')
           from (select asset_clearing_acct clearing_acct
                       ,cb.book_type_code
                       ,2 acct_type
                   from fa_category_books cb,
                        fa_book_controls  bc
                  where cb.book_type_code  = bc.book_type_code
                    and bc.book_class      = 'CORPORATE'
                    and bc.set_of_books_id = p_ledger_id
                  UNION
                 select cip_clearing_acct
                       ,cb.book_type_code
                       ,1
                   from fa_category_books cb,
                        fa_book_controls  bc
                  where cip_clearing_acct is not null
                    and cb.book_type_code  = bc.book_type_code
                    and bc.book_class      = 'CORPORATE'
                    and bc.set_of_books_id = p_ledger_id)
          group by clearing_acct, book_type_code;

      end if;

      l_count := SQL%ROWCOUNT;
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn
                         ,'No of Records Inserted '
                         ,to_char(l_count)
                         ,p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add(l_calling_fn
                         ,'Deleting duplicate rows from '
                         ,'fa_category_accounts_gt'
                         ,p_log_level_rec => g_log_level_rec);
      end if;

      -- purge any duplicates from other books
      -- this will result in FIFO processing if accounts
      -- are not unique across books!!!!

      delete
        from fa_category_accounts_gt gt1
       where gt1.book_type_code <> p_book_type_code
         and exists
             (select /*+ index (gt2 FA_CATEGORY_ACCOUNTS_GT_N1) */ 1
                from fa_category_accounts_gt gt2
               where gt2.book_type_code = p_book_type_code
                 and gt2.clearing_acct  = gt1.clearing_acct);

      l_count := SQL%ROWCOUNT;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn
                         ,'No of Records Deleted '
                         ,to_char(l_count)
                         ,p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add(l_calling_fn
                         ,'Deleting duplicate other book rows from '
                         ,'fa_category_accounts_gt'
                         ,p_log_level_rec => g_log_level_rec);
      end if;

      delete
        from fa_category_accounts_gt gt1
       where not exists
             (select /*+ index (gt2 FA_CATEGORY_ACCOUNTS_GT_N1) */ 1
                from fa_category_accounts_gt gt2
               where gt2.book_type_code = p_book_type_code
                 and gt2.clearing_acct  = gt1.clearing_acct)
         and gt1.rowid <>
             (select min(rowid)
                from fa_category_accounts_gt gt3
               where gt3.clearing_acct  = gt1.clearing_acct);

      l_count := SQL%ROWCOUNT;
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn
                         ,'No of Records Deleted '
                         ,to_char(l_count)
                         ,p_log_level_rec => g_log_level_rec);
      end if;

      return true;

   exception
      when error_found then
           return false;

      WHEN OTHERS THEN
           fa_srvr_msg.add_sql_error
              (calling_fn => l_calling_fn
              ,p_log_level_rec => g_log_level_rec);

           RETURN FALSE;
   end;


 --------------------------------------------------------------------------------

 -- NOTE: the incoming mass_addition_id is always the root parent (not immedate one)!

 FUNCTION Preprocess_Child_Lines
             (p_book_type_code      IN varchar2
             ,p_mode                IN varchar2
             ,p_invoice_dist_id_tbl IN num_tbl_type
             ,p_mass_add_id_tbl     IN num_tbl_type
             ,p_asset_id_tbl        IN num_tbl_type
             ,p_line_status_tbl     IN char_tbl_type
             ,p_posting_status_tbl  IN char_tbl_type
             ,p_queue_name_tbl      IN char_tbl_type
             ,p_asset_type_tbl      IN char_tbl_type
             ,p_merged_code_tbl     IN char_tbl_type)   RETURN BOOLEAN IS


      l_calling_fn          varchar2(80) :=
                           'FA_MASSADD_CREATE_PKG.Preprocess_Child_Lines';

      l_invoice_dist_id_tbl num_tbl_type;
      l_mass_add_id_tbl     num_tbl_type;
      l_asset_id_tbl        num_tbl_type;
      l_line_status_tbl     char_tbl_type;
      l_posting_status_tbl  char_tbl_type;
      l_queue_name_tbl      char_tbl_type;
      l_asset_type_tbl      char_tbl_type;
      l_merged_code_tbl     char_tbl_type;

      error_found           exception;

   begin

      G_child_iteration_count := G_child_iteration_count + 1;

      forall i in 1..p_invoice_dist_id_tbl.count
      update /*+ index(gt FA_MASS_ADDITIONS_GT_N4) */fa_mass_additions_gt
         set mass_addition_id               = fa_mass_additions_s.nextval
            ,book_type_code                 = p_book_type_code
            ,line_status                    = p_line_status_tbl(i)
            ,posting_status                 = p_posting_status_tbl(i)
            ,queue_name                     = p_queue_name_tbl(i)
            ,asset_type                     = p_asset_type_tbl(i)
            ,split_merged_code              = p_merged_code_tbl(i)
            ,merged_code                    = p_merged_code_tbl(i)
            ,parent_mass_addition_id        = p_mass_add_id_tbl(i)
            ,merge_parent_mass_additions_id = p_mass_add_id_tbl(i)
            ,add_to_asset_id                = p_asset_id_tbl(i)
       where parent_invoice_dist_id         = p_invoice_dist_id_tbl(i)
         and line_status                    = 'NEW'
         and ledger_category_code           = 'P'
       returning invoice_distribution_id
                ,parent_mass_addition_id
                ,add_to_asset_id
                ,line_status
                ,posting_status
                ,queue_name
                ,asset_type
                ,merged_code
            bulk collect
            into l_invoice_dist_id_tbl
                ,l_mass_add_id_tbl
                ,l_asset_id_tbl
                ,l_line_status_tbl
                ,l_posting_status_tbl
                ,l_queue_name_tbl
                ,l_asset_type_tbl
                ,l_merged_code_tbl;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn
                         ,'No of elements in the p_inv_dist_array'
                         ,p_invoice_dist_id_tbl.count
                         ,p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add(l_calling_fn
                         ,'No of updated records fetched for iteration' || to_char(G_child_iteration_count)
                         , to_char(l_invoice_dist_id_tbl.count)
                         ,p_log_level_rec => g_log_level_rec);
      end if;

      if (l_invoice_dist_id_tbl.count <> 0) then

         -- continue performing the recursive call until no matches are found
         if not Preprocess_Child_Lines(p_book_type_code      => p_book_type_code
                                       ,p_mode                => 'GT'
                                       ,p_invoice_dist_id_tbl => l_invoice_dist_id_tbl
                                       ,p_mass_add_id_tbl     => l_mass_add_id_tbl
                                       ,p_asset_id_tbl        => l_asset_id_tbl
                                       ,p_line_status_tbl     => l_line_status_tbl
                                       ,p_posting_status_tbl  => l_posting_status_tbl
                                       ,p_queue_name_tbl      => l_queue_name_tbl
                                       ,p_asset_type_tbl      => l_asset_type_tbl
                                       ,p_merged_code_tbl     => l_merged_code_tbl) then
            raise error_found;
         end if;
      end if;

      G_child_iteration_count := G_child_iteration_count - 1;

      return true;

   exception
      WHEN OTHERS THEN
           fa_srvr_msg.add_sql_error
              (calling_fn => l_calling_fn
              ,p_log_level_rec => g_log_level_rec);

           RETURN FALSE;

   end;

   --------------------------------------------------------------------------------
   --
   -- for a child line with a split parent, insert the lines as non-merged for now
   --
   --------------------------------------------------------------------------------


   FUNCTION Preprocess_Split_Lines
               (p_book_type_code  IN varchar2
               ,p_mode            IN varchar2
               ,p_invoice_dist_id_tbl IN num_tbl_type
               ,p_asset_type_tbl  IN char_tbl_type
               ) RETURN BOOLEAN IS


      l_calling_fn          varchar2(80) := 'FA_MASSADD_CREATE_PKG.Preprocess_Split_Lines';

      l_invoice_dist_id_tbl num_tbl_type;
      l_mass_add_id_tbl     num_tbl_type;
      l_asset_id_tbl        num_tbl_type;
      l_line_status_tbl     char_tbl_type;
      l_posting_status_tbl  char_tbl_type;
      l_queue_name_tbl      char_tbl_type;
      l_asset_type_tbl      char_tbl_type;
      l_merged_code_tbl     char_tbl_type;

      error_found           exception;

   begin

      forall i in 1..p_invoice_dist_id_tbl.count
      update /*+ index(gt FA_MASS_ADDITIONS_GT_N4) */ fa_mass_additions_gt
         set mass_addition_id               = fa_mass_additions_s.nextval
            ,book_type_code                 = p_book_type_code
            ,line_status                    = 'VALID'
            ,posting_status                 = 'NEW'
            ,queue_name                     = 'NEW'
            ,asset_type                     = p_asset_type_tbl(i)
       where parent_invoice_dist_id         = p_invoice_dist_id_tbl(i)
         and line_status                    = 'NEW'
         and ledger_category_code           = 'P'
       returning invoice_distribution_id, mass_addition_id, asset_type
            bulk collect
            into l_invoice_dist_id_tbl, l_mass_add_id_tbl, l_asset_type_tbl;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,
                         'No of elements in the p_inv_dist_array'
                         ,p_invoice_dist_id_tbl.count
                         ,p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add(l_calling_fn
                         ,'No of updated records updated for split MAD/AI lines'
                         , l_invoice_dist_id_tbl.count
                         ,p_log_level_rec => g_log_level_rec);
      end if;

      if (l_invoice_dist_id_tbl.count <> 0) then

         -- proactive set the values for merged children
         for i in 1..l_invoice_dist_id_tbl.count loop
            l_asset_id_tbl(l_asset_id_tbl.count + 1) := null;
            l_line_status_tbl(l_line_status_tbl.count + 1) := 'VALID';
            l_posting_status_tbl(l_posting_status_tbl.count + 1) := 'MERGED';
            l_queue_name_tbl(l_queue_name_tbl.count + 1) := 'NEW';
            l_merged_code_tbl(l_merged_code_tbl.count + 1) := 'MC';
         end loop;


         -- flag these updated lines as parent MP where applicable
         forall i in 1..l_mass_add_id_tbl.count
         update /*+ index(gt FA_MASS_ADDITIONS_GT_N3) */ fa_mass_additions_gt gt
            set split_merged_code = 'MP',
                merged_code       = 'MP'
          where mass_addition_id        = l_mass_add_id_tbl(i)
            and book_type_code          = p_book_type_code
            and invoice_payment_id     is null -- exclude discounts
            and ledger_category_code    = 'P'
            and exists
                (select 1
                   from fa_mass_additions_gt gt2
                  where gt2.parent_invoice_dist_id = gt.invoice_distribution_id
                    and gt2.rowid <> gt.rowid);

         -- continue performing the recursive call until no matches are found
         if not Preprocess_Child_Lines(p_book_type_code      => p_book_type_code
                                      ,p_mode                => 'GT'
                                      ,p_invoice_dist_id_tbl => l_invoice_dist_id_tbl
                                      ,p_mass_add_id_tbl     => l_mass_add_id_tbl
                                      ,p_asset_id_tbl        => l_asset_id_tbl
                                      ,p_line_status_tbl     => l_line_status_tbl
                                      ,p_posting_status_tbl  => l_posting_status_tbl
                                      ,p_queue_name_tbl      => l_queue_name_tbl
                                      ,p_asset_type_tbl      => l_asset_type_tbl
                                      ,p_merged_code_tbl     => l_merged_code_tbl) then
            raise error_found;
         end if;

      end if;


      return true;

   exception
      when error_found then
           return false;

      WHEN OTHERS THEN
           fa_srvr_msg.add_sql_error
              (calling_fn => l_calling_fn
              ,p_log_level_rec => g_log_level_rec);

           RETURN FALSE;

   END;

   --------------------------------------------------------------------------------
   --
   -- update the immediate child lines (those linked directly to item/accrual)
   -- we will execute this recursively to work down from second level (MISC/FREIGHT)
   -- to lower levels (TAX/DISCOUNT) and continue until no rows are updated
   --
   -- note this is called multiple times, so do not add savepoints directly to this
   -- but in the caller... the first poses no risks
   --
   --  the first  is for children whose parents are in the GT
   --     (this would pose no risk of a split parent, but could be mult-level)
   --
   --  the second is for children whose immediate parents are
   --    children to parents in the massadd interface
   --     (this would pose a risk of a split parent and could be mult-level)
   --
   --  the third  is for children whose immediate parents are
   --    children to parents in asset_invoices
   --     (this would pose a risk of a split parent and could be mult-level
   --      but we will not be doing add-to-assets)
   --
   -- thus the status will be used to later determine if the merge_parent
   -- should be the immediate parent line or the root parent or none in
   -- the add-to-asset case
   --
   --------------------------------------------------------------------------------

   FUNCTION Preprocess_GT_Records
               (p_book_type_code IN varchar2
               ,p_coa_id         IN number
               ,p_segment_num    IN number
               ,p_column_name    IN varchar2
               ,p_ledger_id      IN NUMBER
               ,p_def_dpis_dt    IN DATE
               ) RETURN BOOLEAN IS

      l_calling_fn                  varchar2(80) := 'FA_MASSADD_CREATE_PKG.Preprocess_GT_Records';
      l_count                       number;
      l_sql                         varchar(4000);
      error_found                   exception;


      l_rowid                       rowid_tbl_type;
      l_mass_addition_id_tbl        num_tbl_type;

      -- used for top level orphan children
      l_invoice_dist_id_tbl         num_tbl_type;
      l_mass_add_id_tbl             num_tbl_type;
      l_line_status_tbl             char_tbl_type;

      l_add_to_asset_id_tbl         num_tbl_type;
      l_asset_id_tbl                num_tbl_type;
      l_mad_count_tbl               num_tbl_type;
      l_posting_status_tbl          char_tbl_type;
      l_queue_name_tbl              char_tbl_type;
      l_asset_type_tbl              char_tbl_type;
      l_merged_code_tbl             char_tbl_type;

      l_temp_inv_dist_id1_tbl       num_tbl_type;

      l_child_inv_dist_id1_tbl      num_tbl_type;
      l_child_mass_add_id1_tbl      num_tbl_type;
      l_child_asset_id1_tbl         num_tbl_type;
      l_child_line_status1_tbl      char_tbl_type;
      l_child_posting_status1_tbl   char_tbl_type;
      l_child_queue_name1_tbl       char_tbl_type;
      l_child_asset_type1_tbl       char_tbl_type;
      l_child_merged_code1_tbl      char_tbl_type;

      l_child_inv_dist_id1A_tbl     num_tbl_type;
      l_child_asset_id1A_tbl        num_tbl_type;
      l_child_line_status1A_tbl     char_tbl_type;
      l_child_asset_type1A_tbl      char_tbl_type;

      -- used for splits
      l_child_inv_dist_id2_tbl      num_tbl_type;
      l_child_asset_type2_tbl       char_tbl_type;

      l_ai_count_tbl                num_tbl_type;
      l_ai_distinct_asset_count_tbl num_tbl_type;

      cursor c_rejected is
      select mad.invoice_distribution_id,
             nvl(mad.parent_mass_addition_id,mad.mass_addition_id)
        from fa_mass_additions mad
       where book_type_code = p_book_type_code
         and posting_status = 'DELETE'
         and not exists
            (select 1
               from fa_mass_additions mad2
              where mad2.book_type_code          = p_book_type_code
                and mad2.invoice_distribution_id = mad.invoice_distribution_id
                and mad2.posting_status     not in ('DELETE', 'SPLIT'));

      cursor c_item_accrual is
      select /*+ index(gt FA_MASS_ADDITIONS_GT_N2) */ rowid,
             fa_mass_additions_s.nextval
        from fa_mass_additions_gt gt
       where gt.line_type_lookup_code in ('ITEM', 'ACCRUAL')
         and gt.ledger_category_code = 'P'
         and gt.line_status = 'NEW'
         and gt.invoice_payment_id is null; -- exclude discounts
   --      and gt.parent_invoice_dist_id is null; -- exclude corrections

      cursor c_orphans is
      select mad.invoice_distribution_id,
             min(nvl(mad.parent_mass_addition_id,mad.mass_addition_id)),
             min(mad.add_to_asset_id),
             min(ad.asset_id),
             min(mad.posting_status),
             max(mad.asset_type),
             count(distinct mad.rowid)
        from fa_mass_additions_gt gt,
             fa_mass_additions    mad,
             fa_additions_b       ad
       where ad.asset_number(+)          = mad.asset_number
         and mad.book_type_code          = p_book_type_code
         and mad.invoice_distribution_id = gt.parent_invoice_dist_id
          -- BUG# 9162562 - see discussion for why we can only
          -- join by dist_id here...
          -- and mad.invoice_id          = gt.invoice_id
         and mad.posting_status          not in ('SPLIT', 'DELETE')
         and mad.invoice_payment_id      is null -- do not merge to discount
         and gt.ledger_category_code     = 'P'
         and gt.line_status              = 'NEW'
       group by mad.invoice_distribution_id;

      cursor c_ai_parents is
      select ai.invoice_distribution_id,
             min(ai.asset_id),
             max(ad.asset_type),
             count(distinct ai.rowid),
             count(distinct ai.asset_id)
        from fa_asset_invoices ai,
             fa_additions_b    ad,
             fa_mass_additions_gt gt
       where ai.invoice_distribution_id    = gt.parent_invoice_dist_id
         and ad.asset_id                   = ai.asset_id
         and gt.ledger_category_code       = 'P'
         and gt.line_status                = 'NEW'
       group by ai.invoice_distribution_id;

   begin

      -- populates the clearing gt used for ITEM/ACCRUAL category/book validation

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn
                         ,'Calling '
                         ,'Prepare_Clearing_GT '
                         ,p_log_level_rec => g_log_level_rec);
      end if;

      savepoint FAMADC_preprocess1;

      if not Prepare_Clearing_GT (p_ledger_id      => p_ledger_id
                                 ,p_book_type_code => p_book_type_code
                                 ,p_coa_id         => p_coa_id
                                 ,p_segment_num    => p_segment_num
                                 ) then
         raise error_found;
      end if;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn
                         ,'Updating children to rejected'
                         ,'due to parents in the delete queue'
                         ,p_log_level_rec => g_log_level_rec);
      end if;

      savepoint FAMADC_preprocess2;

      -- remove any child lines in NEW status whose only matching parents are in the delete queue
      -- per discussion with AP Dev/PM this is correct (just as if te parent was excluded in
      -- the post accounting setups)

      open c_rejected;

      loop
        fetch c_rejected bulk collect
         into l_invoice_dist_id_tbl, l_mass_add_id_tbl
        limit G_batch_size;

         if (l_invoice_dist_id_tbl.count = 0) then
            exit;
         end if;

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn
                            ,'No of rejected parents fetched'
                            ,l_invoice_dist_id_tbl.count
                            ,p_log_level_rec => g_log_level_rec);
            fa_debug_pkg.add(l_calling_fn
                            ,'calling'
                            ,'child line hook'
                            ,p_log_level_rec => g_log_level_rec);
         end if;

         -- update the child lines of these recursively

         if (l_invoice_dist_id_tbl.count > 0) then
            for i in 1..l_invoice_dist_id_tbl.count loop
                l_asset_id_tbl(i)       := null;
                l_posting_status_tbl(i) := 'NEW';
                l_queue_name_tbl(i)     := 'NEW';
                l_asset_type_tbl(i)     := 'CAPITALIZED';
                l_merged_code_tbl(i)    := null;
                l_line_status_tbl(i)    := 'REJECTED';
            end loop;

            savepoint FAMADC_preprocess3;

            if not Preprocess_Child_Lines
                      (p_book_type_code      => p_book_type_code
                      ,p_mode                => 'REJECT'
                      ,p_invoice_dist_id_tbl => l_invoice_dist_id_tbl
                      ,p_mass_add_id_tbl     => l_mass_add_id_tbl
                      ,p_asset_id_tbl        => l_asset_id_tbl
                      ,p_line_status_tbl     => l_line_status_tbl
                      ,p_posting_status_tbl  => l_posting_status_tbl
                      ,p_queue_name_tbl      => l_queue_name_tbl
                      ,p_asset_type_tbl      => l_asset_type_tbl
                      ,p_merged_code_tbl     => l_merged_code_tbl) then
               raise error_found;
            end if;
         end if;
      end loop;

      close c_rejected;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn
                         ,'processing'
                         ,'item and accrual lines'
                         ,p_log_level_rec => g_log_level_rec);
      end if;

      --  update the parents - this is the driving logic.  top level parents
      -- (in this case ITEM / ACCRUAL lines) will be based on clearing account
      -- validation

      -- rather than in-line update, splitting this into bulk fetch/bulk update
      -- in order to keep control of the array size of the bulk returned values

      savepoint FAMADC_preprocess4;

      open c_item_accrual;
      loop

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn
                            ,'fetching '
                            ,'item / accrual'
                            ,p_log_level_rec => g_log_level_rec);
         end if;

         --  update the parents - this is the driving logic.  top level
         fetch c_item_accrual bulk collect
          into l_rowid,
               l_mass_addition_id_tbl
         limit g_batch_size;

         if (l_rowid.count = 0) then
            exit;
         end if;

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn
                         ,'updating item / accrual, array count: '
                         ,l_rowid.count
                         ,p_log_level_rec => g_log_level_rec);
            fa_debug_pkg.add(l_calling_fn
                         ,'segment_num: '
                         ,p_segment_num
                         ,p_log_level_rec => g_log_level_rec);
         end if;

         l_sql := '
         update fa_mass_additions_gt gt
            set (asset_type, line_status, book_type_code, mass_addition_id) =
                (select /*+ index(fca FA_CATEGORY_ACCOUNTS_GT_N2 */
                        decode(gt.asset_type,
                               null, decode(glcc.account_type,
                                            ''E'', ''EXPENSED'',
                                            nvl(fca.asset_type, gt.asset_type)),
                               gt.asset_type),
                        decode(glcc.account_type,
                               ''E'', ''VALID'',
                               decode(gt.book_type_code,
                                      null, decode(fca.book_type_code,
                                                   :h_book_type_code, ''VALID'',
                                                   null,             ''REJECTED'',
                                                   ''OTHER BOOK''),
                                      decode(gt.book_type_code,
                                             :h_book_type_code, decode(fca.book_type_code,
                                                                       :h_book_type_code, ''VALID'',
                                                                       ''REJECTED''),
                                             ''OTHER BOOK''))),
                        decode(glcc.account_type,
                               ''E'', :h_book_type_code,
                               decode(gt.book_type_code,
                                      null, decode(fca.book_type_code,
                                                   :h_book_type_code, :h_book_type_code,
                                                   null),
                                      gt.book_type_code)),
                        :mass_add_id
                   from gl_code_combinations glcc,
                        fa_category_accounts_gt fca
                  where gt.payables_code_combination_id = glcc.code_combination_id
                    and fca.clearing_acct(+)           = '  ||
                         ' glcc.' || p_column_name || '
                )
          where rowid = :l_rowid
          returning invoice_distribution_id, mass_addition_id, line_status,
                    asset_type
               into :inv_tbl, :massadd_tbl, :line_status_tbl,
                    :asset_type_tbl';

         -- BMR: the above fails to set the line status on item/accruals
         -- which have no match clearing table....  (glcc.type = A)
         -- double check this - believe its fixed...

         FORALL i in 1..l_rowid.count
         EXECUTE IMMEDIATE l_sql
           USING p_book_type_code
                ,p_book_type_code
                ,p_book_type_code
                ,p_book_type_code
                ,p_book_type_code
                ,p_book_type_code
                ,l_mass_addition_id_tbl(i)
                ,l_rowid(i)
           RETURNING BULK COLLECT
                INTO l_invoice_dist_id_tbl, l_mass_add_id_tbl,
                     l_line_status_tbl, l_asset_type_tbl;

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn
                            ,'No of item/accrual lines Updated '
                            ,l_invoice_dist_id_tbl.count
                            ,p_log_level_rec => g_log_level_rec);
            fa_debug_pkg.add(l_calling_fn
                            ,'calling'
                            ,'child line hook'
                            ,p_log_level_rec => g_log_level_rec);
         end if;

         -- update the child lines which have their parent in the gt
         -- in new code (one itteration) this will be everything including some discounts

         if (l_invoice_dist_id_tbl.count > 0) then
            for i in 1..l_invoice_dist_id_tbl.count loop
                l_asset_id_tbl(i)       := null;
                l_posting_status_tbl(i) := 'MERGED';
                l_queue_name_tbl(i)     := 'NEW';
                l_merged_code_tbl(i)    := 'MC';
            end loop;

            if not Preprocess_Child_Lines
                      (p_book_type_code      => p_book_type_code
                      ,p_mode                => 'GT'
                      ,p_invoice_dist_id_tbl => l_invoice_dist_id_tbl
                      ,p_mass_add_id_tbl     => l_mass_add_id_tbl
                      ,p_asset_id_tbl        => l_asset_id_tbl
                      ,p_line_status_tbl     => l_line_status_tbl
                      ,p_posting_status_tbl  => l_posting_status_tbl
                      ,p_queue_name_tbl      => l_queue_name_tbl
                      ,p_asset_type_tbl      => l_asset_type_tbl
                      ,p_merged_code_tbl     => l_merged_code_tbl) then
               raise error_found;
            end if;
         end if;
      end loop;  -- bulk

      close c_item_accrual;

      -- flag the parent as MP
      forall i in 1..l_mass_add_id_tbl.count
       update fa_mass_additions_gt gt
          set split_merged_code = 'MP',
              merged_code       = 'MP'
        where mass_addition_id  = l_mass_add_id_tbl(i)
          and book_type_code    = p_book_type_code
          and invoice_payment_id is null
          and ledger_category_code = 'P'
          and exists
              (select 1
                 from fa_mass_additions_gt gt2
                where gt2.parent_invoice_dist_id = gt.invoice_distribution_id
                  and gt2.rowid <> gt.rowid);


      savepoint FAMADC_preprocess5;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn
                         ,'Processing'
                         ,'orphan child lines with parents in MAD'
                         ,p_log_level_rec => g_log_level_rec);
      end if;

      -- update child lines with parent info when match is found
      -- these are lines whose parents were brought over in
      -- previous runs.  Per new AP dependancy, the book is always
      -- populated on such lines ***

      -- in new code (one iteration) this would only include discounts processed
      -- after invoice was originally paid/accounted/transfered but due to datafixes
      -- its possible other lines could come in as well...  In either case, the root
      -- ITEM/ACCURAL line must have previously posted in the dfix case

      -- the code used counts to check if parent was split and if so
      -- we currently do not try to auto-split and follow...  the complexities
      -- and corner cases will/would make this complex.  (e.g. what if some
      -- parents posted and others had not - how do you do allocation of cost?)

      open c_orphans;

      loop

         fetch c_orphans bulk collect
          into l_invoice_dist_id_tbl
              ,l_mass_add_id_tbl
              ,l_add_to_asset_id_tbl
              ,l_asset_id_tbl
              ,l_posting_status_tbl
              ,l_asset_type_tbl
              ,l_mad_count_tbl
         limit g_batch_size;

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn
                            ,'No of MAD orphans fetched'
                            ,l_invoice_dist_id_tbl.count
                            ,p_log_level_rec => g_log_level_rec);
         end if;

         if (l_invoice_dist_id_tbl.count = 0) then
            exit;
         end if;

         l_child_inv_dist_id1_tbl.delete;
         l_child_mass_add_id1_tbl.delete;
         l_child_asset_id1_tbl.delete;
         l_child_line_status1_tbl.delete;
         l_child_posting_status1_tbl.delete;
         l_child_queue_name1_tbl.delete;
         l_child_asset_type1_tbl.delete;
         l_child_merged_code1_tbl.delete;

         l_child_inv_dist_id2_tbl.delete;
         l_child_asset_type2_tbl.delete;

         for i in 1..l_invoice_dist_id_tbl.count loop

            if (l_mad_count_tbl(i) = 1) then

               -- match found, now handle merge / add to asset
               if (l_posting_status_tbl(i) <> 'POSTED') then

                  -- NOTE: POSTED lines will fall into the AI handling later

                  l_child_inv_dist_id1_tbl(l_child_inv_dist_id1_tbl.count + 1)       := l_invoice_dist_id_tbl(i);
                  l_child_mass_add_id1_tbl(l_child_mass_add_id1_tbl.count + 1)       := l_mass_add_id_tbl(i);
                  l_child_asset_id1_tbl(l_child_asset_id1_tbl.count + 1)             := NULL;
                  l_child_line_status1_tbl(l_child_line_status1_tbl.count + 1)       := 'VALID';
                  l_child_posting_status1_tbl(l_child_posting_status1_tbl.count + 1) := 'MERGED';
                  l_child_queue_name1_tbl(l_child_queue_name1_tbl.count + 1)         := 'NEW';
                  l_child_asset_type1_tbl(l_child_asset_type1_tbl.count + 1)         := l_asset_type_tbl(i);
                  l_child_merged_code1_tbl(l_child_merged_code1_tbl.count + 1)       := 'MC';

               end if;

            else
               -- parent lines were split
               l_child_inv_dist_id2_tbl(l_child_inv_dist_id2_tbl.count + 1) := l_invoice_dist_id_tbl(i);
               l_child_asset_type2_tbl(l_child_asset_type2_tbl.count + 1) :=
l_asset_type_tbl(i);

            end if;

         end loop;

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn
                            ,'No of simple MAD orphans'
                            ,l_child_inv_dist_id1_tbl.count
                            ,p_log_level_rec => g_log_level_rec);
            fa_debug_pkg.add(l_calling_fn
                            ,'No of split MAD orphans'
                            ,l_child_inv_dist_id2_tbl.count
                            ,p_log_level_rec => g_log_level_rec);
         end if;

         if (l_child_mass_add_id1_tbl.count > 0) then

            -- flag the parent as MP
            -- no need for existance check as we're already driving by child
            forall i in 1..l_child_mass_add_id1_tbl.count
            update fa_mass_additions
               set split_merged_code = 'MP',
                   merged_code       = 'MP'
             where mass_addition_id  = l_child_mass_add_id1_tbl(i)
               and book_type_code    = p_book_type_code;

            -- process singles
            if not Preprocess_Child_Lines
                      (p_book_type_code      => p_book_type_code
                      ,p_mode                => 'MAD'
                      ,p_invoice_dist_id_tbl => l_child_inv_dist_id1_tbl
                      ,p_mass_add_id_tbl     => l_child_mass_add_id1_tbl
                      ,p_asset_id_tbl        => l_child_asset_id1_tbl
                      ,p_line_status_tbl     => l_child_line_status1_tbl
                      ,p_posting_status_tbl  => l_child_posting_status1_tbl
                      ,p_queue_name_tbl      => l_child_queue_name1_tbl
                      ,p_asset_type_tbl      => l_child_asset_type1_tbl
                      ,p_merged_code_tbl     => l_child_merged_code1_tbl) then
               raise error_found;
            end if;
         end if;

         -- process splits
         if (l_child_inv_dist_id2_tbl.count > 0) then
            if not Preprocess_Split_Lines
                      (p_book_type_code      => p_book_type_code
                      ,p_mode                => 'MAD'
                      ,p_invoice_dist_id_tbl => l_child_inv_dist_id2_tbl
                      ,p_asset_type_tbl      => l_child_asset_type2_tbl) then
               raise error_found;
            end if;
         end if;

      end loop; -- bulk

      close c_orphans;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn
                         ,'processing'
                         ,'asset invoices children'
                         ,p_log_level_rec => g_log_level_rec);
      end if;

      savepoint FAMADC_preprocess6;

      -- process children whose parents are now in asset invoices as valid
      -- but were purged from massadd interface

      open c_ai_parents;

      loop

         fetch c_ai_parents bulk collect
          into l_invoice_dist_id_tbl,
               l_asset_id_tbl,
               l_asset_type_tbl,
               l_ai_count_tbl,
               l_ai_distinct_asset_count_tbl
         limit g_batch_size;

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn
                            ,'No AI orphans fetched'
                            ,l_invoice_dist_id_tbl.count
                            ,p_log_level_rec => g_log_level_rec);
         end if;

         if (l_invoice_dist_id_tbl.count = 0) then
            exit;
         end if;

         l_child_inv_dist_id1_tbl.delete;
         l_child_mass_add_id1_tbl.delete;
         l_child_asset_id1_tbl.delete;
         l_child_line_status1_tbl.delete;
         l_child_posting_status1_tbl.delete;
         l_child_queue_name1_tbl.delete;
         l_child_asset_type1_tbl.delete;
         l_child_merged_code1_tbl.delete;

         l_child_inv_dist_id1A_tbl.delete;
         l_child_asset_id1A_tbl.delete;
         l_child_line_status1A_tbl.delete;
         l_child_asset_type1A_tbl.delete;

         l_child_inv_dist_id2_tbl.delete;
         l_child_asset_type2_tbl.delete;

         for i in 1..l_invoice_dist_id_tbl.count loop

            if (l_ai_count_tbl(i) = 1 or l_ai_distinct_asset_count_tbl(i) = 1) then

               -- single match found which is the simplest case proceed with add-to-asset
               -- except for inv/asset/mad arrays, the others are preset for
               -- subsequent recursive call rather then returning clause

               l_child_inv_dist_id1_tbl(l_child_inv_dist_id1_tbl.count + 1)       := l_invoice_dist_id_tbl(i);
               l_child_asset_id1_tbl(l_child_asset_id1_tbl.count + 1)             := l_asset_id_tbl(i);
               l_child_asset_type1_tbl(l_child_asset_type1_tbl.count + 1)         := l_asset_type_tbl(i);

            else
               -- more than one ai row...  we will bring these in but they must be handled by customer for now
               l_child_inv_dist_id2_tbl(l_child_inv_dist_id2_tbl.count + 1) := l_invoice_dist_id_tbl(i);
               l_child_asset_type2_tbl(l_child_asset_type2_tbl.count + 1)   := l_asset_type_tbl(i);


            end if;

         end loop;

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'No of simple AI orphans',l_child_inv_dist_id1_tbl.count
                            ,p_log_level_rec => g_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'No of split AI orphans', l_child_inv_dist_id2_tbl.count
                            ,p_log_level_rec => g_log_level_rec);
         end if;

         if (l_child_inv_dist_id1_tbl.count > 0) then

            -- in the AI case, the first level line is GT
            -- will not be a MC line (unlike MAD case) and thus
            -- we need to do one update outside the recursive routine here

            forall i in 1..l_child_inv_dist_id1_tbl.count
            update /*+ index(gt FA_MASS_ADDITIONS_GT_N4) */ fa_mass_additions_gt
               set mass_addition_id               = fa_mass_additions_s.nextval,
                   book_type_code                 = p_book_type_code,
                   line_status                    = 'VALID',
                   posting_status                 = 'NEW',
                   queue_name                     = 'ADD TO ASSET',
                   asset_type                     = l_child_asset_type1_tbl(i),
                   split_merged_code              = NULL,
                   merged_code                    = NULL,
                   parent_mass_addition_id        = NULL,
                   merge_parent_mass_additions_id = NULL,
                   add_to_asset_id                = l_child_asset_id1_tbl(i)
             where parent_invoice_dist_id         = l_child_inv_dist_id1_tbl(i)
               and line_status                    = 'NEW'
               and ledger_category_code           = 'P'
                   returning mass_addition_id
                           , invoice_distribution_id
                           , add_to_asset_id
                           , line_status
                           , asset_type bulk collect
                        into l_child_mass_add_id1_tbl
                           , l_child_inv_dist_id1A_tbl
                           , l_child_asset_id1A_tbl
                           , l_child_line_status1A_tbl
                           , l_child_asset_type1A_tbl;

            for i in 1..l_child_mass_add_id1_tbl.count loop
               l_child_line_status1_tbl(l_child_line_status1_tbl.count + 1) := 'VALID';
               l_child_posting_status1_tbl(l_child_posting_status1_tbl.count + 1) := 'MERGED';
               l_child_queue_name1_tbl(l_child_queue_name1_tbl.count + 1) := 'NEW';
               l_child_merged_code1_tbl(l_child_merged_code1_tbl.count + 1) := 'MC';
            end loop;

            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn
                               ,'l_child_inv_dist_id1A_tbl.count'
                               ,l_child_inv_dist_id1A_tbl.count
                               ,p_log_level_rec => g_log_level_rec);
               fa_debug_pkg.add(l_calling_fn
                               ,'l_child_mass_add_id1_tbl.count'
                               ,l_child_mass_add_id1_tbl.count
                               ,p_log_level_rec => g_log_level_rec);
               fa_debug_pkg.add(l_calling_fn
                               ,'l_child_asset_id1A_tbl.count'
                               ,l_child_asset_id1A_tbl.count
                               ,p_log_level_rec => g_log_level_rec);
               fa_debug_pkg.add(l_calling_fn
                               ,'l_child_line_status1A_tbl.count'
                               ,l_child_line_status1A_tbl.count
                               ,p_log_level_rec => g_log_level_rec);
               fa_debug_pkg.add(l_calling_fn
                               ,'l_child_asset_type1A_tbl.count'
                               ,l_child_asset_type1A_tbl.count
                               ,p_log_level_rec => g_log_level_rec);
               fa_debug_pkg.add(l_calling_fn
                               ,'l_child_posting_status1_tbl.count'
                               ,l_child_posting_status1_tbl.count
                               ,p_log_level_rec => g_log_level_rec);
               fa_debug_pkg.add(l_calling_fn
                               ,'l_child_queue_name1_tbl.count'
                               ,l_child_queue_name1_tbl.count
                               ,p_log_level_rec => g_log_level_rec);
               fa_debug_pkg.add(l_calling_fn
                               ,'l_child_merged_code1_tbl.count'
                               ,l_child_merged_code1_tbl.count
                               ,p_log_level_rec => g_log_level_rec);
            end if;

            -- flag these updated lines as parent MP where applicable
            forall i in 1..l_child_mass_add_id1_tbl.count
            update /*+ index(gt FA_MASS_ADDITIONS_GT_N3) */ fa_mass_additions_gt gt
               set split_merged_code = 'MP',
                   merged_code       = 'MP'
             where invoice_distribution_id = l_child_inv_dist_id1A_tbl(i)
               and invoice_payment_id     is null  -- exclude discounts
               and book_type_code          = p_book_type_code
               and ledger_category_code    = 'P'
               and exists
                   (select 1
                      from fa_mass_additions_gt gt2
                     where gt2.parent_invoice_dist_id = gt.invoice_distribution_id
                       and gt2.rowid <> gt.rowid);

            -- process singles
            if not Preprocess_Child_Lines
                      (p_book_type_code      => p_book_type_code
                      ,p_mode                => 'AI'
                      ,p_invoice_dist_id_tbl => l_child_inv_dist_id1A_tbl
                      ,p_mass_add_id_tbl     => l_child_mass_add_id1_tbl
                      ,p_asset_id_tbl        => l_child_asset_id1A_tbl
                      ,p_line_status_tbl     => l_child_line_status1A_tbl
                      ,p_posting_status_tbl  => l_child_posting_status1_tbl
                      ,p_queue_name_tbl      => l_child_queue_name1_tbl
                      ,p_asset_type_tbl      => l_child_asset_type1A_tbl
                      ,p_merged_code_tbl     => l_child_merged_code1_tbl) then
               raise error_found;
            end if;
         end if;

         -- process splits
         if (l_child_inv_dist_id2_tbl.count > 0) then
            if not Preprocess_Split_Lines
                      (p_book_type_code      => p_book_type_code
                      ,p_mode                => 'AI'
                      ,p_invoice_dist_id_tbl => l_child_inv_dist_id2_tbl
                      ,p_asset_type_tbl      => l_child_asset_type2_tbl) then
               raise error_found;
            end if;
         end if;

      end loop; -- bulk

      close c_ai_parents;

      savepoint FAMADC_preprocess7;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn
                         ,'Updating depreciate_flag in'
                         ,'fa_mass_additions_gt'
                         ,p_log_level_rec => g_log_level_rec);
      end if;

      -- update the depreciate_flag and inventorial on valid lines
      update /*+ index(gt FA_MASS_ADDITIONS_GT_N1) */ fa_mass_additions_gt gt
         set depreciate_flag =
               (select decode(gt.asset_type
                             ,'EXPENSED','NO'
                             ,nvl(CBD.depreciate_flag, 'YES'))
                  from fa_category_book_defaults CBD
                 where CBD.book_type_code(+) = p_book_type_code
                   and CBD.category_id(+)= gt.asset_category_id
                   and p_def_dpis_dt between CBD.start_DPIS(+)
                   and nvl(CBD.end_DPIS(+),p_def_dpis_dt)),
             inventorial =
               (select nvl(inventorial, 'YES')
                  from fa_categories_b c
                 where c.category_id(+) = gt.asset_category_id)
       where gt.book_type_code = p_book_type_code
         and gt.line_status = 'VALID'
         and gt.ledger_category_code = 'P'
         and gt.asset_category_id is not null
         and gt.add_to_asset_id is null;

      l_count := SQL%ROWCOUNT;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn
                          ,'No of Records Updated'
                          ,to_char(l_count)
                          ,p_log_level_rec => g_log_level_rec);
      end if;

      RETURN TRUE;

   EXCEPTION
      WHEN ERROR_FOUND then
           RETURN FALSE;

      WHEN OTHERS THEN
           fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
                                    ,p_log_level_rec => g_log_level_rec);

           RETURN FALSE;

   end Preprocess_GT_Records;

   --------------------------------------------------------------------------------

   PROCEDURE create_lines
                (p_book_type_code    IN             VARCHAR2
                ,p_api_version       IN             NUMBER
                ,p_init_msg_list     IN             VARCHAR2 := FND_API.G_FALSE
                ,p_commit            IN             VARCHAR2 := FND_API.G_FALSE
                ,p_validation_level  IN             NUMBER   := FND_API.G_VALID_LEVEL_FULL
                ,p_calling_fn        IN             VARCHAR2
                ,x_return_status        OUT NOCOPY  VARCHAR2
                ,x_msg_count            OUT NOCOPY  NUMBER
                ,x_msg_data             OUT NOCOPY  VARCHAR2
                ) IS


      l_calling_fn        varchar2(40) := 'FA_MASS_ADDITIONS_PKG.create_lines';

      l_count             INTEGER;

      l_date_ineffective  FA_BOOK_CONTROLS.DATE_INEFFECTIVE%TYPE;
      l_book_class        FA_BOOK_CONTROLS.BOOK_CLASS%TYPE;
      l_sob_id            FA_BOOK_CONTROLS.SET_OF_BOOKS_ID%TYPE;
      l_coa_id            FA_BOOK_CONTROLS.ACCOUNTING_FLEX_STRUCTURE%TYPE;
      l_segment_num       NUMBER;
      l_app_column_name   VARCHAR2(100);
      l_def_dpis_option   VARCHAR2(1);
      l_def_dpis_enabled  INTEGER;
      l_def_dpis_dt       DATE;
      l_ledger_id         NUMBER;
      l_period_close_date DATE;
      l_calendar_period_close_date DATE;
      l_request_id        NUMBER;
      l_login_id          NUMBER;
      l_user_id           NUMBER;
      l_result            BOOLEAN;

      fa_ineffective_book EXCEPTION;
      fa_not_corp_book    EXCEPTION;
      create_err          EXCEPTION;

   BEGIN

      savepoint FAMADC_create1;

      if (not g_log_level_rec.initialized) then
         if (NOT fa_util_pub.get_log_level_rec (
                  x_log_level_rec =>  g_log_level_rec
            )) then
            raise create_err;
         end if;
      end if;

      l_request_id := FND_GLOBAL.conc_request_id;
      l_user_id    := FND_GLOBAL.user_id;
      l_login_id   := FND_GLOBAL.login_id;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Stamp FA_SYSTEM_CONTROLS WITH ', l_request_id
                          ,p_log_level_rec => g_log_level_rec);
      end if;

      update fa_system_controls
         set last_mass_additions = l_request_id;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn
                         , 'Validating book '
                         , p_book_type_code
                         ,p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add(l_calling_fn
                         ,'calling'
                         ,'fa_cache_pkg.fazcbc'
                         ,p_log_level_rec => g_log_level_rec);
      end if;

      if NOT fa_cache_pkg.fazcbc(X_book => p_book_type_code,
                                 p_log_level_rec => g_log_level_rec) then
         raise create_err;
      end if;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn
                         ,'calling'
                         ,'fa_cache_pkg.fazcdp'
                         ,p_log_level_rec => g_log_level_rec);
      end if;

      if not fa_cache_pkg.fazcdp (x_book_type_code => p_book_type_code ) THEN
         raise create_err;
      end if;

      l_ledger_id        := fa_cache_pkg.fazcbc_record.set_of_books_id;
      l_date_ineffective := fa_cache_pkg.fazcbc_record.date_ineffective;
      l_book_class       := fa_cache_pkg.fazcbc_record.book_class;
      l_coa_id           := fa_cache_pkg.fazcbc_record.accounting_flex_structure;

      l_calendar_period_close_date :=
          fa_cache_pkg.fazcdp_record.calendar_period_close_date ;

      IF l_date_ineffective IS NOT NULL THEN
          if (g_log_level_rec.statement_level) then
             fa_debug_pkg.add(l_calling_fn
                             ,'Ineffective book '
                             ,p_book_type_code
                             ,p_log_level_rec => g_log_level_rec);
          end if;
          raise fa_ineffective_book;
      END IF;

      IF l_book_class <> 'CORPORATE' THEN
          if (g_log_level_rec.statement_level) then
             fa_debug_pkg.add(l_calling_fn
                             ,'Incorrect Book class '
                             ,p_book_type_code
                             ,p_log_level_rec => g_log_level_rec);
          end if;
          raise fa_not_corp_book;
      END IF;

      -- Get Qualifier segment number
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn
                         ,'Get Qualifier Segment for Chart of Accounts ID '
                         ,l_coa_id
                         ,p_log_level_rec => g_log_level_rec);
      end if;

      if NOT (FND_FLEX_APIS.Get_Qualifier_segnum(101
                                                ,'GL#'
                                                ,l_coa_id
                                                ,'GL_ACCOUNT'
                                                ,l_segment_num)) then
          raise create_err;
      end if;

      select application_column_name
        into l_app_column_name
        from fnd_id_flex_segments
       where application_id = 101
         and id_flex_code   = 'GL#'
         and id_flex_num    = l_coa_id
         and segment_num    = l_segment_num;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn
                         ,'segment num '
                         ,l_segment_num
                         ,p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add(l_calling_fn
                         ,'application column name '
                         ,l_app_column_name
                         ,p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add(l_calling_fn
                         ,'Checking Profile '
                         ,'FA_DEFAULT_DPIS_TO_INV_DATE'
                         ,p_log_level_rec => g_log_level_rec);
      end if;

      l_def_dpis_option := fnd_profile.value('FA_DEFAULT_DPIS_TO_INV_DATE');

      IF (l_def_dpis_option = 'Y')    THEN
         l_def_dpis_enabled := 1;
      ELSE
         l_def_dpis_enabled := 0;
      END IF;

      IF (l_def_dpis_enabled = 0)  THEN /* For Future Dated Txns */
         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn
                            ,'Get Default DPIS for '
                            ,p_book_type_code
                            ,p_log_level_rec => g_log_level_rec);
         end if;

         l_def_dpis_dt :=
            greatest(nvl(fa_cache_pkg.fazcdp_record.calendar_period_open_date,
                         sysdate),
                     least(sysdate,
                            nvl(fa_cache_pkg.fazcdp_record.calendar_period_close_date, sysdate)));

      END IF;


      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'PreProcess Records in GT','that have book type code NULL'
                          ,p_log_level_rec => g_log_level_rec);
      end if;

      IF NOT Preprocess_GT_Records
                (p_book_type_code => p_book_type_code
                ,p_coa_id         => l_coa_id
                ,p_segment_num    => l_segment_num
                ,p_column_name    => l_app_column_name
                ,p_ledger_id      => l_ledger_id
                ,p_def_dpis_dt    => l_def_dpis_dt) THEN
         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'Error during PreProcessing in FA API ',p_book_type_code
                          ,p_log_level_rec => g_log_level_rec);
         end if;
         raise create_err;
      END IF;


      -- Call the cache pkg to fetch the calendar_period_close_date
      if not fa_cache_pkg.fazcdp (x_book_type_code => p_book_type_code ) THEN
         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn
                            ,'Unable to find valid depreciation information '
                            ,p_book_type_code
                            ,p_log_level_rec => g_log_level_rec);
         end if;
         raise fa_ineffective_book;
      end if;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn
                         ,'Insert FA_MASS_ADDITIONS lines for primary ledger '
                         ,p_book_type_code
                         ,p_log_level_rec => g_log_level_rec);
      end if;

      savepoint FAMADC_create2;

      insert into fa_mass_additions(
           mass_addition_id                            ,
           asset_number                                ,
           tag_number                                  ,
           description                                 ,
           asset_category_id                           ,
           manufacturer_name                           ,
           serial_number                               ,
           model_number                                ,
           book_type_code                              ,
           date_placed_in_service                      ,
           fixed_assets_cost                           ,
           payables_units                              ,
           fixed_assets_units                          ,
           payables_code_combination_id                ,
           expense_code_combination_id                 ,
           location_id                                 ,
           assigned_to                                 ,
           feeder_system_name                          ,
           create_batch_date                           ,
           create_batch_id                             ,
           last_update_date                            ,
           last_updated_by                             ,
           reviewer_comments                           ,
           invoice_number                              ,
           vendor_number                               ,
           po_vendor_id                                ,
           po_number                                   ,
           posting_status                              ,
           queue_name                                  ,
           invoice_date                                ,
           invoice_created_by                          ,
           invoice_updated_by                          ,
           payables_cost                               ,
           invoice_id                                  ,
           payables_batch_name                         ,
           depreciate_flag                             ,
           parent_mass_addition_id                     ,
           parent_asset_id                             ,
           split_merged_code                           ,
           ap_distribution_line_number                 ,
           post_batch_id                               ,
           add_to_asset_id                             ,
           amortize_flag                               ,
           new_master_flag                             ,
           asset_key_ccid                              ,
           asset_type                                  ,
           deprn_reserve                               ,
           ytd_deprn                                   ,
           beginning_nbv                               ,
           created_by                                  ,
           creation_date                               ,
           last_update_login                           ,
           salvage_value                               ,
           accounting_date                             ,
           attribute_category_code                     ,
           fully_rsvd_revals_counter                   ,
           merge_invoice_number                        ,
           merge_vendor_number                         ,
           production_capacity                         ,
           reval_amortization_basis                    ,
           reval_reserve                               ,
           unit_of_measure                             ,
           unrevalued_cost                             ,
           ytd_reval_deprn_expense                     ,
           merged_code                                 ,
           split_code                                  ,
           merge_parent_mass_additions_id              ,
           split_parent_mass_additions_id              ,
           project_asset_line_id                       ,
           project_id                                  ,
           task_id                                     ,
           sum_units                                   ,
           dist_name                                   ,
           context                                     ,
           inventorial                                 ,
           short_fiscal_year_flag                      ,
           conversion_date                             ,
           original_deprn_start_date                   ,
           group_asset_id                              ,
           cua_parent_hierarchy_id                     ,
           units_to_adjust                             ,
           bonus_ytd_deprn                             ,
           bonus_deprn_reserve                         ,
           amortize_nbv_flag                           ,
           amortization_start_date                     ,
           transaction_type_code                       ,
           transaction_date                            ,
           warranty_id                                 ,
           lease_id                                    ,
           lessor_id                                   ,
           property_type_code                          ,
           property_1245_1250_code                     ,
           in_use_flag                                 ,
           owned_leased                                ,
           new_used                                    ,
           asset_id                                    ,
           material_indicator_flag                     ,
           invoice_distribution_id                     ,
           invoice_line_number                         ,
           invoice_payment_id                          ,
           warranty_number)
       select /*+ index(gt FA_MASS_ADDITIONS_GT_N1) */
           gt.mass_addition_id                         , --fa_mass_additions_s.nextval,
           gt.asset_number                             ,
           gt.tag_number                               ,
           gt.description                              ,
           gt.asset_category_id                        ,
           gt.manufacturer_name                        ,
           gt.serial_number                            ,
           gt.model_number                             ,
           p_book_type_code                           ,
           decode(l_def_dpis_enabled, 1, gt.invoice_date, l_def_dpis_dt ) ,
           gt.fixed_assets_cost                        ,
           gt.payables_units                           ,
           gt.fixed_assets_units                       ,
           gt.payables_code_combination_id             ,
           gt.expense_code_combination_id              ,
           gt.location_id                              ,
           gt.assigned_to                              ,
           gt.feeder_system_name                       ,
           gt.create_batch_date                        ,
           gt.create_batch_id                          ,
           gt.last_update_date                         ,
           gt.last_updated_by                          ,
           gt.reviewer_comments                        ,
           gt.invoice_number                           ,
           gt.vendor_number                            ,
           gt.po_vendor_id                             ,
           gt.po_number                                ,
           gt.posting_status                           ,
           gt.queue_name                               ,
           gt.invoice_date                             ,
           gt.invoice_created_by                       ,
           gt.invoice_updated_by                       ,
           gt.payables_cost                            ,
           gt.invoice_id                               ,
           gt.payables_batch_name                      ,
           gt.depreciate_flag                          ,
           gt.parent_mass_addition_id                  ,
           gt.parent_asset_id                          ,
           gt.split_merged_code                        ,
           gt.ap_distribution_line_number              ,
           gt.post_batch_id                            ,
           gt.add_to_asset_id                          ,
           gt.amortize_flag                            ,
           gt.new_master_flag                          ,
           gt.asset_key_ccid                           ,
           gt.asset_type                               ,  -- reinstated
           gt.deprn_reserve                            ,
           gt.ytd_deprn                                ,
           gt.beginning_nbv                            ,
           gt.created_by                               ,
           gt.creation_date                            ,
           gt.last_update_login                        ,
           gt.salvage_value                            ,
           gt.accounting_date                          ,
           gt.attribute_category_code                  ,
           gt.fully_rsvd_revals_counter                ,
           gt.merge_invoice_number                     ,
           gt.merge_vendor_number                      ,
           gt.production_capacity                      ,
           gt.reval_amortization_basis                 ,
           gt.reval_reserve                            ,
           gt.unit_of_measure                          ,
           gt.unrevalued_cost                          ,
           gt.ytd_reval_deprn_expense                  ,
           gt.merged_code                              ,
           gt.split_code                               ,
           gt.merge_parent_mass_additions_id           ,
           gt.split_parent_mass_additions_id           ,
           gt.project_asset_line_id                    ,
           gt.project_id                               ,
           gt.task_id                                  ,
           /* gt.sum_units */
           null,
           gt.dist_name                                ,
           gt.context                                  ,
           gt.inventorial                              ,
           gt.short_fiscal_year_flag                   ,
           gt.conversion_date                          ,
           gt.original_deprn_start_date                ,
           gt.group_asset_id                           ,
           gt.cua_parent_hierarchy_id                  ,
           gt.units_to_adjust                          ,
           gt.bonus_ytd_deprn                          ,
           gt.bonus_deprn_reserve                      ,
           gt.amortize_nbv_flag                        ,
           gt.amortization_start_date                  ,
           /* transaction_type_code  - only future add in future period */
           decode(sign(decode(l_def_dpis_enabled, 1, gt.invoice_date, l_def_dpis_dt)
                       - l_calendar_period_close_date), 1, 'FUTURE ADD', NULL ),
           /* transaction date */
           decode(sign(decode(l_def_dpis_enabled, 1, gt.invoice_date, l_def_dpis_dt)
                       - l_calendar_period_close_date), 1, decode(l_def_dpis_enabled,
                         1, invoice_date, l_def_dpis_dt), null ),
           gt.warranty_id                              ,
           gt.lease_id                                 ,
           gt.lessor_id                                ,
           gt.property_type_code                       ,
           gt.property_1245_1250_code                  ,
           gt.in_use_flag                              ,
           gt.owned_leased                             ,
           gt.new_used                                 ,
           gt.asset_id                                 ,
           gt.material_indicator_flag                  ,
           gt.invoice_distribution_id                  ,
           gt.invoice_line_number                      ,
           gt.invoice_payment_id                       ,
           gt.warranty_number
      from fa_mass_additions_gt gt
     where gt.book_type_code = p_book_type_code
       and gt.ledger_category_code = 'P'
       and gt.line_status = 'VALID';

      l_count := SQL%ROWCOUNT;
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn
                         ,'No of Records Inserted '
                         ,to_char(l_count)
                         ,p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add(l_calling_fn
                         ,'Inserting into FA_MC_MASS_RATES for reporting ledger(s) '
                         ,p_book_type_code
                         ,p_log_level_rec => g_log_level_rec);
      end if;

      -- insert into mc_rates

      savepoint FAMADC_create6;

      Insert into fa_mc_mass_rates
                ( set_of_books_id,
                  mass_addition_id,
                  fixed_assets_cost,
                  exchange_rate)
         select /*+ leading(gt)  */
                 gt.ledger_id,
                 mad.mass_addition_id,
                 gt.fixed_assets_cost,
                 0
           from fa_mass_additions    mad,
                fa_mass_additions_gt gt
          where mad.book_type_code               = p_book_type_code
            and mad.invoice_distribution_id      = gt.invoice_distribution_id
            and nvl(mad.invoice_payment_id, -99) = nvl(gt.invoice_payment_id, -99)
            and gt.ledger_category_code          = 'ALC';

      l_count := SQL%ROWCOUNT;
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn
                         ,'No of Records Inserted '
                         ,to_char(l_count)
                         ,p_log_level_rec => g_log_level_rec);
      end if;

      -- update for rejected is already handled in the preprocessing logic

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn
                         ,'Updating successful/processed rows in '
                         ,'fa_mass_additions_gt'
                         ,p_log_level_rec => g_log_level_rec);
      end if;

      savepoint FAMADC_create7;

      update /*+ index(gt FA_MASS_ADDITIONS_GT_N1) */ fa_mass_additions_gt gt
         set gt.line_status       = 'PROCESSED'
       where book_type_code       = p_book_type_code
         and line_status          = 'VALID'
         and ledger_category_code = 'P'
         and exists
                 ( select 1
                     from fa_mass_additions mad
                    where mad.mass_addition_id = gt.mass_addition_id);


      l_count := SQL%ROWCOUNT;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn
                         ,'No of Records Processed'
                         ,to_char(l_count)
                         ,p_log_level_rec => g_log_level_rec);
      end if;

      savepoint FAMADC_create8;

      x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   EXCEPTION

      when create_err then
           fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                  ,p_log_level_rec => g_log_level_rec);
           x_return_status :=  FND_API.G_RET_STS_ERROR;

      when fa_ineffective_book then
           if (g_log_level_rec.statement_level) then
              fa_debug_pkg.add(l_calling_fn
                              ,'This book does not exist or has a date ineffective on or before today'
                              ,p_book_type_code
                              ,p_log_level_rec => g_log_level_rec);
           end if;
           x_return_status :=  FND_API.G_RET_STS_ERROR;

      when fa_not_corp_book then
           if (g_log_level_rec.statement_level) then
              fa_debug_pkg.add(l_calling_fn
                              ,'Mass Additions Create cannot be run for non-corporate book'
                              ,p_book_type_code
                              ,p_log_level_rec => g_log_level_rec);
           end if;
           x_return_status :=  FND_API.G_RET_STS_ERROR;

      when others then
           -- BMR: do not rollback entire processing set here
           -- when debugging
           rollback;

           fa_srvr_msg.add_sql_error(
                 calling_fn => l_calling_fn
                 ,p_log_level_rec => g_log_level_rec);

           x_return_status :=  FND_API.G_RET_STS_ERROR;
   END;


END FA_MASSADD_CREATE_PKG;

/
