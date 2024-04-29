--------------------------------------------------------
--  DDL for Package IBU_REG_NOTIF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBU_REG_NOTIF_PKG" 
/* $Header: iburgnos.pls 115.2.1158.2 2002/07/25 00:25:32 jamose noship $ */
	 AUTHID CURRENT_USER as

         procedure ibu_send_reg_notification  (email_address_in in varchar2,
									  subject in VARCHAR2,
									  user_id VARCHAR2,
                                               reg_greeting in VARCHAR2,
									  reg_thankyou in VARCHAR2,
									  reg_info in VARCHAR2,
									  reg_acctinfo in VARCHAR2,
									  reg_username in VARCHAR2,
									  reg_password in VARCHAR2,
									  reg_contractnum in VARCHAR2,
									  reg_csinum in VARCHAR2,
									  reg_changepwd in VARCHAR2,
									  reg_print in VARCHAR2,
									  reg_logon in VARCHAR2,
									  reg_thanks in VARCHaR2,
									  reg_closing in VARCHAR2,
									  reg_isupport in VARCHAR2);

end ibu_reg_notif_pkg;

 

/
