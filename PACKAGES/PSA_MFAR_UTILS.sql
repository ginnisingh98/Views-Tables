--------------------------------------------------------
--  DDL for Package PSA_MFAR_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSA_MFAR_UTILS" AUTHID CURRENT_USER AS
/* $Header: PSAMFUTS.pls 120.9 2006/09/15 11:47:40 agovil ship $ */

TYPE trx_rec IS RECORD (
                          customer_trx_id number,
                          user_id number,
                          status       varchar2(240),
                          actual_flag  varchar2(240),
                          pst_ctrl_id  number,
                          sob_id       number,
                          source       varchar2(240),
                          cm_cat_name  varchar2(240),
                          dm_cat_name  varchar2(240),
                          cb_cat_name  varchar2(240),
                          inv_cat_name varchar2(240),
                          batch_prefix varchar2(240),
                          summary_flag varchar2(240),
                          pre_ct_line  varchar2(240),
                          post_ct_line varchar2(240),
                          class_cb     varchar2(240),
                          class_cm     varchar2(240),
                          class_dm     varchar2(240),
                          class_dep    varchar2(240),
                          class_guar   varchar2(240),
                          class_inv    varchar2(240),
                          nxtval_id    number,
                          start_date   date,
                          post_thru_date date,
                          last_update_date date
                          );


TYPE adj_rec IS RECORD (
                          adjustment_id number
                          ,user_id          number
                          ,status          varchar2(240)
                          ,actual_flag     varchar2(240)
                          ,pst_ctrl_id     number
                          ,sob_id          number
                          ,source          varchar2(240)
                          ,adj_cat_name    varchar2(240)
                          ,batch_prefix    varchar2(240)
                          ,summary_flag    varchar2(240)
                          ,pre_adjcr_ar    varchar2(240)
                          ,pre_adjdr_ar    varchar2(240)
                          ,pre_adjdr_adj   varchar2(240)
                          ,pre_adjcr_adj   varchar2(240)
                          ,pre_adjdr       varchar2(240)
                          ,pre_adjcr       varchar2(240)
                          ,pre_adj_nrtax   varchar2(240)
                          ,pre_adj_finchrg varchar2(240)
                          ,pre_adj_finchrg_nrtax varchar2(240)
                          ,pre_adj_tax     varchar2(240)
                          ,pre_adj_deftax  varchar2(240)
                          ,class_cb        varchar2(240)
                          ,class_cm        varchar2(240)
                          ,class_dep       varchar2(240)
                          ,class_dm        varchar2(240)
                          ,class_guar      varchar2(240)
                          ,class_inv       varchar2(240)
                          ,post_general    varchar2(240)
                          ,nxtval_id       number
                          ,start_date      date
                          ,post_thru_date  date ,
			  last_update_date date
                          );


TYPE rct_rec IS RECORD (
                          ra_receivable_application_id number
                          ,user_id         number
                          ,status         varchar2(240)
                          ,actual_flag    varchar2(240)
                          ,pst_ctrl_id    number
                          ,sob_id         number
                          ,source         varchar2(240)
                          ,trade_cat_name varchar2(240)
                          ,ccurr_cat_name varchar2(240)
                          ,cmapp_cat_name varchar2(240)
                          ,func_curr     varchar2(240)
                          ,pre_tradeapp  varchar2(240)
                          ,app_onacc     varchar2(240)
                          ,app_unapp     varchar2(240)
                          ,app_unid      varchar2(240)
                          ,app_applied   varchar2(240)
                          ,pre_erdisc    varchar2(240)
                          ,pre_rec_erdisc_nrtax varchar2(240)
                          ,pre_undisc    varchar2(240)
                          ,pre_rec_undisc_nrtax varchar2(240)
                          ,pre_rec_gain  varchar2(240)
                         ,pre_rec_loss  varchar2(240)
                          ,pre_rec_curr_round varchar2(240)
                          ,pre_rec_tax   varchar2(240)
                          ,pre_rec_deftax varchar2(240)
                          ,class_cb      varchar2(240)
                          ,class_cm      varchar2(240)
                          ,class_dep     varchar2(240)
                          ,class_dm      varchar2(240)
                          ,class_guar    varchar2(240)
                          ,class_inv     varchar2(240)
                          ,post_general  varchar2(240)
                          ,pre_cmapp     varchar2(240)
                          ,pre_cmgain    varchar2(240)
                          ,pre_cmloss    varchar2(240)
                          ,batch_prefix  varchar2(240)
                          ,summary_flag  varchar2(240)
                          ,pre_receipt   varchar2(240)
                          ,post_receipt  varchar2(240)
                          ,nxtval_id     number
                          ,start_date    date
                          ,post_thru_date date,
			  last_update_date date
		  );

