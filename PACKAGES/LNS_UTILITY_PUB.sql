--------------------------------------------------------
--  DDL for Package LNS_UTILITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_UTILITY_PUB" AUTHID CURRENT_USER AS
/*$Header: LNS_UTIL_PUBP_S.pls 120.6 2005/10/29 10:32:39 karamach noship $ */

FUNCTION created_by RETURN NUMBER;

FUNCTION creation_date RETURN DATE;

FUNCTION last_updated_by RETURN NUMBER;

FUNCTION last_update_date RETURN DATE;

FUNCTION last_update_login RETURN NUMBER;

FUNCTION request_id RETURN NUMBER;

FUNCTION program_id RETURN NUMBER;

FUNCTION program_application_id RETURN NUMBER;

FUNCTION application_id RETURN NUMBER;

FUNCTION program_update_date RETURN DATE;

FUNCTION user_id RETURN NUMBER;

/* added by raverma */
PROCEDURE Validate_any_id(p_api_version   IN  NUMBER := 1.0,
                          p_init_msg_list IN  VARCHAR2 := FND_API.G_FALSE,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2,
                          p_col_id        IN  NUMBER,
                          p_col_name      IN  VARCHAR2,
                          p_table_name    IN  VARCHAR2);

-- added raverma 01162002
PROCEDURE Validate_any_varchar(p_api_version   IN  NUMBER := 1.0,
                               p_init_msg_list IN  VARCHAR2 := FND_API.G_FALSE,
                               x_msg_count     OUT NOCOPY NUMBER,
                               x_msg_data      OUT NOCOPY VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                               p_col_value     IN  VARCHAR2,
                               p_col_name      IN  VARCHAR2,
                               p_table_name    IN  VARCHAR2);

PROCEDURE Validate_Lookup_CODE(p_api_version   IN  NUMBER := 1.0,
                               p_init_msg_list IN  VARCHAR2 := FND_API.G_FALSE,
                               x_msg_count     OUT NOCOPY NUMBER,
                               x_msg_data      OUT NOCOPY VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                               p_lookup_type   IN  VARCHAR2,
                               p_lookup_code   IN  VARCHAR2,
                               p_lookup_view   IN VARCHAR2 := 'LNS_LOOKUPS');

Procedure getObjectVersion(p_table_name     IN varchar2
                 ,p_primary_key_name    IN varchar2
                 ,p_primary_key_value   IN NUMBER
                 ,p_object_version_number IN NUMBER
                 ,x_object_version_number OUT NOCOPY NUMBER
                 ,x_msg_count           OUT NOCOPY NUMBER
                 ,x_msg_data            OUT NOCOPY VARCHAR2
                 ,x_return_status       OUT NOCOPY VARCHAR2);

FUNCTION get_lookup_meaning (p_lookup_type  IN VARCHAR2,
                             p_lookup_code  IN VARCHAR2)  RETURN VARCHAR2;

function convertAmount(p_from_amount   in number
                      ,p_from_currency in varchar2
                      ,p_to_currency   in varchar2
                      ,p_exchange_type in varchar2
                      ,p_exchange_date in date
                      ,p_exchange_rate in number) return number;

function convertRate(p_from_currency in varchar
                    ,p_to_currency   in varchar
                    ,p_exchange_date in date
                    ,p_exchange_type in varchar) return number;

function Check_PSA_Enabled_Org(p_org_id in number) return varchar2;

function Check_PSA_Enabled_Current_Org return varchar2;

function Check_PSA_Enabled_Loan(p_loan_id number) return varchar2;

function IS_CREDIT_MANAGEMENT_INSTALLED return varchar2;

function Check_Desc_Flex_Setup(p_desc_flex_name varchar2) return varchar2;

function getDocumentName(p_line_type in varchar2) return varchar2;

function Is_Loan_Manager_Role return varchar2 ;

function IS_FED_FIN_ENABLED(p_org_id IN NUMBER) return varchar2 ;

function IS_FED_FIN_ENABLED return varchar2 ;

TYPE t_lookups_table IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;

pg_lookups_rec t_lookups_table;

--This procedure refreshes the materialized view used for graphs
PROCEDURE refresh_mviews(ERRBUF                  OUT NOCOPY VARCHAR2
                        ,RETCODE                 OUT NOCOPY VARCHAR2
                        );

--This function checks if a concurrent program request is pending/running
--Returns 'N' if there are no pending/running requests for the conc program
FUNCTION is_concurrent_request_pending
  (p_application_short_name  IN VARCHAR2,
   p_concurrent_program_name IN VARCHAR2)
RETURN varchar2;

END LNS_UTILITY_PUB;

 

/
