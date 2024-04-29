--------------------------------------------------------
--  DDL for Package Body GR_DISCLOSURE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_DISCLOSURE_PKG" AS
/*$Header: GRHIDISB.pls 115.7 2002/10/25 18:11:12 mgrosser ship $*/


PROCEDURE Check_Primary_Key
/*		  p_document_code is the document code to check.
**		  p_called_by_form is 'T' if called by a form or 'F' if not.
**		  x_rowid is the row id of the record if found.
**		  x_key_exists is 'T' is the record is found, 'F' if not.
*/
		  		 	(p_disclosure_code IN VARCHAR2,
					 p_called_by_form IN VARCHAR2,
					 x_rowid OUT NOCOPY VARCHAR2,
					 x_key_exists OUT NOCOPY VARCHAR2)
  IS
/*	Alphanumeric variables	 */

L_MSG_DATA VARCHAR2(80);

/*		Declare any variables and the cursor */


CURSOR c_get_disclosure_rowid
 IS
   SELECT dc.rowid
   FROM	  gr_disclosures dc
   WHERE  dc.disclosure_code = p_disclosure_code;
DisclosureRecord	   c_get_disclosure_rowid%ROWTYPE;

BEGIN

   x_key_exists := 'F';
   l_msg_data := p_disclosure_code;
   OPEN c_get_disclosure_rowid;
   FETCH c_get_disclosure_rowid INTO DisclosureRecord;
   IF c_get_disclosure_rowid%FOUND THEN
      x_key_exists := 'T';
      x_rowid := DisclosureRecord.rowid;
   ELSE
      x_key_exists := 'F';
   END IF;
   CLOSE c_get_disclosure_rowid;

EXCEPTION

	WHEN Others THEN
	  l_msg_data := SUBSTR(SQLERRM, 1, 200);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_msg_data,
	                        FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
	     APP_EXCEPTION.Raise_Exception;
	  END IF;

END Check_Primary_Key;


PROCEDURE Check_References
				(delete_disclosure gr_disclosures.disclosure_code%TYPE)

 IS

/*	Alpha Variables */
L_CODE_BLOCK		VARCHAR2(2000);
L_TABLE_NAME		VARCHAR2(80);


/* 	Numeric Variables */
L_ORACLE_ERROR		NUMBER;
L_COUNT				NUMBER;

/*	Exception */
ROW_IN_USE_ERROR		EXCEPTION;


/*  Cursor Declarations */
/* Cursor to call disclosure code out of GR_COUNTRY */
   CURSOR country_disclosure_cursor
    IS
      SELECT 	COUNT(1)
      FROM 		gr_country_profiles cp
      WHERE 	cp.disclosure_code = delete_disclosure;

/* Cursor to call disclosure code out of GR_ITEM_DISCLOSURE */
   CURSOR itemdisc_disclosure_cursor
    IS
      SELECT	COUNT(1)
      FROM 		gr_item_disclosures id
      WHERE 	id.disclosure_code = delete_disclosure;

/* Cursor to call disclosure code out of GR_DOCUMENT_PRINT (The Recipient Disclosure) */
   CURSOR docprint_rec_disclosure_cursor
    IS
      SELECT	COUNT(1)
      FROM 		gr_document_print dp
      WHERE 	dp.disclosure_code_recipient = delete_disclosure;

/* Cursor to call disclosure code out of GR_DOCUMENT_PRINT (The Country Disclosure) */
   CURSOR docprint_con_disclosure_cursor
    IS
      SELECT	COUNT(1)
      FROM 		gr_document_print dp
      WHERE 	dp.disclosure_code_country = delete_disclosure;

/* Cursor to call disclosure code out of GR_RECIPIENT_INFO */
   CURSOR recip_disclosure_cursor
    IS
      SELECT	COUNT(1)
      FROM 		gr_recipient_info ri
      WHERE 	ri.disclosure_code = delete_disclosure;

BEGIN

   l_table_name := 'GR_COUNTRY_PROFILES';

/*
**	Open cursor which counts total records that match the item code to be deleted
*/
   OPEN country_disclosure_cursor;
   FETCH country_disclosure_cursor INTO l_count;
   CLOSE country_disclosure_cursor;
/*
**	If the code is not in use in this table then l_count will = 0,
**	otherwise an exception will be raised
*/
   IF (l_count >= 1) THEN
	  RAISE Row_In_Use_Error;
   END IF;

/* Check the GR_ITEM_DISCLOSURE table!!! */

   l_table_name := 'GR_ITEM_DISCLOSURES';

   OPEN itemdisc_disclosure_cursor;
   FETCH itemdisc_disclosure_cursor INTO l_count;
   CLOSE itemdisc_disclosure_cursor;

   IF (l_count >= 1) THEN
	  RAISE Row_In_Use_Error;
   END IF;

/* Check the Document Print table for both the Recipient and the Country Disclosure Code */

   l_table_name := 'GR_DOCUMENT_PRINT';

   OPEN docprint_rec_disclosure_cursor;
   FETCH docprint_rec_disclosure_cursor INTO l_count;
   CLOSE docprint_rec_disclosure_cursor;

   IF (l_count >= 1) THEN
	  RAISE Row_In_Use_Error;
   END IF;

   OPEN docprint_con_disclosure_cursor;
   FETCH docprint_con_disclosure_cursor INTO l_count;
   CLOSE docprint_con_disclosure_cursor;

   IF (l_count >= 1) THEN
	  RAISE Row_In_Use_Error;
   END IF;

/* Check the Recipient Info table for the Disclosure Code */

   l_table_name := 'GR_RECIPIENT_INFO';

   OPEN recip_disclosure_cursor;
   FETCH recip_disclosure_cursor INTO l_count;
   CLOSE recip_disclosure_cursor;

   IF (l_count >= 1) THEN
	  RAISE Row_In_Use_Error;
   END IF;

EXCEPTION

   WHEN Row_In_Use_Error THEN
     FND_MESSAGE.SET_NAME('GR',
     					  'GR_INTEGRITY_HDR');
     FND_MESSAGE.SET_TOKEN('CODE', delete_disclosure,
     					   FALSE);
     FND_MESSAGE.SET_TOKEN('TEXT',
                           l_table_name,
                           FALSE);
	 APP_EXCEPTION.Raise_Exception;

   WHEN OTHERS THEN
      l_oracle_error := SQLCODE;
	  --l_code_block := SUBSTR(SQLERRM, 1, 200);
	  l_code_block := l_code_block || ' ' || TO_CHAR(l_oracle_error);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_code_block||sqlerrm,
	                        FALSE);
      APP_EXCEPTION.Raise_Exception;

END Check_References;

END GR_DISCLOSURE_PKG;

/
