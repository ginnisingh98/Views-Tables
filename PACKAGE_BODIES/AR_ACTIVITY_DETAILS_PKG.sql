--------------------------------------------------------
--  DDL for Package Body AR_ACTIVITY_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ACTIVITY_DETAILS_PKG" AS
/*$Header: ARRWLLTB.pls 120.4.12010000.9 2010/05/28 22:02:30 nemani ship $ */

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE Insert_Row (
    X_ROWID		 IN OUT NOCOPY				 VARCHAR2,
    X_APPLY_TO     	 	IN				 VARCHAR2,
    X_TAX_BALANCE  	     	IN				 NUMBER,
    X_CUSTOMER_TRX_LINE_ID	IN				 NUMBER,
    X_COMMENTS     	 	IN				 VARCHAR2,
    X_TAX          		IN				 NUMBER,
    X_CASH_RECEIPT_ID		IN				 NUMBER,
    X_ATTRIBUTE_CATEGORY	IN				 VARCHAR2,
    X_ALLOCATED_RECEIPT_AMOUNT	IN				 NUMBER,
    X_GROUP_ID     		IN				 NUMBER,
    X_TAX_DISCOUNT 		IN				 NUMBER,
    X_REFERENCE5   		IN				 VARCHAR2,
    X_REFERENCE4   		IN				 VARCHAR2,
    X_REFERENCE3   		IN				 VARCHAR2,
    X_AMOUNT       		IN				 NUMBER,
    X_LINE_DISCOUNT		IN				 NUMBER,
    X_REFERENCE2   		IN				 VARCHAR2,
    X_REFERENCE1   		IN				 VARCHAR2,
    X_ATTRIBUTE9   		IN				 VARCHAR2,
    X_ATTRIBUTE8   		IN				 VARCHAR2,
    X_ATTRIBUTE7   		IN				 VARCHAR2,
    X_ATTRIBUTE6   		IN				 VARCHAR2,
    X_ATTRIBUTE5   		IN				 VARCHAR2,
    X_ATTRIBUTE4   		IN				 VARCHAR2,
    X_ATTRIBUTE3   		IN				 VARCHAR2,
    X_ATTRIBUTE2   		IN				 VARCHAR2,
    X_ATTRIBUTE1   		IN				 VARCHAR2,
    X_LINE_BALANCE 		IN				 NUMBER,
    X_ATTRIBUTE15  		IN				 VARCHAR2,
    X_ATTRIBUTE14  		IN				 VARCHAR2,
    X_ATTRIBUTE13  		IN				 VARCHAR2,
    X_ATTRIBUTE12  		IN				 VARCHAR2,
    X_ATTRIBUTE11  		IN				 VARCHAR2,
    X_ATTRIBUTE10  		IN				 VARCHAR2,
    X_OBJECT_VERSION_NUMBER	IN				 NUMBER,
    X_CREATED_BY_MODULE		IN				 VARCHAR2
) IS

l_line_id   NUMBER;

