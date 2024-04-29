--------------------------------------------------------
--  DDL for Package FII_SIZING_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_SIZING_UTIL" AUTHID CURRENT_USER AS
/* $Header: FIISZ01S.pls 120.1 2005/06/07 11:57:10 sgautam noship $ */

/* Count rows retrieved from the PA REVENUE fact source view */
PROCEDURE fii_pa_revenue_f_cnt 	(p_from_date DATE,
                 	p_to_date DATE,
                 	p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER);

PROCEDURE fii_pa_revenue_f_len (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER);

/* Count rows retrieved from the PA COST fact source view */
PROCEDURE fii_pa_cost_f_cnt (p_from_date DATE,
                  	 p_to_date DATE,
                  	 p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER);

PROCEDURE fii_pa_cost_f_len (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER);

/* Count rows retrieved from the PA BUDGET fact source view */
PROCEDURE fii_pa_budget_f_cnt (p_from_date DATE,
                   	p_to_date DATE,
                  	p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER);

PROCEDURE fii_pa_budget_f_len (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER);

/* Count rows retrieved from the Project Budget dimension source view */
PROCEDURE fii_pa_budget_m_cnt (p_from_date DATE,
                  	 p_to_date DATE,
                 	 p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER);

PROCEDURE fii_pa_budget_m_len (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER);

/* Count rows retrieved from the Project Expenditure Type dimension source view */
PROCEDURE fii_pa_exp_type_m_cnt (p_from_date DATE,
                   	p_to_date DATE,
                   	p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER);

PROCEDURE fii_pa_exp_type_m_len (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER);

/* Count rows retrieved from the Project dimension source view */
PROCEDURE edw_project_m_cnt (p_from_date DATE,
                  	 p_to_date DATE,
                  	 p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER);

PROCEDURE edw_project_m_len (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER);

/* Estimate average row length and number of rows for FII_AP_INV_ON_HOLD_F */
PROCEDURE FII_AP_INV_ON_HOLD_F_CNT (p_from_date DATE,
                  	 p_to_date DATE,
                  	 p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER);

PROCEDURE FII_AP_INV_ON_HOLD_F_LEN (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER);

/* Estimate average row length and number of rows for FII_AR_TRX_DIST_F */
PROCEDURE FII_AR_TRX_DIST_F_CNT (p_from_date DATE,
                  	 p_to_date DATE,
                  	 p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER);

PROCEDURE FII_AR_TRX_DIST_F_LEN (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER);

/* Estimate average row length and number of rows for FII_E_REVENUE_F */
PROCEDURE FII_E_REVENUE_F_CNT (p_from_date DATE,
                  	 p_to_date DATE,
                  	 p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER);

PROCEDURE FII_E_REVENUE_F_LEN (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER);

/* Estimate average row length and number of rows for EDW_AR_DOC_NUM_M */
PROCEDURE EDW_AR_DOC_NUM_M_CNT (p_from_date DATE,
                  	 p_to_date DATE,
                  	 p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER);

PROCEDURE EDW_AR_DOC_NUM_M_LEN (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER);

/* Estimate average row length and number of rows for EDW_TIME_M */
PROCEDURE EDW_TIME_M_CNT (p_from_date DATE,
                  	 p_to_date DATE,
                  	 p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER);

PROCEDURE EDW_TIME_M_LEN (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER);

/* Estimate average row length and number of rows for FII_AP_INV_LINES_F */
PROCEDURE FII_AP_INV_LINES_F_CNT (p_from_date DATE,
                  	 p_to_date DATE,
                  	 p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER);

PROCEDURE FII_AP_INV_LINES_F_LEN (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER);

/* Estimate average row length and number of rows for FII_AP_SCH_PAYMTS_F */
PROCEDURE FII_AP_SCH_PAYMTS_F_CNT (p_from_date DATE,
                  	 p_to_date DATE,
                  	 p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER);

PROCEDURE FII_AP_SCH_PAYMTS_F_LEN (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER);

/* Estimate average row length and number of rows for FII_AP_INV_PAYMTS_F */
PROCEDURE FII_AP_INV_PAYMTS_F_CNT (p_from_date DATE,
                  	 p_to_date DATE,
                  	 p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER);

PROCEDURE FII_AP_INV_PAYMTS_F_LEN (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER);

/* Estimate average row length and number of rows for FII_AP_HOLD_DATA_F */
PROCEDURE FII_AP_HOLD_DATA_F_CNT (p_from_date DATE,
                  	 p_to_date DATE,
                  	 p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER);

PROCEDURE FII_AP_HOLD_DATA_F_LEN (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER);

/* Estimate average row length and number of rows for EDW_AP_PAYMENT_M */
PROCEDURE EDW_AP_PAYMENT_M_CNT (p_from_date DATE,
                  	 p_to_date DATE,
                  	 p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER);

PROCEDURE EDW_AP_PAYMENT_M_LEN (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER);

/* Estimate average row length and number of rows for EDW_INV_TYPE_M */
PROCEDURE EDW_INV_TYPE_M_CNT (p_from_date DATE,
                  	 p_to_date DATE,
                  	 p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER);

PROCEDURE EDW_INV_TYPE_M_LEN (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER);

END;

 

/
