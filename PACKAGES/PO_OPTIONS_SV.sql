--------------------------------------------------------
--  DDL for Package PO_OPTIONS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_OPTIONS_SV" AUTHID CURRENT_USER AS
/* $Header: POXSTDPS.pls 115.1 2002/11/26 19:49:00 sbull ship $*/
PROCEDURE get_startup_values (
			po_install_status  	IN OUT NOCOPY  VARCHAR2,
			oe_install_status	IN OUT NOCOPY  VARCHAR2,
			inv_install_status	IN OUT	NOCOPY VARCHAR2,
			coa			IN OUT NOCOPY  NUMBER,
			inventory_org_id	IN OUT NOCOPY  NUMBER,
			currency_code		IN OUT NOCOPY  VARCHAR2,
			per_pos_grant_exists	IN OUT NOCOPY  VARCHAR2,
			doc_types_grant_exists	IN OUT NOCOPY  VARCHAR2,
			order_types_grant_exists 	IN OUT NOCOPY VARCHAR2,
			order_sources_grant_exists	IN OUT NOCOPY VARCHAR2,
			line_types_grant_exists		IN OUT NOCOPY VARCHAR2,
			psp_has_data			IN OUT NOCOPY BOOLEAN);

END;

 

/
