--------------------------------------------------------
--  DDL for Package Body PO_REQUISITION_LINES_PKG6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQUISITION_LINES_PKG6" as
/* $Header: POXRIL6B.pls 120.1.12010000.2 2012/08/31 09:03:22 hliao ship $ */
 G_CURRENT_RUNTIME_LEVEL      NUMBER;
g_fnd_debug CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

c_log_head    CONSTANT VARCHAR2(35) := 'po.plsql.PO_REQUISITION_LINES_PKG6.';


  PROCEDURE Lock5_Row(X_Rowid                           VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2,
                     X_Bom_Resource_Id                  NUMBER,
                     X_Ussgl_Transaction_Code           VARCHAR2,
                     X_Government_Context               VARCHAR2,
                     X_Closed_Reason                    VARCHAR2,
                     X_Closed_Date                      DATE,
                     X_Transaction_Reason_Code          VARCHAR2,
                     X_Quantity_Received                NUMBER
  ) IS

    CURSOR C IS
        SELECT *
        FROM   PO_REQUISITION_LINES
        WHERE  rowid = X_Rowid
        FOR UPDATE of Requisition_Line_Id NOWAIT;

    Recinfo C%ROWTYPE;
 --For debugging Purposes.
  l_api_name CONSTANT VARCHAR2(30) := 'Lock5_Row';
  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;

    if (
               (   (TRIM(Recinfo.attribute7) = TRIM(X_Attribute7))
                OR (    (TRIM(Recinfo.attribute7) IS NULL)
                    AND (TRIM(X_Attribute7) IS NULL)))
           AND (   (TRIM(Recinfo.attribute8) = TRIM(X_Attribute8))
                OR (    (TRIM(Recinfo.attribute8) IS NULL)
                    AND (TRIM(X_Attribute8) IS NULL)))
           AND (   (TRIM(Recinfo.attribute9) = TRIM(X_Attribute9))
                OR (    (TRIM(Recinfo.attribute9) IS NULL)
                    AND (TRIM(X_Attribute9) IS NULL)))
           AND (   (TRIM(Recinfo.attribute10) = TRIM(X_Attribute10))
                OR (    (TRIM(Recinfo.attribute10) IS NULL)
                    AND (TRIM(X_Attribute10) IS NULL)))
           AND (   (TRIM(Recinfo.attribute11) = TRIM(X_Attribute11))
                OR (    (TRIM(Recinfo.attribute11) IS NULL)
                    AND (TRIM(X_Attribute11) IS NULL)))
           AND (   (TRIM(Recinfo.attribute12) = TRIM(X_Attribute12))
                OR (    (TRIM(Recinfo.attribute12) IS NULL)
                    AND (TRIM(X_Attribute12) IS NULL)))
           AND (   (TRIM(Recinfo.attribute13) = TRIM(X_Attribute13))
                OR (    (TRIM(Recinfo.attribute13) IS NULL)
                    AND (TRIM(X_Attribute13) IS NULL)))
           AND (   (TRIM(Recinfo.attribute14) = TRIM(X_Attribute14))
                OR (    (TRIM(Recinfo.attribute14) IS NULL)
                    AND (TRIM(X_Attribute14) IS NULL)))
           AND (   (TRIM(Recinfo.attribute15) = TRIM(X_Attribute15))
                OR (    (TRIM(Recinfo.attribute15) IS NULL)
                    AND (TRIM(X_Attribute15) IS NULL)))
           AND (   (Recinfo.bom_resource_id = X_Bom_Resource_Id)
                OR (    (Recinfo.bom_resource_id IS NULL)
                    AND (X_Bom_Resource_Id IS NULL)))
           AND (   (TRIM(Recinfo.government_context) = TRIM(X_Government_Context))
                OR (    (TRIM(Recinfo.government_context) IS NULL)
                    AND (TRIM(X_Government_Context) IS NULL)))
           AND (   (TRIM(Recinfo.closed_reason) = TRIM(X_Closed_Reason))
                OR (    (TRIM(Recinfo.closed_reason) IS NULL)
                    AND (TRIM(X_Closed_Reason) IS NULL)))
           AND (   (Recinfo.closed_date = X_Closed_Date)
                OR (    (Recinfo.closed_date IS NULL)
                    AND (X_Closed_Date IS NULL)))
           AND (   (TRIM(Recinfo.transaction_reason_code) = TRIM(X_Transaction_Reason_Code))
                OR (    (TRIM(Recinfo.transaction_reason_code) IS NULL)
                    AND (TRIM(X_Transaction_Reason_Code) IS NULL)))
           AND
	 (   (Recinfo.quantity_received = X_Quantity_Received)
                OR (    (Recinfo.quantity_received IS NULL)
                    AND (X_Quantity_Received IS NULL)))

            ) then
      return;
    else

     -- Logging Infra: Setting up runtime level
     G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
     -- Logging Infra: Procedure level
     IF (FND_LOG.LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
if (nvl(X_Attribute7,'-999') <> nvl(Recinfo.Attribute7,'-999')   ) then
	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form X_Attribute7 '||X_Attribute7 ||' Database  Attribute7 '||Recinfo.Attribute7);
 end if;
if (nvl(X_Attribute8,'-999') <> nvl(Recinfo.Attribute8,'-999')   ) then
	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form X_Attribute8 '||X_Attribute8 ||' Database  Attribute8 '||Recinfo.Attribute8);
 end if;
if (nvl(X_Attribute9,'-999') <> nvl(Recinfo.Attribute9,'-999')   ) then
	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form X_Attribute9 '||X_Attribute9 ||' Database  Attribute9 '||Recinfo.Attribute9);
 end if;
if (nvl(X_Attribute10,'-999') <> nvl(Recinfo.Attribute10,'-999')   ) then
	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form X_Attribute10 '||X_Attribute10 ||' Database  Attribute10 '||Recinfo.Attribute10);
 end if;
if (nvl(X_Attribute11,'-999') <> nvl(Recinfo.Attribute11,'-999')   ) then
	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form X_Attribute11 '||X_Attribute11 ||' Database  Attribute11 '||Recinfo.Attribute11);
 end if;
if (nvl(X_Attribute12,'-999') <> nvl(Recinfo.Attribute12,'-999')   ) then
	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form X_Attribute12 '||X_Attribute12 ||' Database  Attribute12 '||Recinfo.Attribute12);
 end if;
if (nvl(X_Attribute13,'-999') <> nvl(Recinfo.Attribute13,'-999')   ) then
	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form X_Attribute13 '||X_Attribute13 ||' Database  Attribute13 '||Recinfo.Attribute13);
 end if;
if (nvl(X_Attribute14,'-999') <> nvl(Recinfo.Attribute14,'-999')   ) then
	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form X_Attribute14 '||X_Attribute14 ||' Database  Attribute14 '||Recinfo.Attribute14);
 end if;
if (nvl(X_Attribute15,'-999') <> nvl(Recinfo.Attribute15,'-999')   ) then
	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form X_Attribute15 '||X_Attribute15 ||' Database  Attribute15 '||Recinfo.Attribute15);
 end if;
if (nvl(X_Bom_Resource_Id, -999 ) <> nvl(Recinfo.Bom_Resource_Id, -999 )   ) then
	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form X_Bom_Resource_Id '||X_Bom_Resource_Id ||' Database  Bom_Resource_Id '||Recinfo.Bom_Resource_Id);
 end if;
if (nvl(X_Government_Context,'-999') <> nvl(Recinfo.Government_Context,'-999')   ) then
	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form X_Government_Context '||X_Government_Context ||' Database  Government_Context '||Recinfo.Government_Context);
 end if;
if (nvl(X_Closed_Reason,'-999') <> nvl(Recinfo.Closed_Reason,'-999')   ) then
	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form X_Closed_Reason '||X_Closed_Reason ||' Database  Closed_Reason '||Recinfo.Closed_Reason);
 end if;
if (trunc(X_Closed_Date) <>  trunc(Recinfo.Closed_Date) ) then
 	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form X_Closed_Date '||X_Closed_Date ||' Database  Closed_Date '||Recinfo.Closed_Date);
 end if;
if (nvl(X_Transaction_Reason_Code,'-999') <> nvl(Recinfo.Transaction_Reason_Code,'-999')   ) then
	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form X_Transaction_Reason_Code '||X_Transaction_Reason_Code ||' Database  Transaction_Reason_Code '||Recinfo.Transaction_Reason_Code);
 end if;
if (nvl(X_Quantity_Received, -999 ) <> nvl(Recinfo.Quantity_Received, -999 )   ) then
	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form X_Quantity_Received '||X_Quantity_Received ||' Database  Quantity_Received '||Recinfo.Quantity_Received);
 end if;


     END IF;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;

  END Lock5_Row;

END PO_REQUISITION_LINES_PKG6;

/
