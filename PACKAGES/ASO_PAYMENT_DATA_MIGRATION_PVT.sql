--------------------------------------------------------
--  DDL for Package ASO_PAYMENT_DATA_MIGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_PAYMENT_DATA_MIGRATION_PVT" AUTHID CURRENT_USER as
/* $Header: asovpdms.pls 120.0 2005/11/30 11:03 hagrawal noship $ */
-- Start of Comments
-- FILENAME
--    asovmpds.pls
--
-- DESCRIPTION
--    Package spec of Aso_Payment_Data_Migration_Pvt
--
-- PROCEDURE LIST
--    Migrate_Credit_Card_Data
--
-- HISTORY
--    SEPT-07-2005 Initial Creation
--
-- End of Comments


PROCEDURE Migrate_Credit_Card_Data_Mgr
(
   x_errbuf      OUT NOCOPY VARCHAR2,
   x_retcode     OUT NOCOPY NUMBER,
   X_batch_size  IN NUMBER := 1000,
   X_Num_Workers IN NUMBER  := 5
);

PROCEDURE Migrate_Credit_Card_Data_Wkr
(
   x_errbuf      OUT NOCOPY VARCHAR2,
   x_retcode     OUT NOCOPY NUMBER,
   X_batch_size  IN NUMBER,
   X_Worker_Id   IN NUMBER,
   X_Num_Workers IN NUMBER
);


END Aso_Payment_Data_Migration_Pvt;

 

/
