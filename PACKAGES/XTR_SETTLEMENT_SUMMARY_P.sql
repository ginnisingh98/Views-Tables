--------------------------------------------------------
--  DDL for Package XTR_SETTLEMENT_SUMMARY_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_SETTLEMENT_SUMMARY_P" AUTHID CURRENT_USER AS
/* $Header: xtrsetls.pls 120.0.12010000.2 2008/08/06 10:44:38 srsampat ship $  */
--
-- Stored procedures/functions for settlements
--


     Procedure INS_SETTLEMENT_SUMMARY(p_settlement_number IN Number,
                                      p_company IN VARCHAR2,
							  p_currency IN VARCHAR2,
                           	          p_settlement_amount IN Number,
 							  p_settlement_date IN Date,
							  p_company_acct_no IN Varchar2,
							  p_cparty_acct_no IN Varchar2,
							  p_net_ID IN Number,
							  p_status IN Varchar2,
                                      p_created_by IN Number,
							  p_creation_date IN Date,
                                      p_external_source IN Varchar2,
                                      p_cparty_code IN Varchar2,                  -- bug 3832387
							  p_settlement_ID OUT  NOCOPY Number );

     Procedure UPD_SETTLEMENT_SUMMARY(p_flag IN Char,
							  p_netoff_number IN number,
                                      p_settlement_ID IN Number);

     Procedure UPD_Settlement_Summary(p_flag IN Char,
                                      p_netoff_number IN Number,
                                      p_settlement_ID IN Number,
                                      p_amount IN Number);

     Procedure UPD_Settlement_Summary(p_settlement_number IN Number,
                                      p_amount IN Number);

     Procedure DEL_SETTLEMENT_SUMMARY(p_settle_date IN Date,
                                      p_currency IN Varchar2,
                                      p_acct_no IN Varchar2,
                                      p_cpacct_no IN Varchar2,
                                      p_company_code IN Varchar2,
                                      p_flag IN Char,
                                      p_return OUT NOCOPY Char);

     Procedure DEL_SETTLEMENT_SUMMARY(p_settlement_number IN Number,
                                      p_settlement_amount IN Number);

     Procedure Include_Settlement_Group(p_settlement_number IN Number,
								p_netoff_number IN Number,
								p_company IN Varchar2,
							    p_currency IN Varchar2,
							    p_settlement_amount IN Number,
							    p_settlement_date IN Date,
							    p_company_acct_no IN Varchar2,
								p_cparty_acct_no IN Varchar2,
								p_created_by IN Number,
								p_creation_date IN Date,
                                        p_cparty_code IN Varchar2); -- bug 3832387

END;


/
