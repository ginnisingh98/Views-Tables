--------------------------------------------------------
--  DDL for Package IGI_DOS_ACCOUNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_DOS_ACCOUNT" AUTHID CURRENT_USER AS
-- $Header: igidosgs.pls 115.7 2002/11/18 08:48:26 panaraya ship $
   PROCEDURE CREATE_NEW
     ( P_COA_ID             IN  NUMBER,
       P_SOB_ID             IN  NUMBER,
       P_BUDGET_ORG_ID      IN  NUMBER,
       P_NEW_ACCOUNT        IN  VARCHAR2,
       P_NEW_CCID           OUT NOCOPY NUMBER    )
   ;


  END; -- Package Specification IGI_DOS_ACCOUNT

 

/
