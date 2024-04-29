--------------------------------------------------------
--  DDL for Package POS_ASN_REVIEW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_ASN_REVIEW_PKG" AUTHID CURRENT_USER AS
/* $Header: POSASNRS.pls 115.0 99/08/20 11:08:39 porting sh $ */

g_temp_table        ak_query_pkg.results_table_type;

PROCEDURE review_page(p_submit IN VARCHAR2 DEFAULT 'N');

END pos_asn_review_pkg;

 

/
