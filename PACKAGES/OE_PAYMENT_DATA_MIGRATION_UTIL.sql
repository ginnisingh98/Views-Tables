--------------------------------------------------------
--  DDL for Package OE_PAYMENT_DATA_MIGRATION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PAYMENT_DATA_MIGRATION_UTIL" AUTHID CURRENT_USER AS
-- $Header: OEXUPDMS.pls 120.2.12010000.2 2008/08/04 15:04:33 amallik ship $
--+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    OEXUPDMS.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Package Spec of OE_Payment_Data_Migration_Util                    |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Migrate_Data_MGR                                                  |
--|     Migrate_Data_WKR                                                  |
--|     Purge_Data_MGR                                                    |
--|     Purge_Data_WKR                                                    |
--|                                                                       |
--| HISTORY                                                               |
--|    JUN-25-2005 Initial Creation                                       |
--|                                                                       |
--|=======================================================================+

PROCEDURE Migrate_Data_MGR
(   X_errbuf       OUT NOCOPY VARCHAR2,
    X_retcode      OUT NOCOPY VARCHAR2,
    X_batch_size    IN NUMBER,
    X_Num_Workers   IN NUMBER
) ;

PROCEDURE Migrate_Data_WKR
(   X_errbuf       OUT NOCOPY VARCHAR2,
    X_retcode      OUT NOCOPY VARCHAR2,
    X_batch_size    IN NUMBER,
    X_Worker_Id     IN NUMBER,
    X_Num_Workers   IN NUMBER
) ;

PROCEDURE Purge_Data_MGR
(   X_errbuf       OUT NOCOPY VARCHAR2,
    X_retcode      OUT NOCOPY VARCHAR2,
    X_batch_size    IN NUMBER,
    X_Num_Workers   IN NUMBER
) ;

PROCEDURE Purge_Data_WKR
(   X_errbuf       OUT NOCOPY VARCHAR2,
    X_retcode      OUT NOCOPY VARCHAR2,
    X_batch_size    IN NUMBER,
    X_Worker_Id     IN NUMBER,
    X_Num_Workers   IN NUMBER
) ;

--6757060
Function Strip_Non_Numeric_Char(
   p_credit_card_num IN  iby_ext_bank_accounts_v.bank_account_number%TYPE
   )
RETURN VARCHAR2 ;
--6757060

END OE_Payment_Data_Migration_Util ;

/
