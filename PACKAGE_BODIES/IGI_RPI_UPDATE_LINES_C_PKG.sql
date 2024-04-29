--------------------------------------------------------
--  DDL for Package Body IGI_RPI_UPDATE_LINES_C_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_RPI_UPDATE_LINES_C_PKG" as
--- $Header: igiruplb.pls 120.4.12000000.1 2007/08/31 05:54:07 mbremkum ship $

  l_debug_level number:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  l_state_level number:=FND_LOG.LEVEL_STATEMENT;
  l_proc_level number:=FND_LOG.LEVEL_PROCEDURE;
  l_event_level number:=FND_LOG.LEVEL_EVENT;
  l_excep_level number:=FND_LOG.LEVEL_EXCEPTION;
  l_error_level number:=FND_LOG.LEVEL_ERROR;
  l_unexp_level number:=FND_LOG.LEVEL_UNEXPECTED;

  PROCEDURE Insert_Row(
      X_Rowid                   IN OUT NOCOPY VARCHAR2,
      X_run_id         	        NUMBER,
      X_item_id                 NUMBER,
      X_price                   NUMBER,
      X_effective_date          DATE,
      X_revised_price           NUMBER,
      X_revised_effective_date  DATE,
      X_previous_price          NUMBER,
      X_previous_effective_date DATE,
      X_updated_price           NUMBER,
      X_select_flag             VARCHAR2,
      X_Created_By              NUMBER,
      X_Creation_Date           DATE,
      X_Last_Updated_By         NUMBER,
      X_Last_Update_Date        DATE,
      X_Last_Update_Login       NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM igi_rpi_update_lines
                WHERE run_id  = X_run_id
                  and item_id = X_item_id
                  and standing_charge_id is null;
   BEGIN


   INSERT INTO igi_rpi_update_lines (
      run_id,
      item_id,
      price,
      effective_date,
      revised_price,
      revised_effective_date,
      previous_price,
      previous_effective_date,
      updated_price,
      select_flag,
      Created_By,
      Creation_Date,
      Last_Updated_by,
      Last_Update_Date,
      Last_Update_Login )
   VALUES (
      X_run_id,
      X_item_id,
      X_price,
      X_effective_date,
      X_revised_price,
      X_revised_effective_date,
      X_previous_price,
      X_previous_effective_date,
      X_updated_price,
      X_select_flag,
      X_Created_By,
      X_Creation_Date,
      X_Last_Updated_By,
      X_Last_Update_Date,
      X_Last_Update_Login);

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


  PROCEDURE Lock_Row(
      X_Rowid                   IN OUT NOCOPY VARCHAR2,
      X_run_id         	        NUMBER,
      X_item_id                 NUMBER,
      X_price                   NUMBER,
      X_effective_date          DATE,
      X_revised_price           NUMBER,
      X_revised_effective_date  DATE,
      X_previous_price          NUMBER,
      X_previous_effective_date DATE,
      X_updated_price           NUMBER,
      X_select_flag             VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   igi_rpi_update_lines
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
         FND_LOG.MESSAGE(l_unexp_level,'igi.plsql.igi_rpi_update_lines_c_pkg.lock_row.Msg1',FALSE);
      End if;
      --Bug 3199481 (end)
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (
               (Recinfo.run_id                    =  X_run_id)
           AND (Recinfo.item_id                   =  X_item_id)
           AND (Recinfo.price                     =  X_price)
           AND (Recinfo.effective_date            =  X_effective_date)
           AND ((Recinfo.revised_price             =  X_revised_price)
                OR ((Recinfo.revised_price is null)
                     AND (X_revised_price is null)))
           AND ((Recinfo.revised_effective_date    =  X_revised_effective_date)
                OR ((Recinfo.revised_effective_date is null)
                     AND (X_revised_effective_date  is null)))
           AND ((Recinfo.previous_price            =  X_previous_price)
                OR ((Recinfo.previous_price is null)
                     AND (X_previous_price is null)))
           AND ((Recinfo.previous_effective_date   =  X_previous_effective_date)
                OR ((Recinfo.previous_effective_date is null)
                     AND (X_previous_effective_date is null)))
           AND ((Recinfo.updated_price             =  X_updated_price)
                OR ((Recinfo.updated_price is null)
                     AND (X_updated_price is null)))
           AND ((Recinfo.select_flag               =  rtrim(X_select_flag))
                OR ((Recinfo.select_flag is null)
                     AND (rtrim(X_select_flag) is null)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      --Bug 3199481 (start)
      If (l_unexp_level >= l_debug_level) then
         FND_LOG.MESSAGE(l_unexp_level,'igi.plsql.igi_rpi_update_lines_c_pkg.lock_row.Msg2',FALSE);
      End if;
      --Bug 3199481 (end)
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;

  PROCEDURE Update_Row(
      X_Rowid                   IN OUT NOCOPY VARCHAR2,
      X_run_id         	        NUMBER,
      X_item_id                 NUMBER,
      X_price                   NUMBER,
      X_effective_date          DATE,
      X_revised_price           NUMBER,
      X_revised_effective_date  DATE,
      X_previous_price          NUMBER,
      X_previous_effective_date DATE,
      X_updated_price           NUMBER,
      X_select_flag             VARCHAR2,
      X_Last_Updated_By         NUMBER,
      X_Last_Update_Date        DATE,
      X_Last_Update_Login       NUMBER
  ) IS
  BEGIN
    UPDATE igi_rpi_update_lines
    SET
      run_id              	   = X_run_id,
      item_id                      = X_item_id,
      price                        = X_price,
      effective_date               = X_effective_date,
      revised_price                = X_revised_price,
      revised_effective_date       = X_revised_effective_date,
      previous_price               = X_previous_price,
      previous_effective_date      = X_previous_effective_date,
      updated_price                = X_updated_price,
      select_flag                  = X_select_flag,
      Last_Updated_By              = X_Last_Updated_By,
      Last_Update_Date             = X_Last_Update_Date,
      Last_Update_Login            = X_Last_Update_Login
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM igi_rpi_update_lines
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END IGI_RPI_UPDATE_LINES_C_PKG;

/
