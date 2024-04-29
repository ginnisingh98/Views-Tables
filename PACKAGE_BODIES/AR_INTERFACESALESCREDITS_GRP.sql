--------------------------------------------------------
--  DDL for Package Body AR_INTERFACESALESCREDITS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_INTERFACESALESCREDITS_GRP" AS
/* $Header: ARXGISCB.pls 115.3 2003/10/02 22:19:34 kmahajan noship $ */

/*========================================================================
 | PUBLIC Procedure Insert_SalesCredit
 |
 | DESCRIPTION
 |       This function inserts a row into RA_INTERFACE_SALESCREDITS_ALL and
 |	 is passed all the data in p_salescredit_rec
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
 | 02-OCT-2003		 K.Mahajan	Added update of salesgroup_id column
 |					- dependency on arati.odf 115.19
 *=======================================================================*/
 PROCEDURE insert_salescredit(
               p_salescredit_rec IN
                              salescredit_rec_type,
               x_return_status   OUT NOCOPY VARCHAR2,
               x_msg_count       OUT NOCOPY NUMBER,
               x_msg_data        OUT NOCOPY VARCHAR2
               ) IS

BEGIN
    arp_util.debug('AR_InterfaceSalesCredits_GRP.insert_salescredit (+)');
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    INSERT INTO ra_interface_salescredits_all
    (
        INTERFACE_SALESCREDIT_ID      ,
        INTERFACE_LINE_ID             ,
        INTERFACE_LINE_CONTEXT        ,
        INTERFACE_LINE_ATTRIBUTE1     ,
        INTERFACE_LINE_ATTRIBUTE2     ,
        INTERFACE_LINE_ATTRIBUTE3     ,
        INTERFACE_LINE_ATTRIBUTE4     ,
        INTERFACE_LINE_ATTRIBUTE5     ,
        INTERFACE_LINE_ATTRIBUTE6     ,
        INTERFACE_LINE_ATTRIBUTE7     ,
        INTERFACE_LINE_ATTRIBUTE8     ,
        INTERFACE_LINE_ATTRIBUTE9     ,
        INTERFACE_LINE_ATTRIBUTE10    ,
        INTERFACE_LINE_ATTRIBUTE11    ,
        INTERFACE_LINE_ATTRIBUTE12    ,
        INTERFACE_LINE_ATTRIBUTE13    ,
        INTERFACE_LINE_ATTRIBUTE14    ,
        INTERFACE_LINE_ATTRIBUTE15    ,
        SALESREP_NUMBER               ,
        SALESREP_ID                   ,
        SALESGROUP_ID                 ,
        SALES_CREDIT_TYPE_NAME        ,
        SALES_CREDIT_TYPE_ID          ,
        SALES_CREDIT_AMOUNT_SPLIT     ,
        SALES_CREDIT_PERCENT_SPLIT    ,
        INTERFACE_STATUS              ,
        REQUEST_ID                    ,
        ATTRIBUTE_CATEGORY            ,
        ATTRIBUTE1                    ,
        ATTRIBUTE2                    ,
        ATTRIBUTE3                    ,
        ATTRIBUTE4                    ,
        ATTRIBUTE5                    ,
        ATTRIBUTE6                    ,
        ATTRIBUTE7                    ,
        ATTRIBUTE8                    ,
        ATTRIBUTE9                    ,
        ATTRIBUTE10                   ,
        ATTRIBUTE11                   ,
        ATTRIBUTE12                   ,
        ATTRIBUTE13                   ,
        ATTRIBUTE14                   ,
        ATTRIBUTE15                   ,
        CREATED_BY                    ,
        CREATION_DATE                 ,
        LAST_UPDATED_BY               ,
        LAST_UPDATE_DATE              ,
        LAST_UPDATE_LOGIN             ,
        ORG_ID
    )
    VALUES
    (
        p_salescredit_rec.INTERFACE_SALESCREDIT_ID      ,
        p_salescredit_rec.INTERFACE_LINE_ID             ,
        p_salescredit_rec.INTERFACE_LINE_CONTEXT        ,
        p_salescredit_rec.INTERFACE_LINE_ATTRIBUTE1     ,
        p_salescredit_rec.INTERFACE_LINE_ATTRIBUTE2     ,
        p_salescredit_rec.INTERFACE_LINE_ATTRIBUTE3     ,
        p_salescredit_rec.INTERFACE_LINE_ATTRIBUTE4     ,
        p_salescredit_rec.INTERFACE_LINE_ATTRIBUTE5     ,
        p_salescredit_rec.INTERFACE_LINE_ATTRIBUTE6     ,
        p_salescredit_rec.INTERFACE_LINE_ATTRIBUTE7     ,
        p_salescredit_rec.INTERFACE_LINE_ATTRIBUTE8     ,
        p_salescredit_rec.INTERFACE_LINE_ATTRIBUTE9     ,
        p_salescredit_rec.INTERFACE_LINE_ATTRIBUTE10    ,
        p_salescredit_rec.INTERFACE_LINE_ATTRIBUTE11    ,
        p_salescredit_rec.INTERFACE_LINE_ATTRIBUTE12    ,
        p_salescredit_rec.INTERFACE_LINE_ATTRIBUTE13    ,
        p_salescredit_rec.INTERFACE_LINE_ATTRIBUTE14    ,
        p_salescredit_rec.INTERFACE_LINE_ATTRIBUTE15    ,
        p_salescredit_rec.SALESREP_NUMBER               ,
        p_salescredit_rec.SALESREP_ID                   ,
        p_salescredit_rec.SALESGROUP_ID                 ,
        p_salescredit_rec.SALES_CREDIT_TYPE_NAME        ,
        p_salescredit_rec.SALES_CREDIT_TYPE_ID          ,
        p_salescredit_rec.SALES_CREDIT_AMOUNT_SPLIT     ,
        p_salescredit_rec.SALES_CREDIT_PERCENT_SPLIT    ,
        p_salescredit_rec.INTERFACE_STATUS              ,
        p_salescredit_rec.REQUEST_ID                    ,
        p_salescredit_rec.ATTRIBUTE_CATEGORY            ,
        p_salescredit_rec.ATTRIBUTE1                    ,
        p_salescredit_rec.ATTRIBUTE2                    ,
        p_salescredit_rec.ATTRIBUTE3                    ,
        p_salescredit_rec.ATTRIBUTE4                    ,
        p_salescredit_rec.ATTRIBUTE5                    ,
        p_salescredit_rec.ATTRIBUTE6                    ,
        p_salescredit_rec.ATTRIBUTE7                    ,
        p_salescredit_rec.ATTRIBUTE8                    ,
        p_salescredit_rec.ATTRIBUTE9                    ,
        p_salescredit_rec.ATTRIBUTE10                   ,
        p_salescredit_rec.ATTRIBUTE11                   ,
        p_salescredit_rec.ATTRIBUTE12                   ,
        p_salescredit_rec.ATTRIBUTE13                   ,
        p_salescredit_rec.ATTRIBUTE14                   ,
        p_salescredit_rec.ATTRIBUTE15                   ,
        p_salescredit_rec.CREATED_BY                    ,
        p_salescredit_rec.CREATION_DATE                 ,
        p_salescredit_rec.LAST_UPDATED_BY               ,
        p_salescredit_rec.LAST_UPDATE_DATE              ,
        p_salescredit_rec.LAST_UPDATE_LOGIN             ,
        p_salescredit_rec.ORG_ID
    );

    arp_util.debug('AR_InterfaceSalesCredits_GRP.insert_salescredit (-)');

EXCEPTION
    WHEN OTHERS THEN
    	arp_util.debug('EXCEPTION: (' || sqlcode || ': ' || sqlerrm ||') AR_InterfaceSalesCredits_GRP.insert_salescredit()');
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END insert_salescredit;

END AR_InterfaceSalesCredits_GRP;

/
