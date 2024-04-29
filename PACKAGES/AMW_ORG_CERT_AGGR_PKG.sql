--------------------------------------------------------
--  DDL for Package AMW_ORG_CERT_AGGR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_ORG_CERT_AGGR_PKG" AUTHID CURRENT_USER AS
/* $Header: amwocags.pls 120.0 2005/09/30 15:54:33 appldev noship $ */

PROCEDURE populate_full_hierarchies
(
	x_errbuf 		    OUT      NOCOPY VARCHAR2,
	x_retcode		    OUT      NOCOPY NUMBER,
	p_certification_id     	    IN       NUMBER
);

PROCEDURE populate_org_cert_aggr_rows
(
	p_certification_id 	IN 	NUMBER
);

PROCEDURE update_org_cert_aggr_rows
(
	p_certification_id	IN	NUMBER,
	p_organization_id	IN	NUMBER
);

END AMW_ORG_CERT_AGGR_PKG;

 

/
