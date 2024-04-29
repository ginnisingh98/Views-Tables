--------------------------------------------------------
--  DDL for Package FV_BE_PKG4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_BE_PKG4" AUTHID CURRENT_USER as
-- $Header: FVBEPG3S.pls 120.3 2002/11/12 22:21:50 ksriniva ship $

 procedure re_seq_budget_levels (
					x_error_code  OUT NOCOPY 	number,
					x_set_of_books_id IN 	number);

 procedure get_budget_description (x_budget_level_id 	IN number,
				   x_set_of_bks_id   		IN number,
				   x_description  	 OUT NOCOPY varchar2,
				   x_error_code   	 OUT NOCOPY number);

 procedure get_trans_description(x_transaction_type        IN varchar2,
                                 x_set_of_bks_id           IN number,
                                 x_trans_description       OUT NOCOPY varchar2,
                                 x_error_code              OUT NOCOPY number);


 procedure get_user_name (x_error_code OUT NOCOPY number,
				  x_user_name OUT NOCOPY varchar2,
				  x_user_id		IN	number);

 procedure get_resource_type_desc (x_resource_type 	 IN varchar2,
						x_lookup_type 	 IN varchar2,
						x_description	 OUT NOCOPY varchar2,
						x_error_code	 OUT NOCOPY number);

Procedure create_journal_category  ( P_SET_OF_BKS_ID IN  NUMBER,
                                 P_ERR_CODE      OUT NOCOPY NUMBER);


End fv_be_pkg4;


 

/
