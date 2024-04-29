--------------------------------------------------------
--  DDL for Package Body PA_FP_BUDGET_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_BUDGET_LINES_PKG" as
/* $Header: PAFPBLTB.pls 120.2 2005/09/23 14:52:59 rnamburi noship $ */
-- Start of Comments
-- Package name     : PA_FP_BUDGET_LINES_PKG
-- Purpose          :
-- History          :
--  26-OCT-2002 Vejayara Added columns to make pkg in sync with FP.K
--  05-DEC-2002 Rravipat Added new column p_mrc_flag to insert_row
--  10-DEC-2002          Added new column p_mrc_flag to update_row
--                       Modified Delte_row completely for B4 changes
--  21-JAN-2003 Vejayara Added p_buget_version_id parameter to
--                       PA_MRC_FINPLAN.MAINTAIN_ONE_MC_BUDGET_LINE
--
--  23-SEP-2005 Ram Namburi
--                       Bug Fix: 4569365. Removed MRC code.
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PA_FP_BUDGET_LINES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pafpbltb.pls';

PROCEDURE Insert_Row
( p_resource_assignment_id   IN pa_budget_lines.resource_assignment_id%TYPE
                                := FND_API.G_MISS_NUM
 ,p_start_date               IN pa_budget_lines.start_date%TYPE
                                := FND_API.G_MISS_DATE
 ,p_end_date                 IN pa_budget_lines.end_date%TYPE
                                := FND_API.G_MISS_DATE
 ,p_period_name              IN pa_budget_lines.period_name%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_quantity                 IN pa_budget_lines.quantity%TYPE
                                := FND_API.G_MISS_NUM
 ,p_raw_cost                 IN pa_budget_lines.raw_cost%TYPE
                                := FND_API.G_MISS_NUM
 ,p_burdened_cost            IN pa_budget_lines.burdened_cost%TYPE
                                := FND_API.G_MISS_NUM
 ,p_revenue                  IN pa_budget_lines.revenue%TYPE
                                := FND_API.G_MISS_NUM
 ,p_change_reason_code       IN pa_budget_lines.change_reason_code%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_description              IN pa_budget_lines.description%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute_category       IN pa_budget_lines.attribute_category%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute1               IN pa_budget_lines.attribute1%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute2               IN pa_budget_lines.attribute2%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute3               IN pa_budget_lines.attribute3%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute4               IN pa_budget_lines.attribute4%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute5               IN pa_budget_lines.attribute5%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute6               IN pa_budget_lines.attribute6%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute7               IN pa_budget_lines.attribute7%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute8               IN pa_budget_lines.attribute8%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute9               IN pa_budget_lines.attribute9%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute10              IN pa_budget_lines.attribute10%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute11              IN pa_budget_lines.attribute11%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute12              IN pa_budget_lines.attribute12%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute13              IN pa_budget_lines.attribute13%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute14              IN pa_budget_lines.attribute14%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute15              IN pa_budget_lines.attribute15%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_raw_cost_source          IN pa_budget_lines.raw_cost_source%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_burdened_cost_source     IN pa_budget_lines.burdened_cost_source%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_quantity_source          IN pa_budget_lines.quantity_source%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_revenue_source           IN pa_budget_lines.revenue_source%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_pm_product_code          IN pa_budget_lines.pm_product_code%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_pm_budget_line_reference IN pa_budget_lines.pm_budget_line_reference%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_cost_rejection_code      IN pa_budget_lines.cost_rejection_code%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_revenue_rejection_code   IN pa_budget_lines.revenue_rejection_code%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_burden_rejection_code    IN pa_budget_lines.burden_rejection_code%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_other_rejection_code     IN pa_budget_lines.other_rejection_code%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_code_combination_id      IN pa_budget_lines.code_combination_id%TYPE
                                := FND_API.G_MISS_NUM
 ,p_ccid_gen_status_code     IN pa_budget_lines.ccid_gen_status_code%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_ccid_gen_rej_message     IN pa_budget_lines.ccid_gen_rej_message%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_request_id               IN pa_budget_lines.request_id%TYPE
                                := FND_API.G_MISS_NUM
 ,p_borrowed_revenue         IN pa_budget_lines.borrowed_revenue%TYPE
                                := FND_API.G_MISS_NUM
 ,p_tp_revenue_in            IN pa_budget_lines.tp_revenue_in%TYPE
                                := FND_API.G_MISS_NUM
 ,p_tp_revenue_out           IN pa_budget_lines.tp_revenue_out%TYPE
                                := FND_API.G_MISS_NUM
 ,p_revenue_adj              IN pa_budget_lines.revenue_adj%TYPE
                                := FND_API.G_MISS_NUM
 ,p_lent_resource_cost       IN pa_budget_lines.lent_resource_cost%TYPE
                                := FND_API.G_MISS_NUM
 ,p_tp_cost_in               IN pa_budget_lines.tp_cost_in%TYPE
                                := FND_API.G_MISS_NUM
 ,p_tp_cost_out              IN pa_budget_lines.tp_cost_out%TYPE
                                := FND_API.G_MISS_NUM
 ,p_cost_adj                 IN pa_budget_lines.cost_adj%TYPE
                                := FND_API.G_MISS_NUM
 ,p_unassigned_time_cost     IN pa_budget_lines.unassigned_time_cost%TYPE
                                := FND_API.G_MISS_NUM
 ,p_utilization_percent      IN pa_budget_lines.utilization_percent%TYPE
                                := FND_API.G_MISS_NUM
 ,p_utilization_hours        IN pa_budget_lines.utilization_hours%TYPE
                                := FND_API.G_MISS_NUM
 ,p_utilization_adj          IN pa_budget_lines.utilization_adj%TYPE
                                := FND_API.G_MISS_NUM
 ,p_capacity                 IN pa_budget_lines.capacity%TYPE
                                := FND_API.G_MISS_NUM
 ,p_head_count               IN pa_budget_lines.head_count%TYPE
                                := FND_API.G_MISS_NUM
 ,p_head_count_adj           IN pa_budget_lines.head_count_adj%TYPE
                                := FND_API.G_MISS_NUM,
p_projfunc_currency_code        in pa_budget_lines.projfunc_currency_code%type       := FND_API.G_MISS_CHAR,
p_projfunc_cost_rate_type       in pa_budget_lines.projfunc_cost_rate_type%type      := FND_API.G_MISS_CHAR,
p_projfunc_cost_exchange_rate   in pa_budget_lines.projfunc_cost_exchange_rate%type  := FND_API.G_MISS_NUM,
p_projfunc_cost_rate_date_type  in pa_budget_lines.projfunc_cost_rate_date_type%type := FND_API.G_MISS_CHAR,
p_projfunc_cost_rate_date       in pa_budget_lines.projfunc_cost_rate_date%type      := FND_API.G_MISS_DATE,
p_projfunc_rev_rate_type        in pa_budget_lines.projfunc_rev_rate_type%type       := FND_API.G_MISS_CHAR,
p_projfunc_rev_rate_date_type   in pa_budget_lines.projfunc_rev_rate_date_type%type  := FND_API.G_MISS_CHAR,
p_projfunc_rev_exchange_rate    in pa_budget_lines.projfunc_rev_exchange_rate%type   := FND_API.G_MISS_NUM,
p_projfunc_rev_rate_date        in pa_budget_lines.projfunc_rev_rate_date%type       := FND_API.G_MISS_DATE,
p_project_currency_code         in pa_budget_lines.project_currency_code%type        := FND_API.G_MISS_CHAR,
p_project_cost_rate_type        in pa_budget_lines.project_cost_rate_type%type       := FND_API.G_MISS_CHAR,
p_project_cost_exchange_rate    in pa_budget_lines.project_cost_exchange_rate%type   := FND_API.G_MISS_NUM,
p_project_cost_rate_date_type   in pa_budget_lines.project_cost_rate_date_type%type  := FND_API.G_MISS_CHAR,
p_project_cost_rate_date        in pa_budget_lines.project_cost_rate_date%type       := FND_API.G_MISS_DATE,
p_project_raw_cost              in pa_budget_lines.project_raw_cost%type             := FND_API.G_MISS_NUM,
p_project_burdened_cost         in pa_budget_lines.project_burdened_cost%type        := FND_API.G_MISS_NUM,
p_project_revenue               in pa_budget_lines.project_revenue%type              := FND_API.G_MISS_NUM,
p_txn_raw_cost                  in pa_budget_lines.txn_raw_cost%type                 := FND_API.G_MISS_NUM,
p_txn_burdened_cost             in pa_budget_lines.txn_burdened_cost%type            := FND_API.G_MISS_NUM,
p_txn_revenue                   in pa_budget_lines.txn_revenue%type                  := FND_API.G_MISS_NUM,
p_txn_currency_code             in pa_budget_lines.txn_currency_code%type            := FND_API.G_MISS_CHAR,
p_bucketing_period_code         in pa_budget_lines.bucketing_period_code%type        := FND_API.G_MISS_CHAR,
p_project_rev_rate_type         in pa_budget_lines.project_rev_rate_type%type        := FND_API.G_MISS_CHAR,
p_project_rev_exchange_rate     in pa_budget_lines.project_rev_exchange_rate%type    := FND_API.G_MISS_NUM,
p_project_rev_rate_date_type    in pa_budget_lines.project_rev_rate_date_type%type   := FND_API.G_MISS_CHAR,
p_project_rev_rate_date         in pa_budget_lines.project_rev_rate_date%type        := FND_API.G_MISS_DATE,
px_budget_line_id           IN OUT NOCOPY pa_budget_lines.budget_line_id%type, --File.Sql.39 bug 4440895
p_budget_version_id             in pa_budget_lines.budget_version_id%type            := FND_API.G_MISS_NUM,
-- Bug Fix: 4569365. Removed MRC code.
-- p_mrc_flag                      in  VARCHAR2 -- FP Build4 changes
  x_row_id                  OUT NOCOPY ROWID --File.Sql.39 bug 4440895
 ,x_return_status           OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
 IS

l_msg_count                     NUMBER := 0;
l_msg_data                      VARCHAR2(2000);
l_return_status                 VARCHAR2(2000);

CURSOR C2 IS SELECT pa_budget_lines_s.nextval from sys.dual;
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (px_budget_line_id IS NULL) OR
      (px_budget_line_id = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_budget_line_id;
       CLOSE C2;
   END IF;


   INSERT INTO pa_budget_lines(
           resource_assignment_id
          ,start_date
          ,last_update_date
          ,last_updated_by
          ,creation_date
          ,created_by
          ,last_update_login
          ,end_date
          ,period_name
          ,quantity
          ,raw_cost
          ,burdened_cost
          ,revenue
          ,change_reason_code
          ,description
          ,attribute_category
          ,attribute1
          ,attribute2
          ,attribute3
          ,attribute4
          ,attribute5
          ,attribute6
          ,attribute7
          ,attribute8
          ,attribute9
          ,attribute10
          ,attribute11
          ,attribute12
          ,attribute13
          ,attribute14
          ,attribute15
          ,raw_cost_source
          ,burdened_cost_source
          ,quantity_source
          ,revenue_source
          ,pm_product_code
          ,pm_budget_line_reference
          ,cost_rejection_code
          ,revenue_rejection_code
          ,burden_rejection_code
          ,other_rejection_code
          ,code_combination_id
          ,ccid_gen_status_code
          ,ccid_gen_rej_message
          ,request_id
          ,borrowed_revenue
          ,tp_revenue_in
          ,tp_revenue_out
          ,revenue_adj
          ,lent_resource_cost
          ,tp_cost_in
          ,tp_cost_out
          ,cost_adj
          ,unassigned_time_cost
          ,utilization_percent
          ,utilization_hours
          ,utilization_adj
          ,capacity
          ,head_count
          ,head_count_adj
          ,projfunc_currency_code
          ,projfunc_cost_rate_type
          ,projfunc_cost_exchange_rate
          ,projfunc_cost_rate_date_type
          ,projfunc_cost_rate_date
          ,projfunc_rev_rate_type
          ,projfunc_rev_rate_date_type
          ,projfunc_rev_exchange_rate
          ,projfunc_rev_rate_date
          ,project_currency_code
          ,project_cost_rate_type
          ,project_cost_exchange_rate
          ,project_cost_rate_date_type
          ,project_cost_rate_date
          ,project_raw_cost
          ,project_burdened_cost
          ,project_revenue
          ,txn_raw_cost
          ,txn_burdened_cost
          ,txn_revenue
          ,txn_currency_code
          ,bucketing_period_code
          ,project_rev_rate_type
          ,project_rev_exchange_rate
          ,project_rev_rate_date_type
          ,project_rev_rate_date
          ,budget_line_id
          ,budget_version_id
          ) values (
           p_resource_assignment_id
          ,DECODE( p_start_date, FND_API.G_MISS_DATE, to_date(NULL),
                   p_start_date)
		,sysdate
		,fnd_global.user_id
          ,sysdate
          ,fnd_global.user_id
          ,fnd_global.login_id
          ,DECODE( p_end_date, FND_API.G_MISS_DATE, to_date(NULL), p_end_date)
          ,DECODE( p_period_name, FND_API.G_MISS_CHAR, NULL, p_period_name)
          ,DECODE( p_quantity, FND_API.G_MISS_NUM, NULL, p_quantity)
          ,DECODE( p_raw_cost, FND_API.G_MISS_NUM, NULL, p_raw_cost)
          ,DECODE( p_burdened_cost, FND_API.G_MISS_NUM, NULL, p_burdened_cost)
          ,DECODE( p_revenue, FND_API.G_MISS_NUM, NULL, p_revenue)
          ,DECODE( p_change_reason_code, FND_API.G_MISS_CHAR, NULL,
                   p_change_reason_code)
          ,DECODE( p_description, FND_API.G_MISS_CHAR, NULL, p_description)
          ,DECODE( p_attribute_category, FND_API.G_MISS_CHAR, NULL,
                   p_attribute_category)
          ,DECODE( p_attribute1, FND_API.G_MISS_CHAR, NULL, p_attribute1)
          ,DECODE( p_attribute2, FND_API.G_MISS_CHAR, NULL, p_attribute2)
          ,DECODE( p_attribute3, FND_API.G_MISS_CHAR, NULL, p_attribute3)
          ,DECODE( p_attribute4, FND_API.G_MISS_CHAR, NULL, p_attribute4)
          ,DECODE( p_attribute5, FND_API.G_MISS_CHAR, NULL, p_attribute5)
          ,DECODE( p_attribute6, FND_API.G_MISS_CHAR, NULL, p_attribute6)
          ,DECODE( p_attribute7, FND_API.G_MISS_CHAR, NULL, p_attribute7)
          ,DECODE( p_attribute8, FND_API.G_MISS_CHAR, NULL, p_attribute8)
          ,DECODE( p_attribute9, FND_API.G_MISS_CHAR, NULL, p_attribute9)
          ,DECODE( p_attribute10, FND_API.G_MISS_CHAR, NULL, p_attribute10)
          ,DECODE( p_attribute11, FND_API.G_MISS_CHAR, NULL, p_attribute11)
          ,DECODE( p_attribute12, FND_API.G_MISS_CHAR, NULL, p_attribute12)
          ,DECODE( p_attribute13, FND_API.G_MISS_CHAR, NULL, p_attribute13)
          ,DECODE( p_attribute14, FND_API.G_MISS_CHAR, NULL, p_attribute14)
          ,DECODE( p_attribute15, FND_API.G_MISS_CHAR, NULL, p_attribute15)
          ,DECODE( p_raw_cost_source, FND_API.G_MISS_CHAR, NULL,
                   p_raw_cost_source)
          ,DECODE( p_burdened_cost_source, FND_API.G_MISS_CHAR, NULL,
                   p_burdened_cost_source)
          ,DECODE( p_quantity_source, FND_API.G_MISS_CHAR, NULL,
                   p_quantity_source)
          ,DECODE( p_revenue_source, FND_API.G_MISS_CHAR, NULL,
                   p_revenue_source)
          ,DECODE( p_pm_product_code, FND_API.G_MISS_CHAR, NULL,
                   p_pm_product_code)
          ,DECODE( p_pm_budget_line_reference, FND_API.G_MISS_CHAR, NULL,
                   p_pm_budget_line_reference)
          ,DECODE( p_cost_rejection_code, FND_API.G_MISS_CHAR, NULL,
                   p_cost_rejection_code)
          ,DECODE( p_revenue_rejection_code, FND_API.G_MISS_CHAR, NULL,
                   p_revenue_rejection_code)
          ,DECODE( p_burden_rejection_code, FND_API.G_MISS_CHAR, NULL,
                   p_burden_rejection_code)
          ,DECODE( p_other_rejection_code, FND_API.G_MISS_CHAR, NULL,
                   p_other_rejection_code)
          ,DECODE( p_code_combination_id, FND_API.G_MISS_NUM, NULL,
                   p_code_combination_id)
          ,DECODE( p_ccid_gen_status_code, FND_API.G_MISS_CHAR, NULL,
                   p_ccid_gen_status_code)
          ,DECODE( p_ccid_gen_rej_message, FND_API.G_MISS_CHAR, NULL,
                   p_ccid_gen_rej_message)
          ,DECODE( p_request_id, FND_API.G_MISS_NUM, NULL, p_request_id)
          ,DECODE( p_borrowed_revenue, FND_API.G_MISS_NUM, NULL,
                   p_borrowed_revenue)
          ,DECODE( p_tp_revenue_in, FND_API.G_MISS_NUM, NULL, p_tp_revenue_in)
          ,DECODE( p_tp_revenue_out, FND_API.G_MISS_NUM, NULL, p_tp_revenue_out)
          ,DECODE( p_revenue_adj, FND_API.G_MISS_NUM, NULL, p_revenue_adj)
          ,DECODE( p_lent_resource_cost, FND_API.G_MISS_NUM, NULL,
                   p_lent_resource_cost)
          ,DECODE( p_tp_cost_in, FND_API.G_MISS_NUM, NULL, p_tp_cost_in)
          ,DECODE( p_tp_cost_out, FND_API.G_MISS_NUM, NULL, p_tp_cost_out)
          ,DECODE( p_cost_adj, FND_API.G_MISS_NUM, NULL, p_cost_adj)
          ,DECODE( p_unassigned_time_cost, FND_API.G_MISS_NUM, NULL,
                   p_unassigned_time_cost)
          ,DECODE( p_utilization_percent, FND_API.G_MISS_NUM, NULL,
                   p_utilization_percent)
          ,DECODE( p_utilization_hours, FND_API.G_MISS_NUM, NULL,
                   p_utilization_hours)
          ,DECODE( p_utilization_adj, FND_API.G_MISS_NUM, NULL,
                   p_utilization_adj)
          ,DECODE( p_capacity, FND_API.G_MISS_NUM, NULL, p_capacity)
          ,DECODE( p_head_count, FND_API.G_MISS_NUM, NULL, p_head_count)
          ,DECODE( p_head_count_adj, FND_API.G_MISS_NUM, NULL,
                   p_head_count_adj)
          ,DECODE( p_projfunc_currency_code      ,FND_API.G_MISS_CHAR,  NULL,p_projfunc_currency_code      )
          ,DECODE( p_projfunc_cost_rate_type     ,FND_API.G_MISS_CHAR,  NULL,p_projfunc_cost_rate_type     )
          ,DECODE( p_projfunc_cost_exchange_rate ,FND_API.G_MISS_NUM,NULL,p_projfunc_cost_exchange_rate )
          ,DECODE( p_projfunc_cost_rate_date_type,FND_API.G_MISS_CHAR,  NULL,p_projfunc_cost_rate_date_type)
          ,DECODE( p_projfunc_cost_rate_date     ,FND_API.G_MISS_DATE,  to_date(NULL),p_projfunc_cost_rate_date     )
          ,DECODE( p_projfunc_rev_rate_type      ,FND_API.G_MISS_CHAR,  NULL,p_projfunc_rev_rate_type      )
          ,DECODE( p_projfunc_rev_rate_date_type ,FND_API.G_MISS_CHAR,  NULL,p_projfunc_rev_rate_date_type )
          ,DECODE( p_projfunc_rev_exchange_rate  ,FND_API.G_MISS_NUM,NULL,p_projfunc_rev_exchange_rate  )
          ,DECODE( p_projfunc_rev_rate_date      ,FND_API.G_MISS_DATE,  to_date(NULL),p_projfunc_rev_rate_date      )
          ,DECODE( p_project_currency_code       ,FND_API.G_MISS_CHAR,  NULL,p_project_currency_code       )
          ,DECODE( p_project_cost_rate_type      ,FND_API.G_MISS_CHAR,  NULL,p_project_cost_rate_type      )
          ,DECODE( p_project_cost_exchange_rate  ,FND_API.G_MISS_NUM,NULL,p_project_cost_exchange_rate  )
          ,DECODE( p_project_cost_rate_date_type ,FND_API.G_MISS_CHAR,  NULL,p_project_cost_rate_date_type )
          ,DECODE( p_project_cost_rate_date      ,FND_API.G_MISS_DATE,  to_Date(NULL),p_project_cost_rate_date      )
          ,DECODE( p_project_raw_cost            ,FND_API.G_MISS_NUM,NULL,p_project_raw_cost            )
          ,DECODE( p_project_burdened_cost       ,FND_API.G_MISS_NUM,NULL,p_project_burdened_cost       )
          ,DECODE( p_project_revenue             ,FND_API.G_MISS_NUM,NULL,p_project_revenue             )
          ,DECODE( p_txn_raw_cost                ,FND_API.G_MISS_NUM,NULL,p_txn_raw_cost                )
          ,DECODE( p_txn_burdened_cost           ,FND_API.G_MISS_NUM,NULL,p_txn_burdened_cost           )
          ,DECODE( p_txn_revenue                 ,FND_API.G_MISS_NUM,NULL,p_txn_revenue                 )
          ,DECODE( p_txn_currency_code           ,FND_API.G_MISS_CHAR,  NULL,p_txn_currency_code           )
          ,DECODE( p_bucketing_period_code       ,FND_API.G_MISS_CHAR,  NULL,p_bucketing_period_code       )
          ,DECODE( p_project_rev_rate_type       ,FND_API.G_MISS_CHAR,  NULL,p_project_rev_rate_type       )
          ,DECODE( p_project_rev_exchange_rate   ,FND_API.G_MISS_NUM,NULL,p_project_rev_exchange_rate   )
          ,DECODE( p_project_rev_rate_date_type  ,FND_API.G_MISS_CHAR,  NULL,p_project_rev_rate_date_type  )
          ,DECODE( p_project_rev_rate_date       ,FND_API.G_MISS_DATE,  to_date(NULL),p_project_rev_rate_date       )
          ,px_budget_line_id
          ,DECODE( p_budget_version_id           ,FND_API.G_MISS_NUM,NULL,p_budget_version_id           ));

-- +++++ start of FP Build 4 changes +++++ --
    -- Bug Fix: 4569365. Removed MRC code.

	-- If mrc flag is 'Y' insert mrc budget lines for this budget line id
    /*
    IF p_mrc_flag = 'Y' THEN

       IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS IS NULL THEN
              PA_MRC_FINPLAN.CHECK_MRC_INSTALL
                        (x_return_status      => l_return_status,
                         x_msg_count          => l_msg_count,
                         x_msg_data           => l_msg_data);
       END IF;

       IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS AND
          PA_MRC_FINPLAN.G_FINPLAN_MRC_OPTION_CODE = 'A' THEN
          PA_MRC_FINPLAN.MAINTAIN_ONE_MC_BUDGET_LINE
                                (p_budget_line_id => px_budget_line_id,
                                 p_budget_version_id => p_budget_version_id,
                                 p_action         => PA_MRC_FINPLAN.G_ACTION_INSERT,
                                 x_return_status  => l_return_status,
                                 x_msg_count      => l_msg_count,
                                 x_msg_data       => l_msg_data);
       END IF;

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

    END IF;
    */
-- +++++ end of FP Build4 changes +++++ --
EXCEPTION
  WHEN OTHERS THEN
	  FND_MSG_PUB.add_exc_msg( p_pkg_name
                                   => 'PA_FP_BUDGET_LINES_PKG.Insert_Row'
                                  ,p_procedure_name
                                   => PA_DEBUG.G_Err_Stack);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  RAISE;
End Insert_Row;

PROCEDURE Update_Row
( p_resource_assignment_id   IN pa_budget_lines.resource_assignment_id%TYPE
                                := FND_API.G_MISS_NUM
 ,p_start_date               IN pa_budget_lines.start_date%TYPE
                                := FND_API.G_MISS_DATE
 ,p_end_date                 IN pa_budget_lines.end_date%TYPE
                                := FND_API.G_MISS_DATE
 ,p_period_name              IN pa_budget_lines.period_name%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_quantity                 IN pa_budget_lines.quantity%TYPE
                                := FND_API.G_MISS_NUM
 ,p_raw_cost                 IN pa_budget_lines.raw_cost%TYPE
                                := FND_API.G_MISS_NUM
 ,p_burdened_cost            IN pa_budget_lines.burdened_cost%TYPE
                                := FND_API.G_MISS_NUM
 ,p_revenue                  IN pa_budget_lines.revenue%TYPE
                                := FND_API.G_MISS_NUM
 ,p_change_reason_code       IN pa_budget_lines.change_reason_code%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_description              IN pa_budget_lines.description%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute_category       IN pa_budget_lines.attribute_category%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute1               IN pa_budget_lines.attribute1%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute2               IN pa_budget_lines.attribute2%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute3               IN pa_budget_lines.attribute3%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute4               IN pa_budget_lines.attribute4%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute5               IN pa_budget_lines.attribute5%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute6               IN pa_budget_lines.attribute6%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute7               IN pa_budget_lines.attribute7%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute8               IN pa_budget_lines.attribute8%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute9               IN pa_budget_lines.attribute9%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute10              IN pa_budget_lines.attribute10%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute11              IN pa_budget_lines.attribute11%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute12              IN pa_budget_lines.attribute12%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute13              IN pa_budget_lines.attribute13%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute14              IN pa_budget_lines.attribute14%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute15              IN pa_budget_lines.attribute15%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_raw_cost_source          IN pa_budget_lines.raw_cost_source%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_burdened_cost_source     IN pa_budget_lines.burdened_cost_source%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_quantity_source          IN pa_budget_lines.quantity_source%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_revenue_source           IN pa_budget_lines.revenue_source%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_pm_product_code          IN pa_budget_lines.pm_product_code%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_pm_budget_line_reference IN pa_budget_lines.pm_budget_line_reference%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_cost_rejection_code      IN pa_budget_lines.cost_rejection_code%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_revenue_rejection_code   IN pa_budget_lines.revenue_rejection_code%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_burden_rejection_code    IN pa_budget_lines.burden_rejection_code%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_other_rejection_code     IN pa_budget_lines.other_rejection_code%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_code_combination_id      IN pa_budget_lines.code_combination_id%TYPE
                                := FND_API.G_MISS_NUM
 ,p_ccid_gen_status_code     IN pa_budget_lines.ccid_gen_status_code%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_ccid_gen_rej_message     IN pa_budget_lines.ccid_gen_rej_message%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_request_id               IN pa_budget_lines.request_id%TYPE
                                := FND_API.G_MISS_NUM
 ,p_borrowed_revenue         IN pa_budget_lines.borrowed_revenue%TYPE
                                := FND_API.G_MISS_NUM
 ,p_tp_revenue_in            IN pa_budget_lines.tp_revenue_in%TYPE
                                := FND_API.G_MISS_NUM
 ,p_tp_revenue_out           IN pa_budget_lines.tp_revenue_out%TYPE
                                := FND_API.G_MISS_NUM
 ,p_revenue_adj              IN pa_budget_lines.revenue_adj%TYPE
                                := FND_API.G_MISS_NUM
 ,p_lent_resource_cost       IN pa_budget_lines.lent_resource_cost%TYPE
                                := FND_API.G_MISS_NUM
 ,p_tp_cost_in               IN pa_budget_lines.tp_cost_in%TYPE
                                := FND_API.G_MISS_NUM
 ,p_tp_cost_out              IN pa_budget_lines.tp_cost_out%TYPE
                                := FND_API.G_MISS_NUM
 ,p_cost_adj                 IN pa_budget_lines.cost_adj%TYPE
                                := FND_API.G_MISS_NUM
 ,p_unassigned_time_cost     IN pa_budget_lines.unassigned_time_cost%TYPE
                                := FND_API.G_MISS_NUM
 ,p_utilization_percent      IN pa_budget_lines.utilization_percent%TYPE
                                := FND_API.G_MISS_NUM
 ,p_utilization_hours        IN pa_budget_lines.utilization_hours%TYPE
                                := FND_API.G_MISS_NUM
 ,p_utilization_adj          IN pa_budget_lines.utilization_adj%TYPE
                                := FND_API.G_MISS_NUM
 ,p_capacity                 IN pa_budget_lines.capacity%TYPE
                                := FND_API.G_MISS_NUM
 ,p_head_count               IN pa_budget_lines.head_count%TYPE
                                := FND_API.G_MISS_NUM
 ,p_head_count_adj           IN pa_budget_lines.head_count_adj%TYPE
                                := FND_API.G_MISS_NUM,
p_projfunc_currency_code        in pa_budget_lines.projfunc_currency_code%type       := FND_API.G_MISS_CHAR,
p_projfunc_cost_rate_type       in pa_budget_lines.projfunc_cost_rate_type%type      := FND_API.G_MISS_CHAR,
p_projfunc_cost_exchange_rate   in pa_budget_lines.projfunc_cost_exchange_rate%type  := FND_API.G_MISS_NUM,
p_projfunc_cost_rate_date_type  in pa_budget_lines.projfunc_cost_rate_date_type%type := FND_API.G_MISS_CHAR,
p_projfunc_cost_rate_date       in pa_budget_lines.projfunc_cost_rate_date%type      := FND_API.G_MISS_DATE,
p_projfunc_rev_rate_type        in pa_budget_lines.projfunc_rev_rate_type%type       := FND_API.G_MISS_CHAR,
p_projfunc_rev_rate_date_type   in pa_budget_lines.projfunc_rev_rate_date_type%type  := FND_API.G_MISS_CHAR,
p_projfunc_rev_exchange_rate    in pa_budget_lines.projfunc_rev_exchange_rate%type   := FND_API.G_MISS_NUM,
p_projfunc_rev_rate_date        in pa_budget_lines.projfunc_rev_rate_date%type       := FND_API.G_MISS_DATE,
p_project_currency_code         in pa_budget_lines.project_currency_code%type        := FND_API.G_MISS_CHAR,
p_project_cost_rate_type        in pa_budget_lines.project_cost_rate_type%type       := FND_API.G_MISS_CHAR,
p_project_cost_exchange_rate    in pa_budget_lines.project_cost_exchange_rate%type   := FND_API.G_MISS_NUM,
p_project_cost_rate_date_type   in pa_budget_lines.project_cost_rate_date_type%type  := FND_API.G_MISS_CHAR,
p_project_cost_rate_date        in pa_budget_lines.project_cost_rate_date%type       := FND_API.G_MISS_DATE,
p_project_raw_cost              in pa_budget_lines.project_raw_cost%type             := FND_API.G_MISS_NUM,
p_project_burdened_cost         in pa_budget_lines.project_burdened_cost%type        := FND_API.G_MISS_NUM,
p_project_revenue               in pa_budget_lines.project_revenue%type              := FND_API.G_MISS_NUM,
p_txn_raw_cost                  in pa_budget_lines.txn_raw_cost%type                 := FND_API.G_MISS_NUM,
p_txn_burdened_cost             in pa_budget_lines.txn_burdened_cost%type            := FND_API.G_MISS_NUM,
p_txn_revenue                   in pa_budget_lines.txn_revenue%type                  := FND_API.G_MISS_NUM,
p_txn_currency_code             in pa_budget_lines.txn_currency_code%type            := FND_API.G_MISS_CHAR,
p_bucketing_period_code         in pa_budget_lines.bucketing_period_code%type        := FND_API.G_MISS_CHAR,
p_project_rev_rate_type         in pa_budget_lines.project_rev_rate_type%type        := FND_API.G_MISS_CHAR,
p_project_rev_exchange_rate     in pa_budget_lines.project_rev_exchange_rate%type    := FND_API.G_MISS_NUM,
p_project_rev_rate_date_type    in pa_budget_lines.project_rev_rate_date_type%type   := FND_API.G_MISS_CHAR,
p_project_rev_rate_date         in pa_budget_lines.project_rev_rate_date%type        := FND_API.G_MISS_DATE,
p_budget_line_id                in pa_budget_lines.budget_line_id%type               := FND_API.G_MISS_NUM,
p_budget_version_id             in pa_budget_lines.budget_version_id%type            := FND_API.G_MISS_NUM,
-- Bug Fix: 4569365. Removed MRC code.
-- p_mrc_flag                      in  VARCHAR2 -- FP Build 4 Changes
 p_row_id                   IN ROWID
                                := NULL
 ,x_return_status           OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
l_msg_count                     NUMBER := 0;
l_msg_data                      VARCHAR2(2000);
l_return_status                 VARCHAR2(2000);
BEGIN
UPDATE pa_budget_lines
SET
 start_date = DECODE( p_start_date, FND_API.G_MISS_DATE, start_date,
                      p_start_date)
,last_update_date = sysdate
,last_updated_by = fnd_global.user_id
,last_update_login = fnd_global.login_id
,end_date = DECODE( p_end_date, FND_API.G_MISS_DATE, end_date, p_end_date)
,period_name = DECODE( p_period_name, FND_API.G_MISS_CHAR, period_name,
                       p_period_name)
,quantity = DECODE( p_quantity, FND_API.G_MISS_NUM, quantity, p_quantity)
,raw_cost = DECODE( p_raw_cost, FND_API.G_MISS_NUM, raw_cost, p_raw_cost)
,burdened_cost = DECODE( p_burdened_cost, FND_API.G_MISS_NUM, burdened_cost,
                         p_burdened_cost)
,revenue = DECODE( p_revenue, FND_API.G_MISS_NUM, revenue, p_revenue)
,change_reason_code = DECODE( p_change_reason_code, FND_API.G_MISS_CHAR,
                              change_reason_code, p_change_reason_code)
,description = DECODE( p_description, FND_API.G_MISS_CHAR, description,
                       p_description)
,attribute_category = DECODE( p_attribute_category, FND_API.G_MISS_CHAR,
                              attribute_category, p_attribute_category)
,attribute1 = DECODE( p_attribute1, FND_API.G_MISS_CHAR, attribute1,
                      p_attribute1)
,attribute2 = DECODE( p_attribute2, FND_API.G_MISS_CHAR, attribute2,
                      p_attribute2)
,attribute3 = DECODE( p_attribute3, FND_API.G_MISS_CHAR, attribute3,
                      p_attribute3)
,attribute4 = DECODE( p_attribute4, FND_API.G_MISS_CHAR, attribute4,
                      p_attribute4)
,attribute5 = DECODE( p_attribute5, FND_API.G_MISS_CHAR, attribute5,
                      p_attribute5)
,attribute6 = DECODE( p_attribute6, FND_API.G_MISS_CHAR, attribute6,
                      p_attribute6)
,attribute7 = DECODE( p_attribute7, FND_API.G_MISS_CHAR, attribute7,
                      p_attribute7)
,attribute8 = DECODE( p_attribute8, FND_API.G_MISS_CHAR, attribute8,
                      p_attribute8)
,attribute9 = DECODE( p_attribute9, FND_API.G_MISS_CHAR, attribute9,
                      p_attribute9)
,attribute10 = DECODE( p_attribute10, FND_API.G_MISS_CHAR, attribute10,
                       p_attribute10)
,attribute11 = DECODE( p_attribute11, FND_API.G_MISS_CHAR, attribute11,
                       p_attribute11)
,attribute12 = DECODE( p_attribute12, FND_API.G_MISS_CHAR, attribute12,
                       p_attribute12)
,attribute13 = DECODE( p_attribute13, FND_API.G_MISS_CHAR, attribute13,
                       p_attribute13)
,attribute14 = DECODE( p_attribute14, FND_API.G_MISS_CHAR, attribute14,
                       p_attribute14)
,attribute15 = DECODE( p_attribute15, FND_API.G_MISS_CHAR, attribute15,
                       p_attribute15)
,raw_cost_source = DECODE( p_raw_cost_source, FND_API.G_MISS_CHAR,
                           raw_cost_source, p_raw_cost_source)
,burdened_cost_source = DECODE( p_burdened_cost_source, FND_API.G_MISS_CHAR,
                                burdened_cost_source, p_burdened_cost_source)
,quantity_source = DECODE( p_quantity_source, FND_API.G_MISS_CHAR,
                           quantity_source, p_quantity_source)
,revenue_source = DECODE( p_revenue_source, FND_API.G_MISS_CHAR, revenue_source,
                          p_revenue_source)
,pm_product_code = DECODE( p_pm_product_code, FND_API.G_MISS_CHAR,
                           pm_product_code, p_pm_product_code)
,pm_budget_line_reference = DECODE( p_pm_budget_line_reference,
                                    FND_API.G_MISS_CHAR,
                                    pm_budget_line_reference,
                                    p_pm_budget_line_reference)
,cost_rejection_code = DECODE( p_cost_rejection_code, FND_API.G_MISS_CHAR,
                               cost_rejection_code, p_cost_rejection_code)
,revenue_rejection_code = DECODE( p_revenue_rejection_code, FND_API.G_MISS_CHAR,
                                  revenue_rejection_code,
                                  p_revenue_rejection_code)
,burden_rejection_code = DECODE( p_burden_rejection_code, FND_API.G_MISS_CHAR,
                                 burden_rejection_code, p_burden_rejection_code)
,other_rejection_code = DECODE( p_other_rejection_code, FND_API.G_MISS_CHAR,
                                other_rejection_code, p_other_rejection_code)
,code_combination_id = DECODE( p_code_combination_id, FND_API.G_MISS_NUM,
                               code_combination_id, p_code_combination_id)
,ccid_gen_status_code = DECODE( p_ccid_gen_status_code, FND_API.G_MISS_CHAR,
                                ccid_gen_status_code, p_ccid_gen_status_code)
,ccid_gen_rej_message = DECODE( p_ccid_gen_rej_message, FND_API.G_MISS_CHAR,
                                ccid_gen_rej_message, p_ccid_gen_rej_message)
,request_id = DECODE( p_request_id, FND_API.G_MISS_NUM, request_id,
                      p_request_id)
,borrowed_revenue = DECODE( p_borrowed_revenue, FND_API.G_MISS_NUM,
                            borrowed_revenue, p_borrowed_revenue)
,tp_revenue_in = DECODE( p_tp_revenue_in, FND_API.G_MISS_NUM, tp_revenue_in,
                         p_tp_revenue_in)
,tp_revenue_out = DECODE( p_tp_revenue_out, FND_API.G_MISS_NUM, tp_revenue_out,
                          p_tp_revenue_out)
,revenue_adj = DECODE( p_revenue_adj, FND_API.G_MISS_NUM, revenue_adj,
                       p_revenue_adj)
,lent_resource_cost = DECODE( p_lent_resource_cost, FND_API.G_MISS_NUM,
                              lent_resource_cost, p_lent_resource_cost)
,tp_cost_in = DECODE( p_tp_cost_in, FND_API.G_MISS_NUM, tp_cost_in,
                      p_tp_cost_in)
,tp_cost_out = DECODE( p_tp_cost_out, FND_API.G_MISS_NUM, tp_cost_out,
                       p_tp_cost_out)
,cost_adj = DECODE( p_cost_adj, FND_API.G_MISS_NUM, cost_adj, p_cost_adj)
,unassigned_time_cost = DECODE( p_unassigned_time_cost, FND_API.G_MISS_NUM,
                                unassigned_time_cost, p_unassigned_time_cost)
,utilization_percent = DECODE( p_utilization_percent, FND_API.G_MISS_NUM,
                               utilization_percent, p_utilization_percent)
,utilization_hours = DECODE( p_utilization_hours, FND_API.G_MISS_NUM,
                             utilization_hours, p_utilization_hours)
,utilization_adj = DECODE( p_utilization_adj, FND_API.G_MISS_NUM,
                           utilization_adj, p_utilization_adj)
,capacity = DECODE( p_capacity, FND_API.G_MISS_NUM, capacity, p_capacity)
,head_count = DECODE( p_head_count, FND_API.G_MISS_NUM, head_count,
                      p_head_count)
,head_count_adj = DECODE( p_head_count_adj, FND_API.G_MISS_NUM, head_count_adj,
                          p_head_count_adj)
,projfunc_currency_code      =DECODE( p_projfunc_currency_code      ,
                                  FND_API.G_MISS_CHAR, projfunc_currency_code,
                                     p_projfunc_currency_code      )
,projfunc_cost_rate_type     =DECODE( p_projfunc_cost_rate_type     ,
                                  FND_API.G_MISS_CHAR, projfunc_cost_rate_type,
                                     p_projfunc_cost_rate_type     )
,projfunc_cost_exchange_rate =DECODE( p_projfunc_cost_exchange_rate ,
                                  FND_API.G_MISS_NUM,projfunc_cost_exchange_rate,
                                     p_projfunc_cost_exchange_rate )
,projfunc_cost_rate_date_type=DECODE( p_projfunc_cost_rate_date_type,
                                  FND_API.G_MISS_CHAR,  projfunc_cost_rate_date_type,
                                     p_projfunc_cost_rate_date_type)
,projfunc_cost_rate_date     =DECODE( p_projfunc_cost_rate_date     ,
                                  FND_API.G_MISS_DATE,  projfunc_cost_rate_date,
                                     p_projfunc_cost_rate_date     )
,projfunc_rev_rate_type      =DECODE( p_projfunc_rev_rate_type      ,
                                  FND_API.G_MISS_CHAR, projfunc_rev_rate_type,
                                     p_projfunc_rev_rate_type      )
,projfunc_rev_rate_date_type =DECODE( p_projfunc_rev_rate_date_type ,
                                  FND_API.G_MISS_CHAR,  projfunc_rev_rate_date_type,
                                     p_projfunc_rev_rate_date_type )
,projfunc_rev_exchange_rate  =DECODE( p_projfunc_rev_exchange_rate  ,
                                  FND_API.G_MISS_NUM, projfunc_rev_exchange_rate,
                                     p_projfunc_rev_exchange_rate  )
,projfunc_rev_rate_date      =DECODE( p_projfunc_rev_rate_date      ,
                                  FND_API.G_MISS_DATE,projfunc_rev_rate_date,
                                     p_projfunc_rev_rate_date      )
,project_currency_code       =DECODE( p_project_currency_code       ,
                                  FND_API.G_MISS_CHAR,project_currency_code,
                                     p_project_currency_code       )
,project_cost_rate_type      =DECODE( p_project_cost_rate_type      ,
                                  FND_API.G_MISS_CHAR, project_cost_rate_type,
                                     p_project_cost_rate_type      )
,project_cost_exchange_rate  =DECODE( p_project_cost_exchange_rate  ,
                                  FND_API.G_MISS_NUM,project_cost_exchange_rate,
                                     p_project_cost_exchange_rate  )
,project_cost_rate_date_type =DECODE( p_project_cost_rate_date_type ,
                                  FND_API.G_MISS_CHAR,project_cost_rate_date_type,
                                     p_project_cost_rate_date_type )
,project_cost_rate_date      =DECODE( p_project_cost_rate_date      ,
                                  FND_API.G_MISS_DATE,project_cost_rate_date,
                                     p_project_cost_rate_date      )
,project_raw_cost            =DECODE( p_project_raw_cost            ,
                                  FND_API.G_MISS_NUM,project_raw_cost,
                                     p_project_raw_cost            )
,project_burdened_cost       =DECODE( p_project_burdened_cost       ,
                                  FND_API.G_MISS_NUM,project_burdened_cost,
                                     p_project_burdened_cost       )
,project_revenue             =DECODE( p_project_revenue             ,
                                  FND_API.G_MISS_NUM,project_revenue,
                                     p_project_revenue             )
,txn_raw_cost                =DECODE( p_txn_raw_cost                ,
                                  FND_API.G_MISS_NUM,txn_raw_cost,
                                     p_txn_raw_cost                )
,txn_burdened_cost           =DECODE( p_txn_burdened_cost           ,
                                  FND_API.G_MISS_NUM,txn_burdened_cost,
                                     p_txn_burdened_cost           )
,txn_revenue                 =DECODE( p_txn_revenue                 ,
                                  FND_API.G_MISS_NUM,txn_revenue,
                                     p_txn_revenue                 )
,txn_currency_code           =DECODE( p_txn_currency_code           ,
                                  FND_API.G_MISS_CHAR,txn_currency_code,
                                     p_txn_currency_code          )
,bucketing_period_code       =DECODE( p_bucketing_period_code       ,
                                  FND_API.G_MISS_CHAR, bucketing_period_code,
                                     p_bucketing_period_code       )
,project_rev_rate_type       =DECODE( p_project_rev_rate_type       ,
                                  FND_API.G_MISS_CHAR,  project_rev_rate_type,
                                     p_project_rev_rate_type       )
,project_rev_exchange_rate   =DECODE( p_project_rev_exchange_rate   ,
                                  FND_API.G_MISS_NUM,project_rev_exchange_rate,
                                     p_project_rev_exchange_rate   )
,project_rev_rate_date_type  =DECODE( p_project_rev_rate_date_type  ,
                                  FND_API.G_MISS_CHAR, project_rev_rate_date_type,
                                     p_project_rev_rate_date_type  )
,project_rev_rate_date       =DECODE( p_project_rev_rate_date       ,
                                  FND_API.G_MISS_DATE,  project_rev_rate_date,
                                     p_project_rev_rate_date       )
,budget_version_id           =DECODE( p_budget_version_id           ,
                                  FND_API.G_MISS_NUM,budget_version_id,
                                     p_budget_version_id           )
WHERE budget_line_id = p_budget_line_id;

    IF (SQL%NOTFOUND) THEN
         PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_XC_RECORD_CHANGED');
         x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
-- +++++ Start of FP Build 4 changes +++++ --
    -- Bug Fix: 4569365. Removed MRC code.
	--If MRC is enabled, update the mrc lines also
    /*
    IF p_mrc_flag = 'Y' THEN
       IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS IS NULL THEN
              PA_MRC_FINPLAN.CHECK_MRC_INSTALL
                        (x_return_status      => l_return_status,
                         x_msg_count          => l_msg_count,
                         x_msg_data           => l_msg_data);
       END IF;

       IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS AND
          PA_MRC_FINPLAN.G_FINPLAN_MRC_OPTION_CODE = 'A' THEN
            PA_MRC_FINPLAN.MAINTAIN_ONE_MC_BUDGET_LINE
                       (p_budget_line_id => p_budget_line_id,
                        p_budget_version_id => p_budget_version_id,
                        p_action         => PA_MRC_FINPLAN.G_ACTION_UPDATE,
                        x_return_status  => l_return_status,
                        x_msg_count      => l_msg_count,
                        x_msg_data       => l_msg_data);
       END IF;

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

    END IF;
    */

-- +++++ End of FP Build 4 changes +++++ --
EXCEPTION
  WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg( p_pkg_name
                                    => 'PA_FP_BUDGET_LINES_PKG.Update_Row'
                               ,p_procedure_name
                                    => PA_DEBUG.G_Err_Stack);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
END Update_Row;

PROCEDURE Lock_Row
( p_resource_assignment_id   IN pa_budget_lines.resource_assignment_id%TYPE
                                := FND_API.G_MISS_NUM
 ,p_start_date               IN pa_budget_lines.start_date%TYPE
                                := FND_API.G_MISS_DATE
 ,p_row_id                   IN ROWID
                                := NULL
 ,x_return_status           OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
 IS
    l_row_id ROWID;

BEGIN
       SELECT rowid into l_row_id
         FROM pa_budget_lines
        WHERE resource_assignment_id =  p_resource_assignment_id
          AND start_date = p_start_date
          FOR UPDATE NOWAIT;
EXCEPTION
  WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg( p_pkg_name
                                    => 'PA_FP_BUDGET_LINES_PKG.Lock_Row',
                                p_procedure_name
                                    => PA_DEBUG.G_Err_Stack);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
END Lock_Row;

PROCEDURE Delete_Row
( p_budget_line_id        IN   pa_budget_lines.budget_line_id%TYPE
 ,p_row_id                IN   ROWID
 -- Bug Fix: 4569365. Removed MRC code.
 -- ,p_mrc_flag              IN   VARCHAR2
 ,x_return_status         OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
l_msg_count                     NUMBER := 0;
l_msg_data                      VARCHAR2(2000);
l_return_status                 VARCHAR2(2000);
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (p_budget_line_id IS NOT NULL) THEN
         DELETE FROM PA_BUDGET_LINES
          WHERE  budget_line_id = p_budget_line_id;
    ELSIF (p_row_id IS NOT NULL) THEN
         DELETE FROM PA_BUDGET_LINES
          WHERE rowid = p_row_id;
    END IF;

    IF (SQL%NOTFOUND) THEN
         PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_XC_RECORD_CHANGED');
         x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    -- Bug Fix: 4569365. Removed MRC code.
    /*
    IF p_mrc_flag = 'Y' THEN
       --If MRC is enabled, delete the mrc lines also
       IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS IS NULL THEN
              PA_MRC_FINPLAN.CHECK_MRC_INSTALL
                        (x_return_status      => l_return_status,
                         x_msg_count          => l_msg_count,
                         x_msg_data           => l_msg_data);
       END IF;

       IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS AND
          PA_MRC_FINPLAN.G_FINPLAN_MRC_OPTION_CODE = 'A' THEN
            PA_MRC_FINPLAN.MAINTAIN_ONE_MC_BUDGET_LINE
                       (p_budget_line_id => p_budget_line_id,
                        p_budget_version_id => null,
                        p_action         => PA_MRC_FINPLAN.G_ACTION_DELETE,
                        x_return_status  => l_return_status,
                        x_msg_count      => l_msg_count,
                        x_msg_data       => l_msg_data);
       END IF;

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

    END IF;
    */
EXCEPTION
  WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg( p_pkg_name
                                    => 'PA_FP_BUDGET_LINES_PKG.Delete_Row'
                               ,p_procedure_name
                                    => PA_DEBUG.G_Err_Stack);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
END Delete_Row;

END pa_fp_budget_lines_pkg;

/
