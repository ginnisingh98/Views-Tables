--------------------------------------------------------
--  DDL for Package Body PSB_BUDGET_REVISIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_BUDGET_REVISIONS_PVT" AS
/* $Header: PSBVBRVB.pls 120.39.12010000.7 2010/02/23 06:45:04 rkotha ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_BUDGET_REVISIONS_PVT';

  g_default_fte       CONSTANT NUMBER := 1;

  -- Bug#4675858
  -- This variable will be used to check whether the call is
  -- from "Revise_Elements"
  g_elem_projection  BOOLEAN := FALSE ;

  -- use this variable to determine if cost recalc is for new position
  g_new_position      BOOLEAN;

  -- use this variable to determine if this position should be revised
  g_revised_position  BOOLEAN;

  -- use this variable to determine if the revised fte for a position is zero.

  TYPE TokNameArray IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

  -- TokValArray contains values for all tokens
  TYPE TokValArray IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;

  -- Number of Message Tokens
  no_msg_tokens       NUMBER := 0;

  -- Message Token Name
  msg_tok_names       TokNameArray;

  -- Message Token Value
  msg_tok_val         TokValArray;

  -- For Bug#2150471
  TYPE g_ccid_rec_type IS RECORD
  ( ccid                NUMBER(15),
    apply_balance_flag  VARCHAR2(15)
  ) ;
  --
  TYPE g_ccid_rec_table IS TABLE OF g_ccid_rec_type INDEX BY BINARY_INTEGER;
  g_ccid_rec          g_ccid_rec_table;
  g_no_ccids          NUMBER;

  cursor c_Global_Rev (RevID NUMBER) is
    select nvl(global_budget_revision_id, budget_revision_id) global_revision_id
      from PSB_BUDGET_REVISIONS
     where budget_revision_id = RevID;

  cursor c_Distribute_Rev (GlobalRevID NUMBER, BudgetGroupID NUMBER) is
    select budget_revision_id
      from PSB_BUDGET_REVISIONS
     where nvl(global_budget_revision_id, budget_revision_id) = GlobalRevID
       and budget_group_id in
          (select budget_group_id
             from PSB_BUDGET_GROUPS
            where budget_group_type = 'R'
            start with budget_group_id = BudgetGroupID
          connect by prior parent_budget_group_id = budget_group_id);

  TYPE g_revpos_rec_type IS RECORD
  ( budget_revision_pos_line_id NUMBER, position_id NUMBER,
    budget_group_id NUMBER, effective_start_date DATE, effective_end_date DATE,
    revision_type VARCHAR2(1), revision_value_type VARCHAR2(1),
    revision_value NUMBER, note_id NUMBER, delete_flag BOOLEAN ) ;

  TYPE g_costs_rec_type IS RECORD
      (pay_element_id NUMBER, element_type VARCHAR2(1), element_cost NUMBER,
       start_date DATE, end_date DATE, currency_code VARCHAR2(15));

  TYPE g_dists_rec_type IS RECORD
      (ccid NUMBER, budget_group_id NUMBER, currency_code VARCHAR2(15),
       start_date DATE, end_date DATE, amount NUMBER, calc_rev BOOLEAN);

  TYPE g_revaccts_rec_type IS RECORD
      (ccid NUMBER, amount NUMBER);

  TYPE g_elem_assignments_rec_type IS RECORD
  ( budget_revision_id NUMBER, start_date DATE, end_date DATE,
    pay_element_id NUMBER, pay_element_option_id NUMBER, pay_basis VARCHAR2(10),
    element_value_type VARCHAR2(2), element_value NUMBER, use_in_calc BOOLEAN);

  TYPE g_elem_rates_rec_type IS RECORD
  ( budget_revision_id NUMBER, start_date DATE, end_date DATE,
    pay_element_id NUMBER, pay_element_option_id NUMBER, pay_basis VARCHAR2(10),
    element_value_type VARCHAR2(2), element_value NUMBER, formula_id NUMBER);

  TYPE g_fte_assignments_rec_type IS RECORD
      (start_date DATE, end_date DATE, fte NUMBER);

  TYPE g_wkh_assignments_rec_type IS RECORD
      (start_date DATE, end_date DATE, default_weekly_hours NUMBER);

  -- Bug#4310411 Start
  -- Declare three TYPES represnting required datatypes
  TYPE Number_Tbl_Type IS TABLE OF NUMBER        INDEX BY PLS_INTEGER;
  TYPE Char_Tbl_Type   IS TABLE OF VARCHAR2(100) INDEX BY PLS_INTEGER;
  TYPE Date_Tbl_Type   IS TABLE OF DATE          INDEX BY PLS_INTEGER;
  -- Bug#4310411 End

  TYPE g_revpos_tbl_type IS TABLE OF g_revpos_rec_type
      INDEX BY BINARY_INTEGER;

  TYPE g_costs_tbl_type IS TABLE OF g_costs_rec_type
      INDEX BY BINARY_INTEGER;

  TYPE g_dists_tbl_type IS TABLE OF g_dists_rec_type
      INDEX BY BINARY_INTEGER;

  TYPE g_revaccts_tbl_type IS TABLE OF g_revaccts_rec_type
      INDEX BY BINARY_INTEGER;

  TYPE g_elem_assignments_tbl_type IS TABLE OF g_elem_assignments_rec_type
      INDEX BY BINARY_INTEGER;

  TYPE g_elem_rates_tbl_type IS TABLE OF g_elem_rates_rec_type
      INDEX BY BINARY_INTEGER;

  TYPE g_fte_assignments_tbl_type IS TABLE OF g_fte_assignments_rec_type
      INDEX BY BINARY_INTEGER;

  TYPE g_wkh_assignments_tbl_type IS TABLE OF g_wkh_assignments_rec_type
      INDEX BY BINARY_INTEGER;

  g_revpos                g_revpos_tbl_type;
  g_num_revpos            NUMBER;

  g_costs                 g_costs_tbl_type;
  g_num_costs             NUMBER;

  g_dists                 g_dists_tbl_type;
  g_num_dists             NUMBER;

  g_revaccts              g_revaccts_tbl_type;
  g_num_revaccts          NUMBER;

  g_elem_assignments      g_elem_assignments_tbl_type;
  g_num_elem_assignments  NUMBER;

  g_elem_rates            g_elem_rates_tbl_type;
  g_num_elem_rates        NUMBER;

  g_fte_assignments       g_fte_assignments_tbl_type;
  g_num_fte_assignments   NUMBER;

  g_wkh_assignments       g_wkh_assignments_tbl_type;
  g_num_wkh_assignments   NUMBER;

  -- Bug No 2135165
  g_brr_rule_set_id       NUMBER;
  g_brr_sob_id            NUMBER;

  -- bug no 3439168
  TYPE g_last_update_flag_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  g_last_update_flag_tbl g_last_update_flag_tbl_type;
  -- bug no 3439168

PROCEDURE message_token
( tokname  IN  VARCHAR2,
  tokval   IN  VARCHAR2
);

PROCEDURE add_message
(appname  IN  VARCHAR2,
 msgname  IN  VARCHAR2);


/*===========================================================================+
 |                             PROCEDURE pd                                  |
 +===========================================================================*/
-- API to print debug information, used during only development.
PROCEDURE pd( p_message   IN     VARCHAR2)
IS
BEGIN
  NULL ;
  --DBMS_OUTPUT.Put_Line(p_message) ;
END pd ;
/*---------------------------------------------------------------------------*/


/*==========================================================================+
 |                       FUNCTION Get_Rounded_Amount                        |
 +==========================================================================*/
FUNCTION Get_Rounded_Amount
( p_currency_code             IN       VARCHAR2,
  p_amount                    IN       NUMBER
)  RETURN NUMBER IS

  l_precision                   NUMBER;
  l_minimum_accountable_unit    NUMBER;
  l_rounded_amount              NUMBER;

BEGIN

    SELECT minimum_accountable_unit,
           precision
    INTO   l_minimum_accountable_unit,
           l_precision
    FROM   fnd_currencies
    WHERE  currency_code = p_currency_code
    AND    enabled_flag = 'Y'
    AND    currency_flag = 'Y'
    AND    (start_date_active <= sysdate or start_date_active is null)
    AND    (end_date_active >= sysdate or end_date_active is null);

  -- General Ledger rounds distributed amount(distributed to budget periods) to
  -- minimum accountable unit of the currency. This is to handle
  -- difference resulting from amounts that cannot be divided exactly

  l_minimum_accountable_unit := nvl(l_minimum_accountable_unit, power( 10, (-1 * l_precision)));
  --
  -- Calculate Rounded Amount

  l_rounded_amount := round( p_amount / l_minimum_accountable_unit ) * l_minimum_accountable_unit;

  RETURN(l_rounded_amount);

EXCEPTION

  WHEN OTHERS THEN
    RETURN p_amount;

END Get_Rounded_Amount;

/*==========================================================================+
 |                       PROCEDURE Delete_Row                               |
 +==========================================================================*/

PROCEDURE Delete_Row
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_budget_revision_id  IN      NUMBER
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'DELETE_ROW';
  l_api_version         CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     DELETE_ROW;

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Perform the delete

  delete FROM PSB_BUDGET_REVISIONS
  WHERE BUDGET_REVISION_ID = P_BUDGET_REVISION_ID;

  if (sql%notfound) THEN
    raise no_data_found;
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                             p_data  => p_msg_data);

  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) THEN
    commit work;
  END IF;


EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     rollback to DELETE_ROW;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     rollback to DELETE_ROW;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

   WHEN OTHERS THEN
     rollback to DELETE_ROW;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

END Delete_Row;

/*==========================================================================+
 |                       PROCEDURE Create_Budget_Revision                   |
 +==========================================================================*/
PROCEDURE Create_Budget_Revision
( p_api_version                    IN   NUMBER,
  p_init_msg_list                  IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit                         IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level               IN   NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_return_status                  OUT  NOCOPY  VARCHAR2,
  p_msg_count                      OUT  NOCOPY  NUMBER,
  p_msg_data                       OUT  NOCOPY  VARCHAR2,
  p_budget_revision_id          IN OUT  NOCOPY   NUMBER,
  p_budget_group_id                 IN   NUMBER  := FND_API.G_MISS_NUM,
  p_gl_budget_set_id                IN   NUMBER  := FND_API.G_MISS_NUM,
  p_hr_budget_id                    IN   NUMBER  := FND_API.G_MISS_NUM,
  p_justification                   IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_from_gl_period_name             IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_to_gl_period_name               IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_currency_code                   IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_effective_start_date            IN   DATE := FND_API.G_MISS_DATE,
  p_effective_end_date              IN   DATE := FND_API.G_MISS_DATE,
  p_budget_revision_type            IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_transaction_type                IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_permanent_revision              IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_revise_by_position              IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_balance_type                    IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_global_budget_revision          IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_global_budget_revision_id       IN   NUMBER := FND_API.G_MISS_NUM,
  p_requestor                       IN   NUMBER := FND_API.G_MISS_NUM,
  p_parameter_set_id                IN   NUMBER := FND_API.G_MISS_NUM,
  p_constraint_set_id               IN   NUMBER := FND_API.G_MISS_NUM,
  p_submission_date                 IN   DATE := FND_API.G_MISS_DATE,
  p_submission_status               IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_approval_orig_system            IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_approval_override_by            IN   NUMBER := FND_API.G_MISS_NUM,
  p_freeze_flag                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_request_id                      IN   NUMBER := FND_API.G_MISS_NUM,
  p_base_line_revision              IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute1                      IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute2                      IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute3                      IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute4                      IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute5                      IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute6                      IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute7                      IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute8                      IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute9                      IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute10                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute11                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute12                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute13                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute14                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute15                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute16                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute17                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute18                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute19                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute20                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute21                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute22                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute23                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute24                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute25                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute26                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute27                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute28                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute29                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute30                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_context                         IN   VARCHAR2 := FND_API.G_MISS_CHAR
) IS

  l_api_name                        CONSTANT VARCHAR2(30) := 'Create_Budget_Revision';
  l_api_version                     CONSTANT NUMBER       := 1.0;

  l_budget_revision_id              NUMBER;

  cursor c_Seq is
    select psb_budget_revisions_s.nextval budget_revision_id
      from dual;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Create_Budget_Revision;

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  IF FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  if p_budget_revision_id is not null then

    update PSB_BUDGET_REVISIONS
       set justification = decode(p_justification, FND_API.G_MISS_CHAR, justification, p_justification),
           from_gl_period_name = decode(p_from_gl_period_name,FND_API.G_MISS_CHAR, from_gl_period_name, p_from_gl_period_name),
           to_gl_period_name = decode(p_to_gl_period_name, FND_API.G_MISS_CHAR, to_gl_period_name, p_to_gl_period_name),
           currency_code = decode(p_currency_code, FND_API.G_MISS_CHAR, currency_code, p_currency_code),
           effective_start_date = decode(p_effective_start_date, FND_API.G_MISS_DATE, effective_start_date, p_effective_start_date),
           effective_end_date = decode(p_effective_end_date, FND_API.G_MISS_DATE, effective_end_date, p_effective_end_date),
           hr_budget_id = decode(p_hr_budget_id, FND_API.G_MISS_NUM, hr_budget_id, p_hr_budget_id),
           budget_revision_type = decode(p_budget_revision_type, FND_API.G_MISS_CHAR, budget_revision_type, p_budget_revision_type),
           transaction_type = decode(p_transaction_type, FND_API.G_MISS_CHAR, transaction_type, p_transaction_type),
           permanent_revision = decode(p_permanent_revision, FND_API.G_MISS_CHAR, permanent_revision, p_permanent_revision),
           revise_by_position = decode(p_revise_by_position, FND_API.G_MISS_CHAR, revise_by_position, p_revise_by_position),
           balance_type = decode(p_balance_type, FND_API.G_MISS_CHAR, balance_type, p_balance_type),
           global_budget_revision = decode(p_global_budget_revision, FND_API.G_MISS_CHAR,global_budget_revision,p_global_budget_revision),
           global_budget_revision_id = decode(p_global_budget_revision_id, FND_API.G_MISS_NUM,global_budget_revision_id,p_global_budget_revision_id),
           parameter_set_id = decode(p_parameter_set_id, FND_API.G_MISS_NUM, parameter_set_id, p_parameter_set_id),
           constraint_set_id = decode(p_constraint_set_id, FND_API.G_MISS_NUM, constraint_set_id, p_constraint_set_id),
           submission_date = decode(p_submission_date, FND_API.G_MISS_DATE, submission_date, p_submission_date),
           submission_status = decode(p_submission_status, FND_API.G_MISS_CHAR, submission_status, p_submission_status),
           approval_orig_system = decode(p_approval_orig_system, FND_API.G_MISS_CHAR, approval_orig_system, p_approval_orig_system),
           approval_override_by  = decode(p_approval_override_by, FND_API.G_MISS_NUM, approval_override_by, p_approval_override_by),
           freeze_flag = decode(p_freeze_flag, FND_API.G_MISS_CHAR, freeze_flag, p_freeze_flag),
           request_id = decode(p_request_id, FND_API.G_MISS_NUM, request_id, p_request_id),
           base_line_revision = decode(p_base_line_revision, FND_API.G_MISS_CHAR, base_line_revision, p_base_line_revision),
           last_update_date = sysdate,
           last_updated_by = FND_GLOBAL.USER_ID,
           last_update_login = FND_GLOBAL.LOGIN_ID,
           attribute1 = decode(p_attribute1, FND_API.G_MISS_CHAR, attribute1, p_attribute1),
           attribute2 = decode(p_attribute2, FND_API.G_MISS_CHAR, attribute2, p_attribute2),
           attribute3 = decode(p_attribute3, FND_API.G_MISS_CHAR, attribute3, p_attribute3),
           attribute4 = decode(p_attribute4, FND_API.G_MISS_CHAR, attribute4, p_attribute4),
           attribute5 = decode(p_attribute5, FND_API.G_MISS_CHAR, attribute5, p_attribute5),
           attribute6 = decode(p_attribute6, FND_API.G_MISS_CHAR, attribute6, p_attribute6),
           attribute7 = decode(p_attribute7, FND_API.G_MISS_CHAR, attribute7, p_attribute7),
           attribute8 = decode(p_attribute8, FND_API.G_MISS_CHAR, attribute8, p_attribute8),
           attribute9 = decode(p_attribute9, FND_API.G_MISS_CHAR, attribute9, p_attribute9),
           attribute10 = decode(p_attribute10, FND_API.G_MISS_CHAR, attribute10, p_attribute10),
           attribute11 = decode(p_attribute11, FND_API.G_MISS_CHAR, attribute11, p_attribute11),
           attribute12 = decode(p_attribute12, FND_API.G_MISS_CHAR, attribute12, p_attribute12),
           attribute13 = decode(p_attribute13, FND_API.G_MISS_CHAR, attribute13, p_attribute13),
           attribute14 = decode(p_attribute14, FND_API.G_MISS_CHAR, attribute14, p_attribute14),
           attribute15 = decode(p_attribute15, FND_API.G_MISS_CHAR, attribute15, p_attribute15),
           attribute16 = decode(p_attribute16, FND_API.G_MISS_CHAR, attribute16, p_attribute16),
           attribute17 = decode(p_attribute17, FND_API.G_MISS_CHAR, attribute17, p_attribute17),
           attribute18 = decode(p_attribute18, FND_API.G_MISS_CHAR, attribute18, p_attribute18),
           attribute19 = decode(p_attribute19, FND_API.G_MISS_CHAR, attribute19, p_attribute19),
           attribute20 = decode(p_attribute20, FND_API.G_MISS_CHAR, attribute20, p_attribute20),
           attribute21 = decode(p_attribute21, FND_API.G_MISS_CHAR, attribute21, p_attribute21),
           attribute22 = decode(p_attribute22, FND_API.G_MISS_CHAR, attribute22, p_attribute22),
           attribute23 = decode(p_attribute23, FND_API.G_MISS_CHAR, attribute23, p_attribute23),
           attribute24 = decode(p_attribute24, FND_API.G_MISS_CHAR, attribute24, p_attribute24),
           attribute25 = decode(p_attribute25, FND_API.G_MISS_CHAR, attribute25, p_attribute25),
           attribute26 = decode(p_attribute26, FND_API.G_MISS_CHAR, attribute26, p_attribute26),
           attribute27 = decode(p_attribute27, FND_API.G_MISS_CHAR, attribute27, p_attribute27),
           attribute28 = decode(p_attribute28, FND_API.G_MISS_CHAR, attribute28, p_attribute28),
           attribute29 = decode(p_attribute29, FND_API.G_MISS_CHAR, attribute29, p_attribute29),
           attribute30 = decode(p_attribute30, FND_API.G_MISS_CHAR, attribute30, p_attribute30),
           context = decode(p_context,FND_API.G_MISS_CHAR, context, p_context)
     where budget_revision_id = p_budget_revision_id;

     IF (SQL%NOTFOUND) THEN
       RAISE NO_DATA_FOUND;
     END IF;

  else

    for c_Seq_Rec in c_Seq loop
      l_budget_revision_id := c_Seq_Rec.budget_revision_id;
    end loop;

    INSERT INTO PSB_BUDGET_REVISIONS
     (budget_revision_id,
      justification,
      budget_group_id,
      gl_budget_set_id,
      hr_budget_id,
      from_gl_period_name,
      to_gl_period_name,
      currency_code,
      effective_start_date,
      effective_end_date,
      budget_revision_type,
      transaction_type,
      permanent_revision,
      revise_by_position,
      balance_type,
      requestor,
      parameter_set_id,
      constraint_set_id,
      submission_date,
      submission_status,
      approval_orig_system,
      approval_override_by,
      freeze_flag,
      request_id,
      base_line_revision,
      global_budget_revision,
      global_budget_revision_id,
      last_update_date,
      last_updated_by,
      last_update_login,
      created_by,
      creation_date,
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
      attribute16,
      attribute17,
      attribute18,
      attribute19,
      attribute20,
      attribute21,
      attribute22,
      attribute23,
      attribute24,
      attribute25,
      attribute26,
      attribute27,
      attribute28,
      attribute29,
      attribute30,
      context)
  values (l_budget_revision_id,
          decode(p_justification,FND_API.G_MISS_CHAR,null,p_justification),
          decode(p_budget_group_id,FND_API.G_MISS_NUM,null,p_budget_group_id),
          decode(p_gl_budget_set_id,FND_API.G_MISS_NUM,null,p_gl_budget_set_id),
          decode(p_hr_budget_id,FND_API.G_MISS_NUM,null,p_hr_budget_id),
          decode(p_from_gl_period_name,FND_API.G_MISS_CHAR,null,p_from_gl_period_name),
          decode(p_to_gl_period_name,FND_API.G_MISS_CHAR,null,p_to_gl_period_name),
          decode(p_currency_code,FND_API.G_MISS_CHAR,null,p_currency_code),
          decode(p_effective_start_date,FND_API.G_MISS_DATE,null,p_effective_start_date),
          decode(p_effective_end_date,FND_API.G_MISS_DATE,null,p_effective_end_date),
          decode(p_budget_revision_type,FND_API.G_MISS_CHAR,null,p_budget_revision_type),
          decode(p_transaction_type,FND_API.G_MISS_CHAR,null,p_transaction_type),
          decode(p_permanent_revision,FND_API.G_MISS_CHAR,null,p_permanent_revision),
          decode(p_revise_by_position,FND_API.G_MISS_CHAR,null,p_revise_by_position),
          decode(p_balance_type,FND_API.G_MISS_CHAR,'YTD',p_balance_type),
          decode(p_requestor,FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, -1, FND_GLOBAL.USER_ID, p_requestor),
          decode(p_parameter_set_id,FND_API.G_MISS_NUM,null,p_parameter_set_id),
          decode(p_constraint_set_id,FND_API.G_MISS_NUM,null,p_constraint_set_id),
          decode(p_submission_date,FND_API.G_MISS_DATE,null,p_submission_date),
          decode(p_submission_status,FND_API.G_MISS_CHAR,null,p_submission_status),
          decode(p_approval_orig_system,FND_API.G_MISS_CHAR,null,p_approval_orig_system),
          decode(p_approval_override_by,FND_API.G_MISS_NUM,null,p_approval_override_by),
          decode(p_freeze_flag,FND_API.G_MISS_CHAR,null,p_freeze_flag),
          decode(p_request_id,FND_API.G_MISS_NUM,null,p_request_id),
          decode(p_base_line_revision,FND_API.G_MISS_CHAR,null,p_base_line_revision),
          decode(p_global_budget_revision,FND_API.G_MISS_CHAR,null,p_global_budget_revision),
          decode(p_global_budget_revision_id,FND_API.G_MISS_NUM,null,p_global_budget_revision_id),
          sysdate,
          FND_GLOBAL.USER_ID,
          FND_GLOBAL.LOGIN_ID,
          FND_GLOBAL.USER_ID,
          sysdate,
          decode(p_attribute1,FND_API.G_MISS_CHAR,null,p_attribute1),
          decode(p_attribute2,FND_API.G_MISS_CHAR,null,p_attribute2),
          decode(p_attribute3,FND_API.G_MISS_CHAR,null,p_attribute3),
          decode(p_attribute4,FND_API.G_MISS_CHAR,null,p_attribute4),
          decode(p_attribute5,FND_API.G_MISS_CHAR,null,p_attribute5),
          decode(p_attribute6,FND_API.G_MISS_CHAR,null,p_attribute6),
          decode(p_attribute7,FND_API.G_MISS_CHAR,null,p_attribute7),
          decode(p_attribute8,FND_API.G_MISS_CHAR,null,p_attribute8),
          decode(p_attribute9,FND_API.G_MISS_CHAR,null,p_attribute9),
          decode(p_attribute10,FND_API.G_MISS_CHAR,null,p_attribute10),
          decode(p_attribute11,FND_API.G_MISS_CHAR,null,p_attribute11),
          decode(p_attribute12,FND_API.G_MISS_CHAR,null,p_attribute12),
          decode(p_attribute13,FND_API.G_MISS_CHAR,null,p_attribute13),
          decode(p_attribute14,FND_API.G_MISS_CHAR,null,p_attribute14),
          decode(p_attribute15,FND_API.G_MISS_CHAR,null,p_attribute15),
          decode(p_attribute16,FND_API.G_MISS_CHAR,null,p_attribute16),
          decode(p_attribute17,FND_API.G_MISS_CHAR,null,p_attribute17),
          decode(p_attribute18,FND_API.G_MISS_CHAR,null,p_attribute18),
          decode(p_attribute19,FND_API.G_MISS_CHAR,null,p_attribute19),
          decode(p_attribute20,FND_API.G_MISS_CHAR,null,p_attribute20),
          decode(p_attribute21,FND_API.G_MISS_CHAR,null,p_attribute21),
          decode(p_attribute22,FND_API.G_MISS_CHAR,null,p_attribute22),
          decode(p_attribute23,FND_API.G_MISS_CHAR,null,p_attribute23),
          decode(p_attribute24,FND_API.G_MISS_CHAR,null,p_attribute24),
          decode(p_attribute25,FND_API.G_MISS_CHAR,null,p_attribute25),
          decode(p_attribute26,FND_API.G_MISS_CHAR,null,p_attribute26),
          decode(p_attribute27,FND_API.G_MISS_CHAR,null,p_attribute27),
          decode(p_attribute28,FND_API.G_MISS_CHAR,null,p_attribute28),
          decode(p_attribute29,FND_API.G_MISS_CHAR,null,p_attribute29),
          decode(p_attribute30,FND_API.G_MISS_CHAR,null,p_attribute30),
          decode(p_context,FND_API.G_MISS_CHAR,null,p_context));

  end if;

  p_budget_revision_id := l_budget_revision_id;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard check of p_commit.

  IF FND_API.to_Boolean (p_commit) THEN
    commit work;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                             p_data  => p_msg_data);

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     rollback to Create_Budget_Revision;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     rollback to Create_Budget_Revision;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

   WHEN OTHERS THEN
     rollback to Create_Budget_Revision;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);
END Create_Budget_Revision;

/* ----------------------------------------------------------------------- */

PROCEDURE Cache_Revision_Variables
(p_return_status          OUT  NOCOPY   VARCHAR2,
 p_budget_revision_id     IN   NUMBER
) IS

  l_return_status         VARCHAR2(1);

  cursor c_Budget_Revision is
    select budget_group_id,
           budget_revision_type,
           transaction_type,
           permanent_revision,
           nvl(revise_by_position,'N') revise_by_position,
           balance_type,
           parameter_set_id,
           constraint_set_id,
           gl_budget_set_id,
           from_gl_period_name,
           to_gl_period_name,
           effective_start_date,
           effective_end_date,
           freeze_flag,
           base_line_revision,
           currency_code,
           approval_orig_system,
           approval_override_by,
           nvl(global_budget_revision_id, budget_revision_id) global_budget_revision_id,
           hr_budget_id
     from  PSB_BUDGET_REVISIONS
    where  budget_revision_id = p_budget_revision_id;

  cursor c_BG is
    select nvl(root_budget_group_id, budget_group_id) root_budget_group_id,
           nvl(set_of_books_id, root_set_of_books_id) set_of_books_id,
           nvl(business_group_id, root_business_group_id) business_group_id,
           name
      from PSB_BUDGET_GROUPS_V
     where budget_group_id = g_budget_group_id;

  cursor c_Sob is
    select currency_code,
           chart_of_accounts_id,
           name,
           enable_budgetary_control_flag
      from GL_SETS_OF_BOOKS
     where set_of_books_id = g_set_of_books_id;

  cursor c_gl_dates is
    select period_name, start_date,end_date
      from gl_period_statuses
     where application_id = 101
       and set_of_books_id = g_set_of_books_id
       and period_name in (g_from_gl_period_name, g_to_gl_period_name);

  cursor c_gl_dates_br is
    select min(start_date) start_date, max(end_date) end_date
      from GL_PERIOD_STATUSES
     where application_id = 101
       and set_of_books_id = g_set_of_books_id
       and period_name in
          (select b.gl_period_name from psb_budget_revision_lines a, psb_budget_revision_accounts b
            where a.budget_revision_id = p_budget_revision_id
              and b.budget_revision_acct_line_id = a.budget_revision_acct_line_id);

  cursor c_position_dates_br is
    select min(effective_start_date) start_date, max(effective_end_date) end_date
      from PSB_BUDGET_REVISION_POSITIONS a, PSB_BUDGET_REVISION_POS_LINES b
     where b.budget_revision_id = p_budget_revision_id
       and a.budget_revision_pos_line_id = b.budget_revision_pos_line_id;

  cursor c_position_exists is
    select 'Exists'
      from dual
     where exists
          (select a.position_id, a.effective_start_date, a.effective_end_date, a.budget_group_id
             from PSB_POSITIONS a,
                 (select budget_group_id from PSB_BUDGET_GROUPS
                   start with budget_group_id = g_budget_group_id
                 connect by prior budget_group_id = parent_budget_group_id) b
            where a.data_extract_id = g_data_extract_id
              and a.budget_group_id = b.budget_group_id);

  cursor c_constraint_set is
    select name, constraint_threshold
      from PSB_CONSTRAINT_SETS_V
     where constraint_set_id = g_constraint_set_id;

begin

   for c_Budget_Revision_Rec in c_Budget_Revision loop
     g_budget_group_id      := c_Budget_Revision_Rec.budget_group_id;
     g_budget_revision_type := c_Budget_Revision_Rec.budget_revision_type;
     g_transaction_type     := c_Budget_Revision_Rec.transaction_type;
     g_permanent_revision   := c_Budget_Revision_Rec.permanent_revision;
     g_revise_by_position   := c_Budget_Revision_Rec.revise_by_position;
     g_balance_type         := c_Budget_Revision_Rec.balance_type;
     g_from_gl_period_name  := c_Budget_Revision_Rec.from_gl_period_name;
     g_to_gl_period_name    := c_Budget_Revision_Rec.to_gl_period_name;
     g_effective_start_date := c_Budget_Revision_Rec.effective_start_date;
     g_effective_end_date   := c_Budget_Revision_Rec.effective_end_date;
     g_parameter_set_id     := c_Budget_Revision_Rec.parameter_set_id;
     /* For Bug No. 2810621 Start */
     g_constraint_set_id    := fnd_profile.value('PSB_DEFAULT_CONSTRAINT_SET_BUDGET_REVISIONS');
     /* For Bug No. 2810621 End */
     g_freeze_flag          := c_Budget_Revision_Rec.freeze_flag;
     g_base_line_revision   := c_Budget_Revision_Rec.base_line_revision;
     g_approval_orig_system := c_Budget_Revision_Rec.approval_orig_system;
     g_approval_override_by := c_Budget_Revision_Rec.approval_override_by;
     g_currency_code        := c_Budget_Revision_Rec.currency_code;
     g_gl_budget_set_id     := c_Budget_Revision_Rec.gl_budget_set_id;
     g_global_budget_revision_id := c_Budget_Revision_Rec.global_budget_revision_id;
     g_hr_budget_id         := c_Budget_Revision_Rec.hr_budget_id;
   end loop;

   if g_global_budget_revision_id is null then
     g_global_revision := FND_API.G_TRUE;
   else
     g_global_revision := FND_API.G_FALSE;
   end if;

   for c_BG_Rec in c_BG loop
     g_root_budget_group_id := c_BG_Rec.root_budget_group_id;
     g_set_of_books_id      := c_BG_Rec.set_of_books_id;
     g_business_group_id    := c_BG_Rec.business_group_id;
     g_budget_group_name    := c_BG_Rec.name;
   End loop;

   for c_gl_dates_rec in c_gl_dates Loop
     if g_from_gl_period_name = g_to_gl_period_name then
       g_from_date := c_gl_dates_rec.start_date;
       g_to_date := c_gl_dates_rec.end_date;
     else
     begin

       if c_gl_dates_rec.period_name = g_from_gl_period_name then
         g_from_date := c_gl_dates_rec.start_date;
       elsif c_gl_dates_rec.period_name = g_to_gl_period_name then
        g_to_date := c_gl_dates_rec.end_date;
       end if;

     end;
     end if;
   end loop;

   if (g_from_date is null or g_to_date is null) then
   begin

     for c_gl_dates_rec in c_gl_dates_br loop
       g_from_date := c_gl_dates_rec.start_date;
       g_to_date := c_gl_dates_rec.end_date;
     end loop;

   end;
   end if;

   if (g_effective_start_date is null or g_effective_end_date is null) then
   begin

     for c_position_dates_rec in c_position_dates_br loop
       g_effective_start_date := c_position_dates_rec.start_date;
       g_effective_end_date := c_position_dates_rec.end_date;
     end loop;

   end;
   else
     g_position_mass_revision := TRUE;
   end if;

   if g_revise_by_position = 'Y' then
   begin

     g_data_extract_id := Find_System_Data_Extract(g_budget_group_id);

     for c_position_exists_rec in c_position_exists loop
       g_position_exists := TRUE;
     end loop;

     if g_position_exists then
     begin

       PSB_WS_POS1.Cache_Named_Attributes
          (p_return_status => l_return_status,
           p_business_group_id => g_business_group_id);

       if l_return_status <> FND_API.G_RET_STS_SUCCESS then
         raise FND_API.G_EXC_ERROR;
       end if;

     end;
     end if;

   end;
   end if;

   for c_Sob_Rec in c_Sob loop
     g_func_currency := c_Sob_Rec.currency_code;
     g_flex_code             := c_Sob_Rec.chart_of_accounts_id;
     g_set_of_books_name     := c_Sob_Rec.name;
     g_budgetary_control     := c_Sob_Rec.enable_budgetary_control_flag;
   end loop;

  FND_PROFILE.GET(name => 'PSB_CREATE_ZERO_BALANCE_ACCT',
                  val => g_create_zero_bal);

  if g_create_zero_bal is null then
    g_create_zero_bal := 'Y';
  end if;

  g_gl_journal_source := 'Budget Journal';
  g_gl_journal_category := 'Budget';

  for c_constraint_set_rec in c_constraint_set loop
    g_constraint_set_name := c_constraint_set_rec.name;
    g_constraint_threshold := c_constraint_set_rec.constraint_threshold;
  end loop;

  g_flex_delimiter := FND_FLEX_EXT.Get_Delimiter
                         (application_short_name => 'SQLGL',
                          key_flex_code => 'GL#',
                          structure_number => g_flex_code);

  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

End Cache_Revision_Variables;

/*===========================================================================+
 |                      PROCEDURE Create_Revision_Accounts                   |
 +===========================================================================*/
PROCEDURE Create_Revision_Accounts
( p_api_version                  IN      NUMBER,
  p_init_msg_list                IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                       IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level             IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status                OUT  NOCOPY  VARCHAR2,
  p_msg_count                    OUT  NOCOPY  NUMBER,
  p_msg_data                     OUT  NOCOPY  VARCHAR2,
  p_budget_revision_id           IN      NUMBER ,
  p_budget_revision_acct_line_id IN OUT NOCOPY  NUMBER,
  p_code_combination_id          IN      NUMBER,
  p_budget_group_id              IN      NUMBER,
  p_position_id                  IN      NUMBER := FND_API.G_MISS_NUM,
  p_gl_period_name               IN      VARCHAR2,
  p_gl_budget_version_id         IN      NUMBER := FND_API.G_MISS_NUM,
  p_currency_code                IN      VARCHAR2,
  p_budget_balance               IN      NUMBER,
  p_revision_type                IN      VARCHAR2,
  p_revision_value_type          IN      VARCHAR2,
  p_revision_amount              IN      NUMBER,
  p_funds_status_code            IN      VARCHAR2,
  p_funds_result_code            IN      VARCHAR2,
  p_funds_control_timestamp      IN      DATE,
  p_note_id                      IN      NUMBER,
  p_freeze_flag                  IN      VARCHAR2,
  p_view_line_flag               IN      VARCHAR2,
  p_functional_transaction       IN      VARCHAR2 := NULL
)
IS
  --
  l_api_name              CONSTANT  VARCHAR2(30) := 'Create_Revision_Accounts';
  l_api_version           CONSTANT  NUMBER       := 1.0;
  l_return_status                   VARCHAR2(1);
  l_msg_count                       NUMBER;
  l_msg_data                        VARCHAR2(2000);
  --
  l_account_type                    VARCHAR2(1);
  l_template_id                     NUMBER;
  l_budget_revision_acct_line_id    NUMBER;
  l_budget_version_id               NUMBER;
  l_start_date                      DATE;
  l_end_date                        DATE;
  l_global_revision_id              NUMBER;
  l_concat_segments                 VARCHAR2(2000);
  sql_bra                           VARCHAR2(2000);
  --
  TYPE l_sql_bra_cursor_type IS REF CURSOR;
  l_sql_bra_csr                     l_sql_bra_cursor_type;
  l_first_br_al_id                  NUMBER;
  --
  CURSOR l_gl_dates_csr
  IS
  SELECT start_date, end_date
  FROM   gl_period_statuses
  WHERE  application_id  = 101
  AND    set_of_books_id = g_set_of_books_id
  AND    period_name     = p_gl_period_name;
  --
BEGIN
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  Cache_Revision_Variables
  ( p_return_status       => l_return_status,
    p_budget_revision_id  => p_budget_revision_id ) ;
  --
  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  For l_gl_dates_rec in l_gl_dates_csr Loop
    l_start_date := l_gl_dates_rec.start_date;
    l_end_date   := l_gl_dates_rec.end_date;
  End Loop;

  if nvl(p_gl_budget_version_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM then

    PSB_GL_BUDGET_PVT.Find_GL_Budget
    ( p_api_version          => 1.0,
      p_return_status        => l_return_status,
      p_msg_count            => l_msg_count,
      p_msg_data             => l_msg_data,
      p_gl_budget_set_id     => g_gl_budget_set_id,
      p_code_combination_id  => p_code_combination_id,
      p_start_date           => l_start_date,
      p_dual_posting_type    => 'A',
      p_gl_budget_version_id => l_budget_version_id
    ) ;
    --
    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    if ( l_budget_version_id is null and g_permanent_revision = 'Y' ) then

      PSB_GL_BUDGET_PVT.Find_GL_Budget
      ( p_api_version          => 1.0,
        p_return_status        => l_return_status,
        p_msg_count            => l_msg_count,
        p_msg_data             => l_msg_data,
        p_gl_budget_set_id     => g_gl_budget_set_id,
        p_code_combination_id  => p_code_combination_id,
        p_start_date           => l_start_date,
        p_gl_budget_version_id => l_budget_version_id
      ) ;
      --
      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
        raise FND_API.G_EXC_ERROR;
      end if;
      --
    end if;
    --
  else
    l_budget_version_id := p_gl_budget_version_id;
  end if;

  if l_budget_version_id is null then
    l_concat_segments := FND_FLEX_EXT.Get_Segs
                         ( application_short_name => 'SQLGL',
                           key_flex_code          => 'GL#',
                           structure_number       => g_flex_code,
                           combination_id         => p_code_combination_id ) ;
    message_token('ACCOUNT', l_concat_segments);
    add_message('PSB', 'PSB_CANNOT_ASSIGN_BUDGET');
    raise FND_API.G_EXC_ERROR;
  end if;

  IF ( p_budget_revision_acct_line_id is not null ) THEN
    l_budget_revision_acct_line_id := p_budget_revision_acct_line_id;
  ELSE
    --

    -- Bug#3340060: Refixed bug#3022417 using bind variables. Earlier fix was
    -- causing duplicate record creation.
    sql_bra := '' ||
    'select pbra.budget_revision_acct_line_id '||
    'from psb_budget_revision_accounts pbra, psb_budget_revision_lines pbrl ' ||
    'where pbra.code_combination_id = :code_combination_id ' ||
    'and pbra.gl_period_name = :gl_period_name ' ||
    'and NVL(pbra.currency_code, :gmc1) = NVL(:currency_code, :gmc2) ' ||
    'and NVL(pbra.gl_budget_version_id,:gmn1)=NVL(:budget_version_id,:gmn2) '||
    'and NVL(pbra.position_id, :gmn3) = NVL(:position_id, :gmn4) ' ||
    'and pbrl.budget_revision_id = :budget_revision_id ' ||
    'and pbrl.budget_revision_acct_line_id = pbra.budget_revision_acct_line_id';

    l_first_br_al_id := NULL;
    OPEN  l_sql_bra_csr FOR sql_bra
    USING p_code_combination_id, p_gl_period_name, FND_API.G_MISS_CHAR,
          p_currency_code, FND_API.G_MISS_CHAR, FND_API.G_MISS_NUM,
          l_budget_version_id, FND_API.G_MISS_NUM, FND_API.G_MISS_NUM,
          p_position_id, FND_API.G_MISS_NUM, p_budget_revision_id ;
    LOOP
      --
      FETCH l_sql_bra_csr INTO l_budget_revision_acct_line_id;
      EXIT WHEN l_sql_bra_csr%NOTFOUND;

      -- The is defensive cleanup code. If there exists duplicate rollup CCID
      -- due to prior issues, we will delete all but first one and update it
      -- in later code as is the normal flow of the code.
      IF l_first_br_al_id IS NULL THEN
        l_first_br_al_id := l_budget_revision_acct_line_id;
      ELSE
        --
        DELETE psb_budget_revision_lines
        WHERE  budget_revision_acct_line_id = l_budget_revision_acct_line_id;
        --
        DELETE psb_budget_revision_accounts
        WHERE  budget_revision_acct_line_id = l_budget_revision_acct_line_id;
        --
      END IF;

    END LOOP;
    CLOSE l_sql_bra_csr;
    l_budget_revision_acct_line_id := l_first_br_al_id ;
    -- Bug#3340060: End

    /* Commented as this code is replated by the above loop logic.
    sql_bra := 'select pbra.budget_revision_acct_line_id '||
    'from psb_budget_revision_accounts pbra, psb_budget_revision_lines pbrl ' ||
    'where pbra.code_combination_id = :code_combination_id ' ||
    'and pbra.gl_period_name = :gl_period_name ' ||
    'and nvl(pbra.currency_code, ''' || FND_API.G_MISS_CHAR ||
    ''') = nvl(:currency_code, ''' || FND_API.G_MISS_CHAR || ''') ' ||
    -- Start bug # 3022417
    'and nvl(pbra.gl_budget_version_id,-9999)=nvl(:budget_version_id,-9999) '||
    'and nvl(pbra.position_id, -9999) = nvl(:position_id, -9999) ' ||
    -- End bug # 3022417
    'and pbrl.budget_revision_id = :budget_revision_id ' ||
    'and pbrl.budget_revision_acct_line_id = pbra.budget_revision_acct_line_id';
    */
    --
  END IF;

  if l_budget_revision_acct_line_id is null then
  begin

    -- Create new entries for all cases other than revise projections
    GL_CODE_COMBINATIONS_PKG.Select_Columns
      (X_code_combination_id => p_code_combination_id,
       X_account_type        => l_account_type,
       X_template_id         => l_template_id);

    Insert into PSB_BUDGET_REVISION_ACCOUNTS (BUDGET_REVISION_ACCT_LINE_ID, CODE_COMBINATION_ID,
                BUDGET_GROUP_ID, POSITION_ID, GL_PERIOD_NAME, GL_BUDGET_VERSION_ID, CURRENCY_CODE,
                BUDGET_BALANCE, ACCOUNT_TYPE, REVISION_TYPE, REVISION_VALUE_TYPE,
                REVISION_AMOUNT, functional_transaction,
                FUNDS_CONTROL_STATUS_CODE, FUNDS_CONTROL_RESULTS_CODE,
                NOTE_ID, FUNDS_CONTROL_TIMESTAMP, LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, CREATED_BY, CREATION_DATE)
         values (psb_budget_revision_accounts_s.nextval, p_code_combination_id,
                p_budget_group_id, decode(p_position_id, FND_API.G_MISS_NUM, null, p_position_id), p_gl_period_name, l_budget_version_id, p_currency_code,
                p_budget_balance, l_account_type, p_revision_type, p_revision_value_type,
                decode(p_revision_value_type, 'A', Get_Rounded_Amount(p_currency_code, p_revision_amount), p_revision_amount), p_functional_transaction,
                decode(p_funds_status_code, FND_API.G_MISS_CHAR, null, p_funds_status_code),
                decode(p_funds_result_code, FND_API.G_MISS_CHAR, null, p_funds_result_code),
                decode(p_note_id, FND_API.G_MISS_NUM, null, p_note_id), p_funds_control_timestamp,
                sysdate, FND_GLOBAL.USER_ID, FND_GLOBAL.LOGIN_ID, FND_GLOBAL.USER_ID, sysdate)
    returning budget_revision_acct_line_id into l_budget_revision_acct_line_id;

    for c_Global_Rev_Rec in c_Global_Rev (p_budget_revision_id) loop
      l_global_revision_id := c_Global_Rev_Rec.global_revision_id;
    end loop;

    -- this is used to propagate new budget revision entries created at any level to all the distributed levels

    for c_Distribute_Rev_Rec in c_Distribute_Rev (l_global_revision_id, p_budget_group_id) loop

      INSERT INTO PSB_BUDGET_REVISION_LINES
                 (BUDGET_REVISION_ACCT_LINE_ID, BUDGET_REVISION_ID, FREEZE_FLAG,
                  VIEW_LINE_FLAG, LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, CREATED_BY,
                  CREATION_DATE)
         VALUES (l_budget_revision_acct_line_id, c_Distribute_Rev_Rec.budget_revision_id, p_freeze_flag,
                 p_view_line_flag, sysdate, FND_GLOBAL.USER_ID, FND_GLOBAL.LOGIN_ID, FND_GLOBAL.USER_ID,
                 sysdate);

    end loop;

  end;
  else
  begin

    /*bug:7162585:start:Added the call to fetch account_type for the ccid passed to this api*/
    GL_CODE_COMBINATIONS_PKG.Select_Columns
      (X_code_combination_id => p_code_combination_id,
       X_account_type        => l_account_type,
       X_template_id         => l_template_id);
    /*bug:7162585:end*/

    Update PSB_BUDGET_REVISION_ACCOUNTS
       set code_combination_id = p_code_combination_id,
           budget_group_id = p_budget_group_id,
           gl_period_name = p_gl_period_name,
           budget_balance = p_budget_balance,
           revision_type = p_revision_type,
	   account_type = l_account_type,           --bug:7162585:added the condition
           revision_value_type = p_revision_value_type,
           revision_amount = decode(p_revision_value_type, 'A', Get_Rounded_Amount(p_currency_code, p_revision_amount), p_revision_amount),
           funds_control_status_code = decode(p_funds_status_code, FND_API.G_MISS_CHAR, funds_control_status_code, null, funds_control_status_code, p_funds_status_code),
           funds_control_results_code = decode(p_funds_result_code, FND_API.G_MISS_CHAR, funds_control_results_code, null, funds_control_results_code, p_funds_result_code),
           funds_control_timestamp = p_funds_control_timestamp,
           note_id = decode(p_note_id, FND_API.G_MISS_NUM, note_id, null, note_id, p_note_id),
           freeze_flag = p_freeze_flag,
           last_update_date = sysdate,
           last_updated_by = FND_GLOBAL.USER_ID,
           last_update_login = FND_GLOBAL.LOGIN_ID,
           currency_code = p_currency_code  -- Bug 3029168
     where budget_revision_acct_line_id = l_budget_revision_acct_line_id;

  end;
  end if;

  p_budget_revision_acct_line_id := l_budget_revision_acct_line_id;

   -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                             p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

End Create_Revision_Accounts;

/* ----------------------------------------------------------------------- */

-- Check if parameter exists for account for this period

FUNCTION AcctParam_Exists
(p_parameter_id        NUMBER,
 p_budget_revision_id  NUMBER,
 p_period_name         VARCHAR2,
 p_local_parameter     VARCHAR2,
 p_ccid                NUMBER,
 p_ccid_start_period   DATE,
 p_ccid_end_period     DATE,
 p_period_start_date   DATE,
 p_period_end_date     DATE
) RETURN BOOLEAN IS

  l_parameter_exists   BOOLEAN := FALSE;
  l_account_exists     BOOLEAN := FALSE;

/*Bug:5753424: effective_start_date and effective_end_date are used
  from psb_entity_assignment instead of psb_entity*/

  cursor c_Exists is
    select 'Exists'
      from PSB_PARAMETER_ASSIGNMENTS_V a
     where p_local_parameter = 'N'
       and parameter_set_id = g_parameter_set_id
       and parameter_id = p_parameter_id
       and exists
          (select 1
             from PSB_SET_RELATIONS_V b,
                  PSB_BUDGET_ACCOUNTS c
            where b.account_or_position_type = 'A'
              and b.account_position_set_id = c.account_position_set_id
              and b.parameter_id = p_parameter_id
              and c.code_combination_id = p_ccid)
       and a.parameter_type = 'ACCOUNT'
       and (((a.effective_start_date <= nvl(p_ccid_end_period, p_period_end_date))
         and (a.effective_end_date is null))
         or ((a.effective_start_date between nvl(p_ccid_start_period, p_period_start_date) and nvl(p_ccid_end_period, p_period_end_date))
          or (a.effective_end_date between nvl(p_ccid_start_period, p_period_start_date) and nvl(p_ccid_end_period, p_period_end_date))
          or ((effective_start_date < nvl(p_ccid_start_period, p_period_start_date))
          and (effective_end_date > nvl(p_ccid_end_period, p_period_end_date)))))
       and (((a.effective_start_date <= p_period_end_date)
         and (a.effective_end_date is null))
         or ((a.effective_start_date between p_period_start_date and p_period_end_date)
          or (a.effective_end_date between p_period_start_date and p_period_end_date)
          or ((effective_start_date < p_period_start_date)
          and (effective_end_date > p_period_end_date))))
    UNION
    select 'Exists'
      from PSB_ENTITY a,
           psb_entity_assignment pea --bug:5753424
     where p_local_parameter = 'Y'
       and a.entity_id = p_parameter_id
       and a.entity_id = pea.entity_id --bug:5753424
       and exists
          (select 1
             from PSB_SET_RELATIONS_V b,
                  PSB_BUDGET_ACCOUNTS c
            where b.account_or_position_type = 'A'
              and b.account_position_set_id = c.account_position_set_id
              and b.parameter_id = p_parameter_id
              and c.code_combination_id = p_ccid)
       and a.entity_subtype = 'ACCOUNT'
       and (((pea.effective_start_date <= nvl(p_ccid_end_period, p_period_end_date))
         and (pea.effective_end_date is null))
         or ((pea.effective_start_date between nvl(p_ccid_start_period, p_period_start_date) and nvl(p_ccid_end_period, p_period_end_date))
          or (pea.effective_end_date between nvl(p_ccid_start_period, p_period_start_date) and nvl(p_ccid_end_period, p_period_end_date))
          or ((pea.effective_start_date < nvl(p_ccid_start_period, p_period_start_date))
          and (pea.effective_end_date > nvl(p_ccid_end_period, p_period_end_date)))))
       and (((pea.effective_start_date <= p_period_end_date)
         and (pea.effective_end_date is null))
         or ((pea.effective_start_date between p_period_start_date and p_period_end_date)
          or (pea.effective_end_date between p_period_start_date and p_period_end_date)
          or ((pea.effective_start_date < p_period_start_date)
          and (pea.effective_end_date > p_period_end_date))));

  cursor c_AcctExists is
    select 'Exists'
      from psb_budget_revision_accounts a, psb_budget_revision_lines b
     where a.code_combination_id = p_ccid
       and a.gl_period_name = p_period_name
       and b.budget_revision_id = p_budget_revision_id
       and b.budget_revision_acct_line_id = a.budget_revision_acct_line_id;

Begin

  for c_Exists_Rec in c_Exists loop
    l_parameter_exists := TRUE;
  end loop;

  if p_local_parameter = 'Y' then
  begin

    for c_AcctExists_Rec in c_AcctExists loop
      l_account_exists := TRUE;
    end loop;

    if not l_account_exists then
      l_parameter_exists := FALSE;
    end if;

  end;
  end if;

  return l_parameter_exists;

END AcctParam_Exists;

/*==========================================================================+
 |                       PROCEDURE Apply_Revision_Acct_Parameters           |
 +==========================================================================*/

PROCEDURE Apply_Revision_Acct_Parameters
( p_api_version            IN   NUMBER,
  p_init_msg_list          IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level       IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status          OUT  NOCOPY  VARCHAR2,
  p_parameter_id           IN   NUMBER,
  p_parameter_name         IN   VARCHAR2,
  p_compound_annually      IN   VARCHAR2,
  p_compound_factor        IN   NUMBER,
  p_original_budget        IN   NUMBER,
  p_current_budget         IN   NUMBER,
  p_revision_amount        OUT  NOCOPY  NUMBER
) IS

  l_return_status          VARCHAR2(1);

  cursor c_Formula is
    select step_number,
           prefix_operator,
           budget_year_type_id,
           balance_type,
           segment1, segment2, segment3,
           segment4, segment5, segment6,
           segment7, segment8, segment9,
           segment10, segment11, segment12,
           segment13, segment14, segment15,
           segment16, segment17, segment18,
           segment19, segment20, segment21,
           segment22, segment23, segment24,
           segment25, segment26, segment27,
           segment28, segment29, segment30,
           currency_code,
           nvl(amount, 0) amount,
           postfix_operator
      from PSB_PARAMETER_FORMULAS
     where parameter_id = p_parameter_id
     order by step_number;

  l_first_line          VARCHAR2(1) := FND_API.G_TRUE;
  l_first_time          VARCHAR2(1) := FND_API.G_TRUE;

  l_num_lines           NUMBER := 0;
  l_compound_total      NUMBER := 0;

  l_type4               VARCHAR2(1);

  l_line_total          NUMBER := 0;
  l_diff                NUMBER := 0;
  l_budget_amount       NUMBER;
  l_return_status       VARCHAR2(1);
  l_running_total       NUMBER := 0;

Begin

  for c_Formula_Rec in c_Formula loop
   l_type4 := FND_API.G_FALSE;
   l_line_total := 0;

   l_num_lines := l_num_lines + 1;

    -- The prefix operator for the 1st Formula line must be '=';
    -- for the other Formula lines, the
    -- prefix operator can be '+', '-', '*', '/'

    if FND_API.to_Boolean(l_first_line) then
    begin

      l_first_line := FND_API.G_FALSE;

      if c_Formula_Rec.prefix_operator <> '=' then
        message_token('PARAMETER', p_parameter_name);
        message_token('STEPID', c_Formula_Rec.step_number);
        message_token('OPERATOR', '[=]');
        add_message('PSB', 'PSB_INVALID_PARAM_OPR');
        raise FND_API.G_EXC_ERROR;
      end if;

    end;
    else
    begin

      if c_Formula_Rec.prefix_operator not in ('+', '-', '*', '/') then
        message_token('PARAMETER', p_parameter_name);
        message_token('STEPID', c_Formula_Rec.step_number);
        message_token('OPERATOR', '[+, -, *, /]');
        add_message('PSB', 'PSB_INVALID_PARAM_OPR');
        raise FND_API.G_EXC_ERROR;
      end if;
    end;
    end if;

    -- Check Formula Type :
    if ((c_Formula_Rec.prefix_operator is not null) and
           (c_Formula_Rec.postfix_operator is not null) and
           (c_Formula_Rec.balance_type in ('O', 'C')) and
           (c_Formula_Rec.currency_code is not null) and
           (c_Formula_Rec.amount is not null) and
          ((c_Formula_Rec.budget_year_type_id is null) and
           (c_Formula_Rec.segment1 is null) and (c_Formula_Rec.segment2 is null) and (c_Formula_Rec.segment3 is null) and
           (c_Formula_Rec.segment4 is null) and (c_Formula_Rec.segment5 is null) and (c_Formula_Rec.segment6 is null) and
           (c_Formula_Rec.segment7 is null) and (c_Formula_Rec.segment8 is null) and (c_Formula_Rec.segment9 is null) and
           (c_Formula_Rec.segment10 is null) and (c_Formula_Rec.segment11 is null) and (c_Formula_Rec.segment12 is null) and
           (c_Formula_Rec.segment13 is null) and (c_Formula_Rec.segment14 is null) and (c_Formula_Rec.segment15 is null) and
           (c_Formula_Rec.segment16 is null) and (c_Formula_Rec.segment17 is null) and (c_Formula_Rec.segment18 is null) and
           (c_Formula_Rec.segment19 is null) and (c_Formula_Rec.segment20 is null) and (c_Formula_Rec.segment21 is null) and
           (c_Formula_Rec.segment22 is null) and (c_Formula_Rec.segment23 is null) and (c_Formula_Rec.segment24 is null) and
           (c_Formula_Rec.segment25 is null) and (c_Formula_Rec.segment26 is null) and (c_Formula_Rec.segment27 is null) and
           (c_Formula_Rec.segment28 is null) and (c_Formula_Rec.segment29 is null) and (c_Formula_Rec.segment30 is null))) then
    begin
      l_type4 := FND_API.G_TRUE;
    end;
    else
    begin
      message_token('PARAMETER', p_parameter_name);
      add_message('PSB', 'PSB_INVALID_PARAM_FORMULA');
      raise FND_API.G_EXC_ERROR;
    end;
    end if;

    if FND_API.to_Boolean(l_type4) then
    begin

      if (c_Formula_Rec.balance_type  = 'O') then
         l_budget_amount := p_original_budget;
      elsif (c_Formula_Rec.balance_type  = 'C') then
         l_budget_amount := p_current_budget;
      end if;

      if c_Formula_Rec.postfix_operator = '+' then
        l_line_total := l_budget_amount + c_Formula_Rec.amount;
      elsif c_Formula_Rec.postfix_operator = '-' then
        l_line_total := l_budget_amount - c_Formula_Rec.amount;
      elsif c_Formula_Rec.postfix_operator = '*' then
      begin

        l_line_total := l_budget_amount * c_Formula_Rec.amount;

        if FND_API.to_Boolean(p_compound_annually) then
          l_compound_total := l_budget_amount * POWER(c_Formula_Rec.amount, p_compound_factor);
        end if;

      end;
      elsif c_Formula_Rec.postfix_operator = '/' then
      begin

        -- Avoid a divide-by-zero error

        if c_Formula_Rec.amount = 0 then
          l_line_total := 0;
        else
          l_line_total := l_budget_amount / c_Formula_Rec.amount;
        end if;

      end;
      end if;

    end; /* For Budget Revisions only */
    end if;


    if c_Formula_Rec.prefix_operator = '=' then
      l_running_total := l_line_total;
    elsif c_Formula_Rec.prefix_operator = '+' then
      l_running_total := l_running_total + l_line_total;
    elsif c_Formula_Rec.prefix_operator = '-' then
      l_running_total := l_running_total - l_line_total;
    elsif c_Formula_Rec.prefix_operator = '*' then
      l_running_total := l_running_total * l_line_total;
    elsif c_Formula_Rec.prefix_operator = '/' then
    begin

      -- Avoid divide-by-zero error

      if l_line_total = 0 then
        l_running_total := 0;
      else
        l_running_total := l_running_total / l_line_total;
      end if;

    end;
    end if;

  End Loop; /*c_Formula*/

  if ((l_num_lines = 1) and
      (FND_API.to_boolean(l_type4)) and
      (FND_API.to_Boolean(p_compound_annually))) then
    l_running_total := l_compound_total;
  end if;

   /* The difference is always between the current budget and revised budget */
   p_revision_amount := l_running_total;

  -- Set API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

End Apply_Revision_Acct_Parameters;

/*==========================================================================+
 |                       PROCEDURE Create_Base_Budget_Revision              |
 +==========================================================================*/

PROCEDURE Create_Base_Budget_Revision
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_worksheet_id        IN      NUMBER,
  p_event_type          IN      VARCHAR2 DEFAULT 'BP'

) IS

  l_api_name                      CONSTANT VARCHAR2(30)   := 'CREATE_BASE_BUDGET_REVISION';
  l_api_version                   CONSTANT NUMBER         := 1.0;

  l_return_status                 VARCHAR2(1);
  l_msg_count                     NUMBER;
  l_msg_data                      VARCHAR2(2000);

  l_budget_group_id               NUMBER;
  l_budget_revision_id            NUMBER;
  l_budget_revision_exists        BOOLEAN := FALSE;

  l_budget_revision_acct_line_id  NUMBER;

  l_account_type                  VARCHAR2(1);
  l_template_id                   NUMBER;
  l_currency_code                 VARCHAR2(15);

  cursor c_bg is
    select nvl(b.root_budget_group_id, b.budget_group_id) budget_group_id
      from PSB_WORKSHEETS a, PSB_BUDGET_GROUPS b
     where a.worksheet_id = p_worksheet_id
       and b.budget_group_id = a.budget_group_id;

  -- Bug 3029168 added the join with currency code
  -- in the c_budrev_exists cursor
  cursor c_budrev_exists is
    select budget_revision_id
      from psb_budget_revisions
     where budget_group_id = l_budget_group_id
       and base_line_revision = 'Y'
       AND ((currency_code = 'STAT' AND p_event_type = 'SW')
        OR ((currency_code <> 'STAT' OR currency_code IS NULL) AND p_event_type = 'BP'));

  -- Shigva Start
  /*cursor c_lines is
    select aeh.ae_header_id, aeh.budget_version_id, aeh.period_name,
           ael.code_combination_id, ael.currency_code,
      sum(nvl(ael.entered_dr, 0) - nvl(ael.entered_cr, 0)) budget_balance
      from PSB_AE_LINES_ALL ael,
           PSB_AE_HEADERS_ALL aeh
     where ael.source_id = p_worksheet_id
       and ael.source_table = 'PSB_WORKSHEETS'
       and ael.actual_flag = 'B'
       and aeh.ae_header_id = ael.ae_header_id
  group by aeh.ae_header_id, aeh.budget_version_id, aeh.period_name, ael.code_combination_id, ael.currency_code;*/

  -- Bug#4310411 Start
  CURSOR c_lines
  IS
  SELECT pgi.worksheet_id,
         pgi.budget_version_id,
         pgi.period_name,
         pgi.code_combination_id,
         pgi.currency_code,
         SUM(NVL(pgi.entered_dr, 0) - NVL(pgi.entered_cr, 0)) budget_balance
  FROM psb_gl_interfaces pgi
  WHERE pgi.worksheet_id = p_worksheet_id
  AND pgi.actual_flag = 'B'
  AND pgi.budget_source_type = p_event_type -- Bug 3029168
  GROUP BY pgi.worksheet_id,
           pgi.budget_version_id,
           pgi.period_name,
           pgi.code_combination_id,
           pgi.currency_code;
  -- Bug#4310411 End
BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     CREATE_BASE_BUDGET_REVISION;

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  IF FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  /* Bug 3029168 Start */
  IF p_event_type = 'SW' THEN
    l_currency_code := 'STAT';
  END IF;
  /* Bug 3029168 End */

  for c_bg_rec in c_bg loop
    l_budget_group_id := c_bg_rec.budget_group_id;
  end loop;

  for c_budrev_exists_rec IN c_budrev_exists loop
    l_budget_revision_id := c_budrev_exists_rec.budget_revision_id;
    l_budget_revision_exists := TRUE;
  end loop;

  IF not l_budget_revision_exists THEN
  begin

    PSB_BUDGET_REVISIONS_PVT.Create_Budget_Revision
       (p_api_version                      => 1.0,
        p_return_status                    => l_return_status,
        p_msg_count                        => l_msg_count,
        p_msg_data                         => l_msg_data,
        p_budget_revision_id               => l_budget_revision_id,
        p_budget_group_id                  => l_budget_group_id,
        p_gl_budget_set_id                 => 0,
        p_justification                    => null,
        p_from_gl_period_name              => null,
        p_to_gl_period_name                => null,
        p_currency_code                    => l_currency_code, -- Bug 3029168
        p_effective_start_date             => null,
        p_effective_end_date               => null,
        p_budget_revision_type             => 'R',
        p_transaction_type                 => NULL,
        p_permanent_revision               => 'Y',
        p_global_budget_revision           => null,
        p_global_budget_revision_id        => null,
        p_requestor                        => FND_GLOBAL.USER_ID,
        p_parameter_set_id                 => null,
        p_constraint_set_id                => null,
        p_submission_date                  => null,
        p_submission_status                => null,
        p_approval_orig_system             => null,
        p_approval_override_by             => null,
        p_freeze_flag                      => null,
        p_base_line_revision               => 'Y',
        p_attribute1                       => null,
        p_attribute2                       => null,
        p_attribute3                       => null,
        p_attribute4                       => null,
        p_attribute5                       => null,
        p_attribute6                       => null,
        p_attribute7                       => null,
        p_attribute8                       => null,
        p_attribute9                       => null,
        p_attribute10                      => null,
        p_attribute11                      => null,
        p_attribute12                      => null,
        p_attribute13                      => null,
        p_attribute14                      => null,
        p_attribute15                      => null,
        p_attribute16                      => null,
        p_attribute17                      => null,
        p_attribute18                      => null,
        p_attribute19                      => null,
        p_attribute20                      => null,
        p_attribute21                      => null,
        p_attribute22                      => null,
        p_attribute23                      => null,
        p_attribute24                      => null,
        p_attribute25                      => null,
        p_attribute26                      => null,
        p_attribute27                      => null,
        p_attribute28                      => null,
        p_attribute29                      => null,
        p_attribute30                      => null,
        p_context                          => null);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  end;
  END IF;

  for c_lines_rec in c_lines loop

    l_budget_revision_acct_line_id := NULL;

    GL_CODE_COMBINATIONS_PKG.Select_Columns
     (X_code_combination_id => c_lines_rec.code_combination_id,
      X_account_type        => l_account_type,
      X_template_id         => l_template_id);

    PSB_BUDGET_REVISIONS_PVT.Create_Revision_Accounts
      (p_api_version                    => 1.0,
       p_return_status                   => l_return_status,
       p_msg_count                       => l_msg_count,
       p_msg_data                        => l_msg_data,
       p_budget_revision_acct_line_id    => l_budget_revision_acct_line_id,
       p_budget_revision_id              => l_budget_revision_id,
       p_code_combination_id             => c_lines_rec.code_combination_id,
       p_budget_group_id                 => l_budget_group_id,
       p_gl_period_name                  => c_lines_rec.period_name,
       p_gl_budget_version_id            => c_lines_rec.budget_version_id,
       p_currency_code                   => c_lines_rec.currency_code,
       p_budget_balance                  => c_lines_rec.budget_balance,
       p_revision_type                   => null,
       p_revision_value_type             => null,
       p_revision_amount                 => null,
       p_funds_status_code               => null,
       p_funds_result_code               => null,
       p_funds_control_timestamp         => null,
       p_note_id                         => null,
       p_freeze_flag                     => 'N',
       p_view_line_flag                  => 'Y');

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  end loop;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard check of p_commit.

  IF FND_API.to_Boolean (p_commit) THEN
    commit work;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                             p_data  => p_msg_data);


EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     rollback to CREATE_BASE_BUDGET_REVISIONS;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     rollback to CREATE_BASE_BUDGET_REVISIONS;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

   WHEN OTHERS THEN
     rollback to CREATE_BASE_BUDGET_REVISIONS;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

END Create_Base_Budget_Revision;

/*==========================================================================+
 |                       FUNCTION Find_Original_Budget_Balance              |
 +==========================================================================*/

/* The original budget for a ccid is obtained from the base line budget revision */

Function Find_Original_Budget_Balance
 (p_code_combination_id    IN      NUMBER,
  p_budget_group_id        IN      NUMBER,
  p_gl_period              IN      VARCHAR2,
  p_gl_budget_version_id   IN      NUMBER,
  p_set_of_books_id        IN      NUMBER := FND_API.G_MISS_NUM,
  p_end_gl_period          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_currency_code          IN      VARCHAR2 DEFAULT NULL
) RETURN NUMBER IS

l_budget_group_id              NUMBER;
l_from_date                    DATE;
l_to_date                      DATE;
l_gl_period_name               VARCHAR2(15);

l_original_budget_balance      NUMBER := 0;
l_sum_budget_balance           NUMBER := 0;

/* start bug 3687997 */
l_account_type                 VARCHAR2(1);
/* end bug 3687997 */

cursor c_original_budget is
  Select budget_balance
    from psb_budget_revision_accounts pbra,
         psb_budget_revision_lines    pbrl,
         psb_budget_revisions         pbr
   where pbra.code_combination_id = p_code_combination_id
     and pbra.gl_period_name = p_gl_period
     and pbra.gl_budget_version_id = p_gl_budget_version_id
     and pbra.budget_revision_acct_line_id = pbrl.budget_revision_acct_line_id
     and pbra.position_id is null
     and pbrl.budget_revision_id = pbr.budget_revision_id
     and pbr.budget_group_id = l_budget_group_id
     and pbr.base_line_revision = 'Y'
     and NVL(pbr.currency_code,p_currency_code) = p_currency_code
     and NVL(pbra.currency_code,p_currency_code)
       = NVL(pbr.currency_code,p_currency_code);  -- Bug 3029168

Cursor c_original_budget_sum is
  Select sum(budget_balance) sum_budget_balance
    from psb_budget_revision_accounts pbra,
         psb_budget_revision_lines    pbrl,
         psb_budget_revisions         pbr
   where pbra.code_combination_id = p_code_combination_id
     and pbra.gl_budget_version_id = p_gl_budget_version_id
     and pbra.position_id is null
     and pbra.budget_revision_acct_line_id = pbrl.budget_revision_acct_line_id
     and pbrl.budget_revision_id = pbr.budget_revision_id
     and pbr.budget_group_id = l_budget_group_id
     and pbr.base_line_revision = 'Y'
     and NVL(pbr.currency_code,p_currency_code) = p_currency_code
     and NVL(pbra.currency_code,p_currency_code)
       = NVL(pbr.currency_code,p_currency_code)   -- Bug 3029168
     and pbra.gl_period_name in
           (select period_name
            from gl_period_statuses
           where application_id = 101
             and set_of_books_id = p_set_of_books_id
             and start_date between l_from_date and l_to_date
             and end_date between l_from_date and l_to_date);

Cursor c_gl_dates is
  Select period_name, start_date,end_date
    from gl_period_statuses
   where application_id = 101
     and set_of_books_id = p_set_of_books_id
     and period_name in (p_gl_period, p_end_gl_period);

Cursor c_Root_Budget_Group is
  Select nvl(root_budget_group_id,budget_group_id) root_budget_group_id
    from psb_budget_groups_v
   where budget_group_id = p_budget_group_id;

Begin

 For c_Root_Budget_Group_Rec in c_Root_Budget_Group Loop
   l_budget_group_id := c_Root_Budget_Group_Rec.root_budget_group_id;
 End Loop;

 /* Start Bug 3687997 */
 -- Fetch the account type from Gl_Code_Combinations table.
 FOR l_account_type_csr IN
     (SELECT account_type
      FROM gl_code_combinations
      WHERE code_combination_id = p_code_combination_id)
 LOOP
   l_account_type := l_account_type_csr.account_type;
 END LOOP;
 /* end bug 3687997 */


 if (p_end_gl_period = FND_API.G_MISS_CHAR) then
 begin

  For c_original_budget_rec in c_original_budget Loop
    l_original_budget_balance := c_original_budget_rec.budget_balance;
  End Loop;

  /* start bug 3687997 */
  IF l_account_type in ('A','D','E') THEN
    RETURN(l_original_budget_balance);
  ELSE
    RETURN(-1 * l_original_budget_balance);
  END IF;
  /* end bug 3687997 */

 end;
 else

   for c_gl_dates_rec in c_gl_dates Loop
     if p_gl_period = p_end_gl_period then
       l_from_date := c_gl_dates_rec.start_date;
       l_to_date := c_gl_dates_rec.end_date;
     else
     begin

       if c_gl_dates_rec.period_name = p_gl_period then
         l_from_date := c_gl_dates_rec.start_date;
       elsif c_gl_dates_rec.period_name = p_end_gl_period then
         l_to_date := c_gl_dates_rec.end_date;
       end if;

     end;
     end if;
   End Loop;

   For c_original_sum_budget_rec in c_original_budget_sum Loop
    l_sum_budget_balance := c_original_sum_budget_rec.sum_budget_balance;
   End Loop;

  /* start bug 3687997 */
  IF l_account_type In ('A', 'D', 'E') THEN
    RETURN(l_sum_budget_balance);
  ELSE
    RETURN(-1 * l_sum_budget_balance);
  END IF;
  /* end bug 3687997 */

 end if;

End Find_original_budget_balance;

/*==========================================================================+
 |                       PROCEDURE Insert_Into_GL_BCP                       |
 +==========================================================================*/
PROCEDURE Insert_Into_GL_BCP
(x_return_status       OUT NOCOPY VARCHAR2,
 p_packet_id           IN         NUMBER,
 p_budget_revision_id  IN         NUMBER,
 p_code_combination_id IN         Number_Tbl_Type,
 p_account_type        IN         Char_Tbl_Type,
 p_period_name         IN         Char_Tbl_Type,
 p_period_year         IN         Number_Tbl_Type,
 p_period_num          IN         Number_Tbl_Type,
 p_quarter_num         IN         Char_Tbl_Type,
 p_currency_code       IN         Char_Tbl_Type,
 p_status_code         IN         Char_Tbl_Type,
 p_budget_version_id   IN         Number_Tbl_Type,
 p_entered_dr          IN         Number_Tbl_Type,
 p_entered_cr          IN         Number_Tbl_Type,
 p_accounted_dr        IN         Number_Tbl_Type,
 p_accounted_cr        IN         Number_Tbl_Type,
 p_reference1          IN         Char_Tbl_Type
)
IS
  l_session_id     NUMBER(38);
  l_serial_id      NUMBER(38);
  PRAGMA autonomous_transaction;

BEGIN

  -- bug 4589283 added the below clause
  SELECT s.sid, s.serial#
    INTO l_session_id,
         l_serial_id
    FROM v$session s,v$process p
   WHERE s.paddr = p.addr
     AND audsid  = USERENV('SESSIONID');

  --++ Bulk insert into GL_BC_PACKETS
  FORALL l_indx IN 1..p_budget_version_id.COUNT
    INSERT INTO GL_BC_PACKETS
    (packet_id,
     ledger_id,
     je_source_name,
     je_category_name,
     code_combination_id,
     account_type,
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
     application_id, -- Bug 4589283 added the below columns
     session_id,
     serial_id
    )
    VALUES
    (p_packet_id,
     g_set_of_books_id,
     g_gl_journal_source,
     g_gl_journal_category,
     p_code_combination_id(l_indx),
     p_account_type(l_indx),
     'B',
     p_period_name(l_indx),
     p_period_year(l_indx),
     p_period_num(l_indx),
     p_quarter_num(l_indx),
     p_currency_code(l_indx),
     p_status_code(l_indx),
     SYSDATE,
     FND_GLOBAL.USER_ID,
     p_budget_version_id(l_indx),
     p_entered_dr(l_indx),
     p_entered_cr(l_indx),
     p_accounted_dr(l_indx),
     p_accounted_cr(l_indx),
     p_reference1(l_indx),
     p_budget_revision_id,
     8401,      --Bug 4589283 added the below columns
     l_session_id,
     l_serial_id
    );

  COMMIT;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
   /* FND_MSG_PUB.Count_And_Get(p_count => p_msg_count, p_data => p_msg_data
                             );*/

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Budget_Revision_Funds_Check;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
/*    FND_MSG_PUB.Count_And_Get (p_count => p_msg_count, p_data  => p_msg_data);*/

  WHEN OTHERS THEN
    ROLLBACK TO Budget_Revision_Funds_Check;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
/*    FND_MSG_PUB.Count_And_Get(p_count => p_msg_count, p_data  => p_msg_data);

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
    END IF;*/
END;

/*==========================================================================+
 |                       PROCEDURE Budget_Revision_Funds_Check              |
 +==========================================================================*/

PROCEDURE Budget_Revision_Funds_Check
( p_api_version            IN   NUMBER,
  p_init_msg_list          IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit                 IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level       IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status          OUT  NOCOPY  VARCHAR2,
  p_msg_count              OUT  NOCOPY  NUMBER,
  p_msg_data               OUT  NOCOPY  VARCHAR2,
  p_budget_revision_id     IN   NUMBER,
  p_funds_reserve_flag     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_fund_check_failures    OUT  NOCOPY  NUMBER,
  p_called_from            IN   VARCHAR2 DEFAULT 'PSBBGRVS' -- Bug#4310411
) IS

  l_api_name               CONSTANT VARCHAR2(30)   := 'Budget_Revision_Funds_Check';
  l_api_version            CONSTANT NUMBER   := 1.0;

  l_return_status        VARCHAR2(1);
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(2000);
  l_packet_id            NUMBER;
  l_account_type         VARCHAR2(1);
  l_template_id          NUMBER;
  l_entered_dr           NUMBER;
  l_entered_cr           NUMBER;

  l_budget_balance         NUMBER;
  l_budget_revision_acct_line_id NUMBER;

  l_sql_code varchar2(1000);
  l_sql_errm varchar2(1000);

  l_status_code          VARCHAR2(1);
  l_mode                 VARCHAR2(1);

  -- Bug#4310411 Start
  l_code_combination_id_tab Number_Tbl_Type;
  l_account_type_tab        Char_Tbl_Type;
  l_period_name_tab         Char_Tbl_Type;
  l_period_year_tab         Number_Tbl_Type;
  l_period_num_tab          Number_Tbl_Type;
  l_quarter_num_tab         Char_Tbl_Type;
  l_currency_code_tab       Char_Tbl_Type;
  l_status_code_tab         Char_Tbl_Type;
  l_budget_version_id_tab   Number_Tbl_Type;
  l_entered_dr_tab          Number_Tbl_Type;
  l_entered_cr_tab          Number_Tbl_Type;
  l_accounted_dr_tab        Number_Tbl_Type;
  l_accounted_cr_tab        Number_Tbl_Type;
  l_reference1_tab          Char_Tbl_Type;

  TYPE l_rev_lines_rec IS RECORD
  (budget_revision_acct_line_id NUMBER(20),
   budget_revision_id           NUMBER(20),
   code_combination_id          NUMBER(20),
   gl_period_name               VARCHAR2(15),
   period_year                  NUMBER(15),
   period_num                   NUMBER(15),
   quarter_num                  NUMBER(15),
   gl_budget_version_id         NUMBER,
   currency_code                VARCHAR2(15),
   budget_balance               NUMBER,
   revision_type                VARCHAR2(1),
   revision_value_type          VARCHAR2(1),
   revision_amount              NUMBER
  );

  TYPE l_rev_lines_tab IS TABLE OF l_rev_lines_rec;
  l_rev_lines_tab_inst l_rev_lines_tab := l_rev_lines_tab();
  -- Bug#4310411 End

Cursor c_Fund_Balances is
  Select code_combination_id,
         budget_version_id,
         currency_code,
         period_name,
         result_code,
         status_code,
         reference1
    from GL_BC_PACKETS
   where packet_id = l_packet_id;

Cursor c_Revision_Accounts is
  Select pbra.budget_revision_acct_line_id,
         pbra.budget_revision_id,
         pbra.code_combination_id,
         pbra.gl_period_name,
         gps.period_year,
         gps.period_num,
         gps.quarter_num,
         pbra.gl_budget_version_id,
         pbra.currency_code,
         pbra.budget_balance,
         pbra.revision_type,
         pbra.revision_value_type,
         pbra.revision_amount
   from psb_budget_revision_accounts_v pbra,
        GL_PERIOD_STATUSES gps
  where budget_revision_id = p_budget_revision_id
    and gps.application_id = 101
    and gps.set_of_books_id = g_set_of_books_id
    and gps.period_name = pbra.gl_period_name;

CURSOR c_Seq IS
   select gl_bc_packets_s.nextval seq
     from dual;

Begin

  -- Standard Start of API savepoint
  SAVEPOINT Budget_Revision_Funds_Check;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  -- Initialize global variables.
  Cache_Revision_Variables(p_budget_revision_id => p_budget_revision_id,
                           p_return_status => l_return_status);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;
  IF (g_budget_revision_type = 'C')
  AND g_currency_code <> 'STAT' THEN -- Bug 3029168
   /* Budget Rev Stub for CBC */

     PSB_COMMITMENTS_PVT.Commitment_Funds_Check
     ( p_api_version        => 1.0,
       p_init_msg_list      => FND_API.G_FALSE,
       p_commit             => FND_API.G_FALSE,
       p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
       p_return_status      => l_return_status,
       p_msg_count          => l_msg_count,
       p_msg_data           => l_msg_data,
       p_budget_revision_id => p_budget_revision_id);


    if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
      Savepoint Budget_Revision_Funds_Check;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  else
  begin

    for c_seq_rec in c_seq loop
      l_packet_id := c_seq_rec.seq;
    end loop;

    -- Added IF statement for Bug:3681872
    if (fnd_global.conc_request_id <> -1) then
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Packet ID: ' || l_packet_id);
    end if;

    -- Bug#4310411 Start

    /* Bug 5148554 Made the following changes
       funds check will be called in check mode only */
    IF p_called_from = 'PSBBGRVS' OR p_called_from = 'PSBBR' THEN
      -- The Funds Checker/Freeze/Unfreeze/Validate program is called
      -- from Budget Revision form so we don't need to post them to GL.
      l_status_code := 'C';
      l_mode        := 'C'; -- Funds check only.
    END IF;
    /* ELSIF p_called_from = 'PSBBR' THEN
      -- The Funds Checker program is called from PSB_Submit_Revision_PVT
      -- as the part of Budget Revision Submission process, so we will
      -- check records and need to post them to GL also.
      l_status_code := 'P';
      l_mode        := 'R'; -- Funds Reservation check.
    END IF; */

    OPEN c_Revision_Accounts;
    FETCH c_Revision_Accounts BULK COLLECT INTO l_rev_lines_tab_inst;
    CLOSE c_Revision_Accounts;

    IF l_rev_lines_tab_inst.COUNT > 0 THEN
      FOR l_indx IN 1..l_rev_lines_tab_inst.COUNT LOOP
        l_entered_dr := NULL;
        l_entered_cr := NULL;

        GL_CODE_COMBINATIONS_PKG.Select_Columns
        (X_code_combination_id => l_rev_lines_tab_inst(l_indx).code_combination_id,
         X_account_type        => l_account_type,
         X_template_id         => l_template_id
        );

        IF (l_account_type IN ('A','E')) then
          BEGIN
            IF l_rev_lines_tab_inst(l_indx).revision_value_type = 'P' THEN
              IF l_rev_lines_tab_inst(l_indx).revision_type = 'I' THEN
                l_entered_dr := l_rev_lines_tab_inst(l_indx).revision_amount * l_rev_lines_tab_inst(l_indx).budget_balance / 100;
              ELSE
                l_entered_cr := l_rev_lines_tab_inst(l_indx).revision_amount * l_rev_lines_tab_inst(l_indx).budget_balance / 100;
              END IF;
            ELSE
              IF l_rev_lines_tab_inst(l_indx).revision_type = 'I' THEN
                l_entered_dr := l_rev_lines_tab_inst(l_indx).revision_amount;
              ELSE
                l_entered_cr := l_rev_lines_tab_inst(l_indx).revision_amount;
              END IF;
            END IF;
          END;
        ELSIF (l_account_type IN ('L','O','R')) THEN
          BEGIN
            IF l_rev_lines_tab_inst(l_indx).revision_value_type = 'P' THEN
              IF l_rev_lines_tab_inst(l_indx).revision_type = 'I' then
                l_entered_cr := l_rev_lines_tab_inst(l_indx).revision_amount * l_rev_lines_tab_inst(l_indx).budget_balance / 100;
              ELSE
                l_entered_dr := l_rev_lines_tab_inst(l_indx).revision_amount * l_rev_lines_tab_inst(l_indx).budget_balance / 100;
              END IF;
            ELSE
              IF l_rev_lines_tab_inst(l_indx).revision_type = 'I' THEN
                l_entered_cr := l_rev_lines_tab_inst(l_indx).revision_amount;
              ELSE
                l_entered_dr := l_rev_lines_tab_inst(l_indx).revision_amount;
              END IF;
            END IF;
          END;
        END IF;

        -- Now assign the values to the PL/SQL table.
        l_code_combination_id_tab(l_indx) := l_rev_lines_tab_inst(l_Indx).code_combination_id;
        l_account_type_tab(l_indx)        := l_account_type;
        l_period_name_tab(l_indx)         := l_rev_lines_tab_inst(l_Indx).gl_period_name;
        l_period_year_tab(l_indx)         := l_rev_lines_tab_inst(l_Indx).period_year;
        l_period_num_tab(l_indx)          := l_rev_lines_tab_inst(l_Indx).period_num;
        l_quarter_num_tab(l_indx)         := l_rev_lines_tab_inst(l_Indx).quarter_num;
        l_currency_code_tab(l_indx)       := l_rev_lines_tab_inst(l_Indx).currency_code;
        l_status_code_tab(l_indx)         := l_status_code;
        l_budget_version_id_tab(l_indx)   := l_rev_lines_tab_inst(l_Indx).gl_budget_version_id;
        l_entered_dr_tab(l_indx)          := l_entered_dr;
        l_entered_cr_tab(l_indx)          := l_entered_cr;
        l_accounted_dr_tab(l_indx)        := l_entered_dr;
        l_accounted_cr_tab(l_indx)        := l_entered_cr;
        l_reference1_tab(l_indx)
          := TO_NUMBER(l_rev_lines_tab_inst(l_Indx).budget_revision_acct_line_id);
      END LOOP;
    END IF;

    --Now call the procedue in autonomous transaction.
    Insert_Into_GL_BCP
    (x_return_status       => l_return_status,
     p_packet_id           => l_packet_id,
     p_budget_revision_id  => p_budget_revision_id,
     p_code_combination_id => l_code_combination_id_tab,
     p_account_type        => l_account_type_tab,
     p_period_name         => l_period_name_tab,
     p_period_year         => l_period_year_tab,
     p_period_num          => l_period_num_tab,
     p_quarter_num         => l_quarter_num_tab,
     p_currency_code       => l_currency_code_tab,
     p_status_code         => l_status_code_tab,
     p_budget_version_id   => l_budget_version_id_tab,
     p_entered_dr          => l_entered_dr_tab,
     p_entered_cr          => l_entered_cr_tab,
     p_accounted_dr        => l_accounted_dr_tab,
     p_accounted_cr        => l_accounted_cr_tab,
     p_reference1          => l_reference1_tab
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      Savepoint Budget_Revision_Funds_Check;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Changed from R to P as PSA has removed the p_partial_resv_flag
    -- and added a new value 'P' to have the asme effect.
    -- To have the effect R and p_partial_resv_flag=Y, now
    -- we need to supply 'P'. For C, no need as Fund checked will
    -- always be performed with p_partial_resv_flag as Y.
    IF NOT PSA_FUNDS_CHECKER_PKG.GLXFCK
           (p_ledgerid    => g_set_of_books_id,
            p_packetid    => l_packet_id,
            p_mode        => l_mode,
            p_conc_flag   => 'N',
            p_return_code => l_return_status,
            p_calling_prog_flag => 'P' -- Bug 4589283
           )
    THEN
    -- Bug#4310411 End
      Savepoint Budget_Revision_Funds_Check;
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   p_fund_check_failures := 0;

   for c_Fund_Balances_rec in c_Fund_Balances loop

     /* start bug 4341619 */
     if ( (c_Fund_Balances_Rec.status_code = 'F') OR
          (c_Fund_Balances_Rec.status_code = 'T') OR
          (c_Fund_Balances_Rec.status_code = 'R') ) then

        p_fund_check_failures := p_fund_check_failures + 1;

     end if;
     /* end bug 4341619 */
     l_budget_balance
       := Get_GL_Balance
          (p_revision_type        => g_budget_revision_type,
           p_balance_type         => g_balance_type,
           p_set_of_books_id      => g_set_of_books_id,
           p_xbc_enabled_flag     => g_budgetary_control,
           p_gl_period_name       => c_Fund_Balances_Rec.period_name,
           p_gl_budget_version_id => c_Fund_Balances_rec.budget_version_id,
           p_currency_code        => c_Fund_Balances_Rec.currency_code,
           p_code_combination_id  => c_Fund_Balances_Rec.code_combination_id
          );

     UPDATE PSB_BUDGET_REVISION_ACCOUNTS
     SET budget_balance = l_budget_balance,
         funds_control_timestamp = sysdate,
         funds_control_status_code = c_Fund_Balances_Rec.status_code,
         funds_control_results_code = c_Fund_Balances_Rec.result_code
     WHERE budget_revision_acct_line_id = TO_NUMBER(c_Fund_Balances_Rec.reference1);

   end loop;

 end;
 end if;

 -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard check of p_commit.
  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Budget_Revision_Funds_Check;
     l_sql_code := sqlcode;
     l_sql_errm := sqlerrm;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     l_sql_code := sqlcode;
     l_sql_errm := sqlerrm;
     ROLLBACK TO Budget_Revision_Funds_Check;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

   WHEN OTHERS THEN
     l_sql_code := sqlcode;
     l_sql_errm := sqlerrm;
     ROLLBACK TO Budget_Revision_Funds_Check;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                l_api_name);
     end if;

End Budget_Revision_Funds_Check;

/*==========================================================================+
 |                       FUNCTION Get_GL_Balance                            |
 +==========================================================================*/

FUNCTION Get_GL_Balance
(p_revision_type         IN    VARCHAR2,
 p_balance_type          IN    VARCHAR2,
 p_set_of_books_id       IN    NUMBER,
 p_xbc_enabled_flag      IN    VARCHAR2,
 p_gl_period_name        IN    VARCHAR2,
 p_gl_budget_version_id  IN    NUMBER,
 p_currency_code         IN    VARCHAR2,
 p_code_combination_id   IN    NUMBER)
RETURN NUMBER IS

  /*For Bug No : 2925078 Start*/
  CURSOR C_Account_Type IS
    SELECT account_type
      FROM gl_code_combinations
     WHERE code_combination_id = p_code_combination_id;
  l_account_type    VARCHAR2(1);
  /*For Bug No : 2925078 End*/

  l_ccid_balance    NUMBER := 0;
BEGIN

  if p_revision_type = 'R' then
    -- Bug 4474717
    -- Replaced parameter xset_of_books_id with
    -- xledger_id in the following call.

    l_ccid_balance := gl_budget_transfer_pkg.get_balance
     (balance_type         => p_balance_type,
      xledger_id           => p_set_of_books_id,
      xbc_enabled_flag     => p_xbc_enabled_flag,
      xperiod_name         => p_gl_period_name,
      xbudget_version_id   => p_gl_budget_version_id,
      xcurrency_code       => p_currency_code,
      code_combination_id  => p_code_combination_id);

      /*For Bug No : 2925078 Start*/
      FOR C_Account_Type_rec IN C_Account_Type LOOP
        l_account_type := C_Account_Type_Rec.account_type;
      END LOOP;

      /* For Bug No: 3687997 */
      if l_account_type IN ('A','D','E') then
        return(l_ccid_balance);
      else
        return(-1 * l_ccid_balance);
      end if;
      /*For Bug No : 2925078 End*/

  elsif p_revision_type = 'C' then
    return(0);
  end if;

End Get_GL_Balance;

/*==========================================================================+
 |                       FUNCTION Find_System_Data_Extract                  |
 +==========================================================================*/

Function Find_System_Data_Extract
( p_budget_group_id        IN      NUMBER)
RETURN NUMBER IS

  Cursor C_system_data_extract is
    Select data_extract_id
      from psb_data_extracts pde,
           psb_budget_groups pbg
     where system_data_extract = 'Y'
       and (((pde.budget_group_id = pbg.root_budget_group_id)
            and (pbg.budget_group_id = p_budget_group_id))
        or ((pde.budget_group_id = pbg.budget_group_id)
            and (pbg.budget_group_id = p_budget_group_id)
            and (pbg.root_budget_group_id is null)));

  l_system_data_extract_id number := NULL;

Begin

   For C_system_data_extract_rec in C_system_data_extract Loop
    l_system_data_extract_id  := C_system_data_extract_rec.data_extract_id;
   End Loop;

   return(l_system_data_extract_id);

End Find_System_Data_Extract;

/*==========================================================================+
 |                       PROCEDURE Apply_Element_Parameters                 |
 +==========================================================================*/

PROCEDURE Apply_Element_Parameters
( p_return_status          OUT  NOCOPY  VARCHAR2,
  p_budget_revision_id     IN   NUMBER,
  p_local_parameter        IN   VARCHAR2,
  p_parameter_id           IN   NUMBER,
  p_revision_start_date    IN   DATE,
  p_revision_end_date      IN   DATE) IS

  l_return_status          VARCHAR2(1);
  l_compound_annually      VARCHAR2(1);
  l_start_date             DATE;
  l_end_date               DATE;

  l_compound_factor        NUMBER;
  l_num_revision_years     NUMBER;

/*Bug:5753424: Modified the query to fetch effective_start_date from
  psb_entity_assignment table */

  cursor c_Parameter is
    select parameter_id,
           name,
           priority,
           parameter_autoinc_rule,
           parameter_compound_annually,
           currency_code,
           effective_start_date,
           effective_end_date
      from PSB_PARAMETER_ASSIGNMENTS_V
     where p_local_parameter = 'N'
       and data_extract_id = g_data_extract_id
       and parameter_type = 'ELEMENT'
       and (((effective_start_date <= p_revision_end_date)
         and (effective_end_date is null))
         or ((effective_start_date between p_revision_start_date and p_revision_end_date)
          or (effective_end_date between p_revision_start_date and p_revision_end_date)
         or ((effective_start_date < p_revision_start_date)
         and (effective_end_date > p_revision_end_date))))
       and parameter_set_id = g_parameter_set_id
     union
    select prv.parameter_id,
           prv.name,
           0 priority,
           prv.parameter_autoinc_rule,
           prv.parameter_compound_annually,
           prv.currency_code,
           pea.effective_start_date,
           pea.effective_end_date
      from PSB_PARAMETERS_V prv,
           psb_entity_assignment pea
     where p_local_parameter = 'Y'
       and prv.data_extract_id = g_data_extract_id
       and prv.parameter_type = 'ELEMENT'
       and (((pea.effective_start_date <= p_revision_end_date)
         and (pea.effective_end_date is null))
       or ((pea.effective_start_date between p_revision_start_date and p_revision_end_date)
          or (pea.effective_end_date between p_revision_start_date and p_revision_end_date)
         or ((pea.effective_start_date < p_revision_start_date)
         and (pea.effective_end_date > p_revision_end_date))))
       and prv.parameter_id = p_parameter_id
       and prv.parameter_id = pea.entity_id
     order by effective_start_date, priority;

BEGIN

   /*start bug:5753424: procedure level logging*/
  if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
    'PSB/LOCAL_PARAM_SET/PSBVBRVB/Apply_Element_Parameters',
    'BEGIN Apply_Element_Parameters');
   fnd_file.put_line(fnd_file.LOG,'Start Apply_Element_Parameters');
   end if;
   /*end bug:5753424:end procedure level log*/

  for c_parameter_rec in c_parameter loop

   /*start bug:5753424: statement level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
    'PSB/LOCAL_PARAM_SET/PSBVBRVB/Apply_Element_Parameters',
    'Inside c_parameter loop for parameter:'||c_parameter_rec.parameter_id);
   fnd_file.put_line(fnd_file.LOG,'Inside c_parameter loop for parameter:'||c_parameter_rec.parameter_id);
   end if;
   /*end bug:5753424:end statement level log*/

    -- Bug#4675858
    -- Set the global variable to TRUE.
    g_elem_projection := TRUE ;
    --
    if ((c_Parameter_Rec.parameter_compound_annually is null) or
        (c_Parameter_Rec.parameter_compound_annually = 'N')) then
    begin

      l_compound_annually := FND_API.G_FALSE;

      if ((c_Parameter_Rec.parameter_autoinc_rule is null) or
          (c_Parameter_Rec.parameter_autoinc_rule = 'N')) then
      begin

   /*start bug:5753424: statement level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
    'PSB/LOCAL_PARAM_SET/PSBVBRVB/Apply_Element_Parameters',
    'Before call - PSB_WS_POS3.Process_ElemParam for parameter:'||c_parameter_rec.parameter_id);
   fnd_file.put_line(fnd_file.LOG,'Before call - PSB_WS_POS3.Process_ElemParam(on parameter_autoinc_rule = N) for parameter:'||c_parameter_rec.parameter_id);
   end if;
   /*end bug:5753424:end statement level log*/

        PSB_WS_POS3.Process_ElemParam
              (p_return_status => l_return_status,
               p_worksheet_id => p_budget_revision_id,
               p_parameter_id => c_parameter_rec.parameter_id,
               p_currency_code => nvl(c_parameter_rec.currency_code, g_func_currency),
               p_start_date => greatest(p_revision_start_date, c_parameter_rec.effective_start_date),
               p_end_date => least(p_revision_end_date, nvl(c_parameter_rec.effective_end_date, p_revision_end_date)),
               p_compound_annually => l_compound_annually,
               p_compound_factor => l_compound_factor);

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
          raise FND_API.G_EXC_ERROR;
        end if;

      end;
      else
      begin

        if FND_API.to_Boolean(g_global_revision) then
        begin

    /*start bug:5753424: statement level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
    'PSB/LOCAL_PARAM_SET/PSBVBRVB/Apply_Element_Parameters',
    'Before call - PSB_WS_POS3.Process_ElemParam_AutoInc for parameter:'||c_parameter_rec.parameter_id);
   fnd_file.put_line(fnd_file.LOG,'Before call - PSB_WS_POS3.Process_ElemParam_AutoInc for parameter:'||c_parameter_rec.parameter_id);
   end if;
   /*end bug:5753424:end statement level log*/

          PSB_WS_POS3.Process_ElemParam_AutoInc
                (p_return_status => l_return_status,
                 p_worksheet_id => p_budget_revision_id,
                 p_data_extract_id => g_data_extract_id,
                 p_business_group_id => g_business_group_id,
                 p_parameter_id => c_parameter_rec.parameter_id,
                 p_currency_code => nvl(c_parameter_rec.currency_code, g_func_currency),
                 p_start_date => greatest(p_revision_start_date, c_parameter_rec.effective_start_date),
                 p_end_date => least(p_revision_end_date, nvl(c_parameter_rec.effective_end_date, p_revision_end_date)),
                 p_compound_factor => l_compound_factor);

          if l_return_status <> FND_API.G_RET_STS_SUCCESS then
            raise FND_API.G_EXC_ERROR;
          end if;

        end;
        end if;

      end;
      end if;

    end;
    else
    begin

      l_num_revision_years := ceil(months_between(p_revision_end_date, p_revision_start_date) / 12);
      l_start_date := p_revision_start_date;

      for i in 1..l_num_revision_years loop

        l_end_date := least(add_months(l_start_date, 12), p_revision_end_date);

        if ((c_Parameter_Rec.parameter_autoinc_rule is null) or
            (c_Parameter_Rec.parameter_autoinc_rule = 'N')) then
        begin

          l_compound_annually := FND_API.G_TRUE;
          l_compound_factor := greatest(ceil(months_between(l_start_date, c_Parameter_Rec.effective_start_date) / 12), 0) + 1;

      /*start bug:5753424: statement level logging*/
   if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
     'PSB/LOCAL_PARAM_SET/PSBVBRVB/Apply_Element_Parameters',
     'Before call - PSB_WS_POS3.Process_ElemParam for parameter:'||c_parameter_rec.parameter_id);
    fnd_file.put_line(fnd_file.LOG,'Before call - PSB_WS_POS3.Process_ElemParam for parameter:'||c_parameter_rec.parameter_id);
    end if;
   /*end bug:5753424:end statement level log*/

          PSB_WS_POS3.Process_ElemParam
                (p_return_status => l_return_status,
                 p_worksheet_id => p_budget_revision_id,
                 p_parameter_id => c_Parameter_Rec.parameter_id,
                 p_currency_code => nvl(c_Parameter_Rec.currency_code, g_func_currency),
                 p_start_date => greatest(l_start_date, c_Parameter_Rec.effective_start_date),
                 p_end_date => least(l_end_date, nvl(c_Parameter_Rec.effective_end_date, l_end_date)),
                 p_compound_annually => l_compound_annually,
                 p_compound_factor => l_compound_factor);

          if l_return_status <> FND_API.G_RET_STS_SUCCESS then
            raise FND_API.G_EXC_ERROR;
          end if;

        end;
        else
        begin

          if FND_API.to_Boolean(g_global_revision) then
          begin

            l_compound_factor := greatest(ceil(months_between(l_start_date, c_Parameter_Rec.effective_start_date) / 12), 0) + 1;

     /*start bug:5753424: statement level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
    'PSB/LOCAL_PARAM_SET/PSBVBRVB/Apply_Element_Parameters',
    'Before call - PSB_WS_POS3.Process_ElemParam_AutoInc for parameter:'||c_parameter_rec.parameter_id);
   fnd_file.put_line(fnd_file.LOG,'Before call - PSB_WS_POS3.Process_ElemParam_AutoInc for parameter:'||c_parameter_rec.parameter_id);
   end if;
   /*end bug:5753424:end statement level log*/

            PSB_WS_POS3.Process_ElemParam_AutoInc
                   (p_return_status => l_return_status,
                    p_worksheet_id => p_budget_revision_id,
                    p_data_extract_id => g_data_extract_id,
                    p_business_group_id => g_business_group_id,
                    p_parameter_id => c_Parameter_Rec.parameter_id,
                    p_currency_code => nvl(c_Parameter_Rec.currency_code, g_func_currency),
                    p_start_date => greatest(l_start_date, c_Parameter_Rec.effective_start_date),
                    p_end_date => least(l_end_date, nvl(c_Parameter_Rec.effective_end_date, l_end_date)),
                    p_compound_factor => l_compound_factor);

            if l_return_status <> FND_API.G_RET_STS_SUCCESS then
              raise FND_API.G_EXC_ERROR;
            end if;

          end;
          end if;

        end;
        end if;

        l_start_date := l_end_date;

      end loop;

    end;
    end if;

  end loop;

  -- Set API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

   /*start bug:5753424: procedure level logging*/
  if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
    'PSB/LOCAL_PARAM_SET/PSBVBRVB/Apply_Element_Parameters',
    'END Apply_Element_Parameters');
   fnd_file.put_line(fnd_file.LOG,'End Apply_Element_Parameters');
   end if;
   /*end bug:5753424:end procedure level log*/

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

End Apply_Element_Parameters;

/*==========================================================================+
 |                       PROCEDURE Apply_Position_Parameters                |
 +==========================================================================*/

PROCEDURE Apply_Position_Parameters
( p_return_status          OUT  NOCOPY  VARCHAR2,
  p_budget_revision_id     IN   NUMBER,
  p_local_parameter        IN   VARCHAR2,
  p_parameter_id           IN   NUMBER,
  p_revision_start_date    IN   DATE,
  p_revision_end_date      IN   DATE) IS

  l_start_date             DATE;
  l_end_date               DATE;
  l_num_revision_years     NUMBER;
  l_compound_annually      VARCHAR2(1);
  l_compound_factor        NUMBER;
  l_return_status          VARCHAR2(1);

/*Bug:5753424: Modified the cursor*/
  cursor c_parameter is
    select parameter_id,
           name,
           priority,
           parameter_compound_annually,
           currency_code,
           effective_start_date,
           effective_end_date
      from PSB_PARAMETER_ASSIGNMENTS_V
     where p_local_parameter = 'N'
       and parameter_autoinc_rule = 'N'
       and data_extract_id = g_data_extract_id
       and parameter_type = 'POSITION'
       and (((effective_start_date <= p_revision_end_date)
         and (effective_end_date is null))
       or ((effective_start_date between p_revision_start_date and p_revision_end_date)
          or (effective_end_date between p_revision_start_date and p_revision_end_date)
         or ((effective_start_date < p_revision_start_date)
         and (effective_end_date > p_revision_end_date))))
       and parameter_set_id = g_parameter_set_id
     union
/*Bug:5753424: Modified the query to fetch effective_start_date from
  psb_entity_assignment table */
    select prv.parameter_id,
           prv.name,
           0 priority,
           prv.parameter_compound_annually,
           prv.currency_code,
           pea.effective_start_date,
           pea.effective_end_date
      from PSB_PARAMETERS_V prv,
           psb_entity_assignment pea
     where p_local_parameter = 'Y'
       and prv.parameter_autoinc_rule = 'N'
       and prv.data_extract_id = g_data_extract_id
       and prv.parameter_type = 'POSITION'
       and (((pea.effective_start_date <= p_revision_end_date)
         and (pea.effective_end_date is null))
       or ((pea.effective_start_date between p_revision_start_date and p_revision_end_date)
          or (pea.effective_end_date between p_revision_start_date and p_revision_end_date)
         or ((pea.effective_start_date < p_revision_start_date)
         and (pea.effective_end_date > p_revision_end_date))))
       and prv.parameter_id = p_parameter_id
       and prv.parameter_id = pea.entity_id
     order by effective_start_date, priority;

/*Bug:5753424: Modified the cursor*/
  cursor c_ParamAutoInc is
    select parameter_id,
           name,
           priority,
           parameter_compound_annually,
           currency_code,
           effective_start_date,
           effective_end_date
      from PSB_PARAMETER_ASSIGNMENTS_V
     where p_local_parameter = 'N'
       and parameter_autoinc_rule = 'Y'
       and data_extract_id = g_data_extract_id
       and parameter_type = 'POSITION'
       and (((effective_start_date <= p_revision_end_date)
         and (effective_end_date is null))
         or ((effective_start_date between p_revision_start_date and p_revision_end_date)
          or (effective_end_date between p_revision_start_date and p_revision_end_date)
         or ((effective_start_date < p_revision_start_date)
         and (effective_end_date > p_revision_end_date))))
       and parameter_set_id = g_parameter_set_id
     union
/*Bug:5753424: Modified the query to fetch effective_start_date from
  psb_entity_assignment table */
    select prv.parameter_id,
           prv.name,
           0 priority,
           prv.parameter_compound_annually,
           prv.currency_code,
           pea.effective_start_date,
           pea.effective_end_date
      from PSB_PARAMETERS_V prv,
           psb_entity_assignment pea
     where p_local_parameter = 'Y'
       and prv.parameter_id = p_parameter_id
       and pea.entity_id = prv.parameter_id
       and prv.parameter_autoinc_rule = 'Y'
       and prv.data_extract_id = g_data_extract_id
       and prv.parameter_type = 'POSITION'
       and (((pea.effective_start_date <= p_revision_end_date)  --bug:5753424:commented l_end_date
         and (pea.effective_end_date is null))
         or ((pea.effective_start_date between p_revision_start_date and p_revision_end_date)
          or (pea.effective_end_date between p_revision_start_date and p_revision_end_date)
         or ((pea.effective_start_date < p_revision_start_date)
         and (pea.effective_end_date > p_revision_end_date))))
     order by effective_start_date,
              priority;

BEGIN

   /*start bug:5753424: procedure level logging*/
  if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
    'PSB/LOCAL_PARAM_SET/PSBVBRVB/Apply_Position_Parameters',
    'BEGIN Apply_Position_Parameters');
   fnd_file.put_line(fnd_file.LOG,'BEGIN Apply_Position_Parameters');
   end if;
   /*end bug:5753424:end procedure level log*/

  for c_parameter_rec in c_parameter loop

    if ((c_Parameter_Rec.parameter_compound_annually is null) or
        (c_Parameter_Rec.parameter_compound_annually = 'N')) then
    begin

      l_compound_annually := FND_API.G_FALSE;

     /*start bug:5753424: statement level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
    'PSB/LOCAL_PARAM_SET/PSBVBRVB/Apply_Position_Parameters',
    'Before call - PSB_WS_POS3.Process_PosParam_Detailed for parameter:'||c_parameter_rec.parameter_id);
   fnd_file.put_line(fnd_file.LOG,'Before call - PSB_WS_POS3.Process_PosParam_Detailed for parameter:'||c_parameter_rec.parameter_id);
   end if;
   /*end bug:5753424:end statement level log*/

      PSB_WS_POS3.Process_PosParam_Detailed
            (p_return_status => l_return_status,
             p_event_type => 'BR',
             p_local_parameter => p_local_parameter,
             p_worksheet_id => p_budget_revision_id,
             p_global_worksheet_id => g_global_budget_revision_id,
             p_global_worksheet => g_global_revision,
             p_data_extract_id => g_data_extract_id,
             p_business_group_id => g_business_group_id,
             p_parameter_id => c_parameter_rec.parameter_id,
             p_parameter_start_date => c_parameter_rec.effective_start_date,
             p_compound_annually => l_compound_annually,
             p_compound_factor => l_compound_factor,
             p_parameter_autoinc_rule => 'N',
             p_currency_code => nvl(c_parameter_rec.currency_code, g_func_currency),
             p_start_date => greatest(p_revision_start_date, c_Parameter_Rec.effective_start_date),
             p_end_date => least(p_revision_end_date, nvl(c_Parameter_Rec.effective_end_date, p_revision_end_date)));

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
        raise FND_API.G_EXC_ERROR;
      end if;

    end;
    else
    begin

      l_num_revision_years := ceil(months_between(p_revision_end_date, p_revision_start_date) / 12);
      l_start_date := p_revision_start_date;

      for i in 1..l_num_revision_years loop

        l_end_date := least(add_months(l_start_date, 12), p_revision_end_date);

        l_compound_annually := FND_API.G_TRUE;
        l_compound_factor := greatest(ceil(months_between(l_start_date, c_Parameter_Rec.effective_start_date) / 12), 0) + 1;

   /*start bug:5753424: statement level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
    'PSB/LOCAL_PARAM_SET/PSBVBRVB/Apply_Position_Parameters',
    'Before call - PSB_WS_POS3.Process_PosParam_Detailed for parameter:'||c_parameter_rec.parameter_id);
   fnd_file.put_line(fnd_file.LOG,'Before call - PSB_WS_POS3.Process_PosParam_Detailed for parameter:'||c_parameter_rec.parameter_id);
   end if;
   /*end bug:5753424:end statement level log*/

        PSB_WS_POS3.Process_PosParam_Detailed
            (p_return_status => l_return_status,
             p_event_type => 'BR',
             p_local_parameter => p_local_parameter,
             p_worksheet_id => p_budget_revision_id,
             p_global_worksheet_id => g_global_budget_revision_id,
             p_global_worksheet => g_global_revision,
             p_data_extract_id => g_data_extract_id,
             p_business_group_id => g_business_group_id,
             p_parameter_id => c_parameter_rec.parameter_id,
             p_parameter_start_date => c_parameter_rec.effective_start_date,
             p_compound_annually => l_compound_annually,
             p_compound_factor => l_compound_factor,
             p_parameter_autoinc_rule => 'N',
             p_currency_code => nvl(c_parameter_rec.currency_code, g_func_currency),
             p_start_date => greatest(l_start_date, c_Parameter_Rec.effective_start_date),
             p_end_date => least(l_end_date, nvl(c_Parameter_Rec.effective_end_date, l_end_date)));

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
          raise FND_API.G_EXC_ERROR;
        end if;

        l_start_date := l_end_date;

      end loop;

    end;
    end if;

  end loop;

  for c_parameter_rec in c_ParamAutoInc loop

    if ((c_Parameter_Rec.parameter_compound_annually is null) or
        (c_Parameter_Rec.parameter_compound_annually = 'N')) then
      l_compound_annually := FND_API.G_FALSE;
    else
      l_compound_annually := FND_API.G_TRUE;
    end if;

     /*start bug:5753424: statement level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
    'PSB/LOCAL_PARAM_SET/PSBVBRVB/Apply_Position_Parameters',
    'Before call(c_ParamAutoInc cursor) - PSB_WS_POS3.Process_PosParam_Detailed for parameter:'||c_parameter_rec.parameter_id);
   fnd_file.put_line(fnd_file.LOG,'Before call(c_ParamAutoInc cursor) - PSB_WS_POS3.Process_PosParam_Detailed for parameter:'||c_parameter_rec.parameter_id);
   end if;
   /*end bug:5753424:end statement level log*/

    PSB_WS_POS3.Process_PosParam_Detailed
          (p_return_status => l_return_status,
           p_event_type => 'BR',
           p_local_parameter => p_local_parameter,
           p_worksheet_id => p_budget_revision_id,
           p_global_worksheet_id => g_global_budget_revision_id,
           p_global_worksheet => g_global_revision,
           p_data_extract_id => g_data_extract_id,
           p_business_group_id => g_business_group_id,
           p_parameter_id => c_parameter_rec.parameter_id,
           p_parameter_start_date => c_parameter_rec.effective_start_date,
           p_compound_annually => l_compound_annually,
           p_compound_factor => l_compound_factor,
           p_parameter_autoinc_rule => 'Y',
           p_currency_code => nvl(c_parameter_rec.currency_code, g_func_currency),
           p_start_date => greatest(p_revision_start_date, c_Parameter_Rec.effective_start_date),
           p_end_date => least(p_revision_end_date, nvl(c_Parameter_Rec.effective_end_date, p_revision_end_date)));

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end loop;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

   /*start bug:5753424: procedure level logging*/
  if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
    'PSB/LOCAL_PARAM_SET/PSBVBRVB/Apply_Position_Parameters',
    'END Apply_Position_Parameters');
   fnd_file.put_line(fnd_file.LOG,'END Apply_Position_Parameters');
   end if;
   /*end bug:5753424:end procedure level log*/

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

End Apply_Position_Parameters;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                      PROCEDURE Create_Summary_Position_Line               |
 +===========================================================================*/
PROCEDURE Create_Summary_Position_Line
( p_return_status         OUT  NOCOPY  VARCHAR2,
  p_budget_revision_id    IN   NUMBER,
  p_currency_code         IN   VARCHAR2,
  p_gl_period_name        IN   VARCHAR2
)
IS
  l_return_status                 VARCHAR2(1);
  l_msg_count                     NUMBER;
  l_msg_data                      VARCHAR2(2000);
  l_budget_revision_acct_line_id  NUMBER;
  l_revision_type                 VARCHAR2(1);
  l_revision_amount               NUMBER;
  l_current_budget_balance        NUMBER;

  CURSOR l_rollup_ccid_csr
  IS
  SELECT pbra.code_combination_id, pbra.gl_budget_version_id,
         pbra.budget_group_id,
         sum(decode(pbra.revision_type, 'D', -1 * pbra.revision_amount,
             pbra.revision_amount)) sum_revision
  FROM   psb_budget_revision_lines pbrl, psb_budget_revision_accounts pbra
  WHERE  pbrl.budget_revision_id           = p_budget_revision_id
  AND    pbra.budget_revision_acct_line_id = pbrl.budget_revision_acct_line_id
  AND    pbra.gl_period_name               = p_gl_period_name
  AND    pbra.position_id IS NOT NULL
  GROUP  BY pbra.code_combination_id, pbra.gl_budget_version_id,
         pbra.budget_group_id ;

BEGIN

  -- Process all the rollup ccids corresponding to positions.
  FOR l_rollup_ccid_rec IN l_rollup_ccid_csr LOOP

    l_budget_revision_acct_line_id := NULL;

    if l_rollup_ccid_rec.sum_revision < 0 then
      l_revision_type := 'D';
      l_revision_amount := -1 * l_rollup_ccid_rec.sum_revision;
    else
      l_revision_type := 'I';
      l_revision_amount := l_rollup_ccid_rec.sum_revision;
    end if;

    l_current_budget_balance :=
    Get_GL_Balance
    ( p_revision_type         => g_budget_revision_type,
      p_balance_type          => g_balance_type,
      p_set_of_books_id       => g_set_of_books_id,
      p_xbc_enabled_flag      => g_budgetary_control,
      p_gl_period_name        => p_gl_period_name,
      p_gl_budget_version_id  => l_rollup_ccid_rec.gl_budget_version_id,
      p_currency_code         => g_currency_code,
      p_code_combination_id   => l_rollup_ccid_rec.code_combination_id
    );

    Create_Revision_Accounts
    ( p_api_version => 1.0,
      p_return_status => l_return_status,
      p_msg_count => l_msg_count,
      p_msg_data => l_msg_data,
      p_budget_revision_id => p_budget_revision_id,
      p_budget_revision_acct_line_id => l_budget_revision_acct_line_id,
      p_code_combination_id => l_rollup_ccid_rec.code_combination_id,
      p_budget_group_id => l_rollup_ccid_rec.budget_group_id,
      p_gl_period_name => p_gl_period_name,
      p_gl_budget_version_id => l_rollup_ccid_rec.gl_budget_version_id,
      p_currency_code => p_currency_code,
      p_budget_balance => l_current_budget_balance,
      p_revision_type => l_revision_type,
      p_revision_value_type => 'A',
      p_revision_amount => l_revision_amount,
      p_note_id => FND_API.G_MISS_NUM,
      p_funds_control_timestamp => sysdate,
      p_funds_status_code => FND_API.G_MISS_CHAR,
      p_funds_result_code => FND_API.G_MISS_CHAR,
      p_freeze_flag => 'N',
      p_view_line_flag => 'Y'
    ) ;
    --
    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;
    --
  END LOOP;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

End Create_Summary_Position_Line;
/*---------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------*/
PROCEDURE Create_Mass_Revision_Entries
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_data_extract_id     IN      NUMBER,
  p_budget_revision_id  IN      NUMBER,
  p_parameter_id        IN      NUMBER := FND_API.G_MISS_NUM
) IS

  l_api_name                     CONSTANT VARCHAR2(30)  := 'Create_Mass_Revision_Entries';
  l_api_version                  CONSTANT NUMBER        := 1.0;

  l_effective_start_date         DATE;
  l_effective_end_date           DATE;

  l_budget_revision_acct_line_id NUMBER;
  l_original_budget_balance      NUMBER;
  l_current_budget_balance       NUMBER;

  l_budget_version_id            NUMBER;
  l_budget_revision_pos_line_id  NUMBER;
  l_revision_type                VARCHAR2(1);
  l_revision_amount              NUMBER := 0;
  l_revised_amount               NUMBER := 0;
  l_concat_segments              VARCHAR2(2000);
  l_ccid_valid                   VARCHAR2(1) := FND_API.G_FALSE;
  l_out_ccid                     NUMBER;
  l_compound_annually            VARCHAR2(1);
  l_compound_factor              NUMBER;

  l_ccid_index                   NUMBER;
  l_ccid_type                    VARCHAR2(30);
  l_pos_line_id                  NUMBER;
  l_parameter_id                 NUMBER;
  l_local_parameter              VARCHAR2(1);
  lx_from_date                   DATE;
  l_return_status                VARCHAR2(1);
  l_msg_count                    NUMBER;
  l_msg_data                     VARCHAR2(2000);

  l_gl_period_name               VARCHAR2(15);
  l_ccid_start_period            DATE;
  l_ccid_end_period              DATE;

/* Bug No 1808330 Start */
  l_note                         VARCHAR2(4000); -- Bug#4675858
/* Bug No 1808330 End */

  cursor c_gl_periods is
    Select period_name,
           start_date,end_date
      from gl_period_statuses
     where application_id = 101
       and set_of_books_id = g_set_of_books_id
       and start_date between g_from_date and g_to_date
       and end_date between g_from_date and g_to_date
       and closing_status <> 'C'
       /*Bug No. 4018446 Start*/
       and adjustment_period_flag = 'N';
       /*Bug No. 4018446 End*/

  /* Bug:5753424:Fetched effective_start_date and effective_end_date from psb_entity_assignment
     table. */
  -- Bug 3029168 In the following cursor added the join with g_currency_code

  -- Bug#4675858
  -- Added NVL condition for nullable currency_code column.
  cursor c_AccParam is
    Select parameter_id,
           name,
           effective_start_date,
           effective_end_date,
           priority priority,
           parameter_compound_annually,
           currency_code
      from PSB_PARAMETER_ASSIGNMENTS_V
     where l_parameter_id is null
       and parameter_set_id = g_parameter_set_id
       and parameter_type = 'ACCOUNT'
       and NVL(currency_code, g_currency_code) = g_currency_code
    UNION
    Select pe.entity_id,
           pe.name,
           pea.effective_start_date,
           pea.effective_end_date,
           0 priority,
           pe.parameter_compound_annually,
           pe.currency_code
      from PSB_ENTITY pe,
           psb_entity_assignment pea      --bug:5753424
     where pe.entity_id = l_parameter_id
       and pe.entity_subtype = 'ACCOUNT'
       and pe.entity_id = pea.entity_id     --bug:5753424
       and NVL(pe.currency_code, g_currency_code) = g_currency_code
     order by effective_start_date, priority;

  cursor c_account_sets is
    select account_position_set_id, account_or_position_type, budget_group_id,
           effective_start_date, effective_end_date
      from PSB_SET_RELATIONS_V
     where budget_group_id in
          (select budget_group_id
             from psb_budget_groups
            where effective_start_date <= l_effective_start_date
              and (effective_end_date is null or
                   effective_end_date >= l_effective_end_date)
            start with budget_group_id = g_budget_group_id
            connect by prior budget_group_id = parent_budget_group_id)
       and account_or_position_type = 'A';

  cursor c_positions is
    select a.position_id, a.effective_start_date, a.effective_end_date, a.budget_group_id
      from PSB_POSITIONS a,
          (select budget_group_id from PSB_BUDGET_GROUPS
            start with budget_group_id = g_budget_group_id
          connect by prior budget_group_id = parent_budget_group_id) b
     where a.data_extract_id = p_data_extract_id
       and a.budget_group_id = b.budget_group_id
       and a.hr_position_id is not null;

  cursor c_localparam_positions is
    select pbrp.position_id, pbrp.effective_start_date, pbrp.effective_end_date,
/* Bug No 1808330 Start */
    pbrp.budget_revision_pos_line_id
/* Bug No 1808330 End */
      from PSB_BUDGET_REVISION_POS_LINES pbrpl, PSB_BUDGET_REVISION_POSITIONS pbrp
     where pbrpl.budget_revision_id = p_budget_revision_id
       and pbrp.budget_revision_pos_line_id = pbrpl.budget_revision_pos_line_id;

 cursor c_period_list is
   Select period_name,
           start_date,end_date
      from gl_period_statuses
     where application_id = 101
       and set_of_books_id = g_set_of_books_id
       and start_date between g_effective_start_date and g_effective_end_date
       and end_date between g_effective_start_date and g_effective_end_date
       and closing_status <> 'C'
       /*Bug No. 4018446 Start*/
       and adjustment_period_flag = 'N';
       /*Bug No. 4018446 End*/

  cursor c_period (startdate DATE) is
    select period_name,
           start_date,
           end_date
      from gl_period_statuses
     where application_id  = 101
       and set_of_books_id = g_set_of_books_id
       and startdate between start_date and end_date;

Begin

   /*start bug:5753424: procedure level logging*/
  if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
    'PSB/LOCAL_PARAM_SET/PSBVBRVB/Create_Mass_Revision_Entries',
    'BEGIN Create_Mass_Revision_Entries');
   fnd_file.put_line(fnd_file.LOG,'BEGIN Create_Mass_Revision_Entries');
   end if;
   /*end bug:5753424:end procedure level log*/

  -- Standard Start of API savepoint

  SAVEPOINT     Create_Mass_Revision_Entries;

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  -- Initialize global variables.

  Cache_Revision_Variables(p_budget_revision_id => p_budget_revision_id,
                           p_return_status => l_return_status);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  -- Bug 3029168 commitment apis will not be called for STAT
  IF g_budget_revision_type = 'C'
  AND g_currency_code <> 'STAT' THEN
  begin -- commitment budget revision

     PSB_Commitments_PVT.Create_Commitment_Revisions
     ( p_api_version        => 1.0,
       p_init_msg_list      => FND_API.G_FALSE,
       p_commit             => FND_API.G_FALSE,
       p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
       p_return_status      => l_return_status,
       p_msg_count          => l_msg_count,
       p_msg_data           => l_msg_data,
       p_budget_revision_id => p_budget_revision_id);

    if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
      add_message('PSB','PSB_CBC_MASS_REVISION_FAILED');
      RAISE FND_API.G_EXC_ERROR;
    end if;

  end; -- commitment budget revision
  elsif (g_budget_revision_type = 'R') then -- regular budget revision
  begin

    if (p_parameter_id = FND_API.G_MISS_NUM) then
      l_parameter_id := null;
      l_local_parameter := 'N';
    else
      l_parameter_id := p_parameter_id;
      l_local_parameter := 'Y';
    end if;

    lx_from_date := g_from_date;

    for c_gl_periods_rec in c_gl_periods loop
      l_effective_start_date := c_gl_periods_rec.start_date;
      l_effective_end_date   := c_gl_periods_rec.end_date;

      For C_Account_Sets_Rec in C_Account_Sets Loop

        PSB_WS_ACCT1.Find_CCIDs
        (p_return_status => l_return_status,
         p_account_set_id => c_Account_Sets_Rec.account_position_set_id);

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
          raise FND_API.G_EXC_ERROR;
        end if;

        for l_ccid_index in 1..PSB_WS_ACCT1.g_num_ccids loop

          l_ccid_start_period := greatest(nvl(PSB_WS_ACCT1.g_ccids(l_ccid_index).start_date,
                                          c_Account_Sets_Rec.effective_start_date), c_Account_Sets_Rec.effective_start_date);
          l_ccid_end_period := least(nvl(PSB_WS_ACCT1.g_ccids(l_ccid_index).end_date,
                                         c_Account_Sets_Rec.effective_end_date), c_Account_Sets_Rec.effective_end_date);

          l_ccid_type := null;

          if (g_revise_by_position = 'Y') then
          begin

            PSB_WS_ACCT1.Check_CCID_Type
               (p_api_version => 1.0,
                p_return_status => l_return_status,
                p_ccid_type => l_ccid_type,
                p_flex_code => g_flex_code,
                p_ccid => PSB_WS_ACCT1.g_ccids(l_ccid_index).ccid,
                p_budget_group_id => c_Account_Sets_Rec.budget_group_id);

            if l_return_status <> FND_API.G_RET_STS_SUCCESS then
              raise FND_API.G_EXC_ERROR;
            end if;

          end;
          end if;

          if ((g_revise_by_position = 'N') or
             ((g_revise_by_position = 'Y') and (l_ccid_type = 'NON_PERSONNEL_SERVICES'))) then
          begin

            l_budget_version_id := null;
            l_original_budget_balance := 0;
            l_current_budget_balance := 0;

            PSB_GL_BUDGET_PVT.Find_GL_Budget
               (p_api_version => 1.0,
                p_return_status => l_return_status,
                p_msg_count => l_msg_count,
                p_msg_data => l_msg_data,
                p_gl_budget_set_id => g_gl_budget_set_id,
                p_code_combination_id => PSB_WS_ACCT1.g_ccids(l_ccid_index).ccid,
                p_start_date => c_gl_periods_rec.start_date,
                p_dual_posting_type => 'A',
                p_gl_budget_version_id => l_budget_version_id);

            if l_return_status <> FND_API.G_RET_STS_SUCCESS then
              raise FND_API.G_EXC_ERROR;
            end if;

            if ((l_budget_version_id is null) and (g_permanent_revision = 'Y')) then
            begin

              PSB_GL_BUDGET_PVT.Find_GL_Budget
                 (p_api_version => 1.0,
                  p_return_status => l_return_status,
                  p_msg_count => l_msg_count,
                  p_msg_data => l_msg_data,
                  p_gl_budget_set_id => g_gl_budget_set_id,
                  p_code_combination_id => PSB_WS_ACCT1.g_ccids(l_ccid_index).ccid,
                  p_start_date => c_gl_periods_rec.start_date,
                  p_gl_budget_version_id => l_budget_version_id);

              if l_return_status <> FND_API.G_RET_STS_SUCCESS then
                raise FND_API.G_EXC_ERROR;
              end if;

            end;
            end if;

            -- Get Original Budget for the ccid + gl_period + budget_version_id
            l_original_budget_balance := Find_Original_Budget_Balance
             (p_code_combination_id   => PSB_WS_ACCT1.g_ccids(l_ccid_index).ccid,
              p_budget_group_id        => c_Account_Sets_Rec.budget_group_id,
              p_gl_period              => c_gl_periods_rec.period_name,
              p_gl_budget_version_id   => l_budget_version_id,
              p_currency_code          => g_currency_code); -- Bug 3029168

            l_current_budget_balance := Get_GL_Balance
             (p_revision_type         => g_budget_revision_type,
              p_balance_type          => g_balance_type,
              p_set_of_books_id       => g_set_of_books_id,
              p_xbc_enabled_flag      => g_budgetary_control,
              p_gl_period_name        => c_gl_periods_rec.period_name,
              p_gl_budget_version_id  => l_budget_version_id,
              p_currency_code         => g_currency_code,
              p_code_combination_id   => PSB_WS_ACCT1.g_ccids(l_ccid_index).ccid);

            -- Compute a Compound Factor for each Budget Year if Compound Annually is set

            if (c_gl_periods_rec.start_date > add_months(lx_from_date, 12)) then
              lx_from_date := add_months(lx_from_date, 12);
            end if;

            For c_AccParam_Rec in c_AccParam loop

              if (AcctParam_Exists(p_parameter_id => c_AccParam_Rec.parameter_id,
                                   p_budget_revision_id => p_budget_revision_id,
                                   p_period_name => c_gl_periods_rec.period_name,
                                   p_local_parameter => l_local_parameter,
                                   p_ccid => PSB_WS_ACCT1.g_ccids(l_ccid_index).ccid,
                                   p_ccid_start_period => l_ccid_start_period,
                                   p_ccid_end_period => l_ccid_end_period,
                                   p_period_start_date => c_gl_periods_rec.start_date,
                                   p_period_end_date => c_gl_periods_rec.end_date)) then
              begin

                if ((c_AccParam_Rec.parameter_compound_annually is null) or
                    (c_AccParam_Rec.parameter_compound_annually = 'N')) then
                  l_compound_annually := FND_API.G_FALSE;
                else
                  l_compound_annually := FND_API.G_TRUE;
                  l_compound_factor := greatest(ceil(months_between(lx_from_date, c_AccParam_Rec.effective_start_date) / 12), 0) + 1;
                end if;

   /*start bug:5753424: statement level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
    'PSB/LOCAL_PARAM_SET/PSBVBRVB/Create_Mass_Revision_Entries',
    'Before call to Apply_Revision_Acct_Parameters for parameter id:'||c_AccParam_Rec.parameter_id);
   fnd_file.put_line(fnd_file.LOG,'Before call to Apply_Revision_Acct_Parameters for parameter id:'||c_AccParam_Rec.parameter_id);
   end if;
   /*end bug:5753424:end statement level log*/

                Apply_Revision_Acct_Parameters
                     (p_api_version         => 1.0,
                      p_return_status       => l_return_status,
                      p_parameter_id        => c_AccParam_Rec.parameter_id,
                      p_parameter_name      => c_AccParam_Rec.name,
                      p_compound_annually   => l_compound_annually,
                      p_compound_factor     => l_compound_factor,
                      p_original_budget     => l_original_budget_balance,
                      p_current_budget      => l_current_budget_balance,
                      p_revision_amount     => l_revision_amount);

                if l_return_status <> FND_API.G_RET_STS_SUCCESS then
                  raise FND_API.G_EXC_ERROR;
                end if;

                l_budget_revision_acct_line_id := null;

        if (l_revision_amount < 0) then
           l_revision_type := 'D';
           l_revision_amount := (-1) * l_revision_amount;
        else
           l_revision_type := 'I';
        end if;

                if ((l_revision_amount <> 0) or ((l_revision_amount = 0) and (g_create_zero_bal = 'Y'))) then
                begin

                  Create_Revision_Accounts
                        (p_api_version                    => 1.0,
                         p_init_msg_list                  => FND_API.G_FALSE,
                         p_commit                         => FND_API.G_FALSE,
                         p_validation_level               => FND_API.G_VALID_LEVEL_FULL,
                         p_return_status                  => l_return_status,
                         p_msg_count                      => l_msg_count,
                         p_msg_data                       => l_msg_data,
                         p_budget_revision_id             => p_budget_revision_id,
                         p_budget_revision_acct_line_id   => l_budget_revision_acct_line_id,
                         p_code_combination_id            => PSB_WS_ACCT1.g_ccids(l_ccid_index).ccid,
                         p_budget_group_id                => c_Account_Sets_Rec.budget_group_id,
                         p_gl_period_name                 => c_gl_periods_rec.period_name,
                         p_gl_budget_version_id           => l_budget_version_id,
                         p_currency_code                  => g_currency_code,
                         p_budget_balance                 => l_current_budget_balance,
                         p_revision_type                  => l_revision_type,
                         p_revision_value_type            => 'A',
                         p_revision_amount                => l_revision_amount,
                         p_funds_status_code              => FND_API.G_MISS_CHAR,
                         p_funds_result_code              => FND_API.G_MISS_CHAR,
                         p_note_id                        => FND_API.G_MISS_NUM,
                         p_funds_control_timestamp        => sysdate,
                         p_freeze_flag                    => 'N',
                         p_view_line_flag                 => 'Y');

                  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
                    raise FND_API.G_EXC_ERROR;
                  end if;

/* Bug No 1808330 Start */
---- Creates or Updates a Note Id in PSB_WS_ACCOUNT_LINE_NOTES table

      FND_MESSAGE.SET_NAME('PSB', 'PSB_PARAMETER_NOTE_CREATION');
      FND_MESSAGE.SET_TOKEN('NAME', c_AccParam_Rec.name);
      FND_MESSAGE.SET_TOKEN('DATE', sysdate);
      l_note := FND_MESSAGE.GET;

      -- Bug#4571412
      -- Added p_flex_code to make the call in
      -- in sync with its definition.
      Create_Note
      ( p_return_status    => l_return_status
      , p_account_line_id  => l_budget_revision_acct_line_id
      , p_position_line_id => NULL
      , p_note             => l_note
      , p_flex_code        => g_flex_code
      , p_cc_id            => PSB_WS_ACCT1.g_ccids(l_ccid_index).ccid -- Bug#4675858
      ) ;

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
        raise FND_API.G_EXC_ERROR;
      end if;
----
/* Bug No 1808330 End */

                end;
                end if;

              end;
              end if; -- Parameter exists for account

            End Loop; /* Parameter Account Set */

          end;
          end if; --Non Position Account if revise by position

        End Loop; -- CCid Loop

      End Loop; -- Budget Accounts Loop

    End Loop; -- Gl Periods Loop


    -- Mass Entries for Position Revision
    if g_position_exists then
    begin

      if ((g_position_mass_revision) or (l_local_parameter = 'Y')) then
      begin

   /*start bug:5753424: statement level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
    'PSB/LOCAL_PARAM_SET/PSBVBRVB/Create_Mass_Revision_Entries',
    'Before call to Apply_Element_Parameters for parameter id:'||p_parameter_id);
   fnd_file.put_line(fnd_file.LOG,'Before call to Apply_Element_Parameters for parameter id:'||p_parameter_id);
   end if;
   /*end bug:5753424:end statement level log*/

        Apply_Element_Parameters
           (p_return_status       => l_return_status,
            p_budget_revision_id  => p_budget_revision_id,
            p_local_parameter     => l_local_parameter,
            p_parameter_id        => p_parameter_id,
            p_revision_start_date => g_effective_start_date,
            p_revision_end_date   => g_effective_end_date);

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
          raise FND_API.G_EXC_ERROR;
        end if;

   /*start bug:5753424: statement level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
    'PSB/LOCAL_PARAM_SET/PSBVBRVB/Create_Mass_Revision_Entries',
    'Before call to Apply_Position_Parameters for parameter id:'||p_parameter_id);
    fnd_file.put_line(fnd_file.LOG,'Before call to Apply_Position_Parameters for parameter id:'||p_parameter_id);
   end if;
   /*end bug:5753424:end statement level log*/

        Apply_Position_Parameters
             (p_return_status       => l_return_status,
              p_budget_revision_id  => p_budget_revision_id,
              p_local_parameter     => l_local_parameter,
              p_parameter_id        => p_parameter_id,
              p_revision_start_date => g_effective_start_date,
              p_revision_end_date   => g_effective_end_date);

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
          raise FND_API.G_EXC_ERROR;
        end if;

      if l_local_parameter = 'N' then
      begin

        for c_positions_rec in c_positions loop

          Calculate_Position_Cost
          ( p_api_version         => 1.0
          , p_return_status       => l_return_status
          , p_msg_count           => l_msg_count
          , p_msg_data            => l_msg_data
          , p_mass_revision       => TRUE
          , p_budget_revision_id  => p_budget_revision_id
          , p_position_id         => c_positions_rec.position_id
          , p_revision_start_date => g_effective_start_date
          , p_revision_end_date   => g_effective_end_date
          , p_parameter_id        => p_parameter_id -- Bug#4675858
          );

          if l_return_status <> FND_API.G_RET_STS_SUCCESS then
            raise FND_API.G_EXC_ERROR;
          end if;

        end loop; -- Positions


        for c_period_list_rec in c_period_list loop
          l_gl_period_name := null;
          l_gl_period_name := c_period_list_rec.period_name;

        Create_Summary_Position_Line
              (p_return_status => l_return_status,
               p_budget_revision_id => p_budget_revision_id,
               p_currency_code => g_func_currency,
               p_gl_period_name => l_gl_period_name);

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
          raise FND_API.G_EXC_ERROR;
        end if;
        end loop;

      end;
      else
      begin

        for c_positions_rec in c_localparam_positions loop

          Calculate_Position_Cost
          ( p_api_version         => 1.0
          , p_return_status       => l_return_status
          , p_msg_count           => l_msg_count
          , p_msg_data            => l_msg_data
          , p_mass_revision       => TRUE
          , p_budget_revision_id  => p_budget_revision_id
          , p_position_id         => c_positions_rec.position_id
          , p_revision_start_date => c_positions_rec.effective_start_date
          , p_revision_end_date   => c_positions_rec.effective_end_date
          , p_parameter_id        => p_parameter_id -- Bug#4675858
          ) ;

          if l_return_status <> FND_API.G_RET_STS_SUCCESS then
            raise FND_API.G_EXC_ERROR;
          end if;

          l_gl_period_name := null;

          for c_period_rec in c_period(c_positions_rec.effective_start_date) loop
            l_gl_period_name := c_period_rec.period_name;
          end loop;

          Create_Summary_Position_Line
                (p_return_status => l_return_status,
                 p_budget_revision_id => p_budget_revision_id,
                 p_currency_code => g_func_currency,
                 p_gl_period_name => l_gl_period_name);

          if l_return_status <> FND_API.G_RET_STS_SUCCESS then
            raise FND_API.G_EXC_ERROR;
          end if;

        end loop; -- Positions

      end;
      end if;

    end; -- mass revision position entries
    end if;

    end; -- Position Exists
    end if;

  end; -- regular budget revision
  end if;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                             p_data  => p_msg_data);

   /*start bug:5753424: procedure level logging*/
  if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
    'PSB/LOCAL_PARAM_SET/PSBVBRVB/Create_Mass_Revision_Entries',
    'END Create_Mass_Revision_Entries');
   fnd_file.put_line(fnd_file.LOG,'END Create_Mass_Revision_Entries');
   end if;
   /*end bug:5753424:end procedure level log*/

EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Create_Mass_Revision_Entries;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Create_Mass_Revision_Entries;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

   when OTHERS then
     rollback to Create_Mass_Revision_Entries;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

END Create_Mass_Revision_Entries;

/* ----------------------------------------------------------------------- */

PROCEDURE Insert_Revision_Positions
( p_return_status                   OUT  NOCOPY     VARCHAR2,
  p_budget_revision_pos_line_id     OUT  NOCOPY     NUMBER,
  p_budget_revision_id              IN      NUMBER,
  p_position_id                     IN      NUMBER,
  p_budget_group_id                 IN      NUMBER,
  p_effective_start_date            IN      DATE,
  p_effective_end_date              IN      DATE,
  p_revision_type                   IN      VARCHAR2,
  p_revision_value_type             IN      VARCHAR2,
  p_revision_value                  IN      NUMBER,
  p_note_id                         IN      NUMBER,
  p_freeze_flag                     IN      VARCHAR2,
  p_view_line_flag                  IN      VARCHAR2
) IS

  l_budget_revision_pos_line_id     NUMBER;
  l_global_revision_id              NUMBER;

  cursor c_seq is
    select psb_budget_revision_pos_line_s.nextval seq
      from dual;

BEGIN

  for c_seq_rec in c_seq loop
    l_budget_revision_pos_line_id := c_seq_rec.seq;
  end loop;

  INSERT INTO PSB_BUDGET_REVISION_POSITIONS
        (budget_revision_pos_line_id, position_id, budget_group_id, effective_start_date,
         effective_end_date, revision_type, revision_value_type, revision_value, note_id,
         last_update_date, last_updated_by, last_update_login, created_by, creation_date)
  VALUES (l_budget_revision_pos_line_id, p_position_id, p_budget_group_id, p_effective_start_date,
          p_effective_end_date, p_revision_type, p_revision_value_type, p_revision_value, p_note_id,
          sysdate, FND_GLOBAL.USER_ID, FND_GLOBAL.LOGIN_ID, FND_GLOBAL.USER_ID, sysdate);

  for c_Global_Rev_Rec in c_Global_Rev (p_budget_revision_id) loop
    l_global_revision_id := c_Global_Rev_Rec.global_revision_id;
  end loop;

  -- this is used to propagate new budget revision entries created at any level to all the distributed levels

  for c_Distribute_Rev_Rec in c_Distribute_Rev (l_global_revision_id, p_budget_group_id) loop

    INSERT INTO PSB_BUDGET_REVISION_POS_LINES (budget_revision_pos_line_id, budget_revision_id,
           freeze_flag, view_line_flag, last_update_date, last_updated_by, last_update_login,
           created_by, creation_date)
    VALUES (l_budget_revision_pos_line_id, c_Distribute_Rev_Rec.budget_revision_id,
            p_freeze_flag, p_view_line_flag, sysdate, FND_GLOBAL.USER_ID, FND_GLOBAL.LOGIN_ID,
            FND_GLOBAL.USER_ID, sysdate);

  end loop;

  p_budget_revision_pos_line_id := l_budget_revision_pos_line_id;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

End Insert_Revision_Positions;

/* ----------------------------------------------------------------------- */

PROCEDURE Update_Revision_Positions
( p_return_status                OUT  NOCOPY  VARCHAR2,
  p_budget_revision_pos_line_id  IN   NUMBER,
  p_budget_group_id              IN   NUMBER,
  p_effective_start_date         IN   DATE := FND_API.G_MISS_DATE,
  p_effective_end_date           IN   DATE := FND_API.G_MISS_DATE,
  p_revision_type                IN   VARCHAR2,
  p_revision_value_type          IN   VARCHAR2,
  p_revision_value               IN   NUMBER,
  p_note_id                      IN   NUMBER
) IS

BEGIN

  update PSB_BUDGET_REVISION_POSITIONS
     set budget_group_id = p_budget_group_id,
         effective_start_date = decode(p_effective_start_date, FND_API.G_MISS_DATE, effective_start_date, p_effective_start_date),
         effective_end_date = decode(p_effective_end_date, FND_API.G_MISS_DATE, effective_end_date, p_effective_end_date),
         revision_type = p_revision_type,
         revision_value_type = p_revision_value_type,
         revision_value = p_revision_value,
         note_id = decode(p_note_id, null, note_id, p_note_id),
         last_update_date = sysdate,
         last_updated_by = FND_GLOBAL.USER_ID,
         last_update_login = FND_GLOBAL.LOGIN_ID
   WHERE budget_revision_pos_line_id  = p_budget_revision_pos_line_id;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

End Update_Revision_Positions;

/* ----------------------------------------------------------------------- */

PROCEDURE Delete_Revision_Positions
( p_return_status                OUT  NOCOPY  VARCHAR2,
  p_budget_revision_pos_line_id  IN   NUMBER
) IS

BEGIN

  delete from PSB_BUDGET_REVISION_POSITIONS
   where budget_revision_pos_line_id = p_budget_revision_pos_line_id;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

End Delete_Revision_Positions;

/* ----------------------------------------------------------------------- */

PROCEDURE Create_Revision_Positions
( p_api_version                     IN      NUMBER,
  p_init_msg_list                   IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                          IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level                IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status                   OUT  NOCOPY     VARCHAR2,
  p_msg_count                       OUT  NOCOPY     NUMBER,
  p_msg_data                        OUT  NOCOPY     VARCHAR2,
  p_budget_revision_id              IN      NUMBER,
  p_budget_revision_pos_line_id     IN  OUT  NOCOPY NUMBER,
  p_position_id                     IN      NUMBER,
  p_budget_group_id                 IN      NUMBER,
  p_effective_start_date            IN      DATE,
  p_effective_end_date              IN      DATE,
  p_revision_type                   IN      VARCHAR2,
  p_revision_value_type             IN      VARCHAR2,
  p_revision_value                  IN      NUMBER,
  p_note_id                         IN      NUMBER,
  p_freeze_flag                     IN      VARCHAR2,
  p_view_line_flag                  IN      VARCHAR2
) IS

  l_api_name                        CONSTANT VARCHAR2(30) := 'Create_Revision_Positions';
  l_api_version                     CONSTANT NUMBER       := 1.0;

  l_created_record                  BOOLEAN := FALSE;
  l_updated_record                  BOOLEAN;

  l_budget_revision_pos_line_id     NUMBER;
  l_return_status                   VARCHAR2(1);

  cursor c_Overlap is
    select pbrp.*
      from psb_budget_revision_positions pbrp,
           psb_budget_revision_pos_lines pbrl
     where pbrp.position_id = p_position_id
       and ((((p_effective_end_date is not null)
         and ((pbrp.effective_start_date <= p_effective_end_date)
          and (pbrp.effective_end_date is null))
          or ((pbrp.effective_start_date between p_effective_start_date and p_effective_end_date)
           or (pbrp.effective_end_date between p_effective_start_date and p_effective_end_date)
          or ((pbrp.effective_start_date < p_effective_start_date)
          and (pbrp.effective_end_date > p_effective_end_date)))))
          or ((p_effective_end_date is null)
          and (nvl(pbrp.effective_end_date, p_effective_start_date) >= p_effective_start_date)))
       and pbrl.budget_revision_id = p_budget_revision_id
       and pbrp.budget_revision_pos_line_id = pbrl.budget_revision_pos_line_id;

BEGIN

  SAVEPOINT Create_Revision_Positions;

  -- Standard call to check for call compatibility.

  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  IF FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  update PSB_BUDGET_REVISION_POSITIONS brp
     set budget_group_id = p_budget_group_id,
         revision_type = p_revision_type,
         revision_value_type = p_revision_value_type,
         revision_value = p_revision_value,
         last_update_date = sysdate,
         last_updated_by = FND_GLOBAL.USER_ID,
         last_update_login = FND_GLOBAL.LOGIN_ID
   where position_id = p_position_id
     and effective_start_date = p_effective_start_date
     and nvl(effective_end_date, FND_API.G_MISS_DATE) = nvl(p_effective_end_date, FND_API.G_MISS_DATE)
     and exists
        (select 1
           from PSB_BUDGET_REVISION_POS_LINES brpl
          where brpl.budget_revision_id = p_budget_revision_id
            and brpl.budget_revision_pos_line_id = brp.budget_revision_pos_line_id);

  if SQL%NOTFOUND then
  begin

    for l_init_index in 1..g_revpos.Count loop
      g_revpos(l_init_index).budget_revision_pos_line_id := null;
      g_revpos(l_init_index).position_id := null;
      g_revpos(l_init_index).budget_group_id := null;
      g_revpos(l_init_index).effective_start_date := null;
      g_revpos(l_init_index).effective_end_date := null;
      g_revpos(l_init_index).revision_type := null;
      g_revpos(l_init_index).revision_value_type := null;
      g_revpos(l_init_index).revision_value := null;
      g_revpos(l_init_index).note_id := null;
      g_revpos(l_init_index).delete_flag := null;
    end loop;

    g_num_revpos := 0;

    for c_Overlap_Rec in c_Overlap loop
      g_num_revpos := g_num_revpos + 1;

      g_revpos(g_num_revpos).budget_revision_pos_line_id := c_Overlap_Rec.budget_revision_pos_line_id;
      g_revpos(g_num_revpos).position_id := c_Overlap_Rec.position_id;
      g_revpos(g_num_revpos).budget_group_id := c_Overlap_Rec.budget_group_id;
      g_revpos(g_num_revpos).effective_start_date := c_Overlap_Rec.effective_start_date;
      g_revpos(g_num_revpos).effective_end_date := c_Overlap_Rec.effective_end_date;
      g_revpos(g_num_revpos).revision_type := c_Overlap_Rec.revision_type;
      g_revpos(g_num_revpos).revision_value_type := c_Overlap_Rec.revision_value_type;
      g_revpos(g_num_revpos).revision_value := c_Overlap_Rec.revision_value;
      g_revpos(g_num_revpos).note_id := c_Overlap_Rec.note_id;
      g_revpos(g_num_revpos).delete_flag := TRUE;
    end loop;

    if g_num_revpos = 0 then
    begin

      Insert_Revision_Positions
           (p_return_status => l_return_status,
            p_budget_revision_pos_line_id => l_budget_revision_pos_line_id,
            p_budget_revision_id => p_budget_revision_id,
            p_position_id => p_position_id,
            p_budget_group_id => p_budget_group_id,
            p_effective_start_date => p_effective_start_date,
            p_effective_end_date => p_effective_end_date,
            p_revision_type => p_revision_type,
            p_revision_value_type => p_revision_value_type,
            p_revision_value => p_revision_value,
            p_note_id => p_note_id,
            p_freeze_flag => p_freeze_flag,
            p_view_line_flag => p_view_line_flag);

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
          raise FND_API.G_EXC_ERROR;
        end if;

        p_budget_revision_pos_line_id := l_budget_revision_pos_line_id;

    end;
    else
    begin

      for l_revpos_index in 1..g_num_revpos loop

        l_updated_record := FALSE;

        /* Effective Start Date Matches */

        if g_revpos(l_revpos_index).effective_start_date = p_effective_start_date then
        begin

          Update_Revision_Positions
                (p_return_status => l_return_status,
                 p_budget_revision_pos_line_id => g_revpos(l_revpos_index).budget_revision_pos_line_id,
                 p_budget_group_id => p_budget_group_id,
                 p_effective_end_date => p_effective_end_date,
                 p_revision_type => g_revpos(l_revpos_index).revision_type,
                 p_revision_value_type => g_revpos(l_revpos_index).revision_value_type,
                 p_revision_value => g_revpos(l_revpos_index).revision_value,
                 p_note_id => g_revpos(l_revpos_index).note_id);

          if l_return_status <> FND_API.G_RET_STS_SUCCESS then
            raise FND_API.G_EXC_ERROR;
          end if;

          g_revpos(l_revpos_index).delete_flag := FALSE;

        end;

        /* Effective Dates Overlap */
        elsif (((g_revpos(l_revpos_index).effective_start_date <= (p_effective_start_date - 1)) and
               ((g_revpos(l_revpos_index).effective_end_date is null) or
                (g_revpos(l_revpos_index).effective_end_date > (p_effective_start_date - 1)))) or
               ((g_revpos(l_revpos_index).effective_start_date > p_effective_start_date) and
               ((g_revpos(l_revpos_index).effective_end_date is null) or
                (g_revpos(l_revpos_index).effective_end_date > (p_effective_end_date + 1))))) then
        begin

          if ((g_revpos(l_revpos_index).effective_start_date < (p_effective_start_date - 1)) and
             ((g_revpos(l_revpos_index).effective_end_date is null) or
              (g_revpos(l_revpos_index).effective_end_date > (p_effective_start_date - 1)))) then
          begin

            Update_Revision_Positions
                  (p_return_status => l_return_status,
                   p_budget_revision_pos_line_id => g_revpos(l_revpos_index).budget_revision_pos_line_id,
                   p_budget_group_id => p_budget_group_id,
                   p_effective_end_date => p_effective_start_date - 1,
                   p_revision_type => g_revpos(l_revpos_index).revision_type,
                   p_revision_value_type => g_revpos(l_revpos_index).revision_value_type,
                   p_revision_value => g_revpos(l_revpos_index).revision_value,
                   p_note_id => g_revpos(l_revpos_index).note_id);

            if l_return_status <> FND_API.G_RET_STS_SUCCESS then
              raise FND_API.G_EXC_ERROR;
            else
              l_updated_record := TRUE;
            end if;

            g_revpos(l_revpos_index).delete_flag := FALSE;

          end;
          elsif ((g_revpos(l_revpos_index).effective_start_date > p_effective_start_date) and
                ((p_effective_end_date is not null) and
                ((g_revpos(l_revpos_index).effective_end_date is null) or
                 (g_revpos(l_revpos_index).effective_end_date > (p_effective_end_date + 1))))) then
          begin

            Update_Revision_Positions
                  (p_return_status => l_return_status,
                   p_budget_revision_pos_line_id => g_revpos(l_revpos_index).budget_revision_pos_line_id,
                   p_budget_group_id => p_budget_group_id,
                   p_effective_start_date => p_effective_end_date + 1,
                   p_revision_type => g_revpos(l_revpos_index).revision_type,
                   p_revision_value_type => g_revpos(l_revpos_index).revision_value_type,
                   p_revision_value => g_revpos(l_revpos_index).revision_value,
                   p_note_id => g_revpos(l_revpos_index).note_id);

            if l_return_status <> FND_API.G_RET_STS_SUCCESS then
              raise FND_API.G_EXC_ERROR;
            else
              l_updated_record := FALSE;
            end if;

            g_revpos(l_revpos_index).delete_flag := FALSE;

          end;
          end if;

          if not l_created_record then
          begin

            Insert_Revision_Positions
                 (p_return_status => l_return_status,
                  p_budget_revision_pos_line_id => l_budget_revision_pos_line_id,
                  p_budget_revision_id => p_budget_revision_id,
                  p_position_id => p_position_id,
                  p_budget_group_id => p_budget_group_id,
                  p_effective_start_date => p_effective_start_date,
                  p_effective_end_date => p_effective_end_date,
                  p_revision_type => p_revision_type,
                  p_revision_value_type => p_revision_value_type,
                  p_revision_value => p_revision_value,
                  p_note_id => p_note_id,
                  p_freeze_flag => p_freeze_flag,
                  p_view_line_flag => p_view_line_flag);

            if l_return_status <> FND_API.G_RET_STS_SUCCESS then
              raise FND_API.G_EXC_ERROR;
            else
              l_created_record := TRUE;
            end if;

            p_budget_revision_pos_line_id := l_budget_revision_pos_line_id;

          end;
          end if;

          if p_effective_end_date is not null then
          begin

            if nvl(g_revpos(l_revpos_index).effective_end_date, (p_effective_end_date + 1)) > (p_effective_end_date + 1) then
            begin

              if l_updated_record then
              begin

                Insert_Revision_Positions
                     (p_return_status => l_return_status,
                      p_budget_revision_pos_line_id => l_budget_revision_pos_line_id,
                      p_budget_revision_id => p_budget_revision_id,
                      p_position_id => p_position_id,
                      p_budget_group_id => p_budget_group_id,
                      p_effective_start_date => p_effective_end_date + 1,
                      p_effective_end_date => g_revpos(l_revpos_index).effective_end_date,
                      p_revision_type => p_revision_type,
                      p_revision_value_type => p_revision_value_type,
                      p_revision_value => p_revision_value,
                      p_note_id => p_note_id,
                      p_freeze_flag => p_freeze_flag,
                      p_view_line_flag => p_view_line_flag);

                if l_return_status <> FND_API.G_RET_STS_SUCCESS then
                  raise FND_API.G_EXC_ERROR;
                end if;

              end;
              else
              begin

                Update_Revision_Positions
                      (p_return_status => l_return_status,
                       p_budget_revision_pos_line_id => g_revpos(l_revpos_index).budget_revision_pos_line_id,
                       p_budget_group_id => p_budget_group_id,
                       p_effective_start_date => p_effective_end_date + 1,
                       p_effective_end_date => g_revpos(l_revpos_index).effective_end_date,
                       p_revision_type => g_revpos(l_revpos_index).revision_type,
                       p_revision_value_type => g_revpos(l_revpos_index).revision_value_type,
                       p_revision_value => g_revpos(l_revpos_index).revision_value,
                       p_note_id => g_revpos(l_revpos_index).note_id);

                if l_return_status <> FND_API.G_RET_STS_SUCCESS then
                  raise FND_API.G_EXC_ERROR;
                end if;

                g_revpos(l_revpos_index).delete_flag := FALSE;

              end;
              end if;

            end;
            end if;

          end;
          end if;

        end;
        end if;

      end loop;

    end;
    end if;

    for l_revpos_index in 1..g_num_revpos loop

      if g_revpos(l_revpos_index).delete_flag then
      begin

        Delete_Revision_Positions
              (p_return_status => l_return_status,
               p_budget_revision_pos_line_id => g_revpos(l_revpos_index).budget_revision_pos_line_id);

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
          raise FND_API.G_EXC_ERROR;
        end if;

      end;
      end if;

    end loop;

  end;
  end if;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                             p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Create_Revision_Positions;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Create_Revision_Positions;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

   when OTHERS then
     rollback to Create_Revision_Positions;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

End Create_Revision_Positions;


/* ----------------------------------------------------------------------- */

PROCEDURE Initialize_Revisions IS
BEGIN

  -- Initialize the entire structure

  for l_init_index in 1..g_costs.Count loop
    g_costs(l_init_index).pay_element_id := null;
    g_costs(l_init_index).element_type := null;
    g_costs(l_init_index).element_cost := null;
    g_costs(l_init_index).currency_code := null;
    g_costs(l_init_index).start_date := null;
    g_costs(l_init_index).end_date := null;
  end loop;

  g_num_costs := 0;

  for l_init_index in 1..g_dists.Count loop
     g_dists(l_init_index).ccid := null;
     g_dists(l_init_index).budget_group_id := null;
     g_dists(l_init_index).currency_code := null;
     g_dists(l_init_index).start_date := null;
     g_dists(l_init_index).end_date := null;
     g_dists(l_init_index).amount := null;
     g_dists(l_init_index).calc_rev := null;
  end loop;

  g_num_dists := 0;

  for l_init_index in 1..g_revaccts.count loop
    g_revaccts(l_init_index).ccid := null;
    g_revaccts(l_init_index).amount := null;
  end loop;

  g_num_revaccts := 0;

  for l_init_index in 1..g_elem_assignments.Count loop
    g_elem_assignments(l_init_index).budget_revision_id := null;
    g_elem_assignments(l_init_index).start_date := null;
    g_elem_assignments(l_init_index).end_date := null;
    g_elem_assignments(l_init_index).pay_element_id := null;
    g_elem_assignments(l_init_index).pay_element_option_id := null;
    g_elem_assignments(l_init_index).pay_basis := null;
    g_elem_assignments(l_init_index).element_value_type := null;
    g_elem_assignments(l_init_index).element_value := null;
    g_elem_assignments(l_init_index).use_in_calc := null;
  end loop;

  g_num_elem_assignments := 0;

  for l_init_index in 1..g_elem_rates.Count loop
    g_elem_rates(l_init_index).budget_revision_id := null;
    g_elem_rates(l_init_index).start_date := null;
    g_elem_rates(l_init_index).end_date := null;
    g_elem_rates(l_init_index).pay_element_id := null;
    g_elem_rates(l_init_index).pay_element_option_id := null;
    g_elem_rates(l_init_index).pay_basis := null;
    g_elem_rates(l_init_index).element_value_type := null;
    g_elem_rates(l_init_index).element_value := null;
    g_elem_rates(l_init_index).formula_id := null;
  end loop;

  g_num_elem_rates := 0;

  for l_init_index in 1..g_wkh_assignments.Count loop
    g_wkh_assignments(l_init_index).start_date := null;
    g_wkh_assignments(l_init_index).end_date := null;
    g_wkh_assignments(l_init_index).default_weekly_hours := null;
  end loop;

  g_num_wkh_assignments := 0;

  for l_init_index in 1..g_fte_assignments.Count loop
    g_fte_assignments(l_init_index).start_date := null;
    g_fte_assignments(l_init_index).end_date := null;
    g_fte_assignments(l_init_index).fte := null;
  end loop;

  g_num_fte_assignments := 0;

  PSB_WS_POS1.g_salary_budget_group_id := null;
  PSB_WS_POS1.Initialize_Salary_Dist;

  for l_init_index in 1..PSB_WS_POS1.g_elements.Count loop
    PSB_WS_POS1.g_elements(l_init_index).pay_element_id := null;
    PSB_WS_POS1.g_elements(l_init_index).element_name := null;
    PSB_WS_POS1.g_elements(l_init_index).processing_type := null;
    PSB_WS_POS1.g_elements(l_init_index).max_element_value_type := null;
    PSB_WS_POS1.g_elements(l_init_index).max_element_value := null;
    PSB_WS_POS1.g_elements(l_init_index).salary_flag := null;
    PSB_WS_POS1.g_elements(l_init_index).option_flag := null;
    PSB_WS_POS1.g_elements(l_init_index).overwrite_flag := null;
    PSB_WS_POS1.g_elements(l_init_index).salary_type := null;
    PSB_WS_POS1.g_elements(l_init_index).follow_salary := null;
    PSB_WS_POS1.g_elements(l_init_index).period_type := null;
    PSB_WS_POS1.g_elements(l_init_index).process_period_type := null;
  end loop;

  PSB_WS_POS1.g_num_elements := 0;

End Initialize_Revisions;

/* ----------------------------------------------------------------------- */

PROCEDURE Cache_Elements
(p_return_status      OUT  NOCOPY VARCHAR2,
 p_start_date         IN  DATE,
 p_end_date           IN  DATE) IS

  cursor c_Elements is
    select pay_element_id,
           name,
           processing_type,
           max_element_value_type,
           max_element_value,
           option_flag,
           overwrite_flag,
           salary_flag,
           salary_type,
           follow_salary,
           period_type,
           process_period_type
      from PSB_PAY_ELEMENTS
     where data_extract_id = g_data_extract_id
       and business_group_id = g_business_group_id
       and ((start_date >= p_start_date) and ((start_date <= p_end_date)
         or (end_date is null))
         or ((start_date between p_start_date and p_end_date))
         or (p_start_date between  start_date and nvl(end_date,p_end_date)))
     order by salary_flag desc,
              pay_element_id;
BEGIN

  for c_Elements_Rec in c_Elements loop

    PSB_WS_POS1.g_num_elements := PSB_WS_POS1.g_num_elements + 1;

    PSB_WS_POS1.g_elements(PSB_WS_POS1.g_num_elements).pay_element_id := c_Elements_Rec.pay_element_id;
    PSB_WS_POS1.g_elements(PSB_WS_POS1.g_num_elements).element_name := c_Elements_Rec.name;
    PSB_WS_POS1.g_elements(PSB_WS_POS1.g_num_elements).processing_type := c_Elements_Rec.processing_type;
    PSB_WS_POS1.g_elements(PSB_WS_POS1.g_num_elements).max_element_value_type := c_Elements_Rec.max_element_value_type;
    PSB_WS_POS1.g_elements(PSB_WS_POS1.g_num_elements).max_element_value := c_Elements_Rec.max_element_value;
    PSB_WS_POS1.g_elements(PSB_WS_POS1.g_num_elements).option_flag := c_Elements_Rec.option_flag;
    PSB_WS_POS1.g_elements(PSB_WS_POS1.g_num_elements).overwrite_flag := c_Elements_Rec.overwrite_flag;
    PSB_WS_POS1.g_elements(PSB_WS_POS1.g_num_elements).salary_flag := c_Elements_Rec.salary_flag;
    PSB_WS_POS1.g_elements(PSB_WS_POS1.g_num_elements).salary_type := c_Elements_Rec.salary_type;
    PSB_WS_POS1.g_elements(PSB_WS_POS1.g_num_elements).follow_salary := c_Elements_Rec.follow_salary;
    PSB_WS_POS1.g_elements(PSB_WS_POS1.g_num_elements).period_type := c_Elements_Rec.period_type;
    PSB_WS_POS1.g_elements(PSB_WS_POS1.g_num_elements).process_period_type := c_Elements_Rec.process_period_type;
  end loop;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

End Cache_Elements;

/* ----------------------------------------------------------------------- */

-- Cache Salary Distribution for a Position for specific date range

PROCEDURE Cache_Salary_Dist
( p_return_status         OUT  NOCOPY  VARCHAR2,
  p_budget_revision_id    IN   NUMBER,
  p_position_id           IN   NUMBER,
  p_position_name         IN   VARCHAR2,
  p_start_date            IN   DATE,
  p_end_date              IN   DATE
) IS

  l_saldist_found         BOOLEAN := FALSE;
  l_budget_group_found    BOOLEAN := FALSE;

  l_concat_segments       VARCHAR2(2000);

  l_return_status         VARCHAR2(1);

  cursor c_WSDist is
    select code_combination_id,
           distribution_percent,
           effective_start_date,
           effective_end_date
      from PSB_POSITION_PAY_DISTRIBUTIONS
     where position_id = p_position_id
       and worksheet_id = p_budget_revision_id
       and code_combination_id is not null
       and chart_of_accounts_id = g_flex_code
       and (((p_end_date is not null)
         and (((effective_start_date <= p_end_date)
           and (effective_end_date is null))
           or ((effective_start_date between p_start_date and p_end_date)
           or (effective_end_date between p_start_date and p_end_date)
           or ((effective_start_date < p_start_date)
           and (effective_end_date > p_end_date)))))
        or ((p_end_date is null)
        and (nvl(effective_end_date, p_start_date) >= p_start_date)))
     order by distribution_percent desc;

  cursor c_Dist is
    select code_combination_id,
           distribution_percent,
           effective_start_date,
           effective_end_date
      from PSB_POSITION_PAY_DISTRIBUTIONS
     where position_id = p_position_id
       and worksheet_id is null
       and code_combination_id is not null
       and chart_of_accounts_id = g_flex_code
       and (((p_end_date is not null)
         and (((effective_start_date <= p_end_date)
           and (effective_end_date is null))
           or ((effective_start_date between p_start_date and p_end_date)
           or (effective_end_date between p_start_date and p_end_date)
           or ((effective_start_date < p_start_date)
           and (effective_end_date > p_end_date)))))
        or ((p_end_date is null)
        and (nvl(effective_end_date, p_start_date) >= p_start_date)))
     order by distribution_percent desc;

  cursor c_Budget_Group (CCID NUMBER) is
    select a.budget_group_id,
           b.num_proposed_years
      from PSB_SET_RELATIONS a,
           PSB_BUDGET_GROUPS b,
           PSB_BUDGET_ACCOUNTS c
     where a.budget_group_id = b.budget_group_id
       and b.effective_start_date <= p_start_date
       and (b.effective_end_date is null
         or b.effective_end_date >= p_end_date)
       and b.budget_group_type = 'R'
       and ((b.budget_group_id = g_root_budget_group_id) or
            (b.root_budget_group_id = g_root_budget_group_id))
       and a.account_position_set_id = c.account_position_set_id
       and c.code_combination_id = CCID;

BEGIN

  for c_Dist_Rec in c_WSDist loop

    l_saldist_found := TRUE;
    g_revised_position := TRUE;

    if nvl(PSB_WS_POS1.g_salary_budget_group_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM then
    begin

      for c_Budget_Group_Rec in c_Budget_Group (c_Dist_Rec.code_combination_id) loop
        PSB_WS_POS1.g_salary_budget_group_id := c_Budget_Group_Rec.budget_group_id;
        l_budget_group_found := TRUE;
      end loop;

      -- Budget Group for a Position is the Budget Group assigned to the CCID with
      -- the maximum distribution percentage

      if not l_budget_group_found then
      begin

        l_concat_segments := FND_FLEX_EXT.Get_Segs
                                (application_short_name => 'SQLGL',
                                 key_flex_code => 'GL#',
                                 structure_number => g_flex_code,
                                 combination_id => c_Dist_Rec.code_combination_id);

        message_token('CCID', l_concat_segments);
        message_token('POSITION', p_position_name);
        add_message('PSB', 'PSB_CANNOT_ASSIGN_BUDGET_GROUP');
        raise FND_API.G_EXC_ERROR;

      end;
      end if;

    end;
    end if;

    PSB_WS_POS1.g_num_salary_dist := PSB_WS_POS1.g_num_salary_dist + 1;

    PSB_WS_POS1.g_salary_dist(PSB_WS_POS1.g_num_salary_dist).ccid := c_Dist_Rec.code_combination_id;
    PSB_WS_POS1.g_salary_dist(PSB_WS_POS1.g_num_salary_dist).percent := c_Dist_Rec.distribution_percent;
    PSB_WS_POS1.g_salary_dist(PSB_WS_POS1.g_num_salary_dist).start_date := c_Dist_Rec.effective_start_date;
    PSB_WS_POS1.g_salary_dist(PSB_WS_POS1.g_num_salary_dist).end_date := c_Dist_Rec.effective_end_date;

  end loop;

  if not l_saldist_found then
  begin

    for c_Dist_Rec in c_Dist loop

      l_saldist_found := TRUE;

      if nvl(PSB_WS_POS1.g_salary_budget_group_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM then
      begin

        for c_Budget_Group_Rec in c_Budget_Group (c_Dist_Rec.code_combination_id) loop
          PSB_WS_POS1.g_salary_budget_group_id := c_Budget_Group_Rec.budget_group_id;
          l_budget_group_found := TRUE;
        end loop;

        -- Budget Group for a Position is the Budget Group assigned to the CCID with
        -- the maximum distribution percentage

        if not l_budget_group_found then
        begin

          l_concat_segments := FND_FLEX_EXT.Get_Segs
                                  (application_short_name => 'SQLGL',
                                   key_flex_code => 'GL#',
                                   structure_number => g_flex_code,
                                   combination_id => c_Dist_Rec.code_combination_id);

          message_token('CCID', l_concat_segments);
          message_token('POSITION', p_position_name);
          add_message('PSB', 'PSB_CANNOT_ASSIGN_BUDGET_GROUP');
          raise FND_API.G_EXC_ERROR;

        end;
        end if;

      end;
      end if;

      PSB_WS_POS1.g_num_salary_dist := PSB_WS_POS1.g_num_salary_dist + 1;

      PSB_WS_POS1.g_salary_dist(PSB_WS_POS1.g_num_salary_dist).ccid := c_Dist_Rec.code_combination_id;
      PSB_WS_POS1.g_salary_dist(PSB_WS_POS1.g_num_salary_dist).percent := c_Dist_Rec.distribution_percent;
      PSB_WS_POS1.g_salary_dist(PSB_WS_POS1.g_num_salary_dist).start_date := c_Dist_Rec.effective_start_date;
      PSB_WS_POS1.g_salary_dist(PSB_WS_POS1.g_num_salary_dist).end_date := c_Dist_Rec.effective_end_date;

    end loop;

  end;
  end if;

  -- If Salary Distribution is not found return an error. Salary Distribution is
  -- needed to create a Worksheet specific instance of a Position (identified by
  -- position_line_id)

  if not l_saldist_found then
    message_token('POSITION', p_position_name);
    message_token('START_DATE', p_start_date);
    message_token('END_DATE', p_end_date);
    add_message('PSB', 'PSB_NO_SALARY_DISTRIBUTION');
    raise FND_API.G_EXC_ERROR;
  end if;

  if g_flex_code <> nvl(PSB_WS_ACCT1.g_flex_code, FND_API.G_MISS_NUM) then
  begin

    PSB_WS_ACCT1.Flex_Info
       (p_flex_code => g_flex_code,
        p_return_status => l_return_status);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end;
  end if;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Cache_Salary_Dist;

/*==========================================================================+
 |                       PROCEDURE Update_Baseline_Values                   |
 +==========================================================================*/

PROCEDURE Update_Baseline_Values
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_budget_revision_id  IN      NUMBER
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Update_Baseline_Values';
  l_api_version         CONSTANT NUMBER         := 1.0;

  l_return_status       VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);

  l_assignment_id       NUMBER;
  l_position_id         NUMBER;
  l_distribution_id     NUMBER;
  l_rowid               VARCHAR2(100);

  cursor c_fte is
    select position_fte_line_id, position_id, start_date,
           end_date, fte
      from psb_position_fte
     where budget_revision_id = p_budget_revision_id;

  cursor c_costs is
    select position_element_line_id, position_id, pay_element_id,
           element_cost, start_date, end_date, currency_code
      from PSB_POSITION_COSTS
     where budget_revision_id = p_budget_revision_id;

  cursor c_distributions is
    select position_account_line_id, position_id, code_combination_id,
           budget_group_id, amount, start_date, end_date, currency_code
      from PSB_POSITION_ACCOUNTS
     where budget_revision_id = p_budget_revision_id;

  cursor c_assignments is
    select *
      from PSB_POSITION_ASSIGNMENTS
     where worksheet_id = p_budget_revision_id
       and assignment_type = 'ELEMENT';

  cursor c_accdistr is
    select *
      from PSB_POSITION_PAY_DISTRIBUTIONS
     where worksheet_id = p_budget_revision_id;

   cursor c_Positions is
     select *
       from PSB_POSITIONS
      where position_id = l_position_id;

  cursor c_pay_element_rates is
    select *
      from PSB_PAY_ELEMENT_RATES
     where worksheet_id = p_budget_revision_id;

BEGIN

  -- Standard Start of API savepoint

/* Bug No 2532617 Start */
-- Removed the savepoint since intermediate commits have been introduced in called procedures
--  SAVEPOINT     Update_Baseline_Values;
/* Bug No 2532617 End */

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  Cache_Revision_Variables(p_budget_revision_id => p_budget_revision_id,
                           p_return_status => l_return_status);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  for c_fte_rec in c_fte loop

    PSB_POSITION_CONTROL_PVT.Modify_Position_FTE
       (p_api_version => 1.0,
        p_return_status => l_return_status,
        p_msg_count => l_msg_count,
        p_msg_data => l_msg_data,
        p_position_id => c_fte_rec.position_id,
        p_hr_budget_id => g_hr_budget_id,
        p_budget_revision_id => null,
        p_fte => c_fte_rec.fte,
        p_start_date => c_fte_rec.start_date,
        p_end_date => c_fte_rec.end_date,
        p_base_line_version => 'C');

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end loop;

  for c_costs_rec in c_costs loop

    PSB_POSITION_CONTROL_PVT.Modify_Position_Costs
      (p_api_version => 1.0,
       p_return_status => l_return_status,
       p_msg_count => l_msg_count,
       p_msg_data => l_msg_data,
       p_position_id => c_costs_rec.position_id,
       p_hr_budget_id => g_hr_budget_id,
       p_pay_element_id => c_costs_rec.pay_element_id,
       p_budget_revision_id => null,
       p_base_line_version => 'C',
       p_start_date => c_costs_rec.start_date,
       p_end_date => c_costs_rec.end_date,
       p_currency_code => c_costs_rec.currency_code,
       p_element_cost => c_costs_rec.element_cost);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end loop;

  for c_distributions_rec in c_distributions loop

    PSB_POSITION_CONTROL_PVT.Modify_Position_Accounts
       (p_api_version => 1.0,
        p_return_status => l_return_status,
        p_msg_count => l_msg_count,
        p_msg_data => l_msg_data,
        p_position_id => c_distributions_rec.position_id,
        p_hr_budget_id => g_hr_budget_id,
        p_budget_revision_id => null,
        p_budget_group_id => c_distributions_rec.budget_group_id,
        p_base_line_version => 'C',
        p_start_date => c_distributions_rec.start_date,
        p_end_date => c_distributions_Rec.end_date,
        p_code_combination_id => c_distributions_rec.code_combination_id,
        p_currency_code => c_distributions_rec.currency_code,
        p_amount => c_distributions_rec.amount);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end loop;

  for c_assignments_rec in c_assignments loop

    PSB_POSITIONS_PVT.Modify_Assignment
       (p_api_version => 1.0,
        p_return_status => l_return_status,
        p_msg_count => l_msg_count,
        p_msg_data => l_msg_data,
        p_position_assignment_id => l_assignment_id,
        p_data_extract_id => g_data_extract_id,
        p_worksheet_id => null,
        p_position_id => c_assignments_rec.position_id,
        p_assignment_type => c_assignments_rec.assignment_type,
        p_attribute_id => c_assignments_rec.attribute_id,
        p_attribute_value_id => c_assignments_rec.attribute_value_id,
        p_attribute_value => c_assignments_rec.attribute_value,
        p_pay_element_id => c_assignments_rec.pay_element_id,
        p_pay_element_option_id => c_assignments_rec.pay_element_option_id,
        p_effective_start_date => c_assignments_rec.effective_start_date,
        p_effective_end_date => c_assignments_rec.effective_end_date,
        p_element_value_type => c_assignments_rec.element_value_type,
        p_element_value => c_assignments_rec.element_value,
        p_currency_code => c_assignments_rec.currency_code,
        p_pay_basis => c_assignments_rec.pay_basis,
        p_employee_id => c_assignments_rec.employee_id,
        p_primary_employee_flag => c_assignments_rec.primary_employee_flag,
        p_global_default_flag => c_assignments_rec.global_default_flag,
        p_assignment_default_rule_id => c_assignments_rec.assignment_default_rule_id,
        p_modify_flag => c_assignments_rec.modify_flag,
        p_rowid => l_rowid);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end loop;

  for c_accdistr_rec in c_accdistr loop

    l_position_id := c_accdistr_rec.position_id;

    PSB_WS_POS1.Initialize_Salary_Dist;

    for c_Positions_Rec in c_Positions loop

    Cache_Salary_Dist
       (p_return_status => l_return_status,
        p_budget_revision_id => p_budget_revision_id,
        p_position_id => c_accdistr_rec.position_id,
        p_position_name => C_Positions_Rec.name,
        p_start_date => c_accdistr_rec.effective_start_date,
        p_end_date => c_accdistr_rec.effective_end_date);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
        raise FND_API.G_EXC_ERROR;
    end if;

    PSB_POSITIONS_PVT.UPDATE_ROW
    (
            p_api_version            => 1.0,
            p_init_msg_list          => FND_API.G_FALSE,
            p_commit                 => FND_API.G_FALSE,
            p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
            p_return_status          => l_return_status,
            p_msg_count              => l_msg_count,
            p_msg_data               => l_msg_data,
            p_position_id            => l_position_id,
            p_data_extract_id        => c_positions_rec.data_extract_id,
            p_position_definition_id => c_positions_rec.position_definition_id,
            p_hr_position_id         => c_positions_rec.hr_position_id,
            p_hr_employee_id         => c_positions_rec.hr_employee_id,
            p_business_group_id      => c_positions_rec.business_group_id,
            p_budget_group_id        => PSB_WS_POS1.g_salary_budget_group_id,
            p_effective_start_DATE   => c_positions_rec.effective_start_date,
            p_effective_END_DATE     => c_positions_rec.effective_end_date,
            p_set_of_books_id        => c_positions_rec.set_of_books_id,
            p_vacant_position_flag   => c_positions_rec.vacant_position_flag,
        /*For Bug No : 1527423 Start*/
            p_availability_status    => c_positions_rec.availability_status,
        /*For Bug No : 1527423 End*/
            p_attribute1             => c_positions_rec.attribute1,
            p_attribute2             => c_positions_rec.attribute2,
            p_attribute3             => c_positions_rec.attribute3,
            p_attribute4             => c_positions_rec.attribute4,
            p_attribute5             => c_positions_rec.attribute5,
            p_attribute6             => c_positions_rec.attribute6,
            p_attribute7             => c_positions_rec.attribute7,
            p_attribute8             => c_positions_rec.attribute8,
            p_attribute9             => c_positions_rec.attribute9,
            p_attribute10            => c_positions_rec.attribute10,
            p_attribute11            => c_positions_rec.attribute11,
            p_attribute12            => c_positions_rec.attribute12,
            p_attribute13            => c_positions_rec.attribute13,
            p_attribute14            => c_positions_rec.attribute14,
            p_attribute15            => c_positions_rec.attribute15,
            p_attribute16            => c_positions_rec.attribute16,
            p_attribute17            => c_positions_rec.attribute17,
            p_attribute18            => c_positions_rec.attribute18,
            p_attribute19            => c_positions_rec.attribute19,
            p_attribute20            => c_positions_rec.attribute20,
            p_attribute_category     => c_positions_rec.attribute_category,
            p_name                   => c_positions_rec.name,
            p_mode                   => 'R'
          );

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;
    end loop;

    PSB_POSITION_PAY_DISTR_PVT.Modify_Distribution
       (p_api_version => 1.0,
        p_return_status => l_return_status,
        p_msg_count => l_msg_count,
        p_msg_data => l_msg_data,
        p_distribution_id => l_distribution_id,
        p_position_id => c_accdistr_rec.position_id,
        p_data_extract_id => g_data_extract_id,
        p_worksheet_id => null,
        p_effective_start_date => c_accdistr_rec.effective_start_date,
        p_effective_end_date => c_accdistr_rec.effective_end_date,
        p_chart_of_accounts_id => c_accdistr_rec.chart_of_accounts_id,
        p_code_combination_id => c_accdistr_rec.code_combination_id,
        p_distribution_percent => c_accdistr_rec.distribution_percent,
        p_global_default_flag => c_accdistr_rec.global_default_flag,
        p_distribution_default_rule_id => c_accdistr_rec.distribution_default_rule_id,
        p_rowid => l_rowid,
        p_project_id => c_accdistr_rec.project_id,
        p_task_id => c_accdistr_rec.task_id,
        p_award_id => c_accdistr_rec.award_id,
        p_expenditure_type => c_accdistr_rec.expenditure_type,
        p_expenditure_organization_id => c_accdistr_rec.expenditure_organization_id,
        p_description => c_accdistr_rec.description);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end loop;

  for c_rates_rec in c_pay_element_rates
  loop
     PSB_PAY_ELEMENT_RATES_PVT.Modify_Element_Rates
             (p_api_version => 1.0,
              p_return_status => l_return_status,
              p_msg_count => l_msg_count,
              p_msg_data => l_msg_data,
              p_pay_element_id => c_rates_rec.pay_element_id,
              p_pay_element_option_id => c_rates_rec.pay_element_option_id,
              p_effective_start_date => c_rates_rec.effective_start_date,
              p_effective_end_date => c_rates_rec.effective_end_date,
              p_worksheet_id => null,
              p_element_value_type => c_rates_rec.element_value_type,
              p_element_value => c_rates_rec.element_value,
              p_formula_id => c_rates_rec.formula_id,
              p_pay_basis => c_rates_rec.pay_basis,
              p_maximum_value => c_rates_rec.maximum_value,
              p_mid_value => c_rates_rec.mid_value,
              p_minimum_value => c_rates_rec.minimum_value,
              p_currency_code => c_rates_rec.currency_code);

          if l_return_status <> FND_API.G_RET_STS_SUCCESS then
            raise FND_API.G_EXC_ERROR;
          end if;

  end loop;

  --++ upload to HRMS budget

  if g_hr_budget_id is not null then
     psb_position_control_pvt.Upload_Budget_HRMS
         (p_api_version => 1.0,
          p_return_status => l_return_status,
          p_validation_level => FND_API.G_VALID_LEVEL_FULL,
          p_msg_count => l_msg_count,
          p_msg_data => l_msg_data,
          p_event_type => 'BR',
          p_source_id => p_budget_revision_id,
          p_hr_budget_id => g_hr_budget_id,
          p_from_budget_year_id => null,
          p_to_budget_year_id => null);

     if l_return_status <> FND_API.G_RET_STS_SUCCESS then
        raise FND_API.G_EXC_ERROR;
     end if;

     psb_position_control_pvt.Upload_Budget_HRMS
         (p_api_version => 1.0,
          p_return_status => l_return_status,
          p_validation_level => FND_API.G_VALID_LEVEL_NONE,
          p_msg_count => l_msg_count,
          p_msg_data => l_msg_data,
          p_event_type => 'BR',
          p_source_id => p_budget_revision_id,
          p_hr_budget_id => g_hr_budget_id,
          p_from_budget_year_id => null,
          p_to_budget_year_id => null);

     if l_return_status <> FND_API.G_RET_STS_SUCCESS then
        raise FND_API.G_EXC_ERROR;
     end if;

  end if;
  --++ end upload to HRMS budget


  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) THEN
    commit work;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                             p_data  => p_msg_data);

  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
/* Bug No 2532617 Start */
--     rollback to Update_Baseline_Values;
/* Bug No 2532617 End */
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
/* Bug No 2532617 Start */
--     rollback to Update_Baseline_Values;
/* Bug No 2532617 End */
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

   WHEN OTHERS THEN
/* Bug No 2532617 Start */
--     rollback to Update_Baseline_Values;
/* Bug No 2532617 End */
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

End Update_Baseline_Values;

/* ----------------------------------------------------------------------- */

FUNCTION Prorate_Ratio
(p_original_amount      NUMBER,
 p_original_start_date  DATE,
 p_original_end_date    DATE,
 p_new_start_date       DATE,
 p_new_end_date         DATE
) RETURN NUMBER
IS
  --
  l_prorated_value       NUMBER;
  --
BEGIN

  l_prorated_value := p_original_amount
      * months_between(p_new_end_date ,p_new_start_date  - 1)
      / months_between(p_original_end_date ,p_original_start_date - 1) ;

  RETURN l_prorated_value;

END Prorate_Ratio;

/* ----------------------------------------------------------------------- */

FUNCTION Prorate
(p_element_type          VARCHAR2,
 p_element_value         NUMBER,
 p_pay_basis             VARCHAR2,
 p_period_type           VARCHAR2,
 p_effective_start_date  DATE,
 p_effective_end_date    DATE
) RETURN NUMBER IS

  l_prorated_value       NUMBER;

BEGIN

  if p_element_type = 'S' then
  begin

    if p_pay_basis = 'ANNUAL' then
      l_prorated_value := months_between(p_effective_end_date, (p_effective_start_date - 1)) * p_element_value / 12;
    elsif p_pay_basis = 'HOURLY' then
      l_prorated_value := months_between(p_effective_end_date, (p_effective_start_date - 1)) * p_element_value * 4.33333333;
    elsif p_pay_basis = 'MONTHLY' then
      l_prorated_value := months_between(p_effective_end_date, (p_effective_start_date - 1)) * p_element_value;
    elsif p_pay_basis = 'PERIOD' then
      if p_period_type = 'BM' then
        l_prorated_value := months_between(p_effective_end_date, (p_effective_start_date - 1)) * p_element_value * 0.5;
      elsif p_period_type = 'CM' then
        l_prorated_value := months_between(p_effective_end_date, (p_effective_start_date - 1)) * p_element_value * 1;
      elsif p_period_type = 'F' then
        l_prorated_value := months_between(p_effective_end_date, (p_effective_start_date - 1)) * p_element_value * 2.16666667;
      elsif p_period_type = 'LM' then
        l_prorated_value := months_between(p_effective_end_date, (p_effective_start_date - 1)) * p_element_value * 1;
      elsif p_period_type = 'Q' then
        l_prorated_value := months_between(p_effective_end_date, (p_effective_start_date - 1)) * p_element_value * 0.333333333;
      elsif p_period_type = 'SM' then
        l_prorated_value := months_between(p_effective_end_date, (p_effective_start_date - 1)) * p_element_value * 2;
      elsif p_period_type = 'SY' then
        l_prorated_value := months_between(p_effective_end_date, (p_effective_start_date - 1)) * p_element_value * 0.166666667;
      elsif p_period_type = 'W' then
        l_prorated_value := months_between(p_effective_end_date, (p_effective_start_date - 1)) * p_element_value * 4.33333333;
      elsif p_period_type = 'Y' then
        l_prorated_value := months_between(p_effective_end_date, (p_effective_start_date - 1)) * p_element_value * 0.083333333;
      end if;

    end if;

  end;
  else
  begin

    if p_period_type = 'BM' then
      l_prorated_value := months_between(p_effective_end_date, (p_effective_start_date - 1)) * p_element_value * 0.5;
    elsif p_period_type = 'CM' then
      l_prorated_value := months_between(p_effective_end_date, (p_effective_start_date - 1)) * p_element_value * 1;
    elsif p_period_type = 'F' then
      l_prorated_value := months_between(p_effective_end_date, (p_effective_start_date - 1)) * p_element_value * 2.16666667;
    elsif p_period_type = 'LM' then
      l_prorated_value := months_between(p_effective_end_date, (p_effective_start_date - 1)) * p_element_value * 1;
    elsif p_period_type = 'Q' then
      l_prorated_value := months_between(p_effective_end_date, (p_effective_start_date - 1)) * p_element_value * 0.333333333;
    elsif p_period_type = 'SM' then
      l_prorated_value := months_between(p_effective_end_date, (p_effective_start_date - 1)) * p_element_value * 2;
    elsif p_period_type = 'SY' then
      l_prorated_value := months_between(p_effective_end_date, (p_effective_start_date - 1)) * p_element_value * 0.166666667;
    elsif p_period_type = 'W' then
      l_prorated_value := months_between(p_effective_end_date, (p_effective_start_date - 1)) * p_element_value * 4.33333333;
    elsif p_period_type = 'Y' then
      l_prorated_value := months_between(p_effective_end_date, (p_effective_start_date - 1)) * p_element_value * 0.083333333;
    end if;

  end;
  end if;

  return l_prorated_value;

END Prorate;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                       PROCEDURE Find_FTE                                  |
 +===========================================================================*/
PROCEDURE Find_FTE
( p_api_version            IN           NUMBER,
  p_init_msg_list          IN           VARCHAR2 := FND_API.G_FALSE,
  p_validation_level       IN           NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status          OUT  NOCOPY  VARCHAR2,
  p_msg_count              OUT  NOCOPY  NUMBER,
  p_msg_data               OUT  NOCOPY  VARCHAR2,
  p_position_id            IN           NUMBER,
  p_hr_budget_id           IN           NUMBER,
  p_budget_revision_id     IN           NUMBER,
  p_revision_type          IN           VARCHAR2,
  p_revision_value_type    IN           VARCHAR2,
  p_revision_value         IN           NUMBER,
  p_effective_start_date   IN           DATE,
  p_effective_end_date     IN           DATE,
  p_original_fte           OUT  NOCOPY  NUMBER,
  p_current_fte            OUT  NOCOPY  NUMBER,
  p_revised_fte            OUT  NOCOPY  NUMBER
)
IS
  --
  l_api_version        CONSTANT NUMBER       := 1.0;
  l_api_name           CONSTANT VARCHAR2(30) := 'Find_FTE';
  --
  l_new_position                BOOLEAN := TRUE;
  l_original_fte                NUMBER := 0;
  l_original_fte_count          NUMBER := 0;
  l_current_fte                 NUMBER := 0;
  l_current_fte_count           NUMBER := 0;
  l_revised_fte                 NUMBER;
  --
  CURSOR l_base_fte_csr IS
  SELECT base_line_version, position_fte_line_id, start_date, end_date, fte
  FROM   psb_position_fte
  WHERE  position_id = p_position_id
  AND    NVL (hr_budget_id, -1) = NVL (p_hr_budget_id, -1)
  AND    base_line_version IN ('O', 'C')
  AND    budget_revision_id IS NULL
  AND    (
              start_date BETWEEN p_effective_start_date AND p_effective_end_date
           OR end_date BETWEEN p_effective_start_date AND p_effective_end_date
           OR (
                    start_date < p_effective_start_date
                AND end_date > p_effective_end_date
              )
         );
  --
  CURSOR l_rev_fte_csr IS
  SELECT position_fte_line_id, start_date, end_date, fte
  FROM   psb_position_fte
  WHERE  position_id = p_position_id
  AND    NVL (hr_budget_id, -1) = NVL (p_hr_budget_id, -1)
  AND    budget_revision_id = p_budget_revision_id
  AND    (
              start_date BETWEEN p_effective_start_date AND p_effective_end_date
           OR end_date BETWEEN p_effective_start_date AND p_effective_end_date
           OR (
                    start_date < p_effective_start_date
                AND end_date > p_effective_end_date
              )
         );
  --
BEGIN
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Find base FTE for the position.
  FOR l_base_fte_rec IN l_base_fte_csr LOOP

    l_new_position := FALSE;

    IF l_base_fte_rec.base_line_version = 'C' THEN
      l_current_fte_count := l_current_fte_count + 1;
      l_current_fte := l_current_fte + l_base_fte_rec.fte;
    ELSIF l_base_fte_rec.base_line_version = 'O' THEN
      l_original_fte_count := l_original_fte_count + 1;
      l_original_fte := l_original_fte + l_base_fte_rec.fte;
    END IF;

  END LOOP;

  -- Process if new position.
  IF l_new_position THEN

    FOR l_rev_fte_rec IN l_rev_fte_csr LOOP

      -- Bug#1802309
      /* l_current_fte := l_current_fte + l_rev_fte_rec.fte; */
      l_current_fte_count := l_current_fte_count + 1;

      -- Bug#1802309
      /* l_original_fte := l_original_fte + l_rev_fte_rec.fte; */
      l_original_fte_count := l_original_fte_count + 1;

      -- Bug# 2576216
      IF p_revision_type IS NULL THEN
        l_revised_fte := l_rev_fte_rec.fte;
      END IF;

    END LOOP;

  END IF;
  -- End processing if new position.

  /* Bug No 2576216 Start */
  -- Added the IF conditions
  if l_original_fte_count <> 0 then
    l_original_fte := l_original_fte / l_original_fte_count;
  end if;

  if l_current_fte_count <> 0 then
    l_current_fte := l_current_fte / l_current_fte_count;
  end if;
  /* Bug No 2576216 End */


  if p_revision_type = 'I' then
    --
    if p_revision_value_type = 'A' then
      l_revised_fte := l_current_fte + p_revision_value;
    elsif p_revision_value_type = 'P' then
      l_revised_fte := l_current_fte * (1 + p_revision_value / 100);
    end if;
    --
  elsif p_revision_type = 'D' then
    --
    if p_revision_value_type = 'A' then
      l_revised_fte := l_current_fte - p_revision_value;
    elsif p_revision_value_type = 'P' then
      l_revised_fte := l_current_fte * (1 - p_revision_value / 100);
    end if;
    --
  /* Bug No 2576216 Start */
  else
    --
    if not l_new_position then

      -- Bug#3340060: If revision type is not given, it should mean we
      -- display current FTE as it is without applying revision amount.
      /* l_revised_fte := l_current_fte + l_current_fte; */
      l_revised_fte := l_current_fte ;
      --
    end if;
  /* Bug No 2576216 End */
  end if;

  p_original_fte := l_original_fte;
  p_current_fte  := l_current_fte;
  p_revised_fte  := nvl(l_revised_fte, l_current_fte);

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                             p_data  => p_msg_data);
  --
EXCEPTION
  when OTHERS then
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
      FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                               l_api_name);
    end if;

    FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                               p_data  => p_msg_data);
End Find_FTE;
/*---------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------*/
PROCEDURE Reverse_Position_Accounts
( p_return_status         OUT  NOCOPY     VARCHAR2,
  p_budget_revision_id    IN      NUMBER,
  p_position_id           IN      NUMBER,
  p_effective_start_date  IN      DATE,
  p_effective_end_date    IN      DATE) IS

  l_gl_period             VARCHAR2(15);
  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);

  cursor c_gl_period is
    select period_name
      from gl_period_statuses
     where application_id = 101
       and set_of_books_id = g_set_of_books_id
       and p_effective_start_date between start_date and end_date;

  cursor c_position_account is
    select pbra.budget_revision_acct_line_id,
           pbra.code_combination_id,
           pbra.budget_group_id,
           pbra.gl_period_name,
           pbra.gl_budget_version_id,
           pbra.currency_code,
           pbra.budget_balance,
           pbra.revision_type,
           pbra.revision_value_type,
           pbra.revision_amount,
           pbrl.freeze_flag, pbrl.view_line_flag
      from psb_budget_revision_accounts pbra, psb_budget_revision_lines pbrl
     where pbrl.budget_revision_id = p_budget_revision_id
       and pbra.budget_revision_acct_line_id = pbrl.budget_revision_acct_line_id
       and position_id = p_position_id
       and gl_period_name = l_gl_period;

  cursor c_zero_accounts is
    select pbra.budget_revision_acct_line_id
      from psb_budget_revision_accounts pbra, psb_budget_revision_lines pbrl
     where pbrl.budget_revision_id = p_budget_revision_id
       and pbra.budget_revision_acct_line_id = pbrl.budget_revision_acct_line_id
       and pbra.revision_amount = 0;

BEGIN

  For c_gl_period_rec in c_gl_period Loop
    l_gl_period := c_gl_period_rec.period_name;
  End Loop;

  For c_position_account_rec in c_position_account Loop

    Create_Revision_Accounts
          (p_api_version => 1.0,
           p_return_status => l_return_status,
           p_msg_count => l_msg_count,
           p_msg_data => l_msg_data,
           p_budget_revision_id => p_budget_revision_id,
           p_budget_revision_acct_line_id  => c_position_account_rec.budget_revision_acct_line_id,
           p_code_combination_id => c_position_account_rec.code_combination_id,
           p_budget_group_id => c_position_account_rec.budget_group_id,
           p_position_id => p_position_id,
           p_gl_period_name => c_position_account_rec.gl_period_name,
           p_gl_budget_version_id => c_position_account_rec.gl_budget_version_id,
           p_currency_code => c_position_account_rec.currency_code,
           p_budget_balance => c_position_account_rec.budget_balance,
           p_revision_type => c_position_account_rec.revision_type,
           p_revision_value_type => c_position_account_rec.revision_value_type,
           p_revision_amount => 0,
           p_funds_status_code => FND_API.G_MISS_CHAR,
           p_funds_result_code => FND_API.G_MISS_CHAR,
           p_funds_control_timestamp => sysdate,
           p_note_id => FND_API.G_MISS_NUM,
           p_freeze_flag => c_position_account_rec.freeze_flag,
           p_view_line_flag => c_position_account_rec.view_line_flag);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  End Loop;

  Create_Summary_Position_Line
        (p_return_status => l_return_status,
         p_budget_revision_id => p_budget_revision_id,
         p_currency_code => g_func_currency,
         p_gl_period_name => l_gl_period);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
     raise FND_API.G_EXC_ERROR;
  end if;
  /* start bug 3418071 */
  /*if g_create_zero_bal <> 'Y' then */
  begin

    for c_zero_accounts_rec in c_zero_accounts loop

      Delete_Revision_Accounts
            (p_api_version => 1.0,
             p_return_status => l_return_status,
             p_msg_count => l_msg_count,
             p_msg_data => l_msg_data,
             p_budget_revision_id  => p_budget_revision_id,
             p_budget_revision_acct_line_id => c_zero_accounts_rec.budget_revision_acct_line_id);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
        raise FND_API.G_EXC_ERROR;
      end if;

    end loop;

  end;
  /*end if;*/
  /* end bug 3418071 */

  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

End Reverse_Position_Accounts;

/* ----------------------------------------------------------------------- */

PROCEDURE Calculate_Position_Cost_Dates
( p_return_status        OUT  NOCOPY  VARCHAR2,
  p_position_id          IN   NUMBER,
  p_position_name        IN   VARCHAR2,
  p_revision_start_date  IN   DATE,
  p_revision_end_date    IN   DATE
) IS

  l_pay_element_id            NUMBER;
  l_pay_element_option_id     NUMBER;
  l_period_type               VARCHAR2(10);
  l_element_name              VARCHAR2(30);
  l_element_cost              NUMBER;
  l_salary_value              NUMBER;
  l_element_value             NUMBER;
  l_element_value_type        VARCHAR2(2);
  l_element_assigned          BOOLEAN;
  l_start_date                DATE;
  l_end_date                  DATE;
  l_pay_basis                 VARCHAR2(10);
  l_fte                       NUMBER;
  l_default_weekly_hours      NUMBER;
  l_rate_found                BOOLEAN;

BEGIN

  for l_element_index in 1..PSB_WS_POS1.g_num_elements loop
    l_pay_element_id := PSB_WS_POS1.g_elements(l_element_index).pay_element_id;
    l_period_type := PSB_WS_POS1.g_elements(l_element_index).period_type;
    l_element_name := PSB_WS_POS1.g_elements(l_element_index).element_name;
    l_element_cost := 0;
    l_salary_value := 0;
    l_element_assigned := FALSE;

    for l_assign_index in 1..g_num_elem_assignments loop

      if ((g_elem_assignments(l_assign_index).pay_element_id = l_pay_element_id) and
        (((g_elem_assignments(l_assign_index).start_date <= p_revision_end_date) and
          (g_elem_assignments(l_assign_index).end_date is null)) or
         ((g_elem_assignments(l_assign_index).start_date between p_revision_start_date and p_revision_end_date) or
          (g_elem_assignments(l_assign_index).end_date between p_revision_start_date and p_revision_end_date) or
         ((g_elem_assignments(l_assign_index).start_date < p_revision_start_date) and
          (g_elem_assignments(l_assign_index).end_date > p_revision_end_date)))) and
          (g_elem_assignments(l_assign_index).use_in_calc)) then
      begin

        l_element_assigned := TRUE;
        l_element_value_type := g_elem_assignments(l_assign_index).element_value_type;
        l_element_value := g_elem_assignments(l_assign_index).element_value;
        l_pay_element_option_id := g_elem_assignments(l_assign_index).pay_element_option_id;
        l_start_date := greatest(p_revision_start_date, g_elem_assignments(l_assign_index).start_date);
        l_end_date := least(p_revision_end_date, nvl(g_elem_assignments(l_assign_index).end_date, p_revision_end_date));
        l_pay_basis := g_elem_assignments(l_assign_index).pay_basis;

/* Bug No 1832091 Start */
-- Commented
--        if l_element_value is null then
/* Bug No 1832091 End */
        begin

          for l_rate_index in 1..g_num_elem_rates loop

            if ((g_elem_rates(l_rate_index).pay_element_id = l_pay_element_id) and
                (nvl(g_elem_rates(l_rate_index).pay_element_option_id, FND_API.G_MISS_NUM) = nvl(l_pay_element_option_id, FND_API.G_MISS_NUM)) and
              (((g_elem_rates(l_rate_index).start_date <= l_start_date) and
                (g_elem_rates(l_rate_index).end_date is null)) or
               ((g_elem_rates(l_rate_index).start_date between l_start_date and l_end_date) or
                (g_elem_rates(l_rate_index).end_date between l_start_date and l_end_date) or
               ((g_elem_rates(l_rate_index).start_date < l_start_date) and
                (g_elem_rates(l_rate_index).end_date > l_end_date))))) then
            begin

              if g_elem_rates(l_rate_index).budget_revision_id is not null then
              begin

                if l_pay_basis is null then
                  l_pay_basis := g_elem_rates(l_rate_index).pay_basis;
                end if;

                l_element_value_type := g_elem_rates(l_rate_index).element_value_type;
                l_element_value := g_elem_rates(l_rate_index).element_value;
                exit;

              end;
              else
              begin

                if l_pay_basis is null then
                  l_pay_basis := g_elem_rates(l_rate_index).pay_basis;
                end if;

/* Bug No 1832091 Start */
-- Following 2 lines of code is uncommented and put inside the IF statement, which is added.
               if l_element_value is null then
                  l_element_value_type := g_elem_rates(l_rate_index).element_value_type;
                  l_element_value := g_elem_rates(l_rate_index).element_value;
               end if;
/* Bug No 1832091 End */
                exit;

              end;
              end if;

            end;
            end if;

          end loop;

        end;

/* Bug No 1832091 Start */
-- Commented
--        end if;
/* Bug No 1832091 End */

        for l_assign_index in 1..g_num_fte_assignments loop

          if (((g_fte_assignments(l_assign_index).start_date <= l_end_date) and
              (g_fte_assignments(l_assign_index).end_date is null)) or
             ((g_fte_assignments(l_assign_index).start_date between l_start_date and l_end_date) or
              (g_fte_assignments(l_assign_index).end_date between l_start_date and l_end_date) or
             ((g_fte_assignments(l_assign_index).start_date < l_start_date) and
              (g_fte_assignments(l_assign_index).end_date > l_end_date)))) then
          begin

            l_fte := g_fte_assignments(l_assign_index).fte;
            exit;

          end;
          end if;

        end loop;

        for l_assign_index in 1..g_num_wkh_assignments loop

          if (((g_wkh_assignments(l_assign_index).start_date <= l_end_date) and
              (g_wkh_assignments(l_assign_index).end_date is null)) or
             ((g_wkh_assignments(l_assign_index).start_date between l_start_date and l_end_date) or
              (g_wkh_assignments(l_assign_index).end_date between l_start_date and l_end_date) or
             ((g_wkh_assignments(l_assign_index).start_date < l_start_date) and
              (g_wkh_assignments(l_assign_index).end_date > l_end_date)))) then
          begin

            l_default_weekly_hours := g_wkh_assignments(l_assign_index).default_weekly_hours;
            exit;

          end;
          end if;

        end loop;

        if l_element_value_type = 'PI' then
          message_token('ELEMENT_VALUE_TYPE', l_element_value_type);
          message_token('ELEMENT', PSB_WS_POS1.g_elements(l_element_index).element_name);
          message_token('POSITION', p_position_name);
          add_message('PSB', 'PSB_INVALID_ASSIGNMENT_TYPE');
          raise FND_API.G_EXC_ERROR;
        end if;

        if PSB_WS_POS1.g_elements(l_element_index).salary_flag = 'Y' then
        begin
          if l_pay_basis = 'ANNUAL' then
          begin
            l_element_cost := l_element_cost + l_fte
                            * Prorate(p_element_type => 'S', p_element_value => l_element_value,
                                      p_pay_basis => l_pay_basis, p_period_type => null,
                                      p_effective_start_date => l_start_date, p_effective_end_date => l_end_date);
          end;
          elsif l_pay_basis = 'HOURLY' then
          begin
            if l_default_weekly_hours is null then
              message_token('ATTRIBUTE', 'DEFAULT_WEEKLY_HOURS');
              message_token('POSITION', p_position_name);
              message_token('START_DATE', l_start_date);
              message_token('END_DATE', l_end_date);
              add_message('PSB', 'PSB_INVALID_NAMED_ATTRIBUTE');
              raise FND_API.G_EXC_ERROR;
            end if;

            l_element_cost := l_element_cost + l_fte * l_default_weekly_hours
                            * Prorate(p_element_type => 'S', p_element_value => l_element_value,
                                      p_pay_basis => l_pay_basis, p_period_type => null,
                                      p_effective_start_date => l_start_date, p_effective_end_date => l_end_date);
          end;
          elsif l_pay_basis = 'MONTHLY' then
          begin
            l_element_cost := l_element_cost + l_fte
                            * Prorate(p_element_type => 'S', p_element_value => l_element_value,
                                      p_pay_basis => l_pay_basis, p_period_type => null,
                                      p_effective_start_date => l_start_date, p_effective_end_date => l_end_date);
          end;
          elsif l_pay_basis = 'PERIOD' then
          begin
            l_element_cost := l_element_cost + l_fte
                            * Prorate(p_element_type => 'S', p_element_value => l_element_value,
                                      p_pay_basis => l_pay_basis, p_period_type => l_period_type,
                                      p_effective_start_date => l_start_date, p_effective_end_date => l_end_date);
          end;
          else
            message_token('POSITION', p_position_name);
            message_token('START_DATE', l_start_date);
            message_token('END_DATE', l_end_date);
            add_message('PSB', 'PSB_INVALID_SALARY_BASIS');
            raise FND_API.G_EXC_ERROR;
          end if;

        end;
        else  -- non salary element
        begin

          if l_element_value_type = 'PS' then
          begin

            if l_element_value >= 1 then
              l_element_value := l_element_value / 100;
            end if;

            for l_salary_index in 1..g_num_costs loop

              if g_costs(l_salary_index).element_type = 'S' then
                l_salary_value := l_salary_value + Prorate_Ratio (p_original_amount => g_costs(l_salary_index).element_cost,
                                                                  p_original_start_date => g_costs(l_salary_index).start_date,
                                                                  p_original_end_date => g_costs(l_salary_index).end_date,
                                                                  p_new_start_date => l_start_date,
                                                                  p_new_end_date => l_end_date);
              end if;

            end loop;

            l_element_cost := l_salary_value * l_element_value ;

          end;
          elsif l_element_value_type = 'A' then
            l_element_cost := l_element_cost + l_fte
                            * Prorate(p_element_type => 'F', p_element_value => l_element_value,
                                      p_pay_basis => l_pay_basis, p_period_type => l_period_type,
                                      p_effective_start_date => l_start_date, p_effective_end_date => l_end_date);
          end if;

        end;
        end if;

      end;
      end if;

    end loop; -- element assignments

    -- Bug#3340060: Element cost will be null if an element does not have rates
    -- defined. However element cost is required in psb_position_costs table.
    -- The following will address this rare scenario.
    /* if l_element_assigned then */
    IF l_element_assigned AND l_element_cost IS NOT NULL THEN

      g_num_costs := g_num_costs + 1;
      g_costs(g_num_costs).pay_element_id := l_pay_element_id;

      if PSB_WS_POS1.g_elements(l_element_index).salary_flag = 'Y' then
        g_costs(g_num_costs).element_type := 'S';
      elsif PSB_WS_POS1.g_elements(l_element_index).follow_salary = 'Y' then
        g_costs(g_num_costs).element_type := 'F';
      end if;

      g_costs(g_num_costs).element_cost := l_element_cost;
      g_costs(g_num_costs).start_date := l_start_date;
      g_costs(g_num_costs).end_date := l_end_date;
      g_costs(g_num_costs).currency_code := g_func_currency;

    END IF;

  end loop;

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Calculate_Position_Cost_Dates;
/*---------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------*/
PROCEDURE Distribute_Salary
( p_return_status         OUT  NOCOPY  VARCHAR2,
  p_pay_element_id        IN   NUMBER,
  p_position_id           IN   NUMBER,
  p_revision_start_date   IN   DATE,
  p_revision_end_date     IN   DATE
) IS

  l_amount                NUMBER;
  l_percent               NUMBER;

  l_start_date            DATE;
  l_end_date              DATE;

  l_dist_found            BOOLEAN;
  l_account_index         BINARY_INTEGER;

BEGIN

  for l_calc_index in 1..g_num_costs loop

    if g_costs(l_calc_index).pay_element_id = p_pay_element_id then
    begin

      for l_saldist_index in 1..PSB_WS_POS1.g_num_salary_dist loop

        if (((PSB_WS_POS1.g_salary_dist(l_saldist_index).start_date <= g_costs(l_calc_index).end_date) and
             (PSB_WS_POS1.g_salary_dist(l_saldist_index).end_date is null)) or
            ((PSB_WS_POS1.g_salary_dist(l_saldist_index).start_date between g_costs(l_calc_index).start_date and g_costs(l_calc_index).end_date) or
             (PSB_WS_POS1.g_salary_dist(l_saldist_index).end_date between g_costs(l_calc_index).start_date and g_costs(l_calc_index).end_date) or
            ((PSB_WS_POS1.g_salary_dist(l_saldist_index).start_date < g_costs(l_calc_index).start_date) and
             (PSB_WS_POS1.g_salary_dist(l_saldist_index).end_date > g_costs(l_calc_index).end_date)))) then
        begin

          l_dist_found := FALSE;
          l_account_index := null;
          l_start_date := greatest(g_costs(l_calc_index).start_date, PSB_WS_POS1.g_salary_dist(l_saldist_index).start_date);
          l_end_date := least(g_costs(l_calc_index).end_date, nvl(PSB_WS_POS1.g_salary_dist(l_saldist_index).end_date, g_costs(l_calc_index).end_date));

          for l_dist_index in 1..g_num_dists loop

            if g_dists(l_dist_index).ccid = PSB_WS_POS1.g_salary_dist(l_saldist_index).ccid then
              l_dist_found := TRUE;
              l_account_index := l_dist_index;
            end if;

          end loop;

          -- commented for bug # 4502946
          /*if PSB_WS_POS1.g_salary_dist(l_saldist_index).percent < 1 then
            l_percent := PSB_WS_POS1.g_salary_dist(l_saldist_index).percent;
          else
            l_percent := PSB_WS_POS1.g_salary_dist(l_saldist_index).percent / 100;
          end if;*/

          -- added for bug # 4502946
          l_percent := PSB_WS_POS1.g_salary_dist(l_saldist_index).percent / 100;

          if not l_dist_found then
          begin

            g_num_dists := g_num_dists + 1;

            g_dists(g_num_dists).ccid := PSB_WS_POS1.g_salary_dist(l_saldist_index).ccid;
            g_dists(g_num_dists).budget_group_id := PSB_WS_POS1.g_salary_budget_group_id;
            g_dists(g_num_dists).currency_code := g_func_currency;
            g_dists(g_num_dists).start_date := l_start_date;
            g_dists(g_num_dists).end_date := l_end_date;


            g_dists(g_num_dists).amount := l_percent *
                                           Prorate_Ratio (p_original_amount => g_costs(l_calc_index).element_cost,
                                                          p_original_start_date => g_costs(l_calc_index).start_date,
                                                          p_original_end_date => g_costs(l_calc_index).end_date,
                                                          p_new_start_date => l_start_date,
                                                          p_new_end_date => l_end_date);


            g_dists(g_num_dists).calc_rev := FALSE;

          end;
          else
            g_dists(l_account_index).amount := nvl(g_dists(l_account_index).amount, 0) + l_percent *
                                               Prorate_Ratio (p_original_amount => g_costs(l_calc_index).element_cost,
                                                              p_original_start_date => g_costs(l_calc_index).start_date,
                                                              p_original_end_date => g_costs(l_calc_index).end_date,
                                                              p_new_start_date => l_start_date,
                                                              p_new_end_date => l_end_date);

          end if;

        end;
        end if;

      end loop;

    end;
    end if;

  end loop;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Distribute_Salary;

/* ----------------------------------------------------------------------- */

PROCEDURE Distribute_Following_Elements
( p_return_status         OUT  NOCOPY  VARCHAR2,
  p_pay_element_id        IN   NUMBER,
  p_position_id           IN   NUMBER,
  p_revision_start_date   IN   DATE,
  p_revision_end_date     IN   DATE
) IS

  l_ccid_val             FND_FLEX_EXT.SegmentArray;
  l_seg_val              FND_FLEX_EXT.SegmentArray;
  l_ccid                 NUMBER;

  l_start_date           DATE;
  l_end_date             DATE;

  l_dist_start_date      DATE;
  l_dist_end_date        DATE;

  l_amount               NUMBER;
  l_percent              NUMBER;

  l_dist_found           BOOLEAN;
  l_account_index        BINARY_INTEGER;

  cursor c_Dist is
    select a.segment1, a.segment2, a.segment3, a.segment4,
           a.segment5, a.segment6, a.segment7, a.segment8,
           a.segment9, a.segment10, a.segment11, a.segment12,
           a.segment13, a.segment14, a.segment15, a.segment16,
           a.segment17, a.segment18, a.segment19, a.segment20,
           a.segment21, a.segment22, a.segment23, a.segment24,
           a.segment25, a.segment26, a.segment27, a.segment28,
           a.segment29, a.segment30, a.effective_start_date, a.effective_end_date
      from PSB_PAY_ELEMENT_DISTRIBUTIONS a,
           PSB_ELEMENT_POS_SET_GROUPS b,
           PSB_SET_RELATIONS c,
           PSB_BUDGET_POSITIONS d
     where a.chart_of_accounts_id = g_flex_code
       and (((a.effective_start_date <= p_revision_end_date)
         and (a.effective_end_date is null))
         or ((a.effective_start_date between p_revision_start_date and p_revision_end_date)
          or (a.effective_end_date between p_revision_start_date and p_revision_end_date)
         or ((a.effective_start_date < p_revision_start_date)
         and (a.effective_end_date > p_revision_end_date))))
       and a.position_set_group_id = b.position_set_group_id
       and b.position_set_group_id = c.position_set_group_id
       and b.pay_element_id = p_pay_element_id
       and c.account_position_set_id = d.account_position_set_id
       and d.data_extract_id = g_data_extract_id
       and d.position_id = p_position_id;

BEGIN

  for l_calc_index in 1..g_num_costs loop


    if g_costs(l_calc_index).pay_element_id = p_pay_element_id then
    begin

      for c_Dist_Rec in c_Dist loop

        if (((c_Dist_Rec.effective_start_date <= g_costs(l_calc_index).end_date) and
             (c_Dist_Rec.effective_end_date is null)) or
            ((c_Dist_Rec.effective_start_date between g_costs(l_calc_index).start_date and g_costs(l_calc_index).end_date) or
             (c_Dist_Rec.effective_end_date between g_costs(l_calc_index).start_date and g_costs(l_calc_index).end_date) or
            ((c_Dist_Rec.effective_start_date < g_costs(l_calc_index).start_date) and
             (c_Dist_Rec.effective_end_date > g_costs(l_calc_index).end_date)))) then
        begin

          l_start_date := greatest(g_costs(l_calc_index).start_date, c_Dist_Rec.effective_start_date);
          l_end_date := least(g_costs(l_calc_index).end_date, nvl(c_Dist_Rec.effective_end_date, g_costs(l_calc_index).end_date));

          for l_saldist_index in 1..PSB_WS_POS1.g_num_salary_dist loop

            if (((PSB_WS_POS1.g_salary_dist(l_saldist_index).start_date <= l_end_date) and
                 (PSB_WS_POS1.g_salary_dist(l_saldist_index).end_date is null)) or
                ((PSB_WS_POS1.g_salary_dist(l_saldist_index).start_date between l_start_date and l_end_date) or
                 (PSB_WS_POS1.g_salary_dist(l_saldist_index).end_date between l_start_date and l_end_date) or
                ((PSB_WS_POS1.g_salary_dist(l_saldist_index).start_date < l_start_date) and
                 (PSB_WS_POS1.g_salary_dist(l_saldist_index).end_date > l_end_date)))) then
            begin

          l_dist_start_date := greatest(l_start_date, PSB_WS_POS1.g_salary_dist(l_saldist_index).start_date);
          l_dist_end_date := least(l_end_date, nvl(PSB_WS_POS1.g_salary_dist(l_saldist_index).end_date, l_end_date));

              l_dist_found := FALSE;
              l_account_index := null;

              -- commented for bug # 4502946
              /*if PSB_WS_POS1.g_salary_dist(l_saldist_index).percent < 1 then
                l_percent := PSB_WS_POS1.g_salary_dist(l_saldist_index).percent;
              else
                l_percent := PSB_WS_POS1.g_salary_dist(l_saldist_index).percent / 100;
              end if;*/

              -- added for bug # 4502946
              l_percent := PSB_WS_POS1.g_salary_dist(l_saldist_index).percent / 100;

              for l_init_index in 1..PSB_WS_ACCT1.g_num_segs loop
                l_ccid_val(l_init_index) := null;
                l_seg_val(l_init_index) := null;
              end loop;

              if not FND_FLEX_EXT.Get_Segments
                (application_short_name => 'SQLGL',
                 key_flex_code => 'GL#',
                 structure_number => g_flex_code,
                 combination_id => PSB_WS_POS1.g_salary_dist(l_saldist_index).ccid,
                 n_segments => PSB_WS_ACCT1.g_num_segs,
                 segments => l_ccid_val) then

                FND_MSG_PUB.Add;
                raise FND_API.G_EXC_ERROR;
              end if;

              for l_index in 1..PSB_WS_ACCT1.g_num_segs loop

                if ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT1') and
                    (c_Dist_Rec.segment1 is not null)) then
                  l_seg_val(l_index) := c_Dist_Rec.segment1;

                elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT2') and
                    (c_Dist_Rec.segment2 is not null)) then
                  l_seg_val(l_index) := c_Dist_Rec.segment2;

                elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT3') and
                    (c_Dist_Rec.segment3 is not null)) then
                  l_seg_val(l_index) := c_Dist_Rec.segment3;

                elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT4') and
                    (c_Dist_Rec.segment4 is not null)) then
                  l_seg_val(l_index) := c_Dist_Rec.segment4;

                elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT5') and
                    (c_Dist_Rec.segment5 is not null)) then
                  l_seg_val(l_index) := c_Dist_Rec.segment5;

                elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT6') and
                    (c_Dist_Rec.segment6 is not null)) then
                  l_seg_val(l_index) := c_Dist_Rec.segment6;

                elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT7') and
                    (c_Dist_Rec.segment7 is not null)) then
                  l_seg_val(l_index) := c_Dist_Rec.segment7;

                elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT8') and
                    (c_Dist_Rec.segment8 is not null)) then
                  l_seg_val(l_index) := c_Dist_Rec.segment8;

                elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT9') and
                    (c_Dist_Rec.segment9 is not null)) then
                  l_seg_val(l_index) := c_Dist_Rec.segment9;

                elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT10') and
                    (c_Dist_Rec.segment10 is not null)) then
                  l_seg_val(l_index) := c_Dist_Rec.segment10;

                elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT11') and
                    (c_Dist_Rec.segment11 is not null)) then
                  l_seg_val(l_index) := c_Dist_Rec.segment11;

                elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT12') and
                    (c_Dist_Rec.segment12 is not null)) then
                  l_seg_val(l_index) := c_Dist_Rec.segment12;

                elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT13') and
                    (c_Dist_Rec.segment13 is not null)) then
                  l_seg_val(l_index) := c_Dist_Rec.segment13;

                elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT14') and
                    (c_Dist_Rec.segment14 is not null)) then
                  l_seg_val(l_index) := c_Dist_Rec.segment14;

                elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT15') and
                    (c_Dist_Rec.segment15 is not null)) then
                  l_seg_val(l_index) := c_Dist_Rec.segment15;

                elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT16') and
                    (c_Dist_Rec.segment16 is not null)) then
                  l_seg_val(l_index) := c_Dist_Rec.segment16;

                elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT17') and
                    (c_Dist_Rec.segment17 is not null)) then
                  l_seg_val(l_index) := c_Dist_Rec.segment17;

                elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT18') and
                    (c_Dist_Rec.segment18 is not null)) then
                  l_seg_val(l_index) := c_Dist_Rec.segment18;

                elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT19') and
                    (c_Dist_Rec.segment19 is not null)) then
                  l_seg_val(l_index) := c_Dist_Rec.segment19;

                elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT20') and
                    (c_Dist_Rec.segment20 is not null)) then
                  l_seg_val(l_index) := c_Dist_Rec.segment20;

                elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT21') and
                    (c_Dist_Rec.segment21 is not null)) then
                  l_seg_val(l_index) := c_Dist_Rec.segment21;

                elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT22') and
                    (c_Dist_Rec.segment22 is not null)) then
                  l_seg_val(l_index) := c_Dist_Rec.segment22;

                elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT23') and
                    (c_Dist_Rec.segment23 is not null)) then
                  l_seg_val(l_index) := c_Dist_Rec.segment23;

                elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT24') and
                    (c_Dist_Rec.segment24 is not null)) then
                  l_seg_val(l_index) := c_Dist_Rec.segment24;

                elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT25') and
                    (c_Dist_Rec.segment25 is not null)) then
                  l_seg_val(l_index) := c_Dist_Rec.segment25;

                elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT26') and
                    (c_Dist_Rec.segment26 is not null)) then
                  l_seg_val(l_index) := c_Dist_Rec.segment26;

                elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT27') and
                    (c_Dist_Rec.segment27 is not null)) then
                  l_seg_val(l_index) := c_Dist_Rec.segment27;

                elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT28') and
                    (c_Dist_Rec.segment28 is not null)) then
                  l_seg_val(l_index) := c_Dist_Rec.segment28;

                elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT29') and
                    (c_Dist_Rec.segment29 is not null)) then
                  l_seg_val(l_index) := c_Dist_Rec.segment29;

                elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT30') and
                    (c_Dist_Rec.segment30 is not null)) then
                  l_seg_val(l_index) := c_Dist_Rec.segment30;

                else
                  l_seg_val(l_index) := l_ccid_val(l_index);
                end if;

              end loop;

              if not FND_FLEX_EXT.Get_Combination_ID
                (application_short_name => 'SQLGL',
                 key_flex_code => 'GL#',
                 structure_number => g_flex_code,
                 validation_date => sysdate,
                 n_segments => PSB_WS_ACCT1.g_num_segs,
                 segments => l_seg_val,
                 combination_id => l_ccid) then

                FND_MSG_PUB.Add;
                raise FND_API.G_EXC_ERROR;
              end if;


              for l_dist_index in 1..g_num_dists loop

                if g_dists(l_dist_index).ccid = l_ccid then
                  l_dist_found := TRUE;
                  l_account_index := l_dist_index;
                end if;

              end loop;

              if not l_dist_found then
              begin

                g_num_dists := g_num_dists + 1;

                g_dists(g_num_dists).ccid := l_ccid;
                g_dists(g_num_dists).budget_group_id := PSB_WS_POS1.g_salary_budget_group_id;
                g_dists(g_num_dists).currency_code := g_func_currency;
                g_dists(g_num_dists).start_date := l_start_date;
                g_dists(g_num_dists).end_date := l_end_date;
                g_dists(g_num_dists).amount := l_percent *
                                               Prorate_Ratio (p_original_amount => g_costs(l_calc_index).element_cost,
                                                              p_original_start_date => g_costs(l_calc_index).start_date,
                                                              p_original_end_date => g_costs(l_calc_index).end_date,
                                                              p_new_start_date => l_dist_start_date,
                                                              p_new_end_date => l_dist_end_date);
                g_dists(g_num_dists).calc_rev := FALSE;

              end;
              else
                g_dists(l_account_index).amount := nvl(g_dists(l_account_index).amount, 0) + l_percent *
                                                   Prorate_Ratio (p_original_amount => g_costs(l_calc_index).element_cost,
                                                                  p_original_start_date => g_costs(l_calc_index).start_date,
                                                                  p_original_end_date => g_costs(l_calc_index).end_date,
                                                                  p_new_start_date => l_dist_start_date,
                                                                  p_new_end_date => l_dist_end_date);
              end if;

            end;
            end if;

          end loop;

        end;
        end if;

      end loop;

    end;
    end if;

  end loop;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Distribute_Following_Elements;

/* ----------------------------------------------------------------------- */

PROCEDURE Distribute_Other_Elements
( p_return_status         OUT  NOCOPY  VARCHAR2,
  p_pay_element_id        IN   NUMBER,
  p_position_id           IN   NUMBER,
  p_revision_start_date   IN   DATE,
  p_revision_end_date     IN   DATE
) IS

  l_amount                NUMBER;
  l_percent               NUMBER;

  l_start_date            DATE;
  l_end_date              DATE;

  l_dist_found            BOOLEAN;
  l_account_index         BINARY_INTEGER;

  cursor c_Dist is
    select a.code_combination_id,
           a.distribution_percent, a.effective_start_date, a.effective_end_date
      from PSB_PAY_ELEMENT_DISTRIBUTIONS a,
           PSB_ELEMENT_POS_SET_GROUPS b,
           PSB_SET_RELATIONS c,
           PSB_BUDGET_POSITIONS d
     where a.chart_of_accounts_id = g_flex_code
       and (((a.effective_start_date <= p_revision_end_date)
         and (a.effective_end_date is null))
         or ((a.effective_start_date between p_revision_start_date and p_revision_end_date)
          or (a.effective_end_date between p_revision_start_date and p_revision_end_date)
         or ((a.effective_start_date < p_revision_start_date)
         and (a.effective_end_date > p_revision_end_date))))
       and a.position_set_group_id = b.position_set_group_id
       and b.position_set_group_id = c.position_set_group_id
       and b.pay_element_id = p_pay_element_id
       and c.account_position_set_id = d.account_position_set_id
       and d.data_extract_id = g_data_extract_id
       and d.position_id = p_position_id
     order by a.distribution_percent desc;

BEGIN

  for l_calc_index in 1..g_num_costs loop

    if g_costs(l_calc_index).pay_element_id = p_pay_element_id then
    begin

      for c_Dist_Rec in c_Dist loop

        if (((c_Dist_Rec.effective_start_date <= g_costs(l_calc_index).end_date) and
             (c_Dist_Rec.effective_end_date is null)) or
            ((c_Dist_Rec.effective_start_date between g_costs(l_calc_index).start_date and g_costs(l_calc_index).end_date) or
             (c_Dist_Rec.effective_end_date between g_costs(l_calc_index).start_date and g_costs(l_calc_index).end_date) or
            ((c_Dist_Rec.effective_start_date < g_costs(l_calc_index).start_date) and
             (c_Dist_Rec.effective_end_date > g_costs(l_calc_index).end_date)))) then
        begin

          l_start_date := greatest(g_costs(l_calc_index).start_date, c_Dist_Rec.effective_start_date);
          l_end_date := least(g_costs(l_calc_index).end_date, nvl(c_Dist_Rec.effective_end_date, g_costs(l_calc_index).end_date));

          l_dist_found := FALSE;
          l_account_index := null;

          g_costs(l_calc_index).pay_element_id := p_pay_element_id;

          -- commented for bug # 4502946
          /*if c_Dist_Rec.distribution_percent < 1 then
            l_percent := c_Dist_Rec.distribution_percent;
          else
            l_percent := c_Dist_Rec.distribution_percent / 100;
          end if;*/

          -- added for bug # 4502946
          l_percent := c_Dist_Rec.distribution_percent / 100;

          for l_dist_index in 1..g_num_dists loop

            if g_dists(l_dist_index).ccid = c_Dist_Rec.code_combination_id then
              l_dist_found := TRUE;
              l_account_index := l_dist_index;
            end if;

          end loop;

          if not l_dist_found then
          begin

            g_num_dists := g_num_dists + 1;
            g_dists(g_num_dists).ccid := c_Dist_Rec.code_combination_id;
            g_dists(g_num_dists).budget_group_id := PSB_WS_POS1.g_salary_budget_group_id;
            g_dists(g_num_dists).currency_code := g_func_currency;
            g_dists(g_num_dists).start_date := l_start_date;
            g_dists(g_num_dists).end_date := l_end_date;
            g_dists(g_num_dists).amount := l_percent *
                                           Prorate_Ratio (p_original_amount => g_costs(l_calc_index).element_cost,
                                                          p_original_start_date => g_costs(l_calc_index).start_date,
                                                          p_original_end_date => g_costs(l_calc_index).end_date,
                                                          p_new_start_date => l_start_date,
                                                          p_new_end_date => l_end_date);
            g_dists(g_num_dists).calc_rev := FALSE;

          end;
          else
            g_dists(l_account_index).amount := nvl(g_dists(l_account_index).amount, 0) + l_percent *
                                               Prorate_Ratio (p_original_amount => g_costs(l_calc_index).element_cost,
                                                              p_original_start_date => g_costs(l_calc_index).start_date,
                                                              p_original_end_date => g_costs(l_calc_index).end_date,
                                                              p_new_start_date => l_start_date,
                                                              p_new_end_date => l_end_date);
          end if;

        end;
        end if;

      end loop;

    end;
    end if;

  end loop;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Distribute_Other_Elements;

/*-------------------------------------------------------------------------*/

PROCEDURE Distribute_Position_Cost
( p_return_status         OUT  NOCOPY  VARCHAR2,
  p_position_id           IN   NUMBER,
  p_revision_start_date   IN   DATE,
  p_revision_end_date     IN   DATE
) IS

  l_return_status         VARCHAR2(1);

BEGIN

  for l_element_index in 1..PSB_WS_POS1.g_num_elements loop

    if PSB_WS_POS1.g_elements(l_element_index).salary_flag = 'Y' then
    begin

      Distribute_Salary
             (p_return_status  => l_return_status,
              p_pay_element_id => PSB_WS_POS1.g_elements(l_element_index).pay_element_id,
              p_position_id => p_position_id,
              p_revision_start_date => p_revision_start_date,
              p_revision_end_date => p_revision_end_date);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
        raise FND_API.G_EXC_ERROR;
      end if;

    end;
    else
    begin

      if PSB_WS_POS1.g_elements(l_element_index).follow_salary = 'Y' then
      begin

        Distribute_Following_Elements
           (p_return_status => l_return_status,
            p_pay_element_id => PSB_WS_POS1.g_elements(l_element_index).pay_element_id,
            p_position_id => p_position_id,
            p_revision_start_date => p_revision_start_date,
            p_revision_end_date => p_revision_end_date);

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
          raise FND_API.G_EXC_ERROR;
        end if;

      end;
      else
      begin

        Distribute_Other_Elements
           (p_return_status => l_return_status,
            p_pay_element_id => PSB_WS_POS1.g_elements(l_element_index).pay_element_id,
            p_position_id => p_position_id,
            p_revision_start_date => p_revision_start_date,
            p_revision_end_date => p_revision_end_date);

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
          raise FND_API.G_EXC_ERROR;
        end if;

      end;
      end if;

     end;
     end if;

  end loop;

-- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

End Distribute_Position_Cost;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                       PROCEDURE Update_Position_Cost                      |
 +===========================================================================*/
PROCEDURE Update_Position_Cost
( p_return_status       OUT NOCOPY VARCHAR2
, p_mass_revision       IN         BOOLEAN
, p_position_id         IN         NUMBER
, p_hr_budget_id        IN         NUMBER
, p_budget_revision_id  IN         NUMBER
, p_revision_start_date IN         DATE
, p_revision_end_date   IN         DATE
-- Added p_zero_revised_fte for bug 2896687
, p_zero_revised_fte    IN         BOOLEAN := FALSE
, p_parameter_id        IN         NUMBER -- Bug#4675858
)
IS
  --
  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);
  --
  l_budget_rev_acct_line_id   NUMBER;
  l_budget_rev_pos_line_id    NUMBER;
  l_revision_amount           NUMBER;
  l_rounded_amount            NUMBER;
  l_revision_type             VARCHAR2(1);
  l_gl_budget_version_id      NUMBER;
  l_start_date                DATE;
  l_end_date                  DATE;
  l_gl_period_name            VARCHAR2(15);
  l_account_found             BOOLEAN;
  --
  l_pos_line_id               NUMBER ;         -- Bug#4675858
  l_note_parameter_name       VARCHAR2(30) ;   -- Bug#4675858
  l_note                      VARCHAR2(4000) ; -- Bug#4675858
  --
  CURSOR c_currdist IS
  SELECT code_combination_id, start_date, end_date, amount
  FROM   psb_position_accounts
  WHERE  position_id = p_position_id
  AND    NVL (hr_budget_id, -1) = NVL (p_hr_budget_id, -1)
  AND    currency_code = g_func_currency
  AND    base_line_version = 'C'
  AND    (
              start_date BETWEEN p_revision_start_date AND p_revision_end_date
           OR end_date BETWEEN p_revision_start_date AND p_revision_end_date
           OR (
                    start_date < p_revision_start_date
                AND end_date > p_revision_end_date
              )
         );
  --
  CURSOR c_period IS
  SELECT period_name, start_date, end_date
  FROM   gl_period_statuses
  WHERE  application_id = 101
  AND    set_of_books_id = g_set_of_books_id
  AND    p_revision_start_date BETWEEN start_date AND end_date;
  --
  -- Bug#4675858
  CURSOR c_ParamName
  IS
  SELECT name
  FROM psb_entity
  WHERE entity_id = p_parameter_id ;
  --
BEGIN

  --pd('g_num_dists:' || g_num_dists);
  for c_currdist_rec in c_currdist loop

    l_account_found := FALSE;

    FOR l_dist_index in 1..g_num_dists LOOP

      IF (     g_dists(l_dist_index).ccid = c_currdist_rec.code_combination_id
           AND (
                    g_dists(l_dist_index).start_date BETWEEN
                    c_currdist_rec.start_date AND c_currdist_rec.end_date
                 OR g_dists(l_dist_index).end_date BETWEEN
                    c_currdist_rec.start_date AND c_currdist_rec.end_date
                 OR (
                    g_dists(l_dist_index).start_date < c_currdist_rec.start_date
                    AND g_dists(l_dist_index).end_date > c_currdist_rec.end_date
                    )
               )
         )
      THEN
        l_account_found := TRUE;
        g_num_revaccts := g_num_revaccts + 1;
        g_revaccts(g_num_revaccts).ccid := c_currdist_rec.code_combination_id;

        /* Bug No 2141915 Start */
        /* Added OR condition for Bug 2896687 */
        if nvl(g_dists(l_dist_index).amount, 0) <> 0
           OR p_zero_revised_fte then
          --
          g_revaccts(g_num_revaccts).amount := g_dists(l_dist_index).amount -
            Prorate_Ratio( p_original_amount     => c_currdist_rec.amount,
                           p_original_start_date => c_currdist_rec.start_date,
                           p_original_end_date   => c_currdist_rec.end_date,
                           p_new_start_date      => p_revision_start_date,
                           p_new_end_date        => p_revision_end_date ) ;
          --
        else
          g_revaccts(g_num_revaccts).amount :=
            Prorate_Ratio ( p_original_amount     => c_currdist_rec.amount,
                            p_original_start_date => c_currdist_rec.start_date,
                            p_original_end_date   => c_currdist_rec.end_date,
                            p_new_start_date      => p_revision_start_date,
                            p_new_end_date        => p_revision_end_date ) ;
        end if;
        /* Bug No 2141915 End */
        g_dists(l_dist_index).calc_rev := TRUE;
      end if;

    END LOOP;

    -- account not in current distribution; need to reverse them
    if not l_account_found then
      --
      g_num_revaccts := g_num_revaccts + 1;
      g_revaccts(g_num_revaccts).ccid := c_currdist_rec.code_combination_id;
      g_revaccts(g_num_revaccts).amount := -1 *
        Prorate_Ratio ( p_original_amount     => c_currdist_rec.amount,
                        p_original_start_date => c_currdist_rec.start_date,
                        p_original_end_date   => c_currdist_rec.end_date,
                        p_new_start_date      => p_revision_start_date,
                        p_new_end_date        => p_revision_end_date ) ;
      --
    end if;

  end loop;

  -- now find out which accounts in g_dist are new; add as is
  for l_dist_index in 1..g_num_dists loop
    if not g_dists(l_dist_index).calc_rev then
      --
      g_num_revaccts := g_num_revaccts + 1;
      g_revaccts(g_num_revaccts).ccid := g_dists(l_dist_index).ccid;
      g_revaccts(g_num_revaccts).amount := nvl(g_dists(l_dist_index).amount, 0);
      --
    end if;

  end loop;

  -- update fte values in the budget revisions table
  for l_fte_index in 1..g_num_fte_assignments loop

    PSB_POSITION_CONTROL_PVT.Modify_Position_FTE
    ( p_api_version => 1.0,
      p_return_status => l_return_status,
      p_msg_count => l_msg_count,
      p_msg_data => l_msg_data,
      p_position_id => p_position_id,
      p_hr_budget_id => p_hr_budget_id,
      p_budget_revision_id => p_budget_revision_id,
      p_base_line_version => null,
      p_start_date => g_fte_assignments(l_fte_index).start_date,
      p_end_date => g_fte_assignments(l_fte_index).end_date,
      p_fte => g_fte_assignments(l_fte_index).fte
    ) ;
    --
    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;
    --

    if ((p_mass_revision) or (g_new_position)) then
    begin

      Create_Revision_Positions
            (p_api_version => 1.0,
             p_return_status => l_return_status,
             p_msg_count => l_msg_count,
             p_msg_data => l_msg_data,
             p_budget_revision_id => p_budget_revision_id,
             p_budget_revision_pos_line_id => l_budget_rev_pos_line_id,
             p_position_id => p_position_id,
             p_budget_group_id => PSB_WS_POS1.g_salary_budget_group_id,
             p_effective_start_date => p_revision_start_date,
             p_effective_end_date => p_revision_end_date,
             p_revision_type => null,
             p_revision_value_type => null,
             p_revision_value => null,
             p_note_id => null,
             p_freeze_flag => 'N',
             p_view_line_flag => 'Y');

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
        raise FND_API.G_EXC_ERROR;
      end if;

    end;
    end if;

  end loop;

  for l_cost_index in 1..g_num_costs loop

    PSB_POSITION_CONTROL_PVT.Modify_Position_Costs
       (p_api_version => 1.0,
        p_return_status => l_return_status,
        p_msg_count => l_msg_count,
        p_msg_data => l_msg_data,
        p_position_id => p_position_id,
        p_hr_budget_id => p_hr_budget_id,
        p_pay_element_id => g_costs(l_cost_index).pay_element_id,
        p_budget_revision_id => p_budget_revision_id,
        p_base_line_version => null,
        p_start_date => g_costs(l_cost_index).start_date,
        p_end_date => g_costs(l_cost_index).end_date,
        p_currency_code => g_costs(l_cost_index).currency_code,
        p_element_cost => g_costs(l_cost_index).element_cost);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end loop;

  for l_dist_index in 1..g_num_dists loop

    PSB_POSITION_CONTROL_PVT.Modify_Position_Accounts
       (p_api_version => 1.0,
        p_return_status => l_return_status,
        p_msg_count => l_msg_count,
        p_msg_data => l_msg_data,
        p_position_id => p_position_id,
        p_hr_budget_id => p_hr_budget_id,
        p_budget_revision_id => p_budget_revision_id,
        p_budget_group_id => g_dists(l_dist_index).budget_group_id,
        p_base_line_version => null,
        p_start_date => g_dists(l_dist_index).start_date,
        p_end_date => g_dists(l_dist_index).end_date,
        p_code_combination_id => g_dists(l_dist_index).ccid,
        p_currency_code => g_dists(l_dist_index).currency_code,
        p_amount => g_dists(l_dist_index).amount);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end loop;

  for c_period_rec in c_period loop
    l_gl_period_name := c_period_rec.period_name;
    l_start_date  := c_period_rec.start_date;
    l_end_date  := c_period_rec.end_date;
  end loop;

  for l_revacct_index in 1..g_num_revaccts loop

    l_gl_budget_version_id := null;
    l_budget_rev_acct_line_id := null;

    PSB_GL_BUDGET_PVT.Find_GL_Budget
       (p_api_version => 1.0,
        p_return_status => l_return_status,
        p_msg_count => l_msg_count,
        p_msg_data => l_msg_data,
        p_gl_budget_set_id => g_gl_budget_set_id,
        p_code_combination_id => g_revaccts(l_revacct_index).ccid,
        p_start_date => l_start_date,
        p_dual_posting_type => 'A',
        p_gl_budget_version_id => l_gl_budget_version_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    if l_gl_budget_version_id is null then
    begin

      if g_permanent_revision = 'N' then
      begin

        PSB_GL_BUDGET_PVT.Find_GL_Budget
         (p_api_version => 1.0,
          p_return_status => l_return_status,
          p_msg_count => l_msg_count,
          p_msg_data => l_msg_data,
          p_gl_budget_set_id => g_gl_budget_set_id,
          p_code_combination_id => g_revaccts(l_revacct_index).ccid,
          p_start_date => l_start_date,
          p_gl_budget_version_id => l_gl_budget_version_id);

       if l_return_status <> FND_API.G_RET_STS_SUCCESS then
         raise FND_API.G_EXC_ERROR;
       end if;

      end;
      end if;

    end;
    end if;

    l_revision_amount := g_revaccts(l_revacct_index).amount;
    if l_revision_amount < 0 then
       l_revision_type := 'D';
       l_revision_amount := abs(l_revision_amount);
    else
       l_revision_type := 'I';
    end if;

     l_rounded_amount := Get_Rounded_Amount(g_func_currency,l_revision_amount);

    if ((l_rounded_amount <> 0) or ((l_rounded_amount = 0) and (g_create_zero_bal = 'Y'))) then
    begin

      Create_Revision_Accounts
            (p_api_version                  => 1.0,
             p_return_status              => l_return_status,
             p_msg_count                    => l_msg_count,
             p_msg_data                   => l_msg_data,
             p_budget_revision_id           => p_budget_revision_id,
             p_budget_revision_acct_line_id => l_budget_rev_acct_line_id,
             p_code_combination_id          => g_revaccts(l_revacct_index).ccid,
             p_budget_group_id              => PSB_WS_POS1.g_salary_budget_group_id,
             p_gl_period_name               => l_gl_period_name,
             p_gl_budget_version_id         => l_gl_budget_version_id,
             p_position_id                  => p_position_id,
             p_currency_code                => g_func_currency,
             p_budget_balance               => null,
             p_revision_type                => l_revision_type,
             p_revision_value_type          => 'A',
             p_revision_amount              => l_rounded_amount,
             p_note_id                      => null,
             p_funds_control_timestamp      => null,
             p_funds_status_code            => null,
             p_funds_result_code            => null,
             p_freeze_flag                  => 'N',
             p_view_line_flag               => 'Y');

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
        raise FND_API.G_EXC_ERROR;
      end if;

      -- Bug#4675858 Start
      -- Added note call for Revise Elements Projections.
      IF ( g_elem_projection )
      THEN
        -- Get parameter name
        FOR c_ParamName_Rec IN c_ParamName
        LOOP
          l_note_parameter_name := c_ParamName_Rec.name ;
        END LOOP ;
        --
        -- Get position line id for corresponding position.
        SELECT
          budget_revision_pos_line_id
        INTO
	  l_pos_line_id
        FROM
	  psb_budget_revision_position_v
        WHERE
          budget_revision_id = p_budget_revision_id
          AND position_id    = p_position_id ;
        --
        FND_MESSAGE.Set_Name('PSB', 'PSB_PARAMETER_NOTE_CREATION') ;
        FND_MESSAGE.Set_Token('NAME', l_note_parameter_name) ;
        FND_MESSAGE.Set_Token('DATE', sysdate) ;

        l_note := FND_MESSAGE.Get ;

        Create_Note
        ( p_return_status    => l_return_status
        , p_account_line_id  => NULL
        , p_position_line_id => l_pos_line_id
        , p_note             => l_note
        , p_flex_code        => g_flex_code
        , p_cc_id            => g_revaccts(l_revacct_index).ccid
        ) ;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
          RAISE FND_API.G_EXC_ERROR ;
        END IF ;
      END IF ;
      -- Bug#4675858 End

    end;
    end if;

  end loop;

  if not p_mass_revision then
  begin

    Create_Summary_Position_Line
          (p_return_status => l_return_status,
           p_budget_revision_id => p_budget_revision_id,
           p_currency_code => g_func_currency,
           p_gl_period_name => l_gl_period_name);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

End Update_Position_Cost;

/* ----------------------------------------------------------------------- */

PROCEDURE Calculate_Position_Cost
( p_api_version         IN         NUMBER
, p_init_msg_list       IN         VARCHAR2 := FND_API.G_FALSE
, p_commit              IN         VARCHAR2 := FND_API.G_FALSE
, p_validation_level    IN         NUMBER   := FND_API.G_VALID_LEVEL_FULL
, p_msg_count           OUT NOCOPY NUMBER
, p_msg_data            OUT NOCOPY VARCHAR2
, p_return_status       OUT NOCOPY VARCHAR2
, p_mass_revision       IN         BOOLEAN  := FALSE
, p_budget_revision_id  IN         NUMBER
, p_position_id         IN         NUMBER
, p_revision_start_date IN         DATE
, p_revision_end_date   IN         DATE
, p_parameter_id        IN         NUMBER DEFAULT NULL -- Bug#4675858
)
IS

   l_api_name          CONSTANT VARCHAR2(30) := 'Calculate_Position_Cost';
   l_api_version       CONSTANT NUMBER       := 1.0;

   l_start_date                 DATE;
   l_end_date                   DATE;

   l_element_found              BOOLEAN;
   l_fte_found                  BOOLEAN := FALSE;
   l_position_name              VARCHAR2(240);
   l_position_start_date        DATE;
   l_position_end_date          DATE;
   --UTF8 changes for Bug No : 2615261
   l_attribute_value            psb_attribute_values.attribute_value%TYPE;

   l_msg_count                  NUMBER;
   l_msg_data                   VARCHAR2(2000);
   l_original_fte               NUMBER;
   l_current_fte                NUMBER;
   l_revised_fte                NUMBER;
   -- Added l_zero_revised_fte for bug 2896687
   l_zero_revised_fte           BOOLEAN := FALSE;

   l_return_status              VARCHAR2(1);
   -- bug no 3439168
   l_acct_line_cnt              NUMBER;

   cursor c_Positions is
     select position_id,
            name,
            effective_start_date,
            effective_end_date
       from PSB_POSITIONS
      where position_id = p_position_id;

--commented the cursor for 6004284
/*   cursor c_Element_Assignments is
     select worksheet_id,
	    pay_element_id,
	    pay_element_option_id,
	    pay_basis,
	    element_value_type,
	    element_value,
	    effective_start_date,
	    effective_end_date
       from PSB_POSITION_ASSIGNMENTS
      where ((worksheet_id = g_global_budget_revision_id) or (worksheet_id is null))
	and currency_code = g_func_currency
	and assignment_type = 'ELEMENT'
	and (((effective_start_date <= l_end_date)
	  and (effective_end_date is null))
	  or ((effective_start_date between l_start_date and l_end_date)
	   or (effective_end_date between l_start_date and l_end_date)
	  or ((effective_start_date < l_start_date)
	  and (effective_end_date > l_end_date))))
	and position_id = p_position_id
      order by effective_start_date, effective_end_date, element_value desc;
 */ --Bug:6004284

/* Bug:6004284:start*/
/*cursor added for picking the assignment records from worksheet level.
  DE level records will be picked only when worksheet level records are
  not available.
 */

CURSOR c_Element_Assignments IS
select ppa.worksheet_id,
	     ppa.pay_element_id,
	     ppa.pay_element_option_id,
	     ppa.pay_basis,
	     ppa.element_value_type,
	     ppa.element_value,
	     ppa.effective_start_date,
	     ppa.effective_end_date
  from psb_position_assignments ppa,
       psb_pay_elements ppe,
       psb_pay_element_options ppeo
 where ppa.currency_code = g_func_currency
   and ppa.pay_element_id = ppe.pay_element_id
   and ppa.pay_element_option_id = ppeo.pay_element_option_id(+)
   and ppa.assignment_type = 'ELEMENT'
   and (((ppa.effective_start_date <= l_end_date)
   and (ppa.effective_end_date is null))
    or ((ppa.effective_start_date between l_start_date and l_end_date)
	  or (ppa.effective_end_date between l_start_date and l_end_date)
	  or ((ppa.effective_start_date < l_start_date)
	 and (ppa.effective_end_date > l_end_date))))
   and ppa.position_id = p_position_id
   and ((ppa.worksheet_id=g_global_budget_revision_id or ((ppa.worksheet_id is null
   and not exists
      (select 1
         from psb_position_assignments ppa1
        where ppa1.pay_element_id = ppa.pay_element_id
          and ppa1.position_id = p_position_id
          and ppa1.worksheet_id = g_global_budget_revision_id
          and ((ppa1.effective_start_date between
               ppa.effective_start_date and nvl(ppa.effective_end_date,ppa1.effective_start_date)) or
              (ppa.effective_start_date between
              ppa1.effective_start_date and nvl(ppa1.effective_end_date,ppa.effective_start_date))))))))
 order by effective_start_date, effective_end_date, element_value desc;

/*End of addition for bug:6004284*/

   cursor c_Element_Rates is
     select a.worksheet_id,
            a.pay_element_id,
            a.pay_element_option_id,
            a.pay_basis,
            a.element_value_type,
            a.element_value,
            a.formula_id,
            a.effective_start_date,
            a.effective_end_date
       from PSB_PAY_ELEMENT_RATES a,
            PSB_PAY_ELEMENTS b
      where (a.worksheet_id is null or a.worksheet_id = g_global_budget_revision_id)
        and a.currency_code = g_func_currency
        and exists
           (select 1
              from PSB_POSITION_ASSIGNMENTS c
             where nvl(c.pay_element_option_id, FND_API.G_MISS_NUM) = nvl(a.pay_element_option_id, FND_API.G_MISS_NUM)
               and ((c.worksheet_id = g_global_budget_revision_id) or (c.worksheet_id is null))
               and c.currency_code = g_func_currency
               and (((c.effective_start_date <= l_end_date)
                 and (c.effective_end_date is null))
                 or ((c.effective_start_date between l_start_date and l_end_date)
                  or (c.effective_end_date between l_start_date and l_end_date)
                 or ((c.effective_start_date < l_start_date)
                 and (c.effective_end_date > l_end_date))))
               and c.pay_element_id = a.pay_element_id
               and c.position_id = p_position_id)
        and (((a.effective_start_date <= l_end_date)
          and (a.effective_end_date is null))
          or ((a.effective_start_date between l_start_date and l_end_date)
           or (a.effective_end_date between l_start_date and l_end_date)
          or ((a.effective_start_date < l_start_date)
          and (a.effective_end_date > l_end_date))))
        and a.pay_element_id = b.pay_element_id
        and b.business_group_id = g_business_group_id
        and b.data_extract_id = g_data_extract_id
      order by a.worksheet_id, a.effective_start_date, a.effective_end_date, a.element_value desc;

/*Bug:6004284:commented the cursor*/
/*  cursor c_Attribute_Assignments is
    select worksheet_id,
	   effective_start_date,
	   effective_end_date,
	   attribute_id,
           -- Fixed bug # 3683644
	   FND_NUMBER.canonical_to_number(attribute_value) attribute_value,
	   attribute_value_id
      from PSB_POSITION_ASSIGNMENTS
     where attribute_id in (PSB_WS_POS1.g_default_wklyhrs_id, PSB_WS_POS1.g_fte_id)
       and (( worksheet_id = g_global_budget_revision_id) or (worksheet_id is null))
       and assignment_type = 'ATTRIBUTE'
       and (((effective_start_date <= l_end_date)
	 and (effective_end_date is null))
	 or ((effective_start_date between l_start_date and l_end_date)
	  or (effective_end_date between l_start_date and l_end_date)
	 or ((effective_start_date < l_start_date)
	 and (effective_end_date > l_end_date))))
       and position_id = p_position_id
     order by worksheet_id,
              effective_start_date,
              effective_end_date,
              FND_NUMBER.canonical_to_number(attribute_value) desc; -- Fixed bug # 3683644
*/--Bug:6004284

/*Bug:6004284:start*/

cursor c_Attribute_Assignments is
    select worksheet_id,
	   effective_start_date,
	   effective_end_date,
	   attribute_id,
           -- Fixed bug # 3683644
	   FND_NUMBER.canonical_to_number(attribute_value) attribute_value,
	   attribute_value_id
      from PSB_POSITION_ASSIGNMENTS ppa
     where attribute_id in (PSB_WS_POS1.g_default_wklyhrs_id, PSB_WS_POS1.g_fte_id)
       and assignment_type = 'ATTRIBUTE'
       and (((effective_start_date <= l_end_date)
	 and (effective_end_date is null))
	 or ((effective_start_date between l_start_date and l_end_date)
	  or (effective_end_date between l_start_date and l_end_date)
	 or ((effective_start_date < l_start_date)
	 and (effective_end_date > l_end_date))))
   and position_id = p_position_id
   and ((ppa.worksheet_id=g_global_budget_revision_id or ((ppa.worksheet_id is null
   and not exists
      (select 1
         from psb_position_assignments ppa1
        where ppa1.attribute_id = ppa.attribute_id
          and ppa1.position_id = p_position_id
          and ppa1.worksheet_id = g_global_budget_revision_id
          and ((ppa1.effective_start_date between
               ppa.effective_start_date
               and nvl(ppa.effective_end_date,ppa1.effective_start_date)) or
              (ppa.effective_start_date between
             ppa1.effective_start_date
             and nvl(ppa1.effective_end_date,ppa.effective_start_date))))))))
 order by effective_start_date, effective_end_date,
          FND_NUMBER.canonical_to_number(attribute_value) desc;

/*Bug:6004284:end*/

  cursor c_fte is
    select brp.revision_type, brp.revision_value_type, brp.revision_value, brp.effective_start_date, brp.effective_end_date
      from PSB_BUDGET_REVISION_POSITIONS brp, PSB_BUDGET_REVISION_POS_LINES brpl
     where brp.position_id = p_position_id
       and ((effective_start_date between p_revision_start_date and p_revision_end_date)
         or (effective_end_date between p_revision_start_date and p_revision_end_date)
         or ((effective_start_date < p_revision_start_date)
         and (effective_end_date > p_revision_end_date)))
       and brpl.budget_revision_id = p_budget_revision_id
       and brpl.budget_revision_pos_line_id = brp.budget_revision_pos_line_id
       and brp.revision_value is not null;

  cursor c_current_fte is
    select start_date, end_date, fte
      from PSB_POSITION_FTE
     where position_id = p_position_id
       and nvl(hr_budget_id, -1) = nvl(g_hr_budget_id, -1)
       and base_line_version = 'C'
       and ((start_date between p_revision_start_date and p_revision_end_date)
         or (end_date between p_revision_start_date and p_revision_end_date)
         or ((start_date < p_revision_start_date)
         and (end_date > p_revision_end_date)));

BEGIN

 -- Standard call to check for call compatibility

  if not FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- initialize this variable to track if this procedure is invoked when creating a new position
  g_new_position := FALSE;
  g_revised_position := FALSE;

  /* bug no 3439168 */
-- check if the distribution table has been updated
  IF g_last_update_flag_tbl.exists (p_position_id) AND
     g_last_update_flag_tbl (p_position_id) = 1 THEN

    FOR l_acc_line_rec IN
    (SELECT COUNT(1) acct_line_cnt
     FROM psb_budget_revision_accounts
     WHERE budgeT_revision_acct_line_id
     IN (SELECT budget_revision_Acct_line_id
         FROM psb_budget_revision_lines
         WHERE budget_revision_id = p_budget_revision_id)
         AND position_id = p_position_id)
    LOOP
      l_acct_line_cnt := l_acc_line_rec.acct_line_cnt;
    END LOOP;

    -- Call reverse position accounts procedure
    -- to ensure proper account distributions
    IF l_acct_line_cnt > 0 THEN
      Reverse_Position_Accounts
      ( p_return_status         => l_return_status,
        p_budget_revision_id    => p_budget_revision_id,
        p_position_id           => p_position_id,
        p_effective_start_date  => p_revision_start_date,
        p_effective_end_date    => p_revision_end_date
      );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    -- reset the status of the position id back to 0
    g_last_update_flag_tbl(p_position_id) := 0;
  END IF;
  /* bug no 3439168 */


  Cache_Revision_Variables
       (p_return_status => l_return_status,
        p_budget_revision_id => p_budget_revision_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;


  for c_Positions_Rec in c_Positions loop
    l_position_name := c_Positions_Rec.name;
    l_position_start_date := c_Positions_Rec.effective_start_date;
    l_position_end_date := c_Positions_Rec.effective_end_date;
  end loop;

  l_start_date := greatest(p_revision_start_date, l_position_start_date);
  l_end_date := least(p_revision_end_date,nvl(l_position_end_date, p_revision_end_date));

  Initialize_Revisions;

  Cache_Salary_Dist
       (p_return_status => l_return_status,
        p_budget_revision_id => p_budget_revision_id,
        p_position_id => p_position_id,
        p_position_name => l_position_name,
        p_start_date => l_start_date,
        p_end_date => l_end_date);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  Cache_Elements
      (p_return_status     => l_return_status,
       p_start_date        => l_start_date,
       p_end_date          => l_end_date);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  for c_Element_Assignments_Rec in c_Element_Assignments loop

    g_num_elem_assignments := g_num_elem_assignments + 1;
    g_elem_assignments(g_num_elem_assignments).budget_revision_id := c_Element_Assignments_Rec.worksheet_id;
    g_elem_assignments(g_num_elem_assignments).start_date := c_Element_Assignments_Rec.effective_start_date;
    g_elem_assignments(g_num_elem_assignments).end_date := c_Element_Assignments_Rec.effective_end_date;
    g_elem_assignments(g_num_elem_assignments).pay_element_id := c_Element_Assignments_Rec.pay_element_id;
    g_elem_assignments(g_num_elem_assignments).pay_element_option_id := c_Element_Assignments_Rec.pay_element_option_id;
    g_elem_assignments(g_num_elem_assignments).pay_basis := c_Element_Assignments_Rec.pay_basis;
    g_elem_assignments(g_num_elem_assignments).element_value_type := c_Element_Assignments_Rec.element_value_type;
    g_elem_assignments(g_num_elem_assignments).element_value := c_Element_Assignments_Rec.element_value;
    g_elem_assignments(g_num_elem_assignments).use_in_calc := FALSE;

  end loop;

  for l_element_index in 1..PSB_WS_POS1.g_num_elements loop

    l_element_found := FALSE;

    for l_elemassign_index in 1..g_num_elem_assignments loop

      if ((g_elem_assignments(l_elemassign_index).pay_element_id = PSB_WS_POS1.g_elements(l_element_index).pay_element_id) and
          (g_elem_assignments(l_elemassign_index).budget_revision_id is not null)) then
      begin
        l_element_found := TRUE;
        g_revised_position := TRUE;
        g_elem_assignments(l_elemassign_index).use_in_calc := TRUE;
      end;
      end if;

    end loop;

    if not l_element_found then
    begin

      for l_elemassign_index in 1..g_num_elem_assignments loop

        if ((g_elem_assignments(l_elemassign_index).pay_element_id = PSB_WS_POS1.g_elements(l_element_index).pay_element_id) and
            (g_elem_assignments(l_elemassign_index).budget_revision_id is null)) then
          g_elem_assignments(l_elemassign_index).use_in_calc := TRUE;
        end if;

      end loop;

    end;
    end if;

  end loop;

  for c_Element_Rates_Rec in c_Element_Rates loop

    g_num_elem_rates := g_num_elem_rates + 1;

    g_elem_rates(g_num_elem_rates).budget_revision_id := c_Element_Rates_Rec.worksheet_id;

    if c_Element_Rates_Rec.worksheet_id is not null then
      g_revised_position := TRUE;
    end if;

    g_elem_rates(g_num_elem_rates).start_date := c_Element_Rates_Rec.effective_start_date;
    g_elem_rates(g_num_elem_rates).end_date := c_Element_Rates_Rec.effective_end_date;
    g_elem_rates(g_num_elem_rates).pay_element_id := c_Element_Rates_Rec.pay_element_id;
    g_elem_rates(g_num_elem_rates).pay_element_option_id := c_Element_Rates_Rec.pay_element_option_id;
    g_elem_rates(g_num_elem_rates).pay_basis := c_Element_Rates_Rec.pay_basis;
    g_elem_rates(g_num_elem_rates).element_value_type := c_Element_Rates_Rec.element_value_type;
    g_elem_rates(g_num_elem_rates).element_value := c_Element_Rates_Rec.element_value;
    g_elem_rates(g_num_elem_rates).formula_id := c_Element_Rates_Rec.formula_id;

  end loop;

  for c_fte_rec in c_fte loop

    l_fte_found := TRUE;
    g_num_fte_assignments := g_num_fte_assignments + 1;

    Find_FTE
        (p_api_version => 1.0,
         p_return_status => l_return_status,
         p_msg_count => l_msg_count,
         p_msg_data => l_msg_data,
         p_position_id => p_position_id,
         p_hr_budget_id => g_hr_budget_id,
         p_budget_revision_id => p_budget_revision_id,
         p_revision_type => c_fte_rec.revision_type,
         p_revision_value_type => c_fte_rec.revision_value_type,
         p_revision_value => c_fte_rec.revision_value,
         p_effective_start_date => c_fte_rec.effective_start_date,
         p_effective_end_date => c_fte_rec.effective_end_date,
         p_original_fte => l_original_fte,
         p_current_fte => l_current_fte,
         p_revised_fte => l_revised_fte);

    g_fte_assignments(g_num_fte_assignments).start_date := c_fte_rec.effective_start_date;
    g_fte_assignments(g_num_fte_assignments).end_date := c_fte_rec.effective_end_date;
    g_fte_assignments(g_num_fte_assignments).fte := l_revised_fte;

    -- Added the following IF condition for bug 2896687.
    IF l_revised_fte = 0 THEN
      l_zero_revised_fte := TRUE;
    ELSE
      l_zero_revised_fte := FALSE;
    END IF;
  end loop;

  if not l_fte_found then
  begin

    for c_current_fte_rec in c_current_fte loop
      l_fte_found := TRUE;
      g_num_fte_assignments := g_num_fte_assignments + 1;
      g_fte_assignments(g_num_fte_assignments).start_date := c_current_fte_rec.start_date;
      g_fte_assignments(g_num_fte_assignments).end_date := c_current_fte_rec.end_date;
      g_fte_assignments(g_num_fte_assignments).fte := c_current_fte_rec.fte;

    -- Added the following IF condition for bug 2896687.
    IF c_current_fte_rec.fte = 0 THEN
      l_zero_revised_fte := TRUE;
    ELSE
      l_zero_revised_fte := FALSE;
    END IF;
    end loop;

  end;
  end if;

  for c_Attributes_Rec in c_Attribute_Assignments loop

    l_attribute_value := null;

    if ((c_Attributes_Rec.attribute_value is null) and (c_Attributes_Rec.attribute_value_id is not null)) then
      l_attribute_value := PSB_WS_POS2.Get_Attribute_Value(c_Attributes_Rec.attribute_value_id);
    end if;

    if c_Attributes_Rec.attribute_id = PSB_WS_POS1.g_default_wklyhrs_id then
    begin
      g_num_wkh_assignments := g_num_wkh_assignments + 1;
      g_wkh_assignments(g_num_wkh_assignments).start_date := c_Attributes_Rec.effective_start_date;
      g_wkh_assignments(g_num_wkh_assignments).end_date := c_Attributes_Rec.effective_end_date;
      g_wkh_assignments(g_num_wkh_assignments).default_weekly_hours := nvl(c_Attributes_Rec.attribute_value, l_attribute_value);
    end;
    elsif ((c_Attributes_Rec.attribute_id = PSB_WS_POS1.g_fte_id) and not (l_fte_found)) then
    begin
      g_new_position := TRUE;
      g_num_fte_assignments := g_num_fte_assignments + 1;
      g_fte_assignments(g_num_fte_assignments).start_date := c_Attributes_Rec.effective_start_date;
      g_fte_assignments(g_num_fte_assignments).end_date := nvl(c_Attributes_Rec.effective_end_date, l_end_date);
      g_fte_assignments(g_num_fte_assignments).fte := nvl(c_Attributes_Rec.attribute_value, l_attribute_value);
    end;
    end if;

  end loop;

  if g_num_fte_assignments = 0 then
    g_new_position := TRUE;
    g_num_fte_assignments := g_num_fte_assignments + 1;
    g_fte_assignments(g_num_fte_assignments).start_date := p_revision_start_date;
    g_fte_assignments(g_num_fte_assignments).end_date := p_revision_end_date;
    g_fte_assignments(g_num_fte_assignments).fte := g_default_fte;
  end if;

  if g_num_elem_assignments > 0 then
  begin

    Calculate_Position_Cost_Dates
       (p_return_status => l_return_status,
        p_position_id => p_position_id,
        p_position_name => l_position_name,
        p_revision_start_date => l_start_date,
        p_revision_end_date => l_end_date);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    Distribute_Position_Cost
           (p_return_status => l_return_status,
            p_position_id => p_position_id,
            p_revision_start_date => l_start_date,
            p_revision_end_date => l_end_date);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end;
  end if;

  if ((not p_mass_revision) or ((p_mass_revision) and (g_revised_position))) then
  begin

    Update_Position_Cost
    ( p_return_status       => l_return_status
    , p_mass_revision       => p_mass_revision
    , p_position_id         => p_position_id
    , p_hr_budget_id        => g_hr_budget_id
    , p_budget_revision_id  => p_budget_revision_id
    , p_revision_start_date => l_start_date
    , p_revision_end_date   => l_end_date
    -- Added p_zero_revised_fte for bug 2896687
    , p_zero_revised_fte    => l_zero_revised_fte
    , p_parameter_id        => p_parameter_id -- Bug#4675858
    ) ;

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   -- Fix for Bug:3337401
   -- Added call to FND_MSG_PUB.Count_And_Get()

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

End Calculate_Position_Cost;

/* ----------------------------------------------------------------------- */
PROCEDURE Process_Constraint
( p_return_status                 OUT  NOCOPY  VARCHAR2,
  p_constraint_validation_status  OUT  NOCOPY  VARCHAR2,
  p_budget_revision_id            IN   NUMBER,
  p_constraint_id                 IN   NUMBER,
  p_constraint_name               IN   VARCHAR2,
  p_ccid                          IN   NUMBER := FND_API.G_MISS_NUM,
  p_currency_code                 IN   VARCHAR2,
  p_severity_level                IN   NUMBER,
  p_summ_flag                     IN   VARCHAR2
) IS

  cursor c_Formula is
    select step_number, prefix_operator, budget_year_type_id, balance_type, currency_code,
           nvl(amount, 0) amount, postfix_operator,
           segment1, segment2, segment3, segment4, segment5, segment6, segment7, segment8, segment9,
           segment10, segment11, segment12, segment13, segment14, segment15, segment16, segment17, segment18,
           segment19, segment20, segment21, segment22, segment23, segment24, segment25, segment26, segment27,
           segment28, segment29, segment30
      from PSB_CONSTRAINT_FORMULAS
     where constraint_id = p_constraint_id
     order by step_number;

  -- Compute Sum of BR Account Lines (all Account Sets assigned to the Constraint)

  cursor c_SumAll is
    select Sum(decode(a.revision_type,'I',nvl(a.revision_amount, 0),'D',-nvl(a.revision_amount,0))) Sum_Acc
      from PSB_BUDGET_REVISION_LINES b,
           PSB_BUDGET_REVISION_ACCOUNTS a
     where b.budget_revision_id = p_budget_revision_id
       and a.budget_revision_acct_line_id = b.budget_revision_acct_line_id
       and a.currency_code = p_currency_code
       and a.position_id is null
       and exists
          (select 1
             from psb_budget_accounts d,
                  psb_set_relations_v e
            where d.account_position_set_id = e.account_position_set_id
              and d.code_combination_id = a.code_combination_id
              and e.account_or_position_type = 'A'
              and e.constraint_id = p_constraint_id);

  -- Compute sum of BR Account Lines for a Constraint Formula of type 4
  cursor c_Sum (CCID NUMBER) is
    select Sum(decode(a.revision_type,'I',nvl(a.revision_amount, 0),'D',-nvl(a.revision_amount,0))) Sum_Acc
      from PSB_BUDGET_REVISION_ACCOUNTS a,
           PSB_BUDGET_REVISION_LINES b
     where a.code_combination_id = CCID
       and a.currency_code = p_currency_code
       and a.position_id is null
       and b.budget_revision_id = p_budget_revision_id
       and a.budget_revision_acct_line_id = b.budget_revision_acct_line_id;

  cursor c_Original_Balance (CCID NUMBER, Currency VARCHAR2) is
    select sum(budget_balance) original_balance
      from psb_budget_revision_accounts pbra,
           psb_budget_revision_lines pbrl,
           psb_budget_revisions pbr
     where pbra.code_combination_id = CCID
       and pbra.currency_code = Currency
       and pbra.position_id is null
       and pbra.budget_revision_acct_line_id = pbrl.budget_revision_acct_line_id
       and pbrl.budget_revision_id = pbr.budget_revision_id
       and pbr.budget_group_id = g_budget_group_id
       and pbr.base_line_revision = 'Y'
       and pbra.gl_period_name in
          (select period_name
             from gl_period_statuses
            where application_id = 101
              and set_of_books_id = g_set_of_books_id
              and start_date between g_from_date and g_to_date
              and end_date between g_from_date and g_to_date);

  cursor c_Original_Balance_Sum (Currency VARCHAR2) is
    select sum(budget_balance) original_balance
      from psb_budget_revision_accounts pbra,
           psb_budget_revision_lines pbrl,
           psb_budget_revisions pbr
     where pbra.code_combination_id in
          (select d.code_combination_id
             from psb_budget_accounts d,
                  psb_set_relations_v e
            where d.account_position_set_id = e.account_position_set_id
              and d.code_combination_id = pbra.code_combination_id
              and e.account_or_position_type = 'A'
              and e.constraint_id = p_constraint_id)
       and pbra.currency_code = Currency
       and pbra.position_id is null
       and pbra.budget_revision_acct_line_id = pbrl.budget_revision_acct_line_id
       and pbrl.budget_revision_id = pbr.budget_revision_id
       and pbr.budget_group_id = g_budget_group_id
       and pbr.base_line_revision = 'Y'
       and pbra.gl_period_name in
          (select period_name
             from gl_period_statuses
            where application_id = 101
              and set_of_books_id = g_set_of_books_id
              and start_date between g_from_date and g_to_date
              and end_date between g_from_date and g_to_date);

  CURSOR c_Account (CCID NUMBER) IS
    SELECT pbra.gl_budget_version_id,
           pbra.gl_period_name    -- Bug 5148786
      FROM psb_budget_revision_accounts pbra,
           psb_budget_revision_lines pbrl
     WHERE pbra.code_combination_id = CCID
       AND pbra.position_id is null
       AND pbrl.budget_revision_id = p_budget_revision_id
       AND pbrl.budget_revision_acct_line_id = pbra.budget_revision_acct_line_id;

  CURSOR c_Account_Sum is
    SELECT pbra.code_combination_id,
           pbra.gl_budget_version_id,
           pbra.gl_period_name  -- Bug 5148786
      FROM psb_budget_revision_accounts pbra,
           psb_budget_revision_lines pbrl
     WHERE pbra.code_combination_id in
          (select d.code_combination_id
             from psb_budget_accounts d,
                  psb_set_relations_v e
            where d.account_position_set_id = e.account_position_set_id
              and d.code_combination_id = pbra.code_combination_id
              and e.account_or_position_type = 'A'
              and e.constraint_id = p_constraint_id)
       and pbra.position_id is null
       and pbrl.budget_revision_id = p_budget_revision_id
       and pbra.budget_revision_acct_line_id = pbrl.budget_revision_acct_line_id;

  l_first_line       VARCHAR2(1) := FND_API.G_TRUE;

  l_cons_failed      VARCHAR2(1) := FND_API.G_FALSE;
  l_type1            VARCHAR2(1);
  l_type2            VARCHAR2(1);
  l_type3            VARCHAR2(1);
  l_type4            VARCHAR2(1);
  l_type5            VARCHAR2(1);

  l_line_total       NUMBER := 0;
  l_accset_total     NUMBER := 0;
  l_cons_total       NUMBER := 0;
  l_operator         VARCHAR2(2);
  l_description      VARCHAR2(2000) := null;
  l_current_balance  NUMBER;
  l_concat_segments  VARCHAR2(2000);

BEGIN

  -- Parse the Constraint Formula

  for c_Formula_Rec in c_Formula loop

    -- Each Formula Line is of the following types (Type3, Type4, Type5 are applicable for budget revisions) :

    -- Type1: Depends on Account Set Assignments
    --       (Step, Prefix Operator, Postfix Operator, Period, Balance Type, Currency, Amount have values; Account is blank; this is valid only if 'Detailed' flag is set for the Constraint)
    --
    -- Type2: Depends on Account defined in Formula Line
    --       (Step, Prefix Operator, Period, Balance Type, Account, Currency have values; Amount and Postfix Operator are optional; all the Segment Values should be entered if 'Detailed' flag is not set for the Constraint)
    --
    -- Type3: Flat Amount assignment
    --       (Step, Prefix Operator, Amount have values; Period, Balance Type, Account, Currency, Postfix Operator are blank)
    --
    -- Type4: Depends on Account Set Assignments (Detailed Constraint)
    --       (Step, Prefix Operator, Postfix Operator, Balance Type, Currency, Amount have values; Account, Period are blank; this is valid only if 'Detailed' flag is set for the Constraint)
    --
    -- Type5: Depends on Account Set Assignments (Summary Constraint)
    --       (Step, Prefix Operator, Postfix Operator, Balance Type, Currency, Amount have values; Account, Period are blank; this is valid only if 'Detailed' flag is not set for the Constraint)
    --

    l_type1 := FND_API.G_FALSE;
    l_type2 := FND_API.G_FALSE;
    l_type3 := FND_API.G_FALSE;
    l_type4 := FND_API.G_FALSE;
    l_type5 := FND_API.G_FALSE;

    if FND_API.to_Boolean(l_first_line) then

      l_first_line := FND_API.G_FALSE;

      -- Prefix Operator for the 1st line of a Constraint Formula should be either of :
      -- '<=', '>=', '<', '>', '=', '<>'

      if c_Formula_Rec.prefix_operator not in ('<=', '>=', '<', '>', '=', '<>') then
        message_token('CONSTRAINT', p_constraint_name);
        message_token('STEPID', c_Formula_Rec.step_number);
        message_token('OPERATOR', '[<=, >=, <, >, =, <>]');
        add_message('PSB', 'PSB_INVALID_CONS_OPR');
        raise FND_API.G_EXC_ERROR;
      else
        l_operator := c_Formula_Rec.prefix_operator;
      end if;

    else

      -- Prefix Operator for the other lines of a Constraint Formula should be either of :
      -- '+', '-', '*', '/'

      if c_Formula_Rec.prefix_operator not in ('+', '-', '*', '/') then
        message_token('CONSTRAINT', p_constraint_name);
        message_token('STEPID', c_Formula_Rec.step_number);
        message_token('OPERATOR', '[+, -, *, /]');
        add_message('PSB', 'PSB_INVALID_CONS_OPR');
        raise FND_API.G_EXC_ERROR;
      end if;
    end if;

    -- Check Formula Type

    if ((c_Formula_Rec.prefix_operator is not null) and (c_Formula_Rec.postfix_operator is not null) and
        (c_Formula_Rec.budget_year_type_id is not null) and (c_Formula_Rec.balance_type is not null) and
        (c_Formula_Rec.currency_code is not null) and (c_Formula_Rec.amount is not null) and
       ((c_Formula_Rec.segment1 is null) and (c_Formula_Rec.segment2 is null) and (c_Formula_Rec.segment3 is null) and
        (c_Formula_Rec.segment4 is null) and (c_Formula_Rec.segment5 is null) and (c_Formula_Rec.segment6 is null) and
        (c_Formula_Rec.segment7 is null) and (c_Formula_Rec.segment8 is null) and (c_Formula_Rec.segment9 is null) and
        (c_Formula_Rec.segment10 is null) and (c_Formula_Rec.segment11 is null) and (c_Formula_Rec.segment12 is null) and
        (c_Formula_Rec.segment13 is null) and (c_Formula_Rec.segment14 is null) and (c_Formula_Rec.segment15 is null) and
        (c_Formula_Rec.segment16 is null) and (c_Formula_Rec.segment17 is null) and (c_Formula_Rec.segment18 is null) and
        (c_Formula_Rec.segment19 is null) and (c_Formula_Rec.segment20 is null) and (c_Formula_Rec.segment21 is null) and
        (c_Formula_Rec.segment22 is null) and (c_Formula_Rec.segment23 is null) and (c_Formula_Rec.segment24 is null) and
        (c_Formula_Rec.segment25 is null) and (c_Formula_Rec.segment26 is null) and (c_Formula_Rec.segment27 is null) and
        (c_Formula_Rec.segment28 is null) and (c_Formula_Rec.segment29 is null) and (c_Formula_Rec.segment30 is null))) then
    begin

      if FND_API.to_Boolean(p_summ_flag) then
      begin
        message_token('CONSTRAINT', p_constraint_name);
        add_message('PSB', 'PSB_INVALID_CONS_FORMULA');
        raise FND_API.G_EXC_ERROR;
      end;
      else
        l_type1 := FND_API.G_TRUE;
      end if;

    end;
    elsif ((c_Formula_Rec.prefix_operator is not null) and (c_Formula_Rec.budget_year_type_id is not null) and
           (c_Formula_Rec.balance_type is not null) and (c_Formula_Rec.currency_code is not null) and
          ((c_Formula_Rec.segment1 is not null) or (c_Formula_Rec.segment2 is not null) or (c_Formula_Rec.segment3 is not null) or
           (c_Formula_Rec.segment4 is not null) or (c_Formula_Rec.segment5 is not null) or (c_Formula_Rec.segment6 is not null) or
           (c_Formula_Rec.segment7 is not null) or (c_Formula_Rec.segment8 is not null) or (c_Formula_Rec.segment9 is not null) or
           (c_Formula_Rec.segment10 is not null) or (c_Formula_Rec.segment11 is not null) or (c_Formula_Rec.segment12 is not null) or
           (c_Formula_Rec.segment13 is not null) or (c_Formula_Rec.segment14 is not null) or (c_Formula_Rec.segment15 is not null) or
           (c_Formula_Rec.segment16 is not null) or (c_Formula_Rec.segment17 is not null) or (c_Formula_Rec.segment18 is not null) or
           (c_Formula_Rec.segment19 is not null) or (c_Formula_Rec.segment20 is not null) or (c_Formula_Rec.segment21 is not null) or
           (c_Formula_Rec.segment22 is not null) or (c_Formula_Rec.segment23 is not null) or (c_Formula_Rec.segment24 is not null) or
           (c_Formula_Rec.segment25 is not null) or (c_Formula_Rec.segment26 is not null) or (c_Formula_Rec.segment27 is not null) or
           (c_Formula_Rec.segment28 is not null) or (c_Formula_Rec.segment29 is not null) or (c_Formula_Rec.segment30 is not null))) then
    begin
      l_type2 := FND_API.G_TRUE;
    end;
    elsif ((c_Formula_Rec.prefix_operator is not null) and
           (c_Formula_Rec.amount is not null) and
           (c_Formula_Rec.budget_year_type_id is null) and
           (c_Formula_Rec.balance_type is null) and
           (c_Formula_Rec.currency_code is null) and
           (c_Formula_Rec.postfix_operator is null) and
          ((c_Formula_Rec.segment1 is null) and (c_Formula_Rec.segment2 is null) and (c_Formula_Rec.segment3 is null) and
           (c_Formula_Rec.segment4 is null) and (c_Formula_Rec.segment5 is null) and (c_Formula_Rec.segment6 is null) and
           (c_Formula_Rec.segment7 is null) and (c_Formula_Rec.segment8 is null) and (c_Formula_Rec.segment9 is null) and
           (c_Formula_Rec.segment10 is null) and (c_Formula_Rec.segment11 is null) and (c_Formula_Rec.segment12 is null) and
           (c_Formula_Rec.segment13 is null) and (c_Formula_Rec.segment14 is null) and (c_Formula_Rec.segment15 is null) and
           (c_Formula_Rec.segment16 is null) and (c_Formula_Rec.segment17 is null) and (c_Formula_Rec.segment18 is null) and
           (c_Formula_Rec.segment19 is null) and (c_Formula_Rec.segment20 is null) and (c_Formula_Rec.segment21 is null) and
           (c_Formula_Rec.segment22 is null) and (c_Formula_Rec.segment23 is null) and (c_Formula_Rec.segment24 is null) and
           (c_Formula_Rec.segment25 is null) and (c_Formula_Rec.segment26 is null) and (c_Formula_Rec.segment27 is null) and
           (c_Formula_Rec.segment28 is null) and (c_Formula_Rec.segment29 is null) and (c_Formula_Rec.segment30 is null))) then
    begin
      l_type3 := FND_API.G_TRUE;
    end;
    elsif ((c_Formula_Rec.prefix_operator is not null) and (c_Formula_Rec.postfix_operator is not null) and
           (c_Formula_Rec.balance_type in ('O', 'C')) and (c_Formula_Rec.currency_code is not null) and
           (c_Formula_Rec.amount is not null) and (c_Formula_Rec.budget_year_type_id is null) and
           (c_Formula_Rec.segment1 is null) and (c_Formula_Rec.segment2 is null) and
           (c_Formula_Rec.segment3 is null) and (c_Formula_Rec.segment4 is null) and
           (c_Formula_Rec.segment5 is null) and (c_Formula_Rec.segment6 is null) and
           (c_Formula_Rec.segment7 is null) and (c_Formula_Rec.segment8 is null) and
           (c_Formula_Rec.segment9 is null) and (c_Formula_Rec.segment10 is null) and
           (c_Formula_Rec.segment11 is null) and (c_Formula_Rec.segment12 is null) and
           (c_Formula_Rec.segment13 is null) and (c_Formula_Rec.segment14 is null) and
           (c_Formula_Rec.segment15 is null) and (c_Formula_Rec.segment16 is null) and
           (c_Formula_Rec.segment17 is null) and (c_Formula_Rec.segment18 is null) and
           (c_Formula_Rec.segment19 is null) and (c_Formula_Rec.segment20 is null) and
           (c_Formula_Rec.segment21 is null) and (c_Formula_Rec.segment22 is null) and
           (c_Formula_Rec.segment23 is null) and (c_Formula_Rec.segment24 is null) and
           (c_Formula_Rec.segment25 is null) and (c_Formula_Rec.segment26 is null) and
           (c_Formula_Rec.segment27 is null) and (c_Formula_Rec.segment28 is null) and
           (c_Formula_Rec.segment29 is null) and (c_Formula_Rec.segment30 is null)) then
    begin

      if FND_API.to_Boolean(p_summ_flag) then
        l_type5 := FND_API.G_TRUE;
      else
        l_type4 := FND_API.G_TRUE;
      end if;

    end;
    else
    begin
      message_token('CONSTRAINT', p_constraint_name);
      add_message('PSB', 'PSB_INVALID_CONS_FORMULA');
      raise FND_API.G_EXC_ERROR;
    end;
    end if;

    if FND_API.to_Boolean(l_type3) then
      l_line_total := c_Formula_Rec.amount;
    elsif FND_API.to_Boolean(l_type4) then
    begin


      if c_Formula_Rec.balance_type = 'O' then
      begin

        for c_Original_Balance_Rec in c_Original_Balance (p_ccid, c_Formula_Rec.currency_code) loop

          if c_Formula_Rec.postfix_operator = '+' then
            l_line_total := c_Original_Balance_Rec.original_balance + c_Formula_Rec.amount;
          elsif c_Formula_Rec.postfix_operator = '-' then
            l_line_total := c_Original_Balance_Rec.original_balance - c_Formula_Rec.amount;
          elsif c_Formula_Rec.postfix_operator = '*' then
            l_line_total := c_Original_Balance_Rec.original_balance * c_Formula_Rec.amount;
          elsif c_Formula_Rec.postfix_operator = '/' then
          begin

            -- Avoid divide-by-zero error

            if nvl(c_Formula_Rec.amount, 0) = 0 then
              l_line_total := 0;
            else
              l_line_total := c_Original_Balance_Rec.original_balance / c_Formula_Rec.amount;
            end if;

          end;
          else
          begin
            message_token('CONSTRAINT', p_constraint_name);
            add_message('PSB', 'PSB_INVALID_CONS_FORMULA');
            raise FND_API.G_EXC_ERROR;
          end;
          end if;

        end loop;

      end;
      elsif c_Formula_Rec.balance_type = 'C' then
      begin

        l_current_balance := 0;

        for c_Account_Rec in c_Account(p_ccid) loop

          l_current_balance
            := l_current_balance + Get_GL_Balance (p_revision_type => 'R',
                                                   p_balance_type => g_balance_type,
                                                   p_set_of_books_id => g_set_of_books_id,
                                                   p_xbc_enabled_flag => g_budgetary_control,
                                                   p_gl_period_name => c_account_rec.gl_period_name,
                                                   p_gl_budget_version_id => c_Account_Rec.gl_budget_version_id,
                                                   p_currency_code => c_Formula_Rec.currency_code,
                                                   p_code_combination_id => p_ccid);
        end loop;

        if c_Formula_Rec.postfix_operator = '+' then
          l_line_total := l_current_balance + c_Formula_Rec.amount;
        elsif c_Formula_Rec.postfix_operator = '-' then
          l_line_total := l_current_balance - c_Formula_Rec.amount;
        elsif c_Formula_Rec.postfix_operator = '*' then
          l_line_total := l_current_balance * c_Formula_Rec.amount;
        elsif c_Formula_Rec.postfix_operator = '/' then
        begin

          -- Avoid divide-by-zero error

          if nvl(c_Formula_Rec.amount, 0) = 0 then
            l_line_total := 0;
          else
            l_line_total := l_current_balance / c_Formula_Rec.amount;
          end if;

        end;
        else
        begin
          message_token('CONSTRAINT', p_constraint_name);
          add_message('PSB', 'PSB_INVALID_CONS_FORMULA');
          raise FND_API.G_EXC_ERROR;
        end;
        end if;

      end;
      end if;

    end;
    elsif FND_API.to_Boolean(l_type5) then
    begin

      if c_Formula_Rec.balance_type = 'O' then
      begin

        for c_Original_Balance_Rec in c_Original_Balance_Sum (c_Formula_Rec.currency_code) loop

          if c_Formula_Rec.postfix_operator = '+' then
            l_line_total := c_Original_Balance_Rec.original_balance + c_Formula_Rec.amount;
          elsif c_Formula_Rec.postfix_operator = '-' then
            l_line_total := c_Original_Balance_Rec.original_balance - c_Formula_Rec.amount;
          elsif c_Formula_Rec.postfix_operator = '*' then
            l_line_total := c_Original_Balance_Rec.original_balance * c_Formula_Rec.amount;
          elsif c_Formula_Rec.postfix_operator = '/' then
          begin

            -- Avoid divide-by-zero error

            if nvl(c_Formula_Rec.amount, 0) = 0 then
              l_line_total := 0;
            else
              l_line_total := c_Original_Balance_Rec.original_balance / c_Formula_Rec.amount;
            end if;

          end;
          else
          begin
            message_token('CONSTRAINT', p_constraint_name);
            add_message('PSB', 'PSB_INVALID_CONS_FORMULA');
            raise FND_API.G_EXC_ERROR;
          end;
          end if;

        end loop;

      end;
      elsif c_Formula_Rec.balance_type = 'C' then
      begin

        l_current_balance := 0;

        for c_Account_Rec in c_Account_Sum loop

          l_current_balance
            := l_current_balance + Get_GL_Balance (p_revision_type => 'R',
                                                   p_balance_type => g_balance_type,
                                                   p_set_of_books_id => g_set_of_books_id,
                                                   p_xbc_enabled_flag => g_budgetary_control,
                                                   p_gl_period_name => c_account_rec.gl_period_name,
                                                   p_gl_budget_version_id => c_Account_Rec.gl_budget_version_id,
                                                   p_currency_code => c_Formula_Rec.currency_code,
                                                   p_code_combination_id => C_Account_Rec.code_combination_id);
       end loop;


        if c_Formula_Rec.postfix_operator = '+' then
          l_line_total := l_current_balance + c_Formula_Rec.amount;
        elsif c_Formula_Rec.postfix_operator = '-' then
          l_line_total := l_current_balance - c_Formula_Rec.amount;
        elsif c_Formula_Rec.postfix_operator = '*' then
          l_line_total := l_current_balance * c_Formula_Rec.amount;
        elsif c_Formula_Rec.postfix_operator = '/' then
        begin

          -- Avoid divide-by-zero error

          if nvl(c_Formula_Rec.amount, 0) = 0 then
            l_line_total := 0;
          else
            l_line_total := l_current_balance / c_Formula_Rec.amount;
          end if;

        end;
        else
        begin
          message_token('CONSTRAINT', p_constraint_name);
          add_message('PSB', 'PSB_INVALID_CONS_FORMULA');
          raise FND_API.G_EXC_ERROR;
        end;
        end if;

      end;
      end if;

    end;
    end if;

    if c_Formula_Rec.prefix_operator in ('=', '<>', '<=', '>=', '<', '>') then
      l_cons_total := l_line_total;
    elsif c_Formula_Rec.prefix_operator = '+' then
      l_cons_total := l_cons_total + l_line_total;
    elsif c_Formula_Rec.prefix_operator = '-' then
      l_cons_total := l_cons_total - l_line_total;
    elsif c_Formula_Rec.prefix_operator = '*' then
      l_cons_total := l_cons_total * l_line_total;
    elsif c_Formula_Rec.prefix_operator = '/' then
    begin

      -- Avoid divide-by-zero error

      if nvl(l_line_total, 0) = 0 then
        l_cons_total := 0;
      else
        l_cons_total := l_cons_total / l_line_total;
      end if;

    end;
    end if;

  end loop;

  -- Compute Sum of Account Sets or CCID assigned to the Constraint

  if not FND_API.to_Boolean(p_summ_flag) then
  begin

    for c_Sum_Rec in c_Sum (p_ccid) loop
      l_accset_total := c_Sum_Rec.Sum_Acc;
    end loop;

  end;
  else
  begin

    for c_SumAll_Rec in c_SumAll loop
      l_accset_total := c_SumAll_Rec.Sum_Acc;
    end loop;

  end;
  end if;

  if l_accset_total is not null then
  begin

    if l_operator = '<=' then

      if l_accset_total <= l_cons_total then
        l_cons_failed := FND_API.G_TRUE;
      end if;

    elsif l_operator = '>=' then

      if l_accset_total >= l_cons_total then
        l_cons_failed := FND_API.G_TRUE;
      end if;

    elsif l_operator = '<' then

      if l_accset_total < l_cons_total then
        l_cons_failed := FND_API.G_TRUE;
      end if;

    elsif l_operator = '>' then

      if l_accset_total > l_cons_total then
        l_cons_failed := FND_API.G_TRUE;
      end if;

    elsif l_operator = '=' then

      if l_accset_total = l_cons_total then
        l_cons_failed := FND_API.G_TRUE;
      end if;

    elsif l_operator = '<>' then

      if l_accset_total <> l_cons_total then
        l_cons_failed := FND_API.G_TRUE;
      end if;

    end if;

    if FND_API.to_Boolean(l_cons_failed) then
    begin

      if nvl(p_severity_level, -1) >= g_constraint_threshold then
        p_constraint_validation_status := 'F';
      else
        p_constraint_validation_status := 'E';
      end if;
/* For Bug No : 1321519 Start */
      message_token('EFFECTIVE_START_DATE', nvl(g_constraint_start_date,g_from_date));
      message_token('EFFECTIVE_END_DATE', nvl(g_constraint_end_date,g_to_date));
      message_token('FIRST_GL_PERIOD_NAME', g_from_date);
      message_token('LAST_GL_PERIOD_NAME', g_to_date);
/* For Bug No : 1321519 End */
      message_token('CONSTRAINT_SET', g_constraint_set_name);
      message_token('THRESHOLD', g_constraint_threshold);
      message_token('CONSTRAINT', p_constraint_name);
      message_token('SEVERITY_LEVEL', p_severity_level);
      message_token('ASSIGNMENT_VALUE', l_accset_total);
      message_token('OPERATOR', l_operator);
      message_token('FORMULA_VALUE', l_cons_total);


      if FND_API.to_Boolean(p_summ_flag) then
        message_token('NAME', p_constraint_name);
      else
      begin

        l_concat_segments := FND_FLEX_EXT.Get_Segs
                                (application_short_name => 'SQLGL',
                                 key_flex_code => 'GL#',
                                 structure_number => g_flex_code,
                                 combination_id => p_ccid);

        message_token('NAME', l_concat_segments);

      end;
      end if;

      add_message('PSB', 'PSB_REV_CONSTRAINT_FAILURE');

      l_description := FND_MSG_PUB.Get
                          (p_encoded => FND_API.G_FALSE);
      FND_MSG_PUB.Delete_Msg;

      -- Constraint Validation failures are logged in PSB_ERROR_MESSAGES and
      -- viewed using a Form

      insert into PSB_ERROR_MESSAGES
                 (Concurrent_Request_ID,
                  Process_ID,
                  Source_Process,
                  Description,
                  Creation_Date,
                  Created_By)
          values (FND_GLOBAL.CONC_REQUEST_ID,
                  p_budget_revision_id,
                  'BUDGET_REVISION',
                  l_description,
                  sysdate,
                  FND_GLOBAL.USER_ID);

    end;
    else
      p_constraint_validation_status := 'S';
    end if;

  end;
  end if;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Process_Constraint;

/* ----------------------------------------------------------------------- */

PROCEDURE Apply_Detailed_Account
( p_return_status                 OUT  NOCOPY  VARCHAR2,
  p_constraint_validation_status  OUT  NOCOPY  VARCHAR2,
  p_budget_revision_id            IN   NUMBER,
  p_constraint_id                 IN   NUMBER,
  p_constraint_name               IN   VARCHAR2,
  p_currency_code                 IN   VARCHAR2,
  p_severity_level                IN   NUMBER
) IS

  l_return_status                 VARCHAR2(1);

  l_cons_validation_status        VARCHAR2(1) := 'S';
  l_detailed_status               VARCHAR2(1);

  -- CCIDs assigned to the Constraint : select CCIDs that also belong to the Budget Group Hierarchy

  cursor c_CCID is
    select a.code_combination_id ccid
      from PSB_BUDGET_ACCOUNTS a,
           PSB_SET_RELATIONS_V b
     where exists
          (select 1
             from PSB_BUDGET_ACCOUNTS c,
                  PSB_SET_RELATIONS_V d
            where c.account_position_set_id = d.account_position_set_id
              and c.code_combination_id = a.code_combination_id
              and d.account_or_position_type = 'A'
              and exists
                 (select 1
                    from psb_budget_groups e
                   where e.budget_group_type = 'R'
                     and e.budget_group_id = d.budget_group_id
                   start with e.budget_group_id = g_budget_group_id
                 connect by prior e.budget_group_id = e.parent_budget_group_id))
       and a.account_position_set_id = b.account_position_set_id
       and b.account_or_position_type = 'A'
       and b.constraint_id = p_constraint_id;

BEGIN

  for c_CCID_Rec in c_CCID loop

    Process_Constraint
           (p_budget_revision_id => p_budget_revision_id,
            p_constraint_id => p_constraint_id,
            p_constraint_name => p_constraint_name,
            p_ccid => c_CCID_Rec.ccid,
            p_currency_code => p_currency_code,
            p_severity_level => p_severity_level,
            p_summ_flag => FND_API.G_FALSE,
            p_constraint_validation_status => l_detailed_status,
            p_return_status => l_return_status);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    if ((l_cons_validation_status = 'S') and
        (l_detailed_status <> 'S')) then
      l_cons_validation_status := l_detailed_status;
    elsif ((l_cons_validation_status = 'E') and
           (l_detailed_status = 'F')) then
      l_cons_validation_status := l_detailed_status;
    end if;

  end loop;

  -- Initialize API return status to success

  p_constraint_validation_status := l_cons_validation_status;
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Apply_Detailed_Account;

/* ----------------------------------------------------------------------- */

PROCEDURE Apply_Account_Constraints
( p_return_status      OUT  NOCOPY  VARCHAR2,
  p_validation_status  OUT  NOCOPY  VARCHAR2,
  p_budget_revision_id IN   NUMBER
) IS

  l_return_status              VARCHAR2(1);

  l_cons_validation_status     VARCHAR2(1);
  l_consset_validation_status  VARCHAR2(1) := 'S';

  cursor c_Constraint is
    select constraint_id,
           name,
           currency_code,
           severity_level,
           effective_start_date,
           effective_end_date,
           constraint_detailed_flag
      from PSB_CONSTRAINT_ASSIGNMENTS_V
     where constraint_type = 'ACCOUNT'
       and constraint_set_id = g_constraint_set_id
       and currency_code     = g_currency_code -- Bug 3029168
     order by severity_level desc;

BEGIN

  for c_Constraint_Rec in c_Constraint loop
  /* ForBug No : 1321519 Start */
    g_constraint_start_date := c_Constraint_Rec.effective_start_date;
    g_constraint_end_date   := c_Constraint_Rec.effective_end_date;
  /* ForBug No : 1321519 End */
    if ((c_Constraint_Rec.constraint_detailed_flag is null) or
        (c_Constraint_Rec.constraint_detailed_flag = 'N')) then
    begin

      Process_Constraint
             (p_budget_revision_id => p_budget_revision_id,
              p_constraint_id => c_Constraint_Rec.constraint_id,
              p_constraint_name => c_Constraint_Rec.name,
              p_currency_code => nvl(c_Constraint_Rec.currency_code, g_func_currency),
              p_severity_level => c_Constraint_Rec.severity_level,
              p_summ_flag => FND_API.G_TRUE,
              p_constraint_validation_status => l_cons_validation_status,
              p_return_status => l_return_status);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
         raise FND_API.G_EXC_ERROR;
      end if;

      -- Assign a proper validation status for the Constraint Set based on the validation
      -- status for the individual Constraints

      if ((l_consset_validation_status = 'S') and
          (l_cons_validation_status <> 'S')) then
        l_consset_validation_status := l_cons_validation_status;
      elsif ((l_consset_validation_status = 'E') and
             (l_cons_validation_status = 'F')) then
        l_consset_validation_status := l_cons_validation_status;
      elsif ((l_consset_validation_status = 'W') and
             (l_cons_validation_status in ('F', 'E'))) then
        l_consset_validation_status := l_cons_validation_status;
      end if;

    end;
    else
    begin

      -- For a Constraint with the detailed flag set, call this procedure which
      -- processes constraints for individual CCIDs. This is to avoid static
      -- binding

      Apply_Detailed_Account
           (p_return_status => l_return_status,
            p_constraint_validation_status => l_cons_validation_status,
            p_budget_revision_id => p_budget_revision_id,
            p_constraint_id => c_Constraint_Rec.constraint_id,
            p_constraint_name => c_Constraint_Rec.name,
            p_currency_code => nvl(c_Constraint_Rec.currency_code, g_func_currency),
            p_severity_level => c_Constraint_Rec.severity_level);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
         raise FND_API.G_EXC_ERROR;
      end if;

      -- Assign a proper validation status for the Constraint Set based on the validation
      -- status for the individual Constraints

      if ((l_consset_validation_status = 'S') and
          (l_cons_validation_status <> 'S')) then
        l_consset_validation_status := l_cons_validation_status;
      elsif ((l_consset_validation_status = 'E') and
             (l_cons_validation_status = 'F')) then
        l_consset_validation_status := l_cons_validation_status;
      elsif ((l_consset_validation_status = 'W') and
             (l_cons_validation_status in ('F', 'E'))) then
        l_consset_validation_status := l_cons_validation_status;
      end if;

    end;
    end if;

  end loop;

  -- Initialize API return status to success

  p_validation_status := l_consset_validation_status;
  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Apply_Account_Constraints;

/* ----------------------------------------------------------------------- */

PROCEDURE Apply_Element_Constraints
( p_return_status       OUT  NOCOPY  VARCHAR2,
  p_budget_revision_id  IN   NUMBER
) IS

  l_return_status       VARCHAR2(1);

  cursor c_Constraint is
    select constraint_id,
           name,
           currency_code,
           severity_level,
           effective_start_date,
           effective_end_date
      from PSB_CONSTRAINT_ASSIGNMENTS_V
     where constraint_type = 'ELEMENT'
       and (((effective_start_date <= g_effective_end_date)
         and (effective_end_date is null))
         or ((effective_start_date between g_effective_start_date and g_effective_end_date)
          or (effective_end_date between g_effective_start_date and g_effective_end_date)
         or ((effective_start_date < g_effective_start_date)
         and (effective_end_date > g_effective_end_date))))
       and constraint_set_id = g_constraint_set_id;

BEGIN

  for c_Constraint_Rec in c_Constraint loop

    PSB_WS_POS3.Process_ElemCons_Detailed
       (p_return_status => l_return_status,
        p_worksheet_id => g_global_budget_revision_id,
        p_data_extract_id => g_data_extract_id,
        p_constraint_id => c_Constraint_Rec.constraint_id,
        p_start_date => c_Constraint_Rec.effective_start_date,
        p_end_date => nvl(c_Constraint_Rec.effective_end_date, g_effective_end_date));

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end loop;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Apply_Element_Constraints;

/* ----------------------------------------------------------------------- */

PROCEDURE Process_PosCons_Step
( p_return_status                 OUT  NOCOPY  VARCHAR2,
  p_constraint_validation_status  OUT  NOCOPY  VARCHAR2,
  p_budget_revision_id            IN   NUMBER,
  p_constraint_id                 IN   NUMBER,
  p_constraint_name               IN   VARCHAR2,
  p_position_id                   IN   NUMBER := FND_API.G_MISS_NUM,
  p_position_name                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_currency_code                 IN   VARCHAR2,
  p_severity_level                IN   NUMBER,
  p_summ_flag                     IN   VARCHAR2,
  p_pay_element_id                IN   NUMBER,
  p_pay_element_option_id         IN   NUMBER,
  p_prefix_operator               IN   VARCHAR2,
  p_element_value_type            IN   VARCHAR2,
  p_element_value                 IN   NUMBER
) IS

  l_cons_failed                   VARCHAR2(1) := FND_API.G_FALSE;

  l_salary_total                  NUMBER := 0;
  l_posset_total                  NUMBER := 0;
  l_cons_total                    NUMBER := 0;

  l_description                   VARCHAR2(2000);

  l_grade_name                    VARCHAR2(80);
  l_grade_step                    NUMBER;

  cursor c_Grade is
    select name grade_name,
           grade_step
      from PSB_PAY_ELEMENT_OPTIONS
     where pay_element_option_id = p_pay_element_option_id;

  cursor c_SalaryNeqAll is
    select a.name position_name,
           b.name,
           b.grade_step
      from PSB_POSITIONS a,
           PSB_PAY_ELEMENT_OPTIONS b,
           PSB_POSITION_ASSIGNMENTS c
     where exists
          (select 1
             from PSB_BUDGET_POSITIONS d,
                  PSB_SET_RELATIONS e
            where d.data_extract_id = g_data_extract_id
              and d.position_id = c.position_id
              and d.account_position_set_id = e.account_position_set_id
              and e.constraint_id = p_constraint_id)
       and a.position_id = c.position_id
       and b.pay_element_option_id = c.pay_element_option_id
       and c.pay_element_option_id <> p_pay_element_option_id
       and ((c.worksheet_id is null) or (c.worksheet_id = p_budget_revision_id))
       and c.pay_element_id = p_pay_element_id;

  cursor c_SalaryNeq is
    select a.name,
           a.grade_step
      from PSB_PAY_ELEMENT_OPTIONS a,
           PSB_POSITION_ASSIGNMENTS b
     where a.pay_element_option_id = b.pay_element_option_id
       and b.pay_element_option_id <> p_pay_element_option_id
       and b.pay_element_id = p_pay_element_id
       and b.position_id = p_position_id;

  cursor c_SumAll is
    select sum(nvl(a.element_cost, 0)) Sum_Elem
      from PSB_POSITION_COSTS a
     where exists
          (select 1
             from PSB_BUDGET_REVISION_POSITIONS c,
                  PSB_BUDGET_REVISION_POS_LINES d,
                  PSB_BUDGET_POSITIONS e,
                  PSB_SET_RELATIONS f
            where d.budget_revision_id = a.budget_revision_id
              and c.budget_revision_pos_line_id = d.budget_revision_pos_line_id
              and d.budget_revision_id = p_budget_revision_id
              and c.position_id = e.position_id
              and e.data_extract_id = g_data_extract_id
              and e.account_position_set_id = f.account_position_set_id
              and f.constraint_id = p_constraint_id)
       and a.currency_code = p_currency_code
       and a.pay_element_id = p_pay_element_id
       and a.budget_revision_id = p_budget_revision_id;

  cursor c_SumAll_Salary is
    select sum(nvl(a.element_cost, 0)) Sum_Elem
      from PSB_POSITION_COSTS a,
           PSB_PAY_ELEMENTS c
     where exists
          (select 1
             from PSB_BUDGET_REVISION_POSITIONS d,
                  PSB_BUDGET_REVISION_POS_LINES e,
                  PSB_BUDGET_POSITIONS f,
                  PSB_SET_RELATIONS g
            where e.budget_revision_id = a.budget_revision_id
              and d.budget_revision_pos_line_id = e.budget_revision_pos_line_id
              and e.budget_revision_id = p_budget_revision_id
              and d.position_id = f.position_id
              and f.data_extract_id = g_data_extract_id
              and f.account_position_set_id = g.account_position_set_id
              and g.constraint_id = p_constraint_id)
       and a.currency_code = p_currency_code
       and a.pay_element_id = c.pay_element_id
       and a.budget_revision_id = p_budget_revision_id
       and c.processing_type = 'R'
       and c.salary_flag = 'Y'
       and c.business_group_id = g_business_group_id
       and c.data_extract_id = g_data_extract_id;

  cursor c_Sum is
    select sum(nvl(a.element_cost, 0)) Sum_Elem
      from PSB_POSITION_COSTS a
     where a.currency_code = p_currency_code
       and a.pay_element_id = p_pay_element_id
       and a.position_id = p_position_id
       and a.budget_revision_id = p_budget_revision_id;

  cursor c_Sum_Salary is
    select sum(nvl(a.element_cost, 0)) Sum_Elem
      from PSB_POSITION_COSTS a,
           PSB_PAY_ELEMENTS c
     where a.currency_code = p_currency_code
       and a.pay_element_id = c.pay_element_id
       and a.position_id = p_position_id
       and a.budget_revision_id = p_budget_revision_id
       and c.processing_type = 'R'
       and c.salary_flag = 'Y'
       and c.business_group_id = g_business_group_id
       and c.data_extract_id = g_data_extract_id;


BEGIN

  if not FND_API.to_Boolean(p_summ_flag) then
  begin

    if p_pay_element_option_id is null then
    begin

      for c_Sum_Rec in c_Sum loop
        l_posset_total := c_Sum_Rec.Sum_Elem;
      end loop;

      if p_element_value_type = 'PS' then
      begin

        for c_Sum_Salary_Rec in c_Sum_Salary loop
          l_salary_total := c_Sum_Salary_Rec.Sum_Elem;
        end loop;

      end;
      end if;

    end;
    end if;

    if p_pay_element_option_id is not null then
    begin

      for c_Grade_Rec in c_Grade loop
        l_grade_name := c_Grade_Rec.grade_name;
        l_grade_step := c_Grade_Rec.grade_step;
      end loop;

      if p_prefix_operator = '<>' then
      begin

        for c_SalaryNeq_Rec in c_SalaryNeq loop
/* For Bug No : 1321519 Start */
          message_token('EFFECTIVE_START_DATE', nvl(g_constraint_start_date,g_from_date));
          message_token('EFFECTIVE_END_DATE', nvl(g_constraint_end_date,g_to_date));
          message_token('FIRST_GL_PERIOD_NAME', g_from_date);
          message_token('LAST_GL_PERIOD_NAME', g_to_date);
/* For Bug No : 1321519 End */
          message_token('CONSTRAINT_SET', g_constraint_set_name);
          message_token('THRESHOLD', g_constraint_threshold);
          message_token('CONSTRAINT', p_constraint_name);
          message_token('SEVERITY_LEVEL', p_severity_level);
          message_token('ASSIGNMENT_VALUE', c_SalaryNeq_Rec.name || ' ' || c_SalaryNeq_Rec.grade_step);
          message_token('OPERATOR', p_prefix_operator);
          message_token('FORMULA_VALUE', l_grade_name || ' ' || l_grade_step);
          message_token('NAME', p_position_name);
          add_message('PSB', 'PSB_REV_CONSTRAINT_FAILURE');

          l_description := FND_MSG_PUB.Get
                              (p_encoded => FND_API.G_FALSE);
          FND_MSG_PUB.Delete_Msg;

          insert into PSB_ERROR_MESSAGES
                     (Concurrent_Request_ID,
                      Process_ID,
                      Source_Process,
                      Description,
                      Creation_Date,
                      Created_By)
              values (FND_GLOBAL.CONC_REQUEST_ID,
                      p_budget_revision_id,
                      'BUDGET_REVISION',
                      l_description,
                      sysdate,
                      FND_GLOBAL.USER_ID);

          if nvl(p_severity_level, -1) >= g_constraint_threshold then
            p_constraint_validation_status := 'F';
          else
            p_constraint_validation_status := 'E';
          end if;

        end loop;

      end;
      end if;

    end;
    end if;

  end;
  else
  begin

    if p_pay_element_option_id is null then
    begin

      for c_SumAll_Rec in c_SumAll loop
        l_posset_total := c_SumAll_Rec.Sum_Elem;
      end loop;

      if p_element_value_type = 'PS' then
      begin

        for c_SumAll_Salary_Rec in c_SumAll_Salary loop
          l_salary_total := c_SumAll_Salary_Rec.Sum_Elem;
        end loop;

      end;
      end if;

    end;
    end if;

    if p_pay_element_option_id is not null then
    begin

      for c_Grade_Rec in c_Grade loop
        l_grade_name := c_Grade_Rec.grade_name;
        l_grade_step := c_Grade_Rec.grade_step;
      end loop;

      if p_prefix_operator = '<>' then
      begin

        for c_SalaryNeqAll_Rec in c_SalaryNeqAll loop
/* For Bug No : 1321519 Start */
          message_token('EFFECTIVE_START_DATE', nvl(g_constraint_start_date,g_from_date));
          message_token('EFFECTIVE_END_DATE', nvl(g_constraint_end_date,g_to_date));
          message_token('FIRST_GL_PERIOD_NAME', g_from_date);
          message_token('LAST_GL_PERIOD_NAME', g_to_date);
/* For Bug No : 1321519 End */
          message_token('CONSTRAINT_SET', g_constraint_set_name);
          message_token('THRESHOLD', g_constraint_threshold);
          message_token('CONSTRAINT', p_constraint_name);
          message_token('SEVERITY_LEVEL', p_severity_level);
          message_token('ASSIGNMENT_VALUE', c_SalaryNeqAll_Rec.name || ' ' || c_SalaryNeqAll_Rec.grade_step);
          message_token('OPERATOR', p_prefix_operator);
          message_token('FORMULA_VALUE', l_grade_name || ' ' || l_grade_step);
          message_token('NAME', c_SalaryNeqAll_Rec.position_name);
          add_message('PSB', 'PSB_REV_CONSTRAINT_FAILURE');

          l_description := FND_MSG_PUB.Get
                              (p_encoded => FND_API.G_FALSE);
          FND_MSG_PUB.Delete_Msg;

          insert into PSB_ERROR_MESSAGES
                     (Concurrent_Request_ID,
                      Process_ID,
                      Source_Process,
                      Description,
                      Creation_Date,
                      Created_By)
              values (FND_GLOBAL.CONC_REQUEST_ID,
                      p_budget_revision_id,
                      'BUDGET_REVISION',
                      l_description,
                      sysdate,
                      FND_GLOBAL.USER_ID);

          if nvl(p_severity_level, -1) >= g_constraint_threshold then
            p_constraint_validation_status := 'F';
          else
            p_constraint_validation_status := 'E';
          end if;

        end loop;

      end;
      end if;

    end;
    end if;

  end;
  end if;

  if p_element_value_type = 'PS' then
  begin

    if p_element_value < 1 then
      l_cons_total := p_element_value * l_salary_total;
    else
      l_cons_total := p_element_value * l_salary_total / 100;
    end if;

  end;
  elsif p_element_value_type = 'A' then
    l_cons_total := p_element_value;
  end if;

  if l_posset_total is not null then
  begin

    if p_prefix_operator = '<=' then

      if l_posset_total <= l_cons_total then
        l_cons_failed := FND_API.G_TRUE;
      end if;

    elsif p_prefix_operator = '>=' then

      if l_posset_total >= l_cons_total then
        l_cons_failed := FND_API.G_TRUE;
      end if;

    elsif p_prefix_operator = '<' then

      if l_posset_total < l_cons_total then
        l_cons_failed := FND_API.G_TRUE;
      end if;

    elsif p_prefix_operator = '>' then

      if l_posset_total > l_cons_total then
        l_cons_failed := FND_API.G_TRUE;
      end if;

    elsif p_prefix_operator = '=' then

      if l_posset_total = l_cons_total then
        l_cons_failed := FND_API.G_TRUE;
      end if;

    elsif p_prefix_operator = '<>' then

      if l_posset_total <> l_cons_total then
        l_cons_failed := FND_API.G_TRUE;
      end if;

    end if;

  end;
  end if;

  if FND_API.to_Boolean(l_cons_failed) then
  begin

    if nvl(p_severity_level, -1) >= g_constraint_threshold then
      p_constraint_validation_status := 'F';
    else
      p_constraint_validation_status := 'E';
    end if;
/* For Bug No : 1321519 Start */
    message_token('EFFECTIVE_START_DATE', nvl(g_constraint_start_date,g_from_date));
    message_token('EFFECTIVE_END_DATE', nvl(g_constraint_end_date,g_to_date));
    message_token('FIRST_GL_PERIOD_NAME', g_from_date);
    message_token('LAST_GL_PERIOD_NAME', g_to_date);
/* For Bug No : 1321519 End */
    message_token('CONSTRAINT_SET', g_constraint_set_name);
    message_token('THRESHOLD', g_constraint_threshold);
    message_token('CONSTRAINT', p_constraint_name);
    message_token('SEVERITY_LEVEL', p_severity_level);
    message_token('ASSIGNMENT_VALUE', l_posset_total);
    message_token('OPERATOR', p_prefix_operator);
    message_token('FORMULA_VALUE', l_cons_total);

    if FND_API.to_Boolean(p_summ_flag) then
      message_token('NAME', p_constraint_name);
    else
      message_token('NAME', p_position_name);
    end if;

    add_message('PSB', 'PSB_REV_CONSTRAINT_FAILURE');

    l_description := FND_MSG_PUB.Get
                        (p_encoded => FND_API.G_FALSE);
    FND_MSG_PUB.Delete_Msg;

    insert into PSB_ERROR_MESSAGES
               (Concurrent_Request_ID,
                Process_ID,
                Source_Process,
                Description,
                Creation_Date,
                Created_By)
        values (FND_GLOBAL.CONC_REQUEST_ID,
                p_budget_revision_id,
                'BUDGET_REVISION',
                l_description,
                sysdate,
                FND_GLOBAL.USER_ID);

  end;
  else
    p_constraint_validation_status := 'S';
  end if;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Process_PosCons_Step;

/* ----------------------------------------------------------------------- */

PROCEDURE Process_PosCons
( p_return_status                 OUT  NOCOPY  VARCHAR2,
  p_constraint_validation_status  OUT  NOCOPY  VARCHAR2,
  p_budget_revision_id            IN   NUMBER,
  p_constraint_id                 IN   NUMBER,
  p_constraint_name               IN   VARCHAR2,
  p_position_id                   IN   NUMBER := FND_API.G_MISS_NUM,
  p_position_name                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_currency_code                 IN   VARCHAR2,
  p_severity_level                IN   NUMBER,
  p_summ_flag                     IN   VARCHAR2
) IS

  l_cons_validation_status        VARCHAR2(1) := 'S';
  l_detailed_status               VARCHAR2(1);

  l_return_status                 VARCHAR2(1);

  cursor c_Formula is
    select pay_element_id,
           pay_element_option_id,
           prefix_operator,
           nvl(currency_code, p_currency_code) currency_code,
           element_value_type,
           element_value
      from PSB_CONSTRAINT_FORMULAS
     where constraint_id = p_constraint_id
     order by step_number;

BEGIN

  for c_Formula_Rec in c_Formula loop

    Process_PosCons_Step
           (p_return_status => l_return_status,
            p_constraint_validation_status => l_detailed_status,
            p_budget_revision_id => p_budget_revision_id,
            p_constraint_id => p_constraint_id,
            p_constraint_name => p_constraint_name,
            p_position_id => p_position_id,
            p_position_name => p_position_name,
            p_currency_code => c_Formula_Rec.currency_code,
            p_severity_level => p_severity_level,
            p_summ_flag => p_summ_flag,
            p_pay_element_id => c_Formula_Rec.pay_element_id,
            p_pay_element_option_id => c_Formula_Rec.pay_element_option_id,
            p_prefix_operator => c_Formula_Rec.prefix_operator,
            p_element_value_type => c_Formula_Rec.element_value_type,
            p_element_value => c_Formula_Rec.element_value);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    if ((l_cons_validation_status = 'S') and
        (l_detailed_status <> 'S')) then
      l_cons_validation_status := l_detailed_status;
    elsif ((l_cons_validation_status = 'E') and
           (l_detailed_status = 'F')) then
      l_cons_validation_status := l_detailed_status;
    end if;

  end loop;

  -- Initialize API return status to success

  p_constraint_validation_status := l_cons_validation_status;
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Process_PosCons;

/* ----------------------------------------------------------------------- */

PROCEDURE Process_FTECons
( p_return_status                 OUT  NOCOPY  VARCHAR2,
  p_constraint_validation_status  OUT  NOCOPY  VARCHAR2,
  p_budget_revision_id            IN   NUMBER,
  p_constraint_id                 IN   NUMBER,
  p_constraint_name               IN   VARCHAR2,
  p_position_id                   IN   NUMBER := FND_API.G_MISS_NUM,
  p_position_name                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_currency_code                 IN   VARCHAR2,
  p_severity_level                IN   NUMBER,
  p_summ_flag                     IN   VARCHAR2
) IS

  l_cons_failed                   VARCHAR2(1) := FND_API.G_FALSE;

  l_posset_total                  NUMBER := 0;
  l_cons_total                    NUMBER := 0;

  l_description                   VARCHAR2(2000);

  cursor c_Formula is
    select prefix_operator,
           amount
      from PSB_CONSTRAINT_FORMULAS
     where constraint_id = p_constraint_id;

  cursor c_SumAll is
    select sum(nvl(a.fte, 0)) Sum_FTE
      from PSB_POSITION_FTE a
     where exists
          (select 1
             from PSB_BUDGET_REVISION_POSITIONS c,
                  PSB_BUDGET_REVISION_POS_LINES d,
                  PSB_BUDGET_POSITIONS e,
                  PSB_SET_RELATIONS f
            where c.budget_revision_pos_line_id = d.budget_revision_pos_line_id
              and d.budget_revision_id = p_budget_revision_id
              and c.position_id = e.position_id
              and e.data_extract_id = g_data_extract_id
              and e.account_position_set_id = f.account_position_set_id
              and f.constraint_id = p_constraint_id)
       and a.budget_revision_id = p_budget_revision_id;

  cursor c_Sum is
    select sum(nvl(fte, 0)) Sum_FTE
      from PSB_POSITION_FTE
     where position_id = p_position_id
       and budget_revision_id = p_budget_revision_id;

BEGIN

  for c_Formula_Rec in c_Formula loop

    l_cons_total := c_Formula_Rec.amount;

    if not FND_API.to_Boolean(p_summ_flag) then
    begin

      for c_Sum_Rec in c_Sum loop
        l_posset_total := c_Sum_Rec.Sum_FTE;
      end loop;

    end;
    else
    begin

      for c_SumAll_Rec in c_SumAll loop
        l_posset_total := c_SumAll_Rec.Sum_FTE;
      end loop;

    end;
    end if;

    if l_posset_total is not null then
    begin

      if c_Formula_Rec.prefix_operator = '<=' then

        if l_posset_total <= l_cons_total then
          l_cons_failed := FND_API.G_TRUE;
        end if;

      elsif c_Formula_Rec.prefix_operator = '>=' then

        if l_posset_total >= l_cons_total then
          l_cons_failed := FND_API.G_TRUE;
        end if;

      elsif c_Formula_Rec.prefix_operator = '<' then

        if l_posset_total < l_cons_total then
          l_cons_failed := FND_API.G_TRUE;
        end if;

      elsif c_Formula_Rec.prefix_operator = '>' then

        if l_posset_total > l_cons_total then
          l_cons_failed := FND_API.G_TRUE;
        end if;

      elsif c_Formula_Rec.prefix_operator = '=' then

        if l_posset_total = l_cons_total then
          l_cons_failed := FND_API.G_TRUE;
        end if;

      elsif c_Formula_Rec.prefix_operator = '<>' then

        if l_posset_total = l_cons_total then
          l_cons_failed := FND_API.G_TRUE;
        end if;

      end if;

    end;
    end if;

    if FND_API.to_Boolean(l_cons_failed) then
    begin

      if nvl(p_severity_level, -1) >= g_constraint_threshold then
        p_constraint_validation_status := 'F';
      else
        p_constraint_validation_status := 'E';
      end if;
/* For Bug No : 1321519 Start */
      message_token('EFFECTIVE_START_DATE', nvl(g_constraint_start_date,g_from_date));
      message_token('EFFECTIVE_END_DATE', nvl(g_constraint_end_date,g_to_date));
      message_token('FIRST_GL_PERIOD_NAME', g_from_date);
      message_token('LAST_GL_PERIOD_NAME', g_to_date);
/* For Bug No : 1321519 End */
      message_token('CONSTRAINT_SET', g_constraint_set_name);
      message_token('THRESHOLD', g_constraint_threshold);
      message_token('CONSTRAINT', p_constraint_name);
      message_token('SEVERITY_LEVEL', p_severity_level);
      message_token('ASSIGNMENT_VALUE', l_posset_total);
      message_token('OPERATOR', c_Formula_Rec.prefix_operator);
      message_token('FORMULA_VALUE', l_cons_total);

      if FND_API.to_Boolean(p_summ_flag) then
        message_token('NAME', p_constraint_name);
      else
        message_token('NAME', p_position_name);
      end if;

      add_message('PSB', 'PSB_REV_CONSTRAINT_FAILURE');

      l_description := FND_MSG_PUB.Get
                          (p_encoded => FND_API.G_FALSE);
      FND_MSG_PUB.Delete_Msg;

      insert into PSB_ERROR_MESSAGES
                 (Concurrent_Request_ID,
                  Process_ID,
                  Source_Process,
                  Description,
                  Creation_Date,
                  Created_By)
          values (FND_GLOBAL.CONC_REQUEST_ID,
                  p_budget_revision_id,
                  'BUDGET_REVISION',
                  l_description,
                  sysdate,
                  FND_GLOBAL.USER_ID);

    end;
    else
      p_constraint_validation_status := 'S';
    end if;

  end loop;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Process_FTECons;

/* ----------------------------------------------------------------------- */

PROCEDURE Process_PosCons_Detailed
( p_return_status                 OUT  NOCOPY  VARCHAR2,
  p_constraint_validation_status  OUT  NOCOPY  VARCHAR2,
  p_budget_revision_id            IN   NUMBER,
  p_constraint_id                 IN   NUMBER,
  p_constraint_name               IN   VARCHAR2,
  p_fte_constraint                IN   VARCHAR2,
  p_currency_code                 IN   VARCHAR2,
  p_severity_level                IN   NUMBER
) IS

  l_cons_validation_status        VARCHAR2(1) := 'S';
  l_detailed_status               VARCHAR2(1);

  l_return_status                 VARCHAR2(1);

  cursor c_Positions is
    select d.position_id,
           c.name
      from PSB_BUDGET_REVISION_POSITIONS a,
           PSB_BUDGET_REVISION_POS_LINES b,
           PSB_POSITIONS c,
           PSB_BUDGET_POSITIONS d,
           PSB_SET_RELATIONS e
     where a.budget_revision_pos_line_id = b.budget_revision_pos_line_id
       and b.budget_revision_id = p_budget_revision_id
       and a.position_id = c.position_id
       and c.position_id = d.position_id
       and d.data_extract_id = g_data_extract_id
       and d.account_position_set_id = e.account_position_set_id
       and e.constraint_id = p_constraint_id;

BEGIN

  for c_Positions_Rec in c_Positions loop

    if ((p_fte_constraint is null) or (p_fte_constraint = 'N')) then
    begin

      Process_PosCons
             (p_budget_revision_id => p_budget_revision_id,
              p_constraint_id => p_constraint_id,
              p_constraint_name => p_constraint_name,
              p_position_id => c_Positions_Rec.position_id,
              p_position_name => c_Positions_Rec.name,
              p_currency_code => p_currency_code,
              p_severity_level => p_severity_level,
              p_summ_flag => FND_API.G_FALSE,
              p_constraint_validation_status => l_detailed_status,
              p_return_status => l_return_status);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
        raise FND_API.G_EXC_ERROR;
      end if;

    end;
    else
    begin

      Process_FTECons
             (p_budget_revision_id => p_budget_revision_id,
              p_constraint_id => p_constraint_id,
              p_constraint_name => p_constraint_name,
              p_position_id => c_Positions_Rec.position_id,
              p_position_name => c_Positions_Rec.name,
              p_currency_code => p_currency_code,
              p_severity_level => p_severity_level,
              p_summ_flag => FND_API.G_FALSE,
              p_constraint_validation_status => l_detailed_status,
              p_return_status => l_return_status);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
        raise FND_API.G_EXC_ERROR;
      end if;

    end;
    end if;

    if ((l_cons_validation_status = 'S') and
        (l_detailed_status <> 'S')) then
      l_cons_validation_status := l_detailed_status;
    elsif ((l_cons_validation_status = 'E') and
           (l_detailed_status = 'F')) then
      l_cons_validation_status := l_detailed_status;
    end if;

  end loop;


  -- Initialize API return status to success

  p_constraint_validation_status := l_cons_validation_status;
  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Process_PosCons_Detailed;

/* ----------------------------------------------------------------------- */

PROCEDURE Apply_Position_Constraints
( p_return_status         OUT  NOCOPY  VARCHAR2,
  p_validation_status     OUT  NOCOPY  VARCHAR2,
  p_budget_revision_id    IN   NUMBER
) IS

  l_cons_validation_status     VARCHAR2(1);
  l_consset_validation_status  VARCHAR2(1) := 'S';

  l_return_status              VARCHAR2(1);

  cursor c_Constraint is
    select constraint_id,
           name,
           currency_code,
           severity_level,
           fte_constraint,
           effective_start_date,
           effective_end_date,
           constraint_detailed_flag
      from PSB_CONSTRAINT_ASSIGNMENTS_V
     where constraint_type = 'POSITION'
       and constraint_set_id = g_constraint_set_id
     order by severity_level desc;

BEGIN

  for c_Constraint_Rec in c_Constraint loop
  /* ForBug No : 1321519 Start */
    g_constraint_start_date := c_Constraint_Rec.effective_start_date;
    g_constraint_end_date   := c_Constraint_Rec.effective_end_date;
  /* ForBug No : 1321519 End */
    if ((c_Constraint_Rec.constraint_detailed_flag is null) or
        (c_Constraint_Rec.constraint_detailed_flag = 'N')) then
    begin

      if ((c_Constraint_Rec.fte_constraint is null) or (c_Constraint_Rec.fte_constraint = 'N')) then
      begin

        Process_PosCons
               (p_budget_revision_id => p_budget_revision_id,
                p_constraint_id => c_Constraint_Rec.constraint_id,
                p_constraint_name => c_Constraint_Rec.name,
                p_currency_code => nvl(c_Constraint_Rec.currency_code, g_func_currency),
                p_severity_level => c_Constraint_Rec.severity_level,
                p_summ_flag => FND_API.G_TRUE,
                p_constraint_validation_status => l_cons_validation_status,
                p_return_status => l_return_status);

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
          raise FND_API.G_EXC_ERROR;
        end if;

      end;
      else
      begin

        Process_FTECons
               (p_budget_revision_id => p_budget_revision_id,
                p_constraint_id => c_Constraint_Rec.constraint_id,
                p_constraint_name => c_Constraint_Rec.name,
                p_currency_code => nvl(c_Constraint_Rec.currency_code, g_func_currency),
                p_severity_level => c_Constraint_Rec.severity_level,
                p_summ_flag => FND_API.G_TRUE,
                p_constraint_validation_status => l_cons_validation_status,
                p_return_status => l_return_status);

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
          raise FND_API.G_EXC_ERROR;
        end if;

      end;
      end if;

      if ((l_consset_validation_status = 'S') and
          (l_cons_validation_status <> 'S')) then
        l_consset_validation_status := l_cons_validation_status;
      elsif ((l_consset_validation_status = 'E') and
             (l_cons_validation_status = 'F')) then
        l_consset_validation_status := l_cons_validation_status;
      elsif ((l_consset_validation_status = 'W') and
             (l_cons_validation_status in ('F', 'E'))) then
        l_consset_validation_status := l_cons_validation_status;
      end if;

    end;
    else
    begin

      Process_PosCons_Detailed
             (p_return_status => l_return_status,
              p_constraint_validation_status => l_cons_validation_status,
              p_budget_revision_id => p_budget_revision_id,
              p_constraint_id => c_Constraint_Rec.constraint_id,
              p_constraint_name => c_Constraint_Rec.name,
              p_fte_constraint => c_Constraint_Rec.fte_constraint,
              p_currency_code => nvl(c_Constraint_Rec.currency_code, g_func_currency),
              p_severity_level => c_Constraint_Rec.severity_level);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
        raise FND_API.G_EXC_ERROR;
      end if;

      if ((l_consset_validation_status = 'S') and
          (l_cons_validation_status <> 'S')) then
        l_consset_validation_status := l_cons_validation_status;
      elsif ((l_consset_validation_status = 'E') and
             (l_cons_validation_status = 'F')) then
        l_consset_validation_status := l_cons_validation_status;
      elsif ((l_consset_validation_status = 'W') and
             (l_cons_validation_status in ('F', 'E'))) then
        l_consset_validation_status := l_cons_validation_status;
      end if;

    end;
    end if;

  end loop;

  -- Initialize API return status to success

  p_validation_status := l_consset_validation_status;
  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Apply_Position_Constraints;

/* ----------------------------------------------------------------------- */

PROCEDURE Apply_Constraints
( p_api_version               IN   NUMBER,
  p_validation_level          IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY  VARCHAR2,
  p_validation_status         OUT  NOCOPY  VARCHAR2,
  p_budget_revision_id        IN   NUMBER,
  p_constraint_set_id         IN   NUMBER
) IS

  l_api_name                  CONSTANT VARCHAR2(30)   := 'Apply_Constraints';
  l_api_version               CONSTANT NUMBER         := 1.0;

  l_constraint_set_status     VARCHAR2(1) := 'S';
  l_validation_status         VARCHAR2(1);

  l_return_status             VARCHAR2(1);

BEGIN

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  Cache_Revision_Variables
       (p_return_status => l_return_status,
        p_budget_revision_id => p_budget_revision_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  if g_constraint_set_id is not null then
  begin

    delete from PSB_ERROR_MESSAGES
     where source_process = 'BUDGET_REVISION'
       and process_id = p_budget_revision_id;

    if g_constraint_set_id <> p_constraint_set_id then
      g_constraint_set_id := p_constraint_set_id;
    end if;

  end;
  end if;

  Apply_Account_Constraints
       (p_return_status => l_return_status,
        p_validation_status => l_validation_status,
        p_budget_revision_id => p_budget_revision_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  l_constraint_set_status := l_validation_status;

  Apply_Element_Constraints
       (p_return_status => l_return_status,
        p_budget_revision_id => p_budget_revision_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  Apply_Position_Constraints
       (p_return_status => l_return_status,
        p_validation_status => l_validation_status,
        p_budget_revision_id => p_budget_revision_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  if ((l_constraint_set_status = 'S') and
      (l_validation_status <> 'S')) then
    l_constraint_set_status := l_validation_status;
  elsif ((l_constraint_set_status = 'E') and
         (l_validation_status = 'F')) then
    l_constraint_set_status := l_validation_status;
  elsif ((l_constraint_set_status = 'W') and
         (l_validation_status in ('F', 'E'))) then
    l_constraint_set_status := l_validation_status;
  end if;

   /* For Bug No.2810621 Start*/
  Update PSB_BUDGET_REVISIONS
   set constraint_set_id = g_constraint_set_id,
       last_update_date = sysdate,
       last_updated_by = FND_GLOBAL.USER_ID,
       last_update_login = FND_GLOBAL.LOGIN_ID
   where budget_revision_id = p_budget_revision_id;
  /* For Bug No. 2810621 End*/



  -- Initialize API return status to success

  p_validation_status := l_constraint_set_status;
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg
          (p_pkg_name => G_PKG_NAME,
           p_procedure_name => l_api_name);

     end if;

END Apply_Constraints;

/* ----------------------------------------------------------------------- */

-- removing savepoints from this API to allow invocation from HR User Hooks

PROCEDURE Delete_Revision_Positions
( p_api_version                     IN      NUMBER,
  p_init_msg_list                   IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                          IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level                IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status                   OUT  NOCOPY     VARCHAR2,
  p_msg_count                       OUT  NOCOPY     NUMBER,
  p_msg_data                        OUT  NOCOPY     VARCHAR2,
  p_budget_revision_id              IN      NUMBER ,
  p_budget_revision_pos_line_id     IN      NUMBER
) IS

  l_api_name                        CONSTANT VARCHAR2(30) := 'Delete_Revision_Positions';
  l_api_version                     CONSTANT NUMBER       := 1.0;

  l_position_id                     NUMBER;
  l_effective_start_date            DATE;
  l_effective_end_date              DATE;
  l_global_revision                 VARCHAR2(1);

  l_return_status                   VARCHAR2(1);

  cursor c_global_revision is
    select pbr.global_budget_revision
      from psb_budget_revisions pbr
     where pbr.budget_revision_id = p_budget_revision_id;

  cursor c_Position_Revision is
    select position_id, effective_start_date, effective_end_date
      from psb_budget_revision_positions
     where budget_revision_pos_line_id = p_budget_revision_pos_line_id;

BEGIN

  -- Standard call to check for call compatibility.

  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  IF FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  Cache_Revision_Variables
       (p_return_status => l_return_status,
        p_budget_revision_id => p_budget_revision_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  For C_Position_Revision_rec in C_Position_Revision Loop
    l_position_id := C_Position_Revision_Rec.position_id;
    l_effective_start_date := C_Position_Revision_Rec.effective_start_date;
    l_effective_end_date := C_Position_Revision_Rec.effective_end_date;
  End Loop;

  For C_Global_Revision_Rec in C_Global_Revision Loop
    l_global_revision := C_global_Revision_Rec.global_budget_revision;
  End Loop;

/* Bug No 2482305 Start */
-- Added to remove the worksheet specific position records for deleted positions
  delete from PSB_POSITION_ASSIGNMENTS pa
        where pa.position_id = l_position_id
          and pa.worksheet_id = p_budget_revision_id
          and pa.data_extract_id = g_data_extract_id;
/* Bug No 2482305 End */

  If l_global_revision = 'Y' Then

    DELETE PSB_BUDGET_REVISION_POSITIONS
     WHERE budget_revision_pos_line_id  = p_budget_revision_pos_line_id;

    DELETE PSB_BUDGET_REVISION_POS_LINES
     WHERE budget_revision_pos_line_id  = p_budget_revision_pos_line_id;

  Else

    DELETE PSB_BUDGET_REVISION_POS_LINES
     WHERE budget_revision_pos_line_id = p_budget_revision_pos_line_id
       AND budget_revision_id = p_budget_revision_id;

  End If;

  Reverse_Position_Accounts
         (p_return_status => l_return_status,
          p_budget_revision_id => p_budget_revision_id,
          p_position_id => l_position_id,
          p_effective_start_date => l_effective_start_date,
          p_effective_end_date => l_effective_end_date);

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                             p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

End Delete_Revision_Positions;

/* ----------------------------------------------------------------------- */

-- removed savepoints to allow invocation from HR User Hooks

PROCEDURE Delete_Revision_Accounts
( p_api_version                     IN      NUMBER,
  p_init_msg_list                   IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                          IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level                IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status                   OUT  NOCOPY     VARCHAR2,
  p_msg_count                       OUT  NOCOPY     NUMBER,
  p_msg_data                        OUT  NOCOPY     VARCHAR2,
  p_budget_revision_id              IN      NUMBER ,
  p_budget_revision_acct_line_id    IN      NUMBER)

IS

  l_api_name    CONSTANT VARCHAR2(30)   := 'Delete_Revision_Accounts';
  l_api_version CONSTANT NUMBER         := 1.0;

  l_budget_revision_acct_line_id NUMBER := '';
  l_budget_version_id   number;
  l_global_revision     varchar2(1);
  l_return_status       varchar2(1);
  l_msg_count           number;
  l_msg_data            varchar2(2000);

Cursor C_global_revision is
  Select pbr.global_budget_revision
    from psb_budget_revisions pbr
   where pbr.budget_revision_id = p_budget_revision_id;

Cursor C_Account_line is
  Select pbrl.budget_revision_acct_line_id
    from psb_budget_revision_lines pbrl
   where pbrl.budget_revision_id = p_budget_revision_id
     and pbrl.budget_revision_acct_line_id  = p_budget_revision_acct_line_id;

Begin

  -- Standard call to check for call compatibility.

  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  IF FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

   -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


  For C_Account_Line_Rec  in C_Account_Line
  Loop
     l_budget_revision_acct_line_id := C_account_Line_rec.budget_revision_acct_line_id;
  End Loop;

  if (l_budget_revision_acct_line_id is null) then
     null;
  else

      For C_Global_Revision_Rec in C_Global_Revision
      Loop
         l_global_revision := C_global_Revision_Rec.global_budget_revision;
      End Loop;

      IF l_global_revision = 'Y' THEN
         Delete PSB_BUDGET_REVISION_ACCOUNTS
          where budget_revision_acct_line_id = p_budget_revision_acct_line_id;

         Delete PSB_BUDGET_REVISION_LINES
          where budget_revision_acct_line_id = p_budget_revision_acct_line_id;
      ELSE
         Delete PSB_BUDGET_REVISION_LINES
          where budget_revision_acct_line_id = p_budget_revision_acct_line_id
           and budget_revision_id           = p_budget_revision_id;
      END IF;

  end if;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                             p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

End Delete_Revision_Accounts;

/*===========================================================================+
 |                 PROCEDURE Delete_Budget_Revision_Pvt ( Private )          |
 +===========================================================================*/
--
-- This API deletes an official budget_revision by performing deletes on
-- psb_budget_revisions and matrix tables (psb_budget_revision_lines and
-- psb_budget_revision_pos_lines).
-- It also deletes budget_revision related data from other tables.
--
PROCEDURE Delete_Budget_Revision_Pvt
(
  p_budget_revision_id   IN      NUMBER,
  p_revise_by_position   IN      VARCHAR2,
  p_budget_group_id      IN      NUMBER,
  p_return_status        OUT  NOCOPY     VARCHAR2
)
IS
  --
  l_api_name           CONSTANT    VARCHAR2(30):= 'Delete_Budget_Revision_Pvt';
  --
  l_account_line_id       NUMBER;
  l_position_line_id      NUMBER;
  l_data_extract_id       NUMBER;
  l_revise_by_position    VARCHAR2(1);
  l_msg_count             NUMBER ;
  l_msg_data              VARCHAR2(2000) ;
  l_return_status         VARCHAR2(1) ;
  --

  CURSOR l_br_account_lines_csr
    IS
    SELECT budget_revision_acct_line_id
    FROM   psb_budget_revision_lines
    WHERE  budget_revision_id = p_budget_revision_id;

  CURSOR l_br_position_lines_csr
    IS
    SELECT budget_revision_pos_line_id
    FROM   psb_budget_revision_pos_lines
    WHERE  budget_revision_id = p_budget_revision_id;

  CURSOR l_br_distribution_csr
    IS
    SELECT distribution_id
    FROM   psb_ws_distributions
    WHERE  worksheet_id = p_budget_revision_id
    AND    distribution_option_flag = 'R';

  CURSOR l_br_position_csr
    IS
    SELECT   position_assignment_id, pay_element_rate_id
    FROM     psb_position_assignments
    WHERE    worksheet_id = p_budget_revision_id
    AND      data_extract_id = l_data_extract_id
    GROUP BY position_assignment_id, pay_element_rate_id;

  /*For Bug No : 1527423 Start*/
  CURSOR l_br_pos_csr  is

    SELECT   position_id
      FROM   psb_positions pp
     WHERE   pp.data_extract_id = l_data_extract_id
       AND   nvl(pp.new_position_flag, 'N') = 'Y'
       AND   EXISTS (SELECT 1
                       FROM psb_budget_revision_positions brp,
                            psb_budget_revision_pos_lines brpl,
                            psb_budget_revisions br
                      WHERE br.budget_revision_id = p_budget_revision_id
                        AND br.budget_revision_id = brpl.budget_revision_id
                        AND brpl.budget_revision_pos_line_id = brp.budget_revision_pos_line_id
                        AND brp.position_id = pp.position_id
                     );
  /*For Bug No : 1527423 End*/

BEGIN
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;

  --
  -- Deleting account related information.
  --
  /*For Bug No : 1527423 Start*/
   l_data_extract_id := PSB_BUDGET_REVISIONS_PVT.FIND_SYSTEM_DATA_EXTRACT(p_budget_group_id);
  /*For Bug No : 1527423 End*/

  OPEN l_br_account_lines_csr;

  LOOP
    --
    FETCH l_br_account_lines_csr INTO l_account_line_id;

    IF (l_br_account_lines_csr%NOTFOUND) THEN
      EXIT;
    END IF;

    -- Deleting records from psb_budget_revision_lines.

    PSB_BUDGET_REVISIONS_PVT.Delete_Revision_Accounts
    ( p_api_version                    => 1.0 ,
      p_init_msg_list                  => FND_API.G_FALSE,
      p_commit                         => FND_API.G_FALSE,
      p_validation_level               => FND_API.G_VALID_LEVEL_FULL,
      p_return_status                  => l_return_status,
      p_msg_count                      => l_msg_count,
      p_msg_data                       => l_msg_data,
      p_budget_revision_id             => p_budget_revision_id,
      p_budget_revision_acct_line_id   => l_account_line_id);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR ;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
     END IF;
      --
  END LOOP;

  CLOSE l_br_account_lines_csr;

  --
  -- Deleting position related information.
  --
  IF ( p_revise_by_position = 'Y' ) THEN
  --
    /*For Bug No ; 1527423 Start*/
    -- Delete from psb_positions
    FOR l_br_pos_csr_rec IN l_br_pos_csr LOOP
      DELETE psb_position_assignments
       WHERE position_id = l_br_pos_csr_rec.position_id;

      DELETE psb_positions
       WHERE position_id = l_br_pos_csr_rec.position_id;
    END LOOP;
    /*For Bug No : 1527423 End*/

    OPEN l_br_position_lines_csr ;

    LOOP
    --
      FETCH l_br_position_lines_csr INTO l_position_line_id;

      IF ( l_br_position_lines_csr%NOTFOUND ) THEN
        EXIT;
      END IF;

      -- Deleting records from psb_budget_revision_lines.

      PSB_BUDGET_REVISIONS_PVT.Delete_Revision_Positions
      ( p_api_version                    => 1.0 ,
        p_init_msg_list                  => FND_API.G_FALSE,
        p_commit                         => FND_API.G_FALSE,
        p_validation_level               => FND_API.G_VALID_LEVEL_FULL,
        p_return_status                  => l_return_status,
        p_msg_count                      => l_msg_count,
        p_msg_data                       => l_msg_data,
        p_budget_revision_id             => p_budget_revision_id,
        p_budget_revision_pos_line_id    => l_position_line_id);

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR ;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       END IF;

    END LOOP;

    CLOSE l_br_position_lines_csr ;

  END IF ;    -- if p_revise_by_position is 'Y'.
  --
  --
  -- Delete from psb_ws_distribution_details.

  FOR    l_br_distribution_rec IN l_br_distribution_csr
  LOOP
    DELETE psb_ws_distribution_details
    WHERE  distribution_id = l_br_distribution_rec.distribution_id;

    -- Delete from psb_ws_distributions.
    DELETE psb_ws_distributions
    WHERE  distribution_id = l_br_distribution_rec.distribution_id;
  END LOOP;

  -- Delete from psb_workflow_processes.
  DELETE psb_workflow_processes
  WHERE  worksheet_id = p_budget_revision_id
  AND    document_type = 'BR' ;

  --Find system data extract for the given budget revision
  /*For Bug No ; 1527423 Start*/
  --following code has been moved to up
  --l_data_extract_id := PSB_BUDGET_REVISIONS_PVT.FIND_SYSTEM_DATA_EXTRACT(p_budget_group_id);
  /*For Bug No ; 1527423 End*/

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR ;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

  For l_br_position_rec In l_br_position_csr
  LOOP
    -- Delete from psb_position_assignments.
    DELETE psb_position_assignments
    WHERE  position_assignment_id = l_br_position_rec.position_assignment_id;

    -- Delete from psb_pay_elements_rates.
    DELETE psb_pay_element_rates
    WHERE  pay_element_rate_id = l_br_position_rec.pay_element_rate_id;

  END LOOP;

/* Bug No 2482305 Start */
  -- Delete from psb_pay_element_rates.
  DELETE psb_pay_element_rates
  WHERE  worksheet_id = p_budget_revision_id ;
/* Bug No 2482305 End */

  -- Delete from psb_position_accounts.
  DELETE psb_position_accounts
  WHERE  budget_revision_id = p_budget_revision_id ;

  -- Delete from psb_position_fte.
  DELETE psb_position_fte
  WHERE  budget_revision_id = p_budget_revision_id ;

  -- Delete from psb_position_costs
  DELETE psb_position_costs
  WHERE  budget_revision_id = p_budget_revision_id ;

  -- Delete from psb_ws_submit_comments.
  DELETE psb_ws_submit_comments
  WHERE  worksheet_id = p_budget_revision_id ;

  /*For Bug No : 2613269 Start*/
  fnd_attached_documents2_pkg.delete_attachments
             (X_entity_name => 'PSB_BUDGET_REVISIONS',
              X_pk1_value => p_budget_revision_id,
              X_delete_document_flag => 'Y'
             );
  /*For Bug No : 2613269 End*/

  -- Delete from psb_budget_revisions.

  PSB_BUDGET_REVISIONS_PVT.Delete_Row
  (p_api_version        =>   1.0 ,
   p_init_msg_list      =>   FND_API.G_FALSE,
   p_commit             =>   FND_API.G_FALSE,
   p_validation_level   =>   FND_API.G_VALID_LEVEL_FULL,
   p_return_status      =>   l_return_status,
   p_msg_count          =>   l_msg_count,
   p_msg_data           =>   l_msg_data,
   p_budget_revision_id =>   p_budget_revision_id);

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR ;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

EXCEPTION
  --
 WHEN OTHERS THEN
    --
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME,
                                 l_api_name );
    END IF;
    --
END Delete_Budget_Revision_Pvt ;

/*===========================================================================+
 |                     PROCEDURE Delete_Budget_Revision                      |
 +===========================================================================*/
--
-- The API This API deletes a local or global budget revision.
--
PROCEDURE Delete_Budget_Revision
(
  p_api_version               IN       NUMBER   ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --
  p_budget_revision_id        IN       NUMBER
)
IS
  --
  l_api_name                CONSTANT VARCHAR2(30)   := 'Delete_Budget_Revision';
  l_api_version             CONSTANT NUMBER         :=  1.0 ;
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  --
  l_global_budget_revision  VARCHAR2(1);
  l_budget_group_id         NUMBER;
  l_data_extract_id         NUMBER;
  l_revise_by_position      VARCHAR2(1);
  l_budget_revisions_tab    PSB_Create_BR_Pvt.Budget_Revision_Tbl_Type;
  --
BEGIN
  --
  SAVEPOINT Delete_Budget_Revision;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.To_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --

  SELECT NVL( global_budget_revision, 'N') ,
         NVL( revise_by_position, 'N'),
         budget_group_id
       INTO
         l_global_budget_revision,
         l_revise_by_position,
         l_budget_group_id
  FROM   psb_budget_revisions
  WHERE  budget_revision_id = p_budget_revision_id ;

  --
  -- Take action bases on the type of the budget_revision.
  --
  IF l_global_budget_revision = 'Y' THEN
    --
    -- ( It means it is a global budget_revision.)
    -- Lock all the child budget revisions.
    --

    -- Find all related budget_revisions.
    FOR l_budget_revision_rec IN
    (
       SELECT budget_revision_id
       FROM   psb_budget_revisions
       WHERE  global_budget_revision_id  = p_budget_revision_id
       AND    NVL( global_budget_revision, 'N' ) = 'N'
    )
    LOOP
      --
      PSB_Create_BR_Pvt.Enforce_BR_Concurrency
      (
         p_api_version              => 1.0 ,
         p_init_msg_list            => FND_API.G_FALSE ,
         p_validation_level         => FND_API.G_VALID_LEVEL_FULL ,
         p_return_status            => l_return_status ,
         p_msg_count                => l_msg_count ,
         p_msg_data                 => l_msg_data  ,
         --
         p_budget_revision_id        => l_budget_revision_rec.budget_revision_id,
         p_parent_or_child_mode      => 'CHILD',
         p_maintenance_mode          => 'MAINTENANCE'
      );
      --
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR ;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF;
      --
    END LOOP ;  -- Lock child official, review group and local budget_revisions.

    -- Delete all the child official budget_revisions.
    FOR l_budget_revision_rec IN
    (
       SELECT budget_revision_id, revise_by_position, budget_group_id
       FROM   psb_budget_revisions
       WHERE  global_budget_revision_id    = p_budget_revision_id
       AND    NVL( global_budget_revision, 'N' ) = 'N'
    )
    LOOP
      --
      Delete_Budget_Revision_Pvt
      (
         p_budget_revision_id  =>  l_budget_revision_rec.budget_revision_id,
         p_revise_by_position  =>  l_budget_revision_rec.revise_by_position,
         p_budget_group_id     =>  l_budget_revision_rec.budget_group_id,
         p_return_status       =>  l_return_status
      ) ;
      --
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR ;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF;
      --
    END LOOP;

    -- Delete the global budget_revision now.
    Delete_Budget_Revision_Pvt
    (
       p_budget_revision_id  =>  p_budget_revision_id        ,
       p_revise_by_position  =>  l_revise_by_position  ,
       p_budget_group_id     =>  l_budget_group_id,
       p_return_status       =>  l_return_status
    ) ;
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    --
  ELSE
    --
    -- Find all the child budget_revisions.
    PSB_Create_BR_Pvt.Find_Child_Budget_Revisions
    (
       p_api_version        =>   1.0 ,
       p_init_msg_list      =>   FND_API.G_FALSE,
       p_commit             =>   FND_API.G_FALSE,
       p_validation_level   =>   FND_API.G_VALID_LEVEL_FULL,
       p_return_status      =>   l_return_status,
       p_msg_count          =>   l_msg_count,
       p_msg_data           =>   l_msg_data,
       --
       p_budget_revision_id       =>   p_budget_revision_id,
       p_budget_revision_tbl      =>   l_budget_revisions_tab
    );
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    --
    -- Adding the current budget_revision in the table as it has to go through
    -- the same processing
    l_budget_revisions_tab(0) := p_budget_revision_id ;

    --
    -- Process the current and all the child budget_revisions for locking.
    -- (Use 0 and COUNT-1 now).
    --
    FOR i IN 0..l_budget_revisions_tab.COUNT-1
    LOOP

      -- Lock the current budget_revision.

      PSB_Create_BR_Pvt.Enforce_BR_Concurrency
      (
         p_api_version              => 1.0 ,
         p_init_msg_list            => FND_API.G_FALSE ,
         p_validation_level         => FND_API.G_VALID_LEVEL_NONE ,
         p_return_status            => l_return_status ,
         p_msg_count                => l_msg_count ,
         p_msg_data                 => l_msg_data  ,
         --
         p_budget_revision_id        => l_budget_revisions_tab(i),
         p_parent_or_child_mode      => 'CHILD',
         p_maintenance_mode          => 'MAINTENANCE'
      );

      --
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR ;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF;
      --
    END LOOP; -- For locking phase.
    --
    -- Process the current and all the child budget revisions for deletion.
    -- (Use 0 and COUNT-1 now).
    --
    FOR i IN 0..l_budget_revisions_tab.COUNT-1
    LOOP

      -- Delete the current worksheet.
      Delete_Budget_Revision_Pvt
      (
         p_budget_revision_id  =>  l_budget_revisions_tab(i),
         p_revise_by_position  =>  l_revise_by_position,
         p_budget_group_id     =>  l_budget_group_id,
         p_return_status       =>  l_return_status
      ) ;
      --
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR ;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF;

    END LOOP;

  END IF; -- For the main IF statement, check for global_budget_revision.

  IF  FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END IF;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                              p_data  => p_msg_data );
  --
EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Delete_Budget_Revision ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Delete_Budget_Revision ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Delete_Budget_Revision ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );
     --
END Delete_Budget_Revision ;

/*===========================================================================+
 |                   PROCEDURE Mass_Budget_Revision_CP                       |
 +===========================================================================*/
--
-- This is the execution file for the concurrent program 'Create Mass Budget
-- Revision Entries'

PROCEDURE Mass_Budget_Revision_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_budget_revision_id        IN      NUMBER
)
IS
  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Mass_Budget_Revision_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_error_api_name          VARCHAR2(2000);
  l_account_set_id          NUMBER;
  l_data_extract_id         NUMBER;
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  l_msg_index_out           NUMBER;
  l_currency_code           VARCHAR2(15);

 Cursor C_Budget_Group is
   Select budget_group_id,currency_code -- Bug 3029168 added currency_code
     from psb_budget_revisions
    where budget_revision_id = p_budget_revision_id;

BEGIN

  FND_FILE.Put_Line( FND_FILE.OUTPUT,
   'Processing the Budget Revision Batch Number : ' ||p_budget_revision_id);

  -- Enforce Concurrency Control

  PSB_CONCURRENCY_CONTROL_PVT.Enforce_Concurrency_Control
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_concurrency_class => 'BUDGET_REVISION_CREATION',
      p_concurrency_entity_name => 'BUDGET_REVISION',
      p_concurrency_entity_id => p_budget_revision_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  end if;

  PSB_BUDGET_ACCOUNT_PVT.Populate_Budget_Accounts
     (p_api_version       =>  1.0,
      p_init_msg_list     =>  FND_API.G_TRUE,
      p_commit            =>  FND_API.G_TRUE,
      p_return_status     =>  l_return_status,
      p_msg_count         =>  l_msg_count,
      p_msg_data          =>  l_msg_data,
      p_account_set_id    =>  l_account_set_id
      );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
     raise FND_API.G_EXC_ERROR;
  end if;

  For C_Budget_Group_Rec in C_Budget_Group
  Loop
  l_data_extract_id := Find_System_Data_Extract
                ( p_budget_group_id  => C_Budget_Group_Rec.budget_group_id);
  l_currency_code   := c_budget_group_rec.currency_code;
  End Loop;

  IF (l_data_extract_id IS NOT NULL)
  AND l_currency_code <> 'STAT' THEN -- Bug 3029168
  PSB_BUDGET_POSITION_PVT.Populate_Budget_Positions
     (p_api_version       =>  1.0,
      p_commit            =>  FND_API.G_TRUE,
      p_return_status     =>  l_return_status,
      p_msg_count         =>  l_msg_count,
      p_msg_data          =>  l_msg_data,
      p_data_extract_id   =>  l_data_extract_id
      );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  end if;
  end if;

  Create_Mass_Revision_Entries
  (p_api_version            => 1.0,
   p_init_msg_list          => FND_API.G_TRUE,
   p_commit                 => FND_API.G_TRUE,
   p_validation_level       => FND_API.G_VALID_LEVEL_NONE,
   p_return_status          => l_return_status,
   p_msg_count              => l_msg_count,
   p_msg_data               => l_msg_data,
   p_data_extract_id        => l_data_extract_id,
   p_budget_revision_id     => p_budget_revision_id);

   if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  end if;

   PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_concurrency_class => 'BUDGET_REVISION_CREATION',
      p_concurrency_entity_name => 'BUDGET_REVISION',
      p_concurrency_entity_id => p_budget_revision_id);

   if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_ERROR;
   end if;
    /* Start Bug No. 2322856 */
--  PSB_MESSAGE_S.Print_Success;
    /* End Bug No. 2322856 */
  retcode := 0 ;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
                               p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
                                p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
   WHEN OTHERS THEN
     --
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
                               l_api_name  ) ;
     END IF ;
     --
     l_return_status := FND_API.G_RET_STS_ERROR;

     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
                                 p_print_header =>  FND_API.G_TRUE );
     --
     retcode := 2 ;
     COMMIT WORK ;
     --

End Mass_Budget_Revision_CP;

/*===========================================================================+
 |                   PROCEDURE Revision_Funds_Check_CP                       |
 +===========================================================================*/
--
-- This is the execution file for the concurrent program 'Perform Funds Check
-- for Revision Entries'

PROCEDURE Revision_Funds_Check_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_budget_revision_id        IN      NUMBER
)
IS
  l_api_name       CONSTANT VARCHAR2(30)   := 'Revision_Funds_Check_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_error_api_name          VARCHAR2(2000);
  l_account_set_id          NUMBER;
  l_data_extract_id         NUMBER;
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  l_msg_index_out           NUMBER;
  l_fund_check_failures     NUMBER;

BEGIN

  FND_FILE.Put_Line( FND_FILE.OUTPUT,
   'Processing the Budget Revision Batch Number : ' ||p_budget_revision_id);

    Budget_Revision_Funds_Check
    (
       p_api_version                 => 1.0 ,
       p_init_msg_list               => FND_API.G_FALSE,
       p_commit                      => FND_API.G_FALSE,
       p_validation_level            => FND_API.G_VALID_LEVEL_NONE,
       p_return_status               => l_return_status,
       p_msg_count                   => l_msg_count,
       p_msg_data                    => l_msg_data ,
       --
       p_funds_reserve_flag          => 'N',
       p_budget_revision_id          => p_budget_revision_id,
       p_fund_check_failures         => l_fund_check_failures,
       p_called_from                 => 'B' -- Bug#4310411
    );

    --
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF ;

    /* Start Bug No. 2322856 */
--  PSB_MESSAGE_S.Print_Success;
    /* End Bug No. 2322856 */
  retcode := 0 ;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
                               p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
                                p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
   WHEN OTHERS THEN
     --
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
                               l_api_name  ) ;
     END IF ;
     --
     l_return_status := FND_API.G_RET_STS_ERROR;

     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
                                 p_print_header =>  FND_API.G_TRUE );
     --
     retcode := 2 ;
     COMMIT WORK ;
     --
End Revision_Funds_Check_CP;

/*===========================================================================+
 |                   PROCEDURE Revise_Projections_CP                         |
 +===========================================================================*/
--
PROCEDURE Revise_Projections_CP
(
  errbuf                OUT  NOCOPY      VARCHAR2  ,
  retcode               OUT  NOCOPY      VARCHAR2  ,
  --
  p_budget_revision_id  IN   NUMBER,
  p_parameter_id        IN   NUMBER,
  --Bug:5753424: Added the parameter p_param_type
  p_param_type          IN   VARCHAR2 := 'No Param Set'
) IS

  l_api_name          CONSTANT VARCHAR2(30)     := 'Revise_Projections_CP';
  l_api_version       CONSTANT NUMBER           := 1.0;

  l_error_api_name          VARCHAR2(2000);
  l_data_extract_id         NUMBER;
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  l_msg_index_out           NUMBER;
  l_validation_status       VARCHAR2(1);

  l_set_CP_status           BOOLEAN := FALSE; -- Bug#4571412
  l_currency_code           VARCHAR2(15);

 Cursor C_Budget_Group is
   Select budget_group_id,currency_code  -- Bug 3029168 added currency code
     from psb_budget_revisions
    where budget_revision_id = p_budget_revision_id;

/*Bug:5753424: Start */

  l_element_param_exists    VARCHAR2(1) := 'N';
  l_position_param_exists   VARCHAR2(1) := 'N';
  l_param_type              VARCHAR2(15) := p_param_type;
  l_exception               VARCHAR2(1)  := 'N';

  CURSOR c_parameters(l_param_type  VARCHAR2) IS
  SELECT pes.entity_set_id parameter_set_id
        ,pes.name          parameter_set_name
        ,pe.entity_id parameter_id
        ,pe.name      parameter_name
        ,pe.entity_subtype parameter_type
        ,pea.priority
  FROM   psb_entity_set pes
        ,psb_entity pe
        ,psb_entity_assignment pea
  /*Bug:5753424: parameter_set_id is passed to p_parameter_id*/
  WHERE  pes.entity_set_id = p_parameter_id
  AND    pes.entity_type = 'PARAMETER'
  AND    pe.entity_type='PARAMETER'
  AND    ((l_param_type='ACCOUNT' AND pe.entity_subtype='ACCOUNT') OR
         (l_param_type='POSITION' AND pe.entity_subtype ='POSITION') OR
         (l_param_type='ELEMENT' AND pe.entity_subtype ='ELEMENT'))
  AND    pea.entity_id = pe.entity_id
  AND    pea.entity_set_id = pes.entity_set_id
  ORDER  BY pea.priority asc;

  CURSOR c_ele_param_exists IS
  SELECT 'Y'
  FROM   psb_entity_set pes
        ,psb_entity pe
        ,psb_entity_assignment pea
  WHERE  pes.entity_set_id = p_parameter_id
  AND    pes.entity_type = 'PARAMETER'
  AND    pe.entity_type='PARAMETER'
  AND    pe.entity_subtype='ELEMENT'
  AND    pea.entity_id = pe.entity_id
  AND    pea.entity_set_id = pes.entity_set_id;

  CURSOR c_pos_param_exists IS
  SELECT 'Y'
  FROM   psb_entity_set pes
        ,psb_entity pe
        ,psb_entity_assignment pea
  WHERE  pes.entity_set_id = p_parameter_id
  AND    pes.entity_type = 'PARAMETER'
  AND    pe.entity_type='PARAMETER'
  AND    pe.entity_subtype='POSITION'
  AND    pea.entity_id = pe.entity_id
  AND    pea.entity_set_id = pes.entity_set_id;

/*end bug:5753424*/

BEGIN

     /*start bug:5753424: procedure level logging*/
    if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      'PSB/LOCAL_PARAM_SET/PSBVBRVB/Revise_Projections_CP',
      'BEGIN Revise_Projections_CP');
     end if;
     /*end bug:5753424:end procedure level log*/

  FND_FILE.Put_Line( FND_FILE.OUTPUT,
   'Revise Projections for Budget Revision Batch Number : ' ||p_budget_revision_id);

  -- Enforce Concurrency Control

  PSB_CONCURRENCY_CONTROL_PVT.Enforce_Concurrency_Control
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_concurrency_class => 'BUDGET_REVISION_CREATION',
      p_concurrency_entity_name => 'BUDGET_REVISION',
      p_concurrency_entity_id => p_budget_revision_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  end if;

  For C_Budget_Group_Rec in C_Budget_Group
  Loop
  l_data_extract_id := Find_System_Data_Extract
                ( p_budget_group_id  => C_Budget_Group_Rec.budget_group_id);
  l_currency_code   := c_budget_group_rec.currency_code;

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
     raise FND_API.G_EXC_ERROR;
  end if;
  End Loop;

  /*Bug:5753424: start*/
  IF p_param_type IN ('ACCOUNT') THEN

  FOR c_parameter_rec IN c_parameters(l_param_type) LOOP

     /*start bug:5753424: statement level logging*/
    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
      'PSB/LOCAL_PARAM_SET/PSBVBRVB/Revise_Projections_CP',
      'Before call to Create_Mass_Revision_Entries for account parameter id:'||c_parameter_rec.parameter_id);
     end if;
     /*end bug:5753424:end statement level log*/

   Create_Mass_Revision_Entries
   (p_api_version            => 1.0,
    p_init_msg_list          => FND_API.G_TRUE,
    p_commit                 => FND_API.G_FALSE,
    p_validation_level       => FND_API.G_VALID_LEVEL_NONE,
    p_return_status          => l_return_status,
    p_msg_count              => l_msg_count,
    p_msg_data               => l_msg_data,
    p_data_extract_id        => l_data_extract_id,
    p_budget_revision_id     => p_budget_revision_id,
    p_parameter_id           => c_parameter_rec.parameter_id
    );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

      /*start bug:5753424: statement level logging*/
     if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
       'PSB/LOCAL_PARAM_SET/PSBVBRVB/Revise_Projections_CP',
       'Exception due to call - Create_Mass_Revision_Entries for account parameter id:'||c_parameter_rec.parameter_id);
      end if;
      /*end bug:5753424:end statement level log*/

     FND_MESSAGE.SET_NAME('PSB','PSB_LPS_FAILURE_MSG');
     FND_MESSAGE.SET_TOKEN('LOCAL_PARAM_SET',c_parameter_rec.parameter_set_name);
     FND_MESSAGE.SET_TOKEN('LOCAL_PARAM',    c_parameter_rec.parameter_name);
     FND_MESSAGE.SET_TOKEN('ERROR_TRAPPED',  l_msg_data);
     FND_MSG_PUB.ADD;
     l_exception := 'Y';

     EXIT;

    END IF;

    END LOOP;

   ELSIF p_param_type IN ('POSITION') THEN

	FOR c_ele_param_rec IN c_ele_param_exists LOOP
	  l_element_param_exists := 'Y';
	END LOOP;

	FOR c_pos_param_rec IN c_pos_param_exists LOOP
	  l_position_param_exists := 'Y';
	END LOOP;

       IF l_element_param_exists = 'Y' THEN

	  l_param_type := 'ELEMENT';

	 FOR c_parameter_rec IN c_parameters(l_param_type) LOOP

      /*start bug:5753424: statement level logging*/
     if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
       'PSB/LOCAL_PARAM_SET/PSBVBRVB/Revise_Projections_CP',
       'Before call - Create_Mass_Revision_Entries for element parameter id:'||c_parameter_rec.parameter_id);
      end if;
      /*end bug:5753424:end statement level log*/

	   Create_Mass_Revision_Entries
	   (p_api_version            => 1.0,
	    p_init_msg_list          => FND_API.G_TRUE,
	    p_commit                 => FND_API.G_FALSE,
	    p_validation_level       => FND_API.G_VALID_LEVEL_NONE,
	    p_return_status          => l_return_status,
	    p_msg_count              => l_msg_count,
	    p_msg_data               => l_msg_data,
	    p_data_extract_id        => l_data_extract_id,
	    p_budget_revision_id     => p_budget_revision_id,
	    p_parameter_id           => c_parameter_rec.parameter_id
	    );

	    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

	    /*start bug:5753424: statement level logging*/
	   if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
	     'PSB/LOCAL_PARAM_SET/PSBVBRVB/Revise_Projections_CP',
	     'Exception due to call - Create_Mass_Revision_Entries for element parameter id:'||c_parameter_rec.parameter_id);
	    fnd_file.put_line(fnd_file.LOG,'Exception due to call - Create_Mass_Revision_Entries for element parameter id:'||c_parameter_rec.parameter_id);
	    end if;
	    /*end bug:5753424:end statement level log*/

	     FND_MESSAGE.SET_NAME('PSB','PSB_LPS_FAILURE_MSG');
	     FND_MESSAGE.SET_TOKEN('LOCAL_PARAM_SET',c_parameter_rec.parameter_set_name);
	     FND_MESSAGE.SET_TOKEN('LOCAL_PARAM',    c_parameter_rec.parameter_name);
	     FND_MESSAGE.SET_TOKEN('ERROR_TRAPPED',  l_msg_data);
	     FND_MSG_PUB.ADD;
	     l_exception := 'Y';

	     EXIT;

	    END IF;

	 END LOOP;
       END IF;  -- l_element_param_exists = 'Y'

 IF l_position_param_exists = 'Y' AND l_exception = 'N' THEN

   l_param_type := 'POSITION';

  FOR c_parameter_rec IN c_parameters(l_param_type) LOOP

    /*start bug:5753424: statement level logging*/
   if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
     'PSB/LOCAL_PARAM_SET/PSBVBRVB/Revise_Projections_CP',
     'proc call - Create_Mass_Revision_Entries for position parameter id:'||c_parameter_rec.parameter_id);
    fnd_file.put_line(fnd_file.LOG,'proc call - Create_Mass_Revision_Entries for position parameter id:'||c_parameter_rec.parameter_id);
    end if;
    /*end bug:5753424:end statement level log*/

	Create_Mass_Revision_Entries
	(p_api_version            => 1.0,
	 p_init_msg_list          => FND_API.G_TRUE,
	 p_commit                 => FND_API.G_FALSE,
         p_validation_level       => FND_API.G_VALID_LEVEL_NONE,
	 p_return_status          => l_return_status,
	 p_msg_count              => l_msg_count,
	 p_msg_data               => l_msg_data,
	 p_data_extract_id        => l_data_extract_id,
	 p_budget_revision_id     => p_budget_revision_id,
	 p_parameter_id           => c_parameter_rec.parameter_id
	 );

	 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

	 /*start bug:5753424: statement level logging*/
	 if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
	     'PSB/LOCAL_PARAM_SET/PSBVBRVB/Revise_Projections_CP',
	     'Exception due to call - Create_Mass_Revision_Entries for position parameter id:'||c_parameter_rec.parameter_id);
	   fnd_file.put_line(fnd_file.LOG,'Exception due to call - Create_Mass_Revision_Entries for position parameter id:'||c_parameter_rec.parameter_id);
	 end if;
	  /*end bug:5753424:end statement level log*/

	   FND_MESSAGE.SET_NAME('PSB','PSB_LPS_FAILURE_MSG');
	   FND_MESSAGE.SET_TOKEN('LOCAL_PARAM_SET',c_parameter_rec.parameter_set_name);
	   FND_MESSAGE.SET_TOKEN('LOCAL_PARAM',    c_parameter_rec.parameter_name);
	   FND_MESSAGE.SET_TOKEN('ERROR_TRAPPED',  l_msg_data);
	   FND_MSG_PUB.ADD;
	   l_exception := 'Y';

	   EXIT;

	  END IF;

    END LOOP;
  END IF;  --l_position_param_exists = 'Y' AND l_exception = 'N'


  ELSE
   /*Bug:5753424 End*/

   Create_Mass_Revision_Entries
   (p_api_version            => 1.0,
    p_init_msg_list          => FND_API.G_TRUE,
    p_commit                 => FND_API.G_FALSE,
    p_validation_level       => FND_API.G_VALID_LEVEL_NONE,
    p_return_status          => l_return_status,
    p_msg_count              => l_msg_count,
    p_msg_data               => l_msg_data,
    p_data_extract_id        => l_data_extract_id,
    p_budget_revision_id     => p_budget_revision_id,
    p_parameter_id           => p_parameter_id
    );

 /*Bug:5753424 start*/
    END IF;
   /*Bug:5753424 End*/


   -- Bug#4571412
   -- Set the CP status to Warning if
   -- Note updation had errors.
   IF NVL(PSB_BUDGET_REVISIONS_PVT.g_soft_error_flag, 'N') ='Y' THEN
     l_set_CP_status
       := FND_CONCURRENT.SET_COMPLETION_STATUS
          (status  => 'WARNING',
           message => NULL
          );
   END IF;

   if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  end if;

   Apply_Constraints
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_validation_status => l_validation_status,
      p_budget_revision_id => p_budget_revision_id,
      p_constraint_set_id => g_constraint_set_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_concurrency_class => 'BUDGET_REVISION_CREATION',
      p_concurrency_entity_name => 'BUDGET_REVISION',
      p_concurrency_entity_id => p_budget_revision_id);

   if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_ERROR;
   end if;

    /* Start Bug No. 2322856 */
--  PSB_MESSAGE_S.Print_Success;
    /* End Bug No. 2322856 */
  retcode := 0 ;

 /*Bug:5753424: Start*/
   COMMIT WORK;
 /*Bug:5753424: End*/


  /*start bug:5753424: procedure level logging*/
  if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
   'PSB/LOCAL_PARAM_SET/PSBVBRVB/Revise_Projections_CP',
   'END Revise_Projections_CP');
  end if;
/*end bug:5753424:end procedure level log*/

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
                               p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
                                p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
   WHEN OTHERS THEN
     --
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
                               l_api_name  ) ;
     END IF ;
     --
     l_return_status := FND_API.G_RET_STS_ERROR;

     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
                                 p_print_header =>  FND_API.G_TRUE );
     --
     retcode := 2 ;
     COMMIT WORK ;
     --
END Revise_Projections_CP;

/*===========================================================================+
 |                      PROCEDURE Delete_Budget_Revision_CP                  |
 +===========================================================================*/
--
-- This is the execution file for the concurrent program 'Maintain Budget
-- Account Codes'.
--
PROCEDURE Delete_Budget_Revision_CP
( errbuf                      OUT  NOCOPY      VARCHAR2,
  retcode                     OUT  NOCOPY      VARCHAR2,
  p_from_budget_revision_id   IN       NUMBER,
  p_to_budget_revision_id     IN       NUMBER,
  p_submission_status         IN       VARCHAR2) IS

    l_api_name         CONSTANT VARCHAR2(30)   := 'Delete_Budget_Revision_CP' ;
    l_api_version      CONSTANT NUMBER         :=  1.0 ;
    --
    l_return_status             VARCHAR2(1) ;
    l_msg_count                 NUMBER ;
    l_msg_data                  VARCHAR2(2000) ;
    --
    l_string                   VARCHAR2(25) ;

  CURSOR l_budget_revisions_csr IS
  SELECT budget_revision_id
  FROM   psb_budget_revisions
  WHERE  budget_revision_id BETWEEN p_from_budget_revision_id
  AND    p_to_budget_revision_id
  AND    submission_status = p_submission_status;

  CURSOR l_budget_rev_csr IS
  SELECT budget_revision_id
  FROM   psb_budget_revisions
  WHERE  budget_revision_id BETWEEN p_from_budget_revision_id
  AND    p_to_budget_revision_id;

BEGIN
  --
  SAVEPOINT Delete_Budget_Revision_CP_Pvt ;
  --

  If p_submission_status IN ('A', 'R') THEN

  FOR l_budget_revisions_rec IN l_budget_revisions_csr
  LOOP
  Delete_Budget_Revision
  (
     p_api_version             =>   1.0 ,
     p_init_msg_list           =>   FND_API.G_TRUE,
     p_commit                  =>   FND_API.G_FALSE,
     p_validation_level        =>   FND_API.G_VALID_LEVEL_FULL,
     p_return_status           =>   l_return_status,
     p_msg_count               =>   l_msg_count,
     p_msg_data                =>   l_msg_data,
     --
     p_budget_revision_id      =>   l_budget_revisions_rec.budget_revision_id
  );
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --
  END LOOP;
  ELSE

  FOR l_budget_revisions_rec IN l_budget_rev_csr
  LOOP
  Delete_Budget_Revision
  (
     p_api_version             =>   1.0 ,
     p_init_msg_list           =>   FND_API.G_TRUE,
     p_commit                  =>   FND_API.G_FALSE,
     p_validation_level        =>   FND_API.G_VALID_LEVEL_FULL,
     p_return_status           =>   l_return_status,
     p_msg_count               =>   l_msg_count,
     p_msg_data                =>   l_msg_data,
     --
     p_budget_revision_id      =>   l_budget_revisions_rec.budget_revision_id
  );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  END LOOP;

  END IF;

  --
  retcode := 0 ;
  COMMIT WORK;
  --
EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Delete_Budget_Revision_CP_Pvt ;
    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
                                p_print_header =>  FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Delete_Budget_Revision_CP_Pvt ;
    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
                                p_print_header =>  FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Delete_Budget_Revision_CP_Pvt ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
                               l_api_name  ) ;
    END IF ;
    --
    PSB_MESSAGE_S.Print_Error ( p_mode         =>  FND_FILE.LOG ,
                                p_print_header =>  FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
END Delete_Budget_Revision_CP ;

/* ----------------------------------------------------------------------- */

-- Add Token and Value to the Message Token array

PROCEDURE message_token(tokname IN VARCHAR2,
                        tokval  IN VARCHAR2) AS

Begin

  if no_msg_tokens is null then
    no_msg_tokens := 1;
  else
    no_msg_tokens := no_msg_tokens + 1;
  end if;

  msg_tok_names(no_msg_tokens) := tokname;
  msg_tok_val(no_msg_tokens) := tokval;

END message_token;

/* ----------------------------------------------------------------------- */

-- Define a Message Token with a Value and set the Message Name

-- Calls FND_MESSAGE server package to set the Message Stack. This message is
-- retrieved by the calling program.

PROCEDURE add_message(appname IN VARCHAR2,
                      msgname IN VARCHAR2) AS

  i  BINARY_INTEGER;

Begin

  if ((appname is not null) and
      (msgname is not null)) then

    FND_MESSAGE.SET_NAME(appname, msgname);

    if no_msg_tokens is not null then

      for i in 1..no_msg_tokens loop
        FND_MESSAGE.SET_TOKEN(msg_tok_names(i), msg_tok_val(i));
      end loop;

    end if;

    FND_MSG_PUB.Add;

  end if;

  -- Clear Message Token stack

  no_msg_tokens := 0;

END add_message;


/* Budget Revision Rules Enhancement Start */
/*===========================================================================+
 |                      PROCEDURE Apply_Revision_Rules                  |
 +===========================================================================*/
--
-- This procedure has been added for validating the Budget Revision Rules
--

PROCEDURE Apply_Revision_Rules
( p_api_version                 IN   NUMBER,
  p_validation_level            IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY  VARCHAR2,
  p_validation_status           OUT  NOCOPY  VARCHAR2,
  p_budget_revision_id          IN   NUMBER
)
IS
  --
  l_return_status               VARCHAR2(1);
  l_rule_validation_status      VARCHAR2(1);
  l_ruleset_validation_status   VARCHAR2(1);
  l_budget_group_id             NUMBER(20);

  /* Bug 3622182 Start */
  --  l_transaction_type            VARCHAR2(2);
  l_transaction_type            VARCHAR2(30);
  /* Bug 3622182 End */

  l_chart_of_accounts_id        NUMBER;
  l_severity_level              NUMBER;
  l_constraint_threshold        NUMBER;
  l_rule_set_name               VARCHAR2(30);
  l_description                 VARCHAR2(2000) := NULL;
  l_cnt                         NUMBER := 0;
  l_ctr                         NUMBER := 0;
  /*For Bug No : 2150471 Start*/
  l_apply_message               VARCHAR2(2000);
  l_balance_message             VARCHAR2(2000);
  l_con_segments                VARCHAR2(233);
  /*For Bug No : 2150471 End*/

  /* Start for bug: 5654673*/
  l_segment_name                VARCHAR2(500);
  l_ind                         NUMBER := 0;
  l_within_segments           VARCHAR2(1) := 'N';

  TYPE seg_record IS RECORD (segment VARCHAR2(30),
                             validation_status VARCHAR2(1));
  TYPE segment_tab_type IS TABLE of seg_record;

  l_segment_tab                segment_tab_type := segment_tab_type();
 /* End for bug: 5654673*/

  /*For Bug No : 2129723 Start*/
  l_acct_exists                 VARCHAR2(10);
  CURSOR c_acct_exists(l_rule_id NUMBER) IS
     SELECT 'exists' result FROM dual WHERE EXISTS
      (
        SELECT bra.code_combination_id
          FROM PSB_BUDGET_REVISION_LINES brl,
               PSB_BUDGET_REVISION_ACCOUNTS bra
         WHERE brl.budget_revision_id = p_budget_revision_id
           AND bra.budget_revision_acct_line_id = brl.budget_revision_acct_line_id
           /*For Bug No : 2161125 Start*/
           AND bra.position_id IS  NULL
           /*For Bug No : 2161125 End*/
           AND EXISTS (SELECT 1
                         FROM PSB_BUDGET_ACCOUNTS ba,
                              PSB_SET_RELATIONS_V sr
                        WHERE ba.code_combination_id = bra.code_combination_id
                          AND ba.account_position_set_id = sr.account_position_set_id
                          AND sr.rule_id = l_rule_id
                          AND sr.account_or_position_type = 'A'
                          AND sr.apply_balance_flag = 'A'
                      )
           AND EXISTS (SELECT 1
                         FROM PSB_ENTITY ent
                        WHERE ent.entity_id = l_rule_id
                          AND (   (ent.apply_account_set_flag = 'B')
/* Bug No 2144364 Start */
----                           OR (ent.apply_account_set_flag = bra.revision_type)
                               OR (ent.apply_account_set_flag =
                                                DECODE(SIGN(bra.revision_amount), -1,
                                                        DECODE(bra.revision_type, 'I', 'D', 'I'), bra.revision_type)
                                  )
/* Bug No 2144364 End */
                              )
                      )
/* Bug No 2133484 Start */
           AND EXISTS (SELECT 1
                         FROM PSB_RULE_TRANSACTION_TYPE rtt
                        WHERE rtt.rule_id = l_rule_id
                          AND rtt.transaction_type = l_transaction_type
                       -- Next 1 line added for Bug # 2123930
                          AND rtt.enable_flag = 'Y'
                      )
/* Bug No 2133484 End */
/* Bug No 2135165 Start */
           AND EXISTS (SELECT 1 FROM PSB_ENTITY_ASSIGNMENT ea, gl_sets_of_books sob, gl_periods_v gp
                        WHERE ea.entity_set_id = g_brr_rule_set_id
                          AND ea.entity_id = l_rule_id
                          AND sob.set_of_books_id = g_brr_sob_id
                          AND gp.period_set_name = sob.period_set_name
                          AND gp.adjustment_period_flag = 'N'
                          AND gp.period_name = bra.gl_period_name
                          AND (((ea.effective_start_date <= gp.end_date)
                          AND (ea.effective_end_date IS NULL))
                                OR ((ea.effective_start_date BETWEEN gp.start_date AND gp.end_date)
                                OR (ea.effective_end_date BETWEEN gp.start_date AND gp.end_date)
                                OR ((ea.effective_start_date < gp.start_date)
                                        AND (ea.effective_end_date > gp.end_date))))
                        )
/* Bug No 2135165 End */
      );
  /*For Bug No : 2129723 End*/

  cursor c_Brrule is
     SELECT  rra.rule_set_id, rra.rule_id, rra.name, rra.rule_type,
             rra.severity_level, rra.apply_account_set_flag,
             rra.balance_account_set_flag
     FROM    PSB_REVISION_RULE_ASSIGNMENT_V rra
     WHERE   rra.rule_set_id IN (
               SELECT  rrs.rule_set_id
               FROM    PSB_REVISION_RULE_SETS_V rrs
               WHERE   rrs.enable_flag = 'Y'
               and rrs.budget_group_id in (select budget_group_id
                        FROM    PSB_BUDGET_GROUPS
                        WHERE   budget_group_type = 'R'
                        START WITH budget_group_id = l_budget_group_id
                        CONNECT BY PRIOR parent_budget_group_id = budget_group_id));

BEGIN
  --

  SELECT budget_group_id, transaction_type
    INTO l_budget_group_id, l_transaction_type
    FROM psb_budget_revisions_v
   WHERE budget_revision_id = p_budget_revision_id ;
  --
  SELECT chart_of_accounts_id,
/* Bug No 2135165 Start */
         set_of_books_id
/* Bug No 2135165 End */
    INTO l_chart_of_accounts_id,
/* Bug No 2135165 Start */
         g_brr_sob_id
/* Bug No 2135165 End */
    FROM gl_sets_of_books
   WHERE set_of_books_id = (SELECT b.set_of_books_id FROM PSB_BUDGET_GROUPS a,
                PSB_BUDGET_GROUPS b
                WHERE a.budget_group_id = l_budget_group_id
                and nvl(a.root_budget_group_id, a.budget_group_id) = b.budget_group_id);
  --
  /*For Bug No : 2125969 Start*/
  IF g_constraint_set_id IS NULL THEN
  BEGIN
    DELETE FROM PSB_ERROR_MESSAGES
     WHERE source_process = 'BUDGET_REVISION'
       AND process_id = p_budget_revision_id;
  END;
  END IF;
  /*For Bug No : 2125969 End*/

  FOR c_Brrule_Rec IN c_Brrule LOOP
    BEGIN

   /* Start for bug:5654673 */
      l_within_segments := 'N';
      l_ind := 0;
   /* End for bug: 5654673 */

/* Bug No 2135165 Start */
    g_brr_rule_set_id := c_Brrule_Rec.rule_set_id;
/* Bug No 2135165 End */
      -- Call this procedure which apply rules for individual CCIDs
        SELECT name, constraint_threshold
          INTO l_rule_set_name, l_constraint_threshold
          FROM psb_revision_rule_sets_v
         WHERE rule_set_id = c_Brrule_Rec.rule_set_id AND
        /*For Bug No : 2125969 Start*/
               --budget_group_id = l_budget_group_id  AND
        /*For Bug No : 2125969 End*/
               enable_flag = 'Y';
        l_severity_level := c_Brrule_Rec.severity_level;
      --
      /*For Bug No : 2129723 Start*/
      l_acct_exists := 'Not exists';
      FOR c_acct_exists_rec IN c_acct_exists(c_Brrule_Rec.rule_id) LOOP
        l_acct_exists := c_acct_exists_rec.result;
      END LOOP;

      IF (l_acct_exists <> 'Not exists' ) THEN
      BEGIN
        /*For Bug No : 2129723 End*/
        g_no_ccids := 0;
        /*For Bug No : 2150471 End*/


        if c_Brrule_Rec.rule_type in ('TEMPORARY', 'PERMANENT') then
            Apply_Detail_Revision_Rules
           (
            p_return_status             =>      l_return_status,
            p_rule_validation_status    =>      l_rule_validation_status,
            p_budget_revision_id        =>      p_budget_revision_id,
            p_rule_id                   =>      c_Brrule_Rec.rule_id,
            p_rule_type                 =>      c_Brrule_Rec.rule_type,
            p_apply_account_set_flag    =>      c_Brrule_Rec.apply_account_set_flag,
            p_balance_account_set_flag  =>      c_Brrule_Rec.balance_account_set_flag,
            p_segment_name              =>      NULL,
            p_application_column_name   =>      NULL,
            p_chart_of_accounts_id      =>      l_chart_of_accounts_id
           );

        else
         SELECT count(*) into l_cnt
         FROM   PSB_RULE_WITHIN_SEGMENT
         WHERE  rule_id = c_Brrule_Rec.rule_id;

         if l_cnt = 0 then
            Apply_Detail_Revision_Rules
           (
            p_return_status             =>      l_return_status,
            p_rule_validation_status    =>      l_rule_validation_status,
            p_budget_revision_id        =>      p_budget_revision_id,
            p_rule_id                   =>      c_Brrule_Rec.rule_id,
            p_rule_type                 =>      c_Brrule_Rec.rule_type,
            p_apply_account_set_flag    =>      c_Brrule_Rec.apply_account_set_flag,
            p_balance_account_set_flag  =>      c_Brrule_Rec.balance_account_set_flag,
            p_segment_name              =>      NULL,
            p_application_column_name   =>      NULL,
            p_chart_of_accounts_id      =>      l_chart_of_accounts_id
           );
         else

         for c_rule_seg in (Select segment_name, application_column_name
                        from psb_rule_within_segment
                        where rule_id = c_Brrule_Rec.rule_id)
         Loop
            /*Start bug:5654673*/
            l_within_segments := 'Y';
            l_ind := l_ind + 1;
            l_segment_tab.EXTEND;
            l_segment_tab(l_ind).segment := c_rule_seg.segment_name;
            l_segment_tab(l_ind).validation_status := null;
            /*End bug:5654673*/
            Apply_Detail_Revision_Rules
            (
             p_return_status            =>      l_return_status,
             p_rule_validation_status   =>      l_rule_validation_status,
             p_budget_revision_id       =>      p_budget_revision_id,
             p_rule_id                  =>      c_Brrule_Rec.rule_id,
             p_rule_type                =>      c_Brrule_Rec.rule_type,
             p_apply_account_set_flag   =>      c_Brrule_Rec.apply_account_set_flag,
             p_balance_account_set_flag =>      c_Brrule_Rec.balance_account_set_flag,
             p_segment_name             =>      c_rule_seg.segment_name,
             p_application_column_name  =>      c_rule_seg.application_column_name,
             p_chart_of_accounts_id     =>      l_chart_of_accounts_id
           );

           if l_rule_validation_status = 'F' then
              l_rule_validation_status := 'F';
             /*Start for bug:5654673*/
              l_segment_tab(l_ind).validation_status := l_rule_validation_status;
             /*End for bug:5654673*/
           end if;
          End Loop;
         end if;
        end if;

/* Bug No 2133484 Start */
--- Commented for the fix done.
/*      if l_rule_validation_status = 'S' then
          Select count(*) into l_ctr
          from psb_rule_transaction_type
          where rule_id = c_Brrule_Rec.rule_id
          and transaction_type = l_transaction_type
          -- Following 1 line added for Bug # 2123930
          and enable_flag = 'Y';

          IF l_ctr > 0 THEN
             l_rule_validation_status := 'S';
          Else
             l_rule_validation_status := 'F';
          End if;
        end if;*/
/* Bug No 2133484 End */

      /*For Bug No : 2129723 Start*/
      END;
      ELSE
      BEGIN
        l_rule_validation_status := 'S';
      END;
      END IF;
      /*For Bug No : 2129723 End*/

      --
   /* Start: 5654673:*/
      --commented the below condition for bug:5654673
      --IF l_rule_validation_status = 'F' THEN
  IF l_within_segments IN ('N','Y') THEN
    IF l_rule_validation_status = 'F' AND l_within_segments = 'N' THEN
    /* End: 5654673*/
        /*For Bug No : 2125969 Start*/
        --commented because of the error has to be inserted into the table
        --irrespective of the threshold level
        --IF l_severity_level > l_constraint_threshold  THEN    -- Absolute
        /*For Bug No : 2125969 End*/

          /*For Bug No : 2150471 Start*/
          message_token('RULSET', l_rule_set_name);
          message_token('THRESHOLD', l_constraint_threshold);
          message_token('SEVERITY', l_severity_level);
          /*For Bug No : 2150471 End*/
          message_token('RULNAME', c_Brrule_Rec.name);
          message_token('RULETYPE', c_Brrule_Rec.rule_type);
          add_message('PSB', 'PSB_REVISION_RULE_VIOLATION');

          l_description := FND_MSG_PUB.Get
                          (p_encoded => FND_API.G_FALSE);
          FND_MSG_PUB.Delete_Msg;

      /*Start bug:5654673*/
     ELSIF l_within_segments = 'Y' THEN
       FOR i in 1..l_segment_tab.COUNT LOOP
          IF l_segment_tab(i).validation_status = 'F' THEN
               l_rule_validation_status := 'F';
            IF l_segment_name IS NULL THEN
               l_segment_name := l_segment_tab(i).segment;
            ELSE
               l_segment_name := l_segment_name||','||l_segment_tab(i).segment;
            END IF;
          END IF;
       END LOOP;
       IF l_rule_validation_status = 'F' THEN
        message_token('RULSET', l_rule_set_name);
        message_token('THRESHOLD', l_constraint_threshold);
        message_token('SEVERITY', l_severity_level);
        message_token('RULNAME', c_Brrule_Rec.name);
        message_token('RULETYPE', c_Brrule_Rec.rule_type);
        message_token('SEGMENT', l_segment_name);
        add_message('PSB', 'PSB_REVISION_RULE_VIOLATION_SG');

        l_description := FND_MSG_PUB.Get
            (p_encoded => FND_API.G_FALSE);
        FND_MSG_PUB.Delete_Msg;

      END IF;
    END IF;
    IF l_rule_validation_status = 'F' THEN
    /* End for bug:5654673*/

          /*For Bug No : 2150471 Start*/
          l_apply_message := NULL;
          l_balance_message := NULL;
          --Pls. do not change the formatted new line characters below.
          --as AD coding standards doesn't allow chr(10), it has been changed
          FOR l_index IN 1..g_no_ccids LOOP
            SELECT concatenated_segments INTO l_con_segments
              FROM GL_CODE_COMBINATIONS_KFV
             WHERE code_combination_id = g_ccid_rec(l_index).ccid;
            IF (NVL(g_ccid_rec(l_index).apply_balance_flag,'A') = 'A') THEN
              l_apply_message := l_apply_message||fnd_global.local_chr(10)||l_con_segments;
            ELSIF (g_ccid_rec(l_index).apply_balance_flag = 'B') THEN
              l_balance_message := l_balance_message||fnd_global.local_chr(10)||l_con_segments;
            END IF;
          END LOOP;

          l_description := l_description||l_apply_message;
          IF (c_Brrule_Rec.rule_type ='BALANCE') THEN
          /*bug:5654673: added the condition on l_within_segments*/
          IF l_within_segments = 'N' THEN
          /*End of addition: 5654673*/
            add_message('PSB', 'PSB_REV_RULE_BALANCE_ACCTS');
            l_apply_message := FND_MSG_PUB.Get
                               (p_encoded => FND_API.G_FALSE);
            FND_MSG_PUB.Delete_Msg;
          /*start for bug:5654673*/
          ELSIF l_within_segments = 'Y' THEN
             message_token('SEGMENT', l_segment_name);
            add_message('PSB', 'PSB_REV_RULE_BALANCE_ACCTS_SEG');
            l_apply_message := FND_MSG_PUB.Get
                   (p_encoded => FND_API.G_FALSE);
            FND_MSG_PUB.Delete_Msg;
          END IF;
          /*End of addition: 5654673*/
            l_description := l_description||fnd_global.local_chr(10)||l_apply_message||l_balance_message;
          END IF;
          /*For Bug No : 2150471 End*/


          insert into PSB_ERROR_MESSAGES
                 (Concurrent_Request_ID,
                  Process_ID,
                  Source_Process,
                  Description,
                  Creation_Date,
                  Created_By)
          values (FND_GLOBAL.CONC_REQUEST_ID,
                  p_budget_revision_id,
                  'BUDGET_REVISION',
                  l_description,
                  sysdate,
                  FND_GLOBAL.USER_ID);
     /*start bug: 5654673*/
     END IF;
     /*end bug: 5654673*/
        /*For Bug No : 2125969 Start*/
        --END IF;
        /*For Bug No : 2125969 Start*/
      End IF;
      --
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         raise FND_API.G_EXC_ERROR;
      END IF;


      if (l_rule_validation_status = 'F'
      /*For Bug No : 2125969 Start*/
        --If severity is greater than or equal to thresold, wee need to treat it as an error
         AND l_severity_level >= l_constraint_threshold)
      /*For Bug No : 2125969 Endt*/   then
         p_validation_status := 'F';
      end if;
    /*Start bug: 5654673*/
     IF l_within_segments = 'Y' THEN
        l_segment_tab.DELETE;
     END IF;
    /*End bug:5654673*/
    END;
  END LOOP;
  --
  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;
  --
EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
  --
  WHEN OTHERS THEN
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  --
END Apply_Revision_Rules;


/*===========================================================================+
 |                        PROCEDURE Apply_Detail_Revision_Rules              |
 +===========================================================================*/

PROCEDURE Apply_Detail_Revision_Rules
(
  p_return_status               OUT  NOCOPY  VARCHAR2,
  p_rule_validation_status      OUT  NOCOPY  VARCHAR2,
  p_budget_revision_id          IN   NUMBER,
  p_rule_id                     IN   NUMBER,
  p_rule_type                   IN   VARCHAR2,
  p_apply_account_set_flag      IN   VARCHAR2,
  p_balance_account_set_flag    IN   VARCHAR2,
  p_segment_name                IN   VARCHAR2,
  p_application_column_name     IN   VARCHAR2,
  p_chart_of_accounts_id        IN   NUMBER
)
IS
--
  l_return_status               VARCHAR2(1);
  l_apply_cr                    NUMBER := 0;
  l_apply_dr                    NUMBER := 0;
  l_balance_cr                  NUMBER := 0;
  l_balance_dr                  NUMBER := 0;
  l_seg_apply_cr                fnd_flex_ext.SegmentArray;
  l_seg_apply_dr                fnd_flex_ext.SegmentArray;
  l_seg_balance_cr              fnd_flex_ext.SegmentArray;
  l_seg_balance_dr              fnd_flex_ext.SegmentArray;

  l_cnt                         NUMBER := 0;
  --
  -- CCIDs assigned to the Revision Rule : select CCIDs that also belong to the Budget Group Hierarchy
  --
/*For Bug No : 2127951 Start*/
  TYPE SegmentCurTyp IS REF CURSOR;
  l_seg_cur             SegmentCurTyp;
  TYPE AcctCurTyp IS REF CURSOR;
  l_acct_cur            AcctCurTyp;
  l_seg_sql             VARCHAR2(3000);
  l_acct_sql            VARCHAR2(3000);
  l_acct_sql_temp       VARCHAR2(3000);
  l_seg_value           VARCHAR2(30);
  l_cc_id               NUMBER(15);
  l_apply_balance_flag  VARCHAR2(5);
  --
/*For Bug No : 2127951 End*/
/*For Bug No : 2150471 Start*/
  l_temp                NUMBER;
/*For Bug No : 2150471 End*/

  cursor c_CCID is
     SELECT  ba.code_combination_id, sr.apply_balance_flag
     FROM    PSB_BUDGET_ACCOUNTS ba, PSB_SET_RELATIONS_V sr
     WHERE   ba.account_position_set_id = sr.account_position_set_id
     AND     sr.account_or_position_type = 'A'
     AND     sr.rule_id = p_rule_id
/* Bug No 2135165 Start */
        AND  ba.code_combination_id in (SELECT bra.code_combination_id
                   FROM PSB_BUDGET_REVISION_LINES brl, PSB_BUDGET_REVISION_ACCOUNTS bra
                  WHERE brl.budget_revision_id = p_budget_revision_id
                    AND bra.budget_revision_acct_line_id = brl.budget_revision_acct_line_id
                    AND EXISTS (SELECT 1 FROM PSB_ENTITY_ASSIGNMENT ea, gl_sets_of_books sob, gl_periods_v gp
                                 WHERE ea.entity_set_id = g_brr_rule_set_id
                                   AND ea.entity_id = p_rule_id
                                   AND sob.set_of_books_id = g_brr_sob_id
                                   AND gp.period_set_name = sob.period_set_name
                                   AND gp.adjustment_period_flag = 'N'
                                   AND gp.period_name = bra.gl_period_name
                                   AND (((ea.effective_start_date <= gp.end_date)
                                        AND (ea.effective_end_date IS NULL))
                                        OR ((ea.effective_start_date BETWEEN gp.start_date AND gp.end_date)
                                        OR (ea.effective_end_date BETWEEN gp.start_date AND gp.end_date)
                                        OR ((ea.effective_start_date < gp.start_date)
                                                AND (ea.effective_end_date > gp.end_date))))
                                )
                  );
/* Bug No 2135165 End */

  --
BEGIN

  PSB_Flex_Mapping_PVT.Flex_Info(
                                 p_flex_code         =>  p_chart_of_accounts_id,
                                 p_return_status     =>  l_return_status
                                );
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    --
    raise FND_API.G_EXC_ERROR;
    --
  END IF;
  --
  --
 /*For Bug No : 2127951 Start*/
 --the following code has been commented because of the
 --initialization has to be done for each segment group
  /*FOR l_index IN 1..PSB_Flex_Mapping_PVT.g_num_segs  LOOP
   l_seg_apply_cr(l_index) := 0;
   l_seg_balance_cr(l_index) := 0;
   l_seg_apply_dr(l_index) := 0;
   l_seg_balance_dr(l_index) := 0;
  END LOOP;*/
  --
  /*For Bug No : 2127951 End*/

IF p_rule_type = 'BALANCE' THEN
      --
  /*For Bug No : 2127951 Start*/
  IF (p_application_column_name IS NULL) THEN
  /*For Bug No : 2127951 End*/
     FOR c_CCID_Rec IN c_CCID LOOP

         Process_Balance_Rule(
                              p_budget_revision_id        =>  p_budget_revision_id,
                              p_rule_id                   =>  p_rule_id,
                              p_apply_account_set_flag    =>  p_apply_account_set_flag,
                              p_balance_account_set_flag  =>  p_balance_account_set_flag,
                              p_segment_name              =>  p_segment_name,
                              p_application_column_name   =>  p_application_column_name,
                              p_ccid                      =>  c_CCID_Rec.code_combination_id,
                              p_apply_balance_flag        =>  c_CCID_Rec.apply_balance_flag,
                              p_apply_cr                  =>  l_apply_cr,
                              p_apply_dr                  =>  l_apply_dr,
                              p_balance_cr                =>  l_balance_cr,
                              p_balance_dr                =>  l_balance_dr,
                              p_seg_apply_cr              =>  l_seg_apply_cr,
                              p_seg_apply_dr              =>  l_seg_apply_dr,
                              p_seg_balance_cr            =>  l_seg_balance_cr,
                              p_seg_balance_dr            =>  l_seg_balance_dr,
                              p_return_status             =>  l_return_status
                             );
      END LOOP;
      --
      /*For Bug No : 2127951 Start*/

      IF p_application_column_name IS null THEN
        --
        IF ((l_apply_dr = l_balance_cr) AND (l_apply_cr = l_balance_dr))  THEN
          p_rule_validation_status  := 'S';
        ELSE
          p_rule_validation_status := 'F';
        END IF;
        --
      END IF;

  ELSIF (p_application_column_name IS NOT NULL) THEN

     l_seg_sql := 'SELECT DISTINCT glcc.'||p_application_column_name||
                    ' FROM gl_code_combinations glcc,'||
                          ' (SELECT DISTINCT bra.code_combination_id '||
                             ' FROM PSB_BUDGET_REVISION_LINES brl,'||
                                  ' PSB_BUDGET_REVISION_ACCOUNTS bra '||
                            ' WHERE brl.budget_revision_id = '||to_char(p_budget_revision_id)||
                              ' AND bra.budget_revision_acct_line_id = brl.budget_revision_acct_line_id'||
                          ' ) rcc'||
                   ' WHERE glcc.code_combination_id = rcc.code_combination_id';

     -- Bug 5030405 used bind variables in the following string
     l_acct_sql_temp := 'SELECT ba.code_combination_id, sr.apply_balance_flag '||
                                    ' FROM PSB_BUDGET_ACCOUNTS ba, PSB_SET_RELATIONS_V sr'||
                                   ' WHERE ba.account_position_set_id = sr.account_position_set_id'||
                                     ' AND sr.account_or_position_type = '||''''||'A'||''''||
                                     ' AND sr.rule_id = :b_rule_id'||
                                     ' AND ba.code_combination_id in (SELECT bra.code_combination_id '||
                                                   ' FROM PSB_BUDGET_REVISION_LINES brl,'||
                                                        ' PSB_BUDGET_REVISION_ACCOUNTS bra'||
                                                        ' WHERE brl.budget_revision_id = :b_budget_revision_id'||
                                                        ' AND bra.budget_revision_acct_line_id = brl.budget_revision_acct_line_id'||
                                                        ' AND EXISTS (SELECT 1 '||
                                                                      ' FROM PSB_ENTITY_ASSIGNMENT ea, gl_sets_of_books sob, gl_periods_v gp'||
                                                                      ' WHERE ea.entity_set_id = :b_brr_rule_set_id'||
                                                                      ' AND ea.entity_id = :b_rule_id'||
                                                                      ' AND sob.set_of_books_id = :b_brr_sob_id'||
                                                                      ' AND gp.period_set_name = sob.period_set_name'||
                                                                      ' AND gp.adjustment_period_flag = '||''''||'N' ||''''||
                                                                      ' AND gp.period_name = bra.gl_period_name'||
                                                                      ' AND (((ea.effective_start_date <= gp.end_date)'||
                                                                      ' AND (ea.effective_end_date IS NULL))'||
                                                                      ' OR ((ea.effective_start_date BETWEEN gp.start_date AND gp.end_date)'||
                                                                      ' OR (ea.effective_end_date BETWEEN gp.start_date AND gp.end_date)'||
                                                                      ' OR ((ea.effective_start_date < gp.start_date)'||
                                                                      ' AND (ea.effective_end_date > gp.end_date))))'||

                                                   ' ))'||

                                     ' AND EXISTS (SELECT 1 '||
                                                   ' FROM PSB_BUDGET_REVISION_LINES brl,'||
                                                        ' PSB_BUDGET_REVISION_ACCOUNTS bra'||
                                                        ' WHERE brl.budget_revision_id = :b_budget_revision_id'||
                                                        ' AND bra.budget_revision_acct_line_id = brl.budget_revision_acct_line_id'||
                                                        ' AND bra.code_combination_id = ba.code_combination_id)'||
                                     ' AND EXISTS (SELECT 1'||
                                                   ' FROM gl_code_combinations glcc'||
                                                   ' WHERE glcc.code_combination_id = ba.code_combination_id';


     OPEN l_seg_cur FOR l_seg_sql;

     LOOP
       FETCH l_seg_cur INTO l_seg_value;
       EXIT WHEN l_seg_cur%NOTFOUND;

       --for every segment initialize the array to zero values
       FOR l_index IN 1..PSB_Flex_Mapping_PVT.g_num_segs  LOOP
         l_seg_apply_cr(l_index) := 0;
         l_seg_balance_cr(l_index) := 0;
         l_seg_apply_dr(l_index) := 0;
         l_seg_balance_dr(l_index) := 0;
       END LOOP;


       l_acct_sql := l_acct_sql_temp||' AND glcc.'||p_application_column_name||' = '||''''||l_seg_value||''''||')';

       -- Bug 5030405 used using clause below
       OPEN l_acct_cur FOR l_acct_sql
       USING p_rule_id,
             p_budget_revision_id,
             g_brr_rule_set_id,
             p_rule_id,
             g_brr_sob_id,
             p_budget_revision_id;
       LOOP
         FETCH l_acct_cur INTO l_cc_id, l_apply_balance_flag;
         EXIT WHEN l_acct_cur%NOTFOUND;

         --Process each cc_id within the segment
                  Process_Balance_Rule(
                              p_budget_revision_id        =>  p_budget_revision_id,
                              p_rule_id                   =>  p_rule_id,
                              p_apply_account_set_flag    =>  p_apply_account_set_flag,
                              p_balance_account_set_flag  =>  p_balance_account_set_flag,
                              p_segment_name              =>  p_segment_name,
                              p_application_column_name   =>  p_application_column_name,
                              p_ccid                      =>  l_cc_id,
                              p_apply_balance_flag        =>  l_apply_balance_flag,
                              p_apply_cr                  =>  l_apply_cr,
                              p_apply_dr                  =>  l_apply_dr,
                              p_balance_cr                =>  l_balance_cr,
                              p_balance_dr                =>  l_balance_dr,
                              p_seg_apply_cr              =>  l_seg_apply_cr,
                              p_seg_apply_dr              =>  l_seg_apply_dr,
                              p_seg_balance_cr            =>  l_seg_balance_cr,
                              p_seg_balance_dr            =>  l_seg_balance_dr,
                              p_return_status             =>  l_return_status
                             );

       END LOOP;
       CLOSE l_acct_cur;
       --End of the segment validation cursor
       FOR l_index IN 1..PSB_Flex_Mapping_PVT.g_num_segs  LOOP
         IF ( l_seg_apply_dr(l_index) = l_seg_balance_cr(l_index) AND l_seg_apply_cr(l_index) = l_seg_balance_dr(l_index) )  THEN
           IF (p_rule_validation_status IS NULL OR p_rule_validation_status  <> 'F' ) THEN
             p_rule_validation_status  := 'S';
           END IF;
         ELSE
            p_rule_validation_status :=  'F';
            EXIT;
         END IF;

       END LOOP;
       --end of result validation loop
         IF (p_rule_validation_status  = 'F') THEN
           EXIT;
         END IF;
     END LOOP;
     CLOSE l_seg_cur;
     --End of the cc_id validation cursor

  END IF;
  --commented the following code because of the validations are to be done
  --seperately as per the application_column_name with in segment
  /*  IF p_application_column_name IS null THEN
      --
      IF ((l_apply_dr = l_balance_cr) AND (l_apply_cr = l_balance_dr))  THEN
        p_rule_validation_status  := 'S';
      ELSE
        p_rule_validation_status := 'F';
      END IF;
      --
    ELSIF p_application_column_name IS NOT null THEN
      --
      FOR l_index IN 1..PSB_Flex_Mapping_PVT.g_num_segs  LOOP
         IF ( l_seg_apply_dr(l_index) = l_seg_balance_cr(l_index) AND l_seg_apply_cr(l_index) = l_seg_balance_dr(l_index) )  THEN
           if p_rule_validation_status = 'F' then
              p_rule_validation_status := 'F';
           else
              p_rule_validation_status  := 'S';
           end if;
         ELSE
           p_rule_validation_status :=  'F';
           exit;
         END IF;
      END LOOP;
      --
    END IF;*/
      --
  /*For Bug No : 2127951 End*/

ELSIF p_rule_type IN ('PERMANENT', 'TEMPORARY') THEN
    --
    FOR c_CCID_Rec in c_CCID loop
        /*For Bug No : 2150471 Start*/
        --commented due to performance issues
        /*select count(bra.code_combination_id) into l_cnt
        from psb_budget_revision_accounts bra, psb_budget_revision_lines brl
        where bra.budget_revision_acct_line_id = brl.budget_revision_acct_line_id
        and brl.budget_revision_id = p_budget_revision_id
        and bra.code_combination_id = c_CCID_Rec.code_combination_id;*/

        l_temp := 1;
        LOOP
          EXIT WHEN ( (l_temp > g_no_ccids) OR (c_CCID_Rec.code_combination_id = g_ccid_rec(l_temp).ccid) );
          l_temp := l_temp + 1;
        END LOOP;
        IF (l_temp > g_no_ccids) THEN
          g_no_ccids := g_no_ccids + 1;
          g_ccid_rec(g_no_ccids).ccid := c_CCID_Rec.code_combination_id;
        END IF;
        --The following code is commented and calling it from out side of the loop
           /*Process_Perm_Temp_Rule(
                              p_budget_revision_id       =>  p_budget_revision_id,
                              p_rule_id                  =>  p_rule_id,
                              p_rule_type                =>  p_rule_type,
                              p_apply_account_set_flag   =>  p_apply_account_set_flag,
                              p_ccid                     =>  c_CCID_Rec.code_combination_id,
                              p_apply_balance_flag       =>  c_CCID_Rec.apply_balance_flag,
                              p_rule_validation_status   =>  p_rule_validation_status,
                              p_return_status            =>  l_return_status
                            );*/
        /*For Bug No : 2150471 End*/
    END LOOP;
        /*For Bug No : 2150471 Start*/
        Process_Perm_Temp_Rule(
                              p_budget_revision_id       =>  p_budget_revision_id,
                              p_rule_id                  =>  p_rule_id,
                              p_rule_type                =>  p_rule_type,
                              p_apply_account_set_flag   =>  NULL,
                              p_ccid                     =>  NULL,
                              p_apply_balance_flag       =>  NULL,
                              p_rule_validation_status   =>  p_rule_validation_status,
                              p_return_status            =>  l_return_status
                            );
        /*For Bug No : 2150471 End*/
    if p_rule_validation_status = 'F' then
      p_rule_validation_status := 'F';
    else
      p_rule_validation_status := 'S';
    end if;

    --
END IF;
  --

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      raise FND_API.G_EXC_ERROR;
  END IF;
  --
EXCEPTION
   --
   WHEN FND_API.G_EXC_ERROR THEN
     p_return_status := FND_API.G_RET_STS_ERROR;
   --
   WHEN OTHERS THEN
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   --
END Apply_Detail_Revision_Rules;


/*===========================================================================+
 |                        PROCEDURE Process_Balance_Rule                     |
 +===========================================================================*/

PROCEDURE Process_Balance_Rule
(
  p_return_status               OUT  NOCOPY             VARCHAR2,
  p_apply_cr                    IN  OUT  NOCOPY         NUMBER,
  p_apply_dr                    IN  OUT  NOCOPY         NUMBER,
  p_balance_cr                  IN  OUT  NOCOPY         NUMBER,
  p_balance_dr                  IN  OUT  NOCOPY         NUMBER,
  p_seg_apply_cr                IN  OUT  NOCOPY         fnd_flex_ext.SegmentArray,
  p_seg_apply_dr                IN  OUT  NOCOPY         fnd_flex_ext.SegmentArray,
  p_seg_balance_cr              IN  OUT  NOCOPY         fnd_flex_ext.SegmentArray,
  p_seg_balance_dr              IN  OUT  NOCOPY         fnd_flex_ext.SegmentArray,
  p_budget_revision_id          IN              NUMBER,
  p_rule_id                     IN              NUMBER,
  p_apply_account_set_flag      IN              VARCHAR2,
  p_balance_account_set_flag    IN              VARCHAR2,
  p_segment_name                IN              VARCHAR2,
  p_application_column_name     IN              VARCHAR2,
  p_ccid                        IN              NUMBER,
  p_apply_balance_flag          IN              VARCHAR2
)
IS
  -- Compute Sum of BR Account Lines (all Account Sets assigned to the Rule)
  l_revision_type               VARCHAR2(1);
  l_revision_value_type         VARCHAR2(1);
  l_account_type                VARCHAR2(1);
  l_revision_amount             NUMBER;
  l_budget_balance              NUMBER;
  l_chart_of_accounts_id        NUMBER;
  l_temp                        NUMBER;
/* Bug No 2156263 Start */
  l_num                         NUMBER;
/* Bug No 2156263 End */

  cursor c_SumAll is
     SELECT a.revision_type, a.revision_value_type, a.revision_amount,
             a.account_type, a.budget_balance
     FROM PSB_BUDGET_REVISION_LINES b,
          PSB_BUDGET_REVISION_ACCOUNTS a
     WHERE b.budget_revision_id = p_budget_revision_id
       AND a.budget_revision_acct_line_id = b.budget_revision_acct_line_id
       AND a.code_combination_id = p_ccid
       /*For Bug No : 2161125 Start*/
       AND a.position_id IS NULL;
       /*For Bug No : 2161125 End*/
  --
BEGIN
  --

  FOR c_sumall_rec IN c_sumall LOOP
     --
     l_revision_type := c_sumall_rec.revision_type ;
     l_revision_value_type := c_sumall_rec.revision_value_type;
     l_revision_amount := nvl(c_sumall_rec.revision_amount,0);
     l_account_type := c_sumall_rec.account_type;
     l_budget_balance := nvl(c_sumall_rec.budget_balance,0);
     l_temp := 1;
     --
     IF l_revision_value_type = 'P' THEN
       l_temp := nvl(l_budget_balance, 0) / 100;
     END IF;
     --

/* Bug No 2144364 Start */
    if l_revision_amount < 0 then
      if l_revision_type = 'I' then
         l_revision_type := 'D';
      else
         l_revision_type := 'I';
      end if;

      l_revision_amount := abs(l_revision_amount);
    end if;
/* Bug No 2144364 End */

    /*For Bug No : 2150471 Start*/
    IF ( ((p_apply_balance_flag = 'A') AND
          ((l_revision_type = 'I' AND p_apply_account_set_flag <> 'D')
            OR (l_revision_type = 'D' AND p_apply_account_set_flag <> 'I'))) OR
         ((p_apply_balance_flag = 'B') AND
          ((l_revision_type = 'I' AND p_balance_account_set_flag <> 'D')
            OR (l_revision_type = 'D' AND p_balance_account_set_flag <> 'I'))) ) THEN
    BEGIN
/* Bug No 2156263 Start */
-- Changed the variable name from 'l_temp' to 'l_num'
-- since 'l_temp' is being used for later on in this package for some purpose.
      l_num := 1;
      LOOP
        EXIT WHEN ( (l_num > g_no_ccids) OR ((p_ccid = g_ccid_rec(l_num).ccid) AND (p_apply_balance_flag = g_ccid_rec(l_num).apply_balance_flag)) );
        l_num := l_num + 1;
      END LOOP;
      IF (l_num > g_no_ccids) THEN
/* Bug No 2156263 End */
        g_no_ccids := g_no_ccids + 1;
        g_ccid_rec(g_no_ccids).ccid := p_ccid;
        g_ccid_rec(g_no_ccids).apply_balance_flag := p_apply_balance_flag;
      END IF;
    END;
    END IF;
    /*For Bug No : 2150471 End*/

     /*For Bug No : 2125969 Start*/
     --p_apply_account_set_flag, p_balance_account_set_flag variables
     --are added in the if conditions
     IF p_application_column_name is null THEN
        --
        IF p_apply_balance_flag = 'A' then
          IF l_account_type IN('A','E') THEN
          --
            IF (l_revision_type = 'I' AND p_apply_account_set_flag <> 'D') THEN
              p_apply_dr := p_apply_dr + nvl(l_revision_amount, 0) * l_temp;
            ELSIF (l_revision_type = 'D' AND p_apply_account_set_flag <> 'I') THEN
              p_apply_cr := p_apply_cr + nvl(l_revision_amount, 0) * l_temp;
            END IF;
            --
          ELSIF l_account_type IN('L','O','R') THEN
            IF (l_revision_type = 'I' AND p_apply_account_set_flag <> 'D') THEN
              p_apply_cr := p_apply_cr + nvl(l_revision_amount, 0) * l_temp;
            ELSIF (l_revision_type = 'D' AND p_apply_account_set_flag <> 'I') THEN
              p_apply_dr := p_apply_dr + nvl(l_revision_amount, 0) * l_temp;
            END IF;
          END IF;
        ELSIF p_apply_balance_flag = 'B' THEN
          IF l_account_type IN('A','E') THEN
            IF (l_revision_type = 'I' AND p_balance_account_set_flag <> 'D') THEN
              p_balance_dr := p_balance_dr + nvl(l_revision_amount, 0) * l_temp;
            ELSIF (l_revision_type = 'D' AND p_balance_account_set_flag <> 'I') THEN
              p_balance_cr := p_balance_cr + nvl(l_revision_amount, 0) * l_temp;
            END IF;
          ELSIF l_account_type IN('L','O','R') THEN
            IF (l_revision_type = 'I' AND p_balance_account_set_flag <> 'D') THEN
              p_balance_cr := p_balance_cr + nvl(l_revision_amount, 0) * l_temp;
            ELSIF (l_revision_type = 'D' AND p_balance_account_set_flag <> 'I') THEN
              p_balance_dr := p_balance_dr + nvl(l_revision_amount, 0) * l_temp;
            END IF;
          END IF;
        END IF;
     ELSIF p_application_column_name is not null THEN
     --
     FOR i in 1..PSB_Flex_Mapping_PVT.g_num_segs LOOP
      --
      IF PSB_Flex_Mapping_PVT.g_seg_name(i) = p_application_column_name THEN
      --
        IF p_apply_balance_flag = 'A' then
          IF l_account_type IN('A','E') THEN
            IF (l_revision_type = 'I' AND p_apply_account_set_flag <> 'D') THEN
              p_seg_apply_dr(i) := p_seg_apply_dr(i) + nvl(l_revision_amount, 0) * l_temp;
            ELSIF (l_revision_type = 'D' AND p_apply_account_set_flag <> 'I') THEN
              p_seg_apply_cr(i) := p_seg_apply_cr(i) + nvl(l_revision_amount, 0) * l_temp;
            END IF;
          ELSIF l_account_type IN('L','O','R') THEN
            IF (l_revision_type = 'I' AND p_apply_account_set_flag <> 'D') THEN
              p_seg_apply_cr(i) := p_seg_apply_cr(i) + nvl(l_revision_amount, 0) * l_temp;
            ELSIF (l_revision_type = 'D' AND p_apply_account_set_flag <> 'I') THEN
              p_seg_apply_dr(i) := p_seg_apply_dr(i) + nvl(l_revision_amount, 0) * l_temp;
            END IF;
          END IF;
        ELSIF p_apply_balance_flag = 'B' THEN
          IF l_account_type IN('A','E') THEN
            IF (l_revision_type = 'I' AND p_balance_account_set_flag <> 'D') THEN
              p_seg_balance_dr(i) := p_seg_balance_dr(i) + nvl(l_revision_amount, 0) * l_temp;
            ELSIF (l_revision_type = 'D' AND p_balance_account_set_flag <> 'I') THEN
              p_seg_balance_cr(i) := p_seg_balance_cr(i) + nvl(l_revision_amount, 0) * l_temp;
            END IF;
          ELSIF l_account_type IN('L','O','R') THEN
            IF (l_revision_type = 'I' AND p_balance_account_set_flag <> 'D') THEN
              p_seg_balance_cr(i) := p_seg_balance_cr(i) + nvl(l_revision_amount, 0) * l_temp;
            ELSIF (l_revision_type = 'D' AND p_balance_account_set_flag <> 'I') THEN
              p_seg_balance_dr(i) := p_seg_balance_dr(i) + nvl(l_revision_amount, 0) * l_temp;
            END IF;
          END IF;
        END IF;
      --
      END IF;
      --
     END LOOP;
     --
     END IF;
     --
     /*For Bug No : 2125969 End*/
  END LOOP;
  --

END Process_Balance_Rule;

/*===========================================================================+
 |                        PROCEDURE Process_Perm_Temp_Rule                   |
 +===========================================================================*/

PROCEDURE Process_Perm_Temp_Rule
(
  p_return_status               OUT  NOCOPY  VARCHAR2,
  p_rule_validation_status      OUT  NOCOPY  VARCHAR2,
  p_budget_revision_id          IN   NUMBER,
  p_rule_id                     IN   NUMBER,
  p_rule_type                   IN   VARCHAR2,
  p_apply_account_set_flag      IN   VARCHAR2,
  p_ccid                        IN   VARCHAR2,
  p_apply_balance_flag          IN   VARCHAR2
)
IS
  --
  --Compute Sum of BR Account Lines (all Account Sets assigned to the Rule)
  cursor c_type is
      SELECT DECODE(permanent_revision, 'Y', 'PERMANENT', 'TEMPORARY') permanent_revision
      FROM   PSB_BUDGET_REVISIONS
      WHERE  budget_revision_id = p_budget_revision_id;
  l_permanent_revision          VARCHAR2(30);
  --
BEGIN
  --

  FOR c_type_rec IN c_type LOOP
    l_permanent_revision := c_type_rec.permanent_revision;
  END LOOP;

  --
  IF l_permanent_revision = p_rule_type THEN
    p_rule_validation_status := 'S';
  ELSE
    p_rule_validation_status := 'F';
  END IF;

END Process_Perm_Temp_Rule;

/* Budget Revision Rules Enhancements End */

/* ----------------------------------------------------------------------- */
/* Bug No 1808330 Start */

PROCEDURE Create_Note
( p_return_status    OUT NOCOPY VARCHAR2
, p_account_line_id  IN         NUMBER
, p_position_line_id IN         NUMBER
, p_note             IN         VARCHAR2
, p_flex_code        IN         NUMBER  -- Bug#4571412
, p_cc_id            IN         NUMBER DEFAULT NULL -- Bug#4675858
) IS

  l_change_note      VARCHAR2(1);
  l_note_id          NUMBER;
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);

  -- Bug#4571412
  l_concat_segments     VARCHAR2(2000);
  l_code_combination_id NUMBER;
  l_message_text        VARCHAR2(4000);

  cursor c_acct_note_id is
    select note_id from PSB_BUDGET_REVISION_ACCOUNTS where budget_revision_acct_line_id = p_account_line_id;

  -- Bug#4571412
  -- Get the code_combination_id.
  CURSOR c_pos_note_id
  IS
  SELECT pbrp.note_id,
         pbra.code_combination_id
  FROM PSB_BUDGET_REVISION_POSITIONS pbrp, PSB_BUDGET_REVISION_ACCOUNTS pbra
  WHERE pbrp.budget_revision_pos_line_id = p_position_line_id
  AND pbrp.position_id = pbra.position_id;

BEGIN

  FND_PROFILE.GET
     (name => 'PSB_EDIT_CREATE_NOTES',
      val => l_change_note);

  if nvl(l_change_note, 'Y') = 'Y' then
  begin

    if p_account_line_id is not null and p_position_line_id is null then
       for c_acct_note_rec in c_acct_note_id loop
         l_note_id             := c_acct_note_rec.note_id;
	 l_code_combination_id := p_cc_id ; -- Bug#4675858
       end loop;
    elsif p_account_line_id is null and p_position_line_id is not null then
       for c_pos_note_rec in c_pos_note_id loop
         l_note_id := c_pos_note_rec.note_id;
	 l_code_combination_id := c_pos_note_rec.code_combination_id; -- Bug#4675858
       end loop;
    end if;

    if l_note_id is null then
    begin

      Insert into PSB_WS_ACCOUNT_LINE_NOTES
        (note_id, note, last_update_date, last_updated_by, last_update_login, created_by, creation_date)
      values (psb_ws_account_line_notes_s.nextval, p_note, sysdate, FND_GLOBAL.USER_ID, FND_GLOBAL.LOGIN_ID, FND_GLOBAL.USER_ID, sysdate)
      returning note_id into l_note_id;

      if p_account_line_id is not null then
         update PSB_BUDGET_REVISION_ACCOUNTS
         set note_id = l_note_id
         where budget_revision_acct_line_id = p_account_line_id;
      elsif p_position_line_id is not null then
         update PSB_BUDGET_REVISION_POSITIONS
         set note_id = l_note_id
         where budget_revision_pos_line_id = p_position_line_id;
      end if;

    end;
    else
      -- Bug#4571412
      BEGIN
        Update PSB_WS_ACCOUNT_LINE_NOTES
	SET note = note || FND_GLOBAL.NewLine || p_note,
	    last_update_date = sysdate,
	    last_updated_by = FND_GLOBAL.USER_ID,
	    last_update_login = FND_GLOBAL.LOGIN_ID,
	    created_by = FND_GLOBAL.USER_ID,
	    creation_date = sysdate
        WHERE note_id = l_note_id;
      EXCEPTION
        WHEN others THEN
          -- Set the global variable to Yes so that
          -- CP can be set to Warning status.
          PSB_BUDGET_REVISIONS_PVT.g_soft_error_flag := 'Y';

          l_concat_segments
            := FND_FLEX_EXT.Get_Segs
               ( application_short_name => 'SQLGL'
               , key_flex_code          => 'GL#'
               , structure_number       => g_flex_code -- Bug#4675858
               , combination_id         => l_code_combination_id
               );
           FND_MESSAGE.SET_NAME('PSB', 'PSB_BR_NOTES_EXCEEDED_LIMIT');
           FND_MESSAGE.SET_TOKEN('ACCOUNTING_FLEXFIELD', l_concat_segments);

           l_message_text := FND_MESSAGE.Get;
           FND_FILE.PUT_LINE(FND_FILE.LOG, l_message_text);
           --
      END;
    end if;
  end;
  end if;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
                                p_data  => l_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
                                p_data  => l_msg_data);

   WHEN OTHERS THEN
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                'Create_Note');

END Create_Note;
/* Bug No 1808330 End */

/* bug no 3439168 */
PROCEDURE set_position_update_flag
(
  x_return_status        OUT  NOCOPY VARCHAR2, -- Bug#4460150
  p_position_id          IN          NUMBER
)
IS
  l_api_name     VARCHAR2(30) := 'set_update_position_flag';
BEGIN
  g_last_update_flag_tbl(p_position_id) := 1;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN others THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                l_api_name);

END set_position_update_flag;
/* bug no 3439168 */

/*Bug:7162585:start*/
PROCEDURE Lock_Budget_Revision (
          p_api_version                  NUMBER,
          p_init_msg_list                VARCHAR2 := FND_API.G_FALSE,
          p_commit                       VARCHAR2 := FND_API.G_FALSE,
          p_validation_level             NUMBER,
          p_return_status                OUT  NOCOPY  VARCHAR2,
          p_msg_count                    OUT  NOCOPY  NUMBER,
          p_msg_data                     OUT  NOCOPY  VARCHAR2,
          p_lock_row                     OUT  NOCOPY  VARCHAR2,
          P_ROWID                        ROWID,
          P_BUDGET_REVISION_ID           NUMBER,
          P_JUSTIFICATION                VARCHAR2,
          P_BUDGET_GROUP_ID              NUMBER,
          P_GL_BUDGET_SET_ID             NUMBER,
          P_HR_BUDGET_ID                 NUMBER,
          P_CONSTRAINT_SET_ID            NUMBER,
          P_BUDGET_REVISION_TYPE         VARCHAR2,
          P_FROM_GL_PERIOD_NAME          VARCHAR2,
          P_TO_GL_PERIOD_NAME            VARCHAR2,
          P_EFFECTIVE_START_DATE         DATE,
          P_EFFECTIVE_END_DATE           DATE,
          P_TRANSACTION_TYPE             VARCHAR2,
          P_CURRENCY_CODE                VARCHAR2,
          P_PERMANENT_REVISION           VARCHAR2,
          P_REVISE_BY_POSITION           VARCHAR2,
          P_BALANCE_TYPE                 VARCHAR2,
          P_PARAMETER_SET_ID             NUMBER,
          P_REQUESTOR                    NUMBER,
          P_SUBMISSION_DATE              DATE,
          P_SUBMISSION_STATUS            VARCHAR2,
          P_FREEZE_FLAG                  VARCHAR2,
          P_APPROVAL_ORIG_SYSTEM         VARCHAR2,
          P_APPROVAL_OVERRIDE_BY         NUMBER,
          P_BASE_LINE_REVISION           VARCHAR2,
          P_GLOBAL_BUDGET_REVISION       VARCHAR2,
          P_GLOBAL_BUDGET_REVISION_ID    NUMBER,
          P_LAST_UPDATE_DATE             DATE,
          P_LAST_UPDATED_BY              NUMBER,
          P_LAST_UPDATE_LOGIN            NUMBER,
          P_CREATED_BY                   NUMBER,
          P_CREATION_DATE                DATE,
          P_ATTRIBUTE1                   VARCHAR2,
          P_ATTRIBUTE2                   VARCHAR2,
          P_ATTRIBUTE3                   VARCHAR2,
          P_ATTRIBUTE4                   VARCHAR2,
          P_ATTRIBUTE5                   VARCHAR2,
          P_ATTRIBUTE6                   VARCHAR2,
          P_ATTRIBUTE7                   VARCHAR2,
          P_ATTRIBUTE8                   VARCHAR2,
          P_ATTRIBUTE9                   VARCHAR2,
          P_ATTRIBUTE10                  VARCHAR2,
          P_ATTRIBUTE11                  VARCHAR2,
          P_ATTRIBUTE12                  VARCHAR2,
          P_ATTRIBUTE13                  VARCHAR2,
          P_ATTRIBUTE14                  VARCHAR2,
          P_ATTRIBUTE15                  VARCHAR2,
          P_ATTRIBUTE16                  VARCHAR2,
          P_ATTRIBUTE17                  VARCHAR2,
          P_ATTRIBUTE18                  VARCHAR2,
          P_ATTRIBUTE19                  VARCHAR2,
          P_ATTRIBUTE20                  VARCHAR2,
          P_ATTRIBUTE21                  VARCHAR2,
          P_ATTRIBUTE22                  VARCHAR2,
          P_ATTRIBUTE23                  VARCHAR2,
          P_ATTRIBUTE24                  VARCHAR2,
          P_ATTRIBUTE25                  VARCHAR2,
          P_ATTRIBUTE26                  VARCHAR2,
          P_ATTRIBUTE27                  VARCHAR2,
          P_ATTRIBUTE28                  VARCHAR2,
          P_ATTRIBUTE29                  VARCHAR2,
          P_ATTRIBUTE30                  VARCHAR2,
          P_CONTEXT                      VARCHAR2
    ) IS

    l_api_name            CONSTANT VARCHAR2(30)   := 'Lock_BUDGET_REVISION';
    l_api_version         CONSTANT NUMBER         := 1.0;

    CURSOR C_BUDGET_REVISION IS
    SELECT BR.ROWID ,
           BR.BUDGET_REVISION_ID ,
           BR.JUSTIFICATION ,
           BR.BUDGET_GROUP_ID ,
           BR.GL_BUDGET_SET_ID ,
           BR.HR_BUDGET_ID ,
           BR.CONSTRAINT_SET_ID ,
           BR.BUDGET_REVISION_TYPE,
           BR.FROM_GL_PERIOD_NAME,
           BR.TO_GL_PERIOD_NAME,
           BR.EFFECTIVE_START_DATE,
           BR.EFFECTIVE_END_DATE,
           BR.TRANSACTION_TYPE,
           BR.CURRENCY_CODE,
           BR.PERMANENT_REVISION,
           BR.REVISE_BY_POSITION,
           BR.BALANCE_TYPE,
           BR.PARAMETER_SET_ID,
           BR.REQUESTOR,
           BR.SUBMISSION_DATE,
           BR.SUBMISSION_STATUS,
           BR.FREEZE_FLAG,
           BR.APPROVAL_ORIG_SYSTEM,
           BR.APPROVAL_OVERRIDE_BY,
           BR.BASE_LINE_REVISION,
           BR.GLOBAL_BUDGET_REVISION,
           BR.GLOBAL_BUDGET_REVISION_ID ,
           BR.REQUEST_ID,
           BR.LAST_UPDATE_DATE,
           BR.LAST_UPDATED_BY,
           BR.LAST_UPDATE_LOGIN,
           BR.CREATED_BY,
           BR.CREATION_DATE,
           BR.ATTRIBUTE1,
           BR.ATTRIBUTE2,
           BR.ATTRIBUTE3,
           BR.ATTRIBUTE4,
           BR.ATTRIBUTE5,
           BR.ATTRIBUTE6,
           BR.ATTRIBUTE7,
           BR.ATTRIBUTE8,
           BR.ATTRIBUTE9,
           BR.ATTRIBUTE10,
           BR.ATTRIBUTE11,
           BR.ATTRIBUTE12,
           BR.ATTRIBUTE13,
           BR.ATTRIBUTE14,
           BR.ATTRIBUTE15,
           BR.ATTRIBUTE16,
           BR.ATTRIBUTE17,
           BR.ATTRIBUTE18,
           BR.ATTRIBUTE19,
           BR.ATTRIBUTE20,
           BR.ATTRIBUTE21,
           BR.ATTRIBUTE22,
           BR.ATTRIBUTE23,
           BR.ATTRIBUTE24,
           BR.ATTRIBUTE25,
           BR.ATTRIBUTE26,
           BR.ATTRIBUTE27,
           BR.ATTRIBUTE28,
           BR.ATTRIBUTE29,
           BR.ATTRIBUTE30,
           BR.CONTEXT
    FROM   PSB_BUDGET_REVISIONS BR
    WHERE budget_revision_id = P_BUDGET_REVISION_ID
    FOR UPDATE OF BUDGET_REVISION_ID NOWAIT;

    Recinfo C_BUDGET_REVISION%ROWTYPE;
  BEGIN
        SAVEPOINT lock_budget_revision_pvt;
        OPEN C_BUDGET_REVISION;
        FETCH C_BUDGET_REVISION INTO Recinfo;
        if (C_BUDGET_REVISION%NOTFOUND) then
          CLOSE C_BUDGET_REVISION;
          add_message('FND','FORM_RECORD_DELETED');
          raise FND_API.G_EXC_ERROR;
        end if;

        CLOSE C_BUDGET_REVISION;

        IF ((RECINFO.BUDGET_REVISION_ID                  = NVL(P_BUDGET_REVISION_ID,'-99')) AND
           (NVL(RECINFO.JUSTIFICATION,'-99')             = NVL(P_JUSTIFICATION,'-99')) AND
           (NVL(RECINFO.BUDGET_GROUP_ID,'-99')           = NVL(P_BUDGET_GROUP_ID,'-99')) AND
           (NVL(RECINFO.GL_BUDGET_SET_ID,'-99')          = NVL(P_GL_BUDGET_SET_ID,'-99')) AND
           (NVL(RECINFO.HR_BUDGET_ID,'-99')              = NVL(P_HR_BUDGET_ID,'-99')) AND
           (NVL(RECINFO.CONSTRAINT_SET_ID,'-99')         = NVL(P_CONSTRAINT_SET_ID,'-99')) AND
           (NVL(RECINFO.BUDGET_REVISION_TYPE,'-99')      = NVL(P_BUDGET_REVISION_TYPE,'-99')) AND
           (NVL(RECINFO.FROM_GL_PERIOD_NAME,'-99')       = NVL(P_FROM_GL_PERIOD_NAME,'-99')) AND
           (NVL(RECINFO.TO_GL_PERIOD_NAME,'-99')         = NVL(P_TO_GL_PERIOD_NAME,'-99')) AND
           (NVL(RECINFO.EFFECTIVE_START_DATE,TRUNC(SYSDATE)) = NVL(P_EFFECTIVE_START_DATE,TRUNC(SYSDATE))) AND
           (NVL(RECINFO.EFFECTIVE_END_DATE,TRUNC(SYSDATE))   = NVL(P_EFFECTIVE_END_DATE,TRUNC(SYSDATE))) AND
           (NVL(RECINFO.TRANSACTION_TYPE,'-99')          = NVL(P_TRANSACTION_TYPE,'-99')) AND
           (NVL(RECINFO.CURRENCY_CODE,'-99')             = NVL(P_CURRENCY_CODE,'-99')) AND
           (NVL(RECINFO.PERMANENT_REVISION,'-99')        = NVL(P_PERMANENT_REVISION,'-99')) AND
           (NVL(RECINFO.REVISE_BY_POSITION,'-99')        = NVL(P_REVISE_BY_POSITION,'-99')) AND
           (NVL(RECINFO.BALANCE_TYPE,'-99')              = NVL(P_BALANCE_TYPE,'-99')) AND
           (NVL(RECINFO.PARAMETER_SET_ID,'-99')          = NVL(P_PARAMETER_SET_ID,'-99')) AND
           (NVL(RECINFO.REQUESTOR,'-99')                 = NVL(P_REQUESTOR,'-99')) AND
           (NVL(RECINFO.SUBMISSION_DATE,TRUNC(SYSDATE))  = NVL(P_SUBMISSION_DATE,TRUNC(SYSDATE))) AND
           (NVL(RECINFO.SUBMISSION_STATUS,'-99')         = NVL(P_SUBMISSION_STATUS,'-99')) AND
           (NVL(RECINFO.FREEZE_FLAG,'-99')               = NVL(P_FREEZE_FLAG,'-99')) AND
           (NVL(RECINFO.APPROVAL_ORIG_SYSTEM,'-99')      = NVL(P_APPROVAL_ORIG_SYSTEM,'-99')) AND
           (NVL(RECINFO.APPROVAL_OVERRIDE_BY,'-99')      = NVL(P_APPROVAL_OVERRIDE_BY,'-99')) AND
           (NVL(RECINFO.BASE_LINE_REVISION,'-99')        = NVL(P_BASE_LINE_REVISION,'-99')) AND
           (NVL(RECINFO.GLOBAL_BUDGET_REVISION,'-99')    = NVL(P_GLOBAL_BUDGET_REVISION,'-99')) AND
           (NVL(RECINFO.GLOBAL_BUDGET_REVISION_ID,'-99') = NVL(P_GLOBAL_BUDGET_REVISION_ID,'-99')) AND
           /*Bug:9231793:Removed who columns from if condition*/
           (NVL(RECINFO.ATTRIBUTE1,'-99')                = NVL(P_ATTRIBUTE1,'-99')) AND
           (NVL(RECINFO.ATTRIBUTE2,'-99')                = NVL(P_ATTRIBUTE2,'-99')) AND
           (NVL(RECINFO.ATTRIBUTE3,'-99')                = NVL(P_ATTRIBUTE3,'-99')) AND
           (NVL(RECINFO.ATTRIBUTE4,'-99')                = NVL(P_ATTRIBUTE4,'-99')) AND
           (NVL(RECINFO.ATTRIBUTE5,'-99')                = NVL(P_ATTRIBUTE5,'-99')) AND
           (NVL(RECINFO.ATTRIBUTE6,'-99')                = NVL(P_ATTRIBUTE6,'-99')) AND
           (NVL(RECINFO.ATTRIBUTE7,'-99')                = NVL(P_ATTRIBUTE7,'-99')) AND
           (NVL(RECINFO.ATTRIBUTE8,'-99')                = NVL(P_ATTRIBUTE8,'-99')) AND
           (NVL(RECINFO.ATTRIBUTE9,'-99')                = NVL(P_ATTRIBUTE9,'-99')) AND
           (NVL(RECINFO.ATTRIBUTE10,'-99')               = NVL(P_ATTRIBUTE10,'-99')) AND
           (NVL(RECINFO.ATTRIBUTE11,'-99')               = NVL(P_ATTRIBUTE11,'-99')) AND
           (NVL(RECINFO.ATTRIBUTE12,'-99')               = NVL(P_ATTRIBUTE12,'-99')) AND
           (NVL(RECINFO.ATTRIBUTE13,'-99')               = NVL(P_ATTRIBUTE13,'-99')) AND
           (NVL(RECINFO.ATTRIBUTE14,'-99')               = NVL(P_ATTRIBUTE14,'-99')) AND
           (NVL(RECINFO.ATTRIBUTE15,'-99')               = NVL(P_ATTRIBUTE15,'-99')) AND
           (NVL(RECINFO.ATTRIBUTE16,'-99')               = NVL(P_ATTRIBUTE16,'-99')) AND
           (NVL(RECINFO.ATTRIBUTE17,'-99')               = NVL(P_ATTRIBUTE17,'-99')) AND
           (NVL(RECINFO.ATTRIBUTE18,'-99')               = NVL(P_ATTRIBUTE18,'-99')) AND
           (NVL(RECINFO.ATTRIBUTE19,'-99')               = NVL(P_ATTRIBUTE19,'-99')) AND
           (NVL(RECINFO.ATTRIBUTE20,'-99')               = NVL(P_ATTRIBUTE20,'-99')) AND
           (NVL(RECINFO.ATTRIBUTE21,'-99')               = NVL(P_ATTRIBUTE21,'-99')) AND
           (NVL(RECINFO.ATTRIBUTE22,'-99')               = NVL(P_ATTRIBUTE22,'-99')) AND
           (NVL(RECINFO.ATTRIBUTE23,'-99')               = NVL(P_ATTRIBUTE23,'-99')) AND
           (NVL(RECINFO.ATTRIBUTE24,'-99')               = NVL(P_ATTRIBUTE24,'-99')) AND
           (NVL(RECINFO.ATTRIBUTE25,'-99')               = NVL(P_ATTRIBUTE25,'-99')) AND
           (NVL(RECINFO.ATTRIBUTE26,'-99')               = NVL(P_ATTRIBUTE26,'-99')) AND
           (NVL(RECINFO.ATTRIBUTE27,'-99')               = NVL(P_ATTRIBUTE27,'-99')) AND
           (NVL(RECINFO.ATTRIBUTE28,'-99')               = NVL(P_ATTRIBUTE28,'-99')) AND
           (NVL(RECINFO.ATTRIBUTE29,'-99')               = NVL(P_ATTRIBUTE29,'-99')) AND
           (NVL(RECINFO.ATTRIBUTE30,'-99')               = NVL(P_ATTRIBUTE30,'-99')) AND
           (NVL(RECINFO.CONTEXT,'-99')                   = NVL(P_CONTEXT,'-99'))) THEN
               p_lock_row := FND_API.G_TRUE;
        ELSE
         add_message('FND','FORM_RECORD_CHANGED');
         raise FND_API.G_EXC_ERROR;
        END IF;

    p_return_status := FND_API.G_RET_STS_SUCCESS;

    IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END iF;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
   			        p_data  => p_msg_data );

      EXCEPTION
	  WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN
             IF (C_BUDGET_REVISION% ISOPEN) THEN
                close C_BUDGET_REVISION;
              END IF;
              ROLLBACK TO lock_budget_revision_pvt;
               p_lock_row := FND_API.G_FALSE;
	      p_return_status := FND_API.G_RET_STS_ERROR;

	       FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
	       p_data => p_msg_data );

          WHEN FND_API.G_EXC_ERROR THEN
              IF (C_BUDGET_REVISION % ISOPEN) THEN
                close C_BUDGET_REVISION;
              END IF;
              ROLLBACK TO lock_budget_revision_pvt;
              p_return_status := FND_API.G_RET_STS_ERROR;

              FND_MSG_PUB.Count_And_Get(
                  p_count =>  p_msg_count,
                  p_data  =>  p_msg_data
              );

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             IF (C_BUDGET_REVISION% ISOPEN) THEN
                close C_BUDGET_REVISION;
              END IF;
             ROLLBACK TO lock_budget_revision_pvt;
             p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             FND_MSG_PUB.Count_And_Get(
               p_count =>  p_msg_count,
               p_data  =>  p_msg_data
             );

         WHEN OTHERS THEN
             IF (C_BUDGET_REVISION % ISOPEN) THEN
                close C_BUDGET_REVISION;
              END IF;
              ROLLBACK TO lock_budget_revision_pvt;
              p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

              IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
              THEN
                FND_MSG_PUB.Add_Exc_Msg(
                        G_PKG_NAME,
                        l_api_name
                       );
              END IF;

            FND_MSG_PUB.Count_And_Get(
              p_count =>  p_msg_count,
              p_data  =>  p_msg_data
             );
    END LOCK_BUDGET_REVISION;
/*Bug:7162585:end*/


/* Bug#5726358 Start*/
/*-------------------------------------------------------------------------+
 |               PRODCEDURE LOCK_REVISION_ACCOUNTS                         |
 +-------------------------------------------------------------------------*/
PROCEDURE Lock_Revision_Accounts
( p_api_version                  IN      NUMBER,
  p_init_msg_list                IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                       IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level             IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status                OUT  NOCOPY  VARCHAR2,
  p_msg_count                    OUT  NOCOPY  NUMBER,
  p_msg_data                     OUT  NOCOPY  VARCHAR2,
  p_lock_row                     OUT  NOCOPY  VARCHAR2, --bug:7162585
  p_row_id                       IN      ROWID,
  p_budget_revision_id           IN      NUMBER ,
  p_budget_revision_acct_line_id IN OUT NOCOPY  NUMBER,
  p_code_combination_id          IN      NUMBER,
  p_budget_group_id              IN      NUMBER,

  p_gl_period_name               IN      VARCHAR2,
  p_gl_budget_version_id         IN      NUMBER := FND_API.G_MISS_NUM,
  p_currency_code                IN      VARCHAR2,
  p_budget_balance               IN      NUMBER,
  p_revision_type                IN      VARCHAR2,
  p_revision_value_type          IN      VARCHAR2,
  p_revision_amount              IN      NUMBER,
  p_funds_status_code            IN      VARCHAR2,
  p_funds_result_code            IN      VARCHAR2,
  p_funds_control_timestamp      IN      DATE,
  p_note_id                      IN      NUMBER,
  p_freeze_flag                  IN      VARCHAR2,
  p_actual_balance               IN      NUMBER,
  p_account_type                 IN      VARCHAR2,
  p_encumbrance_balance          IN      NUMBER,
  p_last_update_date             IN      DATE,
  p_last_updated_by              IN      NUMBER,
  p_last_update_login            IN      NUMBER,
  p_created_by                   IN      NUMBER,
  p_creation_date                IN      DATE
)
IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'LOCK_REVISION_ACCOUNTS';
  l_api_version         CONSTANT NUMBER         := 1.0;

    CURSOR C IS
         SELECT BUDGET_REVISION_ACCT_LINE_ID
                ,CODE_COMBINATION_ID
                ,BUDGET_GROUP_ID
                ,GL_PERIOD_NAME
                ,GL_BUDGET_VERSION_ID
                ,CURRENCY_CODE
                ,ACCOUNT_TYPE
                ,BUDGET_BALANCE
                ,ACTUAL_BALANCE
                ,ENCUMBRANCE_BALANCE
                ,REVISION_TYPE
                ,REVISION_VALUE_TYPE
                ,REVISION_AMOUNT
                ,FUNDS_CONTROL_STATUS_CODE
                ,FUNDS_CONTROL_RESULTS_CODE
                ,FUNDS_CONTROL_TIMESTAMP
                ,FREEZE_FLAG
                ,NOTE_ID
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_LOGIN
                ,CREATED_BY
                ,CREATION_DATE
            FROM PSB_BUDGET_REVISION_ACCOUNTS
         WHERE rowid = p_row_Id
         FOR UPDATE OF BUDGET_REVISION_ACCT_LINE_ID NOWAIT;
    Recinfo C%ROWTYPE;
  BEGIN
        SAVEPOINT Lock_Revision_Accounts_pvt; --bug:7162585
        OPEN C;
        FETCH C INTO Recinfo;
        if (C%NOTFOUND) then
          CLOSE C;
          add_message('FND',
                       'FORM_RECORD_DELETED');
          raise FND_API.G_EXC_ERROR;

        end if;
        CLOSE C;

        /*bug:7162585:removed the condition on account_type as we are validating ccid change.*/
        if (
            recinfo.budget_revision_acct_line_id =
              p_budget_revision_acct_line_id
            and  nvl(recinfo.code_combination_id, '-99')         =
              nvl(p_code_combination_id, '-99')
            and  nvl(recinfo.budget_group_id, '-99')             =
              nvl(p_budget_group_id, '-99')
            and  nvl(recinfo.gl_period_name, '-99')              =
              nvl(p_gl_period_name, '-99')
            and  nvl(recinfo.gl_budget_version_id, '-99')        =
              nvl(p_gl_budget_version_id, '-99')
            and  nvl(recinfo.currency_code, '-99')               =
              nvl(p_currency_code, '-99')
            and  nvl(recinfo.revision_type, '-99')               =
              nvl(p_revision_type, '-99')
            and  nvl(recinfo.revision_value_type, '-99')         =
              nvl(p_revision_value_type, '-99')
            and  nvl(recinfo.revision_amount, '-99')             =
              nvl(p_revision_amount, '-99')
            and  nvl(recinfo.funds_control_status_code, '-99')   =
              nvl(p_funds_status_code, '-99')
            and  nvl(recinfo.funds_control_results_code, '-99')  =
              nvl(p_funds_result_code, '-99')
            and  nvl(recinfo.funds_control_timestamp, sysdate+1) =
              nvl(p_funds_control_timestamp, sysdate+1)
            and  nvl(recinfo.freeze_flag, '-99')                 =
              nvl(p_freeze_flag, '-99')
            and  nvl(recinfo.note_id, '-99')                     =
              nvl(p_note_id, '-99')
         /*bug:9231793:removed who columns */
           ) then
           p_lock_row := FND_API.G_TRUE; --bug:7162585
        else
         add_message('FND',
                       'FORM_RECORD_CHANGED');
          raise FND_API.G_EXC_ERROR;
        end if;

    IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END iF;
    --
    p_return_status := FND_API.G_RET_STS_SUCCESS;--bug:7162585

    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
   			        p_data  => p_msg_data );

      EXCEPTION
          /*bug:7162585:start*/
	  WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN
             IF (C% ISOPEN) THEN
                close C;
              END IF;
              ROLLBACK TO Lock_Revision_Accounts_pvt;
              p_lock_row  :=  FND_API.G_FALSE;
	      p_return_status := FND_API.G_RET_STS_ERROR;

	       FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
	       p_data => p_msg_data );
          /*bug:7162585:end*/
          WHEN FND_API.G_EXC_ERROR
            THEN
              IF (C% ISOPEN) THEN
                close C;
              END IF;
              ROLLBACK TO Lock_Revision_Accounts_pvt;  --bug:7162585
              p_return_status := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get(
              p_count =>  p_msg_count,
              p_data  =>  p_msg_data
              );

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR
           THEN
             IF (C% ISOPEN) THEN
                close C;
              END IF;
              ROLLBACK TO Lock_Revision_Accounts_pvt;  --bug:7162585
             p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             FND_MSG_PUB.Count_And_Get(
               p_count =>  p_msg_count,
               p_data  =>  p_msg_data
             );

         WHEN OTHERS
           THEN
             IF (C% ISOPEN) THEN
                close C;
              END IF;
              ROLLBACK TO Lock_Revision_Accounts_pvt;  --bug:7162585
              p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
              THEN
                FND_MSG_PUB.Add_Exc_Msg(
                  G_PKG_NAME,
                  l_api_name
                 );
              END IF;
            FND_MSG_PUB.Count_And_Get(
              p_count =>  p_msg_count,
              p_data  =>  p_msg_data
            );
END Lock_Revision_Accounts;

/* Bug#5726358 End */

/* ----------------------------------------------------------------------- */

END PSB_BUDGET_REVISIONS_PVT;

/
