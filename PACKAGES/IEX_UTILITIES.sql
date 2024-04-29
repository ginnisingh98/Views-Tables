--------------------------------------------------------
--  DDL for Package IEX_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_UTILITIES" AUTHID CURRENT_USER AS
/* $Header: iexvutls.pls 120.15.12010000.7 2010/05/19 11:34:13 snuthala ship $ */

TYPE resource_rec_type IS RECORD (
  resource_id NUMBER,
  person_id NUMBER,
  user_id NUMBER,
  person_name VARCHAR2(360),
  user_name VARCHAR2(100));

TYPE resource_tab_type IS TABLE OF resource_Rec_type INDEX BY BINARY_INTEGER;

-- use for building dynamic where clauses
type Condition_REC is record (
   COL_NAME VARCHAR2(25),
   CONDITION VARCHAR2(5),
   VALUE     VARCHAR2(100));

type Condition_Tbl is table of Condition_REC
    index by binary_integer;

-- Table Of Delinquency Ids.
TYPE   t_del_id is TABLE of NUMBER
INDEX BY BINARY_INTEGER;

-- Table of varchar2(1)
TYPE   t_varchar1 is TABLE of Varchar2(1)
INDEX BY BINARY_INTEGER;

-- Table of Asset_ids
TYPE   t_asset_id is TABLE of Number
INDEX BY BINARY_INTEGER;

-- Table of del_children (Repo, Woff, Litg, Bank)
TYPE   t_del_children is TABLE of Number
INDEX BY BINARY_INTEGER;

-- Table of del_asset_id
TYPE   t_del_asset_id is TABLE of NUMBER
INDEX BY BINARY_INTEGER;

-- Table of Numbers
TYPE   t_numbers is TABLE of NUMBER
INDEX BY BINARY_INTEGER;




PROCEDURE ACCT_BALANCE
      (p_api_version      IN  NUMBER := 1.0,
       p_init_msg_list    IN  VARCHAR2,
       p_commit           IN  VARCHAR2,
       p_validation_level IN  NUMBER,
       x_return_status    OUT NOCOPY VARCHAR2,
       x_msg_count        OUT NOCOPY NUMBER,
       x_msg_data         OUT NOCOPY VARCHAR2,
	   p_cust_acct_id     IN  Number,
	   x_balance          OUT NOCOPY Number);

PROCEDURE Validate_any_id(p_api_version   IN  NUMBER := 1.0,
                          p_init_msg_list IN  VARCHAR2,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2,
                          p_col_id        IN  NUMBER,
                          p_col_name      IN  VARCHAR2,
                          p_table_name    IN  VARCHAR2);

-- added raverma 01162002
PROCEDURE Validate_any_varchar(p_api_version   IN  NUMBER := 1.0,
                               p_init_msg_list IN  VARCHAR2,
                               x_msg_count     OUT NOCOPY NUMBER,
                               x_msg_data      OUT NOCOPY VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                               p_col_value     IN  VARCHAR2,
                               p_col_name      IN  VARCHAR2,
                               p_table_name    IN  VARCHAR2);

PROCEDURE Validate_Lookup_CODE(p_api_version   IN  NUMBER := 1.0,
                               p_init_msg_list IN  VARCHAR2,
                               x_msg_count     OUT NOCOPY NUMBER,
                               x_msg_data      OUT NOCOPY VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                               p_lookup_type   IN  VARCHAR2,
                               p_lookup_code   IN  VARCHAR2,
                               p_lookup_view   IN VARCHAR2);
