--------------------------------------------------------
--  DDL for Package GCS_RP_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_RP_UTILITY_PKG" AUTHID CURRENT_USER AS
 
--API Name
  g_api		VARCHAR2(50) :=	'gcs.plsql.GCS_RP_UTILITY_PKG';
 
  -- Action types for writing module information to the log file. Used for
  -- the procedure log_file_module_write.
  g_module_enter      VARCHAR2(2) := '>>';
  g_module_success    VARCHAR2(2) := '<<';
  g_module_failure    VARCHAR2(2) := '<x';
 
  g_rp_selColumnList  VARCHAR2(10000) := '
 '; 
 
  g_rp_srcColumnList  VARCHAR2(10000) := '
 '; 
 
  g_rp_tgtColumnList  VARCHAR2(10000) := '
 '; 
 
  g_rp_offColumnList  VARCHAR2(10000) := '
 ) '; 
 
  g_core_insert_stmt VARCHAR2(2000) := 
  'INSERT INTO gcs_entries_gt(   
    rule_id                   , 
    step_seq                  , 
    step_name                 , 
    formula_text              , 
    rule_step_id              , 
    offset_flag               , 
    sql_statement_num         , 
    currency_code             , 
    ad_input_amount           , 
    pe_input_amount           , 
    ce_input_amount           , 
    ee_input_amount		  , 
    output_amount             , 
    entity_id                 , 
    ytd_credit_balance_e      , 
    ytd_debit_balance_e       , 
    src_company_cost_center_org_id , 
    src_intercompany_id       , 
    tgt_company_cost_center_org_id , 
    tgt_intercompany_id       '; 
 
  g_core_sel_stmt VARCHAR2(2000)      := 
  'SELECT :rid                              , 
           :seq                              , 
           :sna                              , 
           :ftx                              , 
           :rsi                              , 
           :osf                              , 
           :stn                              , 
           :ccy                              , 
           0                                 , 
           SUM(                                
             DECODE(b.entity_id, :pid,         
               b.ytd_balance_e, 0))          , 
           SUM(                                
             DECODE(b.entity_id, :cid,         
               b.ytd_balance_e, 0))          , 
           SUM(                                
             DECODE(b.entity_id, :eid,         
               b.ytd_balance_e, 0))          , 
           0                                 , 
           0                                 , 
           0                                 , 
           0                                 ,  
           b.company_cost_center_org_id      , 
           b.intercompany_id                 , 
           :tgt_cctr_org_id                  , 
           :tgt_intercompany_id              ';
 
 g_core_frm_stmt VARCHAR2(2000)       :=    ' 
   FROM   fem_balances b                    ';
 g_core_whr_stmt VARCHAR2(2000)       :=     '
   WHERE  b.dataset_code       =   :dci        
   AND    b.cal_period_id      =   :cpi        
   AND    b.source_system_code =   70          
   AND    b.ledger_id          =   :ledger     
   AND    b.currency_code      =   :ccy ';    
 
 g_core_grp_stmt VARCHAR2(2000)       := '    
   group by b.company_cost_center_org_id       
   ,b.intercompany_id';               
 
  --Public Procedure and Function Definitions 
 
  --                                                                                     
  -- Procedure                                                                           
  --   create_entry_lines                                                                
  -- Purpose                                                                             
  --   Generated SQL statement to insert data into gcs_entry_lines from gcs_entries_gt   
  --                                                                                     
  -- Arguments                                                                           
  -- p_entry_id: entry identifier                                                        
  -- p_row_count: #of rows inserted                                                      
  --                                                                                     
  PROCEDURE create_entry_lines (p_entry_id IN NUMBER,                                    
                                p_offset_flag IN VARCHAR2,                               
                                p_row_count IN OUT NOCOPY NUMBER);                       
  --                                                                                     
  -- Procedure                                                                           
  --   create_off_gt_lines                                                               
  -- Purpose                                                                             
  --   creates offset lines in gcs_entries_gt for performance                            
  --                                                                                     
  -- Arguments                                                                           
  -- p_rule_id:  rule identifier                                                         
  -- p_step_seq: step seq identifier                                                     
  -- p_offset_members: offset member object                                              
  --                                                                                     
  --PROCEDURE create_off_gt_lines(p_entry_id IN NUMBER,                                  
  --                              p_row_count IN OUT NOCOPY NUMBER);                     
  --                                                                                     
END GCS_RP_UTILITY_PKG;

/
