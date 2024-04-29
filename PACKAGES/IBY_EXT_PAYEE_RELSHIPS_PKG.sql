--------------------------------------------------------
--  DDL for Package IBY_EXT_PAYEE_RELSHIPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_EXT_PAYEE_RELSHIPS_PKG" AUTHID CURRENT_USER AS
/*$Header: ibyprels.pls 120.4.12010000.1 2008/11/28 01:50:39 pschalla noship $*/

PROCEDURE print_debuginfo(
   p_message_text	IN varchar2
   );

PROCEDURE default_Ext_Payee_Relationship (
	   p_party_id IN  NUMBER,
	   p_supplier_site_id IN NUMBER,
	   p_date IN DATE,
	   x_remit_party_id IN OUT NOCOPY NUMBER,
	   x_remit_supplier_site_id IN OUT NOCOPY NUMBER,
	   x_relationship_id	IN OUT NOCOPY NUMBER
	  );

PROCEDURE import_Ext_Payee_Relationship (
	   p_party_id IN  NUMBER,
	   p_supplier_site_id IN NUMBER,
	   p_date IN DATE,
	   x_result  IN OUT NOCOPY VARCHAR2,
	   x_remit_party_id IN OUT NOCOPY NUMBER,
	   x_remit_supplier_site_id IN OUT NOCOPY NUMBER,
	   x_relationship_id	IN OUT NOCOPY NUMBER
	  );

END IBY_EXT_PAYEE_RELSHIPS_PKG;

/
