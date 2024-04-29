--------------------------------------------------------
--  DDL for Package BNE_CONTENT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BNE_CONTENT_UTILS" AUTHID CURRENT_USER AS
/* $Header: bneconts.pls 120.3 2005/07/27 03:17:23 dagroves noship $ */
--------------------------------------------------------------------------------
--  PACKAGE:      BNE_CONTENT_UTILS                                           --
--                                                                            --
--  DESCRIPTION:                                                              --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  05-JUN-2002  KPEET     Created.                                           --
--  04-NOV-2002  KPEET     Added procedure ASSIGN_PARAM_LIST_TO_CONTENT       --
--  11-NOV-2002  KPEET     Removed parameters P_PARAM_LIST_APP_ID and         --
--                         P_PARAM_LIST_CODE from procedure                   --
--                         CREATE_CONTENT_TEXT.                               --
--  27-JUL-2004  DAGROVES  Added P_READ_ONLY_FLAG                             --
--------------------------------------------------------------------------------
PROCEDURE UPSERT_CONTENT_COL
                    (P_APPLICATION_ID  IN NUMBER,
                     P_CONTENT_CODE    IN VARCHAR2,
                     P_SEQUENCE_NUM    IN NUMBER,
                     P_COL_NAME        IN VARCHAR2,
                     P_LANGUAGE        IN VARCHAR2,
                     P_SOURCE_LANGUAGE IN VARCHAR2,
                     P_DESCRIPTION     IN VARCHAR2,
                     P_USER_ID         IN NUMBER,
                     P_READ_ONLY_FLAG  IN VARCHAR2 DEFAULT 'N');

PROCEDURE CREATE_CONTENT
                    (P_APPLICATION_ID  IN NUMBER,
                     P_OBJECT_CODE     IN VARCHAR2,
                     P_INTEGRATOR_CODE IN VARCHAR2,
                     P_DESCRIPTION     IN VARCHAR2,
                     P_LANGUAGE        IN VARCHAR2,
                     P_SOURCE_LANGUAGE IN VARCHAR2,
                     P_CONTENT_CLASS   IN VARCHAR2,
                     P_USER_ID         IN NUMBER,
                     P_CONTENT_CODE    OUT NOCOPY VARCHAR2,
                     P_ONCE_ONLY_DOWNLOAD_FLAG IN VARCHAR2 DEFAULT 'N');

PROCEDURE CREATE_CONTENT_TEXT
                    (P_APPLICATION_ID    IN NUMBER,
                     P_OBJECT_CODE       IN VARCHAR2,
                     P_INTEGRATOR_CODE   IN VARCHAR2,
                     P_CONTENT_DESC      IN VARCHAR2,
                     P_NO_OF_COLS        IN NUMBER,
                     P_COL_PREFIX        IN VARCHAR2,
                     P_LANGUAGE          IN VARCHAR2,
                     P_SOURCE_LANGUAGE   IN VARCHAR2,
                     P_USER_ID           IN NUMBER,
                     P_CONTENT_CODE      OUT NOCOPY VARCHAR2);

PROCEDURE CREATE_CONTENT_STORED_SQL
                    (P_APPLICATION_ID  IN NUMBER,
                     P_OBJECT_CODE     IN VARCHAR2,
                     P_INTEGRATOR_CODE IN VARCHAR2,
                     P_CONTENT_DESC    IN VARCHAR2,
                     P_COL_LIST        IN VARCHAR2,
                     P_QUERY           IN VARCHAR2,
                     P_LANGUAGE        IN VARCHAR2,
                     P_SOURCE_LANGUAGE IN VARCHAR2,
                     P_USER_ID         IN NUMBER,
                     P_CONTENT_CODE    OUT NOCOPY VARCHAR2,
                     P_ONCE_ONLY_DOWNLOAD_FLAG IN VARCHAR2 DEFAULT 'N');

PROCEDURE CREATE_CONTENT_PASSED_SQL
                    (P_APPLICATION_ID  IN NUMBER,
                     P_OBJECT_CODE     IN VARCHAR2,
                     P_INTEGRATOR_CODE IN VARCHAR2,
                     P_CONTENT_DESC    IN VARCHAR2,
                     P_COL_LIST        IN VARCHAR2,
                     P_LANGUAGE        IN VARCHAR2,
                     P_SOURCE_LANGUAGE IN VARCHAR2,
                     P_USER_ID         IN NUMBER,
                     P_CONTENT_CODE    OUT NOCOPY VARCHAR2,
                     P_ONCE_ONLY_DOWNLOAD_FLAG IN VARCHAR2 DEFAULT 'N');

