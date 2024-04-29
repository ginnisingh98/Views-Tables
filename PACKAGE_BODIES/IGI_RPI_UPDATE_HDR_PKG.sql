--------------------------------------------------------
--  DDL for Package Body IGI_RPI_UPDATE_HDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_RPI_UPDATE_HDR_PKG" as
--- $Header: igiruphb.pls 120.4.12000000.1 2007/08/31 05:53:59 mbremkum ship $

  l_debug_level number:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  l_state_level number:=FND_LOG.LEVEL_STATEMENT;
  l_proc_level number:=FND_LOG.LEVEL_PROCEDURE;
  l_event_level number:=FND_LOG.LEVEL_EVENT;
  l_excep_level number:=FND_LOG.LEVEL_EXCEPTION;
  l_error_level number:=FND_LOG.LEVEL_ERROR;
  l_unexp_level number:=FND_LOG.LEVEL_UNEXPECTED;

  PROCEDURE Insert_Row(
      X_Rowid                IN OUT NOCOPY VARCHAR2,
	/*MOAC Impact Bug No 5905216*/
      X_org_id		     NUMBER,
      X_run_id         	     NUMBER,
      X_item_id_from         NUMBER,
      X_item_id_to           NUMBER,
      X_effective_date       DATE,
      X_option_flag          VARCHAR2,
      X_amount               NUMBER,
      X_percentage_amount    NUMBER,
      X_status               VARCHAR2,
      X_process_id           NUMBER,
      X_Created_By           NUMBER,
      X_Creation_Date        DATE,
      X_Last_Updated_By      NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Update_Login    NUMBER,
      X_Incr_Decr_Flag       VARCHAR2
  ) IS
    CURSOR C IS SELECT rowid FROM igi_rpi_update_hdr
                WHERE run_id = X_run_id;

   BEGIN


   INSERT INTO igi_rpi_update_hdr (
      run_id,
      org_id,
      item_id_from,
      item_id_to,
      effective_date,
      option_flag,
      amount,
      percentage_amount,
      status,
      process_id,
      Created_By,
      Creation_Date,
      Last_Updated_by,
      Last_Update_Date,
      Last_Update_Login ,
      Incr_decr_flag
)
   VALUES (
      X_run_id,
      X_org_id,
      X_item_id_from,
      X_item_id_to,
      X_effective_date,
      X_option_flag,
      X_amount,
      X_percentage_amount,
      X_status,
      X_process_id,
      X_Created_By,
      X_Creation_Date,
      X_Last_Updated_By,
      X_Last_Update_Date,
      X_Last_Update_Login,
      X_Incr_Decr_Flag);

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


  PROCEDURE Lock_Row(
      X_Rowid                IN OUT NOCOPY VARCHAR2,
      X_run_id         	     NUMBER,
      X_item_id_from         NUMBER,
      X_item_id_to           NUMBER,
      X_effective_date       DATE,
      X_option_flag          VARCHAR2,
      X_amount               NUMBER,
      X_percentage_amount    NUMBER,
      X_status               VARCHAR2,
      X_process_id           NUMBER,
      X_Incr_decr_flag       VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   igi_rpi_update_hdr
        WHERE  rowid = X_Rowid
        FOR UPDATE of run_id NOWAIT;
    Recinfo C%ROWTYPE;
  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      --Bug 3199481 (start)
      If (l_unexp_level >= l_debug_level) then
         FND_LOG.MESSAGE(l_unexp_level,'igi.plsql.igi_rpi_update_hdr_pkg.lock_row.Msg1',FALSE);
      End if;
      --Bug 3199481 (end)
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (
           (Recinfo.run_id                 =  X_run_id)
           AND (Recinfo.item_id_from       =  X_item_id_from)
           AND (Recinfo.item_id_to         =  X_item_id_to)
           AND (Recinfo.effective_date     =  X_effective_date)
           AND (Recinfo.option_flag        =  rtrim(X_option_flag) )
           AND ((Recinfo.amount            =  X_amount)
                OR ((Recinfo.amount is null) AND (X_amount is null) ) )
           AND ((Recinfo.percentage_amount =  X_percentage_amount)
                OR ((Recinfo.percentage_amount is null)
                     AND (X_percentage_amount is null) ) )
           AND ((Recinfo.status            =  rtrim(X_status))
                OR ((Recinfo.status is null) AND (X_status is null) ) )
           AND ((Recinfo.process_id        =  X_process_id)
                OR ((Recinfo.process_id is null) AND (X_process_id is null) )  )
           AND ((Recinfo.Incr_decr_flag    =  X_Incr_decr_flag)
                OR ((Recinfo.Incr_decr_flag is null) AND (X_Incr_decr_flag is null) )  )
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      --Bug 3199481 (start)
      If (l_unexp_level >= l_debug_level) then
         FND_LOG.MESSAGE(l_unexp_level,'igi.plsql.igi_rpi_update_hdr_pkg.lock_row.Msg2',FALSE);
      End if;
      --Bug 3199481 (end)
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;

  PROCEDURE Update_Row(
      X_Rowid                IN OUT NOCOPY VARCHAR2,
      X_run_id         	     NUMBER,
      X_item_id_from         NUMBER,
      X_item_id_to           NUMBER,
      X_effective_date       DATE,
      X_option_flag          VARCHAR2,
      X_amount               NUMBER,
      X_percentage_amount    NUMBER,
      X_status               VARCHAR2,
      X_process_id           NUMBER,
      X_Last_Updated_By      NUMBER,
      X_Last_Update_Date     DATE,
      X_Last_Update_Login    NUMBER,
      X_Incr_Decr_Flag       VARCHAR2
  ) IS
  BEGIN
    UPDATE igi_rpi_update_hdr
    SET
      run_id         	   = X_run_id,
      item_id_from         = X_item_id_from,
      item_id_to           = X_item_id_to,
      effective_date       = X_effective_date,
      option_flag          = X_option_flag,
      amount               = X_amount,
      percentage_amount    = X_percentage_amount,
      status               = X_status,
      process_id           = X_process_id,
      Last_Updated_By      = X_Last_Updated_By,
      Last_Update_Date     = X_Last_Update_Date,
      Last_Update_Login    = X_Last_Update_Login ,
      Incr_Decr_Flag	   = X_Incr_Decr_Flag
WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM igi_rpi_update_hdr
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END IGI_RPI_UPDATE_HDR_PKG;

/
