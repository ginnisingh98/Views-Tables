--------------------------------------------------------
--  DDL for Package Body GMF_AR_CUSTOMER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_AR_CUSTOMER" as
/* $Header: gmfcscob.pls 120.1 2006/02/01 05:30:50 sschinch noship $ */


	function PHONE 	(cust_id	in	number,
			addressid	in	number,
			contactid	in	number,
			partyid		in	number,
			partysiteid	in	number,
			phonetype	in	varchar2)
	return varchar2 IS
	v_result varchar2(100);
	begin
	  return(null);
	end PHONE;

	function TERMS (pterm_id		in	number)
	return varchar2 IS
		v_result varchar2(100);
	begin
         return(null);
	end TERMS;

	function FOB (pfob_point	in	varchar2)
	return varchar2 IS
	v_result varchar2(100);
	begin
	  return(null);
	end FOB;

	function SALESREP (psalesrep_id	in	number,
			porg_id		in	number)
	return varchar2 IS
		v_result varchar2(100);
	begin
          return(null);
	end SALESREP;

	function CURRENCY (pcust_id	in 	NUMBER,
			psite_use_id	in	NUMBER,
			porg_id		in	NUMBER)
	return varchar2 IS

	begin
	  return(null);
	end CURRENCY;

	function CURRENCY_DATE (pcust_id	in 	NUMBER,
			psite_use_id	in	NUMBER,
			porg_id		in	NUMBER)
	return DATE IS
	begin
         return(null);
	end CURRENCY_DATE;

	function IS_OPM_ORG (v_org_id	in 	NUMBER)
	return boolean is
	begin
           return(false);
	end IS_OPM_ORG;

	FUNCTION phone_date 	(cust_id	in	NUMBER,
			addressid	in	NUMBER,
			contactid	in	NUMBER,
			partyid		in	number,
			partysiteid	in	number)
	RETURN DATE IS

	BEGIN
          return(null);
	END PHONE_DATE;
end GMF_AR_CUSTOMER;

/
