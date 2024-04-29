--------------------------------------------------------
--  DDL for Package IGS_PE_PERSID_GROUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_PERSID_GROUP_PKG" AUTHID CURRENT_USER AS
  /* $Header: IGSNI24S.pls 115.8 2003/06/09 20:04:24 jzyli ship $ */

 -------------------------------------------------------------------------------------------
  --Change History:
  -- Bug ID : 2203134
  -- who      when          what
  -- kpadiyar Mar 14,2002   Added check_uniqueness for the group_cd column.

  -------------------------------------------------------------------------------------------
 -------------------------------------------------------------------------------------------
  --Change History:
  -- Bug ID : 2000408
  -- who      when          what
  -- CDCRUZ   Sep 24,2002   New Flex Fld Col's added for
  --                        Person DLD

  -------------------------------------------------------------------------------------------

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GROUP_ID in NUMBER,
  X_GROUP_CD in VARCHAR2,
  X_CREATOR_PERSON_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_CREATE_DT in DATE,
  X_CLOSED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_FILE_NAME           in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE_CATEGORY  in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE1          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE16         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE17         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE18         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE19         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE20         in      VARCHAR2 DEFAULT NULL,
  X_ORG_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_GROUP_ID in NUMBER,
  X_GROUP_CD in VARCHAR2,
  X_CREATOR_PERSON_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_CREATE_DT in DATE,
  X_CLOSED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_FILE_NAME           in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE_CATEGORY  in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE1          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE16         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE17         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE18         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE19         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE20         in      VARCHAR2 DEFAULT NULL
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_GROUP_ID in NUMBER,
  X_GROUP_CD in VARCHAR2,
  X_CREATOR_PERSON_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_CREATE_DT in DATE,
  X_CLOSED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_FILE_NAME           in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE_CATEGORY  in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE1          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE16         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE17         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE18         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE19         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE20         in      VARCHAR2 DEFAULT NULL,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GROUP_ID in NUMBER,
  X_GROUP_CD in VARCHAR2,
  X_CREATOR_PERSON_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_CREATE_DT in DATE,
  X_CLOSED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_ORG_ID in NUMBER,
  X_FILE_NAME           in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE_CATEGORY  in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE1          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE16         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE17         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE18         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE19         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE20         in      VARCHAR2 DEFAULT NULL,
  X_MODE in VARCHAR2 default 'R'
  );

  FUNCTION Get_PK_For_Validation (
    x_group_id IN NUMBER
    ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation(
    X_GROUP_CD     IN VARCHAR2
    ) RETURN BOOLEAN;

FUNCTION val_persid_group(p_group_id IN NUMBER ,
    p_message_name OUT NOCOPY VARCHAR2
    )RETURN BOOLEAN ;

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    );
PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 );
 PROCEDURE Before_DML (

    p_action IN VARCHAR2,

    x_rowid IN  VARCHAR2 DEFAULT NULL,

    x_group_id IN NUMBER DEFAULT NULL,

    x_group_cd IN VARCHAR2 DEFAULT NULL,

    x_creator_person_id IN NUMBER DEFAULT NULL,

    x_description IN VARCHAR2 DEFAULT NULL,

    x_create_dt IN DATE DEFAULT NULL,

    x_closed_ind IN VARCHAR2 DEFAULT NULL,

    x_comments IN VARCHAR2 DEFAULT NULL,

  x_file_name           IN VARCHAR2 DEFAULT NULL,
  x_attribute_category  IN VARCHAR2 DEFAULT NULL,
  x_attribute1          IN VARCHAR2 DEFAULT NULL,
  x_attribute2          IN VARCHAR2 DEFAULT NULL,
  x_attribute3          IN VARCHAR2 DEFAULT NULL,
  x_attribute4          IN VARCHAR2 DEFAULT NULL,
  x_attribute5          IN VARCHAR2 DEFAULT NULL,
  x_attribute6          IN VARCHAR2 DEFAULT NULL,
  x_attribute7          IN VARCHAR2 DEFAULT NULL,
  x_attribute8          IN VARCHAR2 DEFAULT NULL,
  x_attribute9          IN VARCHAR2 DEFAULT NULL,
  x_attribute10         IN VARCHAR2 DEFAULT NULL,
  x_attribute11         IN VARCHAR2 DEFAULT NULL,
  x_attribute12         IN VARCHAR2 DEFAULT NULL,
  x_attribute13         IN VARCHAR2 DEFAULT NULL,
  x_attribute14         IN VARCHAR2 DEFAULT NULL,
  x_attribute15         IN VARCHAR2 DEFAULT NULL,
  x_attribute16         IN VARCHAR2 DEFAULT NULL,
  x_attribute17         IN VARCHAR2 DEFAULT NULL,
  x_attribute18         IN VARCHAR2 DEFAULT NULL,
  x_attribute19         IN VARCHAR2 DEFAULT NULL,
  x_attribute20         IN VARCHAR2 DEFAULT NULL,


    X_ORG_ID in NUMBER DEFAULT NULL,

    x_creation_date IN DATE DEFAULT NULL,

    x_created_by IN NUMBER DEFAULT NULL,

    x_last_update_date IN DATE DEFAULT NULL,

    x_last_updated_by IN NUMBER DEFAULT NULL,

    x_last_update_login IN NUMBER DEFAULT NULL

  );


end IGS_PE_PERSID_GROUP_PKG;

 

/
