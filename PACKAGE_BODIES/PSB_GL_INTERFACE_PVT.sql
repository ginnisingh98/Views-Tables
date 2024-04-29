--------------------------------------------------------
--  DDL for Package Body PSB_GL_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_GL_INTERFACE_PVT" AS
/* $Header: PSBVOGLB.pls 120.25.12010000.11 2009/05/26 13:37:53 rkotha ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_GL_Interface_PVT';

  g_posting_completed     BOOLEAN := FALSE;
  g_budget_by_position    VARCHAR2(1);
  g_set_of_books_id       NUMBER(15);
  g_set_of_books_name     VARCHAR2(30);
  g_chart_of_accounts_id  NUMBER(15);
  g_flex_mapping_set_id   NUMBER(15);
  g_gl_calendar           VARCHAR2(30);
  g_currency_code         VARCHAR2(30);
  g_gl_map                VARCHAR2(30);
  g_fund_segment          VARCHAR2(30);
  g_budgetary_control     VARCHAR2(1);
  g_average_balances      VARCHAR2(1);
  g_templ_seg_val         FND_FLEX_EXT.SegmentArray;
  g_post_to_all           VARCHAR2(1) := FND_API.G_FALSE; -- Bug#4310411
  g_budget_source_type    VARCHAR2(2); -- Bug#4310411
  g_budget_year_type_id  NUMBER; -- Bug#4310411


  g_offset_revision       VARCHAR2(1);
  g_permanent_revision    VARCHAR2(1);
  g_budget_set_id         NUMBER(15);
  g_revision_type         VARCHAR2(1);

  g_user_id               NUMBER(15);
  g_login_id              NUMBER(15);
  g_program_id            NUMBER(15);
  g_request_id            NUMBER(15);
  /*FOR Bug No : 2760443 Start*/
  --increased the size FROM 15 to 45 FOR NLS compliance
  --g_org_code              VARCHAR2(45); -- Bug#4310411
  /*FOR Bug No : 2760443 END*/
  g_source_name           VARCHAR2(25);
  g_category_name         VARCHAR2(25);
  g_batch_name            VARCHAR2(100); -- Bug#4310411
  g_batch_description     VARCHAR2(100); -- Bug#4310411
  g_je_name               VARCHAR2(100); -- Bug#4310411
  g_je_description        VARCHAR2(100); -- Bug#4310411
  g_budget_year_id        NUMBER(15);    -- Bug 3029168

  -- SLA variables
  g_sob_list              XLA_GL_TRANSFER_PKG.T_SOB_LIST := XLA_GL_TRANSFER_PKG.T_SOB_LIST();
  g_ae_category           XLA_GL_TRANSFER_PKG.t_ae_category;

  --Reporting Sets of books list

  TYPE HdrArrayRec IS RECORD
      (ae_header_id NUMBER,
       budget_version_id NUMBER,
       dual_posting_type VARCHAR2(1));

  TYPE HdrArrayTbl IS TABLE OF HdrArrayRec
    INDEX BY BINARY_INTEGER;

  g_header_ids          HdrArrayTbl;
  g_header_count        NUMBER;

  TYPE LineArrayRec IS RECORD
      ( ae_line_id           NUMBER,
        code_combination_id  NUMBER,
        service_package_id   NUMBER,
        currency_code        VARCHAR2(15),
        ae_line_type_code    VARCHAR2(30),
        delete_flag          VARCHAR2(1),
        reference2           VARCHAR2(240),
        -- FOR bug no 3347237
        reference3           VARCHAR2(240)
      ) ;

  TYPE LineArrayTbl IS TABLE OF LineArrayRec
    INDEX BY BINARY_INTEGER;

  g_line_ids            LineArrayTbl;
  g_line_count          NUMBER;

  TYPE SegNamArray IS TABLE OF VARCHAR2(9)
    INDEX BY BINARY_INTEGER;

  g_seg_name            SegNamArray;
  g_num_segs            NUMBER;

  -- FOR Message reporting
  TYPE TokNameArray IS TABLE OF VARCHAR2(100)
    INDEX BY BINARY_INTEGER;
  --
  TYPE TokValArray IS TABLE OF VARCHAR2(1000)
    INDEX BY BINARY_INTEGER;
  --
  -- Bug#4310411 Start.
  -- Declare three TYPES represnting required datatypes
  TYPE Number_Tbl_Type IS TABLE OF NUMBER        INDEX BY PLS_INTEGER;
  TYPE Char_Tbl_Type   IS TABLE OF VARCHAR2(100) INDEX BY PLS_INTEGER;
  TYPE Date_Tbl_Type   IS TABLE OF DATE          INDEX BY PLS_INTEGER;
  -- Bug#4310411 End.

  no_msg_tokens         NUMBER := 0;
  msg_tok_names         TokNameArray;
  msg_tok_val           TokValArray;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                             PROCEDURE pd                                  |
 +===========================================================================*/
PROCEDURE pd( p_message   IN     VARCHAR2)
IS
BEGIN
  NULL ;
  --DBMS_OUTPUT.Put_Line(p_message) ;
END pd ;
/*---------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------*/

/*Bug:7639620:start*/
PROCEDURE CHECK_POSTING_STATUS
(
  p_return_status        OUT  NOCOPY  VARCHAR2,
  p_event_type                VARCHAR2,
  p_source_id                 NUMBER,
  p_period_name               VARCHAR2,
  p_budget_version_id         NUMBER,
  p_code_combination_id       NUMBER,
  p_budget_version_flag       VARCHAR2
);
/*Bug:7639620:end*/

PROCEDURE Validate_Funding_Account
(x_return_status     OUT    NOCOPY VARCHAR2,
 p_event_type                      VARCHAR2,
 p_source_id                       NUMBER,
 p_stage_sequence                  NUMBER := NULL,
 p_budget_year_id                  NUMBER := NULL,
 p_gl_budget_set_id                NUMBER,
 p_start_date                      DATE,
 x_validation_status IN OUT NOCOPY VARCHAR2
);

PROCEDURE Create_Adopted_Budget
(x_return_status    OUT NOCOPY VARCHAR2,
 p_worksheet_id                NUMBER,
 p_budget_stage_id             NUMBER,
 p_budget_year_id              NUMBER,
 p_year_journal                VARCHAR2,
 p_gl_transfer_mode            VARCHAR2,
 p_auto_offset                 VARCHAR2,
 p_gl_budget_set_id            NUMBER,
 p_order_by1                   VARCHAR2,
 p_order_by2                   VARCHAR2,
 p_order_by3                   VARCHAR2
);

PROCEDURE Message_Token(tokname IN  VARCHAR2,
                        tokval  IN  VARCHAR2);

PROCEDURE Add_Message( appname  IN  VARCHAR2,
                       msgname  IN  VARCHAR2);

/* ----------------------------------------------------------------------- */

FUNCTION Find_GL_Budget_Set
(p_set_of_books_id  IN  NUMBER) RETURN NUMBER IS

  l_gl_budget_set_id NUMBER := 0;

  CURSOR c_gl_budget_set
  IS
  SELECT gl_budget_set_id
  FROM PSB_GL_BUDGET_SETS
  WHERE set_of_books_id = p_set_of_books_id;

BEGIN

  FOR c_gl_budget_set_rec IN c_gl_budget_set LOOP
    l_gl_budget_set_id := c_gl_budget_set_rec.gl_budget_set_id;
  END LOOP;

  RETURN l_gl_budget_set_id;

END Find_GL_Budget_Set;

/* ----------------------------------------------------------------------- */

/* ----------------------------------------------------------------------- */
/*Bug:7639620:start*/
PROCEDURE CHECK_POSTING_STATUS
(
  p_return_status        OUT  NOCOPY  VARCHAR2,
  p_event_type                VARCHAR2,
  p_source_id                 NUMBER,
  p_period_name               VARCHAR2,
  p_budget_version_id         NUMBER,
  p_code_combination_id       NUMBER,
  p_budget_version_flag       VARCHAR2
)
IS

  l_posted  BOOLEAN := FALSE;

  CURSOR c_ws_csr IS
  select 1
  FROM   PSB_GL_INTERFACES
  WHERE  worksheet_id        = p_source_id
  AND    budget_version_id   = p_budget_version_id
  AND    code_combination_id = p_code_combination_id
  AND    budget_version_flag = p_budget_version_flag
  AND    budget_source_type  = p_event_type
  AND    period_name         = p_period_name
  AND    gl_transfer_flag    = 'Y';

BEGIN
    FOR l_ws_rec IN c_ws_csr LOOP
       l_posted := TRUE;
    END LOOP;

    IF l_posted THEN
      IF p_event_type IN ('BP','SW') THEN
	  message_token('WORKSHEET', p_source_id);
	  message_token('PERIOD', p_period_name);
	  add_message('PSB', 'PSB_WORKSHEET_POSTED');
	  raise FND_API.G_EXC_ERROR;
      ELSIF p_event_type IN ('BR','SR') THEN
	  message_token('REVISION', p_source_id);
	  message_token('PERIOD', p_period_name);
	  add_message('PSB', 'PSB_REVISION_POSTED');
	  raise FND_API.G_EXC_ERROR;
      END IF;
    END IF;

  -- Initialize API RETURN status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;
/*Bug:7639620:end*/
/* ----------------------------------------------------------------------- */


PROCEDURE Get_Offset_Account
(x_return_status OUT    NOCOPY VARCHAR2,
 p_templ_acct                  VARCHAR2,
 p_fund                        VARCHAR2,
 p_templ_seg     IN OUT NOCOPY FND_FLEX_EXT.SegmentArray,
 p_ccid          OUT    NOCOPY NUMBER
)
IS

  l_ccid          NUMBER;
  l_seg_val       FND_FLEX_EXT.SegmentArray;

  l_account_found BOOLEAN;

  CURSOR c_templacct
  IS
  SELECT code_combination_id
  FROM psb_fund_balance_accounts
  WHERE set_of_books_id = g_set_of_books_id
  AND template_account = 'Y';

  CURSOR c_nontemplacct
  IS
  SELECT a.code_combination_id
  FROM gl_code_combinations a,
       psb_fund_balance_accounts b
  WHERE a.code_combination_id = b.code_combination_id
  AND b.set_of_books_id = g_set_of_books_id
  AND DECODE(g_fund_segment,'SEGMENT1',  SEGMENT1,
                            'SEGMENT2',  SEGMENT2,
                            'SEGMENT3',  SEGMENT3,
                            'SEGMENT4',  SEGMENT4,
                            'SEGMENT5',  SEGMENT5,
                            'SEGMENT6',  SEGMENT6,
                            'SEGMENT7',  SEGMENT7,
                            'SEGMENT8',  SEGMENT8,
                            'SEGMENT9',  SEGMENT9,
                            'SEGMENT10', SEGMENT10,
                            'SEGMENT11', SEGMENT11,
                            'SEGMENT12', SEGMENT12,
                            'SEGMENT13', SEGMENT13,
                            'SEGMENT14', SEGMENT14,
                            'SEGMENT15', SEGMENT15,
                            'SEGMENT16', SEGMENT16,
                            'SEGMENT17', SEGMENT17,
                            'SEGMENT18', SEGMENT18,
                            'SEGMENT19', SEGMENT19,
                            'SEGMENT20', SEGMENT20,
                            'SEGMENT21', SEGMENT21,
                            'SEGMENT22', SEGMENT22,
                            'SEGMENT23', SEGMENT23,
                            'SEGMENT24', SEGMENT24,
                            'SEGMENT25', SEGMENT25,
                            'SEGMENT26', SEGMENT26,
                            'SEGMENT27', SEGMENT27,
                            'SEGMENT28', SEGMENT28,
                            'SEGMENT29', SEGMENT29,
                            'SEGMENT30', SEGMENT30
            ) = p_fund;

BEGIN

  l_account_found := FALSE;

  IF p_templ_acct = 'Y' THEN
    BEGIN
      FOR c_templacct_rec IN c_templacct LOOP
        l_account_found := TRUE;
        l_ccid := c_templacct_rec.code_combination_id;
      END LOOP;

      IF NOT l_account_found THEN
        Add_Message('PSB', 'PSB_GL_BJE_NO_TEMPL_ACCT');
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        BEGIN
          IF NOT FND_FLEX_EXT.Get_Segments
                 (application_short_name => 'SQLGL',
                  key_flex_code          => 'GL#',
                  structure_number       => g_chart_of_accounts_id,
                  combination_id         => l_ccid,
                  n_segments             => g_num_segs,
                  segments               => p_templ_seg
                 )
          THEN
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
          p_ccid := l_ccid;
        END;
      END IF;
    END;
  ELSE
    BEGIN
      FOR c_nontemplacct_rec IN c_nontemplacct LOOP
        l_account_found := TRUE;
        l_ccid := c_nontemplacct_rec.code_combination_id;
      END LOOP;

      IF NOT l_account_found THEN
        BEGIN
          FOR l_index IN 1..g_num_segs LOOP
            IF g_seg_name(l_index) = g_fund_segment THEN
              l_seg_val(l_index) := p_fund;
            ELSE
              l_seg_val(l_index) := p_templ_seg(l_index);
            END IF;
          END LOOP;

          -- A possibility that this ccid AND mapped ccid
          -- violates cross-validation rule get the new
          -- ccid of substitued template account

          IF NOT FND_FLEX_EXT.Get_Combination_ID
                 (application_short_name => 'SQLGL',
                  key_flex_code          => 'GL#',
                  structure_number       => g_chart_of_accounts_id,
                  validation_date        => sysdate,
                  n_segments             => g_num_segs,
                  segments               => l_seg_val,
                  combination_id         => p_ccid
                 )
          THEN
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END;
      ELSE
        p_ccid := l_ccid;
      END IF;
    END;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Get_Offset_Account;

/* ----------------------------------------------------------------------- */
PROCEDURE Balance_Journal
(x_return_status    OUT NOCOPY VARCHAR2,
 p_worksheet_id     IN         NUMBER,
 p_period_name      IN         VARCHAR2,
 p_GL_budget_set_id IN         NUMBER
)
IS

  l_api_name      CONSTANT VARCHAR2(30) := 'Balance_Journal';
  l_api_version   CONSTANT NUMBER       := 1.0;

  l_ccid                   NUMBER;
  l_out_bal_amt            NUMBER;
  l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

  CURSOR c_balacct
  IS
  SELECT
  DECODE
    ( g_fund_segment,
     'SEGMENT1', SEGMENT1,  'SEGMENT2', SEGMENT2,
     'SEGMENT3', SEGMENT3,  'SEGMENT4', SEGMENT4,  'SEGMENT5',SEGMENT5,
     'SEGMENT6', SEGMENT6,  'SEGMENT7', SEGMENT7,  'SEGMENT8',SEGMENT8,
     'SEGMENT9', SEGMENT9,  'SEGMENT10',SEGMENT10, 'SEGMENT11',SEGMENT11,
     'SEGMENT12',SEGMENT12, 'SEGMENT13',SEGMENT13, 'SEGMENT14',SEGMENT14,
     'SEGMENT15',SEGMENT15, 'SEGMENT16',SEGMENT16, 'SEGMENT17',SEGMENT17,
     'SEGMENT18',SEGMENT18, 'SEGMENT19',SEGMENT19, 'SEGMENT20',SEGMENT20,
     'SEGMENT21',SEGMENT21, 'SEGMENT22',SEGMENT22, 'SEGMENT23',SEGMENT23,
     'SEGMENT24',SEGMENT24, 'SEGMENT25',SEGMENT25, 'SEGMENT26',SEGMENT26,
     'SEGMENT27',SEGMENT27, 'SEGMENT28',SEGMENT28, 'SEGMENT29',SEGMENT29,
     'SEGMENT30',SEGMENT30)
         segment,
         a.group_id,
         a.status,
         a.set_of_books_id,
         a.user_je_source_name,
         a.user_je_category_name,
         a.currency_code,
         a.created_by,
         a.actual_flag,
         a.budget_version_id,
         a.period_name,
         a.period_year,
         a.period_num,
         a.quarter_num,
         a.reference1,
         a.reference2,
         sum(a.entered_dr) dr_amt,
         sum(a.entered_cr) cr_amt,
         a.accounting_date,
         a.budget_version_flag,
         sum(a.amount) amount
  FROM psb_gl_interfaces a,
       gl_code_combinations b
  WHERE worksheet_id = p_worksheet_id
  AND period_name = p_period_name
  AND budget_source_type = g_budget_source_type
  AND a.code_combination_id = b.code_combination_id
  GROUP BY DECODE
    ( g_fund_segment,
     'SEGMENT1', SEGMENT1,  'SEGMENT2', SEGMENT2,
     'SEGMENT3', SEGMENT3,  'SEGMENT4', SEGMENT4,  'SEGMENT5',SEGMENT5,
     'SEGMENT6', SEGMENT6,  'SEGMENT7', SEGMENT7,  'SEGMENT8',SEGMENT8,
     'SEGMENT9', SEGMENT9,  'SEGMENT10',SEGMENT10, 'SEGMENT11',SEGMENT11,
     'SEGMENT12',SEGMENT12, 'SEGMENT13',SEGMENT13, 'SEGMENT14',SEGMENT14,
     'SEGMENT15',SEGMENT15, 'SEGMENT16',SEGMENT16, 'SEGMENT17',SEGMENT17,
     'SEGMENT18',SEGMENT18, 'SEGMENT19',SEGMENT19, 'SEGMENT20',SEGMENT20,
     'SEGMENT21',SEGMENT21, 'SEGMENT22',SEGMENT22, 'SEGMENT23',SEGMENT23,
     'SEGMENT24',SEGMENT24, 'SEGMENT25',SEGMENT25, 'SEGMENT26',SEGMENT26,
     'SEGMENT27',SEGMENT27, 'SEGMENT28',SEGMENT28, 'SEGMENT29',SEGMENT29,
     'SEGMENT30',SEGMENT30) ,
           a.group_id,
           a.status,
           a.set_of_books_id,
           a.user_je_source_name,
           a.user_je_category_name,
           a.currency_code,
           a.created_by,
           a.actual_flag,
           a.budget_version_id,
           a.period_name,
           a.period_year,
           a.period_num,
           a.quarter_num,
           a.reference1,
           a.reference2,
           a.accounting_date,
           a.budget_version_flag;


BEGIN

  SAVEPOINT Balance_Journal;

  FOR c_balacct_rec in c_balacct LOOP
    l_out_bal_amt := NVL(c_balacct_rec.dr_amt, 0) - NVL(c_balacct_rec.cr_amt, 0);
    IF l_out_bal_amt <> 0 THEN
      Get_Offset_Account
      (x_return_status => l_return_status,
       p_templ_acct    => 'N',
       p_fund          => c_balacct_rec.segment,
       p_templ_seg     => g_templ_seg_val,
       p_ccid          => l_ccid
      );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      INSERT INTO psb_gl_interfaces
      (worksheet_id,
       group_id,
       status,
       set_of_books_id,
       user_je_source_name,
       user_je_category_name,
       currency_code,
       date_created,
       created_by,
       actual_flag,
       budget_version_id,
       accounting_date,
       period_name,
       period_year,
       period_num,
       quarter_num,
       code_combination_id,
       entered_dr,
       entered_cr,
       reference1,
       reference2,
       reference4,
       reference5,
       budget_source_type,
       budget_version_flag,
       balancing_entry_flag,
       amount,
       gl_budget_set_id
      )
      VALUES
      (p_worksheet_id,
       p_worksheet_id,
       c_balacct_rec.status,
       c_balacct_rec.set_of_books_id,
       c_balacct_rec.user_je_source_name,
       c_balacct_rec.user_je_category_name,
       c_balacct_rec.currency_code,
       sysdate,
       c_balacct_rec.created_by,
       c_balacct_rec.actual_flag,
       c_balacct_rec.budget_version_id,
       c_balacct_rec.accounting_date,
       c_balacct_rec.period_name,
       c_balacct_rec.period_year,
       c_balacct_rec.period_num,
       c_balacct_rec.quarter_num,
       l_ccid,
       DECODE(sign(l_out_bal_amt), -1, -1*l_out_bal_amt, null),
       DECODE(sign(l_out_bal_amt),  1,  l_out_bal_amt, null),
       c_balacct_rec.reference1,
       c_balacct_rec.reference2,
       NULL,
       NULL,
       g_budget_source_type,
       c_balacct_rec.budget_version_flag,
       'Y',
       c_balacct_rec.amount,
       p_GL_budget_set_id
      );
    END IF;
  END LOOP;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Balance_Journal;
     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Balance_Journal;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
     ROLLBACK TO Balance_Journal;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
     END IF;

