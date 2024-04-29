--------------------------------------------------------
--  DDL for Package WF_SOA_CTX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_SOA_CTX_PKG" AUTHID CURRENT_USER AS
   /* $Header: WFSOACTXS.pls 120.1.12010000.3 2009/06/15 07:34:40 snellepa noship $ */
PROCEDURE setContext(pUserName      VARCHAR2,
                     pResp          VARCHAR2,
                     pRespApp       VARCHAR2,
                     pSecurityGroup VARCHAR2,
                     pnlslanguage   VARCHAR2,
                     pIsLangCode    NUMBER default 0,
                     pOrgId         NUMBER) ;

PROCEDURE GETCONTEXT_ID( pUserName            VARCHAR2,
                         pResp                VARCHAR2,
                         pRespApp             VARCHAR2,
                         pSecurityGroup       VARCHAR2,
                         pLang                VARCHAR2,
                         pIsLangCode          NUMBER default 0,
                         pUserID OUT NOCOPY          NUMBER,
                         pRespID OUT NOCOPY          NUMBER,
                         pRespAppID OUT NOCOPY       NUMBER,
                         pSecurityGroupID OUT NOCOPY NUMBER,
                         pLangCode OUT NOCOPY        VARCHAR2,
                         x_status_code OUT NOCOPY VARCHAR2,
                         x_error_code OUT NOCOPY VARCHAR2
                         );
END WF_SOA_CTX_PKG;


/
