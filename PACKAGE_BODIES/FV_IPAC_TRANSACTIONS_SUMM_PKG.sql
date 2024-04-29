--------------------------------------------------------
--  DDL for Package Body FV_IPAC_TRANSACTIONS_SUMM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_IPAC_TRANSACTIONS_SUMM_PKG" as
/*  $Header: FVIPATHB.pls 120.4 2003/12/17 21:21:01 ksriniva ship $ */
  g_module_name VARCHAR2(100) := 'fv.plsql.FV_IPAC_TRANSACTIONS_SUMM_PKG.';

PROCEDURE Insert_Row(X_ROWID 	              IN OUT NOCOPY  VARCHAR2,
                     X_IPAC_BILLING_ID        IN OUT NOCOPY  NUMBER,
		     X_CUSTOMER_TRX_ID                NUMBER ,
                     X_CUSTOMER_ID                    NUMBER ,
                     X_CUSTOMER_NAME                  VARCHAR2 ,
                     X_TAXPAYER_NUMBER                VARCHAR2 ,
                     X_TRX_NUMBER                     VARCHAR2 ,
                     X_TRX_DATE                       DATE ,
                     X_PO_NUMBER                      VARCHAR2 ,
                     X_CONTRACT_NO                    VARCHAR2 ,
                     X_CLIN                           VARCHAR2 ,
                     X_SENDER_ALC                     VARCHAR2 ,
                     X_SENDER_DO_SYM                  VARCHAR2 ,
                     X_TRN_SET_ID                     NUMBER  ,
                     X_ORG_DCM_RFR                    VARCHAR2 ,
                     X_ORG_ACC_DT                     DATE ,
                     X_DPR_CD                         VARCHAR2 ,
                     X_DSC                            VARCHAR2 ,
                     X_OBL_DCM_NR                     VARCHAR2 ,
                     X_PAY_FLG                        VARCHAR2 ,
                     X_QTY                            NUMBER ,
                     X_SND_APP_SYM                    VARCHAR2 ,
                     X_UNT_ISS                        VARCHAR2 ,
                     X_UNT_PRC                        NUMBER ,
                     X_ORG_LN_ITM                     NUMBER ,
                     X_EXCLUDE_FLAG                   VARCHAR2 ,
                     X_PROCESSED_FLAG                 VARCHAR2 ,
                     X_RUN_DATE                       DATE ,
                     X_SET_OF_BOOKS_ID                NUMBER ,
                     X_EXCEPTION_CATEGORY             VARCHAR2 ,
                     X_ORG_ID                         NUMBER ,
                     X_LAST_UPDATE_DATE               DATE ,
                     X_LAST_UPDATED_BY                NUMBER ,
                     X_LAST_UPDATE_LOGIN              NUMBER ,
                     X_CREATION_DATE                  DATE ,
                     X_CREATED_BY                     NUMBER ,
                     X_ATTRIBUTE1                     VARCHAR2 ,
                     X_ATTRIBUTE2                     VARCHAR2 ,
                     X_ATTRIBUTE3                     VARCHAR2 ,
                     X_ATTRIBUTE4                     VARCHAR2 ,
                     X_ATTRIBUTE5                     VARCHAR2 ,
                     X_ATTRIBUTE6                     VARCHAR2 ,
                     X_ATTRIBUTE7                     VARCHAR2 ,
                     X_ATTRIBUTE8                     VARCHAR2 ,
                     X_ATTRIBUTE9                     VARCHAR2 ,
                     X_ATTRIBUTE10                    VARCHAR2 ,
                     X_ATTRIBUTE11                    VARCHAR2 ,
                     X_ATTRIBUTE12                    VARCHAR2 ,
                     X_ATTRIBUTE13                    VARCHAR2 ,
                     X_ATTRIBUTE14                    VARCHAR2 ,
                     X_ATTRIBUTE15                    VARCHAR2 ,
  -- Commented the below lines for the Bug # 2145501
                  /* X_ATTRIBUTE16                    VARCHAR2 ,
                     X_ATTRIBUTE17                    VARCHAR2 ,
                     X_ATTRIBUTE18                    VARCHAR2 ,
                     X_ATTRIBUTE19                    VARCHAR2 ,
                     X_ATTRIBUTE20                    VARCHAR2 ,
                     X_ATTRIBUTE21                    VARCHAR2 ,
                     X_ATTRIBUTE22                    VARCHAR2 ,
                     X_ATTRIBUTE23                    VARCHAR2 ,
                     X_ATTRIBUTE24                    VARCHAR2 ,
                     X_ATTRIBUTE25                    VARCHAR2 ,
                     X_ATTRIBUTE26                    VARCHAR2 ,
                     X_ATTRIBUTE27                    VARCHAR2 ,
                     X_ATTRIBUTE28                    VARCHAR2 ,
                     X_ATTRIBUTE29                    VARCHAR2 ,
                     X_ATTRIBUTE30                    VARCHAR2 ,    */
                     X_ATTRIBUTE_CATEGORY             VARCHAR2 ,
                     X_ADJUSTMENT_ID                  NUMBER ,
                     X_AMOUNT                         NUMBER ,
                     X_REPORT_FLAG                    VARCHAR2 ,
                     X_CNT_NM                         VARCHAR2 ,
                     X_CNT_PHN_NR                     VARCHAR2 ,
                     X_TRX_LINE_NO                    NUMBER ,
                     X_ORG_DO_SYM                     VARCHAR2
		    ) IS

  l_module_name VARCHAR2(200) := g_module_name || 'Insert_Row';
  l_errbuf      VARCHAR2(1024);
    x_ipac_billing_id_v  NUMBER;

	CURSOR C_ROW_ID IS SELECT ROWID FROM FV_IPAC_TRX
		    WHERE IPAC_BILLING_ID = x_ipac_billing_id_v;
  BEGIN

        SELECT FV_IPAC_BILLING_ID_S.NEXTVAL INTO x_ipac_billing_id
        FROM DUAL;

	INSERT INTO FV_IPAC_TRX(

	                CUSTOMER_TRX_ID,
  			CUSTOMER_ID ,
  			CUSTOMER_NAME  ,
  			TAXPAYER_NUMBER  ,
  			TRX_NUMBER ,
  			TRX_DATE  ,
  			PO_NUMBER  ,
  			CONTRACT_NO  ,
  			CLIN  ,
  			SENDER_ALC  ,
  			SENDER_DO_SYM  ,
  			TRN_SET_ID  ,
  			ORG_DCM_RFR  ,
  			ORG_ACC_DT  ,
  			DPR_CD  ,
  			DSC  ,
  			OBL_DCM_NR  ,
  			PAY_FLG  ,
  			QTY  ,
  			SND_APP_SYM  ,
  			UNT_ISS  ,
  			UNT_PRC  ,
  			ORG_LN_ITM  ,
  			EXCLUDE_FLAG  ,
  			PROCESSED_FLAG ,
  			RUN_DATE  ,
  			SET_OF_BOOKS_ID  ,
  			EXCEPTION_CATEGORY  ,
  			ORG_ID  ,
  			LAST_UPDATE_DATE  ,
  			LAST_UPDATED_BY  ,
  			LAST_UPDATE_LOGIN  ,
  			CREATION_DATE  ,
  			CREATED_BY  ,
  			ATTRIBUTE1  ,
  			ATTRIBUTE2  ,
  			ATTRIBUTE3  ,
  			ATTRIBUTE4  ,
  			ATTRIBUTE5  ,
  			ATTRIBUTE6  ,
  			ATTRIBUTE7  ,
  			ATTRIBUTE8  ,
  			ATTRIBUTE9  ,
  			ATTRIBUTE10  ,
  			ATTRIBUTE11  ,
 		        ATTRIBUTE12  ,
  			ATTRIBUTE13  ,
  			ATTRIBUTE14  ,
  			ATTRIBUTE15  ,
        -- Commented the below code for the Bug# 2145501
  	/*		ATTRIBUTE16  ,
  			ATTRIBUTE17  ,
  			ATTRIBUTE18  ,
  			ATTRIBUTE19  ,
  			ATTRIBUTE20  ,
  			ATTRIBUTE21  ,
  			ATTRIBUTE22  ,
  			ATTRIBUTE23  ,
  			ATTRIBUTE24  ,
  			ATTRIBUTE25  ,
  			ATTRIBUTE26  ,
  			ATTRIBUTE27  ,
  			ATTRIBUTE28  ,
  			ATTRIBUTE29  ,
  			ATTRIBUTE30  , */
  			ATTRIBUTE_CATEGORY  ,
  			ADJUSTMENT_ID  ,
  			AMOUNT  ,
  			REPORT_FLAG  ,
  			CNT_NM  ,
  			CNT_PHN_NR  ,
  			TRX_LINE_NO  ,
  			ORG_DO_SYM ,
  			IPAC_BILLING_ID
  			)
 	VALUES(	        X_CUSTOMER_TRX_ID,
                        X_CUSTOMER_ID ,
 			X_CUSTOMER_NAME  ,
  			X_TAXPAYER_NUMBER  ,
  			X_TRX_NUMBER ,
 			X_TRX_DATE  ,
  			X_PO_NUMBER  ,
  			X_CONTRACT_NO  ,
  			X_CLIN  ,
  			X_SENDER_ALC  ,
  			X_SENDER_DO_SYM  ,
  			X_TRN_SET_ID  ,
  			X_ORG_DCM_RFR  ,
  			X_ORG_ACC_DT  ,
  			X_DPR_CD  ,
  			X_DSC  ,
  			X_OBL_DCM_NR  ,
  			X_PAY_FLG  ,
  			X_QTY  ,
  			X_SND_APP_SYM  ,
  			X_UNT_ISS  ,
  			X_UNT_PRC  ,
  			X_ORG_LN_ITM  ,
  			X_EXCLUDE_FLAG  ,
  			X_PROCESSED_FLAG ,
  			X_RUN_DATE  ,
  			X_SET_OF_BOOKS_ID  ,
  			X_EXCEPTION_CATEGORY  ,
  			X_ORG_ID  ,
  			X_LAST_UPDATE_DATE  ,
  			X_LAST_UPDATED_BY  ,
  			X_LAST_UPDATE_LOGIN  ,
  			X_CREATION_DATE  ,
  			X_CREATED_BY  ,
  			X_ATTRIBUTE1  ,
  			X_ATTRIBUTE2  ,
  			X_ATTRIBUTE3  ,
  			X_ATTRIBUTE4  ,
  			X_ATTRIBUTE5  ,
  			X_ATTRIBUTE6  ,
  			X_ATTRIBUTE7  ,
  			X_ATTRIBUTE8  ,
  			X_ATTRIBUTE9  ,
  			X_ATTRIBUTE10  ,
  			X_ATTRIBUTE11  ,
  			X_ATTRIBUTE12  ,
  			X_ATTRIBUTE13  ,
  			X_ATTRIBUTE14  ,
  			X_ATTRIBUTE15  ,
          -- Commented the below Code for Bug# 2145501
  	 /*		X_ATTRIBUTE16  ,
  			X_ATTRIBUTE17  ,
  			X_ATTRIBUTE18  ,
  			X_ATTRIBUTE19  ,
  			X_ATTRIBUTE20  ,
  			X_ATTRIBUTE21  ,
  			X_ATTRIBUTE22  ,
  			X_ATTRIBUTE23  ,
  			X_ATTRIBUTE24  ,
  			X_ATTRIBUTE25  ,
  			X_ATTRIBUTE26  ,
  			X_ATTRIBUTE27  ,
  			X_ATTRIBUTE28  ,
  			X_ATTRIBUTE29  ,
  			X_ATTRIBUTE30  ,   */
  			X_ATTRIBUTE_CATEGORY  ,
  			X_ADJUSTMENT_ID  ,
  			X_AMOUNT  ,
  			X_REPORT_FLAG  ,
  			X_CNT_NM  ,
  			X_CNT_PHN_NR  ,
  			X_TRX_LINE_NO  ,
  			X_ORG_DO_SYM ,
  			x_ipac_billing_id_v
			);
	OPEN C_ROW_ID;
	FETCH C_ROW_ID INTO X_ROWID;
	IF (C_ROW_ID%NOTFOUND) THEN
	  CLOSE C_ROW_ID;
	  Raise NO_DATA_FOUND;
	END IF;
	CLOSE C_ROW_ID;