END Balance_Journal;

/* ----------------------------------------------------------------------- */

PROCEDURE Initialize
(x_return_status OUT NOCOPY VARCHAR2,
 p_event_type               VARCHAR2,
 p_source_id                NUMBER,
 p_auto_offset              VARCHAR2
)
IS

  l_seg_num           NUMBER;
  l_appcol_name       VARCHAR2(30);
  l_seg_name          VARCHAR2(30);
  l_prompt            VARCHAR2(100);
  l_value_set         VARCHAR2(100);
  l_templ_ccid        NUMBER;
  l_current_sob_index NUMBER;
  l_return_status     VARCHAR2(1);
  /*FOR Bug No : 2098359 Start*/
  l_multi_org_flag    VARCHAR2(1);
  /*FOR Bug No : 2098359 END*/

  CURSOR c_seginfo IS
    SELECT application_column_name
      FROM FND_ID_FLEX_SEGMENTS
     WHERE application_id = 101
       AND id_flex_code = 'GL#'
       AND id_flex_num  = g_chart_of_accounts_id
       AND enabled_flag = 'Y'
     ORDER BY segment_num;

  CURSOR c_worksheet
  IS
  SELECT a.worksheet_id, a.budget_by_position,
         a.flex_mapping_set_id,
         b.set_of_books_id,
         b.name,
         b.chart_of_accounts_id,
         b.currency_code,
         b.enable_budgetary_control_flag,
         b.enable_average_balances_flag,
         b.period_set_name
  FROM PSB_WORKSHEETS a,
       GL_SETS_OF_BOOKS b,
       PSB_BUDGET_GROUPS_V c
  WHERE b.set_of_books_id = NVL(c.set_of_books_id, c.root_set_of_books_id)
  AND a.budget_group_id = c.budget_group_id
  AND a.worksheet_id = p_source_id;

  CURSOR c_revision
  IS
  SELECT a.budget_revision_id, a.revise_by_position,
         a.permanent_revision,
         a.gl_budget_set_id,
         a.budget_revision_type,
         b.set_of_books_id,
         b.name,
         b.chart_of_accounts_id,
         b.currency_code,
         b.enable_budgetary_control_flag,
         b.enable_average_balances_flag,
         b.period_set_name,
         b.latest_opened_period_name,
         b.require_budget_journals_flag
  FROM PSB_BUDGET_REVISIONS a,
       GL_SETS_OF_BOOKS b,
       PSB_BUDGET_GROUPS_V c
  WHERE b.set_of_books_id = NVL(c.set_of_books_id,c.root_set_of_books_id)
  AND a.budget_group_id = c.budget_group_id
  AND a.budget_revision_id = p_source_id;

  CURSOR c_je_source
  IS
  SELECT user_je_source_name
  FROM GL_JE_SOURCES
  WHERE je_source_name = 'Budget Journal';

  CURSOR c_je_category
  IS
  SELECT user_je_category_name
  FROM GL_JE_CATEGORIES
  WHERE je_category_name = 'Budget';

  -- Bug#4310411 Start.
  /*CURSOR c_org_code
  IS
  SELECT substr(name,1,15) org_code
  FROM hr_operating_units
  WHERE organization_id = g_org_id;*/
  -- Bug#4310411 End.

  /*FOR Bug No : 2098359 Start*/
  CURSOR c_multi_org
  IS
  SELECT multi_org_flag
  FROM fnd_product_groups;
  /*FOR Bug No : 2098359 END*/

BEGIN

  g_user_id  := FND_GLOBAL.USER_ID;
  g_login_id := FND_GLOBAL.LOGIN_ID;

  /*FOR Bug No : 2098359 Start*/
  FOR c_multi_org_rec IN c_multi_org LOOP
    l_multi_org_flag := c_multi_org_rec.multi_org_flag;
  END LOOP;

  --The following code has been commented since ORG_ID
  --IS NOT applicable IN single org environments
  --g_org_id := FND_PROFILE.VALUE('ORG_ID');
  /*FOR Bug No : 2098359 END*/

  g_program_id     := FND_GLOBAL.CONC_PROGRAM_ID;
  g_request_id     := FND_GLOBAL.CONC_REQUEST_ID;
  g_ae_category(1) := 'Budget';

  -- Bug#4310411 Start.
  /*IF g_org_id IS NOT NULL THEN
    BEGIN
      FOR c_org_code_rec IN c_org_code LOOP
        g_org_code := c_org_code_rec.org_code;
      END LOOP;
    END;
  END IF;*/
  -- Bug#4310411 End.

  FOR c_je_source_rec IN c_je_source LOOP
    g_source_name := c_je_source_rec.user_je_source_name;
  END LOOP;

  FOR c_je_category_rec IN c_je_category LOOP
    g_category_name := c_je_category_rec.user_je_category_name;
  END LOOP;

  g_budget_source_type := p_event_type; -- -- Bug#4310411.

  -- Bug 3029168 added the second clause p_event_type ='SW'
  if p_event_type = 'BP' OR p_event_type = 'SW' then
    BEGIN
      FND_MESSAGE.SET_NAME('PSB', 'PSB_GL_BJE_BATCH_NAME');
      FND_MESSAGE.SET_TOKEN('WORKSHEET_ID', p_source_id);
      g_batch_name := FND_MESSAGE.Get;

      FND_MESSAGE.SET_NAME('PSB', 'PSB_GL_BJE_BATCH_DESC');
      FND_MESSAGE.SET_TOKEN('WORKSHEET_ID', p_source_id);
      g_batch_description := FND_MESSAGE.Get;

      FND_MESSAGE.SET_NAME('PSB', 'PSB_GL_BJE_JE_NAME');
      FND_MESSAGE.SET_TOKEN('WORKSHEET_ID', p_source_id);
      g_je_name := FND_MESSAGE.Get;

      FND_MESSAGE.SET_NAME('PSB', 'PSB_GL_BJE_JE_DESC');
      FND_MESSAGE.SET_TOKEN('WORKSHEET_ID', p_source_id);
      g_je_description := FND_MESSAGE.Get;

      FOR c_worksheet_rec IN c_worksheet LOOP
        g_budget_by_position   := c_worksheet_rec.budget_by_position;
        g_flex_mapping_set_id  := c_worksheet_rec.flex_mapping_set_id;
        g_set_of_books_id      := c_worksheet_rec.set_of_books_id;
        g_set_of_books_name    := c_worksheet_rec.name;
        g_chart_of_accounts_id := c_worksheet_rec.chart_of_accounts_id;
        g_currency_code        := c_worksheet_rec.currency_code;
        g_budgetary_control
          := c_worksheet_rec.enable_budgetary_control_flag;
        g_average_balances
          := c_worksheet_rec.enable_average_balances_flag;
        g_gl_calendar          := c_worksheet_rec.period_set_name;
      END LOOP;
    END;
  -- Bud 3029168 added the second clause p_event_type='SR'
  elsif p_event_type = 'BR' OR p_event_type = 'SR' then
    BEGIN
      FND_MESSAGE.SET_NAME('PSB', 'PSB_GL_BJR_BATCH_NAME');
      FND_MESSAGE.SET_TOKEN('BUDGET_REVISION_ID', p_source_id);
      g_batch_name := FND_MESSAGE.Get;

      FND_MESSAGE.SET_NAME('PSB', 'PSB_GL_BJR_BATCH_DESC');
      FND_MESSAGE.SET_TOKEN('BUDGET_REVISION_ID', p_source_id);
      g_batch_description := FND_MESSAGE.Get;

      FND_MESSAGE.SET_NAME('PSB', 'PSB_GL_BJR_JE_NAME');
      FND_MESSAGE.SET_TOKEN('BUDGET_REVISION_ID', p_source_id);
      g_je_name := FND_MESSAGE.Get;

      FND_MESSAGE.SET_NAME('PSB', 'PSB_GL_BJR_JE_DESC');
      FND_MESSAGE.SET_TOKEN('BUDGET_REVISION_ID', p_source_id);
      g_je_description := FND_MESSAGE.Get;

      -- Get Auto Offset value FROM a profile option
      FND_PROFILE.GET
      (name => 'PSB_REVISION_AUTO_OFFSET',
       val => g_offset_revision
      );

      FOR c_revision_rec IN c_revision LOOP
        g_budget_by_position   := c_revision_rec.revise_by_position;
        g_set_of_books_id      := c_revision_rec.set_of_books_id;
        g_permanent_revision   := c_revision_rec.permanent_revision;
        g_budget_set_id        := c_revision_rec.gl_budget_set_id;
        g_revision_type        := c_revision_rec.budget_revision_type;
        g_set_of_books_name    := c_revision_rec.name;
        g_chart_of_accounts_id := c_revision_rec.chart_of_accounts_id;
        g_currency_code        := c_revision_rec.currency_code;
        g_budgetary_control    := c_revision_rec.enable_budgetary_control_flag;
        g_average_balances     := c_revision_rec.enable_average_balances_flag;
        g_gl_calendar          := c_revision_rec.period_set_name;
      END LOOP;
    END;
  END IF;

  IF NOT FND_FLEX_APIS.Get_Qualifier_Segnum
         (appl_id          => 101,
          key_flex_code    => 'GL#',
          structure_number => g_chart_of_accounts_id,
          flex_qual_name   => 'GL_BALANCING',
          segment_number   => l_seg_num
         )
  THEN
    Add_Message('PSB', 'PSB_GL_CANNOT_FIND_BAL_SEG');
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF NOT FND_FLEX_APIS.Get_Segment_Info
        (x_application_id => 101,
         x_id_flex_code   => 'GL#',
         x_id_flex_num    => g_chart_of_accounts_id,
         x_seg_num        => l_seg_num,
         x_appcol_name    => g_fund_segment,
         x_seg_name       => l_seg_name,
         x_prompt         => l_prompt,
         x_value_set_name => l_value_set
        )
  THEN
    FND_MSG_PUB.Add;
    Add_Message('PSB', 'PSB_GL_CANNOT_GET_SEG_INFO');
  END IF;

  g_num_segs := 0;

  FOR c_Seginfo_Rec IN c_seginfo LOOP
    g_num_segs             := g_num_segs + 1;
    g_seg_name(g_num_segs) := c_Seginfo_Rec.application_column_name;
  END LOOP;

  IF p_auto_offset = 'Y' THEN
    BEGIN
      Get_Offset_Account
      (x_return_status => l_return_status,
       p_templ_acct    => 'Y',
       p_fund          => NULL,
       p_templ_seg     => g_templ_seg_val,
       p_ccid          => l_templ_ccid
      );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
     END;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Initialize;

/* ----------------------------------------------------------------------- */
/*FOR Bug No : 2543724 Start*/
--Removed the following two parameters FROM this procedure as they are unused
--p_next_period           OUT  NOCOPY VARCHAR2,
--p_reversal_date         OUT  NOCOPY DATE,
/*FOR Bug No : 2543724 END*/

PROCEDURE Get_GL_Period
(x_return_status         OUT NOCOPY VARCHAR2,
 p_start_date                       DATE,
 x_effective_period_num  OUT NOCOPY NUMBER,
 x_period_name           OUT NOCOPY VARCHAR2,
 x_period_start_date     OUT NOCOPY DATE,
 x_period_end_date       OUT NOCOPY DATE,
 x_period_status         OUT NOCOPY VARCHAR2,
 x_period_year           OUT NOCOPY NUMBER,
 x_period_number         OUT NOCOPY NUMBER,
 x_quarter_number        OUT NOCOPY NUMBER
)
IS

  l_period_found BOOLEAN := FALSE;

  CURSOR c_period
  IS
  SELECT period_name,
         effective_period_num,
         start_date,
         end_date,
         closing_status,
         period_year,
         period_num,
         quarter_num
  FROM GL_PERIOD_STATUSES
  WHERE application_id = 101
  AND set_of_books_id = g_set_of_books_id
  AND NVL(adjustment_period_flag, 'N') = 'N'
  AND p_start_date BETWEEN start_date AND end_date
  ORDER BY period_num; -- Bug 3029168

  /*FOR Bug No : 2543724 Start*/
  --commented the following CURSOR as it's NOT being used
  /*
  CURSOR c_next_period IS
    SELECT period_name, start_date
      FROM gl_period_statuses
     WHERE application_id  = 101
       AND set_of_books_id = g_set_of_books_id
       AND NVL(adjustment_period_flag,'N') = 'N'
       AND p_period_end_date+1 BETWEEN start_date AND end_date;
  */
  /*FOR Bug No : 2543724 END*/

BEGIN
  FOR c_period_rec IN c_period LOOP
    l_period_found := TRUE;

    x_period_name          := c_period_rec.period_name;
    x_effective_period_num := c_period_rec.effective_period_num;
    x_period_start_date    := c_period_rec.start_date;
    x_period_end_date      := c_period_rec.end_date;
    x_period_status        := c_period_rec.closing_status;
    x_period_year          := c_period_rec.period_year;    -- Bug#4310411
    x_period_number        := c_period_rec.period_num;     -- Bug#4310411
    x_quarter_number       := c_period_rec.quarter_num;    -- Bug#4310411
  END LOOP;

  IF NOT l_period_found THEN
    Add_Message('PSB', 'PSB_GL_PRD_NOT_FOUND');
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /*FOR Bug No : 2543724 Start*/
  --We need NOT to validate against GL periods as
  --Budget Journal doesn't require Gl periods to be opened
  --hence commenting the following code

  /*
  IF p_period_status = 'N' THEN
    Message_Token('PERIOD_NAME', p_period_name);
    Add_Message('PSB', 'PSB_GL_PRD_NEVER_OPENED');
    RAISE FND_API.G_EXC_ERROR;
  ELSIF p_period_status IN ('P', 'C') THEN
    Message_Token('PERIOD_NAME', p_period_name);
    Add_Message('PSB', 'PSB_GL_PRD_CLOSED');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --commented the following code as this IS NOT being used
  FOR c_next_period_rec IN c_next_period LOOP
    p_next_period := c_next_period_rec.period_name;
    p_reversal_date := c_next_period_rec.start_date;
  END LOOP;
  */

  /*FOR Bug No : 2543724 END*/

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Get_GL_Period;

/* ----------------------------------------------------------------------- */
/*FOR Bug No : 2712019 Start*/
--Following procedure will determine IF there are any GL Budgets, FOR which
--the latest OPEN year IS NOT matching with the year we are trying to post FROM PSB

PROCEDURE Validate_GL_Budget_Year
(x_return_status    OUT NOCOPY VARCHAR2,
 p_gl_budget_set_id IN         NUMBER,
 p_year_start_date  IN         DATE,
 p_year_end_date    IN         DATE
)
IS
  --
  l_period_year NUMBER(15);
  l_open_flag   VARCHAR2(1);
  l_error_flag  BOOLEAN := FALSE;
  l_budget_name VARCHAR2(15);
  --
  CURSOR c_period
  IS
  SELECT period_year
  FROM GL_PERIOD_STATUSES
  WHERE application_id = 101
  AND set_of_books_id = g_set_of_books_id
  AND p_year_end_date BETWEEN start_date AND end_date;

  CURSOR c_budver
  IS
  SELECT gl_budget_version_id
  FROM PSB_GL_BUDGETS
  WHERE gl_budget_set_id = p_gl_budget_set_id
  AND p_year_start_date BETWEEN start_date AND end_date;

  CURSOR c_bud_name(gl_budver_id NUMBER)
  IS
  SELECT budget_name
  FROM gl_budget_versions
  WHERE budget_version_id = gl_budver_id;
  --
BEGIN
  --
  --FETCH the GL accounting year FOR the correponding
  --year END GL posting DATE IN the given set of books
  FOR c_period_rec IN c_period LOOP
    l_period_year := c_period_rec.period_year;
  END LOOP;
  --
  --Validate the GL Budget year FOR all the GL Budget versions
  --available IN PSB GL Budget Set
  FOR c_budver_rec IN c_budver LOOP
    --
    --Following GL API returns the OPEN flag FOR the given accounting year
    --AND the details are stored IN gl_budget_period_ranges table
    GL_Budget_Period_Ranges_Pkg.Get_Open_Flag
    (x_budget_version_id  => c_budver_rec.gl_budget_version_id,
     x_period_year        => l_period_year,
     x_open_flag          => l_open_flag
    );
    --
    --Throw an error IF the corresponding year IS NOT OPEN FOR the GL Budget
    IF NVL(l_open_flag,'X') <> 'O' THEN
      --
      --FETCH the GL Budget name FROM the CURSOR before throwing an error
      FOR c_bud_name_rec IN c_bud_name(c_budver_rec.gl_budget_version_id) LOOP
        l_budget_name := c_bud_name_rec.budget_name;
      END LOOP;
      --
      Message_Token('YEAR', l_period_year);
      Message_Token('GLBUDGET', l_budget_name);
      Add_Message('PSB', 'PSB_GL_BUDGET_YEAR_NOT_OPENED');
      l_error_flag  := TRUE;
      l_budget_name := NULL;
      --
    END IF;
    --
    l_open_flag := NULL;
  END LOOP;
  --
  IF l_error_flag THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  ELSE
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  END IF;
  --
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Validate_GL_Budget_Year;
/*FOR Bug No : 2712019 END*/
/* ----------------------------------------------------------------------- */

PROCEDURE Submit_Concurrent_Request
(x_return_status    OUT NOCOPY VARCHAR2,
 p_source_id                   NUMBER,
 p_event_type                  VARCHAR2,
 p_order_by1                   VARCHAR2,
 p_order_by2                   VARCHAR2,
 p_order_by3                   VARCHAR2,
 p_gl_budget_set_id            NUMBER,
 p_budget_year_id              NUMBER,
 p_currency_code               VARCHAR2 DEFAULT 'C'  -- Bug 3029168
 )
 IS

   l_req_id        NUMBER;
   l_return_status VARCHAR2(10);

BEGIN
  --
  -- Starting the concurrent program
  --
  l_req_id := FND_REQUEST.SUBMIT_REQUEST
              (application => 'PSB',
               program     => 'PSBOTGLR',
               description => 'Budget Journal Edit Report',
               start_time  => NULL,
               sub_request => FALSE,
               argument1   => p_source_id,
               argument2   => p_currency_code,  -- Bug 3029168
               argument5   => p_order_by1,
               argument6   => p_order_by2,
               argument7   => p_order_by3,
               argument4   => p_gl_budget_set_id,
               argument3   => p_budget_year_id
              );

   IF l_req_id = 0 THEN
     Add_Message('PSB', 'PSB_FAIL_TO_SUBMIT_REQUEST');
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Submit_Concurrent_Request;

