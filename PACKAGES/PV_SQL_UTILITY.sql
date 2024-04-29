--------------------------------------------------------
--  DDL for Package PV_SQL_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_SQL_UTILITY" AUTHID CURRENT_USER as
/* $Header: pvsqluts.pls 120.3 2005/12/19 16:19:01 pklin ship $*/


-- ----------------------------------------------------------------------------
-- Public Procedures
-- ----------------------------------------------------------------------------

FUNCTION pv_lookup (
   p_lookup_code IN  VARCHAR2,
   p_lookup_type IN  VARCHAR2
)
RETURN VARCHAR2;

FUNCTION as_lookup (
   p_lookup_code IN  VARCHAR2,
   p_lookup_type IN  VARCHAR2
)
RETURN VARCHAR2;

FUNCTION ar_lookup (
   p_lookup_code IN  VARCHAR2,
   p_lookup_type IN  VARCHAR2
)
RETURN VARCHAR2;

FUNCTION fnd_lookup_values (
   p_lookup_code IN  VARCHAR2,
   p_lookup_type IN  VARCHAR2
)
RETURN VARCHAR2;

FUNCTION as_status (
   p_status_code IN  VARCHAR2
)
RETURN VARCHAR2;

FUNCTION aso_i_sales_channels (
   p_sales_channel_code IN  VARCHAR2
)
RETURN VARCHAR2;

FUNCTION as_sales_methodology (
   p_sales_methodology_id IN  NUMBER
)
RETURN VARCHAR2;

FUNCTION as_sales_stages_all (
   p_sales_stage_id IN  NUMBER
)
RETURN VARCHAR2;

FUNCTION as_sales_lead_ranks (
   p_rank_id IN  NUMBER
)
RETURN VARCHAR2;

FUNCTION fnd_territories (
   p_territory_code IN  VARCHAR2
)
RETURN VARCHAR2;

FUNCTION hz_location_country (
   p_party_site_id IN  NUMBER
)
RETURN VARCHAR2;

FUNCTION customer_contact_name (
   p_party_id IN  NUMBER
)
RETURN VARCHAR2;

FUNCTION customer_contact_email (
   p_party_id IN  NUMBER
)
RETURN VARCHAR2;

FUNCTION customer_contact_phone (
   p_party_id IN  NUMBER
)
RETURN VARCHAR2;


FUNCTION customer_contact_name2 (
   p_lead_id IN  NUMBER
)
RETURN VARCHAR2;

FUNCTION customer_contact_email2 (
   p_lead_id IN  NUMBER
)
RETURN VARCHAR2;

FUNCTION customer_contact_phone2 (
   p_lead_id IN  NUMBER
)
RETURN VARCHAR2;


FUNCTION referral_customer_address (
   p_referral_id IN  NUMBER
)
RETURN VARCHAR2;

FUNCTION jtf_resource (
   p_resource_id IN  NUMBER
)
RETURN VARCHAR2;

FUNCTION party_address (
   p_party_site_id IN  NUMBER
)
RETURN VARCHAR2;

FUNCTION party_address2 (
   p_location_id IN  NUMBER
)
RETURN VARCHAR2;

FUNCTION user_has_permission(p_contact_rel_party_id number, p_permission varchar2)
RETURN NUMBER;

end PV_SQL_UTILITY;

 

/
