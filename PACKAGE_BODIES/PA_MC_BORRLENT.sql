--------------------------------------------------------
--  DDL for Package Body PA_MC_BORRLENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_MC_BORRLENT" AS
/* $Header: PAMRCBLB.pls 120.2 2005/10/18 01:27:11 avajain noship $ */

------------------------------------------------------------
--       PRIVATE PACKAGE SPECIFICATIONS
------------------------------------------------------------

PROCEDURE set_curr_function(p_function IN VARCHAR2);
PROCEDURE reset_curr_function;

PROCEDURE get_mrc_values (
             p_primary_sob_id        IN gl_Sets_of_books.set_of_books_id%TYPE
            ,p_prvdr_org_id          IN PA_PLSQL_DATATYPES.IDTabTyp
            ,p_rsob_id               IN PA_PLSQL_DATATYPES.IDTabTyp
            ,p_rcurrency_code        IN PA_PLSQL_DATATYPES.Char15TabTyp
            ,p_cc_dist_line_id       IN PA_PLSQL_DATATYPES.IDTabTyp
            ,p_upd_type              IN PA_PLSQL_DATATYPES.Char1TabTyp
                               DEFAULT PA_PLSQL_DATATYPES.EmptyChar1Tab
            ,p_dist_line_id_reversed IN PA_PLSQL_DATATYPES.IDTabTyp
                               DEFAULT PA_PLSQL_DATATYPES.EmptyIDTab
            ,p_expenditure_item_id   IN PA_PLSQL_DATATYPES.IDTabTyp
                               DEFAULT PA_PLSQL_DATATYPES.EmptyIDTab
            ,p_line_num              IN PA_PLSQL_DATATYPES.IDTabTyp
                               DEFAULT PA_PLSQL_DATATYPES.EmptyIDTab
            ,p_line_type             IN PA_PLSQL_DATATYPES.Char2TabTyp
                               DEFAULT PA_PLSQL_DATATYPES.EmptyChar2Tab
            ,p_denom_currency_code   IN PA_PLSQL_DATATYPES.Char15TabTyp
            ,p_acct_tp_rate_type     IN PA_PLSQL_DATATYPES.Char30TabTyp
            ,p_expenditure_item_date IN PA_PLSQL_DATATYPES.DateTabTyp
            ,p_acct_tp_exchange_rate IN PA_PLSQL_DATATYPES.NumTabTyp
            ,p_denom_amount          IN PA_PLSQL_DATATYPES.NumTabTyp
            ,p_cdl_line_num          IN PA_PLSQL_DATATYPES.NumTabTyp
                               DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab
            ,p_prvdr_cost_reclass_code IN  PA_PLSQL_DATATYPES.Char240TabTyp
                               DEFAULT PA_PLSQL_DATATYPES.EmptyChar240Tab
            ,x_sob_id                OUT NOCOPY PA_PLSQL_DATATYPES.IDTabTyp
            ,x_cc_dist_line_id       OUT NOCOPY PA_PLSQL_DATATYPES.IDTabTyp
            ,x_expenditure_item_id   OUT NOCOPY PA_PLSQL_DATATYPES.IDTabTyp
            ,x_line_num              OUT NOCOPY PA_PLSQL_DATATYPES.IDTabTyp
            ,x_line_type             OUT NOCOPY PA_PLSQL_DATATYPES.Char2TabTyp
            ,x_exchange_rate         OUT NOCOPY PA_PLSQL_DATATYPES.NumTabTyp
            ,x_rate_type             OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp
            ,x_rate_date             OUT NOCOPY PA_PLSQL_DATATYPES.DateTabTyp
            ,x_currency_code         OUT NOCOPY PA_PLSQL_DATATYPES.Char15TabTyp
            ,x_amount                OUT NOCOPY PA_PLSQL_DATATYPES.NumTabTyp
            );

PROCEDURE log_message(p_message IN VARCHAR2);

------------------------------------------------------------
--           PROCEDURE DEFINTIONS
------------------------------------------------------------

-------------------------------------------------------------------------------
--              Procedure bl_mc_delete
-------------------------------------------------------------------------------

PROCEDURE bl_mc_delete
        (
         p_cc_dist_line_id              IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_debug_mode                   IN  boolean
        ) IS

BEGIN

