--------------------------------------------------------
--  DDL for Package IGS_PS_FAC_TCFT_TMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_FAC_TCFT_TMP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI3GS.pls 115.2 2002/11/29 02:26:12 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_usec_occur_id1                    IN     NUMBER,
    x_usec_occur_id2                    IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_usec_occur_id1                    IN     NUMBER,
    x_usec_occur_id2                    IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_usec_occur_id1                    IN     NUMBER,
    x_usec_occur_id2                    IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_usec_occur_id1                    IN     NUMBER,
    x_usec_occur_id2                    IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

END igs_ps_fac_tcft_tmp_pkg;

 

/