BEGIN

    Select ar_activity_details_s.nextval
      INTO l_line_id
    from dual;

    INSERT INTO AR_ACTIVITY_DETAILS (
        LINE_ID,
        APPLY_TO,
        TAX_BALANCE,
        CUSTOMER_TRX_LINE_ID,
        COMMENTS,
        TAX,
        CASH_RECEIPT_ID,
        ATTRIBUTE_CATEGORY,
        ALLOCATED_RECEIPT_AMOUNT,
        GROUP_ID,
        TAX_DISCOUNT,
        REFERENCE5,
        REFERENCE4,
        REFERENCE3,
        AMOUNT,
        LINE_DISCOUNT,
        FREIGHT,
        FREIGHT_DISCOUNT,
        CHARGES,
        REFERENCE2,
        REFERENCE1,
        ATTRIBUTE9,
        ATTRIBUTE8,
        ATTRIBUTE7,
        ATTRIBUTE6,
        ATTRIBUTE5,
        ATTRIBUTE4,
        ATTRIBUTE3,
        ATTRIBUTE2,
        ATTRIBUTE1,
        LINE_BALANCE,
        ATTRIBUTE15,
        ATTRIBUTE14,
        ATTRIBUTE13,
        ATTRIBUTE12,
        ATTRIBUTE11,
        ATTRIBUTE10,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        OBJECT_VERSION_NUMBER,
        CREATED_BY_MODULE,
        SOURCE_TABLE,
	CURRENT_ACTIVITY_FLAG
    )
    VALUES (
        l_line_id,
        DECODE(X_APPLY_TO, FND_API.G_MISS_CHAR, NULL , X_APPLY_TO),
        DECODE(X_TAX_BALANCE, FND_API.G_MISS_NUM, NULL , X_TAX_BALANCE),
        DECODE(X_CUSTOMER_TRX_LINE_ID, FND_API.G_MISS_NUM, NULL , X_CUSTOMER_TRX_LINE_ID),
        DECODE(X_COMMENTS, FND_API.G_MISS_CHAR, NULL , X_COMMENTS),
        DECODE(X_TAX, FND_API.G_MISS_NUM, NULL , X_TAX),
        DECODE(X_CASH_RECEIPT_ID, FND_API.G_MISS_NUM, NULL , X_CASH_RECEIPT_ID),
        DECODE(X_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL , X_ATTRIBUTE_CATEGORY),
        DECODE(X_ALLOCATED_RECEIPT_AMOUNT, NULL,
               nvl(X_AMOUNT,0) + nvl(X_TAX,0)
        --       - nvl(X_LINE_DISCOUNT,0) - nvl(X_TAX_DISCOUNT,0) - nvl(X_FREIGHT_DISCOUNT,0)
               , X_ALLOCATED_RECEIPT_AMOUNT),
        DECODE(X_GROUP_ID, FND_API.G_MISS_NUM, NULL , X_GROUP_ID),
        DECODE(X_TAX_DISCOUNT, FND_API.G_MISS_NUM, NULL , X_TAX_DISCOUNT),
        DECODE(X_REFERENCE5, FND_API.G_MISS_CHAR, NULL , X_REFERENCE5),
        DECODE(X_REFERENCE4, FND_API.G_MISS_CHAR, NULL , X_REFERENCE4),
        DECODE(X_REFERENCE3, FND_API.G_MISS_CHAR, NULL , X_REFERENCE3),
        DECODE(X_APPLY_TO, 'FREIGHT', 0, 'CHARGES', 0, X_AMOUNT ),
        DECODE(X_APPLY_TO, 'FREIGHT', 0, 'CHARGES', 0, X_LINE_DISCOUNT),
        DECODE(X_APPLY_TO, 'FREIGHT', X_AMOUNT, 0),
        DECODE(X_APPLY_TO, 'FREIGHT', X_LINE_DISCOUNT, 0),
        DECODE(X_APPLY_TO, 'CHARGES', X_AMOUNT, 0),
        DECODE(X_REFERENCE2, FND_API.G_MISS_CHAR, NULL , X_REFERENCE2),
        DECODE(X_REFERENCE1, FND_API.G_MISS_CHAR, NULL , X_REFERENCE1),
        DECODE(X_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL , X_ATTRIBUTE9),
        DECODE(X_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL , X_ATTRIBUTE8),
        DECODE(X_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL , X_ATTRIBUTE7),
        DECODE(X_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL , X_ATTRIBUTE6),
        DECODE(X_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL , X_ATTRIBUTE5),
        DECODE(X_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL , X_ATTRIBUTE4),
        DECODE(X_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL , X_ATTRIBUTE3),
        DECODE(X_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL , X_ATTRIBUTE2),
        DECODE(X_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL , X_ATTRIBUTE1),
        DECODE(X_LINE_BALANCE, FND_API.G_MISS_NUM, NULL , X_LINE_BALANCE),
        DECODE(X_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL , X_ATTRIBUTE15),
        DECODE(X_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL , X_ATTRIBUTE14),
        DECODE(X_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL , X_ATTRIBUTE13),
        DECODE(X_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL , X_ATTRIBUTE12),
        DECODE(X_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL , X_ATTRIBUTE11),
        DECODE(X_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL , X_ATTRIBUTE10),
        NVL(FND_GLOBAL.user_id,-1),
        SYSDATE,
        decode(FND_GLOBAL.conc_login_id,null,FND_GLOBAL.login_id,-1,FND_GLOBAL.login_id,FND_GLOBAL.conc_login_id),
        SYSDATE,
        NVL(FND_GLOBAL.user_id,-1),
        DECODE( X_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, X_OBJECT_VERSION_NUMBER ),
        DECODE( X_CREATED_BY_MODULE, FND_API.G_MISS_CHAR, NULL, X_CREATED_BY_MODULE ),
        'RA',
	'Y'
        )RETURNING ROWID INTO X_ROWID;


END Insert_Row;

-- Bug 7241111
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    offset_row                                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Insert  the Offset row for updated/unapplied line                      |
 |    at apply_in_detail screen for a specific line.                         |
 |									     |
 | SCOPE - PUBLIC			                                     |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    X_CUSTOMER_TRX_LINE_ID                                 |
 |                    X_CASH_RECEIPT_ID                                      |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by mpsingh  - 19-SEP-2008                  |
 +===========================================================================*/

