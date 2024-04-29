--------------------------------------------------------
--  DDL for Package PV_ACCOUNT_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_ACCOUNT_MERGE_PKG" AUTHID CURRENT_USER AS
/* $Header: pvxvmras.pls 115.0 2004/03/18 21:39:39 pklin ship $ */

-- Start of Comments
-- Package name     : PV_ACCOUNT_MERGE_PKG
--
-- History
-- MM-DD-YYYY    NAME          MODIFICATIONS
--
-- End of Comments

PROCEDURE MERGE_REFERRAL_ACCOUNT (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);


END PV_ACCOUNT_MERGE_PKG;

 

/
