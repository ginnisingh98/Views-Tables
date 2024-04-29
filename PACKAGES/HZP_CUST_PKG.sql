--------------------------------------------------------
--  DDL for Package HZP_CUST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZP_CUST_PKG" AUTHID CURRENT_USER as
/* $Header: ARHCUSTS.pls 120.5 2005/06/16 21:10:16 jhuang ship $*/
--
--
procedure check_unique_customer_name(p_rowid in varchar2,
				     p_customer_name in varchar2,
				     p_warning_flag in out NOCOPY varchar2
	    	       		     );
--
--
procedure check_unique_customer_number(p_rowid in varchar2,
				       p_customer_number in varchar2
	    	       		      );
procedure check_unique_party_number(p_rowid in varchar2,
				       p_party_number in varchar2
	    	       		      );
--
--
procedure check_unique_orig_system_ref(p_rowid in varchar2,
			 	       p_orig_system_reference in varchar2
				      );
--
--
procedure delete_customer_alt_names(p_rowid in varchar2,
                                    p_status in varchar2,
                                    p_customer_id in number
                                    );
--
--
FUNCTION get_statement_site (
                    p_customer_id IN hz_cust_accounts.cust_account_id%type
                            ) RETURN NUMBER;

--
--

FUNCTION get_dunning_site   (
                    p_customer_id IN hz_cust_accounts.cust_account_id%type
                            ) RETURN NUMBER;

--
--
FUNCTION get_current_dunning_type (
                   p_customer_id in hz_cust_accounts.cust_account_id%type,
		   p_bill_to_site_id in NUMBER DEFAULT NULL
                                  ) RETURN VARCHAR2;

--
FUNCTION arxvamai_overall_cr_limit ( p_customer_id NUMBER,
                                     p_currency_code VARCHAR2,
                                     p_customer_site_use_id NUMBER
                                    ) RETURN NUMBER;

--
FUNCTION arxvamai_order_cr_limit ( p_customer_id NUMBER,
                                   p_currency_code VARCHAR2,
                                   p_customer_site_use_id NUMBER
                                  ) RETURN NUMBER;

--
TYPE id_tab IS TABLE OF hz_cust_site_uses.site_use_id%type INDEX BY BINARY_INTEGER;
g_site_use_id_tab  id_tab;
--
FUNCTION get_primary_billto_site (
                p_customer_id IN hz_cust_accounts.cust_account_id%type
                                  ) RETURN NUMBER;
--

end;

 

/