PROCEDURE offset_row (
 X_CUSTOMER_TRX_LINE_ID IN NUMBER,
 X_CASH_RECEIPT_ID      IN NUMBER
)
IS
 l_line_id NUMBER;
BEGIN

         IF PG_DEBUG in ('Y', 'C') THEN
	     arp_standard.debug('AR_ACTIVITY_DETAILS_PKG.offset_Row()+');
	 END IF;

   /* Select ar_activity_details_s.nextval
      INTO l_line_id
    from dual; */

  INSERT INTO AR_ACTIVITY_DETAILS(
                                CASH_RECEIPT_ID,
                                CUSTOMER_TRX_LINE_ID,
                                ALLOCATED_RECEIPT_AMOUNT,
                                AMOUNT,
                                TAX,
                                FREIGHT,
                                CHARGES,
                                LAST_UPDATE_DATE,
                                LAST_UPDATED_BY,
                                LINE_DISCOUNT,
                                TAX_DISCOUNT,
                                FREIGHT_DISCOUNT,
                                LINE_BALANCE,
                                TAX_BALANCE,
                                CREATION_DATE,
                                CREATED_BY,
                                LAST_UPDATE_LOGIN,
                                COMMENTS,
                                APPLY_TO,
                                ATTRIBUTE1,
                                ATTRIBUTE2,
                                ATTRIBUTE3,
                                ATTRIBUTE4,
                                ATTRIBUTE5,
                                ATTRIBUTE6,
                                ATTRIBUTE7,
                                ATTRIBUTE8,
                                ATTRIBUTE9,
                                ATTRIBUTE10,
                                ATTRIBUTE11,
                                ATTRIBUTE12,
                                ATTRIBUTE13,
                                ATTRIBUTE14,
                                ATTRIBUTE15,
                                ATTRIBUTE_CATEGORY,
                                GROUP_ID,
                                REFERENCE1,
                                REFERENCE2,
                                REFERENCE3,
                                REFERENCE4,
                                REFERENCE5,
                                OBJECT_VERSION_NUMBER,
                                CREATED_BY_MODULE,
                                SOURCE_ID,
                                SOURCE_TABLE,
                                LINE_ID,
			        CURRENT_ACTIVITY_FLAG)
                        SELECT
                                LLD.CASH_RECEIPT_ID,
                                LLD.CUSTOMER_TRX_LINE_ID,
                                LLD.ALLOCATED_RECEIPT_AMOUNT*-1,
                                LLD.AMOUNT*-1,
                                LLD.TAX*-1,
                                LLD.FREIGHT*-1,
                                LLD.CHARGES*-1,
                                LLD.LAST_UPDATE_DATE,
                                LLD.LAST_UPDATED_BY,
                                LLD.LINE_DISCOUNT,
                                LLD.TAX_DISCOUNT,
                                LLD.FREIGHT_DISCOUNT,
                                LLD.LINE_BALANCE,
                                LLD.TAX_BALANCE,
                                LLD.CREATION_DATE,
                                LLD.CREATED_BY,
                                LLD.LAST_UPDATE_LOGIN,
                                LLD.COMMENTS,
                                LLD.APPLY_TO,
                                LLD.ATTRIBUTE1,
                                LLD.ATTRIBUTE2,
                                LLD.ATTRIBUTE3,
                                LLD.ATTRIBUTE4,
                                LLD.ATTRIBUTE5,
                                LLD.ATTRIBUTE6,
                                LLD.ATTRIBUTE7,
                                LLD.ATTRIBUTE8,
                                LLD.ATTRIBUTE9,
                                LLD.ATTRIBUTE10,
                                LLD.ATTRIBUTE11,
                                LLD.ATTRIBUTE12,
                                LLD.ATTRIBUTE13,
                                LLD.ATTRIBUTE14,
                                LLD.ATTRIBUTE15,
                                LLD.ATTRIBUTE_CATEGORY,
                                LLD.GROUP_ID,
                                LLD.REFERENCE1,
                                LLD.REFERENCE2,
                                LLD.REFERENCE3,
                                LLD.REFERENCE4,
                                LLD.REFERENCE5,
                                LLD.OBJECT_VERSION_NUMBER,
                                LLD.CREATED_BY_MODULE,
                                LLD.SOURCE_ID,
                                LLD.SOURCE_TABLE,
                                ar_activity_details_s.nextval,
                                'R'
                        FROM ar_Activity_details LLD
		         WHERE  1 = 1  AND CUSTOMER_TRX_LINE_ID = X_CUSTOMER_TRX_LINE_ID
			 AND NVL(CURRENT_ACTIVITY_FLAG, 'Y') = 'Y'
			 AND CASH_RECEIPT_ID = X_CASH_RECEIPT_ID;


         UPDATE ar_Activity_details
		     set CURRENT_ACTIVITY_FLAG = 'N'
		         WHERE  1 = 1  AND CUSTOMER_TRX_LINE_ID = X_CUSTOMER_TRX_LINE_ID
			 AND NVL(CURRENT_ACTIVITY_FLAG, 'Y') = 'Y'
			 AND CASH_RECEIPT_ID = X_CASH_RECEIPT_ID;

         IF PG_DEBUG in ('Y', 'C') THEN
	     arp_standard.debug('AR_ACTIVITY_DETAILS_PKG.offset_Row()-');
	 END IF;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    Update_Row                                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This routine changed with the bug 7241111, which deals with sync of    |
 |    line level details under ar_activity_details with the Application      |
 |    (APP rows ) of the AR_receivable_applications.                         |
 |  									     |
 |    This will enable user to get each line level application/unapplication |
 |    details corresponding to the RA ID under AR_receivable_applications    |
 |    if the line level application is performed.                            |
 |									     |
 | SCOPE - PUBLIC			                                     |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                                                                           |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by mpsingh  - 19-SEP-2008                  |
 +===========================================================================*/