/* ----------------------------------------------------------------------- */
PROCEDURE Insert_Lines_Into_BCP
(x_return_status OUT NOCOPY VARCHAR2,
 p_worksheet_id  IN         NUMBER,
 p_called_from   IN         VARCHAR2,
 p_period_name   IN         VARCHAR2 DEFAULT NULL,
 p_packetid      IN         NUMBER   DEFAULT NULL
)
IS

  l_api_name       CONSTANT VARCHAR2(30) := 'Insert_Lines_Into_BCP';
  l_api_version    CONSTANT NUMBER       := 1.0;

  l_period_name   VARCHAR2(15);
  l_packetid      GL_bc_packets.packet_id%TYPE;
  l_return_status VARCHAR2(10);
  l_session_id     number(38);
  l_serial_id     number(38);

  CURSOR l_packet_csr
  IS
  SELECT gl_bc_packets_s.nextval
  FROM dual;
   PRAGMA autonomous_transaction;

  /* 5148282 made this api as autonomous transaction
     as funds check runs as a separate transaction */
BEGIN

  SELECT s.sid, s.serial#
    INTO l_session_id,
         l_serial_id
    FROM v$session s,v$process p
   WHERE s.paddr = p.addr
     AND audsid = USERENV('SESSIONID');


 /*bug:5357711:Removed the condition budget_version_flag = 'P' in select query*/
    INSERT INTO gl_bc_packets
    (packet_id,
     ledger_id, -- Bug#4310411
     je_source_name,
     je_category_name,
     code_combination_id,
     actual_flag,
     period_name,
     period_year,
     period_num,
     quarter_num,
     currency_code,
     status_code,
     last_update_date,
     last_updated_by,
     budget_version_id,
     entered_dr,
     entered_cr,
     accounted_dr,
     accounted_cr,
     reference1,
     reference2,
     reference3,
     reference4,
     reference5,
     application_id, -- Bug 4589283 added the below columns
     session_id,
     serial_id
    )
    SELECT P_packetid,
           set_of_books_id,
           user_je_source_name,
           user_je_category_name,
           code_combination_id,
           actual_flag,
           period_name,
           period_year,
           period_num,
           quarter_num,
           currency_code,
           'P',
           date_created,
           created_by,
           budget_version_id,
           entered_dr,
           entered_cr,
           entered_dr,
           entered_cr,
           reference1,
           reference2,
           reference3,
           reference4,
           reference5,
           8401,
           l_session_id,
           l_serial_id
    FROM psb_gl_interfaces
    WHERE worksheet_id = p_worksheet_id
    AND period_name = p_period_name
    AND NVL(budget_source_type, 'BP') = g_budget_source_type
    AND gl_transfer_flag is null;  --bug:7639620

    /*bug:7639620:start*/
    update psb_gl_interfaces
    set    gl_transfer_flag = 'Y'
    where  worksheet_id = p_worksheet_id
    and    period_name = p_period_name
    and    NVL(budget_source_type, 'BP') = g_budget_source_type
    and    gl_transfer_flag is null;
    /*bug:7639620:end*/

  COMMIT;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


   WHEN OTHERS THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
     END IF;

END Insert_Lines_Into_BCP;

/* ----------------------------------------------------------------------- */

PROCEDURE Insert_Lines_Into_GL_I
(x_return_status OUT NOCOPY VARCHAR2,
 p_worksheet_id  IN         NUMBER
)
IS

  l_api_name    CONSTANT VARCHAR2(30) := 'Insert_Lines_Into_GL_I';
  l_api_version CONSTANT NUMBER       := 1.0;

BEGIN

  SAVEPOINT Insert_Lines_Into_GL_I;

  INSERT INTO gl_interface
  (group_id,
   status,
   ledger_id, -- Bug#4310411
   user_je_source_name,
   user_je_category_name,
   currency_code,
   date_created,
   created_by,
   actual_flag,
   budget_version_id,
   accounting_date,
   period_name,
   code_combination_id,
   entered_dr,
   entered_cr,
   reference1,
   reference2,
   reference4,
   reference5
  )
  SELECT group_id,
         status,
         set_of_books_id,
         user_je_source_name,
         user_je_category_name,
         currency_code,
         date_created,
         created_by,
         actual_flag,
         budget_version_id,
         accounting_date,
         period_name,
         code_combination_id,
         entered_dr,
         entered_cr,
         reference1,
         reference2,
         reference4,
         reference5
  FROM psb_gl_interfaces
  WHERE worksheet_id = p_worksheet_id
  AND NVL(budget_source_type,'BP') = g_budget_source_type
  AND gl_transfer_flag is null;  --bug:7639620

    /*bug:7639620:start*/
    update psb_gl_interfaces
    set    gl_transfer_flag = 'Y'
    where  worksheet_id = p_worksheet_id
    and    NVL(budget_source_type, 'BP') = g_budget_source_type
    and    gl_transfer_flag is null;
    /*bug:7639620:end*/

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Insert_Lines_Into_GL_I;
     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Insert_Lines_Into_GL_I;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
     ROLLBACK TO Insert_Lines_Into_GL_I;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
     END IF;

END Insert_Lines_Into_GL_I;

/* ----------------------------------------------------------------------- */
PROCEDURE Insert_Lines_To_GL
(x_return_status  OUT NOCOPY VARCHAR2,
 p_source_id      IN         NUMBER,
 p_called_from    IN         VARCHAR2,
 p_event_type     IN         VARCHAR2 DEFAULT NULL
)
IS

  l_api_name      CONSTANT VARCHAR2(30) := 'Insert_Lines_To_GL';
  l_api_version   CONSTANT NUMBER       := 1.0;
  l_return_status          VARCHAR2(10);

  l_req_id                    NUMBER;
  l_group_id                  NUMBER;
  l_interface_run_id          NUMBER;
  /* Bug 3029168 Start */
  l_max_period                NUMBER;
  l_min_period                NUMBER;
  l_max_period_name           VARCHAR2(15);
  l_min_period_name           VARCHAR2(15);
  /* Bug 3029168 End */
  l_iso_language              VARCHAR2(2);
  l_iso_territory             VARCHAR2(2);
  l_template_code             VARCHAR2(100);
  l_layout                    BOOLEAN;

  l_period_name   VARCHAR2(15);

CURSOR l_ws_period_csr
  IS
  SELECT DISTINCT period_name
  FROM psb_gl_interfaces
  WHERE worksheet_id = p_source_id
  AND NVL(budget_source_type,'BP') = g_budget_source_type;


CURSOR l_packet_csr
  IS
  SELECT gl_bc_packets_s.nextval
  FROM dual;

  l_packetid      GL_bc_packets.packet_id%TYPE;

BEGIN

  IF g_budgetary_control = 'Y' THEN
    -- FOR GL_BC_PACKATES route.

    -- the following code insert the data in GL_BC_PACKETS
    -- and calls the funds checker in reserve mode
    commit; -- this has to be there before calling the autonomous commit
    IF p_called_from = 'C' THEN

    -- Bug 3029168 Start.  code to find period names
    SELECT MAX(period_num),MIN(PERIOD_NUM)
      INTO l_max_period,
           l_min_period
      FROM psb_gl_interfaces
     WHERE budget_source_type = p_event_type
       AND budget_year_id     = g_budget_year_id
       AND worksheet_id       = p_source_id;


    SELECT period_name
      INTO l_max_period_name
      FROM psb_gl_interfaces
     WHERE period_num         = l_max_period
       AND budget_source_type = p_event_type
       AND budget_year_id     = g_budget_year_id
       AND worksheet_id       = p_source_id
       AND rownum             = 1;

    SELECT period_name
      INTO l_min_period_name
      FROM psb_gl_interfaces
     WHERE period_num         = l_min_period
       AND budget_source_type = p_event_type
       AND budget_year_id     = g_budget_year_id
       AND worksheet_id       = p_source_id
       AND rownum             = 1;
     -- Bug 3029168 End

  /* Bug 5148282 moved the following logic from Insert_Lines_Into_BCP
     as inserts into gl_bc_packets is done as autonomous transaction */
  OPEN l_ws_period_csr;
  LOOP

    FETCH l_ws_period_csr INTO l_period_name;
    IF l_ws_period_csr%notfound THEN
      EXIT;
    END IF;

    OPEN l_packet_csr;
      FETCH l_packet_csr INTO l_packetid;
    CLOSE l_packet_csr;

      Insert_Lines_Into_BCP
      (x_return_status => l_return_status,
       p_worksheet_id  => p_source_id,
       p_called_from   => p_called_from,
       p_period_name   => l_period_name,
       p_packetid      => l_packetid
      );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    IF NOT PSA_FUNDS_CHECKER_PKG.GLXFCK
           (p_ledgerid    => g_set_of_books_id,
            p_packetid    => l_packetid,
            p_mode        => 'P',  -- partial reserve
            p_conc_flag   => 'N',
            p_return_code => l_return_status,
            p_calling_prog_flag => 'P' -- Bug 4589283

           )
    -- Bug#4310411 End
    THEN
      -- Fundscheck Failed --
      Message_Token('GL_PERIOD', l_period_name);
      Add_Message('PSB', 'PSB_FAIL_FUNDS_CHECK');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END LOOP;
      --
      -- Starting the concurrent program
      --
   /* Bug 4589283 Start */
   l_template_code := fnd_profile.value('PSA_BC_REPORT_TEMPLATE');

      SELECT iso_language,iso_territory
        INTO l_iso_language,l_iso_territory
        FROM fnd_languages
       WHERE language_code = userenv('LANG');

      l_layout := FND_REQUEST.ADD_LAYOUT
                     (TEMPLATE_APPL_NAME => 'PSA',
                      TEMPLATE_CODE      => l_template_code,
                      TEMPLATE_LANGUAGE  => l_iso_language,
                      TEMPLATE_TERRITORY => l_iso_territory,
                      OUTPUT_FORMAT      => 'PDF');

      /* Bug 4589283 End */

     /*Bug:6502210:Modified/Added the parameters - 'argument4,argument5 .. argument9'
       for the program call - PSABCRRP */

      l_req_id := FND_REQUEST.SUBMIT_REQUEST
                  (application => 'PSA',
                   program     => 'PSABCRRP',
                   description => 'Budgetary Control Results Report',
                   start_time  => NULL,
                   sub_request => FALSE,
                   argument1   => to_char(g_set_of_books_id),
                   argument2   => l_min_period_name, --PSA_BC_GL_PERIOD_FROM,
                   argument3   => l_max_period_name, --PSA_BC_GL_PERIOD_TO
                   argument4   => NULL,
                   argument5   => NULL,
                   argument6   => NULL,
		   argument7   => 'PSB',
		   argument8   => NULL,
		   argument9   => NULL
                  );

      IF l_req_id = 0 THEN
        Add_Message('PSB', 'PSB_FAIL_TO_SUBMIT_REQUEST');
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    -- Bug 5148554 the following code handles funds checking
    -- in funds reservation mode for a revision
    ELSIF p_called_from = 'R' THEN

      OPEN l_ws_period_csr;
      LOOP

        FETCH l_ws_period_csr INTO l_period_name;
        IF l_ws_period_csr%notfound THEN
          EXIT;
        END IF;

      OPEN l_packet_csr;
      FETCH l_packet_csr INTO l_packetid;
      CLOSE l_packet_csr;

      Insert_Lines_Into_BCP
      (x_return_status => l_return_status,
       p_worksheet_id  => p_source_id,
       p_called_from   => p_called_from,
       p_period_name   => l_period_name,
       p_packetid      => l_packetid
      );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    IF NOT PSA_FUNDS_CHECKER_PKG.GLXFCK
           (p_ledgerid    => g_set_of_books_id,
            p_packetid    => l_packetid,
            p_mode        => 'R',
            p_conc_flag   => 'N',
            p_return_code => l_return_status,
            p_calling_prog_flag => 'P' -- Bug 4589283

           )
    THEN
      -- Fundscheck Failed --
      Message_Token('GL_PERIOD', l_period_name);
      Add_Message('PSB', 'PSB_FAIL_FUNDS_CHECK');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    END LOOP;

    END IF;

  ELSE
    -- FOR GL_INTERFACE route.
    Insert_Lines_Into_GL_I
    (x_return_status => l_return_status,
     p_worksheet_id  => p_source_id
    );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Now spawn the "GLLEZL" CP to create the journel to GL.
    SELECT gl_interface_control_s.NEXTVAL,
           gl_journal_import_s.NEXTVAL
    INTO l_group_id,
         l_interface_run_id
    FROM dual;

    INSERT INTO gl_interface_control
    (JE_SOURCE_NAME,
     STATUS,
     INTERFACE_RUN_ID,
     GROUP_ID,
     SET_OF_BOOKS_ID,
     PACKET_ID
    )
    VALUES
    (g_source_name,
     'S',
     l_interface_run_id,
     p_source_id,
     g_set_of_books_id,
     ''
    );

    l_req_id := FND_Request.Submit_Request
                ('SQLGL',            -- application short name
                 'GLLEZL',          -- program short name
                 NULL,               -- program name
                 NULL,               -- start DATE
                 FALSE,              -- sub-request
                 l_interface_run_id, -- interface run id
                 g_set_of_books_id,  -- set of books id
                 'N',                -- error to suspense flag
                 NULL,               -- FROM accounting DATE
                 NULL,               -- to accounting DATE
                 'N',                -- create summary(Default value N)
                 'N'                 -- import desc flex flag
                );

   IF l_req_id = 0 THEN
     Add_Message('PSB', 'PSB_FAIL_TO_SUBMIT_REQUEST');
     RAISE FND_API.G_EXC_ERROR;
   END IF;
 END IF;

 x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
    END IF;

END Insert_Lines_To_GL;

/* ----------------------------------------------------------------------- */

-- commenting out the savepoints FOR XLA transfer since the XLA transfer
-- program commits within the process AND this erases the savepoints established

PROCEDURE Transfer_GLI_To_GL
(p_return_status  OUT  NOCOPY  VARCHAR2,
 p_msg_count      OUT  NOCOPY  NUMBER,
 p_msg_data       OUT  NOCOPY  VARCHAR2,
 p_init_msg_list       VARCHAR2 := FND_API.G_FALSE,
 p_event_type          VARCHAR2,
 p_source_id           NUMBER,
 p_gl_transfer_mode    VARCHAR2 := NULL,
 p_order_by1           VARCHAR2,
 p_order_by2           VARCHAR2,
 p_order_by3           VARCHAR2
)
 IS

  l_return_status              VARCHAR2(1);
  l_msg_count                  NUMBER;
  l_msg_data                   VARCHAR2(2000);
  l_budget_revision_type       VARCHAR2(1);

  l_cbc_document               BOOLEAN := FALSE;
  l_include_cbc_commit_balance VARCHAR2(1);
  l_include_cbc_oblig_balance  VARCHAR2(1);
  l_include_cbc_budget_balance VARCHAR2(1);

  CURSOR c_rev_type
  IS
  SELECT budget_revision_type
  FROM psb_budget_revisions
  WHERE budget_revision_id = p_source_id;

  CURSOR c_ws
  IS
  SELECT include_cbc_commit_balance,
         include_cbc_oblig_balance,
         include_cbc_budget_balance
  FROM psb_worksheets
  WHERE worksheet_id = p_source_id;

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT Transfer_GLI_To_GL;

  -- Initialize message list IF p_init_msg_list IS set to TRUE.
  IF FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  Initialize
  (x_return_status => l_return_status,
   p_event_type    => p_event_type,  -- Bug 3029168
   p_source_id     => p_source_id,
   p_auto_offset   => 'N'
  );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Bug 3029168 added the clause p_event_type = 'SW'
  if p_event_type = 'BP' OR p_event_type = 'SW' then -- Bug 3029168
    BEGIN
      FOR c_ws_rec IN c_ws LOOP
        l_include_cbc_commit_balance := c_ws_rec.include_cbc_commit_balance;
        l_include_cbc_oblig_balance  := c_ws_rec.include_cbc_oblig_balance;
        l_include_cbc_budget_balance := c_ws_rec.include_cbc_budget_balance;
      END LOOP;

    IF (NVL(l_include_cbc_commit_balance,'N') = 'Y'
       OR
       NVL(l_include_cbc_oblig_balance,'N') = 'Y'
       OR
       NVL(l_include_cbc_budget_balance, 'N') = 'Y')
       AND p_event_type <> 'SW'  -- Bug 3029168 added STAT join
    THEN
      BEGIN
        l_cbc_document := TRUE;

        PSB_COMMITMENTS_PVT.Post_Commitment_Worksheet
        (p_api_version   => 1.0,
         p_return_status => l_return_status,
         p_msg_data      => l_msg_data,
         p_msg_count     => l_msg_count,
         p_worksheet_id  => p_source_id
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          Message_Token('WORKSHEET', p_source_id);
          Add_Message('PSB', 'PSB_CANNOT_POST_COMMITMENT_WS');
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END;
    ELSE
      BEGIN
          -- Bug#4310411 Start
          -- Replace XLA with Old call.
          Insert_Lines_To_GL
          (x_return_status => l_return_status,
           p_source_id     => p_source_id,
           p_called_from   => 'T',
           p_event_type    => p_event_type  -- Bug 3029168
          );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;
          -- Bug#4310411 End
        END;
      END IF;

      -- Initial posting of budget to revisions
      PSB_BUDGET_REVISIONS_PVT.Create_Base_Budget_Revision
      (p_api_version   => 1.0,
       p_return_status => l_return_status,
       p_msg_count     => p_msg_count,
       p_msg_data      => p_msg_data,
       p_worksheet_id  => p_source_id,
       p_event_type    => p_event_type -- Bug 3029168
      );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END;
  -- Bug 3029168 added the clause p_event_type = 'SR'
  elsif p_event_type = 'BR' OR p_event_type = 'SR' then
    BEGIN
      FOR c_rev_type_rec IN c_rev_type LOOP
        l_budget_revision_type := c_rev_type_rec.budget_revision_type;
      END LOOP;

      IF l_budget_revision_type = 'C'
      AND p_event_type <> 'SR' THEN  -- Bug 3029168
        BEGIN
          l_cbc_document := TRUE;

          PSB_COMMITMENTS_PVT.Post_Commitment_Revisions
          (p_api_version        => 1.0,
           p_return_status      => l_return_status,
           p_msg_data           => l_msg_data,
           p_msg_count          => l_msg_count,
           p_budget_revision_id => p_source_id
          );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            Message_Token('BUDGET_REVISION', p_source_id);
            Add_Message('PSB', 'PSB_CANNOT_POST_COMMITMENT_REV');
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END;
      ELSE
        BEGIN
          -- Bug#4310411 Start
          -- Replace XLA with Old call.
          Insert_Lines_To_GL
          (x_return_status => l_return_status,
           p_source_id     => p_source_id,
           p_called_from   => 'T',
           p_event_type    => p_event_type  -- Bug 3029168
          );
          -- Bug#4310411 End

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END;
      END IF;
    END;
  END IF;

  -- Initialize API RETURN status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Transfer_GLI_To_GL;
     p_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Transfer_GLI_To_GL;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
     ROLLBACK TO Transfer_GLI_To_GL;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Transfer_GLI_To_GL;

/*---------------------------------------------------------------------*/

-- Wrapper routine FOR FND_FLEX_APIS. The reason FOR this IS procedure
-- IS to be called FROM PSBSTGLS.fmb (Setup GL Interfaces) form.
-- Call the fnd_flex_apis directly causes a GPF AND I suspect it IS
-- due to the 64 K size limit

PROCEDURE Get_Qualifier_Segnum
(p_api_version          IN         NUMBER,
 p_init_msg_list        IN         VARCHAR2 := FND_API.G_FALSE,
 p_commit               IN         VARCHAR2 := FND_API.G_FALSE,
 p_validation_level     IN         NUMBER   := FND_API.G_VALID_LEVEL_FULL,
 p_return_status        OUT NOCOPY VARCHAR2,
 p_msg_count            OUT NOCOPY NUMBER,
 p_msg_data             OUT NOCOPY VARCHAR2,
  --
 p_chart_of_accounts_id IN         NUMBER,
 p_segment_number       OUT NOCOPY NUMBER
) IS

  l_api_name    CONSTANT VARCHAR2(30) := 'Get_Qualifier_Segnum';
  l_api_version CONSTANT NUMBER       := 1.0;

  l_seg_num     NUMBER;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT Get_Qualifier_Segnum;

  -- Standard call to check FOR call compatibility.
  IF NOT FND_API.Compatible_API_Call
         (l_api_version,
          p_api_version,
          l_api_name,
          G_PKG_NAME
         )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list IF p_init_msg_list IS set to TRUE.
  IF FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_FLEX_APIS.Get_Qualifier_Segnum
         (appl_id                 => 101,
          key_flex_code           => 'GL#',
          structure_number        => p_chart_of_accounts_id,
          flex_qual_name          => 'GL_BALANCING',
          segment_number          => l_seg_num
         )
  THEN
    Add_Message('PSB', 'PSB_GL_CANNOT_FIND_BAL_SEG');
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

  p_segment_number := l_seg_num ;

  -- Initialize API RETURN status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Get_Qualifier_Segnum ;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Get_Qualifier_Segnum ;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO Get_Qualifier_Segnum ;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

END Get_Qualifier_Segnum;

/* ----------------------------------------------------------------------- */

PROCEDURE Position_Name
(p_position_line_id IN         NUMBER,
 x_reference2       OUT NOCOPY VARCHAR2,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_count        OUT NOCOPY NUMBER,
 x_msg_data         OUT NOCOPY VARCHAR2
)
IS

  l_api_name    CONSTANT VARCHAR2(30) := 'Position_Name';
  l_api_version CONSTANT NUMBER       := 1.0;


  CURSOR c_posname
  IS
  SELECT psb_pos.name
  FROM PSB_WS_POSITION_LINES pos_lines,
       PSB_POSITIONS psb_pos
  WHERE pos_lines.position_line_id = p_position_line_id
  AND psb_pos.position_id = pos_lines.position_id;

BEGIN

  IF p_position_line_id IS NULL THEN
    x_reference2   := g_je_description;
  ELSE
    FOR c_posname_rec IN c_posname LOOP
      x_reference2 := c_posname_rec.name;
    END LOOP;
  END IF;

  -- Initialize API RETURN status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                p_data  => x_msg_data);

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                               p_data  => x_msg_data);