/**set_curr_function('bl_mc_delete');
log_message('50: Entered bl_mc_delete');

-- Deleting records for each line id (irrespective of the set of
-- books)

FORALL j IN p_cc_dist_line_id.First..p_cc_dist_line_id.Last

  DELETE
    FROM PA_MC_CC_DIST_LINES_ALL
   WHERE cc_dist_line_id = p_cc_dist_line_id(j);

 log_message('100: -- Records deleted : ' || sql%rowcount);

log_message('150: Leaving bl_mc_delete');

reset_curr_function;

EXCEPTION
 WHEN OTHERS
  THEN
   log_message('200: ERROR in bl_mc_delete');
   raise;
**/
null;
END bl_mc_delete;


-------------------------------------------------------------------------------
--              bl_mc_update
-------------------------------------------------------------------------------

PROCEDURE bl_mc_update
       (
         p_primary_sob_id               IN  gl_sets_of_books.set_of_books_id%TYPE
        ,p_prvdr_org_id                 IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_rsob_id                      IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_rcurrency_code               IN  PA_PLSQL_DATATYPES.Char15TabTyp
        ,p_cc_dist_line_id              IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_line_type                    IN  PA_PLSQL_DATATYPES.Char2TabTyp
        ,p_upd_type                     IN  PA_PLSQL_DATATYPES.Char1TabTyp
        ,p_expenditure_item_date        IN  PA_PLSQL_DATATYPES.DateTabTyp
        ,p_expenditure_item_id          IN  PA_PLSQL_DATATYPES.IDTabTyp
                               DEFAULT PA_PLSQL_DATATYPES.EmptyIDTab
        ,p_denom_currency_code          IN  PA_PLSQL_DATATYPES.Char15TabTyp
        ,p_acct_tp_rate_type            IN  PA_PLSQL_DATATYPES.Char30TabTyp
        ,p_acct_tp_exchange_rate        IN  PA_PLSQL_DATATYPES.NumTabTyp
        ,p_denom_transfer_price         IN  PA_PLSQL_DATATYPES.NumTabTyp
        ,p_cdl_line_num                 IN  PA_PLSQL_DATATYPES.NumTabTyp
                               DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab
        ,p_prvdr_cost_reclass_code      IN  PA_PLSQL_DATATYPES.Char240TabTyp
                               DEFAULT PA_PLSQL_DATATYPES.EmptyChar240Tab
        ,p_login_id                     IN  NUMBER
        ,p_program_id                   IN  NUMBER
        ,p_program_application_id       IN  NUMBER
        ,p_request_id                   IN  NUMBER
        ,p_debug_mode                   IN  boolean
        ) IS


x_sob_id                PA_PLSQL_DATATYPES.IDTabTyp;
x_cc_dist_line_id       PA_PLSQL_DATATYPES.IDTabTyp;
x_expenditure_item_id   PA_PLSQL_DATATYPES.IDTabTyp;
x_line_num              PA_PLSQL_DATATYPES.IDTabTyp;
x_line_type             PA_PLSQL_DATATYPES.Char2TabTyp;
x_exchange_rate         PA_PLSQL_DATATYPES.NumTabTyp;
x_rate_type             PA_PLSQL_DATATYPES.Char30TabTyp;
x_rate_date             PA_PLSQL_DATATYPES.DateTabTyp;
x_currency_code         PA_PLSQL_DATATYPES.Char15TabTyp;
x_amount                PA_PLSQL_DATATYPES.NumTabTyp;

i                      PLS_INTEGER:= 0;

BEGIN

