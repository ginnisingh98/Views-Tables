--------------------------------------------------------
--  DDL for Package IGS_AD_SYSSRC_CAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_SYSSRC_CAT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAI72S.pls 115.9 2003/10/30 13:16:34 akadam ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_SYSTEM_SOURCE_TYPE IN VARCHAR2,
       x_CATEGORY_NAME IN VARCHAR2,
       x_MANDATORY_IND IN VARCHAR2,
       x_SS_IND IN VARCHAR2,
       x_DISPLAY_SEQUENCE IN NUMBER,
       x_AD_TAB_NAME   IN  VARCHAR2 DEFAULT NULL,
       x_INT_TAB_NAME  IN  VARCHAR2 DEFAULT NULL,
      X_MODE in VARCHAR2 default 'R',
      X_CLOSED_IND IN VARCHAR2 DEFAULT 'N'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_SYSTEM_SOURCE_TYPE IN VARCHAR2,
       x_CATEGORY_NAME IN VARCHAR2,
       x_MANDATORY_IND IN VARCHAR2 ,
       x_SS_IND IN VARCHAR2,
       x_DISPLAY_SEQUENCE IN NUMBER,
       x_AD_TAB_NAME   IN  VARCHAR2 DEFAULT NULL,
       x_INT_TAB_NAME  IN  VARCHAR2 DEFAULT NULL,
      X_CLOSED_IND IN VARCHAR2 DEFAULT 'N'
                   );

 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_SYSTEM_SOURCE_TYPE IN VARCHAR2,
       x_CATEGORY_NAME IN VARCHAR2,
       x_MANDATORY_IND IN VARCHAR2,
       x_SS_IND IN VARCHAR2,
       x_DISPLAY_SEQUENCE IN NUMBER,
       x_AD_TAB_NAME   IN  VARCHAR2 DEFAULT NULL,
       x_INT_TAB_NAME  IN  VARCHAR2 DEFAULT NULL,
      X_MODE in VARCHAR2 default 'R',
      X_CLOSED_IND IN VARCHAR2 DEFAULT 'N'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_SYSTEM_SOURCE_TYPE IN VARCHAR2,
       x_CATEGORY_NAME IN VARCHAR2,
       x_MANDATORY_IND IN VARCHAR2,
       x_SS_IND IN VARCHAR2,
       x_DISPLAY_SEQUENCE IN NUMBER,
       x_AD_TAB_NAME   IN  VARCHAR2 DEFAULT NULL,
       x_INT_TAB_NAME  IN  VARCHAR2 DEFAULT NULL,
      X_MODE in VARCHAR2 default 'R',
      X_CLOSED_IND IN VARCHAR2 DEFAULT 'N'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_category_name IN VARCHAR2,
    x_system_source_type IN VARCHAR2,
    x_closed_ind IN VARCHAR2 DEFAULT NULL
    ) RETURN BOOLEAN ;

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_system_source_type IN VARCHAR2 DEFAULT NULL,
    x_category_name IN VARCHAR2 DEFAULT NULL,
    x_mandatory_ind IN VARCHAR2 DEFAULT NULL,
    x_ss_ind IN VARCHAR2 DEFAULT NULL,
    x_display_sequence IN NUMBER DEFAULT NULL,
    x_AD_TAB_NAME   IN  VARCHAR2 DEFAULT NULL,
    x_INT_TAB_NAME  IN  VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
      X_CLOSED_IND IN VARCHAR2 DEFAULT 'N'
 );
END igs_ad_syssrc_cat_pkg;

 

/