/*===========================================================================+
  CODE LOGIC
  1. Instead of updating the row, now we insert the offset
     row under ar_activity_details with negative amount of the original row
    ( routine used 'offset_row') with current_activity_flag as 'R' and source_id
    is of original row. And Update the current_activity_flag as 'N' for the original row.

  2. With the new updated amount we insert the new row under ar_activity_details,
     having current_activity_flag as 'Y' and source_id as NULL.

  3. Also from routine "reversal_insert_oppos_ra_recs " (ARCEAPPB.pls), we call routine
     'Chk_offset_Row' to enter the offset rows and new rows for the lines which are
     not updated/unapplied.

  4. Now under routine "reversal_insert_oppos_ra_recs " (ARCEAPPB.pls), we update
     the source_id for offset record inserted at point 1 and 3 with reversal APP record RA ID
     along with current_activity_flag as 'N'.

  5. The source_id of record point 2 and 3 will get updated with new APP record RA ID.



EXAMPLE :

    1. Perform Line Level application for two lines for amount 100 and 200 to the receipt of amount
       500.


     Rows Under RA table
     ~~~~~~~~~~~~~~~~~~~

     RA ID      AMOUNT    STATUS
     1           500       UNAPP
     2           -300      UNAPP
     3           300       APP

    ROWS UNDER ACTIVITY table
    ~~~~~~~~~~~~~~~~~~~~~~~~~
    Source_id  Amount  Current_activity_flag
    3           100       Y
    3           200       Y



-- Now user updated the Line amount from 200 to 50.

     Rows Under RA table
     ~~~~~~~~~~~~~~~~~~~

     RA ID      AMOUNT    STATUS
     1           500       UNAPP
     2           -300      UNAPP
     3           300       APP
     4           -300      APP
     5           300      UNAPP
     6           150      APP
     7           -150     UNAPP


-- Now rows under ACTIVITY table

Here I am taking the intermediate data record also to understand the code flow.

AFTER POINT 1 :

    ROWS UNDER ACTIVITY table
    ~~~~~~~~~~~~~~~~~~~~~~~~~
    Source_id  Amount  Current_activity_flag
    3           100       Y
    3           200       N
    3           -200      R


AFTER POINT 2 :

    ROWS UNDER ACTIVITY table
    ~~~~~~~~~~~~~~~~~~~~~~~~~
    Source_id  Amount  Current_activity_flag
    3           100       Y
    3           200       N
    3           -200      R
    -           50        Y

AFTER POINT 3 :

    ROWS UNDER ACTIVITY table
    ~~~~~~~~~~~~~~~~~~~~~~~~~
    Source_id  Amount  Current_activity_flag
    3           100       N
    3           200       N
    3           -200      R
    -           50        Y
    3           -100      R
    -           100       Y


AFTER POINT 4 :

    ROWS UNDER ACTIVITY table
    ~~~~~~~~~~~~~~~~~~~~~~~~~
    Source_id  Amount  Current_activity_flag
    3           100       N
    3           200       N
    4          -200       N
    -           50        Y
    4           -100      N
    -           100       Y

AFTER POINT 5 (Final look of Activity table):

    ROWS UNDER ACTIVITY table
    ~~~~~~~~~~~~~~~~~~~~~~~~~
    Source_id  Amount  Current_activity_flag
    3           100       N
    3           200       N
    4          -200       N
    6           50        Y
    4           -100      N
    6           100       Y

 +===========================================================================*/


