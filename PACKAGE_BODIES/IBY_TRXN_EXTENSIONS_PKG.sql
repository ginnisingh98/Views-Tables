--------------------------------------------------------
--  DDL for Package Body IBY_TRXN_EXTENSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_TRXN_EXTENSIONS_PKG" as
/* $Header: ibyfcitb.pls 120.1 2005/09/02 17:56:00 syidner noship $ */

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_TRXN_EXTENSION_ID                NUMBER,
                     X_PAYMENT_CHANNEL_CODE             VARCHAR2,
                     X_INSTR_ASSIGNMENT_ID              NUMBER,
                     X_INSTRUMENT_SECURITY_CODE         VARCHAR2,
                     X_VOICE_AUTHORIZATION_FLAG         VARCHAR2,
                     X_VOICE_AUTHORIZATION_DATE         DATE,
                     X_VOICE_AUTHORIZATION_CODE         VARCHAR2,
                     X_ORIGIN_APPLICATION_ID            NUMBER,
                     X_ORDER_ID                         VARCHAR2,
                     X_PO_NUMBER                        VARCHAR2,
                     X_PO_LINE_NUMBER                   VARCHAR2,
                     X_TRXN_REF_NUMBER1                 VARCHAR2,
                     X_TRXN_REF_NUMBER2                 VARCHAR2,
                     X_ADDITIONAL_INFO                  VARCHAR2,
                     X_Calling_Sequence                 VARCHAR2
  ) IS

    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);


    CURSOR C IS
        SELECT
          TRXN_EXTENSION_ID,
          PAYMENT_CHANNEL_CODE,
          INSTR_ASSIGNMENT_ID,
          INSTRUMENT_SECURITY_CODE,
          VOICE_AUTHORIZATION_FLAG,
          VOICE_AUTHORIZATION_DATE,
          VOICE_AUTHORIZATION_CODE,
          ORIGIN_APPLICATION_ID,
          ORDER_ID,
          PO_NUMBER,
          PO_LINE_NUMBER,
          TRXN_REF_NUMBER1,
          TRXN_REF_NUMBER2,
          ADDITIONAL_INFO
        FROM IBY_FNDCPT_TX_EXTENSIONS
        WHERE  TRXN_EXTENSION_ID = X_TRXN_EXTENSION_ID
        FOR UPDATE of TRXN_EXTENSION_ID NOWAIT;
    Recinfo C%ROWTYPE;


BEGIN

    -- Update the calling sequence
    --
    current_calling_sequence :=
    'IBY_TRXN_EXTENSIONS_PKG.Lock_Row<-'||X_Calling_Sequence;

    debug_info := 'Select from IBY_TRXN_EXTENSIONS_V';

    OPEN C;

    debug_info := 'Fetch cursor C';
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      debug_info := 'Close cursor C - ROW NOTFOUND';
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    debug_info := 'Close cursor C';
    CLOSE C;

    if (   (Recinfo.TRXN_EXTENSION_ID =  X_TRXN_EXTENSION_ID)
           AND (Recinfo.PAYMENT_CHANNEL_CODE = X_PAYMENT_CHANNEL_CODE)
           AND (Recinfo.ORIGIN_APPLICATION_ID = X_ORIGIN_APPLICATION_ID)
           AND (Recinfo.INSTR_ASSIGNMENT_ID = X_INSTR_ASSIGNMENT_ID)
           AND (   (Recinfo.INSTRUMENT_SECURITY_CODE =  X_INSTRUMENT_SECURITY_CODE)
                OR (    (Recinfo.INSTRUMENT_SECURITY_CODE IS NULL)
                    AND (X_INSTRUMENT_SECURITY_CODE IS NULL)))
           AND (   (Recinfo.VOICE_AUTHORIZATION_FLAG =  X_VOICE_AUTHORIZATION_FLAG)
                OR (    (Recinfo.VOICE_AUTHORIZATION_FLAG IS NULL)
                    AND (X_VOICE_AUTHORIZATION_FLAG IS NULL)))
           AND (   (Recinfo.VOICE_AUTHORIZATION_DATE =  X_VOICE_AUTHORIZATION_DATE)
                OR (    (Recinfo.VOICE_AUTHORIZATION_DATE IS NULL)
                    AND (X_VOICE_AUTHORIZATION_DATE IS NULL)))
           AND (   (Recinfo.VOICE_AUTHORIZATION_CODE =  X_VOICE_AUTHORIZATION_CODE)
                OR (    (Recinfo.VOICE_AUTHORIZATION_CODE IS NULL)
                    AND (X_VOICE_AUTHORIZATION_CODE IS NULL)))
           AND (   (Recinfo.ORDER_ID =  X_ORDER_ID)
                OR (    (Recinfo.ORDER_ID IS NULL)
                    AND (X_ORDER_ID IS NULL)))
           AND (   (Recinfo.PO_NUMBER =  X_PO_NUMBER)
                OR (    (Recinfo.PO_NUMBER IS NULL)
                    AND (X_PO_NUMBER IS NULL)))
           AND (   (Recinfo.PO_LINE_NUMBER =  X_PO_LINE_NUMBER)
                OR (    (Recinfo.PO_LINE_NUMBER IS NULL)
                    AND (X_PO_LINE_NUMBER IS NULL)))
           AND (   (Recinfo.TRXN_REF_NUMBER1 =  X_TRXN_REF_NUMBER1)
                OR (    (Recinfo.TRXN_REF_NUMBER1 IS NULL)
                    AND (X_TRXN_REF_NUMBER1 IS NULL)))
           AND (   (Recinfo.TRXN_REF_NUMBER2 =  X_TRXN_REF_NUMBER2)
                OR (    (Recinfo.TRXN_REF_NUMBER2 IS NULL)
                      AND (X_TRXN_REF_NUMBER2 IS NULL)))
           AND (   (Recinfo.ADDITIONAL_INFO =  X_ADDITIONAL_INFO)
                OR (    (Recinfo.ADDITIONAL_INFO IS NULL)
                    AND (X_ADDITIONAL_INFO IS NULL)))
      )
    THEN return;
    ELSE
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      if (SQLCODE <> -20001) then
        IF (SQLCODE = -54) THEN
          FND_MESSAGE.SET_NAME('IBY','IBY_RESOURCE_BUSY');
        ELSE
          FND_MESSAGE.SET_NAME('IBY', 'IBY_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
        END IF;
      end if;
      APP_EXCEPTION.RAISE_EXCEPTION;

  END Lock_Row;


END IBY_TRXN_EXTENSIONS_PKG;

/
