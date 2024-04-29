--------------------------------------------------------
--  DDL for Package Body OKC_SALES_CLASS_QA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_SALES_CLASS_QA" AS
/* $Header: OKCRIQAB.pls 120.1 2005/10/04 19:59:31 smallya noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');


G_UNEXPECTED_ERROR              CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
G_SQLCODE_TOKEN                 CONSTANT VARCHAR2(200) := 'SQLCODE';
G_SQLERRM_TOKEN                 CONSTANT VARCHAR2(200) := 'SQLERRM';
G_PKG_NAME                      CONSTANT VARCHAR2(200) := 'OKC_SALES_CLASS_QA';
G_APP_NAME                      CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
g_okx_system_items_v            CONSTANT VARCHAR2(30)  := 'OKX_SYSTEM_ITEMS_V';
g_okx_customer_products_V       CONSTANT VARCHAR2(30)  := 'OKX_CUSTOMER_PRODUCTS_V';
g_okx_covered_lines_v           CONSTANT VARCHAR2(30)  := 'OKX_COVERED_LINES_V';
g_okx_product_lines_v           CONSTANT VARCHAR2(30)  := 'OKX_PRODUCT_LINES_V';
g_okx_organization_defs_v       CONSTANT VARCHAR2(30)  := 'OKX_ORGANIZATION_DEFS_V';
g_okx_legal_entities_v          CONSTANT VARCHAR2(30)  := 'OKX_LEGAL_ENTITIES_V';
g_okx_parties_v                 CONSTANT VARCHAR2(30)  := 'OKX_PARTIES_V';

g_sell_intent                            Varchar2(1)   := 'S';
g_can_rule                               varchar2(3)   := 'CAN';
g_exl_opn_rule                           varchar2(7)   := 'EXL_OPN';
kto_opn                                  varchar2(3)   := 'KTO';

/*************************************************************************************************************/
/*
-- Bug 2272261
 There are 2 profile options OKS Minimum Service Duration and
 OKS Minum Service Period to define what is the Minimum period of time for
 which service Item can be sold.This check was not there in  our QA process
 so If service line on contract had a duration less than the duration
 specified in OKS then order created from contract was having a wrong
 duration=Minimum period defined in OKS.

Following API takes care of it.
*/
Procedure check_service_duration(p_cle_id IN okc_K_lines_b.id%type,
                                 p_line_start_date okc_k_lines_b.start_date%type,
                                 p_line_number     okc_k_lines_b.line_number%type,
                                 x_return_status OUT NOCOPY VARCHAR2)
is
BEGIN
  NULL;
END;

/*************************************************************************************************************/

Function is_jtf_source_table(  p_object_code    jtf_objects_b.object_code%type,
                                p_from_table    JTF_OBJECTS_B.from_table%type
                             )

return boolean is
begin
   return false;
end;

/****************************************************************************************************/


Function get_line_style_source(  p_cle_id         IN okc_k_lines_b.id%type
                              )
return varchar2 is
begin
  return null;
end;

/*****************************************************************************************************************/

Function get_k_number(p_chr_id okc_k_headers_b.id%type )
return varchar2 is
 begin
 return 'X';
 end;

PROCEDURE validate_kto_integration( p_chr_id     IN  okc_k_headers_b.ID%TYPE,
                                    x_return_status   OUT NOCOPY VARCHAR2
        	                      	) is
BEGIN
   null;
END;
END OKC_SALES_CLASS_QA;

/
