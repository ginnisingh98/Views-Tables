--------------------------------------------------------
--  DDL for Package GMF_AR_CUSTOMER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_AR_CUSTOMER" AUTHID CURRENT_USER as
/* $Header: gmfcscos.pls 115.6 2004/01/09 06:49:28 mkalyani ship $ */
	-- BEGIN BUG# 1982384 Raghavendra Srivatsa
	-- Changed the function prototype.
	function PHONE 	(cust_id	in	number,
			addressid	in	number,
			contactid	in	number,
			partyid		in	number,
			partysiteid	in	number,
			phonetype	in	varchar2)
		return varchar2;
	-- END BUG# 1982384
	function TERMS (pterm_id		in	number)
		return varchar2;
	function FOB	(pfob_point	in	varchar2)
		return varchar2;
	function SALESREP (psalesrep_id	in	number,
			porg_id		in	number)
		return varchar2;
	function CURRENCY (pcust_id	in	number,
			psite_use_id	in	number,
			porg_id		in	number)
		return varchar2;
	function CURRENCY_DATE (pcust_id	in	number,
			psite_use_id	in	number,
			porg_id		in	number)
		return date;
	function IS_OPM_ORG (v_org_id   in      NUMBER)
			return boolean;
/*BEGIN BUG#1822750 Piyush K. Mishra*/
	-- BEGIN BUG# 1982384 Raghavendra Srivatsa
	-- Changed the function prototype.
	function PHONE_DATE 	(cust_id	in	number,
			addressid	in	number,
			contactid	in	number,
			partyid		in	number,
			partysiteid	in	number)
			return date;
	-- END BUG# 1982384
/*END BUG#1822750*/
	pragma restrict_references (PHONE, WNDS);
	pragma restrict_references (TERMS, WNDS);
	pragma restrict_references (FOB, WNDS);
	pragma restrict_references (SALESREP, WNDS);
	pragma restrict_references (CURRENCY, WNDS);
	pragma restrict_references (CURRENCY_DATE, WNDS);
	pragma restrict_references (IS_OPM_ORG, WNDS);
end GMF_AR_CUSTOMER;

 

/
