--------------------------------------------------------
--  DDL for Package IGC_CC_ACCGNWF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CC_ACCGNWF_PKG" AUTHID CURRENT_USER AS
/* $Header: IGCCAGNS.pls 120.3.12000000.2 2007/10/18 15:48:09 vumaasha ship $ */

PROCEDURE Generate_Account
(
  p_project_id                     IN  igc_cc_acct_lines.project_id%TYPE       ,
  p_task_id                        IN  igc_cc_acct_lines.task_id%TYPE          ,
  p_expenditure_type               IN  igc_cc_acct_lines.expenditure_type%TYPE ,
  p_expenditure_organization_id    IN  igc_cc_acct_lines.expenditure_org_id%TYPE ,
  p_expenditure_item_date          IN  igc_cc_acct_lines.expenditure_item_date%TYPE,
  p_vendor_id                      IN  NUMBER,
  p_chart_of_accounts_id           IN  NUMBER,
  p_gen_budget_account             IN  VARCHAR2,  /* 'Y' or 'N' */
  p_cc_acct_line_id                IN  igc_cc_acct_lines.cc_acct_line_id%TYPE ,
  p_cc_header_id                   IN  igc_cc_acct_lines.cc_header_id%TYPE ,
  p_cc_charge_ccid                 IN  igc_cc_acct_lines.cc_charge_code_combination_id%TYPE ,
  p_cc_budget_ccid                 IN  igc_cc_acct_lines.cc_budget_code_combination_id%TYPE ,
  p_cc_acct_desc                   IN  igc_cc_acct_lines.cc_acct_desc%TYPE ,
  p_cc_acct_taxable_flag           IN  igc_cc_acct_lines.cc_acct_taxable_flag%TYPE ,
  p_tax_name                       IN  igc_cc_acct_lines.tax_classif_code%TYPE , /* bug -6472296 Modified tax_id to tax_name for Ebtax uptake*/
  p_context                        IN  igc_cc_acct_lines.context%TYPE ,
  p_attribute1                     IN  igc_cc_acct_lines.attribute1%TYPE ,
  p_attribute2                     IN  igc_cc_acct_lines.attribute2%TYPE ,
  p_attribute3                     IN  igc_cc_acct_lines.attribute3%TYPE ,
  p_attribute4                     IN  igc_cc_acct_lines.attribute4%TYPE ,
  p_attribute5                     IN  igc_cc_acct_lines.attribute5%TYPE ,
  p_attribute6                     IN  igc_cc_acct_lines.attribute6%TYPE ,
  p_attribute7                     IN  igc_cc_acct_lines.attribute7%TYPE ,
  p_attribute8                     IN  igc_cc_acct_lines.attribute8%TYPE ,
  p_attribute9                     IN  igc_cc_acct_lines.attribute9%TYPE ,
  p_attribute10                    IN  igc_cc_acct_lines.attribute10%TYPE ,
  p_attribute11                    IN  igc_cc_acct_lines.attribute11%TYPE ,
  p_attribute12                    IN  igc_cc_acct_lines.attribute12%TYPE ,
  p_attribute13                    IN  igc_cc_acct_lines.attribute13%TYPE ,
  p_attribute14                    IN  igc_cc_acct_lines.attribute14%TYPE ,
  p_attribute15                    IN  igc_cc_acct_lines.attribute15%TYPE ,

  x_out_charge_ccid                OUT NOCOPY igc_cc_acct_lines.cc_charge_code_combination_id%TYPE ,
  x_out_budget_ccid                OUT NOCOPY igc_cc_acct_lines.cc_budget_code_combination_id%TYPE ,
  x_out_charge_account_flex        OUT NOCOPY VARCHAR2,
  x_out_budget_account_flex        OUT NOCOPY VARCHAR2,
  x_out_charge_account_desc        OUT NOCOPY VARCHAR2,
  x_out_budget_account_desc        OUT NOCOPY VARCHAR2,

  x_return_status                  OUT NOCOPY     VARCHAR2,
  x_msg_count                      OUT NOCOPY     NUMBER  ,
  x_msg_data                       OUT NOCOPY     VARCHAR2
);

--
END IGC_CC_ACCGNWF_PKG;

 

/
