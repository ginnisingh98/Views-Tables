--------------------------------------------------------
--  DDL for Package IGS_FI_GL_PERIODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_GL_PERIODS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSIC7S.pls 115.2 2002/11/29 04:07:38 nsidana noship $ */

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
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

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
  );

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
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );


  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );


END igs_fi_gl_periods_pkg;

 

/
