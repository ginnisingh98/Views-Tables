--------------------------------------------------------
--  DDL for Package OKS_ENTITLEMENTS_WEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_ENTITLEMENTS_WEB" AUTHID CURRENT_USER AS
/* $Header: OKSJENWS.pls 120.2 2006/01/04 12:15:32 hmnair noship $ */

  -- GLOBAL VARIABLES
  -----------------------------------------------------------------------------------------
  g_pkg_name	        CONSTANT VARCHAR2(200) := 'OKS_ENTITLEMENTS_WEB';
  g_app_name_oks	    CONSTANT VARCHAR2(3)   := 'OKS';
  g_app_name_okc	    CONSTANT VARCHAR2(3)   := 'OKC';
  -----------------------------------------------------------------------------------------

  -- GLOBAL MESSAGE CONSTANTS
  -----------------------------------------------------------------------------------------
  g_true                CONSTANT VARCHAR2(1)   := OKC_API.G_TRUE;
  g_false               CONSTANT VARCHAR2(1)   := OKC_API.G_FALSE;
  g_ret_sts_success	    CONSTANT VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  g_ret_sts_error	      CONSTANT VARCHAR2(1)   := OKC_API.G_RET_STS_ERROR;
  g_ret_sts_unexp_error CONSTANT VARCHAR2(1)   := OKC_API.G_RET_STS_UNEXP_ERROR;
  g_required_value      CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  g_invlaid_value       CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  g_col_name_token      CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  g_parent_table_token  CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  g_child_table_token   CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  g_no_parent_record    CONSTANT VARCHAR2(200) := 'OKS_NO_PARENT_RECORD';
  g_unexpected_error    CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  g_sqlerrm_token       CONSTANT VARCHAR2(200) := 'SQLerrm';
  g_sqlcode_token       CONSTANT VARCHAR2(200) := 'SQLcode';
  g_uppercase_required  CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UPPERCASE_REQUIRED';
  ------------------------------------------------------------------------------------------

   -- Constants used for Message Logging
  G_LEVEL_UNEXPECTED CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR      CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION  CONSTANT NUMBER := 17;
  G_LEVEL_EVENT      CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE  CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT  CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_LEVEL_CURRENT    CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_MODULE_CURRENT   CONSTANT VARCHAR2(255) := 'oks.plsql.OKS_ENTITLEMENTS_WEB';


  -- RECORD TYPES  TABLE TYPES
  -- =======================================================================================

  -- Record for Entitlement Search results
  TYPE output_rec_contract IS RECORD(
    contract_number              VARCHAR2(120),
    contract_number_modifier     VARCHAR2(120),
    contract_category            VARCHAR2(30),
    contract_category_meaning    VARCHAR2(90),
    contract_status_code         VARCHAR2(30),
    contract_status_meaning      VARCHAR2(90),
    known_as                     VARCHAR2(300),
    short_description            VARCHAR2(1995),
    start_date                   DATE,
    end_date                     DATE,
    date_terminated              DATE,
    contract_amount              NUMBER,
    amount_code                  VARCHAR2(15)
  );
  TYPE output_tbl_contract IS TABLE OF output_rec_contract INDEX BY BINARY_INTEGER;

  -- Record to accomodate all account ID's in search entitlements
  Type account_all_id_rec_type IS RECORD(
    ID  NUMBER
  );
  TYPE account_all_id_tbl_type IS TABLE OF account_all_id_rec_type INDEX BY BINARY_INTEGER;

  --Record for Site for a given Party
  TYPE party_sites_rec_type IS RECORD(
    ID1         NUMBER,
    ID2         CHAR(1),
    NAME        VARCHAR(250),
    DESCRIPTION VARCHAR(250)
  );
  TYPE party_sites_tbl_type IS TABLE OF party_sites_rec_type INDEX BY BINARY_INTEGER;

  --Record for party Items
  TYPE party_items_rec_type IS RECORD(
    ID1         NUMBER,
    ID2         NUMBER,
    NAME        VARCHAR(250),
    DESCRIPTION VARCHAR(250)
  );
  TYPE party_items_tbl_type IS TABLE OF party_items_rec_type INDEX BY BINARY_INTEGER;

  --Record for Systems for a given Party
  TYPE party_systems_rec_type IS RECORD(
    ID1         NUMBER,
    ID2         CHAR(1),
    NAME        VARCHAR(250),
    DESCRIPTION VARCHAR(250)
  );
  TYPE party_systems_tbl_type IS TABLE OF party_systems_rec_type INDEX BY BINARY_INTEGER;

  --Record for Products for a given Party
  TYPE party_products_rec_type IS RECORD(
    ID1         NUMBER,
    ID2         CHAR(1),
    NAME        VARCHAR(250),
    DESCRIPTION VARCHAR(250)
  );
  TYPE party_products_tbl_type IS TABLE OF party_products_rec_type INDEX BY BINARY_INTEGER;

  --Record for Contract Categories for Service
  TYPE contract_cat_rec_type IS RECORD(
    contract_cat_code    VARCHAR2(100),
    contract_cat_meaning VARCHAR2(100)
  );
  TYPE contract_cat_tbl_type IS TABLE OF contract_cat_rec_type INDEX BY BINARY_INTEGER;

  --Record for Status of a given Contract
  TYPE contract_status_rec_type IS RECORD(
    contract_status_code    VARCHAR2(100),
    contract_status_meaning VARCHAR2(100)
  );
  TYPE contract_status_tbl_type IS TABLE OF contract_status_rec_type INDEX BY BINARY_INTEGER;

  --Record for Contract Header Information
  TYPE hdr_rec_type IS RECORD(
    header_id		  NUMBER,
    contract_number	  VARCHAR2(120),
    modifier              VARCHAR2(120),
    version		  Varchar2(1000),
    known_as	          VARCHAR2(300),
    short_description     VARCHAR2(600),
    contract_amount	  NUMBER,
    currency_code         VARCHAR2(15),
    sts_code              VARCHAR2(30),
    status		  VARCHAR2(50),
    scs_code              VARCHAR2(30),
    scs_category          VARCHAR2(90),
    order_number          NUMBER,
    start_date    	  DATE,
    end_date	          DATE,
    duration              NUMBER,
    period_code           VARCHAR2(25)
  );

  --Record for Contract Header Address Information
  TYPE hdr_addr_rec_type IS RECORD(
    header_id	            NUMBER,
  	bill_to_customer        VARCHAR2(940),
	  bill_to_site	        VARCHAR2(940),
  	bill_to_address	        VARCHAR2(360),
	  bill_to_city_state_zip	VARCHAR2(240),
  	bill_to_country	        VARCHAR2(960),
	  ship_to_customer	    VARCHAR2(940),
    ship_to_site            VARCHAR2(940),
  	ship_to_address		    VARCHAR2(360),
	  ship_to_city_state_zip  VARCHAR2(240),
  	ship_to_country			VARCHAR2(960)
  );

  --Record for Party information of a given Contract
  TYPE party_rec_type IS RECORD(
    header_id	 NUMBER,
    rle_code     VARCHAR2(30),
  	party_role	 VARCHAR2(80),
	  party_name	 VARCHAR2(360),
  	party_number VARCHAR2(30),
	  gsa_flag	 VARCHAR2(1),
    bill_profile Varchar2(100)
  );
  TYPE party_tbl_type IS TABLE OF party_rec_type INDEX BY BINARY_INTEGER;

  --Record for Line inforamtion of a given Contract
  TYPE line_rec_type IS RECORD(
    header_id               NUMBER, --NUMBER(40),--to make it work on Oracle database 10iR1 as per bug  2902293
  	line_id                 NUMBER, --NUMBER(40),--to make it work on Oracle database 10iR1 as per bug  2902293
	start_date              DATE,
  	end_date                DATE,
	exemption               VARCHAR2(40),
  	line_type               VARCHAR2(50),
	line_number             VARCHAR2(150),
  	line_name               VARCHAR2(240),
  	line_description        VARCHAR2(450),
	inv_print_flag          VARCHAR2(450),
  	invoice_text            VARCHAR2(2000),
	account_name            VARCHAR2(360),
  	account_desc            VARCHAR2(360),
    account_number          NUMBER,
    quantity                NUMBER,
	coverage_name           VARCHAR2(150),
  	bill_to_site	        VARCHAR2(40),
	bill_to_address	        VARCHAR2(360),
  	bill_to_city_state_zip	VARCHAR2(240),
  	bill_to_country	        VARCHAR2(60),
    ship_to_site            VARCHAR2(40),
	ship_to_address		    VARCHAR2(360),
  	ship_to_city_state_zip  VARCHAR2(240),
	ship_to_country			VARCHAR2(60)
  );
  TYPE line_tbl_type IS TABLE OF line_rec_type INDEX BY BINARY_INTEGER;

  --Record for Contact information of a given Party
  TYPE party_contact_rec_type IS RECORD(
    header_id      NUMBER,
    rle_code       VARCHAR2(30),
  	owner_table_id VARCHAR2(40),
   	contact_role   VARCHAR2(80),
	  start_date     DATE,
    end_date       DATE,
    contact_name   VARCHAR2(360),
    primary_email  VARCHAR2(80),
    contact_id     VARCHAR2(40)
  );
  TYPE party_contact_tbl_type IS TABLE OF party_contact_rec_type INDEX BY BINARY_INTEGER;

  --Record for Contact information for a given Contact
  TYPE pty_cntct_dtls_rec_type IS RECORD(
    owner_table_id   VARCHAR2(40),
    contact_type     VARCHAR2(30),
    email_address    VARCHAR2(2000),
    phone_type       VARCHAR2(30),
    phone_country_cd VARCHAR2(10),
    phone_area_cd    VARCHAR2(10),
    phone_number     VARCHAR2(30),
    phone_extension  VARCHAR2(20)
  );
  TYPE pty_cntct_dtls_tbl_type IS TABLE OF pty_cntct_dtls_rec_type INDEX BY BINARY_INTEGER;

  --Record for Line information of a given Line
  TYPE line_hdr_rec_type IS RECORD(
    renewal_type              VARCHAR2(80),
    line_amount               NUMBER,
    line_amount_denomination  VARCHAR2(100),
    invoice_text              VARCHAR2(450),
    invoice_print_flag        VARCHAR2(450),
    tax_status_code           VARCHAR2(450),
    tax_status                VARCHAR2(80),
    tax_exempt_code           VARCHAR2(40),
    tax_code                  VARCHAR2(50),
    coverage_id               NUMBER,
    coverage_name             VARCHAR2(150),
    coverage_description      VARCHAR2(2000),
    coverage_start_date       DATE,
    coverage_end_date         DATE,
    coverage_warranty_yn      VARCHAR2(5),
    coverage_type             VARCHAR2(80),
    exception_cov_id          NUMBER,
    exception_cov_line_id     VARCHAR2(450),
    exception_cov_name        VARCHAR2(150),
    exception_cov_description VARCHAR2(2000),
    exception_cov_start_date  DATE,
    exception_cov_end_date    DATE,
    exception_cov_warranty_yn VARCHAR2(5),
    exception_cov_type        VARCHAR2(80)
  );

  --Record for Covered Level information for a given Line
  TYPE covered_level_rec_type IS RECORD(
    line_number   VARCHAR2(450),
    covered_level VARCHAR2(450),
    name          VARCHAR2(450),
    start_date    DATE,
    end_date      DATE,
    duration      NUMBER,
    period        VARCHAR2(450),
    terminated    VARCHAR2(450),
    renewal_type  VARCHAR2(450)
  );
  TYPE covered_level_tbl_type IS TABLE OF covered_level_rec_type INDEX BY BINARY_INTEGER;

  --Record for  Customer Contact information for a given Line
  TYPE cust_contacts_rec_type IS RECORD(
    cust_contacts_role       VARCHAR2(450),
    cust_contacts_address    VARCHAR2(450),
    cust_contacts_name       VARCHAR2(450),
    cust_contacts_start_date DATE,
    cust_contacts_end_date   DATE
  );
  TYPE cust_contacts_tbl_type IS TABLE OF cust_contacts_rec_type INDEX BY BINARY_INTEGER;

  --Record for Coverage information for a given Line
  TYPE coverage_rec_type IS RECORD(
    coverage_billing_offset     NUMBER,
    coverage_wrrnty_inheritance VARCHAR2(450),
    transfer_allowed            VARCHAR2(450),
    free_upgrade                VARCHAR2(450)
  );

  --Record for Business Process information for a given Line
  TYPE bus_proc_rec_type IS RECORD(
    bus_proc_id              NUMBER,
    bus_proc_offset_duration NUMBER,
    bus_proc_name            VARCHAR2(450),
    bus_proc_offset_period   VARCHAR2(450),
    bus_proc_discount        VARCHAR2(450),
    bus_proc_price_list      VARCHAR2(450)
  );
  TYPE bus_proc_tbl_type IS TABLE OF bus_proc_rec_type INDEX BY BINARY_INTEGER ;

  --Record for Time Zone information for a given Business Process
  TYPE bus_proc_hdr_rec_type IS RECORD(
    bus_proc_hdr_time_zone VARCHAR2(450)
  );

  --Record for Coverage Times information for a given Business Process
  TYPE coverage_times_rec_type IS RECORD (
    day_of_week VARCHAR2(20),
    start_time  VARCHAR2(10),
    end_time    VARCHAR2(10)
  );
  TYPE coverage_times_tbl_type IS TABLE OF coverage_times_rec_type INDEX BY BINARY_INTEGER ;

  --Record for Reaction Times information for a given Business Process
  TYPE reaction_times_rec_type IS RECORD (
    name         VARCHAR2(450),
    severity     VARCHAR2(450),
    work_thru_yn VARCHAR2(3),
    active_yn    VARCHAR2(3),
    sun          VARCHAR2(30),
    mon          VARCHAR2(30),
    tue          VARCHAR2(30),
    wed          VARCHAR2(30),
    thr          VARCHAR2(30),
    fri          VARCHAR2(30),
    sat          VARCHAR2(30)
  );
  TYPE reaction_times_tbl_type IS TABLE OF reaction_times_rec_type INDEX BY BINARY_INTEGER ;

  --Record for Resolution Times for a given Business Process
  TYPE resolution_times_rec_type IS RECORD (
    name         VARCHAR2(450),
    severity     VARCHAR2(450),
    work_thru_yn VARCHAR2(3),
    active_yn    VARCHAR2(3),
    sun          VARCHAR2(30),
    mon          VARCHAR2(30),
    tue          VARCHAR2(30),
    wed          VARCHAR2(30),
    thr          VARCHAR2(30),
    fri          VARCHAR2(30),
    sat          VARCHAR2(30)
  );
  TYPE resolution_times_tbl_type IS TABLE OF resolution_times_rec_type INDEX BY BINARY_INTEGER ;

  --Record for Preferred Resources for a given Business Process
  TYPE pref_resource_rec_type IS RECORD (
    resource_type VARCHAR2(80),
    name          VARCHAR2(360)
  );
  TYPE pref_resource_tbl_type IS TABLE OF pref_resource_rec_type INDEX BY BINARY_INTEGER ;

  --Record for Billing Types inforamtion for a given Business Process
  TYPE bus_proc_bil_typ_rec_type IS RECORD (
    bill_type           VARCHAR2(450),
    max_amount          VARCHAR2(450),
    per_covered         VARCHAR2(450),
    billing_rate        VARCHAR2(450),
    unit_of_measure     VARCHAR2(25),
    flat_rate           VARCHAR2(450),
    per_over_list_price VARCHAR2(450)
  );
  TYPE bus_proc_bil_typ_tbl_type IS TABLE OF bus_proc_bil_typ_rec_type INDEX BY BINARY_INTEGER ;

  --Record for Usage information for a given Usage Line
  TYPE usage_hdr_rec_type IS RECORD(
    usage_avg_allowed            VARCHAR2(450),
    usage_avg_interval           VARCHAR2(450),
    usage_avg_settlement_allowed VARCHAR2(450),
    usage_type                   VARCHAR2(450),
    usage_invoice_text           VARCHAR2(2000),
    usage_invoice_print_flag     VARCHAR2(450),
    usage_tax_code               VARCHAR2(450),
    usage_tax_status             VARCHAR2(450),
    usage_amount                 NUMBER
  );

  --Record for Covered Products information for a given Usage Line
  TYPE covered_prods_rec_type IS RECORD(
    covered_prod_ID  VARCHAR2(450),
    covered_prod_line_Number  VARCHAR2(450),
    covered_prod_invoice_text VARCHAR2(2000),
    covered_prod_line_ref     VARCHAR2(450),
    covered_prod_rate_fixed   VARCHAR2(450),
    covered_prod_rate_minimum VARCHAR2(450),
    covered_prod_rate_default VARCHAR2(450),
    covered_prod_uom          VARCHAR2(450),
    covered_prod_period       VARCHAR2(450),
    covered_prod_amcv         VARCHAR2(450),
    covered_prod_level_yn     VARCHAR2(450),
    covered_prod_reading      VARCHAR2(450),
    covered_prod_net_reading  VARCHAR2(450),
    covered_prod_price        VARCHAR2(450),
    covered_prod_name         VARCHAR2(450),
    covered_prod_description  VARCHAR2(2000),
    covered_prod_details      VARCHAR2(2000)
  );
  TYPE covered_prods_tbl_type IS TABLE OF covered_prods_rec_type INDEX BY BINARY_INTEGER;

  --Record for Counter information for a given Covered Product of a Usage Line
  TYPE counter_rec_type IS RECORD(
    counter_type        VARCHAR2(450),
    counter_uom_code    VARCHAR2(450),
    counter_name        VARCHAR2(450),
    counter_time_stamp  VARCHAR2(450),
    counter_net_reading VARCHAR2(450)
  );
  TYPE counter_tbl_type IS TABLE OF counter_rec_type INDEX BY BINARY_INTEGER;

  /*
  ||==========================================================================
  || PROCEDURE: simple_srch_rslts
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure is invoked in the Entitlement Simple Search JSP.
  ||     This procedure is used to retrieve contracts for default search criteria.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_contract_party_id     -- Contract Party ID on which to search.
  ||     p_account_id            -- Account ID on which to search.
  ||
  || Out Parameters:
  ||     x_return_status  -- Success of the procedure.
  ||     x_msg_count      -- Error message count
  ||     x_msg_data       -- Error message
  ||     x_contract_tbl   -- Search results contract table
  ||
  || In Out Parameters:
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */
  PROCEDURE simple_srch_rslts(
    p_contract_party_id     IN  NUMBER,
    p_account_id            IN  VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    x_contract_tbl          OUT NOCOPY OKS_ENTITLEMENTS_WEB.output_tbl_contract
  );

  /*
  ||==========================================================================
  || PROCEDURE: cntrct_srch_rslts
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure is invoked in the Entitlement Search JSP.
  ||     This procedure is used to retrieve contracts for given search criteria.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_contract_number       -- Contract Number on which to search.
  ||     p_contract_status_code  -- Contract Status on which to search.
  ||     p_start_date_from       -- Contract Start Date From on which to search.
  ||     p_start_date_to         -- Contract Start Date End on which to search.
  ||     p_end_date_from         -- Contract End Date From on which to search.
  ||     p_end_date_to           -- Contract End Date End on which to search.
  ||     p_date_terminated_from  -- Contract Terminated Date From on which to search.
  ||     p_date_terminated_to    -- Contract Terminated Date End on which to search.
  ||     p_contract_party_id     -- Contract Party ID on which to search.
  ||     p_covlvl_site_id        -- Covered Level Site ID on which to search.
  ||     p_covlvl_site_name      -- Covered Level Site Name on which to search.
  ||     p_covlvl_system_id      -- Covered Level System ID on which to search.
  ||     p_covlvl_system_name    -- Covered Level System Name on which to search.
  ||     p_covlvl_product_id     -- Covered Level Product ID on which to search.
  ||     p_covlvl_product_name   -- Covered Level Product Name on which to search.
  ||     p_covlvl_system_id      -- Covered Level System ID on which to search.
  ||     p_covlvl_system_name    -- Covered Level System Name on which to search.
  ||     p_entitlement_check_YN  -- Flag to searh for Entitlement Contracts.
  ||     p_account_check_all     -- Flag tosearch for all accounts.
  ||     p_account_id            -- Account ID on which to search.
  ||     p_account_all_id        -- List of account ID's to search for all accounts.
  ||     p_covlvl_party_id       -- Party ID of the covered level.
  ||     p_account_all_id        -- Table of accounts if all the accounts are to be searched.
  ||
  || Out Parameters:
  ||     x_return_status  -- Success of the procedure.
  ||     x_msg_count      -- Error message count
  ||     x_msg_data       -- Error message
  ||     x_contract_tbl   -- Search results contract table
  ||
  || In Out Parameters:
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */
  PROCEDURE cntrct_srch_rslts(
    p_contract_number       IN  VARCHAR2,
    p_contract_status_code  IN  VARCHAR2,
    p_start_date_from       IN  DATE,
    p_start_date_to         IN  DATE,
    p_end_date_from         IN  DATE,
    p_end_date_to           IN  DATE,
    p_date_terminated_from  IN  DATE,
    p_date_terminated_to    IN  DATE,
    p_contract_party_id     IN  NUMBER,
    p_covlvl_site_id        IN  NUMBER,
    p_covlvl_site_name      IN  VARCHAR2,
    p_covlvl_system_id      IN  NUMBER,
    p_covlvl_system_name    IN  VARCHAR2,
    p_covlvl_product_id     IN  NUMBER,
    p_covlvl_product_name   IN  VARCHAR2,
    p_covlvl_item_id        IN  NUMBER,
    p_covlvl_item_name      IN  VARCHAR2,
    p_entitlement_check_YN  IN  VARCHAR2,
    p_account_check_all     IN  VARCHAR2,
    p_account_id            IN  VARCHAR2,
    p_covlvl_party_id       IN  VARCHAR2,
    p_account_all_id        IN  OKS_ENTITLEMENTS_WEB.account_all_id_tbl_type,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    x_contract_tbl          OUT NOCOPY OKS_ENTITLEMENTS_WEB.output_tbl_contract
  );

  /*
  ||==========================================================================
  || PROCEDURE: party_sites
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure is invoked in the Entitlement Search JSP.
  ||     This procedure is used to retrieve the Party Sites for a given party.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_party_id_arg   -- PartyID for which the Sites are to retrieved.
  ||     p_site_name_arg  -- Partial or full Name of the Party Site.
  ||
  || Out Parameters:
  ||     x_return_status        -- Success of the procedure.
  ||     x_party_sites_tbl_type -- Table whcih returns all the Party Sites
  ||                               and their information.
  ||
  || In Out Parameters:
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */
  PROCEDURE party_sites(
    p_party_id_arg         IN  VARCHAR2,
    p_site_name_arg        IN  VARCHAR2,
    x_return_status	       OUT NOCOPY VARCHAR2,
    x_party_sites_tbl_type OUT NOCOPY OKS_ENTITLEMENTS_WEB.party_sites_tbl_type
  );

  /*
  ||==========================================================================
  || PROCEDURE: duration_unit
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||             A funtion to retrieve duration unit in between 2 dates.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_start_date -- start date of duration
  ||     p_end_date   -- end date of duration
  ||
  || Return:
  ||        Time unit as a string.
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */
  FUNCTION duration_period(
    p_start_date IN  DATE,
    p_end_date   IN  DATE
  ) RETURN NUMBER;

  /*
  ||==========================================================================
  || PROCEDURE: duration_unit
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||             A funtion to retrieve duration period in between 2 dates.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_start_date -- start date of duration
  ||     p_end_date   -- end date of duration
  ||
  || Return:
  ||        Time period as a number.
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */
  FUNCTION duration_unit(
    p_start_date IN  DATE,
    p_end_date   IN  DATE
  ) RETURN VARCHAR2;


  /*
  ||==========================================================================
  || PROCEDURE: party_items
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure is invoked in the Entitlement Search JSP.
  ||     This procedure is used to retrieve the Party Items.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_party_id_arg   -- PartyID for which the Items are to retrieved.
  ||     p_item_name_arg  -- Partial or full Name of the Party Item.
  ||
  || Out Parameters:
  ||     x_return_status        -- Success of the procedure.
  ||     x_party_items_tbl_type -- Table which returns all the Party items
  ||                               and their information.
  ||
  || In Out Parameters:
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */
  PROCEDURE party_items(
    p_party_id_arg         IN  VARCHAR2,
    p_item_name_arg        IN  VARCHAR2,
    x_return_status	   OUT NOCOPY VARCHAR2,
    x_party_items_tbl_type OUT NOCOPY OKS_ENTITLEMENTS_WEB.party_items_tbl_type
  );

  /*
  ||==========================================================================
  || PROCEDURE: party_systems
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure is invoked in the Entitlement Search JSP.
  ||     This procedure is used to retrieve the Party Systems for a given party.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_party_id_arg     -- PartyID for which the Systems are to retrieved.
  ||     p_account_id_all   -- AccountID's for all the Systems to retrieved.
  ||     p_system_name_arg  -- Partial or full Name of the Party System.
  ||
  || Out Parameters:
  ||     x_return_status          -- Success of the procedure.
  ||     x_party_systems_tbl_type -- Table which returns all the Party items
  ||                                 and their information.
  ||
  || In Out Parameters:
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */
  PROCEDURE party_systems(
    p_party_id_arg           IN  VARCHAR2,
    p_account_id_all         IN  OKS_ENTITLEMENTS_WEB.account_all_id_tbl_type,
    p_system_name_arg        IN  VARCHAR2,
    x_return_status	         OUT NOCOPY VARCHAR2,
    x_party_systems_tbl_type OUT NOCOPY OKS_ENTITLEMENTS_WEB.party_systems_tbl_type
  );

  /*
  ||==========================================================================
  || PROCEDURE: party_products
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure is invoked in the Entitlement Search JSP.
  ||     This procedure is used to retrieve the Party Products for a given party.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_party_id_arg      -- PartyID for which the Products are to retrieved.
  ||     p_account_id_all    -- AccountID's for all the Products to be retrieved.
  ||     p_product_name_arg  -- Partial or full Name of the Party Product.
  ||
  || Out Parameters:
  ||     x_return_status           -- Success of the procedure.
  ||     x_party_products_tbl_type -- Table which returns all the Party Products
  ||                                  and their information.
  ||
  || In Out Parameters:
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */
  PROCEDURE party_products(
    p_party_id_arg            IN  VARCHAR2,
    p_account_id_all          IN  OKS_ENTITLEMENTS_WEB.account_all_id_tbl_type,
    p_product_name_arg        IN  VARCHAR2,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_party_products_tbl_type OUT NOCOPY OKS_ENTITLEMENTS_WEB.party_products_tbl_type
  );

  /*
  ||==========================================================================
  || PROCEDURE: adv_search_overview
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure is invoked in the Entitlement Search JSP.
  ||     This procedure is used to retrieve the Contract Categories and Statuses.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_party_id_arg  -- User Party ID.
  ||
  || Out Parameters:
  ||     x_return_status            -- Success of the procedure.
  ||     x_party_name               -- User Party Name.
  ||     x_contract_cat_tbl_type    -- Table which returns all the Contract Categories.
  ||     x_contract_status_tbl_type -- Table which returns all the Contract Statuses.
  ||
  || In Out Parameters:
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */
  PROCEDURE adv_search_overview(
    p_party_id_arg             IN  VARCHAR2,
    x_return_status	           OUT NOCOPY VARCHAR2,
    x_party_name               OUT NOCOPY VARCHAR2,
    x_contract_cat_tbl_type	   OUT NOCOPY OKS_ENTITLEMENTS_WEB.contract_cat_tbl_type,
    x_contract_status_tbl_type OUT NOCOPY OKS_ENTITLEMENTS_WEB.contract_status_tbl_type
  );

  /*
  ||==========================================================================
  || PROCEDURE: contract_number_overview
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure is invoked in the Entitlement Contract Overview JSP.
  ||     This procedure is used to retrieve the Contract information
  ||     and all the Lines and Parties given the Contract Number and Modifier.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_contract_number_arg   -- Contract Number
  ||     p_contract_modifier_arg -- Contract Modifer
  ||
  || Out Parameters:
  ||     x_return_status     -- Success of the procedure.
  ||     x_hdr_rec_type      -- Record that contains all the Contract Header information
  ||     x_hdr_addr_rec_type -- Record that contains the Billing and Shipping
  ||                            Address of the Contract
  ||     x_party_tbl_type    -- Table that contains all the Contract Parties information
  ||     x_line_tbl_type     -- Table that contains all the Contract Lines information
  ||
  || In Out Parameters:
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */
  PROCEDURE contract_number_overview(
    p_contract_number_arg   IN  VARCHAR2,
    p_contract_modifier_arg IN  VARCHAR2,
    x_return_status	        OUT NOCOPY VARCHAR2,
    x_hdr_rec_type	        OUT NOCOPY OKS_ENTITLEMENTS_WEB.hdr_rec_type,
    x_hdr_addr_rec_type     OUT NOCOPY OKS_ENTITLEMENTS_WEB.hdr_addr_rec_type,
    x_party_tbl_type        OUT NOCOPY OKS_ENTITLEMENTS_WEB.party_tbl_type,
    x_line_tbl_type         OUT NOCOPY OKS_ENTITLEMENTS_WEB.line_tbl_type
  );

  /*
  ||==========================================================================
  || PROCEDURE: contract_overview
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure is invoked in the Entitlement Contract Overview JSP.
  ||     This procedure is used to retrieve the Contract information
  ||     and all the Lines and Parties given the Contract ID
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_contract_id_arg -- Contract ID
  ||
  || Out Parameters:
  ||     x_return_status     -- Success of the procedure.
  ||     x_hdr_rec_type      -- Record that contains all the Contract Header information
  ||     x_hdr_addr_rec_type -- Record that contains the Billing and Shipping
  ||                            Address of the Contract
  ||     x_party_tbl_type    -- Table that contains all the Contract Parties information
  ||     x_line_tbl_type     -- Table that contains all the Contract Lines information
  ||
  || In Out Parameters:
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */
  PROCEDURE contract_overview(
    p_contract_id_arg   IN  VARCHAR2,
    x_return_status	    OUT NOCOPY VARCHAR2,
    x_hdr_rec_type	    OUT NOCOPY OKS_ENTITLEMENTS_WEB.hdr_rec_type,
    x_hdr_addr_rec_type OUT NOCOPY OKS_ENTITLEMENTS_WEB.hdr_addr_rec_type,
    x_party_tbl_type    OUT NOCOPY OKS_ENTITLEMENTS_WEB.party_tbl_type,
    x_line_tbl_type     OUT NOCOPY OKS_ENTITLEMENTS_WEB.line_tbl_type
  );

  /*
  ||==========================================================================
  || PROCEDURE: party_overview
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure is invoked in the Entitlement Party Details JSP.
  ||     This procedure is used to retrieve the Contact information of a given Party
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_contract_id_arg    -- Contract ID of the Contract to which the Party belongs
  ||     p_party_rle_code_arg -- Party Code
  ||
  || Out Parameters:
  ||     x_return_status          -- Success of the procedure.
  ||     x_party_contact_tbl_type -- Table that contains all the Contact information of a given Party
  ||
  || In Out Parameters:
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */
  PROCEDURE party_overview(
    p_contract_id_arg        IN  VARCHAR2,
    p_party_rle_code_arg     IN  VARCHAR2,
    x_return_status	         OUT NOCOPY VARCHAR2,
    x_party_contact_tbl_type OUT NOCOPY OKS_ENTITLEMENTS_WEB.party_contact_tbl_type
  );

  /*
  ||==========================================================================
  || PROCEDURE: party_contacts_overview
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure is invoked in the Entitlement Party Contact Details JSP.
  ||     This procedure is used to retrieve the Contact Details information of a given Contact
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_contact_id_arg -- Contact ID
  ||
  || Out Parameters:
  ||     x_return_status           -- Success of the procedure.
  ||     x_pty_cntct_dtls_tbl_type -- Table that contains all the Contact Details
  ||                                  information of a given Contact
  ||
  || In Out Parameters:
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */
  PROCEDURE party_contacts_overview(
    p_contact_id_arg          IN  VARCHAR2,
    x_return_status	          OUT NOCOPY VARCHAR2,
    x_pty_cntct_dtls_tbl_type OUT NOCOPY OKS_ENTITLEMENTS_WEB.pty_cntct_dtls_tbl_type
  );

  /*
  ||==========================================================================
  || PROCEDURE: line_overview
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure is invoked in the Entitlement Line Details JSP.
  ||     This procedure is used to retrieve the Line information for a given Line and
  ||     also the Covered Levels and Customer Contacts information for the Line.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_line_id_arg -- Line ID
  ||
  || Out Parameters:
  ||     x_return_status          -- Success of the procedure.
  ||     x_line_hdr_rec_type      -- Record that contains all the Line information
  ||     x_covered_level_tbl_type -- Table that contains all the Covered Levels information
  ||                                 for the given Line
  ||     x_cust_contacts_tbl_type -- Table that contains all the Customer Contacts information
  ||                                 for the given Line
  ||
  || In Out Parameters:
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */
  PROCEDURE line_overview(
    p_line_id_arg            IN  VARCHAR2,
    x_return_status	         OUT NOCOPY VARCHAR2,
    x_line_hdr_rec_type      OUT NOCOPY OKS_ENTITLEMENTS_WEB.line_hdr_rec_type,
    x_covered_level_tbl_type OUT NOCOPY OKS_ENTITLEMENTS_WEB.covered_level_tbl_type,
    x_cust_contacts_tbl_type OUT NOCOPY OKS_ENTITLEMENTS_WEB.cust_contacts_tbl_type
  );

  /*
  ||==========================================================================
  || PROCEDURE: coverage_overview
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure is invoked in the Entitlement Coverage Details JSP.
  ||     This procedure is used to retrieve the Coverage information for a given Coverage and
  ||     also the Business Processes information for the Coverage.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_contract_ID_arg -- Contract ID of the Line to which the Coverage belongs
  ||     p_coverage_ID_arg -- Coverage ID
  ||
  || Out Parameters:
  ||     x_return_status     -- Success of the procedure.
  ||     x_coverage_rec_type -- Record that contains all the Coverage information
  ||     x_bus_proc_tbl_type -- Table that contains all the Business Processes information
  ||                            for the given Coverage
  ||
  || In Out Parameters:
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */
  PROCEDURE coverage_overview(
    p_coverage_ID_arg   IN  VARCHAR2,
    p_contract_ID_arg   IN  VARCHAR2,
    x_return_status	    OUT NOCOPY VARCHAR2,
    x_coverage_rec_type OUT NOCOPY OKS_ENTITLEMENTS_WEB.coverage_rec_type,
    x_bus_proc_tbl_type OUT NOCOPY OKS_ENTITLEMENTS_WEB.bus_proc_tbl_type
  );

  /*
  ||==========================================================================
  || PROCEDURE: bus_proc_overview
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure is invoked in the Entitlement Business Process Details JSP.
  ||     This procedure is used to retrieve the Business Process information for a
  ||     given Line Business Process also the Reaction Times, Resolution Times,
  ||     Billing Types, Coverage Times and Preferred Resources information for
  ||     the given Business Process.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_contract_ID_arg -- Contract ID of the Line to which the Coverage
  ||                          and to which the Business Process belongs.
  ||     p_bus_proc_ID_arg -- Business Processes ID
  ||
  || Out Parameters:
  ||     x_return_status             -- Success of the procedure.
  ||     x_bus_proc_hdr_rec_type     -- Record that contains all the Business Processes information
  ||     x_coverage_times_tbl_type   -- Table that contains all the Coverage Times information
  ||                                    for the given Business Processes
  ||     x_reaction_times_tbl_type   -- Table that contains all the Reaction Times information
  ||                                    for the given Business Processes
  ||     x_resolution_times_tbl_type -- Table that contains all the Resolution Times information
  ||                                    for the given Business Processes
  ||     x_pref_resource_tbl_type    -- Table that contains all the Preferred Resources information
  ||                                    for the given Business Processes
  ||     x_bus_proc_bil_typ_tbl_type -- Table that contains all the Billing Types information
  ||                                    for the given Business Processes
  ||
  || In Out Parameters:
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */
  PROCEDURE bus_proc_overview(
    p_bus_proc_ID_arg           IN  VARCHAR2,
    p_contract_ID_arg           IN  VARCHAR2,
    x_return_status	            OUT NOCOPY VARCHAR2,
    x_bus_proc_hdr_rec_type     OUT NOCOPY OKS_ENTITLEMENTS_WEB.bus_proc_hdr_rec_type,
    x_coverage_times_tbl_type   OUT NOCOPY OKS_ENTITLEMENTS_WEB.coverage_times_tbl_type,
    x_reaction_times_tbl_type   OUT NOCOPY OKS_ENTITLEMENTS_WEB.reaction_times_tbl_type,
    x_resolution_times_tbl_type OUT NOCOPY OKS_ENTITLEMENTS_WEB.resolution_times_tbl_type,
    x_pref_resource_tbl_type    OUT NOCOPY OKS_ENTITLEMENTS_WEB.pref_resource_tbl_type,
    x_bus_proc_bil_typ_tbl_type OUT NOCOPY OKS_ENTITLEMENTS_WEB.bus_proc_bil_typ_tbl_type
  );

  /*
  ||==========================================================================
  || PROCEDURE: usage_overview
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure is invoked in the Entitlement Usage Details JSP.
  ||     This procedure is used to retrieve the Usage information for a given Usage Line and
  ||     also the Covered Products information for the Usage.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_line_id_arg -- Line ID
  ||
  || Out Parameters:
  ||     x_return_status          -- Success of the procedure.
  ||     x_usage_hdr_rec_type     -- Record that contains all the Usage Line information
  ||     x_covered_prods_tbl_type -- Table that contains all the Covered Products information
  ||                                 for the given Line
  ||
  || In Out Parameters:
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */
  PROCEDURE usage_overview(
    p_line_id_arg            IN  VARCHAR2,
    x_return_status	         OUT NOCOPY VARCHAR2,
    x_usage_hdr_rec_type     OUT NOCOPY OKS_ENTITLEMENTS_WEB.usage_hdr_rec_type,
    x_covered_prods_tbl_type OUT NOCOPY OKS_ENTITLEMENTS_WEB.covered_prods_tbl_type
  );

  /*
  ||==========================================================================
  || PROCEDURE: product_overview
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure is invoked in the Entitlement Product Details JSP.
  ||     This procedure is used to retrieve the Product information for a given Covered Product and
  ||     also the COunters information for the Covered Product.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_covered_prod_ID_arg -- Covered Product ID
  ||
  || Out Parameters:
  ||     x_return_status    -- Success of the procedure.
  ||     x_counter_tbl_type -- Table that contains all the Counters information
  ||                           for the given Product
  ||
  || In Out Parameters:
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */
  PROCEDURE product_overview(
    p_covered_prod_ID_arg IN  VARCHAR2,
    x_return_status	      OUT NOCOPY VARCHAR2,
    x_counter_tbl_type    OUT NOCOPY OKS_ENTITLEMENTS_WEB.counter_tbl_type
  );
END OKS_ENTITLEMENTS_WEB;

 

/
