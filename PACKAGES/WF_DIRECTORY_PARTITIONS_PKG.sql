--------------------------------------------------------
--  DDL for Package WF_DIRECTORY_PARTITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_DIRECTORY_PARTITIONS_PKG" AUTHID CURRENT_USER as
/* $Header: wfdps.pls 120.2 2005/09/01 08:17:22 hgandiko noship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_ORIG_SYSTEM in VARCHAR2,
  X_PARTITION_ID in NUMBER,
  X_DISPLAY_NAME in VARCHAR2
);

procedure LOCK_ROW (
  X_ORIG_SYSTEM in VARCHAR2,
  X_PARTITION_ID in NUMBER,
  X_DISPLAY_NAME in VARCHAR2
);

procedure UPDATE_ROW (
  X_ORIG_SYSTEM in VARCHAR2,
  X_PARTITION_ID in NUMBER,
  X_DISPLAY_NAME in VARCHAR2
);

procedure DELETE_ROW (
  X_ORIG_SYSTEM in VARCHAR2
);

procedure ADD_LANGUAGE;

procedure LOAD_ROW (
  X_ORIG_SYSTEM in VARCHAR2,
  X_PARTITION_ID in NUMBER,
  X_DISPLAY_NAME in VARCHAR2
);

procedure TRANSLATE_ROW (
  X_ORIG_SYSTEM in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2
);

--<rwunderl:2901155>
procedure UPDATE_VIEW_NAMES (
  X_ORIG_SYSTEM    in VARCHAR2,
  X_PARTITION_ID   in NUMBER,
  X_ROLE_VIEW      in VARCHAR2 default NULL,
  X_USER_ROLE_VIEW in VARCHAR2 default NULL,
  X_ROLE_TL_VIEW   in VARCHAR2 default NULL,
  X_LAST_UPDATE_DATE in DATE default NULL
);

end WF_DIRECTORY_PARTITIONS_PKG;

 

/