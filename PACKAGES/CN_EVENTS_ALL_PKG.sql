--------------------------------------------------------
--  DDL for Package CN_EVENTS_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_EVENTS_ALL_PKG" AUTHID CURRENT_USER as
/* $Header: cnmlevns.pls 120.3 2005/09/22 07:44:31 vensrini noship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_EVENT_ID in NUMBER,
  X_APPLICATION_REPOSITORY_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ORG_ID IN NUMBER);  -- Modified For R12 MOAC

procedure LOCK_ROW (
  X_EVENT_ID in NUMBER,
  X_APPLICATION_REPOSITORY_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_NAME in VARCHAR2,
  X_ORG_ID IN VARCHAR2
);

procedure UPDATE_ROW (
  X_EVENT_ID in NUMBER,
  X_APPLICATION_REPOSITORY_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ORG_ID IN NUMBER,
  P_OBJECT_VERSION_NUMBER     IN OUT NOCOPY NUMBER); -- Modified For R12

procedure DELETE_ROW (
  X_EVENT_ID in NUMBER,
  X_ORG_ID   IN NUMBER
);

procedure ADD_LANGUAGE;

-- --------------------------------------------------------------------+
-- Procedure : LOAD_ROW
-- Description : Called by FNDLOAD to upload seed datas, this procedure
--    only handle seed datas. ORG_ID = -3113
-- --------------------------------------------------------------------+
PROCEDURE LOAD_ROW
  ( x_event_id IN NUMBER,
    x_description IN VARCHAR2,
    x_application_repository_id  IN NUMBER,
    x_name IN VARCHAR2,
    x_org_id IN NUMBER,
    x_owner IN VARCHAR2);

-- --------------------------------------------------------------------+
-- Procedure : TRANSLATE_ROW
-- Description : Called by FNDLOAD to translate seed datas, this procedure
--    only handle seed datas. ORG_ID = -3113
-- --------------------------------------------------------------------+
PROCEDURE TRANSLATE_ROW
  ( x_event_id IN NUMBER,
    x_name IN VARCHAR2,
    x_owner IN VARCHAR2);

end CN_EVENTS_ALL_PKG;

 

/
