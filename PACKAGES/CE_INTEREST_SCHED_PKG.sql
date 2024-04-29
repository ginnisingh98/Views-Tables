--------------------------------------------------------
--  DDL for Package CE_INTEREST_SCHED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_INTEREST_SCHED_PKG" AUTHID CURRENT_USER AS
/* $Header: ceintscs.pls 120.1 2005/07/29 20:38:20 lkwan ship $ */

--l_DEBUG varchar2(1);
PROCEDURE  xtr_schedule_update(p_ce_bank_account_id 	IN 	number,
			   	p_interest_rounding 	IN 	varchar2,
				p_interest_includes 	IN 	varchar2,
				p_basis 		IN 	varchar2,
				p_day_count_basis 	IN 	varchar2,
				x_return_status 	OUT NOCOPY varchar2,
				x_msg_count	 	OUT NOCOPY number,
				x_msg_data	 	OUT NOCOPY varchar2
			  );

PROCEDURE  remove_schedule_account(p_interest_schedule_id IN	number,
				   p_bank_account_id 	  IN	number,
			      	   x_return_status        IN OUT NOCOPY VARCHAR2,
    			      	   x_msg_count               OUT NOCOPY NUMBER,
			      	   x_msg_data                OUT NOCOPY VARCHAR2
				);

PROCEDURE  assign_schedule_account(p_interest_schedule_id IN 	number,
				   p_bank_account_id 	  IN	number,
			   	   p_basis 		  IN 	varchar2,
			   	   p_interest_includes 	  IN 	varchar2,
			   	   p_interest_rounding 	  IN 	varchar2,
			  	   p_day_count_basis 	  IN 	varchar2,
			      	   x_return_status        IN OUT NOCOPY VARCHAR2,
    			      	   x_msg_count               OUT NOCOPY NUMBER,
			      	   x_msg_data                OUT NOCOPY VARCHAR2
				);


PROCEDURE  delete_interest_rates(p_interest_schedule_id number,
				 p_effective_date 	date);

PROCEDURE  delete_bal_ranges(p_interest_schedule_id number);

PROCEDURE  delete_schedule(p_interest_schedule_id IN	number,
			   x_return_status	  IN OUT NOCOPY VARCHAR2,
    			   x_msg_count      	     OUT NOCOPY NUMBER,
			   x_msg_data       	     OUT NOCOPY VARCHAR2
				);


PROCEDURE  update_schedule(p_interest_schedule_id IN 	number,
			   p_basis 		  IN 	varchar2,
			   p_interest_includes 	  IN 	varchar2,
			   p_interest_rounding 	  IN 	varchar2,
			   p_day_count_basis 	  IN 	varchar2,
			   x_return_status	  IN OUT NOCOPY VARCHAR2,
    			   x_msg_count      	     OUT NOCOPY NUMBER,
			   x_msg_data       	     OUT NOCOPY VARCHAR2
			  );


END CE_INTEREST_SCHED_PKG;

 

/
