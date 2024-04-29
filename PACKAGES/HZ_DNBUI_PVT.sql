--------------------------------------------------------
--  DDL for Package HZ_DNBUI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_DNBUI_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHDNBUS.pls 120.2 2005/10/30 03:51:51 appldev ship $*/

FUNCTION get_lookup_meaning (p_lookup_type  IN VARCHAR2,
                             p_lookup_code  IN VARCHAR2)
RETURN VARCHAR2;

function get_financial_number(p_financial_name IN VARCHAR2, p_financial_report_id NUMBER) RETURN NUMBER;

function get_financial_number_currency(
	p_financial_name IN VARCHAR2,
	p_financial_report_id NUMBER)
RETURN VARCHAR2;

function get_financial_number_actflg(
	p_financial_name IN VARCHAR2,
	p_financial_report_id NUMBER)
RETURN VARCHAR2;

function get_primary_phone_number(
	p_party_id IN NUMBER,
	p_source_type IN VARCHAR2)
RETURN VARCHAR2;

function get_primary_fax_number(
	p_party_id IN NUMBER,
	p_source_type IN VARCHAR2)
RETURN VARCHAR2;

function get_all_phone_numbers(
	p_party_id IN NUMBER,
	p_source_type IN VARCHAR2)
RETURN VARCHAR2;

function get_country_name(
	p_country_code IN VARCHAR2)
RETURN VARCHAR2;

function get_max_financial_report_id(
        p_party_id      		IN      NUMBER,
        p_type_of_financial_report	IN      VARCHAR2,
        p_actual_content_source   	IN      VARCHAR2)
RETURN NUMBER;

function get_max_credit_rating_id(
	p_party_id      	IN      NUMBER,
	p_actual_content_source   IN      VARCHAR2)
RETURN NUMBER;

/*
function get_currency_symbol(
	p_financial_name IN VARCHAR2,
	p_financial_report_id NUMBER)
RETURN VARCHAR2;
*/

function get_financial_symbol_number(
    p_financial_name IN VARCHAR2,
    p_financial_report_id NUMBER)
RETURN VARCHAR2;


function get_SIC_code(
    p_class_category IN VARCHAR2,
    p_party_id       IN NUMBER,
    p_sequence       IN NUMBER,
    p_actual_content_source IN VARCHAR2  := 'DNB'
    )
RETURN VARCHAR2;

function get_location_id (
    p_party_id IN NUMBER,
    p_actual_content_source in VARCHAR2)
RETURN NUMBER;

function get_first_available_report(
        p_party_id      		IN      NUMBER,
        p_actual_content_source		IN	VARCHAR2)
RETURN VARCHAR2;


END HZ_DNBUI_PVT;

 

/