END Position_Name;

/*---------------------------------------------------------------------------*/

PROCEDURE Insert_Lines_Into_PSB_I_Fund
(x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_count        OUT NOCOPY NUMBER,
 x_msg_data         OUT NOCOPY VARCHAR2,
 p_worksheet_id     IN         NUMBER,
 p_gl_budget_set_id IN         NUMBER,
 p_stage_seq        IN         NUMBER,
 p_year_id          IN         NUMBER,
 p_column           IN         NUMBER,
 p_gl_period        IN         VARCHAR2,
 p_gl_period_start  IN         DATE,
 p_gl_year          IN         VARCHAR2,
 p_period_num       IN         NUMBER,
 p_quarter_num      IN         NUMBER,
 p_je_source        IN         VARCHAR2,
 p_je_category      IN         VARCHAR2,
 p_budget_stage_id  IN         NUMBER,
 p_budget_year_id   IN         NUMBER,
 p_detailed         IN         VARCHAR2,
 p_event_type       IN         VARCHAR2 DEFAULT 'BP'
)
IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Lines_Into_PSB_I_Fund';
  l_api_version         CONSTANT NUMBER       := 1.0;

  l_batch_name                   VARCHAR2(100);
  l_batch_description            VARCHAR2(100);
  l_je_name                      VARCHAR2(100);
  l_je_description               VARCHAR2(100);
  l_created_by                   NUMBER;
  --
  l_sql_bal                      VARCHAR2(4000);
  l_cur_bal                      INTEGER;
  l_num_bal                      INTEGER;
  --
  l_budget_version_id            NUMBER;
  l_code_combination_id          NUMBER;
  l_dr_amount                    NUMBER;
  l_cr_amount                    NUMBER;

  l_msg_count                    NUMBER;
  l_msg_data                     VARCHAR2(2000);
  l_count                        NUMBER := 0; -- delete this
  l_flex_mapping_set_id          NUMBER;
  l_budget_year_type_id          NUMBER;
  l_concat_segments              VARCHAR2(2000);
  l_budget_version_flag          VARCHAR2(1);
  l_ccid                         NUMBER;
  l_return_status                VARCHAR2(1);

  l_sum_count                    VARCHAR2(1);
  l_currency_code                VARCHAR2(15);

   l_reference2                  VARCHAR2(100);  -- Bug#4310411

  CURSOR c_detail
  IS
  SELECT a.code_combination_id,
         a.position_line_id,
	 a.account_line_id,
         DECODE(a.account_type,'L', NULL, 'O', NULL, 'R', NULL,
                DECODE(p_column, 0, NVL(a.ytd_amount, 0),
                                 1, NVL(a.period1_amount, 0),
                                 2, NVL(a.period2_amount, 0),
                                 3, NVL(a.period3_amount, 0),
                                 4, NVL(a.period4_amount, 0),
                                 5, NVL(a.period5_amount, 0),
                                 6, NVL(a.period6_amount, 0),
                                 7, NVL(a.period7_amount, 0),
                                 8, NVL(a.period8_amount, 0),
                                 9, NVL(a.period9_amount, 0),
                                 10, NVL(a.period10_amount, 0),
                                 11, NVL(a.period11_amount, 0),
                                 12, NVL(a.period12_amount, 0)
                      )
               ) dr_amount,
         DECODE(a.account_type, 'A', NULL, 'E', NULL,
                DECODE(p_column, 0, NVL(a.ytd_amount, 0),
                                 1, NVL(a.period1_amount, 0),
                                 2, NVL(a.period2_amount, 0),
                                 3, NVL(a.period3_amount, 0),
                                 4, NVL(a.period4_amount, 0),
                                 5, NVL(a.period5_amount, 0),
                                 6, NVL(a.period6_amount, 0),
                                 7, NVL(a.period7_amount, 0),
                                 8, NVL(a.period8_amount, 0),
                                 9, NVL(a.period9_amount, 0),
                                 10, NVL(a.period10_amount, 0),
                                 11, NVL(a.period11_amount, 0),
                                 12, NVL(a.period12_amount, 0)
                      )
               ) cr_amount,
         DECODE(p_column, 0,  NVL(ytd_amount, 0),
                            1,  NVL(period1_amount, 0),
                            2,  NVL(period2_amount, 0),
                            3,  NVL(period3_amount, 0),
                            4,  NVL(period4_amount, 0),
                            5,  NVL(period5_amount, 0),
                            6,  NVL(period6_amount, 0),
                            7,  NVL(period7_amount, 0),
                            8,  NVL(period8_amount, 0),
                            9,  NVL(period9_amount, 0),
                            10, NVL(period10_amount, 0),
                            11, NVL(period11_amount, 0),
                            12, NVL(period12_amount, 0)
               ) x_amount
  FROM psb_ws_account_lines a,
       psb_ws_lines b,
       psb_service_packages d
  WHERE a.budget_year_id = p_budget_year_id
  AND a.balance_type = 'E'
  AND a.template_id IS NULL
  AND p_stage_seq BETWEEN a.start_stage_seq AND a.current_stage_seq
  AND DECODE(p_column,0, NVL(a.ytd_amount,0),
                      1, NVL(a.period1_amount,0),
                      2, NVL(a.period2_amount, 0),
                      3, NVL(a.period3_amount, 0),
                      4, NVL(a.period4_amount, 0),
                      5, NVL(a.period5_amount, 0),
                      6, NVL(a.period6_amount, 0),
                      7, NVL(a.period7_amount, 0),
                      8, NVL(a.period8_amount, 0),
                      9, NVL(a.period9_amount, 0),
                      10,NVL(a.period10_amount,0),
                      11,NVL(a.period11_amount, 0),
                      12, NVL(a.period12_amount, 0)
            ) <> 0
  -- Bug 3029168 added the following join for STAT currency
  AND ((a.currency_code   <> 'STAT' AND p_event_type = 'BP') OR
       (a.currency_code    = 'STAT' AND p_event_type = 'SW'))
  AND b.worksheet_id       = p_worksheet_id
  AND b.account_line_id    = a.account_line_id
  AND d.service_package_id = a.service_package_id
  AND b.view_line_flag     = 'Y';

  CURSOR c_summary
  IS
  SELECT a.code_combination_id,
         SUM(DECODE(account_type, 'L', NULL, 'O', NULL, 'R', NULL,
                    DECODE(p_column, 0,  NVL(ytd_amount, 0),
                                     1,  NVL(period1_amount, 0),
                                     2,  NVL(period2_amount, 0),
                                     3,  NVL(period3_amount, 0),
                                     4,  NVL(period4_amount, 0),
                                     5,  NVL(period5_amount, 0),
                                     6,  NVL(period6_amount, 0),
                                     7,  NVL(period7_amount, 0),
                                     8,  NVL(period8_amount, 0),
                                     9,  NVL(period9_amount, 0),
                                     10, NVL(period10_amount, 0),
                                     11, NVL(period11_amount, 0),
                                     12, NVL(period12_amount, 0)
                          )
            )
            ) dr_amount ,
         SUM(DECODE(account_type, 'A', NULL, 'E', NULL,
                    DECODE(p_column, 0, NVL(ytd_amount, 0),
                                     1,  NVL(period1_amount, 0),
                                     2,  NVL(period2_amount, 0),
                                     3,  NVL(period3_amount, 0),
                                     4,  NVL(period4_amount, 0),
                                     5,  NVL(period5_amount, 0),
                                     6,  NVL(period6_amount, 0),
                                     7,  NVL(period7_amount, 0),
                                     8,  NVL(period8_amount, 0),
                                     9,  NVL(period9_amount, 0),
                                     10, NVL(period10_amount, 0),
                                     11, NVL(period11_amount, 0),
                                     12, NVL(period12_amount, 0)
                          )
                   )
            ) cr_amount,
         SUM(DECODE(p_column, 0,  NVL(ytd_amount, 0),
                              1,  NVL(period1_amount, 0),
                              2,  NVL(period2_amount, 0),
                              3,  NVL(period3_amount, 0),
                              4,  NVL(period4_amount, 0),
                              5,  NVL(period5_amount, 0),
                              6,  NVL(period6_amount, 0),
                              7,  NVL(period7_amount, 0),
                              8,  NVL(period8_amount, 0),
                              9,  NVL(period9_amount, 0),
                              10, NVL(period10_amount, 0),
                              11, NVL(period11_amount, 0),
                              12, NVL(period12_amount, 0)
                   )
            ) x_amount
  FROM psb_ws_account_lines a,
       psb_ws_lines b,
       psb_service_packages d
  WHERE a.budget_year_id = p_year_id
  AND a.balance_type = 'E'
  AND a.template_id IS NULL
  AND p_stage_seq BETWEEN a.start_stage_seq AND a.current_stage_seq
  AND DECODE(p_column,0, NVL(a.ytd_amount,0),
                      1, NVL(a.period1_amount,0),
                      2, NVL(a.period2_amount, 0),
                      3, NVL(a.period3_amount, 0),
                      4, NVL(a.period4_amount, 0),
                      5, NVL(a.period5_amount, 0),
                      6, NVL(a.period6_amount, 0),
                      7, NVL(a.period7_amount, 0),
                      8, NVL(a.period8_amount, 0),
                      9, NVL(a.period9_amount, 0),
                      10,NVL(a.period10_amount,0),
                      11,NVL(a.period11_amount, 0),
                      12, NVL(a.period12_amount, 0)
            ) <> 0
  -- Bug 3029168 added the following join for STAT currency
  AND ((a.currency_code   <> 'STAT' AND p_event_type = 'BP') OR
       (a.currency_code    = 'STAT' AND p_event_type = 'SW'))
  AND b.worksheet_id       = p_worksheet_id
  AND b.account_line_id    = a.account_line_id
  AND d.service_package_id = a.service_package_id
  AND b.view_line_flag     = 'Y'
  GROUP BY a.code_combination_id;

  CURSOR c_bgversion
  IS
  SELECT gl_budget_version_id
  FROM   psb_budget_accounts v,
         psb_set_relations vs,
         psb_gl_budgets    vgb
  WHERE vgb.gl_budget_set_id = p_gl_budget_set_id
  AND vgb.gl_budget_id           = vs.gl_budget_id
  AND v.code_combination_id      = l_code_combination_id
  AND vs.account_position_set_id = v.account_position_set_id
  AND p_gl_period_start
    BETWEEN vgb.start_date AND NVL(vgb.end_date, p_gl_period_start);

  CURSOR c_ws
  IS
  SELECT flex_mapping_set_id
  FROM psb_worksheets
  WHERE worksheet_id = p_worksheet_id;

  CURSOR c_type
  IS
  SELECT budget_year_type_id
  FROM psb_budget_periods
  WHERE budget_period_id = p_year_id;

