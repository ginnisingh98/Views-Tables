--------------------------------------------------------
--  DDL for Package IEC_G_REP_CONF_VALIDATORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_G_REP_CONF_VALIDATORS_PKG" AUTHID CURRENT_USER as
/* $Header: IECREPDS.pls 115.0 2004/03/24 05:10:31 anayak noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_VALIDATOR_ID in NUMBER,
  X_VALIDATOR_CLASS in VARCHAR2,
  X_FORMAT in VARCHAR2,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
);

procedure LOCK_ROW (
  X_VALIDATOR_ID in NUMBER,
  X_VALIDATOR_CLASS in VARCHAR2,
  X_FORMAT in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER
);

procedure UPDATE_ROW (
  X_VALIDATOR_ID in NUMBER,
  X_VALIDATOR_CLASS in VARCHAR2,
  X_FORMAT in VARCHAR2,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
);

procedure LOAD_ROW (
  X_VALIDATOR_ID in NUMBER,
  X_VALIDATOR_CLASS in VARCHAR2,
  X_FORMAT in VARCHAR2,
  X_OWNER in VARCHAR2
);

end IEC_G_REP_CONF_VALIDATORS_PKG;

 

/