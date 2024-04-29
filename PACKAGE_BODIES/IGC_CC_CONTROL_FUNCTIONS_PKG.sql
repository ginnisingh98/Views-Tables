--------------------------------------------------------
--  DDL for Package Body IGC_CC_CONTROL_FUNCTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_CONTROL_FUNCTIONS_PKG" AS
-- $Header: IGCCAAGB.pls 120.3.12000000.2 2007/09/26 17:36:51 smannava ship $
PROCEDURE INSERT_ROW ( X_ROWID                 IN OUT NOCOPY VARCHAR2,
                       X_CONTROL_FUNCTION_ID          NUMBER,
                       X_CC_STATE                     VARCHAR2,
                       X_CC_TYPE                      VARCHAR2,
                       X_JOB_ID                       NUMBER,
                       X_POSITION_ID                  NUMBER,
                       X_CONTROL_GROUP_ID             NUMBER,
                       X_ORGANIZATION_ID              NUMBER,
                       X_ORG_ID                       NUMBER,
                       X_END_DATE                     DATE,
                       X_START_DATE                   DATE,
                       X_LAST_UPDATED_BY              NUMBER,
                       X_LAST_UPDATE_DATE             DATE,
                       X_LAST_UPDATE_LOGIN            NUMBER,
                       X_CREATION_DATE                DATE,
                       X_CREATED_BY                   NUMBER,
                       X_ATTRIBUTE_CATEGORY           VARCHAR2,
                       X_ATTRIBUTE1                   VARCHAR2,
                       X_ATTRIBUTE2                   VARCHAR2,
                       X_ATTRIBUTE3                   VARCHAR2,
                       X_ATTRIBUTE4                   VARCHAR2,
                       X_ATTRIBUTE5                   VARCHAR2,
                       X_ATTRIBUTE6                   VARCHAR2,
                       X_ATTRIBUTE7                   VARCHAR2,
                       X_ATTRIBUTE8                   VARCHAR2,
                       X_ATTRIBUTE9                   VARCHAR2,
                       X_ATTRIBUTE10                  VARCHAR2,
                       X_ATTRIBUTE11                  VARCHAR2,
                       X_ATTRIBUTE12                  VARCHAR2,
                       X_ATTRIBUTE13                  VARCHAR2,
                       X_ATTRIBUTE14                  VARCHAR2,
                       X_ATTRIBUTE15                  VARCHAR2 ) IS
   cursor c is select rowid from igc_cc_control_functions_all
   where control_function_id = x_control_function_id;
BEGIN
   insert into igc_cc_control_functions_all (
      CONTROL_FUNCTION_ID,
      CC_STATE,
      CC_TYPE,
      JOB_ID,
      POSITION_ID,
      CONTROL_GROUP_ID,
      ORGANIZATION_ID,
      ORG_ID,
      END_DATE,
      START_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      CREATION_DATE,
      CREATED_BY,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15    )
   VALUES (
      X_CONTROL_FUNCTION_ID,
      X_CC_STATE,
      X_CC_TYPE,
      X_JOB_ID,
      X_POSITION_ID,
      X_CONTROL_GROUP_ID,
      X_ORGANIZATION_ID,
      X_ORG_ID,
      X_END_DATE,
      X_START_DATE,
      X_LAST_UPDATED_BY,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATE_LOGIN,
      X_CREATION_DATE,
      X_CREATED_BY,
      X_ATTRIBUTE_CATEGORY,
      X_ATTRIBUTE1,
      X_ATTRIBUTE2,
      X_ATTRIBUTE3,
      X_ATTRIBUTE4,
      X_ATTRIBUTE5,
      X_ATTRIBUTE6,
      X_ATTRIBUTE7,
      X_ATTRIBUTE8,
      X_ATTRIBUTE9,
      X_ATTRIBUTE10,
      X_ATTRIBUTE11,
      X_ATTRIBUTE12,
      X_ATTRIBUTE13,
      X_ATTRIBUTE14,
      X_ATTRIBUTE15    );
   open c;
   fetch c into x_rowid;
   if c%notfound then
      close c;
      raise no_data_found;
   end if;
   close c;