PROCEDURE Update_Row (
    X_APPLY_TO     		 IN				 VARCHAR2,
    X_TAX_BALANCE  		 IN				 NUMBER,
    X_CUSTOMER_TRX_LINE_ID	 IN				 NUMBER,
    X_COMMENTS     		 IN				 VARCHAR2,
    X_TAX          		 IN				 NUMBER,
    X_CASH_RECEIPT_ID		 IN				 NUMBER,
    X_ATTRIBUTE_CATEGORY	 IN				 VARCHAR2,
    X_ALLOCATED_RECEIPT_AMOUNT	 IN				 NUMBER,
    X_GROUP_ID     		 IN				 NUMBER,
    X_TAX_DISCOUNT 		 IN				 NUMBER,
    X_REFERENCE5   		 IN				 VARCHAR2,
    X_REFERENCE4   		 IN				 VARCHAR2,
    X_REFERENCE3   		 IN				 VARCHAR2,
    X_AMOUNT       		 IN				 NUMBER,
    X_LINE_DISCOUNT		 IN				 NUMBER,
    X_REFERENCE2   		 IN				 VARCHAR2,
    X_REFERENCE1   		 IN				 VARCHAR2,
    X_ATTRIBUTE9   		 IN				 VARCHAR2,
    X_ATTRIBUTE8   		 IN				 VARCHAR2,
    X_ATTRIBUTE7   		 IN				 VARCHAR2,
    X_ATTRIBUTE6   		 IN				 VARCHAR2,
    X_ATTRIBUTE5   		 IN				 VARCHAR2,
    X_ATTRIBUTE4   		 IN				 VARCHAR2,
    X_ATTRIBUTE3   		 IN				 VARCHAR2,
    X_ATTRIBUTE2   		 IN				 VARCHAR2,
    X_ATTRIBUTE1   		 IN				 VARCHAR2,
    X_LINE_BALANCE 		 IN				 NUMBER,
    X_ATTRIBUTE15  		 IN				 VARCHAR2,
    X_ATTRIBUTE14  		 IN				 VARCHAR2,
    X_ATTRIBUTE13  		 IN				 VARCHAR2,
    X_ATTRIBUTE12  		 IN				 VARCHAR2,
    X_ATTRIBUTE11  		 IN				 VARCHAR2,
    X_ATTRIBUTE10  		 IN				 VARCHAR2,
    X_OBJECT_VERSION_NUMBER	 IN				 NUMBER,
    X_CREATED_BY_MODULE		 IN				 VARCHAR2
) IS

p_rowid rowid;

BEGIN


-- Bug 7241111

     offset_row(X_CUSTOMER_TRX_LINE_ID,
                X_CASH_RECEIPT_ID);

-- Instead of update now inserting new rows with latest amounts.


insert_row(
          x_rowid                    =>           p_rowid                       ,
          x_cash_receipt_id          => 	  x_cash_receipt_id           	,
          x_customer_trx_line_id     =>	          x_customer_trx_line_id    	,
          x_attribute2               => 	          x_attribute2                	,
          x_attribute3               => 	          x_attribute3                	,
          x_attribute4               => 	          x_attribute4                	,
          x_attribute5               => 	          x_attribute5                	,
          x_attribute6               => 	          x_attribute6                	,
          x_attribute7               => 	          x_attribute7                	,
          x_attribute8               => 	          x_attribute8                	,
          x_attribute9               => 	          x_attribute9                	,
          x_attribute_category       => 	          x_attribute_category        	,
          x_allocated_receipt_amount => 	          x_allocated_receipt_amount  	,
          x_amount                   => 	          x_amount                    	,
          x_tax                      => 	          x_tax                       	,
          x_line_discount            => 	          x_line_discount             	,
          x_tax_discount             => 	          x_tax_discount              	,
          x_line_balance             => 	          x_line_balance              	,
          x_tax_balance              => 	          x_tax_balance               	,
          x_comments                 => 	          x_comments                  	,
          x_apply_to                 => 	          x_apply_to                  	,
          x_attribute1               => 	          x_attribute1                	,
          x_attribute10              => 	          x_attribute10               	,
          x_attribute11              => 	          x_attribute11               	,
          x_attribute12              => 	          x_attribute12               	,
          x_attribute13              => 	          x_attribute13               	,
          x_attribute14              => 	          x_attribute14               	,
          x_attribute15              => 	          x_attribute15               	,
          x_group_id                 => 	          x_group_id                  	,
          x_object_version_number    => 	          x_object_version_number     	,
          x_created_by_module        => 	          x_created_by_module         	,
          x_reference1               => 	          x_reference1                	,
          x_reference2               => 	          x_reference2                	,
          x_reference3               => 	          x_reference3                	,
          x_reference4               => 	          x_reference4                	,
          x_reference5               => 	          x_reference5
       );