PROCEDURE CREATE_CONTENT_DYNAMIC_SQL
                    (P_APPLICATION_ID  IN NUMBER,
                     P_OBJECT_CODE     IN VARCHAR2,
                     P_INTEGRATOR_CODE IN VARCHAR2,
                     P_CONTENT_DESC    IN VARCHAR2,
                     P_CONTENT_CLASS   IN VARCHAR2,
                     P_COL_LIST        IN VARCHAR2,
                     P_LANGUAGE        IN VARCHAR2,
                     P_SOURCE_LANGUAGE IN VARCHAR2,
                     P_USER_ID         IN NUMBER,
                     P_CONTENT_CODE    OUT NOCOPY VARCHAR2,
                     P_ONCE_ONLY_DOWNLOAD_FLAG IN VARCHAR2 DEFAULT 'N');

PROCEDURE CREATE_CONTENT_COLS_FROM_VIEW
                    (P_APPLICATION_ID  IN NUMBER,
                     P_CONTENT_CODE    IN VARCHAR2,
                     P_VIEW_NAME       IN VARCHAR2,
                     P_LANGUAGE        IN VARCHAR2,
                     P_SOURCE_LANGUAGE IN VARCHAR2,
                     P_USER_ID         IN NUMBER);

PROCEDURE UPSERT_STORED_SQL_STATEMENT
                    (P_APPLICATION_ID IN NUMBER,
                     P_CONTENT_CODE   IN VARCHAR2,
                     P_QUERY          IN VARCHAR2,
                     P_USER_ID        IN NUMBER);

PROCEDURE ENABLE_CONTENT_FOR_REPORTING
                    (P_APPLICATION_ID  IN NUMBER,
                     P_OBJECT_CODE     IN VARCHAR2,
                     P_INTEGRATOR_CODE IN VARCHAR2,
                     P_CONTENT_CODE    IN VARCHAR2,
                     P_LANGUAGE        IN VARCHAR2,
                     P_SOURCE_LANGUAGE IN VARCHAR2,
                     P_USER_ID         IN NUMBER,
                     P_INTERFACE_CODE  OUT NOCOPY VARCHAR2,
                     P_MAPPING_CODE    OUT NOCOPY VARCHAR2);

PROCEDURE CREATE_REPORTING_MAPPING
                    (P_APPLICATION_ID  IN NUMBER,
                     P_OBJECT_CODE     IN VARCHAR2,
                     P_INTEGRATOR_CODE IN VARCHAR2,
                     P_CONTENT_CODE    IN VARCHAR2,
                     P_INTERFACE_CODE  IN VARCHAR2,
                     P_LANGUAGE        IN VARCHAR2,
                     P_SOURCE_LANGUAGE IN VARCHAR2,
                     P_USER_ID         IN NUMBER,
                     P_MAPPING_CODE    OUT NOCOPY VARCHAR2);

PROCEDURE CREATE_CONTENT_TO_API_MAP
                    (P_APPLICATION_ID  IN NUMBER,
                     P_OBJECT_CODE     IN VARCHAR2,
                     P_INTEGRATOR_CODE IN VARCHAR2,
                     P_CONTENT_CODE    IN VARCHAR2,
                     P_INTERFACE_CODE  IN VARCHAR2,
                     P_LANGUAGE        IN VARCHAR2,
                     P_SOURCE_LANGUAGE IN VARCHAR2,
                     P_USER_ID         IN NUMBER,
                     P_MAPPING_CODE    OUT NOCOPY VARCHAR2);

PROCEDURE ASSIGN_PARAM_LIST_TO_CONTENT
                    (P_CONTENT_APP_ID    IN NUMBER,
                     P_CONTENT_CODE      IN VARCHAR2,
                     P_PARAM_LIST_APP_ID IN NUMBER,
                     P_PARAM_LIST_CODE   IN VARCHAR2);

END BNE_CONTENT_UTILS;

 

/
