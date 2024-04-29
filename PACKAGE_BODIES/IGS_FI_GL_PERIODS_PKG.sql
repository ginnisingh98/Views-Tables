--------------------------------------------------------
--  DDL for Package Body IGS_FI_GL_PERIODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_GL_PERIODS_PKG" AS
/* $Header: IGSSIC7B.pls 120.1 2005/09/23 03:34:36 agairola noship $ */

  l_rowid VARCHAR2(25);
  old_references gl_period_statuses%ROWTYPE;
  new_references gl_period_statuses%ROWTYPE;

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_application_id                    IN     NUMBER,
    x_set_of_books_id                   IN     NUMBER,
    x_period_name                       IN     VARCHAR2,
    x_closing_status                    IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_year_start_date                   IN     DATE,
    x_quarter_num                       IN     NUMBER,
    x_quarter_start_date                IN     DATE,
    x_period_type                       IN     VARCHAR2,
    x_period_year                       IN     NUMBER,
    x_effective_period_num              IN     NUMBER,
    x_period_num                        IN     NUMBER,
    x_adjustment_period_flag            IN     VARCHAR2,
    x_elimination_confirmed_flag        IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_context                           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Sanil.Madathil@oracle.com
  ||  Created On : 05-NOV-2002
  ||  Purpose : Handles the INSERT DML logic for the table. Invokes the gl_period_statuses_pkg.insert_row
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

  BEGIN

    x_last_update_date := SYSDATE;
    IF (x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF (x_last_updated_by IS NULL) THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      fnd_message.set_token('ROUTINE','IGS_FI_GL_PERIODS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

/*
  gl_period_statuses_pkg.insert_row(X_Rowid                   => x_rowid             ,
                                    X_Application_Id          => x_application_id    ,
                                    X_Set_Of_Books_Id         => x_set_of_books_id   ,
                                    X_Period_Name             => x_period_name       ,
                                    X_Last_Update_Date        => x_last_update_date  ,
                                    X_Last_Updated_By         => x_last_updated_by   ,
                                    X_Closing_Status          => x_closing_status    ,
                                    X_Start_Date              => x_start_date        ,
                                    X_End_Date                => x_end_date          ,
                                    X_Period_Type             => x_period_type       ,
                                    X_Period_Year             => x_period_year       ,
                                    X_Period_Num              => x_period_num        ,
                                    X_Quarter_Num             => x_quarter_num       ,
                                    X_Adjustment_Period_Flag  => x_adjustment_period_flag ,
                                    X_Creation_Date           => x_last_update_date  ,
                                    X_Created_By              => x_last_updated_by   ,
                                    X_Last_Update_Login       => x_last_update_login ,
                                    X_Attribute1              => x_attribute1        ,
                                    X_Attribute2              => x_attribute2        ,
                                    X_Attribute3              => x_attribute3        ,
                                    X_Attribute4              => x_attribute4        ,
                                    X_Attribute5              => x_attribute5        ,
                                    X_Context                 => x_context
                                  );
*/
  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_application_id                    IN     NUMBER,
    x_set_of_books_id                   IN     NUMBER,
    x_period_name                       IN     VARCHAR2,
    x_closing_status                    IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_year_start_date                   IN     DATE,
    x_quarter_num                       IN     NUMBER,
    x_quarter_start_date                IN     DATE,
    x_period_type                       IN     VARCHAR2,
    x_period_year                       IN     NUMBER,
    x_effective_period_num              IN     NUMBER,
    x_period_num                        IN     NUMBER,
    x_adjustment_period_flag            IN     VARCHAR2,
    x_elimination_confirmed_flag        IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_context                           IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Sanil.Madathil@oracle.com
  ||  Created On : 05-NOV-2002
  ||  Purpose : Handles the LOCK mechanism for the table. Invokes the gl_period_statuses_pkg.lock_row
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  BEGIN
/*
  gl_period_statuses_pkg.lock_row(X_Rowid                     =>  x_rowid           ,
                                  X_Application_Id            =>  x_application_id  ,
                                  X_Set_Of_Books_Id           =>  x_set_of_books_id ,
                                  X_Period_Name               =>  x_period_name     ,
                                  X_Closing_Status            =>  x_closing_status  ,
                                  X_Start_Date                =>  x_start_date      ,
                                  X_End_Date                  =>  x_end_date        ,
                                  X_Period_Type               =>  x_period_type     ,
                                  X_Period_Year               =>  x_period_year     ,
                                  X_Period_Num                =>  x_period_num      ,
                                  X_Quarter_Num               =>  x_quarter_num     ,
                                  X_Adjustment_Period_Flag    =>  x_adjustment_period_flag ,
                                  X_Attribute1                =>  x_attribute1      ,
                                  X_Attribute2                =>  x_attribute2      ,
                                  X_Attribute3                =>  x_attribute3      ,
                                  X_Attribute4                =>  x_attribute4      ,
                                  X_Attribute5                =>  x_attribute5      ,
                                  X_Context                   =>  x_context
				  ); */
   null;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_application_id                    IN     NUMBER,
    x_set_of_books_id                   IN     NUMBER,
    x_period_name                       IN     VARCHAR2,
    x_closing_status                    IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_year_start_date                   IN     DATE,
    x_quarter_num                       IN     NUMBER,
    x_quarter_start_date                IN     DATE,
    x_period_type                       IN     VARCHAR2,
    x_period_year                       IN     NUMBER,
    x_effective_period_num              IN     NUMBER,
    x_period_num                        IN     NUMBER,
    x_adjustment_period_flag            IN     VARCHAR2,
    x_elimination_confirmed_flag        IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_context                           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Sanil.Madathil@oracle.com
  ||  Created On : 05-NOV-2002
  ||  Purpose : Handles the UPDATE DML logic for the table. Invokes the gl_period_statuses_pkg.update_row
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

  BEGIN

    x_last_update_date := SYSDATE;
    IF (X_MODE = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name( 'FND', 'SYSTEM-INVALID ARGS');
      fnd_message.set_token('ROUTINE','IGS_FI_GL_PERIODS_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

/*
     gl_period_statuses_pkg.update_row(X_Rowid                    =>   x_rowid            ,
                                       X_Application_Id           =>   x_application_id   ,
				       X_Ledger_Id                =>   x_set_of_books_id,
                                       X_Set_Of_Books_Id          =>   x_set_of_books_id  ,
                                       X_Period_Name              =>   x_period_name      ,
                                       X_Last_Update_Date         =>   x_last_update_date ,
                                       X_Last_Updated_By          =>   x_last_updated_by  ,
                                       X_Closing_Status           =>   x_closing_status   ,
                                       X_Start_Date               =>   x_start_date       ,
                                       X_End_Date                 =>   x_end_date         ,
                                       X_Period_Type              =>   x_period_type      ,
                                       X_Period_Year              =>   x_period_year      ,
                                       X_Period_Num               =>   x_period_num       ,
                                       X_Quarter_Num              =>   x_quarter_num      ,
                                       X_Adjustment_Period_Flag   =>   x_adjustment_period_flag ,
                                       X_Last_Update_Login        =>   x_last_update_login,
                                       X_Attribute1               =>   x_attribute1       ,
                                       X_Attribute2               =>   x_attribute2       ,
                                       X_Attribute3               =>   x_attribute3       ,
                                       X_Attribute4               =>   x_attribute4       ,
                                       X_Attribute5               =>   x_attribute5       ,
                                       X_Context                  =>   x_context
                                     );
*/

  END update_row;

  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Sanil.Madathil@oracle.com
  ||  Created On : 05-NOV-2002
  ||  Purpose : Handles the DELETE DML logic for the table. Invokes the gl_period_statuses_pkg.delete_row
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
/*
    gl_period_statuses_pkg.Delete_Row(X_Rowid => x_rowid);
*/
    null;
  END delete_row;


END igs_fi_gl_periods_pkg;

/