END Update_Row;



PROCEDURE Delete_Row (
    X_CUSTOMER_TRX_LINE_ID			 IN				 NUMBER,
    X_CASH_RECEIPT_ID				 IN				 NUMBER
) IS


BEGIN

    DELETE AR_ACTIVITY_DETAILS
    WHERE  1 = 1  AND CUSTOMER_TRX_LINE_ID = X_CUSTOMER_TRX_LINE_ID
 AND NVL(CURRENT_ACTIVITY_FLAG, 'Y') = 'Y' -- BUG 7241111
 AND CASH_RECEIPT_ID = X_CASH_RECEIPT_ID
;


    IF ( SQL%NOTFOUND ) THEN
    -- 18 Oct 05 Need not raise error if there is no data
    /*RAISE NO_DATA_FOUND;
    */ null;
    END IF;


END Delete_Row;

procedure select_summary (x_customer_Trx_id in number,
                          x_cash_receipt_id in number,
                          x_total in out NOCOPY number,
                          x_total_rtot_db in out NOCOPY number) IS
begin
  select sum(nvl(line_discount,0)+nvl(tax_discount,0))
  into x_total
  from ar_ll_lines_groups_v
  where customer_Trx_id =  x_customer_Trx_id
  and cash_receipt_id = x_cash_receipt_id;

  x_total_rtot_db := x_total;

end select_summary;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    Chk_offset_Row                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Inserts the remaining Offset rows incase of update/unapply             |
 |    performs by user at apply_in_detail screen.                            |
 |									     |
 | SCOPE - PUBLIC			                                     |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    X_RECEIVABLE_APPLICATION_ID                            |
 |                    X_CASH_RECEIPT_ID                                      |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by mpsingh  - 19-SEP-2008                  |
 +===========================================================================*/

PROCEDURE Chk_offset_Row (
    X_RECEIVABLE_APPLICATION_ID			 IN				 NUMBER,
    X_OLD_RECEIVABLE_APP_ID                      IN                              NUMBER,
    X_CASH_RECEIPT_ID				 IN				 NUMBER
) is
  l_activity_amt number;
  l_ra_amt       number;

