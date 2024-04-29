--------------------------------------------------------
--  DDL for Package PJM_TASK_ATTRIBUTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJM_TASK_ATTRIBUTES_PKG" AUTHID CURRENT_USER AS
/* $Header: PJMPTAS.pls 115.4 2002/08/14 01:17:51 alaw ship $ */

PROCEDURE LOAD_ROW
( X_Assignment_Type    IN VARCHAR2
, X_Attribute_Code     IN VARCHAR2
, X_Owner              IN VARCHAR2
, X_Attribute_Name     IN VARCHAR2
, X_Form_Field_Name    IN VARCHAR2
);


PROCEDURE TRANSLATE_ROW
( X_Assignment_Type    IN VARCHAR2
, X_Attribute_Code     IN VARCHAR2
, X_Owner              IN VARCHAR2
, X_Attribute_Name     IN VARCHAR2
);

PROCEDURE ADD_LANGUAGE;

END PJM_TASK_ATTRIBUTES_PKG;

 

/
