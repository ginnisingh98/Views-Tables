--------------------------------------------------------
--  DDL for Package Body JA_CN_DFF_ASSIGNMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_CN_DFF_ASSIGNMENTS_PKG" AS
  --$Header: JACNDFAB.pls 120.1.12000000.1 2007/08/13 14:09:30 qzhao noship $
  --+=======================================================================+
  --|               Copyright (c) 2006 Oracle Corporation                   |
  --|                       Redwood Shores, CA, USA                         |
  --|                         All rights reserved.                          |
  --+=======================================================================+
  --| FILENAME                                                              |
  --|     JACNDFAB.pls                                                      |
  --|                                                                       |
  --| DESCRIPTION                                                           |
  --|      This package provides table handers for                          |
  --|      table JA_CN_DFF_ASSIGNMENTS, these handlers                      |
  --|      will be called by 'DFF Assignments' form to operate data in table|
  --|      JA_CN_DFF_ASSIGNMENTS                                            |
  --|                                                                       |
  --| PROCEDURE LIST                                                        |
  --|      PROCEDURE Insert_Row                                             |
  --|      PROCEDURE Update_Row                                             |
  --|      PROCEDURE Lock_Row                                               |
  --|                                                                       |
  --| HISTORY                                                               |
  --|     2006/03/01 Jackey Li       Created                                |
  --+======================================================================*/

  G_MODULE_PREFIX VARCHAR2(50) := 'ja.pl/sql.JA_CN_DFF_ASSIGNMENTS_PKG';
  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    Insert_Row                        Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is to insert data that are passed in by parameters into
  --    table JA_CN_DFF_ASSIGNMENTS to create a new record
  --
  --  PARAMETERS:
  --      In:  p_application_id                 Application ID
  --           p_dff_name                       Descriptive Flexfield Name
  --           p_dff_title_code                 DFF title lookup code
  --           p_context_code                   DFF context
  --           p_attribute_column               DFF column
  --           p_creation_date                  Creation date
  --           p_created_by                     Identifier of user that creates
  --                                             the record
  --           p_last_update_date               Last update date of the record
  --           p_last_updated_by                Last update by
  --           p_last_update_login              Last update login
  --
  --   In Out: p_row_id                         Row id of a table record
  --
  --
  --  DESIGN REFERENCES:
  --    CNAO_DFF_ASSIGNMENT_FORM_TD.doc
  --
  --  CHANGE HISTORY:
  --
  --           01-MAR-2006  Jackey Li  created
  --           16-MAy-2007  yanbo liu  changed
  --           add chart_of_accounts_id column.
  --===========================================================================
  PROCEDURE Insert_Row(p_row_id            IN OUT NOCOPY VARCHAR2
                      ,P_application_id    IN NUMBER
                      ,p_dff_name          IN VARCHAR2
                      ,p_dff_title_code    IN VARCHAR2
                      ,p_context_code      IN VARCHAR2
                      ,p_attribute_column  IN VARCHAR2
                      ,p_creation_date     IN DATE
                      ,p_created_by        IN NUMBER
                      ,p_last_update_date  IN DATE
                      ,p_last_updated_by   IN NUMBER
                      ,p_last_update_login IN NUMBER
                      ,p_chart_of_accounts_id In NUMBER
                      ) IS

    l_procedure_name VARCHAR2(100) := 'Insert_Row';
    l_dbg_level      NUMBER := FND_LOG.G_Current_Runtime_Level;
    l_proc_level     NUMBER := FND_LOG.Level_Procedure;

    CURSOR C IS
      SELECT ROWID
        FROM JA_CN_DFF_ASSIGNMENTS
       WHERE DFF_TITLE_CODE = p_dff_title_code;

  BEGIN

    --log for debug
    IF (l_proc_level >= l_dbg_level) THEN
      FND_LOG.STRING(l_proc_level,
                     G_MODULE_PREFIX || '.' || l_procedure_name || '.begin',
                     'Enter procedure');
    END IF; --( l_proc_level >= l_dbg_level)

    --Insert data into table JA_CN_DFF_ASSIGNMENTS
    INSERT INTO JA_CN_DFF_ASSIGNMENTS
      (application_id
      ,descriptive_flexfield_name
      ,dff_title_code
      ,context_code
      ,attribute_column
      ,creation_date
      ,created_by
      ,last_update_date
      ,last_updated_by
      ,last_update_login
      ,chart_of_accounts_id
      )
    VALUES
      (
      p_application_id
      ,p_dff_name
      ,p_dff_title_code
      ,p_context_code
      ,p_attribute_column
      ,p_creation_date
      ,p_created_by
      ,p_last_update_date
      ,p_last_updated_by
      ,p_last_update_login
      ,p_chart_of_accounts_id
     );

    --In case of insert failed, raise error




    OPEN c;
    FETCH c
      INTO p_row_id;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF; --(c%NOTFOUND)
    CLOSE C;

    --log for debug
    IF (l_proc_level >= l_dbg_level) THEN
      FND_LOG.STRING(l_proc_level,
                     G_MODULE_PREFIX || '.' || l_procedure_name || '.end',
                     'Exit procedure');
    END IF; --( l_proc_level >= l_dbg_level)

  END Insert_Row;

  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    Update_Row                        Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to update data in table JA_CN_DFF_ASSIGNMENTS
  --    according to parameters passed in
  --
  --  PARAMETERS:
  --      In:  p_application_id                 Application ID
  --           p_dff_name                       Descriptive Flexfield Name
  --           p_dff_title_code                 DFF title lookup code
  --           p_context_code                   DFF context
  --           p_attribute_column               DFF column
  --           p_creation_date                  Creation date
  --           p_created_by                     Identifier of user that creates
  --                                             the record
  --           p_last_update_date               Last update date of the record
  --           p_last_updated_by                Last update by
  --           p_last_update_login              Last update login
  --
  --  In Out:  p_row_id                         Row id of a table record
  --
  --
  --  DESIGN REFERENCES:
  --    CNAO_DFF_ASSIGNMENT_FORM_TD.doc
  --
  --  CHANGE HISTORY:
  --
  --           01-MAR-2006  Jackey Li  created
  --           16-MAy-2007  yanbo liu  changed
  --           add chart_of_accounts_id column.
  --===========================================================================
  PROCEDURE Update_Row(p_row_id            IN OUT NOCOPY VARCHAR2
                      ,p_application_id    IN NUMBER
                      ,p_dff_name          IN VARCHAR2
                      ,p_dff_title_code    IN VARCHAR2
                      ,p_context_code      IN VARCHAR2
                      ,p_attribute_column  IN VARCHAR2
                      ,p_creation_date     IN DATE
                      ,p_created_by        IN NUMBER
                      ,p_last_update_date  IN DATE
                      ,p_last_updated_by   IN NUMBER
                      ,p_last_update_login IN NUMBER
                      ,p_chart_of_accounts_id In NUMBER) IS

    l_procedure_name VARCHAR2(100) := 'Update_Row';
    l_dbg_level      NUMBER := FND_LOG.G_Current_Runtime_Level;
    l_proc_level     NUMBER := FND_LOG.Level_Procedure;

  BEGIN

    --log for debug
    IF (l_proc_level >= l_dbg_level) THEN
      FND_LOG.STRING(l_proc_level,
                     G_MODULE_PREFIX || '.' || l_procedure_name || '.begin',
                     'Enter procedure');
    END IF; --( l_proc_level >= l_dbg_level)

    --Update data on table JA_CN_DFF_ASSIGNMENTS
    UPDATE JA_CN_DFF_ASSIGNMENTS
       SET application_id             = p_application_id,
           descriptive_flexfield_name = p_dff_name,
           dff_title_code             = p_dff_title_code,
           context_code               = p_context_code,
           attribute_column           = p_attribute_column,
           creation_date              = p_creation_date,
           created_by                 = p_created_by,
           last_update_date           = p_last_update_date,
           last_updated_by            = p_last_updated_by,
           last_update_login          = p_last_update_login,
           chart_of_accounts_id       = p_chart_of_accounts_id
     WHERE ROWID = p_row_id;

    --In case of update failed, raise error
    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF; --(SQL%NOTFOUND)

    --log for debug
    IF (l_proc_level >= l_dbg_level) THEN
      FND_LOG.STRING(l_proc_level,
                     G_MODULE_PREFIX || '.' || l_procedure_name || '.end',
                     'Exit procedure');
    END IF; --( l_proc_level >= l_dbg_level)

  END Update_Row;

  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    Lock_Row                          Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to implement lock on row level on table
  --    JA_CN_DFF_ASSIGNMENTS
  --
  --  PARAMETERS:
  --      In:  p_application_id                 Application ID
  --           p_dff_name                       Descriptive Flexfield Name
  --           p_dff_title_code                 DFF title lookup code
  --           p_context_code                   DFF context
  --           p_attribute_column               DFF column
  --           p_creation_date                  Creation date
  --           p_created_by                     Identifier of user that creates
  --                                             the record
  --           p_last_update_date               Last update date of the record
  --           p_last_updated_by                Last update by
  --           p_last_update_login              Last update login
  --
  --  In Out:  p_row_id                         Row id of a table record
  --
  --
  --  DESIGN REFERENCES:
  --    CNAO_DFF_ASSIGNMENT_FORM_TD.doc
  --
  --  CHANGE HISTORY:
  --
  --           01-MAR-2006  Jackey Li  created
  --           16-MAy-2007  yanbo liu  changed
  --           add chart_of_accounts_id column.
  --===========================================================================
  PROCEDURE Lock_Row(p_row_id            IN OUT NOCOPY VARCHAR2
                    ,p_application_id    IN NUMBER
                    ,p_dff_name          IN VARCHAR2
                    ,p_dff_title_code    IN VARCHAR2
                    ,p_context_code      IN VARCHAR2
                    ,p_attribute_column  IN VARCHAR2
                    ,p_creation_date     IN DATE
                    ,p_created_by        IN NUMBER
                    ,p_last_update_date  IN DATE
                    ,p_last_updated_by   IN NUMBER
                    ,p_last_update_login IN NUMBER
                    ,p_chart_of_accounts_id In NUMBER) IS

    l_procedure_name VARCHAR2(100) := 'Lock_Row';
    l_dbg_level      NUMBER := FND_LOG.G_Current_Runtime_Level;
    l_proc_level     NUMBER := FND_LOG.Level_Procedure;

    CURSOR c IS
      SELECT *
        FROM JA_CN_DFF_ASSIGNMENTS
       WHERE ROWID = p_row_id
         FOR UPDATE OF dff_title_code NOWAIT;

    recinfo c%ROWTYPE;

  BEGIN

    --log for debug
    IF (l_proc_level >= l_dbg_level) THEN
      FND_LOG.STRING(l_proc_level,
                     G_MODULE_PREFIX || '.' || l_procedure_name || '.begin',
                     'Begin procedure');
    END IF; --( l_proc_level >= l_dbg_level)

    IF p_dff_title_code IS NOT NULL THEN
      --If a record has been deleted as form tries to excute dml operation
      --on that record,then raise error to form
      OPEN c;
      FETCH c
        INTO recinfo;
      IF (c%NOTFOUND) THEN
        CLOSE c;
        FND_MESSAGE.Set_Name('FND',
                             'FORM_RECORD_DELETED');
        APP_EXCEPTION.Raise_Exception;
      END IF; --(c%NOTFOUND)
      CLOSE c;

      --To judge if a record has been changed by other programs as the form
      --tries to execute DML operation on that record,if 'Yes', raise error,
      --else the form will be able to do DML operation on the record.
      IF ((recinfo.application_id = p_application_id) AND
         (recinfo.chart_of_accounts_id = p_chart_of_accounts_id) AND
         (rtrim(recinfo.descriptive_flexfield_name) = p_dff_name) AND
         (recinfo.dff_title_code = p_dff_title_code) AND
         ((rtrim(recinfo.context_code) = p_context_code) OR
         ((rtrim(recinfo.context_code) IS NULL) AND
         (p_context_code IS NULL))) AND
         ((rtrim(recinfo.attribute_column) = p_attribute_column) OR
         ((rtrim(recinfo.attribute_column) IS NULL) AND
         (p_attribute_column IS NULL)))) THEN
        RETURN;
      ELSE
        FND_MESSAGE.Set_Name('FND',
                             'FORM_RECORD_CHANGED');
        APP_EXCEPTION.Raise_Exception;
      END IF; --((recinfo.ra_gl_date=p_ra_gl_date) ...
    END IF; --IF p_dff_title_code IS NULL

    --log for debug
    IF (l_proc_level >= l_dbg_level) THEN
      FND_LOG.STRING(l_proc_level,
                     G_MODULE_PREFIX || '.' || l_procedure_name || '.end',
                     'Exit procedure');
    END IF; --( l_proc_level >= l_dbg_level)
  END Lock_Row;

END JA_CN_DFF_ASSIGNMENTS_PKG;

/
