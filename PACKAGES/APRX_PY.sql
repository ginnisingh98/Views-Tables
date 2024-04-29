--------------------------------------------------------
--  DDL for Package APRX_PY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."APRX_PY" AUTHID CURRENT_USER as
/* $Header: aprxpys.pls 120.2.12010000.3 2009/09/16 12:38:44 skyadav ship $ */


--
-- Main AP Payment RX Report
procedure payment_register_run(
	p_payment_date_start in date,
	p_payment_date_end in date,
	p_payment_currency_code in varchar2,
	p_payment_bank_account_name in varchar2,
	p_payment_method in varchar2,
        p_payment_type_flag in varchar2,
	p_ledger_id     in  number,         /* bug8760710 */
	request_id	in	number,
	retcode	out NOCOPY	number,
	errbuf	out NOCOPY	varchar2) ;

--
-- Plug-in Payment Actual Report
procedure payment_actual_run(
	p_payment_date_start in date,
	p_payment_date_end in date,
	p_payment_currency_code in varchar2,
	p_payment_bank_account_name in varchar2,
	p_payment_method in varchar2,
        p_payment_type_flag in varchar2,
	p_ledger_id     in  number,         /* bug8760710 */
	request_id	in	number,
	retcode	out NOCOPY	number,
	errbuf	out NOCOPY	varchar2) ;


--
-- All event trigger procedures must be defined as public procedures
procedure register_before_report;
procedure register_bind(c in integer);
procedure actual_before_report;


--
-- This is the structre to hold the placeholder values
type var_t is record (
	ORGANIZATION_NAME 		VARCHAR2(240),
	FUNCTIONAL_CURRENCY_CODE	VARCHAR2(15),
	PAYMENT_NUMBER			NUMBER,
	PAYMENT_TYPE			VARCHAR2(20),
	PAYMENT_DOC_SEQ_NAME		VARCHAR2(30),
	PAYMENT_DOC_SEQ_VALUE		NUMBER,
	PAYMENT_DATE			DATE,
	PAYMENT_CURRENCY_CODE		VARCHAR2(15),
	ORIG_PAYMENT_AMOUNT		NUMBER,
	ORIG_PAYMENT_BASE_AMOUNT	NUMBER,
	PAYMENT_AMOUNT			NUMBER,
	PAYMENT_BASE_AMOUNT		NUMBER,
	PAYMENT_EXCHANGE_RATE		NUMBER,
	PAYMENT_EXCHANGE_DATE		DATE,
	PAYMENT_EXCHANGE_TYPE		VARCHAR2(30),
	PAYMENT_CLEARED_DATE		DATE,
	PAYMENT_CLEARED_AMOUNT		NUMBER,
	PAYMENT_CLEARED_BASE_AMOUNT	NUMBER,
	PAYMENT_CLEARED_EXC_RATE	NUMBER,
	PAYMENT_CLEARED_EXC_DATE	DATE,
	PAYMENT_CLEARED_EXC_TYPE	VARCHAR2(30),
	PAYMENT_FUTURE_PAY_DUE_DATE	DATE,
	PAYMENT_VOID_FLAG		VARCHAR2(10),
	PAYMENT_PAY_METHOD		VARCHAR2(25),
	PAYMENT_STATUS			VARCHAR2(50),
	PAYMENT_DOC_NAME		VARCHAR2(20),
	PAYMENT_DISBURSEMENT_TYPE	VARCHAR2(25),
	SUPPLIER_NAME			VARCHAR2(240),
	SUPPLIER_NAME_ALT		VARCHAR2(320),
	SUPPLIER_SITE_CODE		VARCHAR2(15),
	SUPPLIER_SITE_CODE_ALT		VARCHAR2(320),
	SUPPLIER_ADDRESS_LINE1		VARCHAR2(240),
	SUPPLIER_ADDRESS_LINE2		VARCHAR2(240),
	SUPPLIER_ADDRESS_LINE3		VARCHAR2(240),
	SUPPLIER_ADDRESS_ALT		VARCHAR2(560),
	SUPPLIER_CITY			AP_SUPPLIER_SITES_ALL.city%type, --6708281
	SUPPLIER_STATE			VARCHAR2(150),
	SUPPLIER_PROVINCE		VARCHAR2(150),
	SUPPLIER_POSTAL_CODE		AP_SUPPLIER_SITES_ALL.zip%type, --6708281
	SUPPLIER_COUNTRY		AP_SUPPLIER_SITES_ALL.country%type, --6708281
	SUPPLIER_TERRITORY		VARCHAR2(80),
	INT_BANK_NAME			VARCHAR2(60),
	INT_BANK_NAME_ALT		VARCHAR2(320),
	INT_BANK_NUMBER			VARCHAR2(30),
	INT_BANK_BRANCH_NAME		VARCHAR2(60),
	INT_BANK_BRANCH_NAME_ALT	VARCHAR2(320),
	INT_BANK_NUM			VARCHAR2(25),
	INT_BANK_ACCOUNT_NAME		VARCHAR2(80),
	INT_BANK_ACCOUNT_NAME_ALT	VARCHAR2(320),
	INT_BANK_ACCOUNT_NUM		VARCHAR2(30),
	INT_BANK_CURRENCY_CODE		VARCHAR2(15),
	INV_PAY_AMOUNT			NUMBER,
	INV_PAY_BASE_AMOUNT		NUMBER,
	INV_PAY_DISCOUNT_TAKEN		NUMBER,
	INVOICE_NUM			VARCHAR2(50),
	INVOICE_DATE			DATE,
	INVOICE_CURRENCY_CODE		VARCHAR2(15),
	INVOICE_AMOUNT			NUMBER,
	INVOICE_BASE_AMOUNT		NUMBER,
        INVOICE_DESCRIPTION		VARCHAR2(240)
);
var var_t;


end aprx_py;

/