BEGIN

  SAVEPOINT Insert_Lines_Into_PSB_I_Fund;

  l_created_by := fnd_global.user_id;

  FND_MESSAGE.SET_NAME('PSB', 'PSB_GL_BJE_BATCH_NAME');
  FND_MESSAGE.SET_TOKEN('WORKSHEET_ID', p_worksheet_id);
  l_batch_name        := FND_MESSAGE.Get;

  FND_MESSAGE.SET_NAME('PSB', 'PSB_GL_BJE_BATCH_DESC');
  FND_MESSAGE.SET_TOKEN('WORKSHEET_ID', p_worksheet_id);
  l_batch_description := FND_MESSAGE.Get;

  FND_MESSAGE.SET_NAME('PSB', 'PSB_GL_BJE_JE_NAME');
  FND_MESSAGE.SET_TOKEN('WORKSHEET_ID', p_worksheet_id);
  l_je_name := FND_MESSAGE.Get;

  FND_MESSAGE.SET_NAME('PSB', 'PSB_GL_BJE_JE_DESC');
  FND_MESSAGE.SET_TOKEN('WORKSHEET_ID', p_worksheet_id);
  l_je_description    := FND_MESSAGE.Get;

  /* Bug 3029168 Start */
  IF p_event_type = 'SW' THEN
    l_currency_code := 'STAT';
  ELSE
    l_currency_code := g_currency_code;
  END IF;
  /* Bug 3029168 End */


  --++ process CURSOR, THEN get mapped account AND corresponding funding budget
  --++
  FOR c_ws_rec IN c_ws LOOP
    l_flex_mapping_set_id := c_ws_rec.FLEX_MAPPING_SET_ID;
    g_flex_mapping_set_id := l_flex_mapping_set_id;
  END LOOP;

  FOR c_type_rec IN c_type LOOP
    l_budget_year_type_id := c_type_rec.budget_year_type_id;
    g_budget_year_type_id := l_budget_year_type_id;
  END LOOP;

  IF p_detailed = 'D' THEN
    -- ++ detail
    BEGIN

      FOR c_detail_rec IN c_detail LOOP
        IF g_flex_mapping_set_id IS NOT NULL THEN
          --++ flex mapping
          l_code_combination_id
            := PSB_Flex_Mapping_PVT.Get_Mapped_CCID
               (p_api_version              => '1.0',
                p_init_msg_list            => FND_API.G_FALSE,
                p_commit                   => FND_API.G_FALSE,
                p_validation_level         => FND_API.G_VALID_LEVEL_FULL,
                p_ccid                     => c_detail_rec.code_combination_id,
                p_budget_year_type_id      => l_budget_year_type_id,
                p_flexfield_mapping_set_id => l_flex_mapping_set_id ,
                p_mapping_mode             => 'GL_POSTING'
               );

          IF l_code_combination_id = 0 THEN
            l_code_combination_id := c_detail_rec.code_combination_id;
          END IF;
          l_ccid := l_code_combination_id;
        ELSE
          l_ccid := c_detail_rec.code_combination_id;
        END IF;

        -- Get the description of the current Pos_line_id.
        Position_Name
        (p_position_line_id => c_detail_rec.position_line_id,
         x_reference2       => l_reference2,
         x_return_status    => l_return_status,
         x_msg_count        => l_msg_count,
         x_msg_data         => l_msg_data
        );

        -- ++ FOR each detail_rec, process 2 times - one FOR Permanent AND another
        -- ++ FOR 'ALL' (IF all exists');
        FOR i IN 1 .. 2 LOOP
          -- ++ post to gl_interface FOR both permanent AND all
          IF i = 1 THEN
            l_budget_version_flag := 'P';
          ELSE
            l_budget_version_flag := 'A';
          END IF;

          IF i = 2 AND NOT FND_API.to_Boolean(g_post_to_all) THEN
            EXIT;
            -- ++ skip posting since there's no 'ALL' posting defined
          END IF;

          --++ get corresponding budget version id AND get out IF with error
          --++ use worksheet ccid
          PSB_GL_BUDGET_PVT.Find_GL_Budget
          (p_api_version          => 1.0,
           p_return_status        => l_return_status,
           p_msg_count            => l_msg_count,
           p_msg_data             => l_msg_data,
           p_gl_budget_set_id     => p_gl_budget_set_id,
           p_code_combination_id  => c_detail_rec.code_combination_id,
           p_start_date           => p_gl_period_start,
           p_dual_posting_type    => l_budget_version_flag,
           p_gl_budget_version_id => l_budget_version_id
          );

          IF l_budget_version_id IS NOT NULL THEN --bug:5357711

      /*Bug:7639620:start*/

       CHECK_POSTING_STATUS
       (
         p_return_status       => l_return_status,
         p_event_type          => p_event_type,
         p_source_id           => p_worksheet_id,
         p_period_name         => p_gl_period,
         p_budget_version_id   => l_budget_version_id,
         p_code_combination_id => l_ccid,
         p_budget_version_flag => l_budget_version_flag
       );

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;
     /*Bug:7639620:end*/

          --++
          --++ THEN INTO psb_gl_interfaces
          --++
          INSERT INTO psb_gl_interfaces
          (worksheet_id,
           group_id,
           status,
           set_of_books_id,
           user_je_source_name,
           user_je_category_name,
           currency_code,
           date_created,
           created_by,
           actual_flag,
           budget_version_id,
           accounting_date,
           period_name,
           period_year,
           period_num,
           quarter_num,
           code_combination_id,
           entered_dr,
           entered_cr,
           reference1,
           reference2,
           reference4,
           reference5,
           budget_stage_id,
           budget_year_id,
           je_type,
           amount,
           budget_source_type,
           budget_version_flag,
           balancing_entry_flag,
           gl_budget_set_id
          )
          VALUES
          (p_worksheet_id,
           p_worksheet_id ,
           'NEW',
           g_set_of_books_id ,
           p_je_source,
           p_je_category ,
           l_currency_code, -- Bug 3029168
           sysdate,
           l_created_by   ,
           'B',
           l_budget_version_id,
           p_gl_period_start,
           p_gl_period,
           p_gl_year,
           p_period_num ,
           p_quarter_num,
           l_ccid ,
           c_detail_rec.dr_amount,
           c_detail_rec.cr_amount,
           g_je_name,
           l_reference2,
           c_detail_rec.account_line_id,
	   NULL,
           p_budget_stage_id,
           p_budget_year_id ,
           p_detailed,
           c_detail_rec.x_amount,
           p_event_type ,  -- Bug 3029168
           l_budget_version_flag,
           'N',
           p_gl_budget_set_id
           );
          END IF;--bug:5357711
         END LOOP;   -- END of 2 loops FOR permanent AND temp FOR each record
       END LOOP;      -- END of detail rec processing
     END;

   --++ END detail
   ELSE
     --++ summary
     BEGIN

       FOR c_summary_rec IN c_summary LOOP
         IF g_flex_mapping_set_id IS NOT NULL THEN
           --++ get flex mapping
           l_code_combination_id
             := PSB_Flex_Mapping_PVT.Get_Mapped_CCID
                (
                 p_api_version              => '1.0',
                 p_init_msg_list            => FND_API.G_FALSE,
                 p_commit                   => FND_API.G_FALSE,
                 p_validation_level         => FND_API.G_VALID_LEVEL_FULL,
                 p_ccid                     => c_summary_rec.code_combination_id,
                 p_budget_year_type_id      =>l_budget_year_type_id,
                 p_flexfield_mapping_set_id => l_flex_mapping_set_id ,
                 p_mapping_mode             => 'GL_POSTING'
                );

           IF l_code_combination_id = 0 THEN
             l_code_combination_id := c_summary_rec.code_combination_id;
           END IF;

           l_ccid := l_code_combination_id;

         ELSE
           l_ccid := c_summary_rec.code_combination_id;
         END IF;

         FOR i IN 1 .. 2 LOOP
           -- ++ post to gl_interface FOR both permanent AND all FOR each record
           IF i = 1 THEN
             l_budget_version_flag := 'P';
           ELSE
             l_budget_version_flag := 'A';
           END IF;

           IF i = 2 AND NOT FND_API.to_Boolean(g_post_to_all)  THEN
             EXIT;
             -- ++ skip posting since there's no 'ALL' posting defined
           END IF;

           --++ get corresponding budget version id AND get out IF with error
           --++ use worksheet ccid
           PSB_GL_BUDGET_PVT.Find_GL_Budget
           (p_api_version          => 1.0,
            p_return_status        => l_return_status,
            p_msg_count            => l_msg_count,
            p_msg_data             => l_msg_data,
            p_gl_budget_set_id     => p_gl_budget_set_id,
            p_code_combination_id  => c_summary_rec.code_combination_id,
            p_start_date           => p_gl_period_start,
            p_dual_posting_type    => l_budget_version_flag,
            p_gl_budget_version_id => l_budget_version_id
           );

           IF l_budget_version_id IS NOT NULL THEN --bug:5357711

      /*Bug:7639620:start*/
        CHECK_POSTING_STATUS
        (
          p_return_status       => l_return_status,
          p_event_type          => p_event_type,
          p_source_id           => p_worksheet_id,
          p_period_name         => p_gl_period,
          p_budget_version_id   => l_budget_version_id,
          p_code_combination_id => l_ccid,
          p_budget_version_flag => l_budget_version_flag
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;
     /*Bug:7639620:end*/

           --++
           --++ THEN INTO psb_gl_interfaces
           --++
           INSERT INTO psb_gl_interfaces
           (worksheet_id,
            group_id,
            status,
            set_of_books_id,
            user_je_source_name,
            user_je_category_name,
            currency_code,
            date_created,
            created_by,
            actual_flag,
            budget_version_id,
            accounting_date,
            period_name,
            period_year,
            period_num,
            quarter_num,
            code_combination_id,
            entered_dr,
            entered_cr,
            reference1,
            reference2,
            reference4,
            reference5,
            budget_stage_id,
            budget_year_id,
            je_type,
            amount,
            budget_source_type,
            budget_version_flag,
            balancing_entry_flag,
            gl_budget_set_id
           )
           VALUES
           (p_worksheet_id,
            p_worksheet_id,
            'NEW',
            g_set_of_books_id,
            p_je_source,
            p_je_category ,
            l_currency_code,
            sysdate,
            l_created_by   ,
            'B',
            l_budget_version_id,
            p_gl_period_start,
            p_gl_period,
            p_gl_year,
            p_period_num ,
            p_quarter_num,
            l_ccid ,
            c_summary_rec.dr_amount,
            c_summary_rec.cr_amount,
            g_je_name ,
            g_je_description,
            NULL,
            NULL,
            p_budget_stage_id,
            p_budget_year_id ,
            p_detailed,
            c_summary_rec.x_amount,
            p_event_type , -- Bug 3029168
            l_budget_version_flag,
            'N',
            p_GL_budget_set_id
           );
          END IF;--bug:5357711
         END LOOP;   -- END of 2 loops FOR permanent AND temp FOR each record
       END LOOP;  -- END of summary record processing

     END;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Insert_Lines_Into_PSB_I_Fund;
     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Insert_Lines_Into_PSB_I_Fund;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
     ROLLBACK TO Insert_Lines_Into_PSB_I_Fund;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
     END IF;
END Insert_Lines_Into_PSB_I_Fund;
/* ----------------------------------------------------------------------- */

PROCEDURE Create_JE_Lines_Fund
(x_return_status    OUT NOCOPY VARCHAR2,
 p_worksheet_id     IN         NUMBER,
 p_budget_stage_id  IN         NUMBER,
 p_budget_year_id   IN         NUMBER,
 p_detailed         IN         VARCHAR2,
 p_auto_offset      IN         VARCHAR2,
 p_gl_budget_set_id IN         NUMBER,
 p_start_date       IN         DATE,
 p_end_date         IN         DATE,
 p_column           IN         NUMBER,
 p_je_source        IN         VARCHAR2,
 p_je_category      IN         VARCHAR2,
 p_period_name      IN         VARCHAR2,
 p_gl_year          IN         NUMBER,
 p_gl_period_num    IN         NUMBER,
 p_gl_quarter_num   IN         NUMBER,
 p_event_type       IN         VARCHAR2 DEFAULT 'BP'
)
IS

  l_api_name        CONSTANT VARCHAR2(30) := 'Create_JE_Lines_Fund';
  l_api_version     CONSTANT NUMBER       := 1.0;

  l_gl_period                VARCHAR2(15);
  l_gl_year                  NUMBER;
  l_gl_period_num            NUMBER;
  l_gl_quarter_num           NUMBER;
  l_worksheet_id             NUMBER;
  l_stage_seq                NUMBER;
  l_gl_period_start          DATE;

  l_event_number             NUMBER;
  l_return_status            VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(2000);

  CURSOR bgt_stage
  IS
  SELECT sequence_number
  FROM   psb_budget_stages
  WHERE  budget_stage_id = p_budget_stage_id;

BEGIN

   FOR bgt_stage_rec IN bgt_stage LOOP
     l_stage_seq := bgt_stage_rec.sequence_number;
   END LOOP;

   --++ INSERT INTO PSB_GL_INTERFACE Table.
   Insert_Lines_Into_PSB_I_Fund
   (x_return_status    => l_return_status ,
    x_msg_count        => l_msg_count,
    x_msg_data         => l_msg_data,
    p_worksheet_id     => p_worksheet_id,
    p_gl_budget_set_id => p_gl_budget_set_id ,
    p_stage_seq        => l_stage_seq,
    p_year_id          => p_budget_year_id,
    p_column           => p_column,
    p_gl_period        => p_period_name,
    p_gl_period_start  => p_start_date,
    p_gl_year          => p_gl_year,
    p_period_num       => p_gl_period_num,
    p_quarter_num      => p_gl_quarter_num,
    p_je_source        => p_je_source,
    p_je_category      => p_je_category,
    p_budget_stage_id  => p_budget_stage_id,
    p_budget_year_id   => p_budget_year_id,
    p_detailed         => p_detailed,
    p_event_type       => p_event_type);  -- Bug 3029168

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF p_auto_offset = 'Y' THEN
     Balance_Journal
     (x_return_status    => l_return_status ,
      p_worksheet_id     => p_worksheet_id,
      p_period_name      => p_period_name,
      p_gl_budget_set_id => p_gl_budget_set_id
     );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;

  -- Initialize API RETURN status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

END Create_JE_Lines_Fund;

/* ----------------------------------------------------------------------- */

PROCEDURE Delete_Old_Run
(x_return_status      OUT NOCOPY VARCHAR2,
 p_worksheet_id       IN         NUMBER,
 p_budget_source_type IN         VARCHAR2
)
IS
  l_api_name    CONSTANT VARCHAR2(30) := 'Delete_Old_Run';
  l_api_version CONSTANT NUMBER       := 1.0;


BEGIN

  SAVEPOINT Delete_Old_Run;

  DELETE FROM psb_gl_interfaces
  WHERE worksheet_id = p_worksheet_id
  AND NVL(budget_source_type, 'P') = p_budget_source_type
  AND gl_transfer_flag is null; --bug:7639620

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Delete_Old_Run;
     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Delete_Old_Run;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
     ROLLBACK TO Delete_Old_Run;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

END Delete_Old_Run;
/* ----------------------------------------------------------------------- */

-- commenting out the savepoints FOR XLA transfer since the XLA transfer
-- program commits within the process AND this erases the savepoints established

PROCEDURE Create_Budget_Journal_Fund
(x_return_status     OUT NOCOPY  VARCHAR2,
 p_worksheet_id                  NUMBER,
 p_budget_stage_id               NUMBER,
 p_budget_year_id                NUMBER,
 p_year_journal                  VARCHAR2,
 p_gl_transfer_mode              VARCHAR2,
 p_auto_offset                   VARCHAR2,
 p_gl_budget_set_id              NUMBER,
 p_run_mode                      VARCHAR2,
 p_order_by1                     VARCHAR2,
 p_order_by2                     VARCHAR2,
 p_order_by3                     VARCHAR2,
 p_currency_code                 VARCHAR2 DEFAULT 'C'  -- Bug 3029168
)
IS

  l_year_start_date            DATE;
  l_year_end_date              DATE;
  l_budget_year_type_id        NUMBER;

  l_stage_sequence             NUMBER;

  l_period_name                VARCHAR2(15);
  l_period_start_date          DATE;
  l_period_end_date            DATE;

  l_gl_year                    NUMBER;
  l_gl_period_num              NUMBER;
  l_gl_quarter_num             NUMBER;

  /*FOR Bug No : 2543724 Start*/
  --commented the following two variables as they are NOT being used
  --AND also removed them FROM passing INTO Get_GL_Period procedure
  --l_next_period          VARCHAR2(15);
  --l_reversal_date        DATE;
  /*FOR Bug No : 2543724 END*/

  l_column                     NUMBER;

  l_req_id                     NUMBER;
  l_funding_status             VARCHAR2(1);
  l_validation_status          VARCHAR2(1);
  l_acct_overlap_status        VARCHAR2(1);

  l_event_number               NUMBER;
  l_accounting_date            DATE;
  l_period_status              VARCHAR2(1);

  l_return_status              VARCHAR2(1);
  l_msg_count                  NUMBER;
  l_msg_data                   VARCHAR2(2000);

  l_cbc_document               BOOLEAN := FALSE;
  l_include_cbc_commit_balance VARCHAR2(1);
  l_include_cbc_oblig_balance  VARCHAR2(1);
  l_include_cbc_budget_balance VARCHAR2(1);

  l_gl_budget_set_id           NUMBER;
  l_event_type                 VARCHAR2(5);

  CURSOR c_year
  IS
  SELECT start_date,
         end_date,
         budget_year_type_id
  FROM psb_budget_periods
  WHERE budget_period_id = p_budget_year_id;

  CURSOR c_stage
  IS
  SELECT sequence_number
  FROM psb_budget_stages
  WHERE budget_stage_id = p_budget_stage_id;

  CURSOR c_period
  IS
  SELECT budget_period_id,
         start_date,
         end_date
  FROM psb_budget_periods
  WHERE budget_period_type = 'P'
  AND parent_budget_period_id = p_budget_year_id
  ORDER BY start_date;

  CURSOR c_ws
  IS
  SELECT include_cbc_commit_balance,
         include_cbc_oblig_balance,
         include_cbc_budget_balance
  FROM psb_worksheets
  WHERE worksheet_id = p_worksheet_id;

  CURSOR c_post_to_all
  IS
  SELECT 'Y'
  FROM dual
  WHERE EXISTS
  (SELECT 1
   FROM psb_GL_BUDGETS
   WHERE dual_posting_type = 'A'
   AND gl_budget_set_id = p_gl_budget_set_id
   AND l_accounting_date BETWEEN start_date AND end_date   --bug:5357711:modified
  );

BEGIN

  FND_MSG_PUB.initialize;

  /* Bug 3029168 Start */
  IF p_currency_code = 'C' THEN
    l_event_type   := 'BP';
  ELSE
    l_event_type   := 'SW';
  END IF;
  /* Bug 3029168 End */
  g_budget_year_id := p_budget_year_id;


  Initialize
  (x_return_status => l_return_status,
   p_event_type    => l_event_type,  -- Bug 3029168
   p_source_id     => p_worksheet_id,
   p_auto_offset   => p_auto_offset
  );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Dele the old run for the same worksheet
  -- and budget source.
  Delete_Old_Run
  (x_return_status      => l_return_status,
   p_worksheet_id       => p_worksheet_id,
   p_budget_source_type => g_budget_source_type
  );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  FOR c_year_rec IN c_year LOOP
    l_year_start_date     := c_year_rec.start_date;
    l_year_end_date       := c_year_rec.end_date;
    l_budget_year_type_id := c_year_rec.budget_year_type_id;
  END LOOP;

  FOR c_ws_rec IN c_ws LOOP
    l_include_cbc_commit_balance := c_ws_rec.include_cbc_commit_balance;
    l_include_cbc_oblig_balance  := c_ws_rec.include_cbc_oblig_balance;
    l_include_cbc_budget_balance := c_ws_rec.include_cbc_budget_balance;
  END LOOP;

  IF g_budget_by_position = 'Y' AND p_currency_code = 'C' THEN
    BEGIN
      PSB_POSITION_CONTROL_PVT.Validate_Position_Budget
      (p_return_status => l_return_status,
       p_event_type => l_event_type,
       p_source_id => p_worksheet_id
      );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END;
  END IF;

  FOR c_stage_rec IN c_stage LOOP
    l_stage_sequence := c_stage_rec.sequence_number;
  END LOOP;

  l_gl_budget_set_id := p_gl_budget_set_id;

  PSB_GL_BUDGET_SET_PVT.Validate_Account_Overlap
    (p_api_version       => 1.0,
     p_return_status     => l_return_status,
     p_msg_data          => l_msg_data,
     p_msg_count         => l_msg_count,
     p_gl_budget_set_id  => l_gl_budget_set_id,
     p_validation_status => l_acct_overlap_status
    );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_acct_overlap_status <> FND_API.G_RET_STS_SUCCESS THEN
      -- dummy line to force this error to print to outfile IF no
      -- error IN validate funded proc
      Add_Message('PSB', 'PSB_VAL_LINE');
    END IF;

    /*FOR Bug No : 2712019 Start*/
    --Validate the GL Budget year FOR all the gl budgets IN PSB GL Budget set
    --AND this procedure throws an error IF there IS no correponding year
    --opened FOR any GL Budget IN PSB GL Budget Set

    Validate_GL_Budget_Year
    (x_return_status    => l_return_status,
     p_gl_budget_set_id => p_gl_budget_set_id,
     p_year_start_date  => l_year_start_date,
     p_year_end_date    => l_year_end_date
    );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    /*FOR Bug No : 2712019 END*/

    -- continue validation regardless value of validation status
    IF p_year_journal = 'Y' THEN
      BEGIN
        Get_GL_Period
        (x_return_status        => l_return_status,
         x_effective_period_num => l_event_number,
         p_start_date           => l_year_start_date,
         x_period_name          => l_period_name,
         x_period_start_date    => l_accounting_date,
         x_period_end_date      => l_period_end_date,
         x_period_status        => l_period_status,
         x_period_year          => l_gl_year,
         x_period_number        => l_gl_period_num,
         x_quarter_number       => l_gl_quarter_num
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        Validate_Funding_Account
        (x_return_status     => l_return_status,
         p_event_type        => l_event_type,
         p_source_id         => p_worksheet_id,
         p_stage_sequence    => l_stage_sequence,
         p_budget_year_id    => p_budget_year_id,
         p_gl_budget_set_id  => l_gl_budget_set_id,
         p_start_date        => l_accounting_date,
         x_validation_status => l_validation_status
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_funding_status := l_validation_status;
      END;
    ELSE
      BEGIN
        l_funding_status := FND_API.G_RET_STS_SUCCESS;

        FOR c_period_rec IN c_period LOOP
          Get_GL_Period
          (x_return_status        => l_return_status,
           x_effective_period_num => l_event_number,
           p_start_date           => c_period_rec.start_date,
           x_period_name          => l_period_name,
           x_period_start_date    => l_accounting_date,
           x_period_end_date      => l_period_end_date,
           x_period_status        => l_period_status,
           x_period_year          => l_gl_year,
           x_period_number        => l_gl_period_num,
           x_quarter_number       => l_gl_quarter_num
          );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          Validate_Funding_Account
          (x_return_status     => l_return_status,
           p_event_type        => l_event_type,
           p_source_id         => p_worksheet_id,
           p_stage_sequence    => l_stage_sequence,
           p_budget_year_id    => p_budget_year_id,
           p_gl_budget_set_id  => l_gl_budget_set_id,
           p_start_date        => l_accounting_date,
           x_validation_status => l_validation_status
          );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF ((l_funding_status = FND_API.G_RET_STS_SUCCESS)
               AND
              (l_validation_status <> FND_API.G_RET_STS_SUCCESS)
             )
          THEN
            l_funding_status := l_validation_status;
          END IF;
        END LOOP;
      END;
    END IF;

    IF (l_funding_status <> FND_API.G_RET_STS_SUCCESS
        OR
        l_acct_overlap_status <> FND_API.G_RET_STS_SUCCESS
       )
    THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      BEGIN

        IF p_year_journal = 'Y' THEN
          BEGIN
            Get_GL_Period
            (x_return_status        => l_return_status,
             x_effective_period_num => l_event_number,
             p_start_date           => l_year_start_date,
             x_period_name          => l_period_name,
             x_period_start_date    => l_accounting_date,
             x_period_end_date      => l_period_end_date,
             x_period_status        => l_period_status,
             x_period_year          => l_gl_year,
             x_period_number        => l_gl_period_num,
             x_quarter_number       => l_gl_quarter_num
            );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
            END IF;

            -- Include your changes here.
            l_column := 0;

  -- initialize global variable which determines IF there's an 'ALL' posting type
          /*bug:5357711:start*/
          FOR c_post_rec IN c_post_to_all LOOP
              g_post_to_all := FND_API.G_TRUE;
          END LOOP;
          /*bug:5357711:end*/

            Create_JE_Lines_Fund
            (x_return_status    => l_return_status,
             p_worksheet_id     => p_worksheet_id,
             p_budget_stage_id  => p_budget_stage_id,
             p_budget_year_id   => p_budget_year_id ,
             p_detailed         => p_gl_transfer_mode,
             p_auto_offset      => p_auto_offset,
             p_gl_budget_set_id => p_gl_budget_set_id,
             p_start_date       => l_accounting_date,
             p_end_date         => l_year_end_date,
             p_column           => l_column,
             p_je_source        => g_source_name,
             p_je_category      => g_category_name,
             p_period_name      => l_period_name,
             p_gl_year          => l_gl_year,
             p_gl_period_num    => l_gl_period_num,
             p_gl_quarter_num   => l_gl_quarter_num,
             p_event_type       => l_event_type
            );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
            END IF;
            -- Include your changes here done.
          END;
        ELSE
          BEGIN
            l_column := 0;
            FOR c_period_rec IN c_period LOOP
              l_column := l_column + 1;

              Get_GL_Period
              (x_return_status        => l_return_status,
               x_effective_period_num => l_event_number,
               p_start_date           => c_period_rec.start_date,
               x_period_name          => l_period_name,
               x_period_start_date    => l_accounting_date,
               x_period_end_date      => l_period_end_date,
               x_period_status        => l_period_status,
               x_period_year          => l_gl_year,
               x_period_number        => l_gl_period_num,
               x_quarter_number       => l_gl_quarter_num
              );

              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
              END IF;

  -- initialize global which determines IF there's an 'ALL' posting type
          /*bug:5357711:start*/
          FOR c_post_rec IN c_post_to_all LOOP
              g_post_to_all := FND_API.G_TRUE;
          END LOOP;
          /*bug:5357711:end*/

              -- Include your changes here.
              Create_JE_Lines_Fund
              (x_return_status    => l_return_status,
               p_worksheet_id     => p_worksheet_id,
               p_budget_stage_id  => p_budget_stage_id,
               p_budget_year_id   => p_budget_year_id ,
               p_detailed         => p_gl_transfer_mode,
               p_auto_offset      => p_auto_offset,
               p_gl_budget_set_id => p_gl_budget_set_id ,
               p_start_date       => l_accounting_date,
               p_end_date         => l_period_end_date,
               p_column           => l_column,
               p_je_source        => g_source_name,
               p_je_category      => g_category_name,
               p_period_name      => l_period_name,
               p_gl_year          => l_gl_year,
               p_gl_period_num    => l_gl_period_num,
               p_gl_quarter_num   => l_gl_quarter_num,
               p_event_type       => l_event_type
              );

              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
              END IF;
              -- Include your changes here done.
            END LOOP; /*END of LOOP FOR getting gl periods*/
          END;
        END IF;

        IF p_run_mode <> 'F' THEN       --
          -- Starting the concurrent program FOR trial mode
          --
          Submit_Concurrent_Request
          (x_return_status    => l_return_status,
           p_source_id        => p_worksheet_id,
           p_event_type       => l_event_type,
           p_order_by1        => p_order_by1,
           p_order_by2        => p_order_by2,
           p_order_by3        => p_order_by3,
           p_gl_budget_set_id => l_gl_budget_set_id,
           p_budget_year_id   => p_budget_year_id,
           p_currency_code    => p_currency_code  -- Bug 3029168
          );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;
      END;
    END IF; -- no validation error found

  -- ++ Final mode update to GL
  IF p_run_mode = 'F' THEN
    -- no report FOR final since xla will process all records
    BEGIN
      IF (NVL(l_include_cbc_commit_balance,'N') = 'Y'
         OR
         NVL(l_include_cbc_oblig_balance,'N') = 'Y'
         OR
         NVL(l_include_cbc_budget_balance, 'N') = 'Y')
         AND l_event_type <> 'SW'
      THEN
        BEGIN
          l_cbc_document := TRUE;

          PSB_COMMITMENTS_PVT.Post_Commitment_Worksheet
          (p_api_version   => 1.0,
           p_return_status => l_return_status,
           p_msg_data      => l_msg_data,
           p_msg_count     => l_msg_count,
           p_worksheet_id  => p_worksheet_id
          );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            Message_Token('WORKSHEET', p_worksheet_id);
            Add_Message('PSB', 'PSB_CANNOT_POST_COMMITMENT_WS');
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END;
      ELSE
        BEGIN
          -- Include your changes here. At the place of XLA call, make ur own call FOR Journel Import.
          Insert_Lines_To_GL
          (x_return_status => l_return_status,
           p_source_id     => p_worksheet_id,
           p_called_from   => 'C',
           p_event_type    => l_event_type
          );
          -- Include your changes here. END.

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
         END IF;
       END;
     END IF;

     PSB_BUDGET_REVISIONS_PVT.Create_Base_Budget_Revision
     (p_api_version   => 1.0,
      p_return_status => l_return_status,
      p_msg_count     => l_msg_count,
      p_msg_data      => l_msg_data,
      p_worksheet_id  => p_worksheet_id,
      p_event_type    => l_event_type  -- Bug 3029168
     );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;
   END;
 END IF;

  -- Initialize API RETURN status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Create_Budget_Journal_Fund;

/* ----------------------------------------------------------------------- */

PROCEDURE Validate_Funding_Account
(x_return_status     OUT    NOCOPY VARCHAR2,
 p_event_type                      VARCHAR2,
 p_source_id                       NUMBER,
 p_stage_sequence                  NUMBER := NULL,
 p_budget_year_id                  NUMBER := NULL,
 p_gl_budget_set_id                NUMBER,
 p_start_date                      DATE,
 x_validation_status IN OUT NOCOPY VARCHAR2
)
IS

  TYPE FBCurType IS REF CURSOR;
  fb_cv                 FBCurType;

   l_cv_ccid            NUMBER;
   l_return_status      VARCHAR2(1);

   l_gl_budget_set_name VARCHAR2(80);
   l_concat_segments    VARCHAR2(2000);
   l_curr_string        VARCHAR2(100);

   CURSOR c_budgetset
   IS
   SELECT gl_budget_set_name
   FROM PSB_GL_BUDGET_SETS
   WHERE gl_budget_set_id = p_gl_budget_set_id;

   CURSOR c_revision
   IS
   SELECT permanent_revision
   FROM PSB_BUDGET_REVISIONS
   WHERE budget_revision_id = p_source_id;

BEGIN
  /* Bug 3029168 Start */
  -- setting the dynamic cursor based on event type
  IF p_event_type = 'BP' THEN
    l_curr_string := 'and a.currency_code <> ''STAT'' ';
  ELSIF p_event_type = 'SW' THEN
    l_curr_string := 'and a.currency_code = ''STAT'' ';
  ELSIF p_event_type = 'BR' THEN
    l_curr_string := 'and bra.currency_code <> ''STAT'' ';
  ELSIF p_event_type = 'SR' THEN
    l_curr_string := 'and bra.currency_code = ''STAT'' ';
  END IF;
  /* Bug 3029168 End */

  FOR c_budgetset_rec IN c_budgetset LOOP
    l_gl_budget_set_name := c_budgetset_rec.gl_budget_set_name;
  END LOOP;

  IF p_event_type = 'BP' OR p_event_type = 'SW' THEN -- Bug 3029168
    BEGIN

      OPEN fb_cv FOR
        'SELECT a.code_combination_id ' ||
        'FROM PSB_WS_ACCOUNT_LINES a, PSB_WS_LINES b ' ||
        'WHERE b.worksheet_id = :source_id ' ||
         l_curr_string||   -- Bug 3029168
        'AND b.account_line_id = a.account_line_id ' ||
        'AND a.budget_year_id =  :budget_year_id ' ||
        'AND a.balance_type = ''E'' ' ||
        'AND a.template_id IS NULL ' ||
        'AND :stage_sequence BETWEEN a.start_stage_seq AND a.current_stage_seq ' ||
        /* Bug No 1357416 Start */
        ---        'minus ' ||
        'AND NOT exists (' ||
        /* Bug No 1357416 END */
        'SELECT v.code_combination_id ' ||
        'FROM PSB_BUDGET_ACCOUNTS v, PSB_SET_RELATIONS vs, PSB_GL_BUDGETS vgb ' ||
        'WHERE :start_date BETWEEN vgb.start_date AND vgb.end_date ' ||
        'AND vgb.gl_budget_set_id = :gl_budget_set_id ' ||
        'AND vgb.gl_budget_id = vs.gl_budget_id ' ||
        'AND vs.account_position_set_id = v.account_position_set_id ' ||
        /* Bug No 1357416 Start */
        'AND v.code_combination_id = a.code_combination_id)'
        /* Bug No 1357416 END */
      USING p_source_id, p_budget_year_id, p_stage_sequence, p_start_date, p_gl_budget_set_id;
      LOOP
        FETCH fb_cv INTO l_cv_ccid;
        EXIT WHEN fb_cv%NOTFOUND;

        l_concat_segments := FND_FLEX_EXT.Get_Segs
                             (application_short_name => 'SQLGL',
                              key_flex_code          => 'GL#',
                              structure_number       => g_chart_of_accounts_id,
                              combination_id         => l_cv_ccid
                             );
         Message_Token('CCID', l_concat_segments);
         Message_Token('BUDGETSET', l_gl_budget_set_name);
         Add_Message('PSB', 'PSB_CCID_NO_FUND_INFO');
         x_validation_status := FND_API.G_RET_STS_ERROR;
      END LOOP;
      CLOSE fb_cv;
    END;
  ELSIF p_event_type = 'BR' OR p_event_type = 'SR' THEN -- Bug 3029168
    BEGIN
      OPEN fb_cv FOR
        'SELECT bra.code_combination_id ' ||
        'FROM psb_budget_revision_accounts bra, psb_budget_revision_lines brl ' ||
        'WHERE brl.budget_revision_id = :source_id ' ||
         l_curr_string|| -- Bug 3029168
        'AND bra.budget_revision_acct_line_id = brl.budget_revision_acct_line_id ' ||
        /* Bug No 1357416 Start */
        ---        'minus ' ||
        'AND NOT exists (' ||
        /* Bug No 1357416 END */
        'SELECT v.code_combination_id ' ||
        'FROM PSB_BUDGET_ACCOUNTS v, PSB_SET_RELATIONS vs, PSB_GL_BUDGETS vgb ' ||
        'WHERE :start_date BETWEEN vgb.start_date AND vgb.end_date ' ||
        'AND vgb.gl_budget_set_id = :gl_budget_set_id ' ||
        'AND vgb.gl_budget_id = vs.gl_budget_id ' ||
        'AND vs.account_position_set_id = v.account_position_set_id ' ||
        'AND NVL(dual_posting_type, ''P'') = DECODE(:permanent_revision, ''Y'', NVL(dual_posting_type, ''P''), ''A'') ' ||
        /* Bug No 1357416 Start */
        'AND v.code_combination_id = bra.code_combination_id)'
        /* Bug No 1357416 END */
      USING p_source_id, p_start_date, p_gl_budget_set_id, g_permanent_revision;
      LOOP
        FETCH fb_cv INTO l_cv_ccid;
        EXIT WHEN fb_cv%NOTFOUND;
        l_concat_segments := FND_FLEX_EXT.Get_Segs
                             (application_short_name => 'SQLGL',
                              key_flex_code          => 'GL#',
                              structure_number       => g_chart_of_accounts_id,
                              combination_id         => l_cv_ccid
                             );


        Message_Token('CCID', l_concat_segments);
        Message_Token('BUDGETSET', l_gl_budget_set_name);
        Add_Message('PSB', 'PSB_CCID_NO_FUND_INFO');
        x_validation_status := FND_API.G_RET_STS_ERROR;
      END LOOP;
      CLOSE fb_cv;
    END;
  END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Validate_Funding_Account;

/* ----------------------------------------------------------------------- */
PROCEDURE Insert_BR_Lines_In_PSB_I_Fund
(p_api_version        IN         NUMBER,
 p_init_msg_list      IN         VARCHAR2,
 p_commit             IN         VARCHAR2,
 p_validation_level   IN         NUMBER,
 x_return_status      OUT NOCOPY VARCHAR2,
 x_msg_count          OUT NOCOPY NUMBER,
 x_msg_data           OUT NOCOPY VARCHAR2,
 p_budget_revision_id IN         NUMBER,
 p_je_source          IN         VARCHAR2,
 p_je_category        IN         VARCHAR2,
 p_auto_offset        IN         VARCHAR2,
 p_gl_budget_set_id   IN         NUMBER,
 p_event_type         IN         VARCHAR2,
 x_validation_status  OUT NOCOPY VARCHAR2
)
IS

  l_api_name            CONSTANT VARCHAR2(30) := 'Insert_BR_Lines_In_PSB_I_Fund';
  l_api_version         CONSTANT NUMBER  := 1.0;

  l_batch_name                   VARCHAR2(100);
  l_batch_description            VARCHAR2(100);
  l_je_name                      VARCHAR2(100);
  l_je_description               VARCHAR2(100);
  l_created_by                   NUMBER;
--
  l_funding_status               VARCHAR2(1);
  l_validation_status            VARCHAR2(1);

  l_budget_version_id            NUMBER := NULL;
  l_code_combination_id          NUMBER;
  l_dr_amount                    NUMBER;
  l_cr_amount                    NUMBER;
  l_msg_count                    NUMBER;
  l_msg_data                     VARCHAR2(2000);
  l_concat_segments              VARCHAR2(2000);
  l_budget_version_flag          VARCHAR2(1);
  l_permanent_revision           VARCHAR2(1);

  l_prev_gl_period_name          VARCHAR2(15) := 'INITIALLY NULL';
  l_gl_period_name               VARCHAR2(15);
  l_gl_year                      NUMBER;
  l_gl_period_num                NUMBER;
  l_gl_quarter_num               NUMBER;

  l_period_changed               VARCHAR2(1);
  l_validation_start_date        DATE;

  l_accounting_date              DATE;
  l_period_end_date              DATE;
  l_event_number                 NUMBER;
  l_period_name                  VARCHAR2(15);
  l_period_status                VARCHAR2(1);

  l_return_status                VARCHAR2(1);

  l_period_indx                  NUMBER :=0;
  l_tbl_indx                     NUMBER :=0;

  l_pst_budget_version_id        NUMBER; --bug:5357711

  -- Bug#4310411 Start
  -- Record types those will hold the PSB_GL_INTERFACES
  -- table's columns.
  rec_budget_version_id          Number_Tbl_Type;
  rec_accounting_date            Date_Tbl_Type;
  rec_period_name                Char_Tbl_Type;
  rec_period_year                Char_Tbl_Type;
  rec_period_num                 Char_Tbl_Type;
  rec_quarter_num                Char_Tbl_Type;
  rec_code_combination_id Number_Tbl_Type;
  rec_entered_dr                 Char_Tbl_Type;
  rec_entered_cr                 Char_Tbl_Type;
  rec_amount                     Char_Tbl_Type;
  rec_budget_version_flag        Char_Tbl_Type;
  -- Bug#4310411 End

  CURSOR c_budrev_accts
  IS
  SELECT bra.gl_period_name,
         gps.start_date, ---1
         pgb.start_date budget_set_start_date, --2
         gps.period_name,
         gps.effective_period_num,
         gps.end_date,
         gps.closing_status,
         gps.period_year,
         gps.period_num,
         gps.quarter_num,
         bra.code_combination_id,
         pgb.gl_budget_version_id,   --bug:5357711:modified from bra.gl_budget_version_id to pgb.gl_budget_version_id
         DECODE(bra.account_type,'L', NULL, 'O', NULL, 'R', NULL,
                DECODE(bra.revision_type,'I',bra.revision_amount * 1.0,'D',
                                        bra.revision_amount * -1.0
                      )
               ) dr_amount,
         DECODE(bra.account_type, 'A' , NULL, 'E' , NULL,
                DECODE(bra.revision_type,'I',bra.revision_amount * 1.0,'D',
                                        bra.revision_amount * -1.0
                      )
               ) cr_amount,
         budget_balance x_amount
  FROM psb_budget_revisions         br,
       psb_budget_revision_accounts bra,
       psb_budget_revision_lines    brl,
       gl_period_statuses           gps,
       psb_gl_budgets               pgb
  WHERE br.budget_revision_id = p_budget_revision_id
  AND brl.budget_revision_id = p_budget_revision_id
  AND br.budget_revision_type = 'R'
  -- Bug 3029168 added the following OR condition
  AND ((bra.currency_code <> 'STAT' AND p_event_type = 'BR') OR
       (bra.currency_code  = 'STAT' AND p_event_type = 'SR'))
  AND brl.budget_revision_acct_line_id = bra.budget_revision_acct_line_id
  AND gps.period_name = bra.gl_period_name
  AND gps.application_id = 101
  AND gps.adjustment_period_flag='N'
  AND bra.position_id IS NULL        --bug:8548497
  AND ((gps.start_date BETWEEN pgb.start_date AND pgb.end_date)
        OR
       (gps.end_date BETWEEN pgb.start_date AND pgb.end_date)
      )
  AND gps.set_of_books_id = g_set_of_books_id
  AND pgb.gl_budget_set_id = p_gl_budget_set_id
  ORDER BY bra.gl_period_name, bra.code_combination_id, gps.period_num;

  l_rec_period_name Char_Tbl_Type;

BEGIN

  SAVEPOINT Insert_BR_Lines_In_PSB_I_Fund;

  l_created_by := fnd_global.user_id;

  FND_MESSAGE.SET_NAME('PSB', 'PSB_GL_BJR_BATCH_NAME');
  FND_MESSAGE.SET_TOKEN('BUDGET_REVISION_ID', p_budget_revision_id);
  l_batch_name := FND_MESSAGE.Get;

  FND_MESSAGE.SET_NAME('PSB', 'PSB_GL_BJR_BATCH_DESC');
  FND_MESSAGE.SET_TOKEN('BUDGET_REVISION_ID', p_budget_revision_id);
  l_batch_description := FND_MESSAGE.Get;

  FND_MESSAGE.SET_NAME('PSB', 'PSB_GL_BJR_JE_NAME');
  FND_MESSAGE.SET_TOKEN('BUDGET_REVISION_ID', p_budget_revision_id);
  l_je_name := FND_MESSAGE.Get;

  FND_MESSAGE.SET_NAME('PSB', 'PSB_GL_BJR_JE_DESC');
  FND_MESSAGE.SET_TOKEN('BUDGET_REVISION_ID', p_budget_revision_id);
  l_je_description := FND_MESSAGE.Get;

  /*bug:8201280:start*/
  IF p_event_type = 'SR' THEN
    g_currency_code := 'STAT';
  END IF;
  /*bug:8201280:end*/

  -- initialize global which determines IF revision IS permanent OR temporary

  FOR c_budrev_accts_rec IN c_budrev_accts LOOP
    -- Bug#4310411 Start
    -- Get all the different gl_period names.
    l_gl_period_name := c_budrev_accts_rec.gl_period_name;

    IF l_gl_period_name <> l_prev_gl_period_name THEN
      l_period_indx                    := l_period_indx + 1;
      l_rec_period_name(l_period_indx) := l_gl_period_name;
      l_prev_gl_period_name            := l_gl_period_name;
    END IF;
    -- Bug#4310411 End

    -- FOR each budget revisions acct rec, process 2 times FOR permanent revision
    -- (post to the 'A' version flag budget AND 'P' version flag budget)
    -- AND once FOR temporary revision (post only to 'A' version flag)

    FOR i IN 1 .. 2 LOOP
    -- post to gl_interface FOR both permanent AND temporary revisions

      IF i = 1 THEN
        l_budget_version_flag := 'A';
      ELSE
        l_budget_version_flag := 'P';
      END IF;

      l_budget_version_id := c_budrev_accts_rec.gl_budget_version_id;

      IF i = 2 THEN
        -- post to gl_interface FOR only permanent revision
        IF g_permanent_revision = 'N' THEN
          EXIT;
          -- skip posting since this IS NOT a permanent revision
        END IF;

        -- get corresponding budget version id FOR 'permanent' budget
        -- AND get out IF with error
        -- use actual ccid

        l_validation_start_date
          := GREATEST(c_budrev_accts_rec.start_date, c_budrev_accts_rec.budget_set_start_date);

        x_validation_status := FND_API.G_RET_STS_SUCCESS;

        Validate_Funding_Account
        (x_return_status     => l_return_status,
         p_event_type        => p_event_type, -- Bug 3029168
         p_source_id         => p_budget_revision_id,
         p_gl_budget_set_id  => p_gl_budget_set_id,
         p_start_date        => l_validation_start_date,
         x_validation_status => l_validation_status
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
  	  RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_validation_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_validation_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

        /*bug:5357711:start*/
         l_pst_budget_version_id := 0;

          PSB_GL_BUDGET_PVT.Find_GL_Budget
          (p_api_version          => 1.0,
           p_return_status        => l_return_status,
           p_msg_count            => l_msg_count,
           p_msg_data             => l_msg_data,
           p_gl_budget_set_id     => p_gl_budget_set_id,
           p_code_combination_id  => c_budrev_accts_rec.code_combination_id,
           p_start_date           => c_budrev_accts_rec.start_date,
           p_dual_posting_type    => l_budget_version_flag,
           p_gl_budget_version_id => l_pst_budget_version_id
          );

      IF nvl(l_pst_budget_version_id,0) = l_budget_version_id THEN
     /*bug:5357711:end*/

      --
      -- THEN INSERT INTO psb_gl_interfaces
      --

      l_tbl_indx                          := l_tbl_indx + 1;

      rec_budget_version_id(l_tbl_indx)   := l_budget_version_id;
      rec_accounting_date(l_tbl_indx)     := c_budrev_accts_rec.start_date;
      rec_period_name(l_tbl_indx)         := c_budrev_accts_rec.gl_period_name;
      rec_period_year(l_tbl_indx)         := c_budrev_accts_rec.period_year;
      rec_period_num(l_tbl_indx)          := c_budrev_accts_rec.period_num;
      rec_quarter_num(l_tbl_indx)         := c_budrev_accts_rec.quarter_num;
      rec_code_combination_id(l_tbl_indx) := c_budrev_accts_rec.code_combination_id;
      rec_entered_dr(l_tbl_indx)          := c_budrev_accts_rec.dr_amount;
      rec_entered_cr(l_tbl_indx)          := c_budrev_accts_rec.cr_amount;
      rec_amount(l_tbl_indx)              := c_budrev_accts_rec.x_amount;
      rec_budget_version_flag(l_tbl_indx) := l_budget_version_flag;

      /*Bug:7639620:start*/
      CHECK_POSTING_STATUS
      (
        p_return_status       => l_return_status,
        p_event_type          => p_event_type,
        p_source_id           => p_budget_revision_id,
        p_period_name         => rec_period_name(l_tbl_indx),
        p_budget_version_id   => rec_budget_version_id(l_tbl_indx),
        p_code_combination_id => rec_code_combination_id(l_tbl_indx),
        p_budget_version_flag => rec_budget_version_flag(l_tbl_indx)
      );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
     /*Bug:7639620:end*/

     END IF; --bug:5357711

    END LOOP; -- END of 2 loops FOR permanent AND temp revisions FOR each record
  END LOOP; -- END of budget revision accounts rec processing

  -- Populate the last period also
  -- IN the PL/SQL table as no period
  -- change occured.
  l_period_indx                    := l_period_indx + 1;
  l_rec_period_name(l_period_indx) := l_gl_period_name;

  --++ Now Bulk Insert the Data INTO PSB_GL_INTERFACES.
  IF rec_budget_version_id.COUNT > 0 THEN
    FORALL l_indx IN 1..rec_budget_version_id.COUNT
      INSERT INTO psb_gl_interfaces
      (worksheet_id,
       group_id,
       status,
       set_of_books_id,
       user_je_source_name,
       user_je_category_name,
       currency_code,
       date_created,
       created_by,
       actual_flag,
       budget_version_id,
       accounting_date,
       period_name,
       period_year,
       period_num,
       quarter_num,
       code_combination_id,
       entered_dr,
       entered_cr,
       reference1,
       reference2,
       reference4,
       reference5,
       budget_stage_id,
       budget_year_id,
       je_type,
       amount,
       budget_source_type,
       budget_version_flag,
       balancing_entry_flag
      )
      VALUES
      (
       p_budget_revision_id,
       p_budget_revision_id,
       /* For bug 4654145 --> Changed the status to POSTED, as there is no trial mode for budget revision */
       'Posted',
       g_set_of_books_id,
       p_je_source,
       p_je_category,
       g_currency_code,
       SYSDATE,
       l_created_by,
       'B',
       rec_budget_version_id(l_indx),
       rec_accounting_date(l_indx),
       rec_period_name(l_indx),
       rec_period_year(l_indx),
       rec_period_num(l_indx),
       rec_quarter_num(l_indx),
       rec_code_combination_id(l_indx),
       rec_entered_dr(l_indx),
       rec_entered_cr(l_indx),
       g_je_name,
       g_je_description,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       rec_amount(l_indx),
       p_event_type,
       rec_budget_version_flag(l_indx),
       'N'
      );
  END IF;

  --++ Now balance the Journal.
  IF p_auto_offset = 'Y' THEN
    BEGIN
      FOR l_indx IN 1..l_rec_period_name.COUNT LOOP
        Balance_Journal
        (x_return_status    => l_return_status ,
         p_worksheet_id     => p_budget_revision_id,
         p_period_name      => l_rec_period_name(l_indx),
         p_gl_budget_set_id => NULL
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END LOOP;
    END;
  END IF;--END of check FOR auto offset value

  x_return_status := FND_API.G_RET_STS_SUCCESS;
   --

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Insert_BR_Lines_In_PSB_I_Fund;
     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Insert_BR_Lines_In_PSB_I_Fund;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
     ROLLBACK TO Insert_BR_Lines_In_PSB_I_Fund;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
     END IF;

END Insert_BR_Lines_In_PSB_I_Fund;
/* ----------------------------------------------------------------------- */

-- commenting out the savepoints FOR XLA transfer since the XLA transfer
-- program commits within the process AND this erases the savepoints established

PROCEDURE Create_Revision_Journal
(p_api_version        IN         NUMBER,
 p_init_msg_list      IN         VARCHAR2 := FND_API.G_FALSE,
 p_commit             IN         VARCHAR2 := FND_API.G_FALSE,
 p_validation_level   IN         NUMBER   := FND_API.G_VALID_LEVEL_FULL,
 p_return_status      OUT NOCOPY VARCHAR2,
 p_msg_count          OUT NOCOPY NUMBER,
 p_msg_data           OUT NOCOPY VARCHAR2,
 p_budget_revision_id IN         NUMBER,
 p_order_by1          IN         VARCHAR2,
 p_order_by2          IN         VARCHAR2,
 p_order_by3          IN         VARCHAR2,
 p_error_code         OUT NOCOPY VARCHAR2 -- bug# 4341619
)
IS

  l_api_name                 CONSTANT VARCHAR2(30) := 'Create_Revision_Journal';
  l_api_version              CONSTANT NUMBER       := 1.0;

  TYPE RevCurType IS REF CURSOR;
  rev_cv                     RevCurType;

  l_cv_period_name           VARCHAR2(15);
  l_cv_start_date            DATE;
  l_cv_effective_period_num  NUMBER;
  l_cv_budgetset_start_date  DATE;

  l_auto_offset              VARCHAR2(1);

  l_je_source                VARCHAR2(25);
  l_je_category              VARCHAR2(25);

  l_req_id                   NUMBER;
  l_funding_status           VARCHAR2(1);
  l_validation_status        VARCHAR2(1);
  l_acct_overlap_status      VARCHAR2(1);
  l_validation_start_date    DATE;

  l_column                   NUMBER;

  l_cbc_document             BOOLEAN := FALSE;

  l_set_of_books_id          NUMBER;
  l_gl_budget_set_id         NUMBER;

  l_return_status            VARCHAR2(1);
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(2000);
  /*FOR Bug No : 2920702 Start*/
  l_year_start_date          DATE;
  l_year_end_date            DATE;
  l_event_type               VARCHAR2(5);
  l_budget_group_id          NUMBER;
  l_currency_code            VARCHAR2(15);



  CURSOR c_year
  IS
  SELECT MIN(gp.start_date) start_date, MAX(gp.end_date) end_date
  FROM PSB_BUDGET_REVISION_ACCOUNTS ac,
       GL_PERIOD_STATUSES gp
  WHERE ac.budget_revision_acct_line_id IN
  (SELECT budget_revision_acct_line_id
   FROM psb_budget_revision_lines
   WHERE budget_revision_id = p_budget_revision_id
  )
  AND ac.gl_period_name  = gp.period_name
  AND gp.application_id  = 101
  AND gp.set_of_books_id = g_set_of_books_id ;

  /*FOR Bug No : 2920702 END*/
BEGIN

  -- Standard call to check FOR call compatibility.
  IF NOT FND_API.Compatible_API_Call
         (l_api_version,
          p_api_version,
          l_api_name,
          G_PKG_NAME
         )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list IF p_init_msg_list IS set to TRUE.
  IF FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  p_error_code := 'NO_ERR'; -- bug # 4341619

  /* Bug 3029168 Start */
    SELECT currency_code,budget_group_id,gl_budget_set_id
    INTO l_currency_code,l_budget_group_id,l_gl_budget_set_id
    FROM psb_budget_revisions
   WHERE budget_revision_id = p_budget_revision_id;
  /* Bug 3029168 Start */

  IF l_currency_code = 'STAT' THEN
    l_event_type   := 'SR';
  ELSE
    l_event_type := 'BR';
  END IF;
  /* Bug 3029168 End */


  /* FOR Bug No. 2662506 : Start */
    l_auto_offset := FND_PROFILE.VALUE('PSB_REVISION_AUTO_OFFSET');
  /* FOR Bug No. 2662506 : END */

  -- Bug#4310411 Start
  --Get Journal Source value FROM a profile option
  l_je_source := FND_PROFILE.VALUE('PSB_GL_BUDGET_JOURNAL_SOURCE');

  IF l_je_source IS NULL THEN
    l_je_source := 'Budget Journal';
  END IF;

  --Get Journal Category value FROM a profile option
  l_je_category := FND_PROFILE.VALUE('PSB_GL_BUDGET_JOURNAL_CATEGORY');

  IF l_je_category IS NULL THEN
    l_je_category := 'Budget';
  END IF;
  -- Bug#4310411 End


  Initialize
  (x_return_status => l_return_status,
   p_event_type => l_event_type,
   p_source_id => p_budget_revision_id,
   p_auto_offset => l_auto_offset
  );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Dele the old run for the same Budget Revision
  -- and budget source.
  Delete_Old_Run
  (x_return_status      => l_return_status,
   p_worksheet_id       => p_budget_revision_id,
   p_budget_source_type => g_budget_source_type
  );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Bug 3029168 added the second clause
  IF g_budget_by_position = 'Y' AND l_currency_code <> 'STAT' THEN
    BEGIN
      PSB_POSITION_CONTROL_PVT.Validate_Position_Budget
      (p_return_status => l_return_status,
       p_event_type => l_event_type,
       p_source_id => p_budget_revision_id
      );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END;
  END IF;

    l_set_of_books_id := l_set_of_books_id;

    PSB_GL_BUDGET_SET_PVT.Validate_Account_Overlap
    (p_api_version       => p_api_version,
     p_return_status     => l_return_status,
     p_msg_data          => l_msg_data,
     p_msg_count         => l_msg_count,
     p_gl_budget_set_id  => l_gl_budget_set_id,
     p_validation_status => l_acct_overlap_status
    );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_acct_overlap_status <> FND_API.G_RET_STS_SUCCESS THEN
      /* start bug # 4341619 */
      p_error_code := 'ACCOUNT_OVERLAP_ERR';
      p_return_status := FND_API.G_RET_STS_SUCCESS;
      RETURN;
      --Add_Message('PSB', 'PSB_VAL_LINE');
      /* END bug # 4341619 */
    END IF;

    --l_funding_status := FND_API.G_RET_STS_SUCCESS; -- bug # 4341619

    -- continue validation regardless value of validation status
    /*FOR Bug No : 2920702 Start*/
    FOR c_year_rec IN c_year LOOP
      l_year_start_date := c_year_rec.start_date;
      l_year_end_date := c_year_rec.end_date;
    END LOOP;

    Validate_GL_Budget_Year
      (x_return_status    => l_return_status,
       p_gl_budget_set_id => l_gl_budget_set_id,
       p_year_start_date  => l_year_start_date,
       p_year_end_date    => l_year_end_date
      );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      /* start bug # 4341619 */
      p_error_code := 'GL_BUDGET_PERIOD_NOT_OPEN_ERR';
      p_return_status := FND_API.G_RET_STS_SUCCESS;
      RETURN;
      --RAISE FND_API.G_EXC_ERROR;
      /* END bug # 4341619 */
    END IF;

    /*FOR Bug No : 2920702 END*/
    BEGIN
      -- Bug#4310411 Start
      Insert_BR_Lines_In_PSB_I_Fund
      (p_api_version        => p_api_version,
       p_init_msg_list      => p_init_msg_list,
       p_commit             => p_commit,
       p_validation_level   => p_validation_level,
       x_return_status      => l_return_status,
       x_msg_count          => l_msg_count,
       x_msg_data           => l_msg_data,
       p_budget_revision_id => p_budget_revision_id,
       p_je_source          => l_je_source,
       p_je_category        => l_je_category,
       p_auto_offset        => l_auto_offset,
       p_gl_budget_set_id   => l_gl_budget_set_id,
       p_event_type         => l_event_type,  -- Bug 3029168
       x_validation_status  => l_validation_status
      );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      /* start bug # 4341619 */
      IF(l_validation_status <> FND_API.G_RET_STS_SUCCESS) THEN
        p_error_code    := 'NO_FUNDING_BUDGET_ERR';
        p_return_status := FND_API.G_RET_STS_SUCCESS;
        RETURN;
      END IF;
      -- Bug#4310411 End
    END;
    -- END IF; -- bug # 4341619

  IF g_revision_type = 'C' AND l_currency_code <> 'STAT' THEN -- Bug 3029168
    BEGIN
      l_cbc_document := TRUE;
      PSB_COMMITMENTS_PVT.Post_Commitment_Revisions
      (p_api_version        => 1.0,
       p_return_status      => l_return_status,
       p_msg_data           => l_msg_data,
       p_msg_count          => l_msg_count,
       p_budget_revision_id => p_budget_revision_id
      );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        Message_Token('BUDGET_REVISION', p_budget_revision_id);
        Add_Message('PSB', 'PSB_CANNOT_POST_COMMITMENT_REV');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END;
  ELSE
    BEGIN
      -- Bug#4310411 Start
      --Final INSERT INTO GL
      Insert_Lines_To_GL
      (x_return_status => l_return_status,
       p_source_id     => p_budget_revision_id,
       p_called_from   => 'R',
       p_event_type    => l_event_type   -- Bug 3029168
      );
      -- Bug#4310411 End

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END;
  END IF;

  -- Standard check of p_commit.
  IF FND_API.to_Boolean (p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Initialize API RETURN status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;
    /* Start Bug No. 2322856 */
--  PSB_MESSAGE_S.Print_Success;
    /* END Bug No. 2322856 */

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                 p_data  => p_msg_data);
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
                                 p_print_header =>  FND_API.G_TRUE ) ;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                 p_data  => p_msg_data);
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
                                 p_print_header =>  FND_API.G_TRUE ) ;

   WHEN OTHERS THEN
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                 p_data  => p_msg_data);
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                l_api_name);
     END IF;
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
                                 p_print_header =>  FND_API.G_TRUE ) ;

