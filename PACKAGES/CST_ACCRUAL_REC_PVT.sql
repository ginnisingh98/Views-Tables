--------------------------------------------------------
--  DDL for Package CST_ACCRUAL_REC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_ACCRUAL_REC_PVT" AUTHID CURRENT_USER AS
/* $Header: CSTACRHS.pls 120.1.12010000.1 2008/07/24 17:19:17 appldev ship $ */

 -- Start of comments
 --	API name 	: Get_Accounts
 --	Type		: Private
 --	Pre-reqs	: None.
 --	Function	: Get all the "default accounts" for a given operating unit.
 --                       Only distint accrual account IDs are return.
 --	Parameters	:
 --	IN		: p_ou_id	IN NUMBER		Required
 --				Operating Unit Identifier.
 --     OUT             : x_count       OUT NOCOPY NUBMER	Required
 --  			        Succes Indicator
 --				1  => Success
 --				-1 => Failure
 --                     : x_err_num	OUT NOCOPY NUMBER	Required
 --                             Standard Error Parameter
 --                     : x_err_code	OUT NOCOPY VARCHAR2	Required
 --                             Standard Error Parameter
 --                     : x_err_msg	OUT NOCOPY VARCHAR2	Required
 --                             Standard Error Parameter
 --	Version	: Current version	1.0
 --		  Previous version 	1.0
 --		  Initial version 	1.0
 -- End of comments
 procedure get_accounts( p_ou_id in number,
 			 x_count out nocopy number,
			 x_err_num out nocopy number,
			 x_err_code out nocopy varchar2,
			 x_err_msg out nocopy varchar2);

 -- Start of comments
 --	API name 	: Flip_Flag
 --	Type		: Private
 --	Pre-reqs	: None.
 --	Function	: Sets the write_off_select_flag column in the appropriate
 --                       database tables to 'Y' or NULL.
 --	Parameters	:
 --	IN		: p_row_id	IN VARCHAR2		Required
 --				Row Identifier
 -- 			: p_bit		IN VARCHAR2		Required
 --				Determines whether to set the column to 'Y' or NULL
 --				FND_API.G_TRUE => 'Y'
 --				FND_API.G_FALSE => NULL
 --			: p_prog	IN NUMBER		Required
 --				Codes which tables's write_off_select_flag column will be altered
 --				0 => cst_reconciliation_summary (AP and PO Form)
 --		                1 => cst_misc_reconciliation (Miscellaneous Form)
 --                             2 => cst_write_offs (View Write-Offs Form)
 --     OUT             : x_count       OUT NOCOPY NUBMER	Required
 --  			        Succes Indicator
 --				FND_API.G_TRUE  => Success
 --				FND_API.G_FALSE => Failure
 --                     : x_err_num	OUT NOCOPY NUMBER	Required
 --                             Standard Error Parameter
 --                     : x_err_code	OUT NOCOPY VARCHAR2	Required
 --                             Standard Error Parameter
 --                     : x_err_msg	OUT NOCOPY VARCHAR2	Required
 --                             Standard Error Parameter
 --	Version	: Current version	1.0
 --		  Previous version 	1.0
 --		  Initial version 	1.0
 -- End of comments
 procedure flip_flag ( p_row_id in varchar2,
		       p_bit in varchar2,
		       p_prog in number,
 		       x_count out nocopy varchar2,
		       x_err_num out nocopy number,
	               x_err_code out nocopy varchar2,
		       x_err_msg out nocopy varchar2);

 -- Start of comments
 --	API name 	: Calc_Age_In_Days
 --	Type		: Private
 --	Pre-reqs	: None.
 --	Function	: Calculates age in days using the profile option CST_ACCRUAL_AGE_IN_DAYS
 --	Parameters	:
 --	IN		: p_lrd		IN DATE			Required
 --				Last Receipt Date
 -- 			: p_lid		IN DATE			Required
 --				Last Invoice Date
 --     OUT             : x_count       OUT NOCOPY NUBMER	Required
 --  			        Age In Days Value
 --                     : x_err_num	OUT NOCOPY NUMBER	Required
 --                             Standard Error Parameter
 --                     : x_err_code	OUT NOCOPY VARCHAR2	Required
 --                             Standard Error Parameter
 --                     : x_err_msg	OUT NOCOPY VARCHAR2	Required
 --                             Standard Error Parameter
 --	Version	: Current version	1.0
 --		  Previous version 	1.0
 --		  Initial version 	1.0
 -- End of comments
 procedure calc_age_in_days ( p_lrd in date,
			      p_lid in date,
		  	      x_count out nocopy number,
		              x_err_num out nocopy number,
	                      x_err_code out nocopy varchar2,
		              x_err_msg out nocopy varchar2);

 -- Start of comments
 --	API name 	: Calc_Age_In_Days
 --	Type		: Private
 --	Pre-reqs	: None.
 --	Function	: Calculates age in days using the profile option CST_ACCRUAL_AGE_IN_DAYS
 --	Parameters	:
 --	IN		: p_lrd		IN DATE			Required
 --				Last Receipt Date
 -- 			: p_lid		IN DATE			Required
 --				Last Invoice Date
 --     RETURN          : NUMBER
 --  			        Age In Days Value
 --				{x > -1} => Normal Completion
 --				-1	 => Error
 --	Version	: Current version	1.0
 --		  Previous version 	1.0
 --		  Initial version 	1.0
 -- End of comments
 function  calc_age_in_days ( p_lrd in date,
			      p_lid in date) return number;

 -- Start of comments
 --	API name 	: Update_All
 --	Type		: Private
 --	Pre-reqs	: None.
 --	Function	: Sets all the write_off_select_flags to 'Y' in the appropriate
 --                       table whose rows are returned by the where clause
 --	Parameters	:
 --	IN		: p_where	IN VARCHAR2		Required
 --				Where Clause
 -- 			: p_prog	IN NUMBER		Required
 --				Codes which table's write_off_select_flag column will be altered
 --		  	     	0 => cst_reconciliation_summary (AP and PO Form)
 --		       		1 => cst_misc_reconciliation (Miscellaneous Form)
 --                    		2 => cst_write_offs (View Write-Offs Form)
 --			: p_ou_id	IN NUMBER		Required
 --				Operating Unit Identifier
 --     OUT             : x_out       	OUT NOCOPY NUBMER	Required
 --				Sum of distributions/transactions selected
 --			: x_tot		OUT NOCOPY NUMBER	Required
 --  			        Number of rows selected for update
 --                     : x_err_num	OUT NOCOPY NUMBER	Required
 --                             Standard Error Parameter
 --                     : x_err_code	OUT NOCOPY VARCHAR2	Required
 --                             Standard Error Parameter
 --                     : x_err_msg	OUT NOCOPY VARCHAR2	Required
 --                             Standard Error Parameter
 --	Version	: Current version	1.0
 --		  Previous version 	1.0
 --		  Initial version 	1.0
 -- End of comments
 procedure update_all (
 			p_where in varchar2,
 		        p_prog in number,
		        p_ou_id in number,
		        x_out out nocopy number,
	    	        x_tot out nocopy number,
		        x_err_num out nocopy number,
	                x_err_code out nocopy varchar2,
		        x_err_msg out nocopy varchar2);

 -- Start of comments
 --	API name 	: Insert_Misc_Data_All
 --	Type		: Private
 --	Pre-reqs	: None.
 --	Function	: Write-off transactions selected in the Miscellaneous
 --  			  Accrual Write-Off Form in Costing tables.  Proecedue will also generate
 --   			  Write-Off events in SLA.  At the end, all the written-off transactions are
 --   			  removed from cst_misc_reconciliation.
 --	Parameters	:
 --	IN		: p_wo_date	IN DATE			Required
 --				Write-Off Date
 -- 			: p_off_id	IN NUMBER		Required
 --				Offset Account
 -- 			: p_rea_id	IN NUMBER		Optional
 --				Write-Off Reason
 --			: p_comments	IN VARCHAR2		Optional
 --				Write-Off Comments
 --			: p_sob_id	IN NUMBER		Required
 --				Ledger/Set of Books
 --			: p_ou_id	IN NUMBER		Required
 --				Operating Unit Identifier
 --     OUT             : x_count      	OUT NOCOPY NUBMER	Required
 --  			        Success Indicator
 --				{x > 0} => Success
 --				-1	=> Failure
 --                     : x_err_num	OUT NOCOPY NUMBER	Required
 --                             Standard Error Parameter
 --                     : x_err_code	OUT NOCOPY VARCHAR2	Required
 --                             Standard Error Parameter
 --                     : x_err_msg	OUT NOCOPY VARCHAR2	Required
 --                             Standard Error Parameter
 --	Version	: Current version	1.0
 --		  Previous version 	1.0
 --		  Initial version 	1.0
 -- End of comments
 procedure insert_misc_data_all(
 			    	p_wo_date in date,
			    	p_off_id in number,
			    	p_rea_id in number,
			    	p_comments in varchar2,
				p_sob_id in number,
			    	p_ou_id in number,
   		                x_count out nocopy number,
		                x_err_num out nocopy number,
	                        x_err_code out nocopy varchar2,
		                x_err_msg out nocopy varchar2);


 -- Start of comments
 --	API name 	: Insert_Appo_Data_All
 --	Type		: Private
 --	Pre-reqs	: None.
 --	Function	: Write-off PO distributions selected in the AP and PO
 --   		          Accrual Write-Off Form in Costing tables.  Proecedue will also generate
 --   			  Write-Off events in SLA.  A single write-off event will be generated
 --   			  regardless of the number of transactions that make up the PO distribution.
 --   			  At the end, all the written-off PO distributions
 --   			  and individual AP and PO transactions are removed from
 --   			  cst_reconciliation_summary and cst_ap_po_reconciliation..
 --	Parameters	:
 --	IN		: p_wo_date	IN DATE			Required
 --				Write-Off Date
 -- 			: p_rea_id	IN NUMBER		Optional
 --				Write-Off Reason
 --			: p_comments	IN VARCHAR2		Optional
 --				Write-Off Comments
 --			: p_sob_id	IN NUMBER		Required
 --				Ledger/Set of Books
 --			: p_ou_id	IN NUMBER		Required
 --				Operating Unit Identifier
 --     OUT             : x_count      	OUT NOCOPY NUBMER	Required
 --  			        Success Indicator
 --				{x > 0} => Success
 --				-1	=> Failure
 --                     : x_err_num	OUT NOCOPY NUMBER	Required
 --                             Standard Error Parameter
 --                     : x_err_code	OUT NOCOPY VARCHAR2	Required
 --                             Standard Error Parameter
 --                     : x_err_msg	OUT NOCOPY VARCHAR2	Required
 --                             Standard Error Parameter
 --	Version	: Current version	1.0
 --		  Previous version 	1.0
 --		  Initial version 	1.0
 -- End of comments
 procedure insert_appo_data_all(
 			    	p_wo_date in date,
			    	p_rea_id in number,
			    	p_comments in varchar2,
				p_sob_id in number,
			    	p_ou_id in number,
   		                x_count out nocopy number,
		                x_err_num out nocopy number,
	                        x_err_code out nocopy varchar2,
		                x_err_msg out nocopy varchar2);

 -- Start of comments
 --	API name 	: Is_Reversible
 --	Type		: Private
 --	Pre-reqs	: None.
 --	Function	: Checks whether a specific write-off distribution is reversible.
 --    			  A write-off is reversible if the write-off was performed in release 12 and later,
 --  			  has the transaction type code 'WRITE OFF', has not alredy been reversed and is
 --   			  not already part of another write-off distribution.
 --	Parameters	:
 --	IN		: p_wo_id	IN NUMBER		Required
 --				Write-Off Date
 --			: p_txn_c	IN VARCHAR2		Required
 --				Transaction Type
 --			: p_off_id	IN NUMBER		Required
 --				Offset Accont
 --			: p_ou_id	IN NUMBER		Required
 --				Operating Unit Identifier
 --     OUT             : x_count      	OUT NOCOPY NUBMER	Required
 --  			        Reversible Indicator
 --				FND_API.G_TRUE  => Reversible
 --				FND_API.G_FALSE	=> Not Reversible
 --                     : x_err_num	OUT NOCOPY NUMBER	Required
 --                             Standard Error Parameter
 --                     : x_err_code	OUT NOCOPY VARCHAR2	Required
 --                             Standard Error Parameter
 --                     : x_err_msg	OUT NOCOPY VARCHAR2	Required
 --                             Standard Error Parameter
 --	Version	: Current version	1.0
 --		  Previous version 	1.0
 --		  Initial version 	1.0
 -- End of comments
 procedure is_reversible(
			p_wo_id in number,
			p_txn_c in varchar2,
			p_off_id in number,
			p_ou_id in number,
 		        x_count out nocopy varchar2,
		        x_err_num out nocopy number,
	                x_err_code out nocopy varchar2,
		        x_err_msg out nocopy varchar2);

 -- Start of comments
 --	API name 	: Reverse_Write_Offs
 --	Type		: Private
 --	Pre-reqs	: None.
 --	Function	: Performs a write-off reversal and insert distributions and/or
 --    			  individual transactions back into the appropriate tables.
 --			  If the reversing miscellaneous write-offs, then a write-off
 --                       reversal is created and the individual miscellaneous transactions
 --			  is inserted back into cst_misc_reconciliation.  If reversing an
 --			  AP and PO distribution, then a write-off reversal is created and all
 --   		 	  the individual AP and PO transactions in addition to all write-offs
 --			  and reversals sharing the same PO distribution ID and accrual account
 --			  are summed up and if they equal a non-zero value, they are inserted
 --			  into the cst_reconciliation_summary and cst_ap_po_reconciliation
 --			  as appropriate (see package body).
 --	Parameters	:
 --	IN		: p_wo_date	IN DATE			Required
 --				Write-Off Date
 -- 			: p_rea_id	IN NUMBER		Optional
 --				Write-Off Reason
 --			: p_comments	IN VARCHAR2		Optional
 --				Write-Off Comments
 --			: p_sob_id	IN NUMBER		Required
 --				Ledger/Set of Books
 --			: p_ou_id	IN NUMBER		Required
 --				Operating Unit Identifier
 --     OUT             : x_count      	OUT NOCOPY NUBMER	Required
 --  			        Success Indicator
 --				{x > 0} => Success
 --				-1	=> Failure
 --                     : x_err_num	OUT NOCOPY NUMBER	Required
 --                             Standard Error Parameter
 --                     : x_err_code	OUT NOCOPY VARCHAR2	Required
 --                             Standard Error Parameter
 --                     : x_err_msg	OUT NOCOPY VARCHAR2	Required
 --                             Standard Error Parameter
 --	Version	: Current version	1.0
 --		  Previous version 	1.0
 --		  Initial version 	1.0
 -- End of comments
 procedure reverse_write_offs(
			    	p_wo_date in date,
			    	p_rea_id in number,
			    	p_comments in varchar2,
				p_sob_id in number,
			    	p_ou_id in number,
   		                x_count out nocopy number,
		                x_err_num out nocopy number,
	                        x_err_code out nocopy varchar2,
		                x_err_msg out nocopy varchar2);

END CST_ACCRUAL_REC_PVT;

/
