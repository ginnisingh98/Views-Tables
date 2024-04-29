--------------------------------------------------------
--  DDL for Package IGI_DOS_DEFAULT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_DOS_DEFAULT_PKG" AUTHID CURRENT_USER AS
-- $Header: igidoshs.pls 120.4.12000000.1 2007/06/08 09:50:21 vkilambi ship $

   PROCEDURE ACCOUNT
     ( P_ORIGIN                     IN VARCHAR2,
       P_ORIGIN_ID                  IN NUMBER,
       P_COA_ID                     IN NUMBER,
       P_SOB_ID                     IN NUMBER,
       P_BUDGET_ORG_ID              IN NUMBER,
       P_IN_HIDDEN_ACCOUNT          IN  VARCHAR2,
       P_IN_VISIBLE_ACCOUNT         IN  VARCHAR2,
       P_RETURN_HIDDEN_ACCOUNT      OUT NOCOPY VARCHAR2,
       P_RETURN_HIDDEN_CCID         OUT NOCOPY VARCHAR2,
       P_RETURN_VISIBLE_ACCOUNT     OUT NOCOPY VARCHAR2,
       P_RETURN_MESSAGE_NAME        OUT NOCOPY VARCHAR2,
       P_RETURN_TOKEN               OUT NOCOPY VARCHAR2,
       P_RESULT_CODE                OUT NOCOPY VARCHAR2);

END; -- Package spec

 

/