END Create_Revision_Journal;

/* ----------------------------------------------------------------------- */

-- Add Token AND Value to the Message Token array

PROCEDURE Message_Token(tokname IN VARCHAR2,
                        tokval  IN VARCHAR2) IS

BEGIN

  IF no_msg_tokens IS NULL THEN
    no_msg_tokens := 1;
  ELSE
    no_msg_tokens := no_msg_tokens + 1;
  END IF;

  msg_tok_names(no_msg_tokens) := tokname;
  msg_tok_val(no_msg_tokens) := tokval;

END Message_Token;

/* ----------------------------------------------------------------------- */

-- Define a Message Token with a Value AND set the Message Name

-- Calls FND_MESSAGE server package to set the Message Stack. This message IS
-- retrieved by the calling program.

PROCEDURE Add_Message(appname IN VARCHAR2,
                      msgname IN VARCHAR2) IS

  i  BINARY_INTEGER;

BEGIN

  IF ((appname IS NOT NULL) AND
      (msgname IS NOT NULL)) THEN

    FND_MESSAGE.SET_NAME(appname, msgname);

    IF no_msg_tokens IS NOT NULL THEN
      FOR i IN 1..no_msg_tokens LOOP
        FND_MESSAGE.SET_TOKEN(msg_tok_names(i), msg_tok_val(i));
      END LOOP;
    END IF;

    FND_MSG_PUB.Add;

  END IF;

  -- Clear Message Token stack

  no_msg_tokens := 0;

