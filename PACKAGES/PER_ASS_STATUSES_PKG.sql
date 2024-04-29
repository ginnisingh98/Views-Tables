--------------------------------------------------------
--  DDL for Package PER_ASS_STATUSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ASS_STATUSES_PKG" AUTHID CURRENT_USER AS
/* $Header: peast01t.pkh 120.1.12010000.1 2008/07/28 04:12:15 appldev ship $ */

PROCEDURE UNIQUENESS_CHECK(P_USER_STATUS                VARCHAR2,
                           P_BUSINESS_GROUP_ID          NUMBER,
                           P_LEGISLATION_CODE           VARCHAR2,
                           P_ROWID                      VARCHAR2,
                           P_ASSIGNMENT_STATUS_TYPE_ID  NUMBER,
                           P_STARTUP_MODE               VARCHAR2,
                           P_PRIMARY_FLAG               VARCHAR2,
                           P_AMENDMENT                  VARCHAR2,
                           P_C_ACTIVE_FLAG              VARCHAR2,
                           P_C_DEFAULT_FLAG             VARCHAR2,
                           P_DEFAULT_FLAG               VARCHAR2,
                           P_ACTIVE_FLAG                VARCHAR2,
                           P_PER_SYSTEM_STATUS          VARCHAR2,
			   P_MODE                       VARCHAR2) ;

PROCEDURE PRE_UPDATE(P_ACTIVE_FLAG         VARCHAR2,
                     P_DEFAULT_FLAG        VARCHAR2,
                     P_USER_STATUS         VARCHAR2,
                     P_PAY_SYSTEM_STATUS   VARCHAR2,
                     P_LAST_UPDATE_DATE    DATE,
                     P_LAST_UPDATED_BY     NUMBER,
                     P_LAST_UPDATE_LOGIN   NUMBER,
                     P_CREATED_BY          NUMBER,
                     P_CREATION_DATE       DATE,
                     P_ASS_STATUS_TYPE_ID  NUMBER,
                     P_AMENDMENT           VARCHAR2) ;

PROCEDURE INSERT_AMENDS(P_ASS_STATUS_TYPE_AMEND_ID IN OUT NOCOPY NUMBER,
                        P_ASSIGNMENT_STATUS_TYPE_ID NUMBER,
                        P_BUSINESS_GROUP_ID         NUMBER,
                        P_ACTIVE_FLAG               VARCHAR2,
                        P_DEFAULT_FLAG              VARCHAR2,
                        P_USER_STATUS               VARCHAR2,
                        P_PAY_SYSTEM_STATUS         VARCHAR2,
                        P_PER_SYSTEM_STATUS         VARCHAR2,
                        P_LAST_UPDATE_DATE          DATE,
                        P_LAST_UPDATED_BY           NUMBER,
                        P_LAST_UPDATE_LOGIN         NUMBER,
                        P_CREATED_BY                NUMBER,
                        P_CREATION_DATE             DATE);

procedure chk_dflt_per_sys_statuses
(
 p_business_group_id number,
 p_legislation_code  varchar2
);

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_ASSIGNMENT_STATUS_TYPE_ID in NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_LEGISLATION_CODE in VARCHAR2,
  X_ACTIVE_FLAG in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_PRIMARY_FLAG in VARCHAR2,
  X_PAY_SYSTEM_STATUS in VARCHAR2,
  X_PER_SYSTEM_STATUS in VARCHAR2,
  X_USER_STATUS in VARCHAR2,
  X_EXTERNAL_STATUS in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_ASSIGNMENT_STATUS_TYPE_ID in NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_LEGISLATION_CODE in VARCHAR2,
  X_ACTIVE_FLAG in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_PRIMARY_FLAG in VARCHAR2,
  X_PAY_SYSTEM_STATUS in VARCHAR2,
  X_PER_SYSTEM_STATUS in VARCHAR2,
  X_USER_STATUS in VARCHAR2
);
procedure UPDATE_ROW (
  X_ASSIGNMENT_STATUS_TYPE_ID in NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_LEGISLATION_CODE in VARCHAR2,
  X_ACTIVE_FLAG in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_PRIMARY_FLAG in VARCHAR2,
  X_PAY_SYSTEM_STATUS in VARCHAR2,
  X_PER_SYSTEM_STATUS in VARCHAR2,
  X_USER_STATUS in VARCHAR2,
  X_EXTERNAL_STATUS in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_ASSIGNMENT_STATUS_TYPE_ID in NUMBER
);
procedure LOAD_ROW (
  X_STATUS in VARCHAR2,
  X_BUSINESS_GROUP_NAME in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_ACTIVE_FLAG in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_PRIMARY_FLAG in VARCHAR2,
  X_PAY_SYSTEM_STATUS in VARCHAR2,
  X_PER_SYSTEM_STATUS in VARCHAR2,
  X_USER_STATUS in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE IN VARCHAR2 default sysdate,
  X_CUSTOM_MODE IN VARCHAR2 default null
);
procedure TRANSLATE_ROW (
  X_STATUS in VARCHAR2,
  X_BUSINESS_GROUP_NAME in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_USER_STATUS in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE IN VARCHAR2 default sysdate,
  X_CUSTOM_MODE IN VARCHAR2 default null
);
PROCEDURE ADD_LANGUAGE;

--------------------------------------------------------------------------------
PROCEDURE set_translation_globals(p_business_group_id IN NUMBER,
				  p_legislation_code IN VARCHAR2);
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
procedure validate_TRANSLATION (assignment_status_type_id IN    number,
				language IN             varchar2,
                                user_status IN  varchar2,
				p_business_group_id IN NUMBER DEFAULT NULL);
--------------------------------------------------------------------------------
END PER_ASS_STATUSES_PKG;

/
