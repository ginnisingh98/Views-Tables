--------------------------------------------------------
--  DDL for Package CS_CHG_LINENO_UPG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CHG_LINENO_UPG_PKG" AS

PROCEDURE Upgrade_Chg_LineNo_Mgr(
                  X_errbuf     OUT NOCOPY VARCHAR2,
                  X_retcode    OUT NOCOPY VARCHAR2);

PROCEDURE Upgrade_Chg_LineNo_Wkr(
                  X_errbuf     OUT NOCOPY VARCHAR2,
                  X_retcode    OUT NOCOPY VARCHAR2,
                  X_batch_size  IN number,
                  X_Worker_Id   IN number,
                  X_Num_Workers IN number );

END CS_CHG_LINENO_UPG_PKG;

 

/
