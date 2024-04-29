--------------------------------------------------------
--  DDL for Package ZX_MIGRATE_REP_ENTITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_MIGRATE_REP_ENTITIES_PKG" AUTHID CURRENT_USER AS
/* $Header: zxrepentitiess.pls 120.5 2006/05/25 10:26:42 agurram ship $ */
PROCEDURE CREATE_ZX_REPORTING_ASSOC(p_tax_id IN NUMBER DEFAULT NULL);
PROCEDURE CREATE_ZX_REP_TYPE_CODES(p_tax_id IN NUMBER DEFAULT NULL);

----------Procedure added as part of bug fix 3722296---------
PROCEDURE ZX_CREATE_REP_ASSOCIATION_PTP
(
p_rep_type_info		 varchar2,
p_ptp_id                 zx_party_tax_profile.party_tax_profile_id%type,
p_reporting_type_code    zx_reporting_types_b.reporting_type_code%type
);

PROCEDURE ZX_MIGRATE_REP_ENTITIES_MAIN;

PROCEDURE CREATE_SEEDED_REPORTING_TYPES
(
	p_country_code          IN	   VARCHAR2,
	x_return_status        OUT NOCOPY VARCHAR2
);

END ZX_MIGRATE_REP_ENTITIES_PKG;

 

/