END INSERT_ROW;

PROCEDURE UPDATE_ROW ( X_ROWID                        VARCHAR2,
                       X_CONTROL_FUNCTION_ID          NUMBER,
                       X_CC_STATE                     VARCHAR2,
                       X_CC_TYPE                      VARCHAR2,
                       X_JOB_ID                       NUMBER,
                       X_POSITION_ID                  NUMBER,
                       X_CONTROL_GROUP_ID             NUMBER,
                       X_ORGANIZATION_ID              NUMBER,
                       X_ORG_ID                       NUMBER,
                       X_END_DATE                     DATE,
                       X_START_DATE                   DATE,
                       X_LAST_UPDATED_BY              NUMBER,
                       X_LAST_UPDATE_DATE             DATE,
                       X_LAST_UPDATE_LOGIN            NUMBER,
                       X_CREATION_DATE                DATE,
                       X_CREATED_BY                   NUMBER,
                       X_ATTRIBUTE_CATEGORY           VARCHAR2,
                       X_ATTRIBUTE1                   VARCHAR2,
                       X_ATTRIBUTE2                   VARCHAR2,
                       X_ATTRIBUTE3                   VARCHAR2,
                       X_ATTRIBUTE4                   VARCHAR2,
                       X_ATTRIBUTE5                   VARCHAR2,
                       X_ATTRIBUTE6                   VARCHAR2,
                       X_ATTRIBUTE7                   VARCHAR2,
                       X_ATTRIBUTE8                   VARCHAR2,
                       X_ATTRIBUTE9                   VARCHAR2,
                       X_ATTRIBUTE10                  VARCHAR2,
                       X_ATTRIBUTE11                  VARCHAR2,
                       X_ATTRIBUTE12                  VARCHAR2,
                       X_ATTRIBUTE13                  VARCHAR2,
                       X_ATTRIBUTE14                  VARCHAR2,
                       X_ATTRIBUTE15                  VARCHAR2 ) IS
BEGIN
   update igc_cc_control_functions_all set
      CONTROL_FUNCTION_ID         =  X_CONTROL_FUNCTION_ID,
      CC_STATE                    =  X_CC_STATE,
      CC_TYPE                     =  X_CC_TYPE,
      JOB_ID                      =  X_JOB_ID,
      POSITION_ID                 =  X_POSITION_ID,
      CONTROL_GROUP_ID            =  X_CONTROL_GROUP_ID,
      ORGANIZATION_ID             =  X_ORGANIZATION_ID,
      ORG_ID                      =  X_ORG_ID,
      END_DATE                    =  X_END_DATE,
      START_DATE                  =  X_START_DATE,
      LAST_UPDATED_BY             =  X_LAST_UPDATED_BY,
      LAST_UPDATE_DATE            =  X_LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN           =  X_LAST_UPDATE_LOGIN,
      CREATION_DATE               =  X_CREATION_DATE,
      CREATED_BY                  =  X_CREATED_BY,
      ATTRIBUTE_CATEGORY          =  X_ATTRIBUTE_CATEGORY,
      ATTRIBUTE1                  =  X_ATTRIBUTE1,
      ATTRIBUTE2                  =  X_ATTRIBUTE2,
      ATTRIBUTE3                  =  X_ATTRIBUTE3,
      ATTRIBUTE4                  =  X_ATTRIBUTE4,
      ATTRIBUTE5                  =  X_ATTRIBUTE5,
      ATTRIBUTE6                  =  X_ATTRIBUTE6,
      ATTRIBUTE7                  =  X_ATTRIBUTE7,
      ATTRIBUTE8                  =  X_ATTRIBUTE8,
      ATTRIBUTE9                  =  X_ATTRIBUTE9,
      ATTRIBUTE10                 =  X_ATTRIBUTE10,
      ATTRIBUTE11                 =  X_ATTRIBUTE11,
      ATTRIBUTE12                 =  X_ATTRIBUTE12,
      ATTRIBUTE13                 =  X_ATTRIBUTE13,
      ATTRIBUTE14                 =  X_ATTRIBUTE14,
      ATTRIBUTE15                 =  X_ATTRIBUTE15
   WHERE ROWID = X_ROWID;
   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;
