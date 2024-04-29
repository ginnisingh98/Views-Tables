--------------------------------------------------------
--  DDL for Package BSC_DB_MEASURE_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_DB_MEASURE_GROUPS_PKG" AUTHID CURRENT_USER as
/* $Header: BSCMSGRS.pls 120.1 2005/08/02 03:09:45 ashankar noship $ */

-- mdamle 04/23/2003 - Measure Definer - Added sequence for Group Id
-- Callers must not pass a new group Id in.
procedure INSERT_ROW (
  X_MEASURE_GROUP_ID out NOCOPY NUMBER,
  X_HELP in VARCHAR2,
  X_SHORT_NAME IN VARCHAR2  := NULL
);
procedure LOCK_ROW (
  X_MEASURE_GROUP_ID in NUMBER,
  X_HELP in VARCHAR2
);
procedure TRANSLATE_ROW (
  X_MEASURE_GROUP_ID in NUMBER,
  X_HELP in VARCHAR2
);
procedure UPDATE_ROW (
  X_MEASURE_GROUP_ID in NUMBER,
  X_HELP in VARCHAR2,
  X_SHORT_NAME IN VARCHAR2  := NULL
);
procedure DELETE_ROW (
  X_MEASURE_GROUP_ID in NUMBER
);
procedure ADD_LANGUAGE;


PROCEDURE Insert_Default_Meas_Row
(
    x_Measure_group_id    IN    NUMBER
  , x_Help                IN    VARCHAR2
);

PROCEDURE Insert_Row_Values
(
    x_Measure_group_id    IN    NUMBER
  , x_Help                IN    VARCHAR2
  , x_Short_name          IN    VARCHAR2
);

END BSC_DB_MEASURE_GROUPS_PKG;

 

/
