--------------------------------------------------------
--  DDL for Package JE_ZZ_AUDIT_AP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JE_ZZ_AUDIT_AP_PKG" AUTHID CURRENT_USER
-- $Header: jezzauditaps.pls 120.2 2006/06/16 11:04:43 spasupun ship $
AS
  P_VAT_REPORTING_ENTITY_ID NUMBER;
  P_CHART_OF_ACC_ID        NUMBER;
  P_LEGAL_ENTITY_ID	   NUMBER;
  P_LEDGER_ID		   NUMBER;
  G_LE_ID                  NUMBER;
  P_COMPANY                VARCHAR2(35);
  P_REP_DATE               DATE;
  P_CALLING_REPORT         VARCHAR2(40);
  P_REPORT_BY		   VARCHAR2(1);
  P_PERIOD		   VARCHAR2(20);
  G_ledger_name            VARCHAR2(30);
  G_LEDGER_CURR            VARCHAR2(15);
  G_STRUCT_NUM             VARCHAR2(15) := '0';
  G_CURR_NAME              VARCHAR2(40);
  G_INDUSTRY_CODE          VARCHAR2(20);
  G_company_title          VARCHAR2(20);
  G_precision              NUMBER;
  G_disc_isinvlesstax_flag VARCHAR2(1) := 'N';
  G_tax_discount_amt       NUMBER;
  G_DATA_FOUND             VARCHAR2(40);


  FUNCTION BeforeReport RETURN BOOLEAN;

  FUNCTION g_companygroupfilter(company IN VARCHAR2) RETURN BOOLEAN;

  PROCEDURE get_lookup_meaning
  (
    p_lookup_type    IN VARCHAR2
   ,p_lookup_code    IN VARCHAR2
   ,x_lookup_meaning IN OUT NOCOPY VARCHAR2
  );

  PROCEDURE get_boiler_plates;

  FUNCTION c_payment_amtformula
  (
    p_tax_type   IN VARCHAR2
   ,p_inv_type   IN VARCHAR2
   ,p_invoice_id IN NUMBER
   ,p_pay_amt    IN NUMBER
   ,p_start_date IN DATE
   ,p_end_date   IN DATE
  ) RETURN NUMBER;

  FUNCTION cf_rec_tax_calcformula(p_rec_per IN NUMBER) RETURN CHAR;

  FUNCTION cf_tax_amtformula
  (
    p_invoice_id        IN NUMBER
   ,p_tax_type          IN VARCHAR2
   ,p_inv_type          IN VARCHAR2
   ,p_real_inv_amt      IN NUMBER
   ,p_txbl_discount_amt IN NUMBER
   ,p_tax_amt           IN NUMBER
   ,p_payment_amt       IN NUMBER
   ,p_check_void_date   IN DATE
   ,p_start_date        IN DATE
   ,p_end_date          IN DATE
  ) RETURN NUMBER;

  FUNCTION cf_txbl_discount_amtformula
  (
    p_tax_type   IN VARCHAR2
   ,p_inv_type   IN VARCHAR2
   ,p_invoice_id IN NUMBER
   ,p_tax_rate   IN NUMBER
   ,p_start_date IN DATE
   ,p_end_date   IN DATE
  ) RETURN NUMBER;

  FUNCTION cf_item_tax_amtformula
  (
    p_cancelled_date IN DATE
   ,p_acc_date       IN DATE
   ,p_tax_amt        IN NUMBER
   ,p_item_line_cnt  IN NUMBER
   ,p_start_date     IN DATE
   ,p_end_date       IN DATE
  ) RETURN NUMBER;

  FUNCTION cf_real_inv_amtformula
  (
    p_invoice_id     IN NUMBER
   ,p_invoice_amount IN NUMBER
  ) RETURN NUMBER;

  FUNCTION G_DATA_FOUND_formula RETURN VARCHAR2;
  FUNCTION G_CURR_NAME_formula RETURN VARCHAR2;
  FUNCTION G_company_title_formula RETURN VARCHAR2;
  FUNCTION G_PRECISION_formula RETURN NUMBER;

  FUNCTION C_PRT_AMT_TXBLFormula
  (
    p_tax_type              IN VARCHAR2
   ,p_const_num             IN VARCHAR2
   ,p_inv_type              IN VARCHAR2
   ,p_tax_rate              IN NUMBER
   ,p_invoice_id            IN NUMBER
   ,p_tax_id                IN NUMBER
   ,p_offset_tax_rate_code  IN VARCHAR2
   ,p_start_date            IN DATE
   ,p_end_date              IN DATE
   ,p_real_inv_amt          IN NUMBER
   ,p_cancelled_date        IN DATE
   ,p_check_void_date       IN DATE
   ,p_payment_amt           IN NUMBER
   ,p_txbl_disc_amt         IN NUMBER
   ,p_tax_disc_amt          IN NUMBER
  ) RETURN VARCHAR2;

  FUNCTION C_PRT_INV_AMTFormula
  (
    p_cancelled_date IN DATE
   ,P_START_DATE     IN DATE
   ,P_END_DATE       IN DATE
   ,p_real_inv_amt   IN NUMBER
  ) RETURN VARCHAR2;

  FUNCTION set_display_for_core RETURN BOOLEAN;
  FUNCTION set_display_for_gov RETURN BOOLEAN;

  FUNCTION get_balancing_segment
    (
      p_ccid         IN NUMBER
     ,x_company_desc IN OUT NOCOPY VARCHAR2
    )
    RETURN VARCHAR2;

  FUNCTION get_balancing_segment
    (
      p_ccid         IN NUMBER
    )
    RETURN VARCHAR2;

    FUNCTION G_LEDGER_CURR_FORMULA RETURN VARCHAR2;
    FUNCTION G_INDUSTRY_CODE_FORMULA RETURN VARCHAR2;

  FUNCTION get_accounting_segment(p_ccid NUMBER) RETURN VARCHAR2;
 END JE_ZZ_AUDIT_AP_PKG;

 

/
