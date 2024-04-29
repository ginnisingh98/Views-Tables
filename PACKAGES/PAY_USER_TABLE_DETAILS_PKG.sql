--------------------------------------------------------
--  DDL for Package PAY_USER_TABLE_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_USER_TABLE_DETAILS_PKG" AUTHID CURRENT_USER AS
/* $Header: pyutabdp.pkh 120.0 2007/07/17 10:51:57 sukukuma noship $ */
g_upload                BOOLEAN := FALSE;
g_user_table_name       pay_user_tables.user_table_name%TYPE;

PROCEDURE user_table_upd_ins
(
   X_USER_TABLE_NAME             IN VARCHAR2,
   X_USER_ROW_TITLE              IN VARCHAR2,
   X_LEGISLATION_CODE            IN VARCHAR2,
   X_RANGE_OR_MATCH              IN VARCHAR2,
   X_USER_KEY_UNITS              IN VARCHAR2,
   X_OWNER                       IN VARCHAR2,
   X_LEG_VIEW                    IN VARCHAR2,
   X_PRODUCT_CODE                IN VARCHAR2
);

PROCEDURE user_row_upd_ins
(
   X_USER_TABLE_NAME             IN VARCHAR2,
   X_LEGISLATION_CODE            IN VARCHAR2,
   X_ROW_LOW_RANGE_OR_NAME       IN VARCHAR2,
   X_ROW_HIGH_RANGE              IN VARCHAR2,
   X_EFFECTIVE_START_DATE        IN VARCHAR2,
   X_EFFECTIVE_END_DATE          IN VARCHAR2,
   X_DISPLAY_SEQUENCE            IN VARCHAR2,
   X_OWNER                       IN VARCHAR2,
   X_LEG_VIEW                    IN VARCHAR2
);

PROCEDURE column_row_upd_ins
(
   X_USER_TABLE_NAME             IN  VARCHAR2,
   X_LEGISLATION_CODE            IN  VARCHAR2,
   X_USER_COLUMN_NAME            IN  VARCHAR2,
   X_FORMULA_NAME                IN  VARCHAR2,
   X_FORMULA_LEG_CODE            IN  VARCHAR2,
   X_OWNER                       IN  VARCHAR2,
   X_LEG_VIEW                    IN  VARCHAR2
);

PROCEDURE column_instance_upd_ins
(
   X_USER_TABLE_NAME            IN  VARCHAR2,
   X_USER_COLUMN_NAME           IN  VARCHAR2,
   X_ROW_LOW_RANGE_OR_NAME      IN  VARCHAR2,
   X_ROW_HIGH_RANGE             IN  VARCHAR2,
   X_LEGISLATION_CODE           IN  VARCHAR2,
   X_VALUE                      IN  VARCHAR2,
   X_EFFECTIVE_START_DATE       IN  VARCHAR2,
   X_EFFECTIVE_END_DATE         IN  VARCHAR2,
   X_OWNER                      IN  VARCHAR2,
   X_LEG_VIEW                   IN  VARCHAR2
);

END pay_user_table_details_pkg;


/
