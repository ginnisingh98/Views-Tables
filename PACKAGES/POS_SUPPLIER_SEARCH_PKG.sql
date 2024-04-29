--------------------------------------------------------
--  DDL for Package POS_SUPPLIER_SEARCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_SUPPLIER_SEARCH_PKG" AUTHID CURRENT_USER AS
-- $Header: POS_SUPPLIER_SEARCH_PKG.pls 120.0.12010000.2 2013/02/07 10:56:39 irasoolm noship $

g_fnd_debug          CONSTANT VARCHAR2(1)  := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
g_pkg_name           CONSTANT VARCHAR2(50) := 'POS_SUPPLIER_SEARCH_PKG';
g_module_prefix      CONSTANT VARCHAR2(50) := 'pon.plsql.' || g_pkg_name || '.';

TYPE vendor_tbl IS TABLE OF NUMBER;

TYPE typTokenTab IS TABLE OF VARCHAR(1000) INDEX BY BINARY_INTEGER;

FUNCTION generate_uda_xml(p_party_id IN NUMBER,
                           p_party_site_id IN NUMBER,
                           p_vendor_site_id IN NUMBER)
RETURN xmltype;

PROCEDURE index_supplier (p_all_suppliers IN VARCHAR2,
                          EFFBUF           OUT NOCOPY VARCHAR2,
                          RETCODE          OUT NOCOPY VARCHAR2);

PROCEDURE generate_supplier_xml(p_party_id IN NUMBER,
                                p_vendor_id IN NUMBER,
                                x_result OUT NOCOPY VARCHAR2,
                                x_msg OUT NOCOPY VARCHAR2 );

PROCEDURE search_supplier ( p_keyword IN VARCHAR2,
                            x_record_found IN OUT NOCOPY VARCHAR2,
                            x_search_string IN OUT NOCOPY VARCHAR2 );

FUNCTION creTokenList(pLine IN VARCHAR2, pDelimiter IN VARCHAR2) RETURN typTokenTab;

PROCEDURE has_supplier_changed(vendors IN OUT NOCOPY vendor_tbl);

PROCEDURE print_log
  (
    p_message IN VARCHAR2 );

END pos_supplier_search_pkg;

/
