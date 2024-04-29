--------------------------------------------------------
--  DDL for Package AR_INTERFACESALESCREDITS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_INTERFACESALESCREDITS_GRP" AUTHID CURRENT_USER AS
/* $Header: ARXGISCS.pls 115.1 2003/10/02 22:17:36 kmahajan noship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

 TYPE application_tbl_type IS TABLE of ar_receivable_applications%ROWTYPE
      INDEX BY BINARY_INTEGER;

 TYPE salescredit_rec_type IS RECORD
   (
	INTERFACE_SALESCREDIT_ID	NUMBER(15),
	INTERFACE_LINE_ID		NUMBER(15),
	INTERFACE_LINE_CONTEXT		VARCHAR2(30),
	INTERFACE_LINE_ATTRIBUTE1	VARCHAR2(30),
	INTERFACE_LINE_ATTRIBUTE2	VARCHAR2(30),
	INTERFACE_LINE_ATTRIBUTE3	VARCHAR2(30),
	INTERFACE_LINE_ATTRIBUTE4	VARCHAR2(30),
	INTERFACE_LINE_ATTRIBUTE5	VARCHAR2(30),
	INTERFACE_LINE_ATTRIBUTE6	VARCHAR2(30),
	INTERFACE_LINE_ATTRIBUTE7	VARCHAR2(30),
	INTERFACE_LINE_ATTRIBUTE8	VARCHAR2(30),
	INTERFACE_LINE_ATTRIBUTE9	VARCHAR2(30),
	INTERFACE_LINE_ATTRIBUTE10	VARCHAR2(30),
	INTERFACE_LINE_ATTRIBUTE11	VARCHAR2(30),
	INTERFACE_LINE_ATTRIBUTE12	VARCHAR2(30),
	INTERFACE_LINE_ATTRIBUTE13	VARCHAR2(30),
	INTERFACE_LINE_ATTRIBUTE14	VARCHAR2(30),
	INTERFACE_LINE_ATTRIBUTE15	VARCHAR2(30),
	SALESREP_NUMBER			VARCHAR2(30),
	SALESREP_ID			NUMBER(15),
	SALESGROUP_ID			NUMBER,
	SALES_CREDIT_TYPE_NAME		VARCHAR2(30),
	SALES_CREDIT_TYPE_ID		NUMBER(15),
	SALES_CREDIT_AMOUNT_SPLIT	NUMBER,
	SALES_CREDIT_PERCENT_SPLIT	NUMBER,
	INTERFACE_STATUS		VARCHAR2(1),
	REQUEST_ID			NUMBER(15),
	ATTRIBUTE_CATEGORY		VARCHAR2(30),
	ATTRIBUTE1			VARCHAR2(150),
	ATTRIBUTE2			VARCHAR2(150),
	ATTRIBUTE3			VARCHAR2(150),
	ATTRIBUTE4			VARCHAR2(150),
	ATTRIBUTE5			VARCHAR2(150),
	ATTRIBUTE6			VARCHAR2(150),
	ATTRIBUTE7			VARCHAR2(150),
	ATTRIBUTE8			VARCHAR2(150),
	ATTRIBUTE9			VARCHAR2(150),
	ATTRIBUTE10			VARCHAR2(150),
	ATTRIBUTE11			VARCHAR2(150),
	ATTRIBUTE12			VARCHAR2(150),
	ATTRIBUTE13			VARCHAR2(150),
	ATTRIBUTE14			VARCHAR2(150),
	ATTRIBUTE15			VARCHAR2(150),
	CREATED_BY			NUMBER(15),
	CREATION_DATE			DATE,
	LAST_UPDATED_BY			NUMBER(15),
	LAST_UPDATE_DATE		DATE,
	LAST_UPDATE_LOGIN		NUMBER(15),
	ORG_ID				NUMBER(15)
   );

/*=======================================================================+
 |  Declare PUBLIC Exceptions
 +=======================================================================*/

/*========================================================================
 | PUBLIC Procedure Insert_SalesCredit
 |
 | DESCRIPTION
 |       This function inserts a row into RA_INTERFACE_SALESCREDITS_ALL and
 |	 is passed all the data in the salescredit_rec_type parameter
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |       IN
 |         p_salescredit_rec
 |       OUT NOCOPY
 |         x_return_status  - Standard return status
 |         x_msg_data       - Standard msg data
 |         x_msg_count      - Standard msg count
 |
 |
 | RETURNS
 |      nothing
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author         Description of Changes
 | 01-OCT-2003           K.Mahajan      Created
 *=======================================================================*/
 PROCEDURE insert_salescredit(
               p_salescredit_rec IN
                              salescredit_rec_type,
               x_return_status   OUT NOCOPY VARCHAR2,
               x_msg_count       OUT NOCOPY NUMBER,
               x_msg_data        OUT NOCOPY VARCHAR2
               );

END AR_InterfaceSalesCredits_GRP;

 

/