END UPDATE_ROW;

PROCEDURE DELETE_ROW(x_rowid VARCHAR2) IS
BEGIN
   delete from igc_cc_control_functions_all
   where rowid = x_rowid;
   if (SQL%NOTFOUND) then
      raise no_data_found;
   end if;
END DELETE_ROW;

PROCEDURE LOCK_ROW (   X_ROWID                        VARCHAR2,
                       X_CONTROL_FUNCTION_ID          NUMBER,
                       X_CC_STATE                     VARCHAR2,
                       X_CC_TYPE                      VARCHAR2,
                       X_JOB_ID                       NUMBER,
                       X_POSITION_ID                  NUMBER,
                       X_CONTROL_GROUP_ID             NUMBER,
                       X_ORGANIZATION_ID              NUMBER,
                       X_ORG_ID                       NUMBER,
                       X_END_DATE                     DATE,
                       X_START_DATE                   DATE,
                       X_LAST_UPDATED_BY              NUMBER,
                       X_LAST_UPDATE_DATE             DATE,
                       X_LAST_UPDATE_LOGIN            NUMBER,
                       X_CREATION_DATE                DATE,
                       X_CREATED_BY                   NUMBER,
                       X_ATTRIBUTE_CATEGORY           VARCHAR2,
                       X_ATTRIBUTE1                   VARCHAR2,
                       X_ATTRIBUTE2                   VARCHAR2,
                       X_ATTRIBUTE3                   VARCHAR2,
                       X_ATTRIBUTE4                   VARCHAR2,
                       X_ATTRIBUTE5                   VARCHAR2,
                       X_ATTRIBUTE6                   VARCHAR2,
                       X_ATTRIBUTE7                   VARCHAR2,
                       X_ATTRIBUTE8                   VARCHAR2,
                       X_ATTRIBUTE9                   VARCHAR2,
                       X_ATTRIBUTE10                  VARCHAR2,
                       X_ATTRIBUTE11                  VARCHAR2,
                       X_ATTRIBUTE12                  VARCHAR2,
                       X_ATTRIBUTE13                  VARCHAR2,
                       X_ATTRIBUTE14                  VARCHAR2,
                       X_ATTRIBUTE15                  VARCHAR2 ) IS
   CURSOR C is select * from igc_cc_control_functions_all
   where rowid = x_rowid
   for update of control_function_id nowait;
   recinfo c%rowtype;