END Add_Message;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                   PROCEDURE Transfer_GLI_TO_GL_CP                         |
 +===========================================================================*/
--
-- This IS the execution file FOR the concurrent program  Transfer GLI to GL
-- through Standard Report Submissions.
--
PROCEDURE Transfer_GLI_To_GL_CP
(errbuf             OUT NOCOPY VARCHAR2,
 retcode            OUT NOCOPY VARCHAR2,
 p_source_id        IN         NUMBER,
 p_currency_code       VARCHAR2 DEFAULT 'C', -- Bug 3029168
 p_gl_transfer_mode IN         VARCHAR2 := NULL,
 p_order_by1        IN         VARCHAR2,
 p_order_by2        IN         VARCHAR2,
 p_order_by3        IN         VARCHAR2
)
IS

  l_api_name      CONSTANT VARCHAR2(30) := 'Transfer_GLI_To_GL_CP';
  l_api_version   CONSTANT NUMBER       :=  1.0 ;

  l_return_status          VARCHAR2(1);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);
  l_event_type             VARCHAR2(5);

BEGIN
  /* Bug 3029168 Start */
  IF p_currency_code = 'C' THEN
    l_event_type := 'BP';
  ELSE
    l_event_type := 'SW';
  END IF;
  /* Bug 3029168 End */
  Transfer_GLI_To_GL
  (p_return_status    => l_return_status,
   p_msg_count        => l_msg_count,
   p_msg_data         => l_msg_data,
   p_init_msg_list    => FND_API.G_TRUE,
   p_event_type       => l_event_type, -- Bug 3029168
   p_source_id        => p_source_id,
   p_gl_transfer_mode => p_gl_transfer_mode,
   p_order_by1        => p_order_by1,
   p_order_by2        => p_order_by2,
   p_order_by3        => p_order_by3
  );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --
  retcode := 0 ;
  --COMMIT WORK; Bug#4310411
  --
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     PSB_MESSAGE_S.Print_Error(p_mode         => FND_FILE.LOG ,
                               p_print_header => FND_API.G_TRUE
                              );
     retcode := 2 ;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     PSB_MESSAGE_S.Print_Error(p_mode         => FND_FILE.LOG ,
                               p_print_header => FND_API.G_TRUE
                              );
     retcode := 2 ;

   WHEN OTHERS THEN
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,
                               l_api_name
                              );
     END IF ;
     PSB_MESSAGE_S.Print_Error(p_mode         => FND_FILE.LOG ,
                               p_print_header => FND_API.G_TRUE
                              );
     retcode := 2 ;