/**
set_curr_function('bl_mc_update');

log_message('250: Entered bl_mc_update');

-- Obtain the converted values for each combination of set of books
-- and line id attributes

get_mrc_values(
               p_primary_sob_id           => p_primary_sob_id
              ,p_prvdr_org_id             => p_prvdr_org_id
              ,p_rsob_id                  => p_rsob_id
              ,p_rcurrency_code           => p_rcurrency_code
              ,p_cc_dist_line_id          => p_cc_dist_line_id
              ,p_upd_type                 => p_upd_type
              ,p_denom_currency_code      => p_denom_currency_code
              ,p_acct_tp_rate_type        => p_acct_tp_rate_type
              ,p_expenditure_item_date    => p_expenditure_item_date
              ,p_acct_tp_exchange_rate    => p_acct_tp_exchange_rate
              ,p_denom_amount             => p_denom_transfer_price
              ,p_line_type                => p_line_type
              ,p_cdl_line_num             => p_cdl_line_num
              ,p_prvdr_cost_reclass_code  => p_prvdr_cost_reclass_code
              ,x_sob_id                   => x_sob_id
              ,x_cc_dist_line_id          => x_cc_dist_line_id
              ,x_expenditure_item_id      => x_expenditure_item_id
              ,x_line_num                 => x_line_num
              ,x_line_type                => x_line_type
              ,x_exchange_rate            => x_exchange_rate
              ,x_rate_type                => x_rate_type
              ,x_rate_date                => x_rate_date
              ,x_currency_code            => x_currency_code
              ,x_amount                   => x_amount
             );

log_message('300: About to update pa_mc_cc_dist_lines_all');

-- If all the rows being updated are reversing lines then the
-- get_mrc_values will not return any rows in x_cc_dist_line_id. Then
-- no updates to the MRC table need to be performed.

IF x_cc_dist_line_id.exists(1)
THEN
 FORALL j IN x_cc_dist_line_id.First..x_cc_dist_line_id.Last
     UPDATE pa_mc_cc_dist_lines_all
        SET
             acct_tp_rate_type       = x_rate_type(j)
            ,acct_tp_rate_date       = x_rate_date(j)
            ,acct_tp_exchange_rate   = x_exchange_rate(j)
            ,amount                  = x_amount(j)
            ,request_id              = p_request_id
            ,program_id              = p_program_id
            ,program_application_id  = p_program_application_id
     WHERE  set_of_books_id   = x_sob_id(j)
       AND  cc_dist_line_id   = x_cc_dist_line_id(j)
       AND  prc_assignment_id = -99;

   log_message('350: Rows updated : ' || sql%rowcount);

END IF;

-- Clean up before leaving

 log_message('350: Cleaning up');

 x_sob_id.delete;
 x_cc_dist_line_id.delete;
 x_expenditure_item_id.delete;
 x_line_num.delete;
 x_line_type.delete;
 x_exchange_rate.delete;
 x_rate_type.delete;
 x_rate_date.delete;
 x_currency_code.delete;
 x_amount.delete;

log_message('400: Leaving bl_mc_update');

reset_curr_function;

EXCEPTION
 WHEN OTHERS
  THEN
   log_message('450: ERROR in bl_mc_update');
   raise;
**/
null;
END bl_mc_update;


-------------------------------------------------------------------------------
--              bl_mc_insert
-------------------------------------------------------------------------------

PROCEDURE bl_mc_insert
       (
         p_primary_sob_id               IN  gl_sets_of_books.set_of_books_id%TYPE
        ,p_prvdr_org_id                 IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_rsob_id                      IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_rcurrency_code               IN  PA_PLSQL_DATATYPES.Char15TabTyp
        ,p_cc_dist_line_id              IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_line_type                    IN  PA_PLSQL_DATATYPES.Char2TabTyp
        ,p_expenditure_item_id          IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_line_num                     IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_denom_currency_code          IN  PA_PLSQL_DATATYPES.Char15TabTyp
        ,p_acct_tp_rate_type            IN  PA_PLSQL_DATATYPES.Char30TabTyp
        ,p_expenditure_item_date        IN  PA_PLSQL_DATATYPES.DateTabTyp
        ,p_acct_tp_exchange_rate        IN  PA_PLSQL_DATATYPES.NumTabTyp
        ,p_denom_transfer_price         IN  PA_PLSQL_DATATYPES.NumTabTyp
        ,p_dist_line_id_reversed        IN  PA_PLSQL_DATATYPES.IDTabTyp
                               DEFAULT PA_PLSQL_DATATYPES.EmptyIDTab
        ,p_cdl_line_num                 IN  PA_PLSQL_DATATYPES.NumTabTyp
                               DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab
        ,p_prvdr_cost_reclass_code      IN  PA_PLSQL_DATATYPES.Char240TabTyp
                               DEFAULT PA_PLSQL_DATATYPES.EmptyChar240Tab
        ,p_login_id                     IN  NUMBER
        ,p_program_id                   IN  NUMBER
        ,p_program_application_id       IN  NUMBER
        ,p_request_id                   IN  NUMBER
        ,p_debug_mode                   IN  boolean
       ) IS

