--------------------------------------------------------
--  DDL for Package IGS_AD_LOCATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_LOCATION_PKG" AUTHID CURRENT_USER as
/* $Header: IGSAI46S.pls 115.10 2003/10/30 13:12:59 akadam ship $ */

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1.

  Usage: (e.g. restricted, unrestricted, where to call from)
     1.

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  msrinivi        18 Jul,2001     Added a new col : revenue_account_cd
  *******************************************************************************/

PROCEDURE INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LOCATION_TYPE in VARCHAR2,
  X_MAIL_DLVRY_WRK_DAYS in NUMBER,
  X_COORD_PERSON_ID in igs_pe_person.person_id%type,
    x_attribute_category IN VARCHAR2 DEFAULT NULL,
    x_attribute1 IN VARCHAR2 DEFAULT NULL,
    x_attribute2 IN VARCHAR2 DEFAULT NULL,
    x_attribute3 IN VARCHAR2 DEFAULT NULL,
    x_attribute4 IN VARCHAR2 DEFAULT NULL,
    x_attribute5 IN VARCHAR2 DEFAULT NULL,
    x_attribute6 IN VARCHAR2 DEFAULT NULL,
    x_attribute7 IN VARCHAR2 DEFAULT NULL,
    x_attribute8 IN VARCHAR2 DEFAULT NULL,
    x_attribute9 IN VARCHAR2 DEFAULT NULL,
    x_attribute10 IN VARCHAR2 DEFAULT NULL,
    x_attribute11 IN VARCHAR2 DEFAULT NULL,
    x_attribute12 IN VARCHAR2 DEFAULT NULL,
    x_attribute13 IN VARCHAR2 DEFAULT NULL,
    x_attribute14 IN VARCHAR2 DEFAULT NULL,
    x_attribute15 IN VARCHAR2 DEFAULT NULL,
    x_attribute16 IN VARCHAR2 DEFAULT NULL,
    x_attribute17 IN VARCHAR2 DEFAULT NULL,
    x_attribute18 IN VARCHAR2 DEFAULT NULL,
    x_attribute19 IN VARCHAR2 DEFAULT NULL,
    x_attribute20 IN VARCHAR2 DEFAULT NULL,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  x_rev_account_cd IN VARCHAR2 DEFAULT NULL
  );

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1.

  Usage: (e.g. restricted, unrestricted, where to call from)
     1.

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  msrinivi        18 Jul,2001     Added a new col : revenue_account_cd
  *******************************************************************************/
  PROCEDURE LOCK_ROW (
  X_ROWID  in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LOCATION_TYPE in VARCHAR2,
  X_MAIL_DLVRY_WRK_DAYS in NUMBER,
  X_COORD_PERSON_ID in igs_pe_person.person_id%type,
    x_attribute_category IN VARCHAR2 DEFAULT NULL,
    x_attribute1 IN VARCHAR2 DEFAULT NULL,
    x_attribute2 IN VARCHAR2 DEFAULT NULL,
    x_attribute3 IN VARCHAR2 DEFAULT NULL,
    x_attribute4 IN VARCHAR2 DEFAULT NULL,
    x_attribute5 IN VARCHAR2 DEFAULT NULL,
    x_attribute6 IN VARCHAR2 DEFAULT NULL,
    x_attribute7 IN VARCHAR2 DEFAULT NULL,
    x_attribute8 IN VARCHAR2 DEFAULT NULL,
    x_attribute9 IN VARCHAR2 DEFAULT NULL,
    x_attribute10 IN VARCHAR2 DEFAULT NULL,
    x_attribute11 IN VARCHAR2 DEFAULT NULL,
    x_attribute12 IN VARCHAR2 DEFAULT NULL,
    x_attribute13 IN VARCHAR2 DEFAULT NULL,
    x_attribute14 IN VARCHAR2 DEFAULT NULL,
    x_attribute15 IN VARCHAR2 DEFAULT NULL,
    x_attribute16 IN VARCHAR2 DEFAULT NULL,
    x_attribute17 IN VARCHAR2 DEFAULT NULL,
    x_attribute18 IN VARCHAR2 DEFAULT NULL,
    x_attribute19 IN VARCHAR2 DEFAULT NULL,
    x_attribute20 IN VARCHAR2 DEFAULT NULL,
  X_CLOSED_IND in VARCHAR2,
  x_rev_account_cd IN VARCHAR2 DEFAULT NULL
);

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:
  Purpose:
     1.
  Usage: (e.g. restricted, unrestricted, where to call from)
     1.
  Known limitations/enhancements/remarks:
     -
  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  msrinivi        18 Jul,2001     Added a new col : revenue_account_cd
  *******************************************************************************/
  PROCEDURE UPDATE_ROW (
  X_ROWID  in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LOCATION_TYPE in VARCHAR2,
  X_MAIL_DLVRY_WRK_DAYS in NUMBER,
  X_COORD_PERSON_ID in igs_pe_person.person_id%type,
  X_CLOSED_IND in VARCHAR2,
    x_attribute_category IN VARCHAR2 DEFAULT NULL,
    x_attribute1 IN VARCHAR2 DEFAULT NULL,
    x_attribute2 IN VARCHAR2 DEFAULT NULL,
    x_attribute3 IN VARCHAR2 DEFAULT NULL,
    x_attribute4 IN VARCHAR2 DEFAULT NULL,
    x_attribute5 IN VARCHAR2 DEFAULT NULL,
    x_attribute6 IN VARCHAR2 DEFAULT NULL,
    x_attribute7 IN VARCHAR2 DEFAULT NULL,
    x_attribute8 IN VARCHAR2 DEFAULT NULL,
    x_attribute9 IN VARCHAR2 DEFAULT NULL,
    x_attribute10 IN VARCHAR2 DEFAULT NULL,
    x_attribute11 IN VARCHAR2 DEFAULT NULL,
    x_attribute12 IN VARCHAR2 DEFAULT NULL,
    x_attribute13 IN VARCHAR2 DEFAULT NULL,
    x_attribute14 IN VARCHAR2 DEFAULT NULL,
    x_attribute15 IN VARCHAR2 DEFAULT NULL,
    x_attribute16 IN VARCHAR2 DEFAULT NULL,
    x_attribute17 IN VARCHAR2 DEFAULT NULL,
    x_attribute18 IN VARCHAR2 DEFAULT NULL,
    x_attribute19 IN VARCHAR2 DEFAULT NULL,
    x_attribute20 IN VARCHAR2 DEFAULT NULL,
  X_MODE in VARCHAR2 default 'R',
  x_rev_account_cd IN VARCHAR2 DEFAULT NULL
  );

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:
  Purpose:
     1.
  Usage: (e.g. restricted, unrestricted, where to call from)
     1.
  Known limitations/enhancements/remarks:
     -
  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  msrinivi        18 Jul,2001     Added a new col : revenue_account_cd
  *******************************************************************************/
  PROCEDURE ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LOCATION_TYPE in VARCHAR2,
  X_MAIL_DLVRY_WRK_DAYS in NUMBER,
  X_COORD_PERSON_ID in igs_pe_person.person_id%type,
  X_CLOSED_IND in VARCHAR2,
    x_attribute_category IN VARCHAR2 DEFAULT NULL,
    x_attribute1 IN VARCHAR2 DEFAULT NULL,
    x_attribute2 IN VARCHAR2 DEFAULT NULL,
    x_attribute3 IN VARCHAR2 DEFAULT NULL,
    x_attribute4 IN VARCHAR2 DEFAULT NULL,
    x_attribute5 IN VARCHAR2 DEFAULT NULL,
    x_attribute6 IN VARCHAR2 DEFAULT NULL,
    x_attribute7 IN VARCHAR2 DEFAULT NULL,
    x_attribute8 IN VARCHAR2 DEFAULT NULL,
    x_attribute9 IN VARCHAR2 DEFAULT NULL,
    x_attribute10 IN VARCHAR2 DEFAULT NULL,
    x_attribute11 IN VARCHAR2 DEFAULT NULL,
    x_attribute12 IN VARCHAR2 DEFAULT NULL,
    x_attribute13 IN VARCHAR2 DEFAULT NULL,
    x_attribute14 IN VARCHAR2 DEFAULT NULL,
    x_attribute15 IN VARCHAR2 DEFAULT NULL,
    x_attribute16 IN VARCHAR2 DEFAULT NULL,
    x_attribute17 IN VARCHAR2 DEFAULT NULL,
    x_attribute18 IN VARCHAR2 DEFAULT NULL,
    x_attribute19 IN VARCHAR2 DEFAULT NULL,
    x_attribute20 IN VARCHAR2 DEFAULT NULL,
  X_MODE in VARCHAR2 default 'R',
  x_rev_account_cd IN VARCHAR2 DEFAULT NULL
  );

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:
  Purpose:
     1.
  Usage: (e.g. restricted, unrestricted, where to call from)
     1.
  Known limitations/enhancements/remarks:
     -
  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/
  PROCEDURE DELETE_ROW (
   X_ROWID  in VARCHAR2
  );

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:
  Purpose:
     1.
  Usage: (e.g. restricted, unrestricted, where to call from)
     1.
  Known limitations/enhancements/remarks:
     -
  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/
  FUNCTION Get_PK_For_Validation (
    x_location_cd IN VARCHAR2,
    x_closed_ind IN VARCHAR2 DEFAULT NULL
    )
