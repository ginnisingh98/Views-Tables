--------------------------------------------------------
--  DDL for Package MTH_UDA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTH_UDA_PKG" AUTHID CURRENT_USER AS
/*$Header: mthuntbs.pls 120.3.12010000.5 2010/03/15 22:06:58 lvenkatr ship $*/

PROCEDURE UPDATE_TO_PRIMARY_KEY(P_ENTITY IN VARCHAR2)  ;
PROCEDURE NTB_UPLOAD_STANDARD_WHO(P_EXT_TBL_NAME IN VARCHAR2,  P_EXTENSION_ID IN NUMBER,  P_IF_ROW_EXISTS IN NUMBER)  ;
PROCEDURE NTB_UPLOADTL(P_ENTITY IN VARCHAR2,  P_EXTID IN NUMBER,  P_IF_ROW_EXISTS IN NUMBER)  ;
PROCEDURE NTB_UPLOAD(P_TARGET IN VARCHAR2)  ;
PROCEDURE DEVICE_PRE_LOG(P_TARGET IN VARCHAR2)  ;
PROCEDURE TB_UPLOAD  ;
PROCEDURE DEVICE_POST_LOG(P_TARGET IN VARCHAR2)  ;


FUNCTION GET_MST_TABLE_NAME(P_ENTITY IN VARCHAR2) RETURN VARCHAR2  ;
FUNCTION GET_MST_PK_NAME(P_ENTITY IN VARCHAR2) RETURN VARCHAR2  ;
FUNCTION GET_EXT_TL_TABLE_NAME(P_ENTITY IN VARCHAR2) RETURN VARCHAR2  ;
FUNCTION GET_EXT_TABLE_NAME(P_ENTITY IN VARCHAR2) RETURN VARCHAR2  ;
FUNCTION GET_ENTITY_CODE(P_ENTITY IN VARCHAR2) RETURN NUMBER  ;

--Added for Composite Primary key
TYPE v_csv_column_names IS TABLE OF VARCHAR2(100);
TYPE v_mst_pk_key_columns IS TABLE OF VARCHAR2(50);

PROCEDURE UPDATE_COMPOSITE_PRIMARY_KEY(P_ENTITY IN VARCHAR2);
PROCEDURE GET_MST_COMPOSITE_PK_NAME(P_ENTITY IN VARCHAR2,v_mst_pk_name OUT NOCOPY v_mst_pk_key_columns, v_entity_code OUT NUMBER, v_csv_columns OUT NOCOPY v_csv_column_names);
PROCEDURE NTB_UPLOAD_COMPOSITETL(P_ENTITY IN VARCHAR2,  P_EXTID IN NUMBER,  P_IF_ROW_EXISTS IN NUMBER);
PROCEDURE NTB_UPLOAD_COMPOSITE_PK(P_TARGET IN VARCHAR2);


END MTH_UDA_PKG;


/