END Transfer_GLI_To_GL_CP;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                   PROCEDURE Create_Budget_Journal_CP                      |
 +===========================================================================*/
--
-- This IS the execution file FOR the concurrent program  Create Budget Journal
-- through Standard Report Submissions.
--
PROCEDURE Create_Budget_Journal_CP
(errbuf             OUT NOCOPY VARCHAR2,
 retcode            OUT NOCOPY VARCHAR2,
 p_worksheet_id     IN         NUMBER,
 p_budget_stage_id  IN         NUMBER,
 p_budget_year_id   IN         NUMBER,
 p_year_journal     IN         VARCHAR2,
 p_gl_transfer_mode IN         VARCHAR2,
 p_currency_code    IN         VARCHAR2 DEFAULT 'C', -- Bug 3029168
 p_auto_offset      IN         VARCHAR2,
 p_gl_budget_set_id IN         NUMBER,
 p_run_mode         IN         VARCHAR2,
 p_order_by1        IN         VARCHAR2,
 p_order_by2        IN         VARCHAR2,
 p_order_by3        IN         VARCHAR2
)
IS
  --
  l_api_name       CONSTANT VARCHAR2(30) := 'Create_Budget_Journal_CP';
  l_api_version    CONSTANT NUMBER       :=  1.0 ;
  --
  l_error_api_name          VARCHAR2(2000);
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  l_msg_index_out           NUMBER;
  --
BEGIN
  --
  Create_Budget_Journal_Fund
  (x_return_status    => l_return_status,
   p_worksheet_id     => p_worksheet_id,
   p_budget_stage_id  => p_budget_stage_id,
   p_budget_year_id   => p_budget_year_id,
   p_year_journal     => p_year_journal,
   p_gl_transfer_mode => p_gl_transfer_mode,
   p_auto_offset      => p_auto_offset,
   p_gl_budget_set_id => p_gl_budget_set_id,
   p_run_mode         => p_run_mode,
   p_order_by1        => p_order_by1,
   p_order_by2        => p_order_by2,
   p_order_by3        => p_order_by3,
   p_currency_code    => p_currency_code  -- Bug 3029168
  );
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --

  --
  -- Check whether the API performed the validation successfully. Otherwise,
  -- we will fail the concurrent program so that the user can fix it.
  --
  IF NVL(l_msg_count, 0) > 0 THEN

    -- Print error on the OUTPUT file.
    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.OUTPUT ,
                                p_print_header => FND_API.G_TRUE ) ;
    --
    retcode := 2 ;
    --
  ELSE
    retcode := 0 ;
  END IF;
  --
  --COMMIT WORK; -- Bug#4310411
  --
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     PSB_MESSAGE_S.Print_Error(p_mode         => FND_FILE.LOG ,
                               p_print_header => FND_API.G_TRUE
                              );
     retcode := 2 ;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     PSB_MESSAGE_S.Print_Error(p_mode         => FND_FILE.LOG ,
                               p_print_header => FND_API.G_TRUE
                              );
     retcode := 2 ;
   WHEN OTHERS THEN
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF ;
     PSB_MESSAGE_S.Print_Error(p_mode         => FND_FILE.LOG ,
                               p_print_header => FND_API.G_TRUE
                              );
     retcode := 2 ;

END Create_Budget_Journal_CP;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                   PROCEDURE Create Adopted Budget - post upgrade          |
 +===========================================================================*/

PROCEDURE Create_Adopted_Budget
(x_return_status    OUT NOCOPY VARCHAR2,
 p_worksheet_id     IN         NUMBER,
 p_budget_stage_id  IN         NUMBER,
 p_budget_year_id   IN         NUMBER,
 p_year_journal     IN         VARCHAR2,
 p_gl_transfer_mode IN         VARCHAR2,
 p_auto_offset      IN         VARCHAR2,
 p_gl_budget_set_id IN         NUMBER,
 p_order_by1        IN         VARCHAR2,
 p_order_by2        IN         VARCHAR2,
 p_order_by3        IN         VARCHAR2
)
IS

  l_year_start_date            DATE;
  l_year_end_date              DATE;
  l_budget_year_type_id        NUMBER;

  l_gl_year                    NUMBER;
  l_gl_period_num              NUMBER;
  l_gl_quarter_num             NUMBER;

  l_stage_sequence             NUMBER;

  l_period_name                VARCHAR2(15);
  l_period_start_date          DATE;
  l_period_end_date            DATE;
  /*FOR Bug No : 2543724 Start*/
  --commented the following two variables as they are NOT being used
  --AND also removed them FROM passing INTO Get_GL_Period procedure
  --l_next_period          VARCHAR2(15);
  --l_reversal_date        DATE;
  /*FOR Bug No : 2543724 END*/

  l_column                     NUMBER;

  l_req_id                     NUMBER;
  l_funding_status             VARCHAR2(1);
  l_validation_status          VARCHAR2(1);
  l_acct_overlap_status        VARCHAR2(1);

  l_event_number               NUMBER;
  l_accounting_date            DATE;
  l_period_status              VARCHAR2(1);

  l_return_status              VARCHAR2(1);
  l_msg_count                  NUMBER;
  l_msg_data                   VARCHAR2(2000);

  l_include_cbc_commit_balance VARCHAR2(1);
  l_include_cbc_oblig_balance  VARCHAR2(1);
  l_include_cbc_budget_balance VARCHAR2(1);

  l_gl_budget_set_id           NUMBER;

  CURSOR c_year
  IS
  SELECT start_date,
         end_date,
         budget_year_type_id
  FROM psb_budget_periods
  WHERE budget_period_id = p_budget_year_id;

  CURSOR c_stage
  IS
  SELECT sequence_number
  FROM psb_budget_stages
  WHERE budget_stage_id = p_budget_stage_id;

  CURSOR c_period
  IS
  SELECT budget_period_id,
         start_date,
         end_date
  FROM psb_budget_periods
  WHERE budget_period_type = 'P'
  AND parent_budget_period_id = p_budget_year_id
  ORDER BY start_date;

  CURSOR c_ws
  IS
  SELECT include_cbc_commit_balance,
         include_cbc_oblig_balance,
         include_cbc_budget_balance
  FROM psb_worksheets
  WHERE worksheet_id = p_worksheet_id;

BEGIN

  FND_MSG_PUB.initialize;

  Initialize
  (x_return_status => l_return_status,
   p_event_type    => 'BP',
   p_source_id     => p_worksheet_id,
   p_auto_offset   => p_auto_offset
  );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  FOR c_year_rec IN c_year LOOP
    l_year_start_date     := c_year_rec.start_date;
    l_year_end_date       := c_year_rec.end_date;
    l_budget_year_type_id := c_year_rec.budget_year_type_id;
  END LOOP;

  FOR c_ws_rec IN c_ws LOOP
    l_include_cbc_commit_balance := c_ws_rec.include_cbc_commit_balance;
    l_include_cbc_oblig_balance  := c_ws_rec.include_cbc_oblig_balance;
    l_include_cbc_budget_balance := c_ws_rec.include_cbc_budget_balance;
  END LOOP;

  FOR c_stage_rec IN c_stage LOOP
    l_stage_sequence := c_stage_rec.sequence_number;
  END LOOP;

      l_gl_budget_set_id := p_gl_budget_set_id;

    PSB_GL_BUDGET_SET_PVT.Validate_Account_Overlap
    (p_api_version       => 1.0,
     p_return_status     => l_return_status,
     p_msg_data          => l_msg_data,
     p_msg_count         => l_msg_count,
     p_gl_budget_set_id  => l_gl_budget_set_id,
     p_validation_status => l_acct_overlap_status
    );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_acct_overlap_status <> FND_API.G_RET_STS_SUCCESS THEN
      Add_Message('PSB', 'PSB_VAL_LINE');
    END IF;

    /*FOR Bug No : 2712019 Start*/
    --Validate the GL Budget year FOR all the gl budgets IN PSB GL Budget set
    --AND this procedure throws an error IF there IS no correponding year
    --opened FOR any GL Budget IN PSB GL Budget Set

    Validate_GL_Budget_Year
    (x_return_status    => l_return_status,
     p_gl_budget_set_id => p_gl_budget_set_id,
     p_year_start_date  => l_year_start_date,
     p_year_end_date    => l_year_end_date
    );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;
    /*FOR Bug No : 2712019 END*/

    -- continue validation regardless value of validation status

    IF p_year_journal = 'Y' THEN
      BEGIN
        Get_GL_Period
        (x_return_status        => l_return_status,
         x_effective_period_num => l_event_number,
         p_start_date           => l_year_start_date,
         x_period_name          => l_period_name,
         x_period_start_date    => l_accounting_date,
         x_period_end_date      => l_period_end_date,
         x_period_status        => l_period_status,
         x_period_year          => l_gl_year,
         x_period_number        => l_gl_period_num,
         x_quarter_number       => l_gl_quarter_num
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        Validate_Funding_Account
        (x_return_status     => l_return_status,
         p_event_type        => 'BP',
         p_source_id         => p_worksheet_id,
         p_stage_sequence    => l_stage_sequence,
         p_budget_year_id    => p_budget_year_id,
         p_gl_budget_set_id  => l_gl_budget_set_id,
         p_start_date        => l_accounting_date,
         x_validation_status => l_validation_status
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_funding_status := l_validation_status;
      END;
    ELSE
      BEGIN
        l_funding_status := FND_API.G_RET_STS_SUCCESS;

        FOR c_period_rec IN c_period LOOP
          Get_GL_Period
          (x_return_status        => l_return_status,
           x_effective_period_num => l_event_number,
           p_start_date           => c_period_rec.start_date,
           x_period_name          => l_period_name,
           x_period_start_date    => l_accounting_date,
           x_period_end_date      => l_period_end_date,
           x_period_status        => l_period_status,
           x_period_year          => l_gl_year,
           x_period_number        => l_gl_period_num,
           x_quarter_number       => l_gl_quarter_num
          );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          Validate_Funding_Account
          (x_return_status     => l_return_status,
           p_event_type        => 'BP',
           p_source_id         => p_worksheet_id,
           p_stage_sequence    => l_stage_sequence,
           p_budget_year_id    => p_budget_year_id,
           p_gl_budget_set_id  => l_gl_budget_set_id,
           p_start_date        => l_accounting_date,
           x_validation_status => l_validation_status
          );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF ((l_funding_status = FND_API.G_RET_STS_SUCCESS)
              AND
              (l_validation_status <> FND_API.G_RET_STS_SUCCESS)
             )
          THEN
            l_funding_status := l_validation_status;
          END IF;
        END LOOP;
      END;
    END IF;

    IF (l_funding_status <> FND_API.G_RET_STS_SUCCESS
        OR
        l_acct_overlap_status <> FND_API.G_RET_STS_SUCCESS
       )
    THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSE
      BEGIN
        IF p_year_journal = 'Y' THEN
          BEGIN
            Get_GL_Period
            (x_return_status        => l_return_status,
             x_effective_period_num => l_event_number,
             p_start_date           => l_year_start_date,
             x_period_name          => l_period_name,
             x_period_start_date    => l_accounting_date,
             x_period_end_date      => l_period_end_date,
             x_period_status        => l_period_status,
             x_period_year          => l_gl_year,
             x_period_number        => l_gl_period_num,
             x_quarter_number       => l_gl_quarter_num
            );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
            END IF;

            -- Include your changes here.
            l_column := 0;

            Create_JE_Lines_Fund
            (x_return_status    => l_return_status,
             p_worksheet_id     => p_worksheet_id,
             p_budget_stage_id  => p_budget_stage_id,
             p_budget_year_id   => p_budget_year_id ,
             p_detailed         => p_gl_transfer_mode,
             p_auto_offset      => p_auto_offset,
             p_gl_budget_set_id => p_gl_budget_set_id,
             p_start_date       => l_accounting_date,
             p_end_date         => l_year_end_date,
             p_column           => l_column,
             p_je_source        => g_source_name,
             p_je_category      => g_category_name,
             p_period_name      => l_period_name,
             p_gl_year          => l_gl_year,
             p_gl_period_num    => l_gl_period_num,
             p_gl_quarter_num   => l_gl_quarter_num
            );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
            END IF;
          END;
        ELSE
          BEGIN
            l_column := 0;

            FOR c_period_rec IN c_period LOOP
              l_column := l_column + 1;

              Get_GL_Period
              (x_return_status        => l_return_status,
               x_effective_period_num => l_event_number,
               p_start_date           => c_period_rec.start_date,
               x_period_name          => l_period_name,
               x_period_start_date    => l_accounting_date,
               x_period_end_date      => l_period_end_date,
               x_period_status        => l_period_status,
               x_period_year          => l_gl_year,
               x_period_number        => l_gl_period_num,
               x_quarter_number       => l_gl_quarter_num
              );

              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
              END IF;

              Create_JE_Lines_Fund
              (x_return_status    => l_return_status,
               p_worksheet_id     => p_worksheet_id,
               p_budget_stage_id  => p_budget_stage_id,
               p_budget_year_id   => p_budget_year_id ,
               p_detailed         => p_gl_transfer_mode,
               p_auto_offset      => p_auto_offset,
               p_gl_budget_set_id => p_gl_budget_set_id ,
               p_start_date       => l_accounting_date,
               p_end_date         => l_period_end_date,
               p_column           => l_column,
               p_je_source        => g_source_name,
               p_je_category      => g_category_name,
               p_period_name      => l_period_name,
               p_gl_year          => l_gl_year,
               p_gl_period_num    => l_gl_period_num,
               p_gl_quarter_num   => l_gl_quarter_num
              );

              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
              END IF;
            END LOOP;
          END;
        END IF;

      /*FOR Bug No : 2221409 Start*/
      --commented the following procedure as the same has to be
      --invoked after uploading all the lines INTO SLA tables
      /*
      PSB_BUDGET_REVISIONS_PVT.Create_Base_Budget_Revision
         (p_api_version       => 1.0,
          p_return_status     => l_return_status,
          p_msg_count         => l_msg_count,
          p_msg_data          => l_msg_data,
          p_worksheet_id      => p_worksheet_id);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      */
      /*FOR Bug No : 2221409 END*/

        --
        -- Starting the concurrent program
        --
        Submit_Concurrent_Request
        (x_return_status    => l_return_status,
         p_source_id        => p_worksheet_id,
         p_event_type       => 'BP',
         p_order_by1        => p_order_by1,
         p_order_by2        => p_order_by2,
         p_order_by3        => p_order_by3,
         p_gl_budget_set_id => l_gl_budget_set_id,
         p_budget_year_id   => p_budget_year_id
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END;
    END IF; -- no validation error found

  /*FOR Bug No : 2221409 Start*/

  PSB_BUDGET_REVISIONS_PVT.Create_Base_Budget_Revision
  (p_api_version   => 1.0,
   p_return_status => l_return_status,
   p_msg_count     => l_msg_count,
   p_msg_data      => l_msg_data,
   p_worksheet_id  => p_worksheet_id
  );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  /*FOR Bug No : 2221409 END*/
  -- Initialize API RETURN status to success

  x_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     /*FOR Bug No : 2712019 Start*/
     --ROLLBACK TO Adopted_Budget;
     ROLLBACK TO Create_Adopted_Budget;
     /*FOR Bug No : 2712019 END*/
     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     /*FOR Bug No : 2712019 Start*/
     --ROLLBACK TO Adopted_Budget;
     ROLLBACK TO Create_Adopted_Budget;
     /*FOR Bug No : 2712019 END*/
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
     /*FOR Bug No : 2712019 Start*/
     --ROLLBACK TO Adopted_Budget;
     ROLLBACK TO Create_Adopted_Budget;
     /*FOR Bug No : 2712019 END*/
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Create_Adopted_Budget;

/*===========================================================================+
 |                   PROCEDURE Create Adopted Budget - post upgrade          |
 +===========================================================================*/
--
-- This IS the execution file FOR the concurrent program  Create Adopted Budget
-- through Standard Report Submissions.
--
PROCEDURE Create_Adopted_Budget_CP
(errbuf             OUT NOCOPY VARCHAR2,
 retcode            OUT NOCOPY VARCHAR2,
 p_worksheet_id     IN         NUMBER,
 p_budget_stage_id  IN         NUMBER,
 p_budget_year_id   IN         NUMBER,
 p_year_journal     IN         VARCHAR2,
 p_gl_transfer_mode IN         VARCHAR2,
 p_auto_offset      IN         VARCHAR2,
 p_gl_budget_set_id IN         NUMBER
)
IS
  --
  l_api_name       CONSTANT VARCHAR2(30) := 'Create_Budget_Journal_CP';
  l_api_version    CONSTANT NUMBER       :=  1.0 ;
  --
  l_error_api_name          VARCHAR2(2000);
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  l_msg_index_out           NUMBER;
  --
BEGIN
  --
  Create_Adopted_Budget
  (x_return_status    => l_return_status,
   p_worksheet_id     => p_worksheet_id,
   p_budget_stage_id  => p_budget_stage_id,
   p_budget_year_id   => p_budget_year_id,
   p_year_journal     => p_year_journal,
   p_gl_transfer_mode => p_gl_transfer_mode,
   p_auto_offset      => p_auto_offset,
   p_gl_budget_set_id => p_gl_budget_set_id,
   p_order_by1        => NULL,
   p_order_by2        => NULL,
   p_order_by3        => NULL
  );
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --

  --
  -- Check whether the API performed the validation successfully. Otherwise,
  -- we will fail the concurrent program so that the user can fix it.
  --
  IF NVL(l_msg_count, 0) > 0 THEN

    -- Print error on the OUTPUT file.
    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.OUTPUT ,
                                p_print_header => FND_API.G_TRUE ) ;
    --
    retcode := 2 ;
    --
  ELSE
    retcode := 0 ;
  END IF;
  --
  --COMMIT WORK; --Bug#4310411
  --
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
                                 p_print_header =>  FND_API.G_TRUE ) ;
     retcode := 2 ;
     --
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
                                 p_print_header =>  FND_API.G_TRUE ) ;
     retcode := 2 ;
     --

   WHEN OTHERS THEN
     --
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
       --
       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
                                l_api_name  ) ;
     END IF ;
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
                                 p_print_header =>  FND_API.G_TRUE ) ;
     retcode := 2 ;
     --
END Create_Adopted_Budget_CP;

/* Start bug  3659531 */
-- This procedure returns the status of Budget Revision posting.
PROCEDURE Find_Document_Posting_Status (
 x_return_Status              OUT NOCOPY VARCHAR2, -- Bug#4460150
 x_document_posted_flag       OUT NOCOPY VARCHAR2, -- Bug#4460150
 p_document_type              IN         VARCHAR2,
 p_document_Id                IN         NUMBER)
 IS
 -- local variables
 l_api_name                     CONSTANT VARCHAR2(30) := 'Find Document Posting Status';

/* for bug 4654145 --> Check the psb_gl_interfaces table whether the BR has been posted or not */
l_no NUMBER;

BEGIN
  IF p_Document_Type = 'BR' THEN
    SELECT 1
    INTO l_no
    FROM psb_gl_interfaces
    WHERE worksheet_id = p_document_id
    AND   budget_source_type = p_document_type
    AND   rownum = 1;

    x_document_posted_flag := 'Y';
  END IF;

EXCEPTION
   WHEN no_data_found THEN
     x_document_posted_flag :=  'N';
   WHEN OTHERS THEN
     x_document_posted_flag  := 'N';

     -- set the status of the API
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
       fnd_msg_pub.add_exc_msg(G_PKG_NAME , l_api_name);
     END IF;

END Find_Document_Posting_Status;
 /* END bug 3659531 */


END PSB_GL_Interface_PVT;


/