RETURN BOOLEAN ;

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:
  Purpose:
     1.
  Usage: (e.g. restricted, unrestricted, where to call from)
     1.
  Known limitations/enhancements/remarks:
     -
  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/
  PROCEDURE GET_FK_IGS_AD_LOCATION_TYPE (
    x_location_type IN VARCHAR2
    );

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:
  Purpose:
     1.
  Usage: (e.g. restricted, unrestricted, where to call from)
     1.
  Known limitations/enhancements/remarks:
     -
  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/
  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN igs_pe_person.person_id%type
    );

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:
  Purpose:
     1.
  Usage: (e.g. restricted, unrestricted, where to call from)
     1.
  Known limitations/enhancements/remarks:
     -
  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/
  PROCEDURE Check_Constraints (
  Column_Name IN VARCHAR2 DEFAULT NULL,
  Column_Value IN VARCHAR2 DEFAULT NULL
  );

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:
  Purpose:
     1.
  Usage: (e.g. restricted, unrestricted, where to call from)
     1.
  Known limitations/enhancements/remarks:
     -
  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  msrinivi        18 Jul,2001     Added a new col : revenue_account_cd
  *******************************************************************************/
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_org_id IN  NUMBER DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_location_type IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_coord_person_id IN igs_pe_person.person_id%type DEFAULT NULL,
    x_mail_dlvry_wrk_days IN NUMBER DEFAULT NULL,
    x_attribute_category IN VARCHAR2 DEFAULT NULL,
    x_attribute1 IN VARCHAR2 DEFAULT NULL,
    x_attribute2 IN VARCHAR2 DEFAULT NULL,
    x_attribute3 IN VARCHAR2 DEFAULT NULL,
    x_attribute4 IN VARCHAR2 DEFAULT NULL,
    x_attribute5 IN VARCHAR2 DEFAULT NULL,
    x_attribute6 IN VARCHAR2 DEFAULT NULL,
    x_attribute7 IN VARCHAR2 DEFAULT NULL,
    x_attribute8 IN VARCHAR2 DEFAULT NULL,
    x_attribute9 IN VARCHAR2 DEFAULT NULL,
    x_attribute10 IN VARCHAR2 DEFAULT NULL,
    x_attribute11 IN VARCHAR2 DEFAULT NULL,
    x_attribute12 IN VARCHAR2 DEFAULT NULL,
    x_attribute13 IN VARCHAR2 DEFAULT NULL,
    x_attribute14 IN VARCHAR2 DEFAULT NULL,
    x_attribute15 IN VARCHAR2 DEFAULT NULL,
    x_attribute16 IN VARCHAR2 DEFAULT NULL,
    x_attribute17 IN VARCHAR2 DEFAULT NULL,
    x_attribute18 IN VARCHAR2 DEFAULT NULL,
    x_attribute19 IN VARCHAR2 DEFAULT NULL,
    x_attribute20 IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_rev_account_cd IN VARCHAR2 DEFAULT NULL
    ) ;

end IGS_AD_LOCATION_PKG;

 

/