EXCEPTION
  WHEN OTHERS THEN
    l_errbuf  := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf) ;
    RAISE;
END Insert_Row;

PROCEDURE Update_Row(X_ROWID 	              IN OUT NOCOPY VARCHAR2,
		     X_CUSTOMER_TRX_ID                NUMBER,
                     X_CUSTOMER_ID                    NUMBER ,
                     X_CUSTOMER_NAME                  VARCHAR2 ,
                     X_TAXPAYER_NUMBER                VARCHAR2 ,
                     X_TRX_NUMBER                     VARCHAR2 ,
                     X_TRX_DATE                       DATE ,
                     X_PO_NUMBER                      VARCHAR2 ,
                     X_CONTRACT_NO                    VARCHAR2 ,
                     X_CLIN                           VARCHAR2 ,
                     X_SENDER_ALC                     VARCHAR2 ,
                     X_SENDER_DO_SYM                  VARCHAR2 ,
                     X_TRN_SET_ID                     NUMBER ,
                     X_ORG_DCM_RFR                    VARCHAR2 ,
                     X_ORG_ACC_DT                     DATE ,
                     X_DPR_CD                         VARCHAR2 ,
                     X_DSC                            VARCHAR2 ,
                     X_OBL_DCM_NR                     VARCHAR2 ,
                     X_PAY_FLG                        VARCHAR2 ,
                     X_QTY                            NUMBER ,
                     X_SND_APP_SYM                    VARCHAR2 ,
                     X_UNT_ISS                        VARCHAR2 ,
                     X_UNT_PRC                        NUMBER ,
                     X_ORG_LN_ITM                     NUMBER ,
                     X_EXCLUDE_FLAG                   VARCHAR2 ,
                     X_PROCESSED_FLAG                 VARCHAR2 ,
                     X_RUN_DATE                       DATE ,
                     X_SET_OF_BOOKS_ID                NUMBER ,
                     X_EXCEPTION_CATEGORY             VARCHAR2 ,
                     X_ORG_ID                         NUMBER ,
                     X_LAST_UPDATE_DATE               DATE ,
                     X_LAST_UPDATED_BY                NUMBER ,
                     X_LAST_UPDATE_LOGIN              NUMBER ,
                     X_CREATION_DATE                  DATE ,
                     X_CREATED_BY                     NUMBER ,
                     X_ATTRIBUTE1                     VARCHAR2 ,
                     X_ATTRIBUTE2                     VARCHAR2 ,
                     X_ATTRIBUTE3                     VARCHAR2 ,
                     X_ATTRIBUTE4                     VARCHAR2 ,
                     X_ATTRIBUTE5                     VARCHAR2 ,
                     X_ATTRIBUTE6                     VARCHAR2 ,
                     X_ATTRIBUTE7                     VARCHAR2 ,
                     X_ATTRIBUTE8                     VARCHAR2 ,
                     X_ATTRIBUTE9                     VARCHAR2 ,
                     X_ATTRIBUTE10                    VARCHAR2 ,
                     X_ATTRIBUTE11                    VARCHAR2 ,
                     X_ATTRIBUTE12                    VARCHAR2 ,
                     X_ATTRIBUTE13                    VARCHAR2 ,
                     X_ATTRIBUTE14                    VARCHAR2 ,
                     X_ATTRIBUTE15                    VARCHAR2 ,
              /*     X_ATTRIBUTE16                    VARCHAR2 ,
                     X_ATTRIBUTE17                    VARCHAR2 ,
                     X_ATTRIBUTE18                    VARCHAR2 ,
                     X_ATTRIBUTE19                    VARCHAR2 ,
                     X_ATTRIBUTE20                    VARCHAR2 ,
                     X_ATTRIBUTE21                    VARCHAR2 ,
                     X_ATTRIBUTE22                    VARCHAR2 ,
                     X_ATTRIBUTE23                    VARCHAR2 ,
                     X_ATTRIBUTE24                    VARCHAR2 ,
                     X_ATTRIBUTE25                    VARCHAR2 ,
                     X_ATTRIBUTE26                    VARCHAR2 ,
                     X_ATTRIBUTE27                    VARCHAR2 ,
                     X_ATTRIBUTE28                    VARCHAR2 ,
                     X_ATTRIBUTE29                    VARCHAR2 ,
                     X_ATTRIBUTE30                    VARCHAR2 ,   */
                     X_ATTRIBUTE_CATEGORY             VARCHAR2 ,
                     X_ADJUSTMENT_ID                  NUMBER ,
                     X_AMOUNT                         NUMBER ,
                     X_REPORT_FLAG                    VARCHAR2 ,
                     X_CNT_NM                         VARCHAR2 ,
                     X_CNT_PHN_NR                     VARCHAR2 ,
                     X_TRX_LINE_NO                    NUMBER ,
                     X_ORG_DO_SYM                     VARCHAR2 ,
                     X_IPAC_BILLING_ID		      NUMBER

		    ) IS
  l_module_name VARCHAR2(200) := g_module_name || 'Update_Row';
  l_errbuf      VARCHAR2(1024);