--Begin bug#5373412 schekuri 10-Jul-2006
--Removed the following procedures and added a single consolidate procedure get_assigned_collector
/*
-- added by jypark 03052002
PROCEDURE get_access_resources(p_api_version   IN  NUMBER := 1.0,
                               p_init_msg_list IN  VARCHAR2,
                               p_commit           IN  VARCHAR2,
                               p_validation_level IN  NUMBER,
                               x_msg_count     OUT NOCOPY NUMBER,
                               x_msg_data      OUT NOCOPY VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                               p_party_id      IN  VARCHAR2,
                               x_resource_tab  OUT NOCOPY resource_tab_type);
-- added by ehuh 02102003 based on kalis request
PROCEDURE get_assign_resources(p_api_version   IN  NUMBER := 1.0,
                               p_init_msg_list IN  VARCHAR2,
                               p_commit           IN  VARCHAR2,
                               p_validation_level IN  NUMBER,
                               x_msg_count     OUT NOCOPY NUMBER,
                               x_msg_data      OUT NOCOPY VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                               p_party_id      IN  VARCHAR2,
                               x_resource_tab  OUT NOCOPY resource_tab_type);

PROCEDURE get_assign_account_resources(p_api_version      IN  NUMBER := 1.0,
                               p_init_msg_list    IN  VARCHAR2,
                               p_commit           IN  VARCHAR2,
                               p_validation_level IN  NUMBER,
                               x_msg_count        OUT NOCOPY NUMBER,
                               x_msg_data         OUT NOCOPY VARCHAR2,
                               x_return_status    OUT NOCOPY VARCHAR2,
                               p_account_id         IN  VARCHAR2,
                               x_resource_tab     OUT NOCOPY resource_tab_type);

-- added by jsanju 12/22/2003 based on kalis request
PROCEDURE get_case_resources(p_api_version   IN  NUMBER := 1.0,
                               p_init_msg_list IN  VARCHAR2,
                               p_commit           IN  VARCHAR2,
                               p_validation_level IN  NUMBER,
                               x_msg_count     OUT NOCOPY NUMBER,
                               x_msg_data      OUT NOCOPY VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                               p_party_id      IN  VARCHAR2,
                               x_resource_tab  OUT NOCOPY resource_tab_type);*/
--End bug#5373412 schekuri 10-Jul-2006

/*
|| Overview:   builds a dynamic where clause based on name / condition / value array
||
|| Parameter:  array of name / condition / value like
||            'PARTY_NAME', '=', 'Anna Kournikova'
||            'AMOUNT_OVERDUE', '>=', '5000'
||
|| Return value: String with "Where party_name = 'Anna Kournikova' AND
||                                  amount_overdue >= 5000"
||
|| Source Tables: NA
||
|| Target Tables: NA
||
|| Creation date:  01/28/2003 5:53PM
||
|| Major Modifications: when              who                       what
||                      01/28/2003 5:53PM raverma                created
*/
function buildWhereClause(P_CONDITIONS IN IEX_UTILITIES.Condition_Tbl) return VARCHAR2;

-- Added by acaraujo 07/27/2004 -
-- This procedure will return access to a bill to site use instead of party_id
-- this assumes use of the script to transfer collector from customer profiles
-- to as_accesses, this will place the site_use_id into the attribute1 column

--Begin bug#5373412 schekuri 10-Jul-2006
--Removed the following procedures and added a single consolidate procedure get_assigned_collector
/*PROCEDURE get_billto_resources(p_api_version      IN  NUMBER := 1.0,
                               p_init_msg_list    IN  VARCHAR2,
                               p_commit           IN  VARCHAR2,
                               p_validation_level IN  NUMBER,
                               x_msg_count        OUT NOCOPY NUMBER,
                               x_msg_data         OUT NOCOPY VARCHAR2,
                               x_return_status    OUT NOCOPY VARCHAR2,
                               p_site_use_id      IN  VARCHAR2,
                               x_resource_tab     OUT NOCOPY resource_tab_type);*/

--Added the following procedure to consolidate the functionality of procedures
--get_billto_resources, get_assign_account_resources, get_assign_resources and get_access_resources
--into a single procedure.