x_sob_id                PA_PLSQL_DATATYPES.IDTabTyp;
x_cc_dist_line_id       PA_PLSQL_DATATYPES.IDTabTyp;
x_expenditure_item_id   PA_PLSQL_DATATYPES.IDTabTyp;
x_line_num              PA_PLSQL_DATATYPES.IDTabTyp;
x_line_type             PA_PLSQL_DATATYPES.Char2TabTyp;
x_exchange_rate         PA_PLSQL_DATATYPES.NumTabTyp;
x_rate_type             PA_PLSQL_DATATYPES.Char30TabTyp;
x_rate_date             PA_PLSQL_DATATYPES.DateTabTyp;
x_currency_code         PA_PLSQL_DATATYPES.Char15TabTyp;
x_amount                PA_PLSQL_DATATYPES.NumTabTyp;

i PLS_INTEGER := 0;

BEGIN
/**
set_curr_function('bl_mc_insert');

log_message('500: Entered bl_mc_insert');

-- Obtain the converted values for each combination of set of books
-- and line id attributes

get_mrc_values(
               p_primary_sob_id           => p_primary_sob_id
              ,p_prvdr_org_id             => p_prvdr_org_id
              ,p_rsob_id                  => p_rsob_id
              ,p_rcurrency_code           => p_rcurrency_code
              ,p_cc_dist_line_id          => p_cc_dist_line_id
              ,p_dist_line_id_reversed    => p_dist_line_id_reversed
              ,p_expenditure_item_id      => p_expenditure_item_id
              ,p_line_num                 => p_line_num
              ,p_line_type                => p_line_type
              ,p_denom_currency_code      => p_denom_currency_code
              ,p_acct_tp_rate_type        => p_acct_tp_rate_type
              ,p_expenditure_item_date    => p_expenditure_item_date
              ,p_acct_tp_exchange_rate    => p_acct_tp_exchange_rate
              ,p_denom_amount             => p_denom_transfer_price
              ,p_cdl_line_num             => p_cdl_line_num
              ,p_prvdr_cost_reclass_code  => p_prvdr_cost_reclass_code
              ,x_sob_id                   => x_sob_id
              ,x_cc_dist_line_id          => x_cc_dist_line_id
              ,x_expenditure_item_id      => x_expenditure_item_id
              ,x_line_num                 => x_line_num
              ,x_line_type                => x_line_type
              ,x_exchange_rate            => x_exchange_rate
              ,x_rate_type                => x_rate_type
              ,x_rate_date                => x_rate_date
              ,x_currency_code            => x_currency_code
              ,x_amount                   => x_amount
             );

log_message('550: About to apply MRC inserts');

IF x_cc_dist_line_id.exists(1)
THEN
  FORALL i in x_cc_dist_line_id.First..x_cc_dist_line_id.Last
    INSERT INTO PA_MC_CC_DIST_LINES_ALL
     (
       set_of_books_id
      ,prc_assignment_id
      ,cc_dist_line_id
      ,expenditure_item_id
      ,line_num
      ,line_type
      ,acct_currency_code
      ,amount
      ,program_id
      ,program_application_id
      ,program_update_date
      ,request_id
      ,transfer_status_code
      ,acct_tp_rate_type
      ,acct_tp_rate_date
      ,acct_tp_exchange_rate
      ,gl_batch_name
      ,transferred_date
      ,transfer_rejection_code
     )
  VALUES
     (
       x_sob_id(i)               -- set_of_books_id
      ,-99                       -- prc_assignment_id
      ,x_cc_dist_line_id(i)      -- cc_dist_line_id
      ,x_expenditure_item_id(i)  -- expenditure_item_id
      ,x_line_num(i)             -- line_num
      ,x_line_type(i)            -- line_type
      ,x_currency_code(i)        -- acct_currency_code
      ,x_amount(i)               -- amount
      ,p_program_id              -- program_id
      ,p_program_application_id  -- program_application_id
      ,sysdate                   -- program_update_date
      ,p_request_id              -- request_id
      ,'P'                       -- transfer_status_code
      ,x_rate_type(i)            -- acct_tp_rate_type
      ,x_rate_date(i)            -- acct_tp_rate_date
      ,x_exchange_rate(i)        -- acct_tp_exchange_rate
      ,NULL                      -- gl_batch_name
      ,NULL                      -- transferred_date
      ,NULL                      -- transfer_rejection_code
     );
END IF;

log_message('600: Rows inserted: ' || sql%rowcount);

-- Clean up before leaving

 x_sob_id.delete;
 x_cc_dist_line_id.delete;
 x_expenditure_item_id.delete;
 x_line_num.delete;
 x_line_type.delete;
 x_exchange_rate.delete;
 x_rate_type.delete;
 x_rate_date.delete;
 x_currency_code.delete;
 x_amount.delete;

log_message('650: Leaving bl_mc_insert');

reset_curr_function;

EXCEPTION
 WHEN OTHERS
  THEN
   log_message('700: ERROR in bl_mc_insert');
   raise;
**/
null;
END bl_mc_insert;