BEGIN
 UPDATE FV_IPAC_TRX
 SET                CUSTOMER_TRX_ID    =    X_CUSTOMER_TRX_ID,
  		    CUSTOMER_ID        =    X_CUSTOMER_ID,
  		    CUSTOMER_NAME      =    X_CUSTOMER_NAME ,
		    TAXPAYER_NUMBER    =    X_TAXPAYER_NUMBER,
		    TRX_NUMBER         =    X_TRX_NUMBER,
		    TRX_DATE           =    X_TRX_DATE,
		    PO_NUMBER          =    X_PO_NUMBER,
		    CONTRACT_NO        =    X_CONTRACT_NO,
		    CLIN               =    X_CLIN ,
		    SENDER_ALC         =    X_SENDER_ALC  ,
		    SENDER_DO_SYM      =    X_SENDER_DO_SYM ,
		    TRN_SET_ID	       =    X_TRN_SET_ID,
		    ORG_DCM_RFR        =    X_ORG_DCM_RFR,
		    ORG_ACC_DT         =    X_ORG_ACC_DT,
		    DPR_CD             =    X_DPR_CD  ,
  		    DSC                =    X_DSC  ,
		    OBL_DCM_NR         =    X_OBL_DCM_NR,
		    PAY_FLG            =    X_PAY_FLG ,
		    QTY                =    X_QTY,
		    SND_APP_SYM        =    X_SND_APP_SYM,
		    UNT_ISS  	       =    X_UNT_ISS	,
		    UNT_PRC            =    X_UNT_PRC,
		    ORG_LN_ITM         =    X_ORG_LN_ITM,
		    EXCLUDE_FLAG       =    X_EXCLUDE_FLAG,
		    PROCESSED_FLAG     =    X_PROCESSED_FLAG,
		    RUN_DATE           =    X_RUN_DATE,
		    EXCEPTION_CATEGORY =    X_EXCEPTION_CATEGORY ,
		    ORG_ID             =    X_ORG_ID ,
		    SET_OF_BOOKS_ID    =    X_SET_OF_BOOKS_ID,
		    LAST_UPDATE_DATE   =    X_LAST_UPDATE_DATE,
		    LAST_UPDATED_BY    =    X_LAST_UPDATED_BY,
		    CREATION_DATE      =    X_CREATION_DATE,
		    CREATED_BY         =    X_CREATED_BY ,
		    LAST_UPDATE_LOGIN  =    X_LAST_UPDATE_LOGIN ,
		    ATTRIBUTE1         =    X_ATTRIBUTE1 ,
		    ATTRIBUTE2         =    X_ATTRIBUTE2,
		    ATTRIBUTE3         =    X_ATTRIBUTE3,
		    ATTRIBUTE4         =    X_ATTRIBUTE4 ,
		    ATTRIBUTE5         =    X_ATTRIBUTE5 ,
		    ATTRIBUTE6         =    X_ATTRIBUTE6 ,
		    ATTRIBUTE7         =    X_ATTRIBUTE7 ,
		    ATTRIBUTE8         =    X_ATTRIBUTE8 ,
		    ATTRIBUTE9         =    X_ATTRIBUTE9 ,
		    ATTRIBUTE10        =    X_ATTRIBUTE10 ,
		    ATTRIBUTE11        =    X_ATTRIBUTE11 ,
		    ATTRIBUTE12        =    X_ATTRIBUTE12 ,
		    ATTRIBUTE13        =    X_ATTRIBUTE13 ,
		    ATTRIBUTE14        =    X_ATTRIBUTE14 ,
		    ATTRIBUTE15        =    X_ATTRIBUTE15,
	/*	    ATTRIBUTE16        =    X_ATTRIBUTE16 ,
		    ATTRIBUTE17        =    X_ATTRIBUTE17,
		    ATTRIBUTE18        =    X_ATTRIBUTE18 ,
		    ATTRIBUTE19        =    X_ATTRIBUTE19,
		    ATTRIBUTE20        =    X_ATTRIBUTE20,
		    ATTRIBUTE21        =    X_ATTRIBUTE21 ,
		    ATTRIBUTE22        =    X_ATTRIBUTE22 ,
		    ATTRIBUTE23        =    X_ATTRIBUTE23 ,
		    ATTRIBUTE24        =    X_ATTRIBUTE24 ,
		    ATTRIBUTE25        =    X_ATTRIBUTE25 ,
		    ATTRIBUTE26        =    X_ATTRIBUTE26 ,
		    ATTRIBUTE27        =    X_ATTRIBUTE27,
		    ATTRIBUTE28        =    X_ATTRIBUTE28 ,
		    ATTRIBUTE29        =    X_ATTRIBUTE29 ,
		    ATTRIBUTE30        =    X_ATTRIBUTE30,   */
		    ATTRIBUTE_CATEGORY =    X_ATTRIBUTE_CATEGORY,
		    ADJUSTMENT_ID      =    X_ADJUSTMENT_ID,
                    AMOUNT             =    X_AMOUNT,
                    REPORT_FLAG        =    X_REPORT_FLAG,
                    CNT_NM             =    X_CNT_NM,
                    CNT_PHN_NR         =    X_CNT_PHN_NR,
                    TRX_LINE_NO        =    X_TRX_LINE_NO,
                    ORG_DO_SYM         =    X_ORG_DO_SYM ,
                    IPAC_BILLING_ID    =    X_IPAC_BILLING_ID


 WHERE ROWID = X_ROWID;

 IF (SQL%NOTFOUND) THEN
	RAISE NO_DATA_FOUND;
 END IF;
