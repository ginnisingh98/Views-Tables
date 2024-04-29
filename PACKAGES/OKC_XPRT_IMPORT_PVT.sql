--------------------------------------------------------
--  DDL for Package OKC_XPRT_IMPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_XPRT_IMPORT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVXCONCPGMS.pls 120.0 2005/05/25 18:25:56 appldev noship $ */

---------------------------------------------------
--  Procedure:
---------------------------------------------------
PROCEDURE publish_rules
(
 errbuf             OUT NOCOPY VARCHAR2,
 retcode            OUT NOCOPY VARCHAR2,
 p_org_id           IN NUMBER
);

PROCEDURE disable_rules
(
 errbuf             OUT NOCOPY VARCHAR2,
 retcode            OUT NOCOPY VARCHAR2,
 p_org_id           IN NUMBER
);

PROCEDURE rebuild_templates
(
 errbuf             OUT NOCOPY VARCHAR2,
 retcode            OUT NOCOPY VARCHAR2,
 p_org_id           IN NUMBER,
 p_intent           IN VARCHAR2,
 p_template_id      IN NUMBER DEFAULT NULL
);

PROCEDURE tmpl_approval_publish_rules
(
 errbuf             OUT NOCOPY VARCHAR2,
 retcode            OUT NOCOPY VARCHAR2,
 p_template_id      IN NUMBER
);



END OKC_XPRT_IMPORT_PVT ;

 

/
