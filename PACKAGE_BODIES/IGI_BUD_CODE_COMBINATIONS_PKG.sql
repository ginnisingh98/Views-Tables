--------------------------------------------------------
--  DDL for Package Body IGI_BUD_CODE_COMBINATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_BUD_CODE_COMBINATIONS_PKG" as
-- $Header: igibudib.pls 120.4 2005/10/30 05:57:53 appldev ship $
--

--Bug 3199481(Start)

l_debug_level   number := FND_LOG.G_CURRENT_RUNTIME_LEVEL ;

l_state_level   number := FND_LOG.LEVEL_STATEMENT ;
l_proc_level    number := FND_LOG.LEVEL_PROCEDURE ;
l_event_level   number := FND_LOG.LEVEL_EVENT ;
l_excep_level   number := FND_LOG.LEVEL_EXCEPTION ;
l_error_level   number := FND_LOG.LEVEL_ERROR ;
l_unexp_level   number := FND_LOG.LEVEL_UNEXPECTED ;

--Bug 3199481(End)

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Code_Combination_Id              NUMBER,
                     X_Igi_Balanced_Budget_Flag         VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   GL_CODE_COMBINATIONS
        WHERE  rowid = X_Rowid
        FOR UPDATE of igi_balanced_budget_flag NOWAIT;
    Recinfo C%ROWTYPE;

  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      --Bug 3199481 (start)
      If (l_unexp_level >= l_debug_level) then
            FND_LOG.MESSAGE(l_unexp_level,'igi.plsql.igi_bud_code_combinations_pkg.lock_row.Msg1',FALSE);
      End if;
      --Bug 3199481 (End)
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if ( (Recinfo.code_combination_id    =  X_Code_Combination_Id   )
        AND ( (Recinfo.igi_balanced_budget_flag =  X_igi_balanced_budget_flag )
	     OR (  (Recinfo.igi_balanced_budget_flag IS NULL)
		 AND  (X_igi_balanced_budget_flag IS NULL)))
        ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      --Bug 3199481 (start)
      If (l_unexp_level >= l_debug_level) then
            FND_LOG.MESSAGE(l_unexp_level,'igi.plsql.igi_bud_journals_periods_pkg.lock_row.Msg2',FALSE);
      End if;
      --Bug 3199481 (End)
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;


  PROCEDURE Update_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Code_Combination_Id             NUMBER,
                       X_Igi_Balanced_Budget_Flag       VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER
  ) IS
  BEGIN
    UPDATE GL_CODE_COMBINATIONS
    SET
       igi_balanced_budget_flag        =     X_igi_balanced_budget_flag,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;


END IGI_BUD_CODE_COMBINATIONS_PKG;

/
