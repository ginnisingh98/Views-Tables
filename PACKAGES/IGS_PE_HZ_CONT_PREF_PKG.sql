--------------------------------------------------------
--  DDL for Package IGS_PE_HZ_CONT_PREF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_HZ_CONT_PREF_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNIB2S.pls 115.0 2003/06/16 06:21:39 ssawhney noship $ */
 procedure INSERT_ROW (
       X_MSG_COUNT OUT NOCOPY NUMBER,
       X_MSG_DATA  OUT NOCOPY VARCHAR2,
       X_RETURN_STATUS OUT NOCOPY VARCHAR2,
       X_ROWID in out NOCOPY VARCHAR2,
       x_CONTACT_PREFERENCE_ID IN OUT NOCOPY NUMBER,
       x_OBJECT_VERSION_NUMBER IN OUT NOCOPY NUMBER,
       X_CONTACT_LEVEL_TABLE  IN  VARCHAR2,
       X_CONTACT_LEVEL_TABLE_ID IN  NUMBER,
       X_CONTACT_TYPE  IN  VARCHAR2,
       X_PREFERENCE_CODE  IN  VARCHAR2,
       X_PREFERENCE_START_DATE  IN  DATE,
       X_PREFERENCE_END_DATE IN  DATE,
       X_REQUESTED_BY IN  VARCHAR2,
       X_REASON_CODE IN  VARCHAR2,
       X_STATUS IN  VARCHAR2,
       X_MODE in VARCHAR2 default 'R'
  );


 procedure UPDATE_ROW (
       X_MSG_COUNT OUT NOCOPY NUMBER,
       X_MSG_DATA  OUT NOCOPY VARCHAR2,
       X_RETURN_STATUS OUT NOCOPY VARCHAR2,
       X_ROWID in out NOCOPY VARCHAR2,
       x_CONTACT_PREFERENCE_ID IN OUT NOCOPY NUMBER,
       x_OBJECT_VERSION_NUMBER IN OUT NOCOPY NUMBER,
       X_CONTACT_LEVEL_TABLE  IN  VARCHAR2,
       X_CONTACT_LEVEL_TABLE_ID IN  NUMBER,
       X_CONTACT_TYPE  IN  VARCHAR2,
       X_PREFERENCE_CODE  IN  VARCHAR2,
       X_PREFERENCE_START_DATE  IN  DATE,
       X_PREFERENCE_END_DATE IN  DATE,
       X_REQUESTED_BY IN  VARCHAR2,
       X_REASON_CODE IN  VARCHAR2,
       X_STATUS IN VARCHAR2,
       X_MODE in VARCHAR2 default 'R'
  );


END IGS_PE_HZ_CONT_PREF_PKG;

 

/