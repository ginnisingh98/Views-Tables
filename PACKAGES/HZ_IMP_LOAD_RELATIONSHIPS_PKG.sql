--------------------------------------------------------
--  DDL for Package HZ_IMP_LOAD_RELATIONSHIPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_IMP_LOAD_RELATIONSHIPS_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHLRELS.pls 120.6 2005/10/30 03:53:11 appldev noship $*/

  TYPE RefCurType IS REF CURSOR;
  TYPE BATCH_ID 		        IS TABLE OF HZ_IMP_RELSHIPS_INT.BATCH_ID%TYPE;
  TYPE PARTY_ID				IS TABLE OF HZ_PARTIES.PARTY_ID%TYPE;
  TYPE RELATIONSHIP_TYPE 		IS TABLE OF HZ_IMP_RELSHIPS_INT.RELATIONSHIP_TYPE%TYPE;
  TYPE COMMENTS				IS TABLE OF HZ_IMP_RELSHIPS_INT.COMMENTS%TYPE;
  TYPE ATTRIBUTE_CATEGORY 		IS TABLE OF HZ_IMP_RELSHIPS_INT.ATTRIBUTE_CATEGORY%TYPE;
  TYPE ATTRIBUTE 			IS TABLE OF HZ_IMP_RELSHIPS_INT.ATTRIBUTE1%TYPE;
  TYPE RELATIONSHIP_ID			IS TABLE OF HZ_RELATIONSHIPS.RELATIONSHIP_ID%TYPE;
  TYPE ROWID				IS TABLE OF VARCHAR2(50); --UROWID;
  TYPE NUMBER_COLUMN			IS TABLE OF NUMBER;
  TYPE FLAG_COLUMN			IS TABLE OF VARCHAR2(1);

  /* Validation error columns */
  TYPE FLAG_ERROR IS TABLE OF VARCHAR2(1);

  PROCEDURE load_relationships (
    P_DML_RECORD  	         IN  	HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
    ,x_return_status             OUT NOCOPY    VARCHAR2
    ,x_msg_count                 OUT NOCOPY    NUMBER
    ,x_msg_data                  OUT NOCOPY    VARCHAR2 );

  FUNCTION validate_desc_flexfield_f(
    p_attr_category  IN VARCHAR2,
    p_attr1          IN VARCHAR2,
    p_attr2          IN VARCHAR2,
    p_attr3          IN VARCHAR2,
    p_attr4          IN VARCHAR2,
    p_attr5          IN VARCHAR2,
    p_attr6          IN VARCHAR2,
    p_attr7          IN VARCHAR2,
    p_attr8          IN VARCHAR2,
    p_attr9          IN VARCHAR2,
    p_attr10         IN VARCHAR2,
    p_attr11         IN VARCHAR2,
    p_attr12         IN VARCHAR2,
    p_attr13         IN VARCHAR2,
    p_attr14         IN VARCHAR2,
    p_attr15         IN VARCHAR2,
    p_attr16         IN VARCHAR2,
    p_attr17         IN VARCHAR2,
    p_attr18         IN VARCHAR2,
    p_attr19         IN VARCHAR2,
    p_attr20         IN VARCHAR2,
    p_validation_date IN DATE
  ) RETURN VARCHAR2;

END HZ_IMP_LOAD_RELATIONSHIPS_PKG;
 

/
