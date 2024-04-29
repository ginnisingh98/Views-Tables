--------------------------------------------------------
--  DDL for Package Body IGS_SS_TEST_CONF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_SS_TEST_CONF_PKG" AS
/* $Header: IGSAIC3B.pls 115.6 2003/01/10 14:58:42 nshee ship $ */

  l_rowid VARCHAR2(25);

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_test_config_id                    IN     NUMBER      DEFAULT NULL,
    x_source_type_id                    IN     NUMBER      DEFAULT NULL,
    x_admission_test_type               IN     VARCHAR2    DEFAULT NULL,
    x_inactive                          IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : ssomani
  ||  Created On : 18-DEC-2000
  ||  Obsoleted on / by : 17-DEC-2001 by vdixit per enh 2138615
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */



  BEGIN

	NULL;

 END set_column_values;


  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : ssomani
  ||  Created On : 18-DEC-2000
  ||  Obsoleted on / by : 17-DEC-2001 by vdixit per enh 2138615
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    NULL;

  END check_uniqueness;


  FUNCTION get_pk_for_validation (
    x_test_config_id                    IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : ssomani
  ||  Created On : 18-DEC-2000
  ||  Obsoleted on / by : 17-DEC-2001 by vdixit per enh 2138615
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */


  BEGIN

    NULL;

  END get_pk_for_validation;


  FUNCTION get_uk_for_validation (
    x_source_type_id                    IN     NUMBER,
    x_admission_test_type               IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : ssomani
  ||  Created On : 18-DEC-2000
  ||  Obsoleted on / by : 17-DEC-2001 by vdixit per enh 2138615
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  BEGIN

   NULL;

  END get_uk_for_validation ;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_test_config_id                    IN     NUMBER      DEFAULT NULL,
    x_source_type_id                    IN     NUMBER      DEFAULT NULL,
    x_admission_test_type               IN     VARCHAR2    DEFAULT NULL,
    x_inactive                          IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : ssomani
  ||  Created On : 18-DEC-2000
  ||  Obsoleted on / by : 17-DEC-2001 by vdixit per enh 2138615
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

	NULL;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_test_config_id                    IN OUT NOCOPY NUMBER,
    x_source_type_id                    IN     NUMBER,
    x_admission_test_type               IN     VARCHAR2,
    x_inactive                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : ssomani
  ||  Created On : 18-DEC-2000
  ||  Obsoleted on / by : 17-DEC-2001 by vdixit per enh 2138615
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */


  BEGIN

	NULL;
  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_test_config_id                    IN     NUMBER,
    x_source_type_id                    IN     NUMBER,
    x_admission_test_type               IN     VARCHAR2,
    x_inactive                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : ssomani
  ||  Created On : 18-DEC-2000
  ||  Obsoleted on / by : 17-DEC-2001 by vdixit per enh 2138615
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  BEGIN

	   NULL;
  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_test_config_id                    IN     NUMBER,
    x_source_type_id                    IN     NUMBER,
    x_admission_test_type               IN     VARCHAR2,
    x_inactive                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : ssomani
  ||  Created On : 18-DEC-2000
  ||  Obsoleted on / by : 17-DEC-2001 by vdixit per enh 2138615
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */


  BEGIN

	NULL;
  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_test_config_id                    IN OUT NOCOPY NUMBER,
    x_source_type_id                    IN     NUMBER,
    x_admission_test_type               IN     VARCHAR2,
    x_inactive                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : ssomani
  ||  Created On : 18-DEC-2000
  ||  Obsoleted on / by : 17-DEC-2001 by vdixit per enh 2138615
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  BEGIN

	NULL;
  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : ssomani
  ||  Created On : 18-DEC-2000
  ||  Obsoleted on / by : 17-DEC-2001 by vdixit per enh 2138615
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

	   NULL;
  END delete_row;


END igs_ss_test_conf_pkg;

/