PROCEDURE get_assigned_collector(p_api_version    IN  NUMBER := 1.0,
                               p_init_msg_list    IN  VARCHAR2,
                               p_commit           IN  VARCHAR2,
                               p_validation_level IN  NUMBER,
                               p_level            IN  VARCHAR2,
                               p_level_id         IN  VARCHAR2,
                               x_msg_count        OUT NOCOPY NUMBER,
                               x_msg_data         OUT NOCOPY VARCHAR2,
                               x_return_status    OUT NOCOPY VARCHAR2,
                               x_resource_tab     OUT NOCOPY resource_tab_type);

--End bug#5373412 schekuri 10-Jul-2006


-- End- Andre 07/28/2004 - Add bill to assignmnet

PROCEDURE get_dunning_resource(p_api_version    IN  NUMBER := 1.0,
                               p_init_msg_list    IN  VARCHAR2,
                               p_commit           IN  VARCHAR2,
                               p_validation_level IN  NUMBER,
                               p_level            IN  VARCHAR2,
                               p_level_id         IN  VARCHAR2,
                               x_msg_count        OUT NOCOPY NUMBER,
                               x_msg_data         OUT NOCOPY VARCHAR2,
                               x_return_status    OUT NOCOPY VARCHAR2,
                               x_resource_tab     OUT NOCOPY resource_tab_type);

PROCEDURE get_grace_days (p_api_version    IN  NUMBER := 1.0,
                               p_init_msg_list    IN  VARCHAR2,
                               p_commit           IN  VARCHAR2,
                               p_validation_level IN  NUMBER,
                               p_level            IN  VARCHAR2,
			       p_party_id         IN  NUMBER,
			       p_account_id       IN  NUMBER,
			       p_site_use_id      IN  NUMBER,
                               x_msg_count        OUT NOCOPY NUMBER,
                               x_msg_data         OUT NOCOPY VARCHAR2,
                               x_return_status    OUT NOCOPY VARCHAR2,
                               x_grace_days       OUT NOCOPY NUMBER);

TYPE t_lookups_table IS TABLE OF VARCHAR2(80)
      INDEX BY BINARY_INTEGER;

pg_lookups_rec t_lookups_table;

TYPE INC_INV_CURR_TBL IS TABLE OF VARCHAR2(80)
      INDEX BY BINARY_INTEGER;

l_inc_inv_curr INC_INV_CURR_TBL;

FUNCTION get_lookup_meaning (p_lookup_type  IN VARCHAR2,
                             p_lookup_code  IN VARCHAR2)
 RETURN VARCHAR2;
-- End- Andre 09/15/2004 - Function to get lookup meaning - performance enhancement as per Ramakant Alat

-- Begin- jypark 09/22/2004 - Function to get parameter value

TYPE t_param_tab_type IS TABLE OF VARCHAR2(32000)
      INDEX BY BINARY_INTEGER;

pg_param_tab t_param_tab_type;


-- Begin- Andre 11/22/2005 - bug4740016 - Cache for SQL populated data.
pg_iexcache_rec t_lookups_table;
FUNCTION get_cache_value (p_Identifier  IN VARCHAR2,
                          p_PopulateSql IN VARCHAR2)
 RETURN VARCHAR2;
-- End- Andre 11/22/2005 - bug4740016 - Cache for SQL populated data.


PROCEDURE put_param_value (p_param_value  IN VARCHAR2,
                          p_param_key  OUT NOCOPY NUMBER);

PROCEDURE get_param_value(p_param_key IN NUMBER,
                          p_param_value OUT NOCOPY VARCHAR2);

PROCEDURE delete_param_value(p_param_key IN NUMBER);

-- End- jypark 09/22/2004 - Function to get parameter value

/*
   Overview : check if the dunning letter flag before send out a dunning letter
              It checks the billto level first then account level; at last customer level.
   Parameter: p_party_id:  if customer level then pass the party_id
              p_cust_account_id : if account level then pass the cust_account_id
              p_site_use_id : if bill_to level then pass the customer_site_use_id
              p_delinquency_id : if delinquency level then pass the delinquency_id
   Return:  'Y' if ok to send dunning letter
            'N' if no dunning letter should be sent
   creation date: 06/02/2004
   author:  ctlee
*/
FUNCTION DunningProfileCheck
(
  p_party_id           IN  number
  , p_cust_account_id    IN  number
  , p_site_use_id        IN  number
  , p_delinquency_id     IN  number
)
return varchar2 ;

