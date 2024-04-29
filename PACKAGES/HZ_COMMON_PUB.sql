--------------------------------------------------------
--  DDL for Package HZ_COMMON_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_COMMON_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHCOMMS.pls 120.2 2005/10/30 04:18:12 appldev ship $ */

procedure commit_transaction;

procedure rollback_transaction;

function is_TCA_installed RETURN BOOLEAN;

procedure validate_lookup(
        p_lookup_type           IN      VARCHAR2,
        p_column                IN      VARCHAR2,
        p_column_value          IN      VARCHAR2,
        x_return_status         IN OUT NOCOPY     VARCHAR2
);

PROCEDURE validate_fnd_lookup(
        p_lookup_type   IN     VARCHAR2,
        p_column        IN     VARCHAR2,
        p_column_value  IN     VARCHAR2,
        x_return_status IN OUT NOCOPY VARCHAR2
);

function get_account_number RETURN NUMBER;
function get_party_site_number RETURN NUMBER;


function content_source_type_security(
	p_object_schema		IN 	VARCHAR2,
	p_object_name		IN	VARCHAR2
) RETURN VARCHAR2;


procedure enable_cont_source_security;

procedure disable_cont_source_security;

function get_cust_address(v_address_id in number) return varchar2;
PRAGMA RESTRICT_REFERENCES (get_cust_address,WNDS,WNPS,RNPS);

function get_cust_name(v_cust_id in number) return varchar2;
PRAGMA RESTRICT_REFERENCES (get_cust_name,WNDS,WNPS,RNPS);

function get_cust_contact_name(v_contact_id in number) return varchar2;
PRAGMA RESTRICT_REFERENCES (get_cust_contact_name,WNDS,WNPS,RNPS);

function get_party_name(v_party_id in number) return varchar2;
PRAGMA RESTRICT_REFERENCES (get_party_name,WNDS,WNPS,RNPS);

procedure check_mandatory_str_col(
	create_update_flag		IN  VARCHAR2,
	p_col_name 				IN  VARCHAR2,
	p_col_val				IN  VARCHAR2,
	p_miss_allowed_in_c		IN  BOOLEAN,
	p_miss_allowed_in_u		IN  BOOLEAN,
	x_return_status			IN OUT NOCOPY VARCHAR2
);

procedure check_mandatory_date_col(
	create_update_flag		IN  VARCHAR2,
	p_col_name 				IN	VARCHAR2,
	p_col_val				IN  DATE,
	p_miss_allowed_in_c		IN  BOOLEAN,
	p_miss_allowed_in_u		IN  BOOLEAN,
	x_return_status			IN OUT NOCOPY VARCHAR2
);

procedure check_mandatory_num_col(
	create_update_flag		IN  VARCHAR2,
	p_col_name 				IN	VARCHAR2,
	p_col_val				IN  NUMBER,
	p_miss_allowed_in_c		IN  BOOLEAN,
	p_miss_allowed_in_u		IN  BOOLEAN,
	x_return_status			IN OUT NOCOPY VARCHAR2
);

  FUNCTION time_compare(datetime1 IN DATE, datetime2 IN DATE) RETURN NUMBER;
  FUNCTION is_time_between (
    datetimex   IN      DATE,
    datetime1   IN      DATE,
    datetime2   IN      DATE
  ) RETURN BOOLEAN;
  FUNCTION is_time_overlap (
    s1          IN      DATE,
    e1          IN      DATE,
    s2          IN      DATE,
    e2          IN      DATE
  ) RETURN VARCHAR2;


FUNCTION compare
(date1 DATE,
 date2 DATE)
RETURN NUMBER;

-- NULL indicates infinite
FUNCTION is_between
(datex DATE,
 date1 DATE,
 date2 DATE)
RETURN BOOLEAN;

FUNCTION is_overlap
-- Returns 'Y' if period [s1,e1] overlaps [s2,e2]
--         'N' otherwise
--         NULL indicates infinite for end dates
(s1 DATE,
 e1 DATE,
 s2 DATE,
 e2 DATE)
RETURN VARCHAR2;

FUNCTION cleanse
-- Return varchar2 with a set of characters non desired.
( str IN varchar2)
RETURN varchar2;
--BugNo:3071968--
PROCEDURE enable_health_care_security;
PROCEDURE disable_health_care_security;
PROCEDURE add_hcare_policy_function;
PROCEDURE drop_hcare_policy_function;
FUNCTION hcare_created_by_module_sec(p_object_schema IN  VARCHAR2,
                                     p_object_name IN VARCHAR2)
RETURN VARCHAR2;

--End of bugNo:3171968

END;

 

/
