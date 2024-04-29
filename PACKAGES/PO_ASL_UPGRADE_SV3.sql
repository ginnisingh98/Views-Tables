--------------------------------------------------------
--  DDL for Package PO_ASL_UPGRADE_SV3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ASL_UPGRADE_SV3" AUTHID CURRENT_USER AS
/* $Header: POXA3LUS.pls 115.2 2002/11/25 19:43:55 sbull ship $*/

PROCEDURE get_split_multiplier(
	x_autosource_rule_id	IN	NUMBER,
	x_split_multiplier	IN OUT NOCOPY  NUMBER,
	x_add_percent		IN OUT NOCOPY  VARCHAR2
);

END PO_ASL_UPGRADE_SV3;

 

/
