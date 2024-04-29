--------------------------------------------------------
--  DDL for Package Body GR_DOCUMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_DOCUMENTS" AS
/*$Header: GRFMDOCB.pls 115.5 2002/10/25 18:53:18 mgrosser ship $*/


PROCEDURE paste_document
				(p_copy_from_document IN VARCHAR2,
				 p_paste_to_document IN VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_oracle_error OUT NOCOPY NUMBER,
				 x_msg_data OUT NOCOPY VARCHAR2)
 IS

/*	Alpha Variables */
L_CODE_BLOCK		VARCHAR2(2000);


/* 	Numeric Variables */
L_ORACLE_ERROR		NUMBER;

BEGIN

   l_code_block := NULL;

EXCEPTION

   WHEN OTHERS THEN
      l_oracle_error := APP_EXCEPTION.Get_Code;
	  l_code_block := l_code_block || ' ' || TO_CHAR(l_oracle_error);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_code_block,
	                        FALSE);
      APP_EXCEPTION.Raise_Exception;

END paste_document;

PROCEDURE delete_document
				(p_delete_document IN VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_oracle_error OUT NOCOPY NUMBER,
				 x_msg_data OUT NOCOPY VARCHAR2)

 IS

/*	Alpha Variables */
L_CODE_BLOCK		VARCHAR2(2000);


/* 	Numeric Variables */
L_ORACLE_ERROR		NUMBER;

BEGIN

   l_code_block := NULL;

EXCEPTION

   WHEN OTHERS THEN
      l_oracle_error := APP_EXCEPTION.Get_Code;
	  l_code_block := l_code_block || ' ' || TO_CHAR(l_oracle_error);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_code_block,
	                        FALSE);
      APP_EXCEPTION.Raise_Exception;

END delete_document;


END GR_DOCUMENTS;

/