-------------------------------------------------------------------------------
--              get_mrc_values
--
-- This function is called by the bl_mc_insert and bl_mc_updated
-- procedures and computes the conversions for each set of books and
-- line ids passed in. The details of each Cross Charge Distribution
-- and the corresponding attributes are passed in (the IN parameters).
-- The output is a cartesian product of the set of books and line ids
-- passed in. For example if there are 2 sets of books (p_rsob_id
-- table will have two values) and three line ids (p_cc_dist_line_id
-- table will have 3 values), then the corresponding out parameters
-- will have 6 records (Sob1, Line1), (Sob2, Line1), (Sob1, Line2),
-- (Sob2, Line2), etc.
--
-- Depending on whether it is called from the bl_mc_update or
-- bl_mc_insert procedure, certain values may not be populated. For
-- example, upd_type is not relevant for inserts and p_cc_dist_line_id
-- is not relevant for updates.
-------------------------------------------------------------------------------

PROCEDURE get_mrc_values (
             p_primary_sob_id        IN gl_Sets_of_books.set_of_books_id%TYPE
            ,p_prvdr_org_id          IN PA_PLSQL_DATATYPES.IDTabTyp
            ,p_rsob_id               IN PA_PLSQL_DATATYPES.IDTabTyp
            ,p_rcurrency_code        IN PA_PLSQL_DATATYPES.Char15TabTyp
            ,p_cc_dist_line_id       IN PA_PLSQL_DATATYPES.IDTabTyp
            ,p_upd_type              IN PA_PLSQL_DATATYPES.Char1TabTyp
                               DEFAULT PA_PLSQL_DATATYPES.EmptyChar1Tab
            ,p_dist_line_id_reversed IN PA_PLSQL_DATATYPES.IDTabTyp
                               DEFAULT PA_PLSQL_DATATYPES.EmptyIDTab
            ,p_expenditure_item_id   IN PA_PLSQL_DATATYPES.IDTabTyp
                               DEFAULT PA_PLSQL_DATATYPES.EmptyIDTab
            ,p_line_num              IN PA_PLSQL_DATATYPES.IDTabTyp
                               DEFAULT PA_PLSQL_DATATYPES.EmptyIDTab
            ,p_line_type             IN PA_PLSQL_DATATYPES.Char2TabTyp
            ,p_denom_currency_code   IN PA_PLSQL_DATATYPES.Char15TabTyp
            ,p_acct_tp_rate_type     IN PA_PLSQL_DATATYPES.Char30TabTyp
            ,p_expenditure_item_date IN PA_PLSQL_DATATYPES.DateTabTyp
            ,p_acct_tp_exchange_rate IN PA_PLSQL_DATATYPES.NumTabTyp
            ,p_denom_amount          IN PA_PLSQL_DATATYPES.NumTabTyp
            ,p_cdl_line_num          IN PA_PLSQL_DATATYPES.NumTabTyp
                               DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab
            ,p_prvdr_cost_reclass_code IN  PA_PLSQL_DATATYPES.Char240TabTyp
                               DEFAULT PA_PLSQL_DATATYPES.EmptyChar240Tab
            ,x_sob_id                OUT NOCOPY PA_PLSQL_DATATYPES.IDTabTyp
            ,x_cc_dist_line_id       OUT NOCOPY PA_PLSQL_DATATYPES.IDTabTyp
            ,x_expenditure_item_id   OUT NOCOPY PA_PLSQL_DATATYPES.IDTabTyp
            ,x_line_num              OUT NOCOPY PA_PLSQL_DATATYPES.IDTabTyp
            ,x_line_type             OUT NOCOPY PA_PLSQL_DATATYPES.Char2TabTyp
            ,x_exchange_rate         OUT NOCOPY PA_PLSQL_DATATYPES.NumTabTyp
            ,x_rate_type             OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp
            ,x_rate_date             OUT NOCOPY PA_PLSQL_DATATYPES.DateTabTyp
            ,x_currency_code         OUT NOCOPY PA_PLSQL_DATATYPES.Char15TabTyp
            ,x_amount                OUT NOCOPY PA_PLSQL_DATATYPES.NumTabTyp
            ) IS

