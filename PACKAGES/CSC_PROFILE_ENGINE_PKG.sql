--------------------------------------------------------
--  DDL for Package CSC_PROFILE_ENGINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_PROFILE_ENGINE_PKG" AUTHID CURRENT_USER AS
/* $Header: csccpeps.pls 120.7.12010000.2 2009/07/20 09:43:42 spamujul ship $ */

		  /* Added G_PKG_NAME for JIT enhancement -- Bug 4535407 */
		  G_PKG_NAME VARCHAR2(100) := 'CSC_PROFILE_ENGINE_PKG';

		  --
		  -- to be used if block id is passed
		  --
		  TYPE r_block_rectype IS RECORD
			( p_block_id	NUMBER);

		  TYPE t_BlockTable IS TABLE of r_block_rectype
			INDEX BY BINARY_INTEGER;

		  Block_TBL	t_BlockTable;

		  --
		  -- to be used if check id is passed
		  --
		  TYPE r_check_rectype IS RECORD
			( p_check_id	NUMBER);

		  TYPE t_CheckTable IS TABLE of r_check_rectype
			INDEX BY BINARY_INTEGER;

		  Check_TBL	t_CheckTable;

		  -- p_old_check_id    NUMBER;
		  -- p_old_check_cid   NUMBER;
		  -- p_old_block_id    NUMBER;
		  -- p_old_block_cid   NUMBER;


		  --
		  -- Global Tables
		  --
		  -- tables for updating party results table
		  --
		  TYPE UP_Block_Id_Tab	 Is Table of NUMBER Index By Binary_Integer;
		  TYPE UP_Check_Id_Tab Is Table of NUMBER Index By Binary_Integer;
		  TYPE UP_Party_Id_Tab	Is Table of NUMBER Index By Binary_Integer;
		  TYPE UP_Account_Id_Tab Is Table of NUMBER Index By Binary_Integer;
		  TYPE UP_Psite_Id_Tab	is Table of NUMBER Index By Binary_Integer;		-- Added by spamujul for ER#8473903
		  TYPE UP_Value_Tab Is Table of Varchar2(240) Index By Binary_Integer;
		  TYPE UP_Currency_Tab is Table of Varchar2(15) Index By Binary_Integer;
		  TYPE UP_Grade_Tab is Table of Varchar2(9) Index By Binary_Integer;
		  TYPE UP_Rating_Tab is Table of Varchar2(240) Index By Binary_Integer;
		  TYPE UP_Color_Tab is Table of Varchar2(240) Index By Binary_Integer;
		  TYPE UP_Results_Tab Is Table of Varchar2(3) Index By Binary_Integer;

		  UP_Block_Id		UP_Block_Id_Tab;
		  UP_Check_Id		UP_Check_Id_Tab;
		  UP_Party_Id		UP_Party_Id_Tab;
		  UP_Account_Id		UP_Account_Id_Tab;
		  UP_Psite_id		UP_Psite_Id_Tab;			-- Added by spamujul for ER#8473903
		  UP_Value		UP_Value_Tab;
		  UP_Currency		UP_Currency_Tab;
		  UP_Grade		UP_Grade_Tab;
		  UP_Rating_code        UP_Rating_Tab;
		  UP_Color_code         UP_Color_Tab;
		  UP_Results            UP_Results_Tab;

		  --
		  -- tables for inserting party results table
		  --
		  TYPE IP_Block_Id_Tab Is Table of NUMBER Index By Binary_Integer;
		  TYPE IP_Check_Id_Tab Is Table of NUMBER Index By Binary_Integer;
		  TYPE IP_Party_Id_Tab Is Table of NUMBER Index By Binary_Integer;
		  TYPE IP_Account_Id_Tab Is Table of NUMBER Index By Binary_Integer;
		  TYPE IP_Psite_Id_Tab is Table of NUMBER Index By Binary_Integer;		-- Added by spamujul for ER#8473903
		  TYPE IP_Value_Tab Is Table of Varchar2(240) Index By Binary_Integer;
		  TYPE IP_Currency_Tab is Table of Varchar2(15) Index By Binary_Integer;
		  TYPE IP_Grade_Tab is Table of Varchar2(9) Index By Binary_Integer;
		  TYPE IP_Rating_Tab is Table of Varchar2(240) Index By Binary_Integer;
		  TYPE IP_Color_Tab is Table of Varchar2(240) Index By Binary_Integer;
		  TYPE IP_Results_Tab Is Table of Varchar2(3) Index By Binary_Integer;

		  IP_Block_Id		IP_Block_Id_Tab;
		  IP_Check_Id		IP_Check_Id_Tab;
		  IP_Party_Id		IP_Party_Id_Tab;
		  IP_Account_Id		IP_Account_Id_Tab;
		  IP_Psite_id		IP_Psite_Id_Tab;				-- Added by spamujul for ER#8473903
		  IP_Value		IP_Value_Tab;
		  IP_Currency		IP_Currency_Tab;
		  IP_Grade		IP_Grade_Tab;
		  IP_Rating_code        IP_Rating_Tab;
		  IP_Color_code         IP_Color_Tab;
		  IP_Results            IP_Results_Tab;

		  --
		  -- tables for updating party account results table
		  --
		  TYPE UA_Block_Id_Tab Is Table of NUMBER Index By Binary_Integer;
		  TYPE UA_Check_Id_Tab Is Table of NUMBER Index By Binary_Integer;
		  TYPE UA_Party_Id_Tab Is Table of NUMBER Index By Binary_Integer;
		  TYPE UA_Account_Id_Tab Is Table of NUMBER Index By Binary_Integer;
		  TYPE UA_Psite_Id_Tab Is Table of NUMBER Index By Binary_Integer;		-- Added by spamujul for ER#8473903
		  TYPE UA_Value_Tab Is Table of Varchar2(240) Index By Binary_Integer;
		  TYPE UA_Currency_Tab is Table of Varchar2(15) Index By Binary_Integer;
		  TYPE UA_Grade_Tab is Table of Varchar2(9) Index By Binary_Integer;
		  TYPE UA_Rating_Tab is Table of Varchar2(240) Index By Binary_Integer;
		  TYPE UA_Color_Tab is Table of Varchar2(240) Index By Binary_Integer;
		  TYPE UA_Results_Tab Is Table of Varchar2(3) Index By Binary_Integer;

		  UA_Block_Id		UA_Block_Id_Tab;
		  UA_Check_Id		UA_Check_Id_Tab;
		  UA_Party_Id		UA_Party_Id_Tab;
		  UA_Account_Id		UA_Account_Id_Tab;
		  UA_Psite_Id		UA_Psite_Id_Tab;				-- Added by spamujul for ER#8473903
		  UA_Value		UA_Value_Tab;
		  UA_Currency		UA_Currency_Tab;
		  UA_Grade		UA_Grade_Tab;
		  UA_Rating_code        UA_Rating_Tab;
		  UA_Color_code         UA_Color_Tab;
		  UA_Results            UA_Results_Tab;

		  --
		  -- tables for inserting party account results table
		  --
		  TYPE IA_Block_Id_Tab Is Table of NUMBER Index By Binary_Integer;
		  TYPE IA_Check_Id_Tab Is Table of NUMBER Index By Binary_Integer;
		  TYPE IA_Party_Id_Tab Is Table of NUMBER Index By Binary_Integer;
		  TYPE IA_Account_Id_Tab Is Table of NUMBER Index By Binary_Integer;
		    TYPE IA_Psite_Id_Tab Is Table of NUMBER Index By Binary_Integer;			-- Added by spamujul for ER#8473903
		  TYPE IA_Value_Tab Is Table of Varchar2(240) Index By Binary_Integer;
		  TYPE IA_Currency_Tab is Table of Varchar2(15) Index By Binary_Integer;
		  TYPE IA_Grade_Tab is Table of Varchar2(9) Index By Binary_Integer;
		  TYPE IA_Rating_Tab Is Table of Varchar2(240) Index By Binary_Integer;
		  TYPE IA_Color_Tab Is Table of Varchar2(240) Index By Binary_Integer;
		  TYPE IA_Results_Tab Is Table of Varchar2(3) Index By Binary_Integer;

		  IA_Block_Id		IA_Block_Id_Tab;
		  IA_Check_Id		IA_Check_Id_Tab;
		  IA_Party_Id		IA_Party_Id_Tab;
		  IA_Account_Id		IA_Account_Id_Tab;
		  IA_Psite_Id		IA_Psite_Id_Tab;			-- Added by spamujul for ER#8473903
		  IA_Value		IA_Value_Tab;
		  IA_Currency		IA_Currency_Tab;
		  IA_Grade		IA_Grade_Tab;
		  IA_Rating_Code        IA_Rating_Tab;
		  IA_Color_Code         IA_Color_Tab;
		  IA_Results            IA_Results_Tab;

		-- Begin Fix by spamujul  for ER#8473903
		  TYPE US_Block_Id_Tab Is Table of NUMBER Index By Binary_Integer;
		  TYPE US_Check_Id_Tab Is Table of NUMBER Index By Binary_Integer;
		  TYPE US_Party_Id_Tab Is Table of NUMBER Index By Binary_Integer;
		  TYPE US_Account_Id_Tab Is Table of NUMBER Index By Binary_Integer;
		  TYPE US_Psite_Id_Tab Is Table of NUMBER Index By Binary_Integer;
		  TYPE US_Value_Tab Is Table of Varchar2(240) Index By Binary_Integer;
		  TYPE US_Currency_Tab is Table of Varchar2(15) Index By Binary_Integer;
		  TYPE US_Grade_Tab is Table of Varchar2(9) Index By Binary_Integer;
		  TYPE US_Rating_Tab is Table of Varchar2(240) Index By Binary_Integer;
		  TYPE US_Color_Tab is Table of Varchar2(240) Index By Binary_Integer;
		  TYPE US_Results_Tab Is Table of Varchar2(3) Index By Binary_Integer;

		  US_Block_Id		US_Block_Id_Tab;
		  US_Check_Id		US_Check_Id_Tab;
		  US_Party_Id		US_Party_Id_Tab;
		  US_Account_Id		US_Account_Id_Tab;
		  US_Psite_Id		US_Psite_Id_Tab;
		  US_Value		US_Value_Tab;
		  US_Currency		US_Currency_Tab;
		  US_Grade		US_Grade_Tab;
		  US_Rating_code        US_Rating_Tab;
		  US_Color_code         US_Color_Tab;
		  US_Results            US_Results_Tab;

		  TYPE IS_Block_Id_Tab Is Table of NUMBER Index By Binary_Integer;
		  TYPE IS_Check_Id_Tab Is Table of NUMBER Index By Binary_Integer;
		  TYPE IS_Party_Id_Tab Is Table of NUMBER Index By Binary_Integer;
		  TYPE IS_Account_Id_Tab Is Table of NUMBER Index By Binary_Integer;
		  TYPE IS_Psite_Id_Tab Is Table of NUMBER Index By Binary_Integer;
		  TYPE IS_Value_Tab Is Table of Varchar2(240) Index By Binary_Integer;
		  TYPE IS_Currency_Tab is Table of Varchar2(15) Index By Binary_Integer;
		  TYPE IS_Grade_Tab is Table of Varchar2(9) Index By Binary_Integer;
		  TYPE IS_Rating_Tab Is Table of Varchar2(240) Index By Binary_Integer;
		  TYPE IS_Color_Tab Is Table of Varchar2(240) Index By Binary_Integer;
		  TYPE IS_Results_Tab Is Table of Varchar2(3) Index By Binary_Integer;

		  IS_Block_Id		IS_Block_Id_Tab;
		  IS_Check_Id		IS_Check_Id_Tab;
		  IS_Party_Id		IS_Party_Id_Tab;
		  IS_Account_Id	IS_Account_Id_Tab;
		  IS_Psite_Id		IS_Psite_Id_Tab;
		  IS_Value		IS_Value_Tab;
		  IS_Currency		IS_Currency_Tab;
		  IS_Grade		IS_Grade_Tab;
		  IS_Rating_Code        IS_Rating_Tab;
		  IS_Color_Code         IS_Color_Tab;
		  IS_Results            IS_Results_Tab;
		-- End Fix by spamujul  for ER#8473903
		--
		-- Tables for Relationship Plan Engine
		--

		  plan_id_plan_table	csc_plan_assignment_pkg.csc_plan_id_tbl_type;
		  party_id_plan_table	csc_plan_assignment_pkg.csc_party_id_tbl_type;
		  account_id_plan_table	csc_plan_assignment_pkg.csc_cust_id_tbl_type;
		  --org_id_plan_table	csc_plan_assignment_pkg.csc_cust_org_tbl_type;
		  check_id_plan_table	csc_plan_assignment_pkg.csc_check_id_tbl_type;

		-- For Relationship party profile checks
		  g_dashboard_for_contact VARCHAR2(1) := NULL;

		-- R12 Employee HelpDesk Modifications
		-- Flag For Employee level profile checks
		 g_dashboard_for_employee VARCHAR2(1) := NULL;

		  -- for profiles with no batch sql
		  g_check_no_batch VARCHAR2(1) := NULL;

		  Type checks_cur_var IS REF CURSOR;

		  TYPE r_blk_rectype IS RECORD
			( block_id	NUMBER,
			  sql_stmnt   VARCHAR2(4000),
			  currency    VARCHAR2(30));

		   TYPE blocks_curtype IS
		       REF CURSOR RETURN r_blk_rectype;


		    TYPE r_chk_rectype IS RECORD
			( check_id	NUMBER,
		     select_type   VARCHAR2(3),
		     select_block_id NUMBER,
		     data_type VARCHAR2(30),
		     format_mask VARCHAR2(30),
		     check_upper_lower_flag VARCHAR2(3),
		     threshold_grade VARCHAR2(9),
		     check_level VARCHAR2(10)
		     );


		   TYPE checks_curtype IS
		       REF CURSOR RETURN r_chk_rectype;

		--
		-- Insert or Update Records into Csc_Prof_Block_Results Table
		-- IN
		--    p_count	   - the number of records to be inserted or updated
		--    p_for_insert - flag to check if for insert or update.
		--    p_for_party  - flag to check if the insert or update is for party or account
		--
		PROCEDURE Insert_Update_Block_Results( p_count	IN Number,
												    p_for_insert	IN Varchar2,
												    p_for_party	IN Varchar2
												    ,p_for_psite	IN Varchar2-- added by spamujul for ER#8473903
												  );


		--
		-- Insert or Update Records into Csc_Prof_Check_Results Table
		-- IN
		--    p_count	   - the number of records to be inserted or updated
		--    p_for_insert - flag to check if for insert or update.
		--    p_for_party  - flag to check if the insert or update is for party or account
		--

		PROCEDURE Insert_Update_Check_Results( p_count		IN Number,
												      p_for_insert	IN Varchar2,
												      p_for_party	IN Varchar2
												      ,p_for_psite	IN Varchar2 -- Added by spamujul for ER#8473903
												  );

		/*******************************************
		  UPDATE_JIT_STATUS
		  Added this procedure for JIT enhancement -- Bug 4535407
		  Updates the columns jit_status, jit_err_code in CCT_MEDIA_ITEMS.
		  Called from CSC_PROF_JIT
		********************************************/
		PROCEDURE update_jit_status ( p_status        VARCHAR2 DEFAULT NULL,
									     p_err_code      NUMBER DEFAULT NULL,
									     p_media_item_id NUMBER
									   );

		/*******************************************
		  CSC_PROF_JIT
		  Added this procedure for JIT enhancement -- Bug 4535407
		  Called from OTM java code
		  Calls profile engine for the party_id passed from OTM.
		  OTM passes the key-value pair in a VARRAY (cct_keyvalue_varr)
		********************************************/

		PROCEDURE csc_prof_jit ( p_key_value_varr	 IN  cct_keyvalue_varr,
								     p_init_msg_list	IN  VARCHAR2 := FND_API.G_FALSE,
								     p_critical_flag		IN  VARCHAR2 DEFAULT NULL,
								     x_return_status	OUT NOCOPY VARCHAR2,
								     x_msg_count		OUT NOCOPY NUMBER,
								     x_msg_data		OUT NOCOPY VARCHAR2
								     );


		/*******************************************
		  GET_PROFILE_VALUE_RESP
		  Added this procedure for JIT enhancement -- Bug 4535407
		  Returns Profile Option value at the responsibility level.
		  This function has been added as API fnd_profile.value_specific is
		  not defined at form level FND_PROFILE package (pld)
		********************************************/
		FUNCTION get_profile_value_resp  ( p_profile_name	VARCHAR2,
										     p_resp_id			NUMBER,
										     p_resp_appl_id	NUMBER,
										     p_user_id			NUMBER
										   )  RETURN VARCHAR2 ;

		  --
		  -- Build_Rule
		  --   Construct the rule as a SQL statement for an indicator check
		  -- IN
		  --   check_id - profile check identifier
		  -- OUT
		  --   rule - sql statement that returns 0 or 1 row (0 for false, 1 for true)
		  --
		  PROCEDURE Build_Rule ( acct_flag		 IN	VARCHAR2,
								     chk_id		IN	NUMBER,
								     chk_level		IN	VARCHAR2,
								     rule			OUT NOCOPY VARCHAR2
								     );

		  --
		  -- Set_Context
		  --   Set procedure context (for stack trace).
		  -- IN
		  --   proc_name - procedure/function name
		  --   arg1 - first IN argument
		  --   argn - n'th IN argument
		  --
		  PROCEDURE Set_Context  ( proc_name	IN VARCHAR2,
								      arg1 	IN VARCHAR2 DEFAULT '*none*',
								      arg2	IN VARCHAR2 DEFAULT '*none*',
								      arg3	IN VARCHAR2 DEFAULT '*none*',
								      arg4	IN VARCHAR2 DEFAULT '*none*',
								      arg5	IN VARCHAR2 DEFAULT '*none*'
								      );

		  --
		  -- to run engine as a concurrent program
		  --
		  PROCEDURE Run_Engine (p_errbuf				OUT NOCOPY VARCHAR2,
									p_retcode			OUT NOCOPY NUMBER,
									p_party_id			IN NUMBER,
									p_acct_id			IN NUMBER,
									p_psite_id			IN   NUMBER DEFAULT NULL, -- Added by spamujul for ER#8473903
									p_group_id			IN NUMBER );
		  --
		  -- Bug 1942032 to run engine as a concurrent program - overloaded procedure when
		  -- Account Id is removed from conc. program parameters.
		  --
		  PROCEDURE Run_Engine (p_errbuf		OUT NOCOPY VARCHAR2,
									p_retcode	OUT NOCOPY NUMBER,
									p_party_id	IN NUMBER,
									p_group_id	IN NUMBER
									);

		  /* added the overloaded procedure for JIT enhancement -- Bug 4535407 */
		  PROCEDURE Run_Engine_jit (p_party_id			IN NUMBER,
										p_acct_id		IN NUMBER,
										p_psite_id		IN   NUMBER DEFAULT NULL, -- Added by spamujul for ER#8473903
										p_group_id		IN NUMBER,
										p_critical_flag	IN VARCHAR2,
										p_party_type		IN VARCHAR2 DEFAULT 'CUSTOMER'
					);


		/* R12 Employee HelpDesk Modifications -overloaded procedure */
		 PROCEDURE Run_Engine_All (p_errbuf		OUT NOCOPY VARCHAR2,
								p_retcode	OUT NOCOPY NUMBER,
							       p_party_type	IN VARCHAR2,
							       p_party_id	IN  NUMBER,
							       p_group_id	IN  NUMBER
							       );


		  --
		  -- Modified for batch sql changes
		  -- Evaluate_Checks1_Var
		  --   Loop through all checks and evaluate the results
		  --   for each customer and account for Variable type
		  --   if check_id is null, party_id is null, account_id is null
		  --	      and block_id is null
		  --
		  PROCEDURE Evaluate_Checks1_Var;

		  --
		  -- Evaluate_Checks1_Rule
		 --   Added for batch sql changes
		  --   Loop through all checks and evaluate the results
		  --   for each customer and account for Rule type
		  --   if check_id is null, party_id is null, account_id is null
		  --	      and block_id is null

		PROCEDURE Evaluate_Checks1_Rule( errbuf		OUT	NOCOPY VARCHAR2,
											retcode		OUT	NOCOPY NUMBER );

		  -- Evaluate_Checks1_No_Batch
		  --   This procedure evaluates the checks
		  --   for which the batch sql statement is NULL
		  --
		  PROCEDURE Evaluate_Checks1_No_Batch
		      ( errbuf  OUT  NOCOPY VARCHAR2,
			retcode OUT  NOCOPY NUMBER ) ;
		  --
		  --
		  -- Evaluate_Checks2
		  --   Loop through all checks and evaluate the results
		  --   for each customer and account.
		  --   if check_id is null, party_id is not null or account_id is not null
		  --	      and block_id is null
		  --
		  PROCEDURE Evaluate_Checks2( p_party_id		IN		NUMBER,
										      p_acct_id	  		IN		NUMBER,
										      p_psite_id		IN		NUMBER DEFAULT NULL, -- Added by spamujul for ER#8473903
										      p_group_id		IN		NUMBER,
										      p_critical_flag		IN		 VARCHAR2 DEFAULT 'N', /* added for JIT enhancement */
										      errbuf	  		OUT	 NOCOPY VARCHAR2,
										      retcode	  		OUT	 NOCOPY NUMBER
										    );

		   --
		   -- Evaluate_Checks3
		   --   Loop through all checks and evaluate the results
		   --   for each customer and account.
		   --   if check_id is null, party_id is not null or account_id is not null
		   --       and block_id is null
		   --
		  PROCEDURE Evaluate_Checks3( p_party_id		IN   NUMBER,
										  p_acct_id		IN   NUMBER,
										  p_psite_id		IN   NUMBER DEFAULT NULL, -- Added by spamujul for ER#8473903
										  p_group_id		IN   NUMBER,
										  errbuf			OUT NOCOPY VARCHAR2,
										  retcode			OUT NOCOPY NUMBER
										  );

		 --
		  -- Evaluate_Checks4_Var
		  --   Modified for batch sql changes
		  --   Loop through Checks in this group and evaluate the results
		  --   for all Parties and Accounts.
		  --   if Party_id is null, Account_id is null and Group_id is not null
		  --
		  PROCEDURE Evaluate_Checks4_Var(p_group_id IN  NUMBER);

		  --
		  -- Evaluate_Checks4_No_Batch
		  -- This procedure evaluates the checks
		  -- for which the batch sql statement is NULL
		  --
		  PROCEDURE Evaluate_Checks4_No_Batch (errbuf	OUT	NOCOPY VARCHAR2,
												     retcode	OUT	NOCOPY NUMBER ,
												     p_group_id IN  NUMBER
												     );
		  --
		  -- Evaluate_Checks4_Rule -- Added for 1850508
		  --   Loop through Checks in this group and evaluate the results
		  --   for all Parties and Accounts.
		  --   if Party_id is null, Account_id is null and Group_id is not null
		  --
		  PROCEDURE Evaluate_Checks4_Rule ( errbuf		OUT	NOCOPY VARCHAR2,
											     retcode		OUT	NOCOPY NUMBER ,
											     p_group_id	IN 	NUMBER
											     );


		  --
		  -- Evaluate_One_Check
		  --   Evaluate the given profile check and store the result in the
		  --   CS_PROF_CHECK_RESULTS table. Also store the grade if ranges are
		  --   specified.
		  -- IN
		  --   chk_id      - profile check identifier
		  --   cust_id     - customer identifier for which check is evaluated
		  --   acct_id     - customer's account identifier
		  --   sel_type    - 'B' for block; 'T' for true or false ("indicator" check)
		  --   sel_blk_id  - building block identifier (required if select type is
		  --                 block)
		  --   data_type   - data type of check result (used for applying format mask)
		  --   fmt_mask    - format mask for check result (ignored if data type is
		  --                 char or currency code is present)
		  --   rule - sql statement that returns 0 or 1 row for an indicator check
		  --   P_CID 	- Cursor passed from calling routine to avoid re-parsing the same sql statement (1850508)
		  PROCEDURE Evaluate_One_Check( p_truncate_flag	IN		VARCHAR2,
										    p_chk_id			IN		NUMBER,
										    p_party_id			IN		NUMBER,
										    p_acct_id			IN		NUMBER	DEFAULT NULL,
										    p_psite_id			IN		NUMBER	DEFAULT NULL, -- Added by spamujul for ER#8473903
										    p_check_level		IN		VARCHAR2	DEFAULT NULL,
										    p_sel_type		IN		VARCHAR2,
										    p_sel_blk_id		IN		NUMBER	DEFAULT NULL,
										    p_data_type	        IN		VARCHAR2	DEFAULT NULL,
										    p_fmt_mask		IN		VARCHAR2	DEFAULT NULL,
										    p_chk_u_l_flag	IN		VARCHAR2	DEFAULT NULL,
										    p_thd_grade		IN		VARCHAR2	DEFAULT NULL,
										    p_rule				IN		VARCHAR2	DEFAULT NULL,
										    p_blk_id			IN		NUMBER	DEFAULT NULL,
										    p_sql_stmt		IN		VARCHAR2	DEFAULT NULL,
										    p_curr_code		IN		VARCHAR2	DEFAULT NULL,
										    p_up_total      		IN		OUT NOCOPY NUMBER ,
										    p_ip_total      		IN		OUT NOCOPY NUMBER ,
										    p_ua_total      		IN		OUT NOCOPY NUMBER ,
										    p_ia_total      		IN		OUT NOCOPY NUMBER ,
										    p_us_total			IN		OUT NOCOPY NUMBER, -- Added by spamujul for ER#8473903
										    p_is_total			IN		OUT NOCOPY NUMBER, -- Added by spamujul for ER#8473903
										    p_cid				IN		NUMBER
										    );

		  --
		  -- Evaluate_Blocks1
		  --   Loop through all the effective building blocks and evaluate the results
		  --   for each customer.
		  --   if block_id is null, party_id is null and account_id is null
		  --
		  PROCEDURE Evaluate_Blocks1 (p_up_total     IN	OUT NOCOPY NUMBER ,
									    p_ip_total		 IN	OUT NOCOPY NUMBER ,
									    p_ua_total		 IN	OUT NOCOPY NUMBER ,
									    p_ia_total		 IN	OUT NOCOPY NUMBER
									   ,p_us_total		 IN	OUT NOCOPY NUMBER, -- Added by spamujul for ER#8473903
									    p_is_total		 IN	OUT NOCOPY NUMBER -- Added by spamujul for ER#8473903
									  );


		   --
		  -- Evaluate_Blocks1_No_Batch
		  -- This procedure evaluates the blocks
		  -- for which the batch sql statement is NULL
		  PROCEDURE Evaluate_Blocks1_No_Batch ( p_up_total	IN OUT NOCOPY NUMBER ,
												    p_ip_total		IN OUT NOCOPY NUMBER ,
												    p_ua_total		IN OUT NOCOPY NUMBER ,
												    p_ia_total		IN OUT NOCOPY NUMBER
												    ,p_us_total	 IN OUT NOCOPY NUMBER, -- Added by spamujul for ER#8473903
												    p_is_total		IN OUT NOCOPY NUMBER -- Added by spamujul for ER#8473903
		    );

		  --
		  -- Evaluate_Blocks2
		  --   Loop through all the effective building blocks and evaluate the results
		  --   for each customer.
		  --   if block_id is not null, party_id is not null or account_id is not null
		  --
		  PROCEDURE Evaluate_Blocks2( p_block_id	IN     NUMBER,
									      p_party_id	IN     NUMBER,
									      p_acct_id	 	IN     NUMBER,
									      p_psite_id	IN	NUMBER DEFAULT NULL, -- Added by spamujul for ER#8473903
									      p_up_total      	IN OUT NOCOPY NUMBER ,
									      p_ip_total      	IN OUT NOCOPY NUMBER ,
									      p_ua_total      	IN OUT NOCOPY NUMBER ,
									      p_ia_total      	IN OUT NOCOPY NUMBER
									      ,p_us_total	IN OUT NOCOPY NUMBER, -- Added by spamujul for ER#8473903
									      p_is_total	IN OUT NOCOPY NUMBER -- Added by spamujul for ER#8473903
										);


		  --
		  -- Evaluate_Blocks4 -- Added for 1850508
		  --   Calculate for All Parties, Accounts * For all checks present in the group
		  --   When Group Id is given but not party_id or Account_id
		  PROCEDURE Evaluate_Blocks4( p_up_total      	IN OUT NOCOPY NUMBER ,
									      p_ip_total      		IN OUT NOCOPY NUMBER ,
									      p_ua_total      		IN OUT NOCOPY NUMBER ,
									      p_ia_total      		IN OUT NOCOPY NUMBER ,
									      p_us_total		IN OUT NOCOPY NUMBER, -- Added by spamujul for ER#8473903
									      p_is_total		IN OUT NOCOPY NUMBER, -- Added by spamujul for ER#8473903
									      p_group_id		IN     NUMBER
									      );
		   --
		  -- Evaluate_Blocks4_No_Batch
		  -- This procedure evaluates the blocks
		  -- for which the batch sql statement is NULL
		  PROCEDURE Evaluate_Blocks4_No_Batch ( p_up_total      	IN OUT NOCOPY NUMBER ,
												      p_ip_total      	IN OUT NOCOPY NUMBER ,
												      p_ua_total      	IN OUT NOCOPY NUMBER ,
												      p_ia_total      	IN OUT NOCOPY NUMBER ,
												      p_us_total	IN OUT NOCOPY NUMBER, -- Added by spamujul for ER#8473903
												      p_is_total	IN OUT NOCOPY NUMBER, -- Added by spamujul for ER#8473903
												      p_group_id	IN     NUMBER
												      );

		  --
		  -- Evaluate_One_Block
		  --   Execute dynamic SQL to evaluate the given building block and store the
		  --   result in the CS_PROF_BLOCK_RESULTS table.
		  -- IN
		  --   blk_id 	    - profile check building block identifier
		  --   party_id     - customer identifier for which building block is evaluated
		  --   acct_id 	    - account id
		  --   sql_stmt     - sql statement to execute dynamically
		  --   P_CID 	    - Cursor passed from calling routine to avoid re-parsing the same sql statement (1850508)
		  PROCEDURE Evaluate_One_Block( p_truncate_flag		IN     VARCHAR2,
										      p_blk_id				IN     NUMBER,
										      p_party_id			IN     NUMBER,
										      p_acct_id				IN     NUMBER,
										      p_psite_id			IN     NUMBER DEFAULT NULL,				-- Added by spamujul for ER#8473903
										      p_sql_stmt			IN     VARCHAR2,
										      p_curr_code			IN     VARCHAR2,
										      p_up_total			IN OUT NOCOPY NUMBER ,
										      p_ip_total			IN OUT NOCOPY NUMBER ,
										      p_ua_total			IN OUT NOCOPY NUMBER ,
										      p_ia_total			IN OUT NOCOPY NUMBER ,
										      p_us_total			IN OUT NOCOPY NUMBER,	-- Added by spamujul for ER#8473903
										      p_is_total			IN OUT NOCOPY NUMBER,	-- Added by spamujul for ER#8473903
										      p_cid				IN     NUMBER
										      );

		  PROCEDURE Evaluate_Blocks5  ( p_block_id			 IN  NUMBER,
										    p_party_id			 IN  NUMBER,
										    p_psite_id			 IN	NUMBER DEFAULT NULL, -- Added by spamujul for ER#8473903
										    p_up_total			 IN	OUT NOCOPY NUMBER ,
										    p_ip_total			 IN	OUT NOCOPY NUMBER ,
										    p_ua_total			 IN	OUT NOCOPY NUMBER ,
										    p_ia_total			 IN   OUT NOCOPY NUMBER
										    ,p_us_total		 IN   OUT NOCOPY NUMBER, -- Added by spamujul for ER#8473903
										    p_is_total			 IN   OUT NOCOPY NUMBER -- Added by spamujul for ER#8473903
										    );

		    PROCEDURE Evaluate_Blocks_Rel ( p_up_total		IN OUT NOCOPY NUMBER ,
											    p_ip_total		IN OUT NOCOPY NUMBER ,
											    p_ua_total		IN OUT NOCOPY NUMBER ,
											    p_ia_total		IN OUT NOCOPY NUMBER,
											    p_us_total		IN OUT NOCOPY NUMBER, -- Added by spamujul for ER#8473903
											    p_is_total		IN OUT NOCOPY NUMBER, -- Added by spamujul for ER#8473903
											    p_group_id       IN NUMBER DEFAULT NULL,
											    p_no_batch_sql  IN VARCHAR2 DEFAULT NULL,
											    p_rule_only	IN VARCHAR2 DEFAULT NULL
											   );

		  PROCEDURE Evaluate_Checks_Rel( errbuf			OUT	NOCOPY VARCHAR2,
										      retcode			OUT	NOCOPY NUMBER ,
										      p_group_id		IN NUMBER DEFAULT NULL,
										      p_no_batch_sql	IN VARCHAR2 DEFAULT NULL,
										      p_rule_only		IN VARCHAR2 DEFAULT NULL
										      );


		  PROCEDURE Evaluate_Blocks_Emp( p_up_total		IN OUT NOCOPY NUMBER ,
											    p_ip_total		IN OUT NOCOPY NUMBER ,
											    p_ua_total		IN OUT NOCOPY NUMBER ,
											    p_ia_total		IN OUT NOCOPY NUMBER,
											    p_us_total		IN OUT NOCOPY NUMBER, -- Added by spamujul for ER#8473903
											    p_is_total		IN OUT NOCOPY NUMBER, -- Added by spamujul for ER#8473903
											    p_group_id	IN NUMBER DEFAULT NULL,
											    p_no_batch_sql  IN VARCHAR2 DEFAULT NULL,
											    p_rule_only	IN VARCHAR2 DEFAULT NULL
											    );

		  PROCEDURE Evaluate_Checks_Emp( errbuf				OUT	NOCOPY VARCHAR2,
											      retcode			OUT	NOCOPY NUMBER ,
											      p_group_id		IN		NUMBER DEFAULT NULL,
											      p_no_batch_sql	IN		VARCHAR2 DEFAULT NULL,
											      p_rule_only		IN		VARCHAR2 DEFAULT NULL);


		/* added the below 3 functions and handle_exception for batch sql changes */
		FUNCTION  Calc_Threshold(  p_val			 VARCHAR2,
									   p_low_val		VARCHAR2,
									   p_high_val		VARCHAR2,
									   p_data_type	VARCHAR2,
									   p_chk_u_l_flag VARCHAR2
									) RETURN VARCHAR2;

		FUNCTION Format_Mask (   p_curr_code   VARCHAR2,
								    p_data_type   VARCHAR2,
								    p_val         VARCHAR2,
								    p_fmt_mask VARCHAR2
								) RETURN VARCHAR2 ;

		   TYPE r_rating IS RECORD
		    ( rating_code VARCHAR2(240), grade VARCHAR2(240),
		     color_code VARCHAR2(240), low_value VARCHAR2(240), high_value VARCHAR2(240));

		   TYPE t_rating IS TABLE of r_rating
		     INDEX BY BINARY_INTEGER;

		   Rating_TBL	t_rating;

		   g_check_id NUMBER;
		   g_party_id NUMBER;
		   g_account_id NUMBER;
		   g_psite_id NUMBER; -- Added by spamujul for ER#8473903
		   g_value VARCHAR2(240);
		   g_color_code VARCHAR2(240);
		   g_rating VARCHAR2(240);
		   g_grade VARCHAR2(240);

		FUNCTION rating_color( p_chk_id			NUMBER,
								   p_party_id		NUMBER,
								   p_account_id	NUMBER,
								   p_psite_id		NUMBER  DEFAULT NULL, -- Added by spamujul for ER#8473903
								   p_val			VARCHAR2,
								   p_data_type	VARCHAR2,
								   p_column		VARCHAR2,
								   p_count		NUMBER
								)  RETURN VARCHAR2;

		PROCEDURE Handle_Exception;

END CSC_Profile_Engine_PKG;

/
