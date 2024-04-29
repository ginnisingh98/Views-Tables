--------------------------------------------------------
--  DDL for Package ARW_SEARCH_CUSTOMERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARW_SEARCH_CUSTOMERS" AUTHID CURRENT_USER AS
/*$Header: ARWCUSRS.pls 120.6.12010000.3 2009/01/08 06:54:21 avepati ship $*/
--

TYPE cust_rec IS RECORD (
  cus_seq_num BINARY_INTEGER := 0,
  addr_cnt    BINARY_INTEGER := 0
  );

TYPE rev_cust_rec IS RECORD (
  customer_id hz_cust_accounts.cust_account_id%TYPE,
  addr_cnt    BINARY_INTEGER := 0
  );

TYPE addr_rec IS RECORD (
  customer_id    hz_cust_acct_sites.cust_account_id%TYPE,
  addr_seq_num   BINARY_INTEGER := 0,
  total_score    NUMBER(15) := 0
  );

TYPE customer_rectype IS RECORD (
       customer_id           ari_customer_search_v.customer_id%TYPE,
       DETAILS_LEVEL         ari_customer_search_v.DETAILS_LEVEL%TYPE,
       CUSTOMER_NUMBER       ari_customer_search_v.CUSTOMER_NUMBER%TYPE,
       CUSTOMER_NAME         ari_customer_search_v.CUSTOMER_NAME%TYPE,
       ADDRESS_ID            hz_cust_acct_sites.cust_acct_site_id%TYPE,
       CONCATENATED_ADDRESS  ari_customer_search_v.CONCATENATED_ADDRESS%TYPE,
       CONTACT_NAME          ar_cust_search_gt.CONTACT_NAME%TYPE,
       CONTACT_PHONE         ar_cust_search_gt.CONTACT_PHONE%TYPE,
       BILL_TO_SITE_USE_ID   hz_cust_site_uses.SITE_USE_ID%type,
       SITE_USES             ar_cust_search_gt.SITE_USES%TYPE,
       ORG_ID                ari_customer_search_v.ORG_ID%TYPE,
       SELECTED              VARCHAR2(2),
       LOCATION              VARCHAR2(4000)
       );

TYPE cust_tab IS TABLE OF cust_rec INDEX BY BINARY_INTEGER;

TYPE rev_cust_tab IS TABLE OF rev_cust_rec INDEX BY BINARY_INTEGER;

TYPE addr_tab IS TABLE OF addr_rec INDEX BY BINARY_INTEGER;

TYPE customer_tabletype IS TABLE OF customer_rectype INDEX BY BINARY_INTEGER;

--

FUNCTION search_customers(
    i_keyword IN varchar2 DEFAULT null,
    i_first_row IN binary_integer DEFAULT 1,
    i_last_row IN binary_integer DEFAULT null
  ) RETURN customer_tabletype;
--
PROCEDURE ari_search ( i_keyword   IN varchar2,
                       i_name_num IN VARCHAR2,
                       x_status    OUT NOCOPY VARCHAR2,
                       x_msg_count OUT NOCOPY NUMBER,
                       x_msg_data  OUT NOCOPY VARCHAR2 );
--

TYPE CustSite_rec_type IS RECORD (
	CustomerId         NUMBER,
        SiteUseId	   NUMBER
	);

TYPE CustSite_tbl IS TABLE of CustSite_rec_type INDEX BY BINARY_INTEGER;

-- Bug# 5858769
-- Provision to select sites
PROCEDURE initialize_account_sites ( p_custsite_rec_tbl in CustSite_tbl,
		p_party_id in number,
		p_session_id in number,
		p_user_id in number ,
		p_org_id in number ,
		p_is_internal_user in varchar2
		);


PROCEDURE init_acct_sites_anon_login ( p_customer_id in number,
		p_site_use_id in number,
		p_party_id in number,
		p_session_id in number,
		p_user_id in number ,
		p_org_id in number ,
		p_is_internal_user in varchar2
		);
PROCEDURE update_account_sites ( p_customer_id in number,
		p_session_id in number,
		p_user_id in number ,
		p_org_id in number ,
		p_is_internal_user in varchar2
		);

END arw_search_customers;

/
