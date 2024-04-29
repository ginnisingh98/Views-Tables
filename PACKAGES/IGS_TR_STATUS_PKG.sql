--------------------------------------------------------
--  DDL for Package IGS_TR_STATUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_TR_STATUS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSTI02S.pls 115.6 2003/02/19 12:55:22 kpadiyar ship $ */

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. Used for creation of tracking steps and associating them with
     system tracking types

  Usage: (e.g. restricted, unrestricted, where to call from)
     1. Called from IGSTR003.fmb

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  msrinivi        9 Jul, 2001    Added the new column default_ind to TBH
  *******************************************************************************/

  PROCEDURE insert_row (
    x_rowid IN OUT NOCOPY VARCHAR2,
    x_tracking_status IN VARCHAR2,
    x_description IN VARCHAR2,
    x_s_tracking_status IN VARCHAR2,
    x_closed_ind IN VARCHAR2,
    x_mode IN VARCHAR2 DEFAULT 'R',
    x_default_ind IN VARCHAR2 DEFAULT 'N'
  );

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. Used for creation of tracking steps and associating them with
     system tracking types

  Usage: (e.g. restricted, unrestricted, where to call from)
     1. Called from IGSTR003.fmb

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  msrinivi        9 Jul, 2001    Added the new column default_ind to TBH
  *******************************************************************************/

  PROCEDURE lock_row (
    x_rowid IN VARCHAR2,
    x_tracking_status IN VARCHAR2,
    x_description IN VARCHAR2,
    x_s_tracking_status IN VARCHAR2,
    x_closed_ind IN VARCHAR2,
    x_default_ind IN VARCHAR2 DEFAULT 'N'
  );

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. Used for creation of tracking steps and associating them with
     system tracking types

  Usage: (e.g. restricted, unrestricted, where to call from)
     1. Called from IGSTR003.fmb

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  msrinivi        9 Jul, 2001    Added the new column default_ind to TBH
  *******************************************************************************/

  PROCEDURE update_row (
    x_rowid IN VARCHAR2,
    x_tracking_status IN VARCHAR2,
    x_description IN VARCHAR2,
    x_s_tracking_status IN VARCHAR2,
    x_closed_ind IN VARCHAR2,
    x_mode IN VARCHAR2 DEFAULT 'R',
    x_default_ind IN VARCHAR2 DEFAULT 'N'
  );
  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. Used for creation of tracking steps and associating them with
     system tracking types

  Usage: (e.g. restricted, unrestricted, where to call from)
     1. Called from IGSTR003.fmb

  Known limitations/enhancements/remarks:
     -
  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  msrinivi        9 Jul, 2001    Added the new column default_ind to TBH
  *******************************************************************************/

  PROCEDURE add_row (
    x_rowid IN OUT NOCOPY VARCHAR2,
    x_tracking_status IN VARCHAR2,
    x_description IN VARCHAR2,
    x_s_tracking_status IN VARCHAR2,
    x_closed_ind IN VARCHAR2,
    x_mode IN VARCHAR2 DEFAULT 'R',
    x_default_ind IN VARCHAR2 DEFAULT 'N'
  );

  FUNCTION get_pk_for_validation (
    x_tracking_status IN VARCHAR2
  )RETURN BOOLEAN;

  -- added to take care of check constraints
  PROCEDURE check_constraints(
    column_name IN VARCHAR2 DEFAULT NULL,
    column_value IN VARCHAR2 DEFAULT NULL
  );

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. Used for creation of tracking steps and associating them with
     system tracking types

  Usage: (e.g. restricted, unrestricted, where to call from)
     1. Called from IGSTR003.fmb

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  msrinivi        9 Jul, 2001    Added the new column default_ind to TBH
  *******************************************************************************/

  PROCEDURE before_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_tracking_status IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_s_tracking_status IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_default_ind IN VARCHAR2 DEFAULT 'N'
  );

END igs_tr_status_pkg;

 

/