function get_user_category_name (cat_name in varchar2)
return varchar2 ;



FUNCTION override_segments
		(p_primary_ccid			IN  NUMBER,
		 p_override_ccid		IN  NUMBER,
		 p_set_of_books_id		IN  NUMBER,
		 p_trx_type			IN  VARCHAR2,
		 P_ccid		 		OUT NOCOPY NUMBER)
		RETURN BOOLEAN;

PROCEDURE INSERT_DISTRIBUTIONS_LOG (p_error_id	      IN NUMBER,
				    p_activity 	      IN VARCHAR2,
				    p_customer_trx_id IN NUMBER,
				    p_activity_id     IN NUMBER,
				    p_error_message   IN VARCHAR2);

PROCEDURE PSA_MF_ORG_DETAILS (l_org_details OUT NOCOPY psa_implementation_all%rowtype);

FUNCTION get_ar_sob_id return number;

FUNCTION get_rec_ccid (p_applied_trx_id in NUMBER, p_trx_id IN NUMBER) return number;

FUNCTION get_coa (sob_id in number) return number;

FUNCTION accounting_method RETURN VARCHAR2;

PROCEDURE insert_ccid (p_ccid         IN NUMBER,
                       p_segment_info IN FND_FLEX_EXT.SEGMENTARRAY,
                       p_num_segments IN NUMBER);

FUNCTION is_ccid_exists(x_ccid               IN OUT  NOCOPY NUMBER,
                        x_segment_info       IN OUT  NOCOPY FND_FLEX_EXT.SEGMENTARRAY,
                        x_number_of_segments    OUT  NOCOPY NUMBER)
RETURN BOOLEAN;

/* Modified this structure for bug 4496742
TYPE hold_ccid_info_rec_type IS RECORD
         (ccid      NUMBER(15),
          SEGMENTS  FND_FLEX_EXT.SEGMENTARRAY,
          NUMBER_OF_SEGMENTS NUMBER);
*/

TYPE hold_ccid_info_rec_type IS RECORD
         (ccid      NUMBER(15),
          segment1  VARCHAR2(200),
          segment2  VARCHAR2(200),
          segment3  VARCHAR2(200),
          segment4  VARCHAR2(200),
          segment5  VARCHAR2(200),
          segment6  VARCHAR2(200),
          segment7  VARCHAR2(200),
          segment8  VARCHAR2(200),
          segment9  VARCHAR2(200),
          segment10  VARCHAR2(200),
          segment11  VARCHAR2(200),
          segment12  VARCHAR2(200),
          segment13  VARCHAR2(200),
          segment14  VARCHAR2(200),
          segment15  VARCHAR2(200),
          segment16  VARCHAR2(200),
          segment17  VARCHAR2(200),
          segment18  VARCHAR2(200),
          segment19  VARCHAR2(200),
          segment20  VARCHAR2(200),
          segment21  VARCHAR2(200),
          segment22  VARCHAR2(200),
          segment23  VARCHAR2(200),
          segment24  VARCHAR2(200),
          segment25  VARCHAR2(200),
          segment26  VARCHAR2(200),
          segment27  VARCHAR2(200),
          segment28  VARCHAR2(200),
          segment29  VARCHAR2(200),
          segment30  VARCHAR2(200),
          NUMBER_OF_SEGMENTS NUMBER);


TYPE hold_ccid_info_tab_type IS TABLE OF hold_ccid_info_rec_type
INDEX BY BINARY_INTEGER;

TYPE combinations_rec IS RECORD
        (combination    VARCHAR2(800),
         error_message  VARCHAR2(2000));

TYPE combinations_table IS TABLE OF combinations_rec INDEX BY BINARY_INTEGER;

g_invalid_combinations   combinations_table;
g_invalid_index          BINARY_INTEGER;
ccid_info               hold_ccid_info_tab_type;
g_chart_of_accounts_id  gl_sets_of_books.chart_of_accounts_id%TYPE;
g_bal_acct_seg_num		NUMBER;
g_nat_acct_seg_num		NUMBER;
g_org_details			PSA_IMPLEMENTATION_ALL%ROWTYPE;
g_segment_delimiter     fnd_id_flex_structures.concatenated_segment_delimiter%TYPE;

END PSA_MFAR_UTILS;

 

/