BEGIN


	      IF PG_DEBUG in ('Y', 'C') THEN
		     arp_standard.debug('AR_ACTIVITY_DETAILS_PKG.Chk_offset_Row()+');
	      END IF;

             begin

			select  sum( nvl(amount,0)+ nvl(tax,0)+ nvl(freight,0)+ nvl(charges,0) )
			into l_activity_amt
			from  ar_Activity_details
			where cash_receipt_id = X_CASH_RECEIPT_ID
			and NVL(source_id,-1) = X_OLD_RECEIVABLE_APP_ID
			and source_table = 'RA'
			and nvl(CURRENT_ACTIVITY_FLAG,'Y') = 'R';


			Select amount_applied into l_ra_amt
			from ar_receivable_applications
			where receivable_application_id = X_RECEIVABLE_APPLICATION_ID;


		exception
			  when others then
			    IF PG_DEBUG in ('Y', 'C') THEN
			     arp_standard.debug('ERROR : Chk_offset_Row ' || ' UNABLE TO GET AMT TOTALS FOR ACTIVITY_DETAILS AND RA TABLES' );
			    END IF;
			   null;
		end;

                 -- If the RA amount is different then the Activity table amount,we need to insert offset rows.

	           IF NVL(l_activity_amt,0) <> NVL(l_ra_amt,0) THEN

                    INSERT INTO AR_ACTIVITY_DETAILS(
                                CASH_RECEIPT_ID,
                                CUSTOMER_TRX_LINE_ID,
                                ALLOCATED_RECEIPT_AMOUNT,
                                AMOUNT,
                                TAX,
                                FREIGHT,
                                CHARGES,
                                LAST_UPDATE_DATE,
                                LAST_UPDATED_BY,
                                LINE_DISCOUNT,
                                TAX_DISCOUNT,
                                FREIGHT_DISCOUNT,
                                LINE_BALANCE,
                                TAX_BALANCE,
                                CREATION_DATE,
                                CREATED_BY,
                                LAST_UPDATE_LOGIN,
                                COMMENTS,
                                APPLY_TO,
                                ATTRIBUTE1,
                                ATTRIBUTE2,
                                ATTRIBUTE3,
                                ATTRIBUTE4,
                                ATTRIBUTE5,
                                ATTRIBUTE6,
                                ATTRIBUTE7,
                                ATTRIBUTE8,
                                ATTRIBUTE9,
                                ATTRIBUTE10,
                                ATTRIBUTE11,
                                ATTRIBUTE12,
                                ATTRIBUTE13,
                                ATTRIBUTE14,
                                ATTRIBUTE15,
                                ATTRIBUTE_CATEGORY,
                                GROUP_ID,
                                REFERENCE1,
                                REFERENCE2,
                                REFERENCE3,
                                REFERENCE4,
                                REFERENCE5,
                                OBJECT_VERSION_NUMBER,
                                CREATED_BY_MODULE,
                                SOURCE_ID,
                                SOURCE_TABLE,
                                LINE_ID,
			        CURRENT_ACTIVITY_FLAG,
				OFFSET_REC_FLAG)
                        SELECT
                                LLD.CASH_RECEIPT_ID,
                                LLD.CUSTOMER_TRX_LINE_ID,
                                 LLD.ALLOCATED_RECEIPT_AMOUNT*-1,
                                LLD.AMOUNT*-1,
                                LLD.TAX*-1,
                                LLD.FREIGHT*-1,
                                LLD.CHARGES*-1,
                                LLD.LAST_UPDATE_DATE,
                                LLD.LAST_UPDATED_BY,
                                LLD.LINE_DISCOUNT,
                                LLD.TAX_DISCOUNT,
                                LLD.FREIGHT_DISCOUNT,
                                LLD.LINE_BALANCE,
                                LLD.TAX_BALANCE,
                                LLD.CREATION_DATE,
                                LLD.CREATED_BY,
                                LLD.LAST_UPDATE_LOGIN,
                                LLD.COMMENTS,
                                LLD.APPLY_TO,
                                LLD.ATTRIBUTE1,
                                LLD.ATTRIBUTE2,
                                LLD.ATTRIBUTE3,
                                LLD.ATTRIBUTE4,
                                LLD.ATTRIBUTE5,
                                LLD.ATTRIBUTE6,
                                LLD.ATTRIBUTE7,
                                LLD.ATTRIBUTE8,
                                LLD.ATTRIBUTE9,
                                LLD.ATTRIBUTE10,
                                LLD.ATTRIBUTE11,
                                LLD.ATTRIBUTE12,
                                LLD.ATTRIBUTE13,
                                LLD.ATTRIBUTE14,
                                LLD.ATTRIBUTE15,
                                LLD.ATTRIBUTE_CATEGORY,
                                LLD.GROUP_ID,
                                LLD.REFERENCE1,
                                LLD.REFERENCE2,
                                LLD.REFERENCE3,
                                LLD.REFERENCE4,
                                LLD.REFERENCE5,
                                LLD.OBJECT_VERSION_NUMBER,
                                LLD.CREATED_BY_MODULE,
                                LLD.SOURCE_ID,
                                LLD.SOURCE_TABLE,
                                ar_activity_details_s.nextval,
                                'R',
				'Y'
                         FROM ar_Activity_details LLD
		         WHERE cash_receipt_id = X_CASH_RECEIPT_ID
		         and NVl(source_id,-1) = X_OLD_RECEIVABLE_APP_ID
		         and source_table = 'RA'
			 AND NVL(CURRENT_ACTIVITY_FLAG, 'Y') = 'Y';

			 INSERT INTO AR_ACTIVITY_DETAILS(
                                CASH_RECEIPT_ID,
                                CUSTOMER_TRX_LINE_ID,
                                ALLOCATED_RECEIPT_AMOUNT,
                                AMOUNT,
                                TAX,
                                FREIGHT,
                                CHARGES,
                                LAST_UPDATE_DATE,
                                LAST_UPDATED_BY,
                                LINE_DISCOUNT,
                                TAX_DISCOUNT,
                                FREIGHT_DISCOUNT,
                                LINE_BALANCE,
                                TAX_BALANCE,
                                CREATION_DATE,
                                CREATED_BY,
                                LAST_UPDATE_LOGIN,
                                COMMENTS,
                                APPLY_TO,
                                ATTRIBUTE1,
                                ATTRIBUTE2,
                                ATTRIBUTE3,
                                ATTRIBUTE4,
                                ATTRIBUTE5,
                                ATTRIBUTE6,
                                ATTRIBUTE7,
                                ATTRIBUTE8,
                                ATTRIBUTE9,
                                ATTRIBUTE10,
                                ATTRIBUTE11,
                                ATTRIBUTE12,
                                ATTRIBUTE13,
                                ATTRIBUTE14,
                                ATTRIBUTE15,
                                ATTRIBUTE_CATEGORY,
                                GROUP_ID,
                                REFERENCE1,
                                REFERENCE2,
                                REFERENCE3,
                                REFERENCE4,
                                REFERENCE5,
                                OBJECT_VERSION_NUMBER,
                                CREATED_BY_MODULE,
                                SOURCE_ID,
                                SOURCE_TABLE,
                                LINE_ID,
			        CURRENT_ACTIVITY_FLAG,
				OFFSET_REC_FLAG)
                        SELECT
                                LLD.CASH_RECEIPT_ID,
                                LLD.CUSTOMER_TRX_LINE_ID,
                                LLD.ALLOCATED_RECEIPT_AMOUNT,
                                LLD.AMOUNT,
                                LLD.TAX,
                                LLD.FREIGHT,
                                LLD.CHARGES,
                                sysdate,
                                NVL(FND_GLOBAL.user_id,-1),
                                LLD.LINE_DISCOUNT,
                                LLD.TAX_DISCOUNT,
                                LLD.FREIGHT_DISCOUNT,
                                LLD.LINE_BALANCE,
                                LLD.TAX_BALANCE,
                                sysdate,
                                NVL(FND_GLOBAL.user_id,-1),
                                NVL(arp_standard.profile.last_update_login,lld.last_update_login),
                                LLD.COMMENTS,
                                LLD.APPLY_TO,
                                LLD.ATTRIBUTE1,
                                LLD.ATTRIBUTE2,
                                LLD.ATTRIBUTE3,
                                LLD.ATTRIBUTE4,
                                LLD.ATTRIBUTE5,
                                LLD.ATTRIBUTE6,
                                LLD.ATTRIBUTE7,
                                LLD.ATTRIBUTE8,
                                LLD.ATTRIBUTE9,
                                LLD.ATTRIBUTE10,
                                LLD.ATTRIBUTE11,
                                LLD.ATTRIBUTE12,
                                LLD.ATTRIBUTE13,
                                LLD.ATTRIBUTE14,
                                LLD.ATTRIBUTE15,
                                LLD.ATTRIBUTE_CATEGORY,
                                LLD.GROUP_ID,
                                LLD.REFERENCE1,
                                LLD.REFERENCE2,
                                LLD.REFERENCE3,
                                LLD.REFERENCE4,
                                LLD.REFERENCE5,
                                LLD.OBJECT_VERSION_NUMBER,
                                LLD.CREATED_BY_MODULE,
                                NULL,
                                LLD.SOURCE_TABLE,
                                ar_activity_details_s.nextval,
                                'Y',
				'Y'
                         FROM ar_Activity_details LLD
		         WHERE cash_receipt_id = X_CASH_RECEIPT_ID
		         and NVL(source_id,-1) = X_OLD_RECEIVABLE_APP_ID
		         and source_table = 'RA'
			 AND NVL(CURRENT_ACTIVITY_FLAG, 'Y') = 'Y';


			  UPDATE ar_Activity_details
		         set CURRENT_ACTIVITY_FLAG = 'N'
		          WHERE cash_receipt_id = X_CASH_RECEIPT_ID
		         and NVL(source_id,-1) = X_OLD_RECEIVABLE_APP_ID
		         and source_table = 'RA'
			 AND NVL(CURRENT_ACTIVITY_FLAG, 'Y') = 'Y';


		 END IF;


         IF PG_DEBUG in ('Y', 'C') THEN
	     arp_standard.debug('Amount total under AR_ACTIVITY_DETAILS : '|| l_activity_amt );
	     arp_standard.debug('Amount total under RECEIVABLE_APPLICATIONS  : '|| l_ra_amt );
	 END IF;


	 IF PG_DEBUG in ('Y', 'C') THEN
	     arp_standard.debug('AR_ACTIVITY_DETAILS_PKG.Chk_offset_Row()-');
	 END IF;

END Chk_offset_Row;


END AR_ACTIVITY_DETAILS_PKG;

/