/*
    Overview: This function is to determine if the required min_dunning and min_invoice_dunning amount are
              met before sending the dunning letter.
   Parameter: p_cust_account_id : if account level then pass the cust_account_id
              p_site_use_id : if bill_to level then pass the customer_site_use_id
   Return:  'Y' if ok to send dunning letter
            'N' if no dunning letter should be sent
   creation date: 06/02/2004
   author:  ctlee
   Note: it is not available in the customer level
 */
FUNCTION DunningMinAmountCheck
(
  p_cust_account_id    IN  number
  , p_site_use_id        IN  number
)
return varchar2 ;

Procedure StagedDunningMinAmountCheck
(
  p_cust_account_id         IN  number
  , p_site_use_id           IN  number
  , p_party_id              IN number
  , p_dunning_plan_id       IN number
  , p_grace_days            IN number
  , p_dun_disputed_items    IN VARCHAR2
  , p_correspondence_date   IN DATE
  , p_running_level         IN VARCHAR2
  , p_inc_inv_curr          OUT NOCOPY INC_INV_CURR_TBL
  , p_dunning_letters       OUT NOCOPY varchar2
);

Procedure MaxStageForanDelinquency (  p_delinquency_id   IN  number
                                    , p_stage_number     OUT NOCOPY number);

Procedure WriteLog      (  p_msg                     IN VARCHAR2);

--Begin bug#4368394 schekuri 30-Nov-2005
--Added the following to provide a way to get the view by level of collections header
--in the database view itself
PROCEDURE SET_VIEW_BY_LEVEL(p_view_by in VARCHAR2);

FUNCTION GET_VIEW_BY_LEVEL RETURN VARCHAR2;

--End bug#4368394 schekuri 30-Nov-2005

--Begin bug#4773082 ctlee 1-Dec-2005 performance issue
FUNCTION get_amount_due_remaining (p_customer_trx_id  IN number)
 RETURN number;
--End bug#4773082 ctlee 1-Dec-2005


--Begin bug#4864641 ctlee 6-Dec-2005 performance issue
FUNCTION get_amount_due_original (p_customer_trx_id  IN number)
 RETURN number;
--End bug#4864641 ctlee 6-Dec-2005 performance issue

--Begin bug 6723556 gnramasa 11th Jan 08
FUNCTION CheckContractStatus
(
  p_contract_number    IN  VARCHAR2
)
return varchar2 ;
--End bug 6723556 gnramasa 11th Jan 08

--Begin bug 6627832 gnramasa 21st Jan 08
FUNCTION ValidateXMLRequestId
(
  p_xml_request_id    IN  number

)
return boolean;
--End bug 6627832 gnramasa 21st Jan 08

--Begin bug 6717279 by gnramasa 25th Aug 08
p_be_cust_acct_rec t_numbers;
Procedure copy_cust_acct_value
 (
   p_fe_cust_acct_rec IN DBMS_SQL.NUMBER_TABLE
 );

FUNCTION cust_acct_id_check
(
  p_cust_acct_id    IN  number
)
return varchar;
--End bug 6717279 by gnramasa 25th Aug 08
--Begin bug#6717849 by schekuri 27-Jul-2009
--Created for multi level strategy enhancement
FUNCTION VALIDATE_RUNNING_LEVEL
(
      p_running_level IN  varchar2
)
return varchar2;

FUNCTION GET_PARTY_RUNNING_LEVEL
(
      p_party_id IN  NUMBER,
      p_org_id IN NUMBER DEFAULT NULL
)
return varchar2;
--End bug#6717849 by schekuri 27-Jul-2009

Function Get_Manager_role(p_user_id in number) return varchar2;

Function Delete_delinquncies(p_transaction_id number) return varchar2;

END;

/
