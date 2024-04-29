--------------------------------------------------------
--  DDL for Package PA_UOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_UOM" AUTHID CURRENT_USER AS
/* $Header: PATXUOMS.pls 120.1 2007/02/06 09:27:47 rshaik ship $ */

FUNCTION get_uom(P_user_id IN number, P_uom_code IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;

/* added for bug 5624048 */
PROCEDURE update_fnd_lookup_values(
  X_LOOKUP_TYPE in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER default NULL,
  X_VIEW_APPLICATION_ID in NUMBER,
  X_LOOKUP_CODE in VARCHAR2,
  X_LANGUAGE  in VARCHAR2,
  X_TAG in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_TERRITORY_CODE in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

END pa_uom;

/
