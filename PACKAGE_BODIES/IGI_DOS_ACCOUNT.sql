--------------------------------------------------------
--  DDL for Package Body IGI_DOS_ACCOUNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_DOS_ACCOUNT" AS
-- $Header: igidosgb.pls 115.12 2003/05/13 12:15:55 klakshmi ship $
  PROCEDURE CREATE_NEW
     ( P_COA_ID             IN  NUMBER,
       P_SOB_ID             IN  NUMBER,
       P_BUDGET_ORG_ID      IN  NUMBER,
       P_NEW_ACCOUNT        IN  VARCHAR2,
       P_NEW_CCID           OUT NOCOPY NUMBER    )

   IS
   BEGIN
     null;
   END;

END; -- Package Body IGI_DOS_ACCOUNT

/
