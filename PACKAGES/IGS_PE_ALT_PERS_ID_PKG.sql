--------------------------------------------------------
--  DDL for Package IGS_PE_ALT_PERS_ID_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_ALT_PERS_ID_PKG" AUTHID CURRENT_USER as
/* $Header: IGSNI02S.pls 120.0 2005/06/01 18:07:46 appldev noship $ */

 -------------------------------------------------------------------------------------------
  --Change History:
  -- Bug ID : 2000408
  -- who      when          what
  -- CDCRUZ   Sep 24,2002   New Flex Fld Col's added for
  --                        Person DLD
  -------------------------------------------------------------------------------------------

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PE_PERSON_ID in NUMBER,
  X_API_PERSON_ID in VARCHAR2,
  X_API_PERSON_ID_UF IN VARCHAR2 DEFAULT NULL,
  X_PERSON_ID_TYPE in VARCHAR2,
  X_START_DT in DATE,
  X_END_DT in DATE,
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
  x_region_cd           IN VARCHAR2 DEFAULT NULL,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PE_PERSON_ID in NUMBER,
  X_API_PERSON_ID in VARCHAR2,
  X_API_PERSON_ID_UF IN VARCHAR2 DEFAULT NULL,
  X_PERSON_ID_TYPE in VARCHAR2,
  X_START_DT in DATE,
  X_END_DT in DATE,
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
  x_region_cd           IN VARCHAR2 DEFAULT NULL
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PE_PERSON_ID in NUMBER,
  X_API_PERSON_ID in VARCHAR2,
  X_API_PERSON_ID_UF in VARCHAR2 DEFAULT NULL,
  X_PERSON_ID_TYPE in VARCHAR2,
  X_START_DT in DATE,
  X_END_DT in DATE,
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
  x_region_cd           IN VARCHAR2 DEFAULT NULL,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PE_PERSON_ID in NUMBER,
  X_API_PERSON_ID in VARCHAR2,
  X_API_PERSON_ID_UF IN VARCHAR2 DEFAULT NULL,
  X_PERSON_ID_TYPE in VARCHAR2,
  X_START_DT in DATE,
  X_END_DT in DATE,
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
  x_region_cd           IN VARCHAR2 DEFAULT NULL,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
);
   FUNCTION Get_PK_For_Validation (
    x_pe_person_id IN NUMBER,
    x_api_person_id IN VARCHAR2,
    x_person_id_type IN VARCHAR2,
    x_start_dt IN DATE
    ) RETURN BOOLEAN ;

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN VARCHAR2
    );

  PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 );

 PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_pe_person_id IN NUMBER DEFAULT NULL,
    x_api_person_id IN VARCHAR2 DEFAULT NULL,
    X_API_PERSON_ID_UF IN VARCHAR2 DEFAULT NULL,
    x_person_id_type IN VARCHAR2 DEFAULT NULL,
    x_start_dt IN DATE DEFAULT NULL,
    x_end_dt IN DATE DEFAULT NULL,
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
  x_region_cd           IN VARCHAR2 DEFAULT NULL,
  x_creation_date       IN DATE DEFAULT NULL,
  x_created_by          IN NUMBER DEFAULT NULL,
  x_last_update_date    IN DATE DEFAULT NULL,
  x_last_updated_by     IN NUMBER DEFAULT NULL,
  x_last_update_login   IN NUMBER DEFAULT NULL
  );

end IGS_PE_ALT_PERS_ID_PKG;

 

/
