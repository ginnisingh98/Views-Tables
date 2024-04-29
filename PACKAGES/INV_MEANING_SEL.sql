--------------------------------------------------------
--  DDL for Package INV_MEANING_SEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MEANING_SEL" AUTHID CURRENT_USER as
/* $Header: INVRPTMS.pls 120.0.12010000.2 2010/02/26 01:38:22 qyou ship $ */

FUNCTION C_MFG_LOOKUP(lookup_code_val number,lookup_type_val varchar2) RETURN varchar2;

FUNCTION C_UNIT_MEASURE(uom_code_val in varchar2) RETURN varchar2;

FUNCTION C_PO_UN_NUMB(un_number_val in number) RETURN varchar2;

FUNCTION C_PO_HAZARD_CLASS(hazard_val in number) RETURN varchar2;

FUNCTION C_PER_PEOPLE(person_id_val in number) RETURN varchar2;

FUNCTION C_LOOKUPS(lookup_code_val in varchar2,lookup_type_val in varchar2) RETURN varchar2;

FUNCTION C_PICK_RULES(pick_id_val in number) RETURN varchar2;

FUNCTION C_ATP_RULES(atp_id_val in number) RETURN varchar2;

FUNCTION C_ORG_NAME(org_id_val in number) RETURN VARCHAR2;

FUNCTION C_RA_RULES(rule_id_val in NUMBER) RETURN varchar2;

FUNCTION C_FND_LOOKUP_VL(lookup_code_val in varchar2,lookup_type_val in varchar2) RETURN varchar2;

FUNCTION C_RA_TERMS(term_id_val in NUMBER) RETURN varchar2;

FUNCTION C_PO_LOOKUP(lookup_code_val in varchar2,lookup_type_val in varchar2) RETURN varchar2;

FUNCTION C_FND_LOOKUP(lookup_code_val in varchar2,lookup_type_val in varchar2) RETURN varchar2;

FUNCTION C_LOT_LOOKUP(status_id_val in Number) RETURN varchar2;

FUNCTION C_SERIAL_LOOKUP(status_id_val in Number) RETURN varchar2;

FUNCTION C_UNITMEASURE(uom_code_val in Varchar2) RETURN varchar2;

FUNCTION C_FNDCOMMON(lookup_code_val in varchar2,lookup_type_val in varchar2) RETURN varchar2;

FUNCTION C_QTY_ON_HAND(Item_Id in Number,Org_Id in Number , Sub_Code in Varchar2, Break_Id in Number) RETURN Number;

FUNCTION C_ITEM_DESCRIPTION(Item_Id in Number , Org_Id in Number) RETURN varchar2;

FUNCTION C_ITEM_REV_DESCRIPTION(Item_Id in Number , Org_Id in Number , Rev_Id in Number) RETURN varchar2;

FUNCTION C_OE_LOOKUP(lookup_code_val in varchar2,lookup_type_val in varchar2) RETURN varchar2;

FUNCTION C_COVERAGE_SCHEDULE(COVERAGE_SCHEDULE_ID NUMBER) RETURN VARCHAR2;

FUNCTION C_ITEM_STATUS (status_code_val in varchar2) RETURN VARCHAR2; --Bug: 1968090

FUNCTION C_DEFAULT_MATERIAL_STATUS (status_code_val in varchar2) RETURN
VARCHAR2; --Bug: 8762354

END INV_MEANING_SEL;

/