l_sob_cnt          PLS_INTEGER ;  -- Count of set of books
l_id_cnt           PLS_INTEGER ;  -- Count of line ids
i                  PLS_INTEGER ;  -- Output record counter

l_result_code      VARCHAR2(15); -- Holds the result of the get_mc_rate package
l_denominator_rate NUMBER; -- Denominator rate from mc package
l_numerator_rate   NUMBER; -- Numerator rate from mc package

l_cdl_line_num     pa_cost_distribution_lines_all.line_num%TYPE;

-- Single element variables
l_acct_tp_rate_type     pa_cc_dist_lines_all.acct_tp_rate_type%TYPE;
l_acct_tp_rate_date     DATE;
l_acct_tp_exchange_rate pa_cc_dist_lines_all.acct_tp_exchange_rate%TYPE;

-- Defines whether MC has to be performed on record or not
lb_process_record         BOOLEAN;

-- Defines whether rate has to be obtained from the MRC package or
-- whether it will be obtained from a reversed line
lb_get_new_rate           BOOLEAN;

-- Defines whether this is a Provider Reclass entry
lb_provider_reclass_line  BOOLEAN;

-- Defines whether this is a Borrowed and Lent entry
lb_borrowed_lent_line     BOOLEAN;

-- Exception raised if line type is not valid
EXCP_INVALID_LINE_TYPE    EXCEPTION;