EXCEPTION
  WHEN OTHERS THEN
    l_errbuf  := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf) ;
    RAISE;
 END Update_Row;


PROCEDURE Lock_Row(  X_ROWID 	   IN OUT NOCOPY     VARCHAR2,
                     X_CUSTOMER_TRX_ID        NUMBER,
                     X_CUSTOMER_ID            NUMBER,
                     X_TRX_NUMBER             VARCHAR2,
                     X_SET_OF_BOOKS_ID        NUMBER,
		     X_IPAC_BILLING_ID        NUMBER

		  ) IS
  l_module_name VARCHAR2(200) := g_module_name || 'Lock_Row';
  l_errbuf      VARCHAR2(1024);
	CURSOR c_lock_record IS
		SELECT  customer_trx_id,
		        customer_id,
		        trx_number,
		        set_of_books_id,
		        ipac_billing_id
		FROM    fv_ipac_trx
		WHERE ROWID = X_ROWID
		for UPDATE OF IPAC_BILLING_ID NOWAIT;
	Recinfo c_lock_record%ROWTYPE;

 BEGIN
  OPEN c_lock_record;
  FETCH c_lock_record INTO Recinfo;
   IF (c_lock_record%NOTFOUND) THEN
   CLOSE c_lock_record;
   fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.MESSAGE(FND_LOG.LEVEL_ERROR, l_module_name) ;
    END IF;
   APP_EXCEPTION.Raise_Exception;
   END IF;
  CLOSE c_lock_record;
  IF ((recinfo.CUSTOMER_TRX_ID = X_CUSTOMER_TRX_ID)
                OR ((recinfo.CUSTOMER_TRX_ID IS NULL)
                AND (X_CUSTOMER_TRX_ID IS NULL)))
	AND ((recinfo.CUSTOMER_ID =  X_CUSTOMER_ID)
                OR ((recinfo.CUSTOMER_ID IS NULL)
                AND (X_CUSTOMER_ID IS NULL)))
	AND ((recinfo.TRX_NUMBER = X_TRX_NUMBER)
                OR ((recinfo.TRX_NUMBER IS NULL)
                AND (X_TRX_NUMBER IS NULL)))
	AND ((recinfo.SET_OF_BOOKS_ID = X_SET_OF_BOOKS_ID)
                OR ((recinfo.SET_OF_BOOKS_ID IS NULL)
                AND (X_SET_OF_BOOKS_ID IS NULL)))
	AND ((recinfo.IPAC_BILLING_ID = X_IPAC_BILLING_ID)
                OR ((recinfo.IPAC_BILLING_ID IS NULL)
                AND (X_IPAC_BILLING_ID IS NULL)))

  THEN
	RETURN;
  ELSE
	fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
  IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FV_UTILITY.MESSAGE(FND_LOG.LEVEL_ERROR, l_module_name) ;
  END IF;
	APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
EXCEPTION
  WHEN OTHERS THEN
    l_errbuf  := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf) ;
    RAISE;
 END Lock_Row;



PROCEDURE Delete_Row(X_ROWID  IN OUT NOCOPY  VARCHAR2  ) IS
  l_module_name VARCHAR2(200) := g_module_name || 'Delete_Row';
  l_errbuf      VARCHAR2(1024);
 x_ipac_billing_id NUMBER;

BEGIN
  BEGIN
	SELECT ipac_billing_id
	INTO   x_ipac_billing_id
	FROM   FV_IPAC_TRX
	WHERE  rowid = x_rowid  ;


  EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RAISE;
  END;


/* Delete FV_IPAC_TRX - Record */
  DELETE FROM FV_IPAC_TRX
  WHERE ipac_billing_id = X_ipac_billing_id ;

  IF (SQL%NOTFOUND) THEN
  RAISE NO_DATA_FOUND;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    l_errbuf  := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf) ;
    RAISE;
END Delete_Row;

END FV_IPAC_TRANSACTIONS_SUMM_PKG;

/
