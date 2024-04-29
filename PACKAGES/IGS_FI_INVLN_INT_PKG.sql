--------------------------------------------------------
--  DDL for Package IGS_FI_INVLN_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_INVLN_INT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSI74S.pls 120.1 2005/06/05 19:43:06 appldev  $ */

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. This function returns the status of a tracking group

  Usage: (e.g. restricted, unrestricted, where to call from)

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  svuppala      30-MAY-2005       Enh 3442712 - Added new columns Unit_Type_Id, Unit_Level
  smadathi      01-Nov-2002       Enh. Bug 2584986. Added new column GL_DATE,GL_POSTED_DATE,
                                  POSTING_CONTROL_ID.
  msrinivi        17 Jul,2001    Added 2 new cols : error string, error_account
  *******************************************************************************/
 PROCEDURE INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_INVOICE_ID IN NUMBER,
       x_LINE_NUMBER IN NUMBER,
       x_INVOICE_LINES_ID IN out NOCOPY  NUMBER,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_CHG_ELEMENTS IN NUMBER,
       x_AMOUNT IN NUMBER,
       x_UNIT_ATTEMPT_STATUS IN VARCHAR2,
       x_EFTSU IN NUMBER,
       x_CREDIT_POINTS IN NUMBER,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_S_CHG_METHOD_TYPE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_ORG_ID IN NUMBER,
       X_MODE in VARCHAR2 default 'R',
       x_REC_ACCOUNT_CD    IN VARCHAR2,
       x_REV_ACCOUNT_CD    IN VARCHAR2,
       x_REC_GL_CCID    IN NUMBER,
       x_REV_GL_CCID    IN NUMBER,
       x_ORG_UNIT_CD    IN VARCHAR2,
       x_POSTING_ID    IN NUMBER,
       x_ATTRIBUTE11    IN VARCHAR2,
       x_ATTRIBUTE12    IN VARCHAR2,
       x_ATTRIBUTE13    IN VARCHAR2,
       x_ATTRIBUTE14    IN VARCHAR2,
       x_ATTRIBUTE15    IN VARCHAR2,
       x_ATTRIBUTE16    IN VARCHAR2,
       x_ATTRIBUTE17    IN VARCHAR2,
       x_ATTRIBUTE18    IN VARCHAR2,
       x_ATTRIBUTE19    IN VARCHAR2,
       x_ATTRIBUTE20    IN VARCHAR2,
       x_ERROR_STRING         IN     VARCHAR2 DEFAULT NULL,
       x_ERROR_ACCOUNT        IN     VARCHAR2 DEFAULT NULL,
       x_LOCATION_CD          IN     VARCHAR2 DEFAULT NULL ,
       x_UOO_ID               IN     NUMBER   DEFAULT NULL,
       x_gl_date              IN     DATE     DEFAULT NULL,
       x_gl_posted_date       IN     DATE     DEFAULT NULL,
       x_posting_control_id   IN     NUMBER   DEFAULT NULL,
       x_unit_type_id         IN     NUMBER   DEFAULT NULL,
       x_unit_level           IN     VARCHAR2 DEFAULT NULL
  );

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. This function returns the status of a tracking group

  Usage: (e.g. restricted, unrestricted, where to call from)

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  svuppala      30-MAY-2005       Enh 3442712 - Added new columns Unit_Type_Id, Unit_Level
  smadathi      01-Nov-2002       Enh. Bug 2584986. Added new column GL_DATE,GL_POSTED_DATE,
                                  POSTING_CONTROL_ID.
  msrinivi        17 Jul,2001    Added 2 new cols : error string, error_account
  *******************************************************************************/
 PROCEDURE LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_INVOICE_ID IN NUMBER,
       x_LINE_NUMBER IN NUMBER,
       x_INVOICE_LINES_ID IN NUMBER,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_CHG_ELEMENTS IN NUMBER,
       x_AMOUNT IN NUMBER,
       x_UNIT_ATTEMPT_STATUS IN VARCHAR2,
       x_EFTSU IN NUMBER,
       x_CREDIT_POINTS IN NUMBER,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_S_CHG_METHOD_TYPE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_REC_ACCOUNT_CD    IN VARCHAR2,
       x_REV_ACCOUNT_CD    IN VARCHAR2,
       x_REC_GL_CCID    IN NUMBER,
       x_REV_GL_CCID    IN NUMBER,
       x_ORG_UNIT_CD    IN VARCHAR2,
       x_POSTING_ID    IN NUMBER,
       x_ATTRIBUTE11    IN VARCHAR2,
       x_ATTRIBUTE12    IN VARCHAR2,
       x_ATTRIBUTE13    IN VARCHAR2,
       x_ATTRIBUTE14    IN VARCHAR2,
       x_ATTRIBUTE15    IN VARCHAR2,
       x_ATTRIBUTE16    IN VARCHAR2,
       x_ATTRIBUTE17    IN VARCHAR2,
       x_ATTRIBUTE18    IN VARCHAR2,
       x_ATTRIBUTE19    IN VARCHAR2,
       x_ATTRIBUTE20    IN VARCHAR2,
       x_ERROR_STRING IN VARCHAR2 DEFAULT NULL,
       x_ERROR_ACCOUNT IN VARCHAR2 DEFAULT NULL,
       x_LOCATION_CD    IN VARCHAR2 DEFAULT NULL,
       x_UOO_ID         IN NUMBER DEFAULT NULL,
       x_gl_date              IN     DATE     DEFAULT NULL,
       x_gl_posted_date       IN     DATE     DEFAULT NULL,
       x_posting_control_id   IN     NUMBER   DEFAULT NULL,
       x_unit_type_id         IN     NUMBER   DEFAULT NULL,
       x_unit_level           IN     VARCHAR2 DEFAULT NULL
       );
  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. This function returns the status of a tracking group

  Usage: (e.g. restricted, unrestricted, where to call from)

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  svuppala      30-MAY-2005       Enh 3442712 - Added new columns Unit_Type_Id, Unit_Level
  smadathi      01-Nov-2002       Enh. Bug 2584986. Added new column GL_DATE,GL_POSTED_DATE,
                                  POSTING_CONTROL_ID.
  msrinivi        17 Jul,2001    Added 2 new cols : error string, error_account
  *******************************************************************************/
 PROCEDURE UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_INVOICE_ID IN NUMBER,
       x_LINE_NUMBER IN NUMBER,
       x_INVOICE_LINES_ID IN NUMBER,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_CHG_ELEMENTS IN NUMBER,
       x_AMOUNT IN NUMBER,
       x_UNIT_ATTEMPT_STATUS IN VARCHAR2,
       x_EFTSU IN NUMBER,
       x_CREDIT_POINTS IN NUMBER,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_S_CHG_METHOD_TYPE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       X_MODE in VARCHAR2 default 'R',
       x_REC_ACCOUNT_CD    IN VARCHAR2,
       x_REV_ACCOUNT_CD    IN VARCHAR2,
       x_REC_GL_CCID    IN NUMBER,
       x_REV_GL_CCID    IN NUMBER,
       x_ORG_UNIT_CD    IN VARCHAR2,
       x_POSTING_ID    IN NUMBER,
       x_ATTRIBUTE11    IN VARCHAR2,
       x_ATTRIBUTE12    IN VARCHAR2,
       x_ATTRIBUTE13    IN VARCHAR2,
       x_ATTRIBUTE14    IN VARCHAR2,
       x_ATTRIBUTE15    IN VARCHAR2,
       x_ATTRIBUTE16    IN VARCHAR2,
       x_ATTRIBUTE17    IN VARCHAR2,
       x_ATTRIBUTE18    IN VARCHAR2,
       x_ATTRIBUTE19    IN VARCHAR2,
       x_ATTRIBUTE20    IN VARCHAR2,
       x_ERROR_STRING IN VARCHAR2 DEFAULT NULL,
       x_ERROR_ACCOUNT IN VARCHAR2 DEFAULT NULL,
       x_LOCATION_CD    IN VARCHAR2 DEFAULT NULL,
       x_UOO_ID         IN NUMBER DEFAULT NULL,
       x_gl_date              IN     DATE     DEFAULT NULL,
       x_gl_posted_date       IN     DATE     DEFAULT NULL,
       x_posting_control_id   IN     NUMBER   DEFAULT NULL,
       x_unit_type_id         IN     NUMBER   DEFAULT NULL,
       x_unit_level           IN     VARCHAR2 DEFAULT NULL
  );
  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. This function returns the status of a tracking group

  Usage: (e.g. restricted, unrestricted, where to call from)

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  svuppala      30-MAY-2005       Enh 3442712 - Added new columns Unit_Type_Id, Unit_Level
  smadathi      01-Nov-2002       Enh. Bug 2584986. Added new column GL_DATE,GL_POSTED_DATE,
                                  POSTING_CONTROL_ID.
  msrinivi        17 Jul,2001    Added 2 new cols : error string, error_account
  *******************************************************************************/
 PROCEDURE ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_INVOICE_ID IN NUMBER,
       x_LINE_NUMBER IN NUMBER,
       x_INVOICE_LINES_ID IN out NOCOPY  NUMBER,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_CHG_ELEMENTS IN NUMBER,
       x_AMOUNT IN NUMBER,
       x_UNIT_ATTEMPT_STATUS IN VARCHAR2,
       x_EFTSU IN NUMBER,
       x_CREDIT_POINTS IN NUMBER,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_S_CHG_METHOD_TYPE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_ORG_ID IN NUMBER,
       X_MODE in VARCHAR2 default 'R',
       x_REC_ACCOUNT_CD    IN VARCHAR2,
       x_REV_ACCOUNT_CD    IN VARCHAR2,
       x_REC_GL_CCID    IN NUMBER,
       x_REV_GL_CCID    IN NUMBER,
       x_ORG_UNIT_CD    IN VARCHAR2,
       x_POSTING_ID    IN NUMBER,
       x_ATTRIBUTE11    IN VARCHAR2,
       x_ATTRIBUTE12    IN VARCHAR2,
       x_ATTRIBUTE13    IN VARCHAR2,
       x_ATTRIBUTE14    IN VARCHAR2,
       x_ATTRIBUTE15    IN VARCHAR2,
       x_ATTRIBUTE16    IN VARCHAR2,
       x_ATTRIBUTE17    IN VARCHAR2,
       x_ATTRIBUTE18    IN VARCHAR2,
       x_ATTRIBUTE19    IN VARCHAR2,
       x_ATTRIBUTE20    IN VARCHAR2,
       x_ERROR_STRING IN VARCHAR2 DEFAULT NULL,
       x_ERROR_ACCOUNT IN VARCHAR2 DEFAULT NULL,
       x_LOCATION_CD    IN VARCHAR2 DEFAULT NULL,
       x_UOO_ID         IN NUMBER DEFAULT NULL ,
       x_gl_date              IN     DATE     DEFAULT NULL,
       x_gl_posted_date       IN     DATE     DEFAULT NULL,
       x_posting_control_id   IN     NUMBER   DEFAULT NULL,
       x_unit_type_id         IN     NUMBER   DEFAULT NULL,
       x_unit_level           IN     VARCHAR2 DEFAULT NULL
  ) ;

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. This function returns the status of a tracking group

  Usage: (e.g. restricted, unrestricted, where to call from)

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/
  PROCEDURE DELETE_ROW (
      X_ROWID in VARCHAR2
  ) ;

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. This function returns the status of a tracking group

  Usage: (e.g. restricted, unrestricted, where to call from)

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/
  FUNCTION Get_PK_For_Validation (
    x_invoice_lines_id IN NUMBER
    ) RETURN BOOLEAN ;

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. This function returns the status of a tracking group

  Usage: (e.g. restricted, unrestricted, where to call from)
     1. Called from IGSTR007.FMB

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/
  FUNCTION Get_UK_For_Validation (
    x_invoice_id IN NUMBER,
    x_line_number IN NUMBER
    ) RETURN BOOLEAN;

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. This function returns the status of a tracking group

  Usage: (e.g. restricted, unrestricted, where to call from)

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/
  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. This function returns the status of a tracking group

  Usage: (e.g. restricted, unrestricted, where to call from)
     1. Called from IGSTR007.FMB

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/
 PROCEDURE get_fk_igs_ps_unit_ofr_opt_all (
         x_uoo_id IN NUMBER
         );
  /*******************************************************************************
  Created by  : svuppala
  Date created: 30-MAY-2005

  Usage: (e.g. restricted, unrestricted, where to call from)

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/
  PROCEDURE get_fk_igs_fi_posting_int_all (
         x_posting_id IN NUMBER
         );

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. This function returns the status of a tracking group

  Usage: (e.g. restricted, unrestricted, where to call from)

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  svuppala      30-MAY-2005       Enh 3442712 - Added new columns Unit_Type_Id, Unit_Level
  smadathi      01-Nov-2002       Enh. Bug 2584986. Added new column GL_DATE,GL_POSTED_DATE,
                                  POSTING_CONTROL_ID.
  msrinivi        17 Jul,2001    Added 2 new cols : error string, error_account
  *******************************************************************************/
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_invoice_id IN NUMBER DEFAULT NULL,
    x_line_number IN NUMBER DEFAULT NULL,
    x_invoice_lines_id IN NUMBER DEFAULT NULL,
    x_attribute2 IN VARCHAR2 DEFAULT NULL,
    x_chg_elements IN NUMBER DEFAULT NULL,
    x_amount IN NUMBER DEFAULT NULL,
    x_unit_attempt_status IN VARCHAR2 DEFAULT NULL,
    x_eftsu IN NUMBER DEFAULT NULL,
    x_credit_points IN NUMBER DEFAULT NULL,
    x_attribute_category IN VARCHAR2 DEFAULT NULL,
    x_attribute1 IN VARCHAR2 DEFAULT NULL,
    x_s_chg_method_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_attribute3 IN VARCHAR2 DEFAULT NULL,
    x_attribute4 IN VARCHAR2 DEFAULT NULL,
    x_attribute5 IN VARCHAR2 DEFAULT NULL,
    x_attribute6 IN VARCHAR2 DEFAULT NULL,
    x_attribute7 IN VARCHAR2 DEFAULT NULL,
    x_attribute8 IN VARCHAR2 DEFAULT NULL,
    x_attribute9 IN VARCHAR2 DEFAULT NULL,
    x_attribute10 IN VARCHAR2 DEFAULT NULL,
    x_ORG_ID IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_REC_ACCOUNT_CD    IN VARCHAR2 DEFAULT NULL,
    x_REV_ACCOUNT_CD    IN VARCHAR2 DEFAULT NULL,
    x_REC_GL_CCID    IN NUMBER DEFAULT NULL,
    x_REV_GL_CCID    IN NUMBER DEFAULT NULL,
    x_ORG_UNIT_CD    IN VARCHAR2 DEFAULT NULL,
    x_POSTING_ID    IN NUMBER DEFAULT NULL,
    x_ATTRIBUTE11    IN VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE12    IN VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE13    IN VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE14    IN VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE15    IN VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE16    IN VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE17    IN VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE18    IN VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE19    IN VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE20    IN VARCHAR2 DEFAULT NULL,
    x_ERROR_STRING         IN     VARCHAR2 DEFAULT NULL,
    x_ERROR_ACCOUNT        IN     VARCHAR2 DEFAULT NULL,
    x_LOCATION_CD          IN     VARCHAR2 DEFAULT NULL,
    x_UOO_ID               IN     NUMBER   DEFAULT NULL,
    x_gl_date              IN     DATE     DEFAULT NULL,
    x_gl_posted_date       IN     DATE     DEFAULT NULL,
    x_posting_control_id   IN     NUMBER   DEFAULT NULL,
    x_unit_type_id         IN     NUMBER   DEFAULT NULL,
    x_unit_level           IN     VARCHAR2 DEFAULT NULL
 );


END igs_fi_invln_int_pkg;

 

/
