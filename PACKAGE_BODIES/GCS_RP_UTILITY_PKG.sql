--------------------------------------------------------
--  DDL for Package Body GCS_RP_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_RP_UTILITY_PKG" AS                                     
                                                                                         
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
                                p_row_count IN OUT NOCOPY NUMBER)                        
  IS                                                                                     
    l_elimtb_y_n VARCHAR2(1) := 'Y';                                                   
  BEGIN                                                                                  
                                                                                         
    if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then                 
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'gcs_rp_utility_pkg.begin', null);       
    end if;                                                                              
                                                                                         
    begin                                                                                
      select 'N'                                                                       
      into l_elimtb_y_n                                                                  
      from gcs_entries_gt geg                                                            
      where formula_text NOT LIKE '%ELIMTB%'                                                   
      and rownum < 2;                                                                    
      exception when others then l_elimtb_y_n := 'Y';                                      
    end;                                                                                 
                                                                                         
    if (l_elimtb_y_n = 'N') then                                                       
    insert into gcs_entry_lines                                                          
    (      entry_id,                                                                     
           company_cost_center_org_id,                                                   
           intercompany_id,                                                              
           ytd_debit_balance_e,                                                          
           ytd_credit_balance_e,                                                         
           ytd_balance_e,                                                                
           creation_date,                                                                
           created_by,                                                                   
           last_updated_by,                                                              
           last_update_date,                                                             
           last_update_login                                                             
    )                                                                                    
    SELECT p_entry_id,                                                                   
           min(geg.tgt_company_cost_center_org_id),                                      
           min(geg.tgt_intercompany_id),                                                 
           sum(decode(sign(geg.output_amount), 1,                                        
                                               geg.output_amount, 0)),                   
           sum(decode(sign(geg.output_amount), -1,                                       
                                               -1 *geg.output_amount, 0)),               
           sum(geg.output_amount),                                                       
           sysdate,                                                                      
           fnd_global.user_id,                                                           
           fnd_global.user_id,                                                           
           sysdate,                                                                      
           fnd_global.login_id                                                           
    FROM   gcs_entries_gt geg                                                            
    GROUP BY geg.tgt_line_item_id                                                        
    ;                                                                                    
                                                                                         
    --check number of rows inserted                                                      
    p_row_count  := SQL%ROWCOUNT;                                                        
                                                                                         
    --insert rows if the offset flag was used                                            
    if (p_offset_flag = 'Y') then                                                      
      insert into gcs_entry_lines                                                        
      (      entry_id,                                                                   
             company_cost_center_org_id,                                                 
             intercompany_id,                                                            
             ytd_debit_balance_e,                                                        
             ytd_credit_balance_e,                                                       
             ytd_balance_e,                                                              
             creation_date,                                                              
             created_by,                                                                 
             last_updated_by,                                                            
             last_update_date,                                                           
             last_update_login                                                           
      )                                                                                  
      SELECT p_entry_id,                                                                 
             min(geg.tgt_company_cost_center_org_id),                                    
             min(geg.tgt_intercompany_id),                                               
             sum(decode(sign(geg.output_amount), -1,                                     
                                                 -1 * geg.output_amount, 0)),            
             sum(decode(sign(geg.output_amount), 1,                                      
                                                 geg.output_amount, 0)),                 
             -1 * sum(geg.output_amount),                                                
             sysdate,                                                                    
             fnd_global.user_id,                                                         
             fnd_global.user_id,                                                         
             sysdate,                                                                    
             fnd_global.login_id                                                         
      FROM   gcs_entries_gt geg                                                          
      GROUP BY geg.off_line_item_id                                                      
      ;                                                                                  
    end if; --p_offset_flag = Y                                                          
    else                                                                                 
    insert into gcs_entry_lines                                                          
    (      entry_id,                                                                     
           company_cost_center_org_id,                                                   
           intercompany_id,                                                              
           ytd_debit_balance_e,                                                          
           ytd_credit_balance_e,                                                         
           ytd_balance_e,                                                                
           creation_date,                                                                
           created_by,                                                                   
           last_updated_by,                                                              
           last_update_date,                                                             
           last_update_login                                                             
    )                                                                                    
    SELECT p_entry_id,                                                                   
           geg.src_company_cost_center_org_id,                                           
           min(geg.tgt_intercompany_id),                                                 
           sum(decode(sign(geg.output_amount), 1,                                        
                                               geg.output_amount, 0)),                   
           sum(decode(sign(geg.output_amount), -1,                                       
                                               -1 *geg.output_amount, 0)),               
           sum(geg.output_amount),                                                       
           sysdate,                                                                      
           fnd_global.user_id,                                                           
           fnd_global.user_id,                                                           
           sysdate,                                                                      
           fnd_global.login_id                                                           
    FROM   gcs_entries_gt geg                                                            
    GROUP BY geg.src_company_cost_center_org_id, geg.tgt_line_item_id                    
    ;                                                                                    
                                                                                         
    --check number of rows inserted                                                      
    p_row_count  := SQL%ROWCOUNT;                                                        
                                                                                         
    --insert rows if the offset flag was used                                            
    if (p_offset_flag = 'Y') then                                                      
      insert into gcs_entry_lines                                                        
      (      entry_id,                                                                   
             company_cost_center_org_id,                                                 
             intercompany_id,                                                            
             ytd_debit_balance_e,                                                        
             ytd_credit_balance_e,                                                       
             ytd_balance_e,                                                              
             creation_date,                                                              
             created_by,                                                                 
             last_updated_by,                                                            
             last_update_date,                                                           
             last_update_login                                                           
      )                                                                                  
      SELECT p_entry_id,                                                                 
             geg.src_company_cost_center_org_id,                                         
             min(geg.tgt_intercompany_id),                                               
             sum(decode(sign(geg.output_amount), -1,                                     
                                                 -1 * geg.output_amount, 0)),            
             sum(decode(sign(geg.output_amount), 1,                                      
                                                 geg.output_amount, 0)),                 
             -1 * sum(geg.output_amount),                                                
             sysdate,                                                                    
             fnd_global.user_id,                                                         
             fnd_global.user_id,                                                         
             sysdate,                                                                    
             fnd_global.login_id                                                         
      FROM   gcs_entries_gt geg                                                          
      GROUP BY geg.src_company_cost_center_org_id, geg.off_line_item_id                  
      ;                                                                                  
    end if; --p_offset_flag = Y                                                          
    end if;                                                                              
                                                                                         
    if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then                 
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'gcs_rp_utility_pkg.end', null);         
    end if;                                                                              
                                                                                         
  end create_entry_lines;                                                                
END GCS_RP_UTILITY_PKG;

/
