--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_BURDEN_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_BURDEN_SUMMARY" AUTHID CURRENT_USER AS
/* $Header: PAXBSGCS.pls 120.4 2006/05/26 07:43:32 rahariha noship $ */

  FUNCTION CLIENT_GROUPING

  (
   p_src_expnd_type     IN PA_EXPENDITURE_TYPES.expenditure_type%TYPE,
   p_src_ind_expnd_type IN PA_EXPENDITURE_TYPES.expenditure_type%TYPE,
   p_src_attribute1     IN PA_EXPENDITURE_TYPES.attribute1%TYPE,
   p_src_attribute2     IN PA_EXPENDITURE_TYPES.attribute2%TYPE,
   p_src_attribute3     IN PA_EXPENDITURE_TYPES.attribute3%TYPE,
   p_src_attribute4     IN PA_EXPENDITURE_TYPES.attribute4%TYPE,
   p_src_attribute5     IN PA_EXPENDITURE_TYPES.attribute5%TYPE,
   p_src_attribute6     IN PA_EXPENDITURE_TYPES.attribute6%TYPE,
   p_src_attribute7     IN PA_EXPENDITURE_TYPES.attribute7%TYPE,
   p_src_attribute8     IN PA_EXPENDITURE_TYPES.attribute8%TYPE,
   p_src_attribute9     IN PA_EXPENDITURE_TYPES.attribute9%TYPE,
   p_src_attribute10    IN PA_EXPENDITURE_TYPES.attribute10%TYPE,
   p_src_attribute_category    IN PA_EXPENDITURE_TYPES.attribute_category%TYPE
   ,p_src_exp_item_date  IN PA_EXPENDITURE_ITEMS_ALL.expenditure_item_date%TYPE DEFAULT NULL
  ,p_src_acct_rate_date              IN PA_COST_DISTRIBUTION_LINES_ALL.ACCT_RATE_DATE%TYPE DEFAULT NULL
  ,p_src_acct_rate_type              IN PA_COST_DISTRIBUTION_LINES_ALL.ACCT_RATE_TYPE%TYPE DEFAULT NULL
  ,p_src_acct_exchange_rate          IN PA_COST_DISTRIBUTION_LINES_ALL.ACCT_EXCHANGE_RATE%TYPE DEFAULT NULL
  ,p_src_project_rate_date           IN PA_COST_DISTRIBUTION_LINES_ALL.PROJECT_RATE_DATE%TYPE DEFAULT NULL
  ,p_src_project_rate_type           IN PA_COST_DISTRIBUTION_LINES_ALL.PROJECT_RATE_TYPE%TYPE DEFAULT NULL
  ,p_src_project_exchange_rate       IN PA_COST_DISTRIBUTION_LINES_ALL.PROJECT_EXCHANGE_RATE%TYPE DEFAULT NULL
  ,p_src_projfunc_cost_rate_date     IN PA_COST_DISTRIBUTION_LINES_ALL.PROJFUNC_COST_RATE_DATE%TYPE DEFAULT NULL
  ,p_src_projfunc_cost_rate_type     IN PA_COST_DISTRIBUTION_LINES_ALL.PROJFUNC_COST_RATE_TYPE%TYPE DEFAULT NULL
  ,p_src_projfunc_cost_xchng_rate    IN PA_COST_DISTRIBUTION_LINES_ALL.PROJFUNC_COST_EXCHANGE_RATE%TYPE DEFAULT NULL
  ) RETURN varchar2 ;


 PROCEDURE CLIENT_COLUMN_VALUES
  (
   p_src_attribute2     IN OUT NOCOPY PA_EXPENDITURE_TYPES.attribute2%TYPE,
   p_src_attribute3     IN OUT NOCOPY PA_EXPENDITURE_TYPES.attribute3%TYPE,
   p_src_attribute4     IN OUT NOCOPY PA_EXPENDITURE_TYPES.attribute4%TYPE,
   p_src_attribute5     IN OUT NOCOPY PA_EXPENDITURE_TYPES.attribute5%TYPE,
   p_src_attribute6     IN OUT NOCOPY PA_EXPENDITURE_TYPES.attribute6%TYPE,
   p_src_attribute7     IN OUT NOCOPY PA_EXPENDITURE_TYPES.attribute7%TYPE,
   p_src_attribute8     IN OUT NOCOPY PA_EXPENDITURE_TYPES.attribute8%TYPE,
   p_src_attribute9     IN OUT NOCOPY PA_EXPENDITURE_TYPES.attribute9%TYPE,
   p_src_attribute10    IN OUT NOCOPY PA_EXPENDITURE_TYPES.attribute10%TYPE,
   p_src_attribute_category IN PA_EXPENDITURE_TYPES.attribute_category%TYPE
  ,p_src_acct_rate_date           IN OUT NOCOPY PA_COST_DISTRIBUTION_LINES_ALL.ACCT_RATE_DATE%TYPE
  ,p_src_acct_rate_type           IN OUT NOCOPY PA_COST_DISTRIBUTION_LINES_ALL.ACCT_RATE_TYPE%TYPE
  ,p_src_acct_exchange_rate       IN OUT NOCOPY PA_COST_DISTRIBUTION_LINES_ALL.ACCT_EXCHANGE_RATE%TYPE
  ,p_src_project_rate_date        IN OUT NOCOPY PA_COST_DISTRIBUTION_LINES_ALL.PROJECT_RATE_DATE%TYPE
  ,p_src_project_rate_type        IN OUT NOCOPY PA_COST_DISTRIBUTION_LINES_ALL.PROJECT_RATE_TYPE%TYPE
  ,p_src_project_exchange_rate    IN OUT NOCOPY PA_COST_DISTRIBUTION_LINES_ALL.PROJECT_EXCHANGE_RATE%TYPE
  ,p_src_projfunc_cost_rate_date  IN OUT NOCOPY PA_COST_DISTRIBUTION_LINES_ALL.PROJFUNC_COST_RATE_DATE%TYPE
  ,p_src_projfunc_cost_rate_type  IN OUT NOCOPY PA_COST_DISTRIBUTION_LINES_ALL.PROJFUNC_COST_RATE_TYPE%TYPE
  ,p_src_projfunc_cost_xchng_rate IN OUT NOCOPY PA_COST_DISTRIBUTION_LINES_ALL.PROJFUNC_COST_EXCHANGE_RATE%TYPE
  );

/* Function Same_Line_Burden_Cmt added for bug 2989775 */

        FUNCTION Same_Line_Burden_Cmt
        RETURN BOOLEAN;

        pragma RESTRICT_REFERENCES (Same_Line_Burden_Cmt, WNDS, WNPS);

END PA_CLIENT_EXTN_BURDEN_SUMMARY;

 

/