BEGIN
/*
set_curr_function('get_mrc_values');

log_message('750: Entered get_mrc_values');


i := 0;  -- Initialize output counter

-- Following are two loops so that the cartesian product of the
-- reporting set of books and the line_id records can be obtained.
-- Set of books id put in as inner loop since it is more likely that
-- all record related to a line_id will be physically together in the
-- database

FOR l_id_cnt IN p_cc_dist_line_id.First..p_cc_dist_line_id.Last
LOOP

  log_message('800: Processing set of books count ' || l_id_cnt);

-- Determine the type of line passed in. The two types of lines
-- supported at present are: Provider Reclassification and Borrowed
-- and Lent

  IF p_line_type(l_id_cnt) = 'BL'
  THEN
     log_message('850: Processing Borrowed and Lent line');
     lb_borrowed_lent_line    := TRUE;
     lb_provider_reclass_line := FALSE;
  ELSIF p_line_type(l_id_cnt) = 'PC'
  THEN
     log_message('900: Processing Provider Reclass line');
     lb_provider_reclass_line := TRUE;
     lb_borrowed_lent_line    := FALSE;
  ELSE
    IF ( p_upd_type.exists(l_id_cnt) )
    THEN
        IF ( p_upd_type(l_id_cnt) <> 'R' )
        THEN
          log_message('940: Invalid line type');
          raise EXCP_INVALID_LINE_TYPE;
        END IF;
    ELSE
       log_message('970: Invalid line type');
       raise EXCP_INVALID_LINE_TYPE;
    END IF;
  END IF;


 FOR l_sob_cnt IN p_rsob_id.First..p_rsob_id.Last
  LOOP

   log_message('1000: Processing set of books id: ' || p_rsob_id(l_sob_cnt));

-- No updates required for reversed distribution lines (upd_type =
-- 'R'). For inserts, upd_type will not exist while for other updates,
-- upd_type will be 'U'. The logic below avoids a no_Data_found error
-- so that the value of upd_type is not checked when it is not
-- initialized

   IF p_upd_type.exists(l_id_cnt)
   THEN
     IF p_upd_type(l_id_cnt) = 'R'
     THEN
        lb_process_record := FALSE;
     ELSE
        lb_process_record := TRUE;
     END IF;
   ELSE
        lb_process_record := TRUE;
   END IF;

   IF lb_process_record
   THEN

-- Set counter for output records
         i := i + 1;

-- Copy line attributes for insert if applicable

        x_sob_id(i)          := p_rsob_id(l_sob_cnt);
        x_currency_code(i)   := p_rcurrency_code(l_sob_cnt);
        x_cc_dist_line_id(i) := p_cc_dist_line_id(l_id_cnt);

-- Expenditure item id not required for updates. Populate in output
-- only if passed in

        IF p_expenditure_item_id.exists(l_id_cnt)
        THEN
           x_expenditure_item_id(i) := p_expenditure_item_id(l_id_cnt);
           x_line_num(i)   := p_line_num(l_id_cnt);
           x_line_type(i)  := p_line_type(l_id_cnt);
        END IF;

-- If there is a dist_line_id_reversed, this means that the current
-- distribution reverses an existing one. The attributes for this
-- distribution will be copied from the reversed distribution and the
-- amounts negated

        IF      p_dist_line_id_reversed.exists(l_id_cnt)
        THEN
           IF p_dist_line_id_reversed(l_id_cnt) IS NOT NULL
           THEN
              lb_get_new_rate := FALSE;
           ELSE
              lb_get_new_rate := TRUE;
           END IF;
        ELSE
            lb_get_new_rate := TRUE;
        END IF;

-- If this is not a reversing line, then the attributes have to be
-- derived. In the case of Borrowed and Lent lines, the derivation is
-- straightforward - take the input denom transfer price and convert
-- it to the corresponding amount in the reporting set of books. For
-- Provider Reclassification entries (line_type = 'PC'), since it is
-- supposed to reclassify the existing cost, the attributes should not
-- be got from the GL API (using current conversion attributes), but
-- instead, should be got from the corresponding CDL line

       IF lb_get_new_rate   --- If100
       THEN

         log_message('1050: New rates to be determined');

         IF lb_borrowed_lent_line  --- If200
         THEN

         log_message('1100: Processing Borrowed and Lent line');

-- The existing rate attributes have to be passed in. If the
-- conversion from the denom_transfer_price to the acct_transfer_price
-- has occurred using a 'User' rate type in the primary set of books,
-- then the MRC package will first convert the denom_Transfer_price to
-- the functional currency and then to the reporting currency (a two
-- stage conversion). Otherwise, it will convert directly from the
-- denom_transfer_price to the reporting currency
-- Note that for the reporting set of books, the date used is always
-- the expenditure item date

             l_acct_tp_rate_type     := p_acct_tp_rate_type(l_id_cnt);
             l_acct_tp_exchange_rate := p_acct_tp_exchange_rate(l_id_cnt);
             l_acct_tp_rate_date     := p_expenditure_item_date(l_id_cnt);

-- Log rate attributes passed in for future debugging

             log_message('1150: Parameters passed to MRC API');
             log_message('1200: Primary sob id: ' || to_char(p_primary_sob_id));
             log_message('1250: Reporting sob id: ' || to_char(p_rsob_id(l_sob_cnt)));
             log_message('1300: Trans date : ' || p_expenditure_item_date(l_id_cnt));
             log_message('1350: Conv type: ' || l_acct_tp_rate_type);
             log_message('1400: Conv date: ' || l_acct_tp_rate_date);
             log_message('1450: Conv rate: ' || l_acct_tp_exchange_rate);
             log_message('1500: Org_id: ' || p_prvdr_org_id(l_id_cnt));

-- Call the MRC API for obtaining the converted values for this set of
-- books and line attributes


              gl_mc_currency_pkg.get_rate
              ( p_primary_set_of_books_id   => p_primary_sob_id
               ,p_reporting_set_of_books_id => p_rsob_id(l_sob_cnt)
               ,p_trans_date                => p_expenditure_item_date(l_id_cnt)
               ,p_trans_currency_code       => p_denom_currency_code(l_id_cnt)
               ,p_trans_conversion_type     => l_acct_tp_rate_type
               ,p_trans_conversion_date     => l_acct_tp_rate_date
               ,p_trans_conversion_rate     => l_acct_tp_exchange_rate
               ,p_application_id            => 275
               ,p_org_id                    => p_prvdr_org_id(l_id_cnt)
               ,p_fa_book_type_code         => NULL
               ,p_je_source_name            => NULL
               ,p_je_category_name          => NULL
               ,p_result_code               => l_result_code
               ,p_denominator_rate          => l_denominator_rate
               ,p_numerator_rate            => l_numerator_rate
               );

               log_message('1550: Returned from get_rate with ' || l_result_code);

-- Save returned attributes

              x_rate_type(i)     := l_acct_tp_rate_type;
              x_rate_date(i)     := l_acct_tp_rate_date;
              x_exchange_rate(i) := l_acct_tp_exchange_rate;

              IF l_acct_tp_rate_type = 'User'
              THEN
                log_message('1600: Rate type returned is user');
                x_amount(i)  :=
                pa_mc_currency_pkg.CurrRound ((p_denom_amount(l_id_cnt)*
                 p_acct_tp_exchange_rate(l_id_cnt)),
                            p_rcurrency_code(l_sob_cnt));
              ELSE
                x_amount(i)  :=
                   pa_mc_currency_pkg.CurrRound(
                     ((p_denom_amount(l_id_cnt)/
                       l_denominator_rate)*l_numerator_rate),
                                        p_rcurrency_code(l_sob_cnt));
              END IF;

-- For the Provider Reclassification entries, the CDL line acts
-- as the source of the rates and amounts.

 -- Following elsif borrowed and lent line If200

          ELSIF lb_provider_reclass_line
          THEN

           log_message('1650: Selecting MRC Cost distribution line');

                SELECT   currency_code
                        ,decode(p_prvdr_cost_reclass_code(l_id_cnt), 'R',
                           amount, burdened_cost)
                        ,rate_type
                        ,conversion_date
                        ,exchange_rate
                 INTO
                         x_currency_code(i)
                        ,x_amount(i)
                        ,x_rate_type(i)
                        ,x_rate_date(i)
                        ,x_exchange_rate(i)
                 FROM   pa_mc_cost_dist_lines_all
                WHERE   expenditure_item_id = p_expenditure_item_id(l_id_cnt)
                  AND   line_num            = p_cdl_line_num(l_id_cnt)
                  AND   prc_assignment_id   = -99
                  AND   set_of_books_id     = p_rsob_id(l_sob_cnt);

           log_message('1700: Got MRC Cost distribution line');

            x_sob_id(i)                := p_rsob_id(l_sob_cnt);
            x_cc_dist_line_id(i)       := p_cc_dist_line_id(l_id_cnt);


          END IF;                            -- If200

        ELSE                                 -- Else100 -  reversing or not

-- Reversing line. Note that unlike for Cost Distribution lines, it
-- does not matter whether the reversed line is in the same
-- Expenditure Item or a different Expenditure item. The two line_ids
-- are linked by the dist_line_id_reversed column. Getting values from
-- reversed line

         log_message('1750: Getting values from reversed line');

            SELECT
                  acct_currency_code,
                  -amount,
                  acct_tp_rate_type,
                  acct_tp_rate_date,
                  acct_tp_exchange_rate
             INTO
                  x_currency_code(i),
                  x_amount(i),
                  x_rate_type(i),
                  x_rate_date(i),
                  x_exchange_rate(i)
             FROM pa_mc_cc_dist_lines_all
            WHERE set_of_books_id   = p_rsob_id(l_sob_cnt)
              AND cc_dist_line_id   = p_dist_line_id_reversed(l_id_cnt)
              AND prc_assignment_id = -99;

         log_message('1800: Got values for reversed line');

        END IF;  -- end get_new rate

   END IF; -- end process record

  END LOOP;  -- end loop for processing line ids

END LOOP; -- end loop for processing set of books

log_message('1850: Leaving get_mrc_values. Filled up records: '|| to_char(i));

reset_curr_function;

EXCEPTION
 WHEN OTHERS
  THEN
   x_sob_id.delete;
   x_cc_dist_line_id.delete;
   x_expenditure_item_id.delete;
   x_line_num.delete;
   x_line_type.delete;
   x_exchange_rate.delete;
   x_rate_type.delete;
   x_rate_date.delete;
   x_currency_code.delete;
   x_amount.delete;
   log_message('1900: Error in get_mrc_values');
   raise;
*/
null;
END get_mrc_values;

-------------------------------------------------------------------------------
--              log_message
-------------------------------------------------------------------------------

PROCEDURE log_message( p_message IN VARCHAR2) IS
BEGIN
/*
  pa_cc_utils.log_message(p_message);
*/
null;

END log_message;

-------------------------------------------------------------------------------
--              set_curr_function
-------------------------------------------------------------------------------

PROCEDURE set_curr_function(p_function IN VARCHAR2) IS
BEGIN
   --pa_cc_utils.set_curr_function(p_function);
null;

END;

-------------------------------------------------------------------------------
--              reset_curr_function
-------------------------------------------------------------------------------

PROCEDURE reset_curr_function IS
BEGIN
   --pa_cc_utils.reset_curr_function;
null;
END;

END PA_MC_BORRLENT;

/