BEGIN
   open c;
   fetch c into recinfo;
   if (c%notfound) then
      close c;
      fnd_message.set_name('FND','FORM_RECORD_DELETED');
      APP_EXCEPTION.raise_exception;
   end if;
   close c;
   if
      ( recinfo.CONTROL_FUNCTION_ID         =  X_CONTROL_FUNCTION_ID ) AND
      ( recinfo.CC_STATE                    =  X_CC_STATE ) AND
      ( recinfo.CC_TYPE                     =  X_CC_TYPE ) AND
      ( ( recinfo.JOB_ID                    =  X_JOB_ID )
        OR ( ( recinfo.job_id is null ) and ( x_job_id is null ) ) ) AND
      ( ( recinfo.POSITION_ID               =  X_POSITION_ID )
        OR ( ( recinfo.position_id is null ) and ( x_position_id is null ) ) ) AND
      ( recinfo.CONTROL_GROUP_ID            =  X_CONTROL_GROUP_ID ) AND
      ( ( recinfo.ORGANIZATION_ID           =  X_ORGANIZATION_ID )
        OR ( ( recinfo.organization_id is null ) and ( x_organization_id is null ) ) ) AND
      ( ( recinfo.ORG_ID                    =  X_ORG_ID )
        OR ( ( recinfo.org_id is null ) and ( x_org_id is null ) ) ) AND
      ( ( recinfo.END_DATE                  =  X_END_DATE )
        OR ( ( recinfo.end_date is null ) and ( x_end_date is null ) ) ) AND
      ( ( recinfo.START_DATE                =  X_START_DATE )
        OR ( ( recinfo.start_date is null ) and ( x_start_date is null ) ) ) AND
      ( ( recinfo.LAST_UPDATED_BY           =  X_LAST_UPDATED_BY ) AND
      ( ( recinfo.LAST_UPDATE_DATE          =  X_LAST_UPDATE_DATE ) AND
      ( recinfo.LAST_UPDATE_LOGIN           =  X_LAST_UPDATE_LOGIN )
        OR ( ( recinfo.last_update_login is null ) and ( x_last_update_login is null ) ) ) AND
      ( recinfo.CREATION_DATE               =  X_CREATION_DATE ) AND
      ( recinfo.CREATED_BY                  =  X_CREATED_BY ) AND
      ( ( recinfo.ATTRIBUTE_CATEGORY        =  X_ATTRIBUTE_CATEGORY )
        OR ( ( recinfo.attribute_category is null ) and ( x_attribute_category is null))) AND
      ( ( recinfo.ATTRIBUTE1                =  X_ATTRIBUTE1 )
        OR ( ( recinfo.attribute1 is null ) and ( x_attribute1 is null ) ) ) AND
      ( ( recinfo.ATTRIBUTE2                =  X_ATTRIBUTE2 )
        OR ( ( recinfo.attribute2 is null ) and ( x_attribute2 is null ) ) ) AND
      ( ( recinfo.ATTRIBUTE3                =  X_ATTRIBUTE3 )
        OR ( ( recinfo.attribute3 is null ) and ( x_attribute3 is null ) ) ) AND
      ( ( recinfo.ATTRIBUTE4                =  X_ATTRIBUTE4 )
        OR ( ( recinfo.attribute4 is null ) and ( x_attribute4 is null ) ) ) AND
      ( ( recinfo.ATTRIBUTE5                =  X_ATTRIBUTE5 )
        OR ( ( recinfo.attribute5 is null ) and ( x_attribute5 is null ) ) ) AND
      ( ( recinfo.ATTRIBUTE6                =  X_ATTRIBUTE6 )
        OR ( ( recinfo.attribute6 is null ) and ( x_attribute6 is null ) ) ) AND
      ( ( recinfo.ATTRIBUTE7                =  X_ATTRIBUTE7 )
        OR ( ( recinfo.attribute7 is null ) and ( x_attribute7 is null ) ) ) AND
      ( ( recinfo.ATTRIBUTE8                =  X_ATTRIBUTE8 )
        OR ( ( recinfo.attribute8 is null ) and ( x_attribute8 is null ) ) ) AND
      ( ( recinfo.ATTRIBUTE9                =  X_ATTRIBUTE9 )
        OR ( ( recinfo.attribute9 is null ) and ( x_attribute9 is null ) ) ) AND
      ( ( recinfo.ATTRIBUTE10               =  X_ATTRIBUTE10 )
        OR ( ( recinfo.attribute10 is null ) and ( x_attribute10 is null ) ) ) AND
      ( ( recinfo.ATTRIBUTE11               =  X_ATTRIBUTE11 )
        OR ( ( recinfo.attribute11 is null ) and ( x_attribute11 is null ) ) ) AND
      ( ( recinfo.ATTRIBUTE12               =  X_ATTRIBUTE12 )
        OR ( ( recinfo.attribute12 is null ) and ( x_attribute12 is null ) ) ) AND
      ( ( recinfo.ATTRIBUTE13               =  X_ATTRIBUTE13 )
        OR ( ( recinfo.attribute13 is null ) and ( x_attribute13 is null ) ) ) AND
      ( ( recinfo.ATTRIBUTE14               =  X_ATTRIBUTE14 )
        OR ( ( recinfo.attribute14 is null ) and ( x_attribute14 is null ) ) ) AND
      ( ( recinfo.ATTRIBUTE15               =  X_ATTRIBUTE15 )
        OR ( ( recinfo.attribute15 is null ) and ( x_attribute15 is null ) ) ) ) THEN
        return;
   else
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
   end if;
END LOCK_ROW;

END IGC_CC_CONTROL_FUNCTIONS_PKG;

/
