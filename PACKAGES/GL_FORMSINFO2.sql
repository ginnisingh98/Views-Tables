--------------------------------------------------------
--  DDL for Package GL_FORMSINFO2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_FORMSINFO2" AUTHID CURRENT_USER AS
/* $Header: gligcf2s.pls 120.4 2005/05/05 01:08:02 kvora ship $ */

  --   NAME
  --     get_coa_info
  --   DESCRIPTION
  --     Gets various chart of accounts attributes based on
  --     the coa id provided.
  --   PARAMETERS
  PROCEDURE get_coa_info (x_chart_of_accounts_id    IN     NUMBER,
                          x_segment_delimiter       IN OUT NOCOPY VARCHAR2,
                          x_enabled_segment_count   IN OUT NOCOPY NUMBER,
                          x_segment_order_by        IN OUT NOCOPY VARCHAR2,
                          x_accseg_segment_num      IN OUT NOCOPY NUMBER,
                          x_accseg_app_col_name     IN OUT NOCOPY VARCHAR2,
                          x_accseg_left_prompt      IN OUT NOCOPY VARCHAR2,
                          x_balseg_segment_num      IN OUT NOCOPY NUMBER,
                          x_balseg_app_col_name     IN OUT NOCOPY VARCHAR2,
                          x_balseg_left_prompt      IN OUT NOCOPY VARCHAR2,
                          x_ieaseg_segment_num      IN OUT NOCOPY NUMBER,
                          x_ieaseg_app_col_name     IN OUT NOCOPY VARCHAR2,
                          x_ieaseg_left_prompt      IN OUT NOCOPY VARCHAR2);

  --   NAME
  --     get_sob_info
  --   DESCRIPTION
  --     Gets various set of books attributes based on
  --     the set of books id provided.
  --   PARAMETERS
  PROCEDURE get_sob_info ( X_set_of_books_id		IN     NUMBER,
                   X_chart_of_accounts_id   		IN OUT NOCOPY NUMBER,
		   X_name				IN OUT NOCOPY VARCHAR2,
		   X_short_name				IN OUT NOCOPY VARCHAR2,
                   X_currency_code	 		IN OUT NOCOPY VARCHAR2,
                   X_period_set_name	 		IN OUT NOCOPY VARCHAR2,
                   X_accounted_period_type 		IN OUT NOCOPY VARCHAR2,
                   X_suspense_allowed_flag		IN OUT NOCOPY VARCHAR2,
                   X_allow_intercompany_post_flag	IN OUT NOCOPY VARCHAR2,
                   X_require_budget_journals_flag	IN OUT NOCOPY VARCHAR2,
		   X_enable_bc_flag			IN OUT NOCOPY VARCHAR2,
                   X_latest_opened_period_name 		IN OUT NOCOPY VARCHAR2,
                   X_latest_encumbrance_year 		IN OUT NOCOPY NUMBER,
		   X_future_enterable_periods  		IN OUT NOCOPY NUMBER,
 		   X_cum_trans_ccid			IN OUT NOCOPY NUMBER,
 		   X_ret_earn_ccid			IN OUT NOCOPY NUMBER,
 		   X_res_encumb_ccid 			IN OUT NOCOPY NUMBER,
		   X_enable_average_balances_flag       IN OUT NOCOPY VARCHAR2,
		   X_transaction_calendar_id		IN OUT NOCOPY NUMBER,
 		   X_net_income_ccid			IN OUT NOCOPY NUMBER,
                   X_consolidation_sob_flag             IN OUT NOCOPY VARCHAR2,
                   X_daily_translation_rate_type        IN OUT NOCOPY VARCHAR2,
		   X_enable_automatic_tax_flag		IN OUT NOCOPY VARCHAR2,
		   X_mrc_sob_type_code			IN OUT NOCOPY VARCHAR2,
                   X_enable_je_approval_flag            IN OUT NOCOPY VARCHAR2 );

  --   NAME
  --     multi_org
  --   DESCRIPTION
  --     Returns TRUE if this is a multi-org environment and false otherwise
  --   PARAMETERS
  FUNCTION multi_org RETURN BOOLEAN;

  --   NAME
  --     install_info
  --   DESCRIPTION
  --     Just calls fnd_installation.get to workaround a forms bug
  --   PARAMETERS
  FUNCTION install_info(appl_id  	IN NUMBER,
			dep_appl_id	IN NUMBER,
			status		OUT NOCOPY VARCHAR2,
			industry	OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

  --
  -- Procedure
  --   get_iea_info
  -- Purpose
  --   Used to select all of the information about a subsidiary
  -- History
  --   01-16-97  D. J. Ogg    Created
  --   11-12-98	 S Kung	      Added parameters for data model changes.
  -- Arguments
  --   x_subsidiary_id			ID of subsidiary to get information
  --				        about
  --   x_name				Name of subsidiary
  --   x_chart_of_accounts_id		ID of chart of accounts used by
  --				        subsidiary
  --   x_set_of_books_id		ID of set of books used by subsidiary
  --   x_enabled_flag			Enabled flag of subsidiary
  --   x_subsidiary_type_code		P - parent, S - subsidiary
  --   x_company_value			Company value of subsidiary
  --   x_currency_code			Functional currency of subsidiary
  --   x_autoapprove_flag		Y - subsidiary has autoapproval.
  --					N - subsidiary does not.
  --   x_view_partner_lines_flag	Y - subsidiary can access
  --					    partner lines.
  -- 					N - subsidiary cannot.
  --   x_conversion_type_code		D - Daily Rates.
  -- 					P - Period Rates.
  --   x_conversion_type		Conversion type for transactions
  --   x_remote_instance_flag		Y - Transfer Set of Books is on
  -- 					    a remote instance.
  --					N - Transfer Set of Books is on
  --					    local instance.
  --   x_transfer_set_of_books_id	Transfer Set of Books ID.
  --   x_transfer_currency_code		Transfer currency code.
  --   x_contact			Workflow role to send
  --					notification when threshold is
  --					reached.
  --   x_notification_threshold		Notification Threshold level
  --					in transfer currency.
  -- Example
  --   gl_formsinfo2.get_iea_info(100, :name, :coa_id, :sob_id,
  --			         :enabled_flag, :sub_type_code,
  --				 :company_code, :currency_code,
  --			         :autoapprove_flag);
  -- Notes
  --
  PROCEDURE get_iea_info(x_subsidiary_id		   NUMBER,
			 x_name		    	    IN OUT NOCOPY VARCHAR2,
			 x_chart_of_accounts_id     IN OUT NOCOPY NUMBER,
			 x_set_of_books_id	    IN OUT NOCOPY NUMBER,
 			 x_enabled_flag	    	    IN OUT NOCOPY VARCHAR2,
			 x_subsidiary_type_code     IN OUT NOCOPY VARCHAR2,
                         x_company_value	    IN OUT NOCOPY VARCHAR2,
                         x_currency_code	    IN OUT NOCOPY VARCHAR2,
		         x_autoapprove_flag	    IN OUT NOCOPY VARCHAR2,
			 x_view_partner_lines_flag  IN OUT NOCOPY VARCHAR2,
			 x_conversion_type_code	    IN OUT NOCOPY VARCHAR2,
			 x_conversion_type	    IN OUT NOCOPY VARCHAR2,
			 x_remote_instance_flag	    IN OUT NOCOPY VARCHAR2,
			 x_transfer_set_of_books_id IN OUT NOCOPY NUMBER,
			 x_transfer_currency_code   IN OUT NOCOPY VARCHAR2,
			 x_contact		    IN OUT NOCOPY VARCHAR2,
			 x_notification_threshold   IN OUT NOCOPY NUMBER);
  --
  -- Procedure
  --   get_usage_info
  -- Purpose
  --   Gets the values of some columns from gl_system_usages
  -- History
  --   16-JAN-96  D J Ogg  Created.
  -- Arguments
  --   x_average_balances_flag		Indicates whether average balances
  --					is used in any set of books
  --   x_consolidation_ledger_flag      For indicating if consolidation
  --                                    ledger is available in the sob
  PROCEDURE get_usage_info(
              x_average_balances_flag		IN OUT NOCOPY  VARCHAR2,
              x_consolidation_ledger_flag	IN OUT NOCOPY  VARCHAR2);

  --
  -- Procedure
  --  get_business_days_pattern
  -- Purpose
  --  Uses transaction_calendar_id and start and end dates
  --  to obtain which days are business in the form of a
  --  binary VARCHAR pattern.
  -- History
  --   16-JAN-96  D J Ogg  Created.
  -- Arguments
  --  X_transaction_cal_id
  --  X_start_date
  --  X_end_date
  --  X_bus_days_pattern
  --
  PROCEDURE get_business_days_pattern(X_transaction_cal_id     IN NUMBER,
	 		              X_start_date             IN DATE,
                                      X_end_date               IN DATE,
			              X_bus_days_pattern       IN OUT NOCOPY VARCHAR2);

  --
  -- Procedure
  --  iea_disabled_subsidiary
  -- Purpose
  --  Check if a GIS subsidiary is disabled.
  --  Return true if subsidiary is diabled or does not exist.
  -- History
  --   20-MAY-99  Charmaine Wang    Created.
  -- Arguments
  --   X_Subsidiary_Id
  --
  FUNCTION iea_disabled_subsidiary(X_Subsidiary_Id IN NUMBER) RETURN BOOLEAN;


  --
  -- Procedure
  --  get_industry_message
  -- Purpose
  --  Library cover for gl_public_sector.get_message_name
  --  Given a message name, returns the appropriate message name
  --  for the industry
  -- History
  --   17-DEC-01  D J Ogg  Created
  -- Arguments
  --   Message_Name -- Message Name to check
  --   Application_Shortname -- Application Shortname
  --
  FUNCTION get_industry_message(Message_Name           IN VARCHAR2,
                                Application_Shortname  IN VARCHAR2)
    RETURN VARCHAR2;




END GL_FORMSINFO2;

 

/
