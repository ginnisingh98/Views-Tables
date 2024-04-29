--------------------------------------------------------
--  DDL for Package Body OKS_UPGRADE_PRECHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_UPGRADE_PRECHECK" AS
/* $Header: OKS22PCB.pls 115.5 2004/02/11 19:29:09 jvarghes noship $ */
PROCEDURE Log_Errors(P_Original_system_Reference IN VARCHAR2,
				 P_Original_System_Reference_Id IN NUMBER,
			      P_Original_System_Ref_Id_Upper IN NUMBER,
			      P_DateTime IN DATE,
                     P_Error_Message IN VARCHAR2) IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
INSERT INTO CS_UPG_ERRORS(Orig_System_Reference,
					 Orig_System_Reference_Id,
					 Orig_System_Ref_Id_Upper,
					 Upgrade_DateTime,
					 Error_Message)
            VALUES       (P_Original_System_Reference,
					 P_Original_System_Reference_Id,
					 P_Original_System_Ref_Id_Upper,
					 P_DateTime,
					 P_Error_Message);
COMMIT;
END;

PROCEDURE Insert_Time_code_units IS

    l_api_version              CONSTANT    NUMBER         := 1.0;
    l_init_msg_list            CONSTANT    VARCHAR2(1)    := 'T';
    l_return_status            VARCHAR2(3);
    l_return_msg               VARCHAR2(2000);
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(2000);
    l_msg_index_out            NUMBER;
    l_Error_Message            VARCHAR2(2000);

	G_EXCEPTION_HALT_VALIDATION Exception;

    CURSOR cur_timecode(p_uom_code IN varchar2,p_tce_code IN Varchar2) IS
           SELECT 'y' FROM okc_time_code_units_v
           WHERE uom_code = p_uom_code
           AND   tce_code = p_tce_code;

     l_tcuv_rec_in      okc_time_pub.tcuv_rec_type;
     l_tcuv_rec_out    okc_time_pub.tcuv_rec_type;

     l_exist  Varchar2(1);

BEGIN

    l_exist := NULL;
    OPEN cur_timecode('DAY','DAY');
    FETCH cur_timecode INTO l_exist;
    IF cur_timecode%NOTFOUND THEN
      l_exist := 'n';
    END IF;
    CLOSE cur_timecode;

 IF l_exist <> 'y' then
    l_tcuv_rec_in.short_description              := NULL;
    l_tcuv_rec_in.description                    := NULL;
    l_tcuv_rec_in.comments                       := NULL;
    l_tcuv_rec_in.attribute_category             := NULL;
    l_tcuv_rec_in.attribute1                     := NULL;
    l_tcuv_rec_in.attribute2                     := NULL;
    l_tcuv_rec_in.attribute3                     := NULL;
    l_tcuv_rec_in.attribute4                     := NULL;
    l_tcuv_rec_in.attribute5                     := NULL;
    l_tcuv_rec_in.attribute6                     := NULL;
    l_tcuv_rec_in.attribute7                     := NULL;
    l_tcuv_rec_in.attribute8                     := NULL;
    l_tcuv_rec_in.attribute9                     := NULL;
    l_tcuv_rec_in.attribute10                    := NULL;
    l_tcuv_rec_in.attribute11                    := NULL;
    l_tcuv_rec_in.attribute12                    := NULL;
    l_tcuv_rec_in.attribute13                    := NULL;
    l_tcuv_rec_in.attribute14                    := NULL;
    l_tcuv_rec_in.attribute15                    := NULL;
    l_tcuv_rec_in.created_by                     := -1 ;
    l_tcuv_rec_in.creation_date                  := SYSDATE;
    l_tcuv_rec_in.last_updated_by                := -1;
    l_tcuv_rec_in.last_update_date               := SYSDATE;
    l_tcuv_rec_in.last_update_login              := -1;
    l_tcuv_rec_in.active_flag                    := 'Y';
    l_tcuv_rec_in.uom_code                       := 'DAY';
    l_tcuv_rec_in.tce_code                       := 'DAY';
    l_tcuv_rec_in.object_version_number          := 1;
    l_tcuv_rec_in.sfwt_flag                      := 'N';
    l_tcuv_rec_in.quantity                       := 1;

   OKC_TIME_PUB.CREATE_TIME_CODE_UNITS(
    p_api_version        =>        l_api_version,
    p_init_msg_list      =>        l_init_msg_list,
    x_return_status      =>        l_return_status,
    x_msg_count          =>        l_msg_count,
    x_msg_data           =>        l_msg_data,
    p_tcuv_rec           =>        l_tcuv_rec_in,
    x_tcuv_rec           =>        l_tcuv_rec_out) ;

            IF l_return_status <>'S' THEN
               IF l_msg_count > 0
               THEN
                    FOR i in 1..l_msg_count
                    LOOP
                     fnd_msg_pub.get (p_msg_index     => -1,
                                      p_encoded       => 'F',
                                      p_data          => l_msg_data,
                                      p_msg_index_out => l_msg_index_out);
                   END LOOP;
               END IF;
l_Error_Message := 'Error while creating uom_code DAY(Day) into OKC_TIME_CODE_UNITS_B Table '||l_msg_data;
               Log_Errors('INSERT_TIME_CODE_UNITS',
						  NULL,
						  NULL,
						  SYSDATE,
                          l_Error_Message);

               raise G_EXCEPTION_HALT_VALIDATION;
            END IF;
     END IF;
             l_return_status := NULL;
             l_msg_count     := NULL;
             l_msg_data      := NULL;
    		 l_exist := NULL;

    OPEN cur_timecode('HR','HOUR');
    FETCH cur_timecode INTO l_exist;
    IF cur_timecode%NOTFOUND THEN
      l_exist := 'n';
    END IF;
    CLOSE cur_timecode;

 IF l_exist <> 'y' then
    l_tcuv_rec_in.uom_code                      := 'HR';
    l_tcuv_rec_in.tce_code                      := 'HOUR';
    l_tcuv_rec_in.object_version_number         := 1;
    l_tcuv_rec_in.sfwt_flag                     := 'N';
    l_tcuv_rec_in.quantity                      := 1;

   OKC_TIME_PUB.CREATE_TIME_CODE_UNITS(
    p_api_version        =>        l_api_version,
    p_init_msg_list      =>        l_init_msg_list,
    x_return_status      =>        l_return_status,
    x_msg_count          =>        l_msg_count,
    x_msg_data           =>        l_msg_data,
    p_tcuv_rec           =>        l_tcuv_rec_in,
    x_tcuv_rec           =>        l_tcuv_rec_out) ;

            IF l_return_status <>'S' THEN
               IF l_msg_count > 0
               THEN
                    FOR i in 1..l_msg_count
                    LOOP
                     fnd_msg_pub.get (p_msg_index     => -1,
                                      p_encoded       => 'F',
                                      p_data          => l_msg_data,
                                      p_msg_index_out => l_msg_index_out);
                   END LOOP;
               END IF;
               l_Error_Message := 'Error while creating uom_code HR(Hour) into OKC_TIME_CODE_UNITS_B '||l_msg_data;
               Log_Errors('INSERT_TIME_CODE_UNITS',
						  NULL,
						  NULL,
						  SYSDATE,
                          l_Error_Message);
               raise G_EXCEPTION_HALT_VALIDATION;
            END IF;
END IF;
             l_return_status := NULL;
             l_msg_count     := NULL;
             l_msg_data      := NULL;


l_exist := NULL;
OPEN cur_timecode('MIN','MINUTE');
FETCH cur_timecode INTO l_exist;
IF cur_timecode%NOTFOUND THEN
  l_exist := 'n';
END IF;
    CLOSE cur_timecode;

 IF l_exist <> 'y' then
    l_tcuv_rec_in.uom_code                      := 'MIN';
    l_tcuv_rec_in.tce_code                      := 'MINUTE';
    l_tcuv_rec_in.object_version_number         := 1;
    l_tcuv_rec_in.sfwt_flag                     := 'N';
    l_tcuv_rec_in.quantity                      := 1;

   OKC_TIME_PUB.CREATE_TIME_CODE_UNITS(
    p_api_version        =>        l_api_version,
    p_init_msg_list      =>        l_init_msg_list,
    x_return_status      =>        l_return_status,
    x_msg_count          =>        l_msg_count,
    x_msg_data           =>        l_msg_data,
    p_tcuv_rec           =>        l_tcuv_rec_in,
    x_tcuv_rec           =>        l_tcuv_rec_out) ;

            IF l_return_status <>'S' THEN

               IF l_msg_count > 0 THEN

                    FOR i in 1..l_msg_count LOOP

                     fnd_msg_pub.get (p_msg_index     => -1,
                                      p_encoded       => 'F',
                                      p_data          => l_msg_data,
                                      p_msg_index_out => l_msg_index_out);

                   END LOOP;

               END IF;

               l_Error_Message := 'Error while creating uom_code MIN(Minute) into OKC_TIME_CODE_UNITS_B '||l_msg_data;
               Log_Errors('INSERT_TIME_CODE_UNITS',
						  NULL,
						  NULL,
						  SYSDATE,
                          l_Error_Message);
               raise G_EXCEPTION_HALT_VALIDATION;
            END IF;
    END IF;
             l_return_status := NULL;
             l_msg_count     := NULL;
             l_msg_data      := NULL;

    l_exist := NULL;
    OPEN cur_timecode('WK','DAY');
    FETCH cur_timecode INTO l_exist;
    IF cur_timecode%NOTFOUND THEN
      l_exist := 'n';
    END IF;
    CLOSE cur_timecode;

 IF l_exist <> 'y' then
    l_tcuv_rec_in.uom_code                      := 'WK';
    l_tcuv_rec_in.tce_code                      := 'DAY';
    l_tcuv_rec_in.object_version_number         := 1;
    l_tcuv_rec_in.sfwt_flag                     := 'N';
    l_tcuv_rec_in.quantity                      := 7;

   OKC_TIME_PUB.CREATE_TIME_CODE_UNITS(
    p_api_version        =>        l_api_version,
    p_init_msg_list      =>        l_init_msg_list,
    x_return_status      =>        l_return_status,
    x_msg_count          =>        l_msg_count,
    x_msg_data           =>        l_msg_data,
    p_tcuv_rec           =>        l_tcuv_rec_in,
    x_tcuv_rec           =>        l_tcuv_rec_out) ;
            IF l_return_status <>'S' THEN
               IF l_msg_count > 0
               THEN
                    FOR i in 1..l_msg_count
                    LOOP
                     fnd_msg_pub.get (p_msg_index     => -1,
                                      p_encoded       => 'F',
                                      p_data          => l_msg_data,
                                      p_msg_index_out => l_msg_index_out);
                   END LOOP;
               END IF;
               l_Error_Message := 'Error while creating uom_code WK(Day) into OKC_TIME_CODE_UNITS_B '||l_msg_data;
               Log_Errors('INSERT_TIME_CODE_UNITS',
						  NULL,
						  NULL,
						  SYSDATE,
                          l_Error_Message);
               raise G_EXCEPTION_HALT_VALIDATION;
            END IF;
    END IF;
             l_return_status := NULL;
             l_msg_count     := NULL;
             l_msg_data      := NULL;

    OPEN cur_timecode('MTH','MONTH');
    FETCH cur_timecode INTO l_exist;
    IF cur_timecode%NOTFOUND THEN
      l_exist := 'n';
    END IF;
    CLOSE cur_timecode;

 IF l_exist <> 'y' then
    l_tcuv_rec_in.uom_code                       := 'MTH';
    l_tcuv_rec_in.tce_code                       := 'MONTH';
    l_tcuv_rec_in.object_version_number          := 1;
    l_tcuv_rec_in.sfwt_flag                      :='N';
    l_tcuv_rec_in.quantity                       := 1;

   OKC_TIME_PUB.CREATE_TIME_CODE_UNITS(
    p_api_version        =>        l_api_version,
    p_init_msg_list      =>        l_init_msg_list,
    x_return_status      =>        l_return_status,
    x_msg_count          =>        l_msg_count,
    x_msg_data           =>        l_msg_data,
    p_tcuv_rec           =>        l_tcuv_rec_in,
    x_tcuv_rec           =>        l_tcuv_rec_out) ;
            IF l_return_status <>'S' THEN
               IF l_msg_count > 0
               THEN
                    FOR i in 1..l_msg_count
                    LOOP
                     fnd_msg_pub.get (p_msg_index     => -1,
                                      p_encoded       => 'F',
                                      p_data          => l_msg_data,
                                      p_msg_index_out => l_msg_index_out);
                   END LOOP;
               END IF;
               l_Error_Message := 'Error while creating uom_code MTH(Month) into OKC_TIME_CODE_UNITS_B '||l_msg_data;
               Log_Errors('INSERT_TIME_CODE_UNITS',
						  NULL,
						  NULL,
						  SYSDATE,
                          l_Error_Message);
               raise G_EXCEPTION_HALT_VALIDATION;
            END IF;
    END IF;
             l_return_status := NULL;
             l_msg_count     := NULL;
             l_msg_data      := NULL;

    OPEN cur_timecode('YR','YEAR');
    FETCH cur_timecode INTO l_exist;
    IF cur_timecode%NOTFOUND THEN
      l_exist := 'n';
    END IF;
    CLOSE cur_timecode;

 IF l_exist <> 'y' then

    l_tcuv_rec_in.uom_code                       := 'YR';
    l_tcuv_rec_in.tce_code                       := 'YEAR';
    l_tcuv_rec_in.object_version_number          := 1;
    l_tcuv_rec_in.sfwt_flag                      := 'N';
    l_tcuv_rec_in.quantity                       := 1;

   OKC_TIME_PUB.CREATE_TIME_CODE_UNITS(
    p_api_version        =>        l_api_version,
    p_init_msg_list      =>        l_init_msg_list,
    x_return_status      =>        l_return_status,
    x_msg_count          =>        l_msg_count,
    x_msg_data           =>        l_msg_data,
    p_tcuv_rec           =>        l_tcuv_rec_in,
    x_tcuv_rec           =>        l_tcuv_rec_out) ;
            IF l_return_status <>'S' THEN
               IF l_msg_count > 0
               THEN
                    FOR i in 1..l_msg_count
                    LOOP
                     fnd_msg_pub.get (p_msg_index     => -1,
                                      p_encoded       => 'F',
                                      p_data          => l_msg_data,
                                      p_msg_index_out => l_msg_index_out);
                   END LOOP;
               END IF;
               l_Error_Message := 'Error while creating uom_code YR(Year) into OKC_TIME_CODE_UNITS_B '||l_msg_data;
               Log_Errors('INSERT_TIME_CODE_UNITS',
						  NULL,
						  NULL,
						  SYSDATE,
                          l_Error_Message);
               raise G_EXCEPTION_HALT_VALIDATION;
            END IF;
    END IF;
             l_return_status := NULL;
             l_msg_count     := NULL;
             l_msg_data      := NULL;

 COMMIT;

 EXCEPTION
     When  G_EXCEPTION_HALT_VALIDATION Then
          rollback;
          RAISE_APPLICATION_ERROR(-20000,'Error While running Insert_Time_Code_Units for: '||l_error_message);

  WHEN OTHERS THEN
		rollback;
		RAISE_APPLICATION_ERROR(-20001,'Error while creating records into OKC_TIME_CODE_UNITS_B '||SQLERRM);

END Insert_Time_code_units;

PROCEDURE Create_Bus_Process(x_Return_status IN OUT NOCOPY Varchar2,
                             x_Return_Msg IN OUT NOCOPY Varchar2)
IS

l_busproc_id             NUMBER;
l_busproc_cnt            NUMBER;

BEGIN
x_Return_status := NULL;
x_Return_Msg    := NULL;

SELECT count(*)
INTO   l_busproc_cnt
FROM   cs_business_processes
WHERE  UPPER(name) = UPPER('SERVICE_CONTRACTS_UPGRADE_BP');

    IF l_busproc_cnt <> 0
    THEN
       NULL;
    ELSE
       SELECT max(BUSINESS_PROCESS_ID)+1
       INTO   l_busproc_id
       FROM   cs_business_processes;


       INSERT into cs_business_processes(
                                        BUSINESS_PROCESS_ID    ,
                                        ORDER_TYPE_ID          ,
                                        NAME                   ,
                                        LAST_UPDATE_DATE       ,
                                        LAST_UPDATED_BY        ,
                                        CREATION_DATE          ,
                                        CREATED_BY             ,
                                        LAST_UPDATE_LOGIN      ,
                                        DESCRIPTION            ,
                                        START_DATE_ACTIVE      ,
                                        END_DATE_ACTIVE        ,
                                        SERVICE_REQUEST_FLAG   ,
                                        DEPOT_REPAIR_FLAG      ,
                                        FIELD_SERVICE_FLAG     ,
                                        CONTRACTS_FLAG         ,
                                        STAND_ALONE_FLAG       ,
                                        ATTRIBUTE1             ,
                                        ATTRIBUTE2             ,
                                        ATTRIBUTE3             ,
                                        ATTRIBUTE4             ,
                                        ATTRIBUTE5             ,
                                        ATTRIBUTE6             ,
                                        ATTRIBUTE7             ,
                                        ATTRIBUTE8             ,
                                        ATTRIBUTE9             ,
                                        ATTRIBUTE10            ,
                                        ATTRIBUTE11            ,
                                        ATTRIBUTE12            ,
                                        ATTRIBUTE13            ,
                                        ATTRIBUTE14            ,
                                        ATTRIBUTE15            ,
                                        CONTEXT                )
         values
                                        (l_busproc_id       ,
                                        NULL          ,
                                        'SERVICE_CONTRACTS_UPGRADE_BP',
                                        SYSDATE       ,
                                        0, --LAST_UPDATED_BY  ??
                                        SYSDATE          ,
                                        -1 , --CREATED_BY ??
                                        0, --LAST_UPDATE_LOGIN ??
                                        'Business Process for Upgrade',
                                        To_Date('01/01/1900','DD/MM/YYYY'),
                                        NULL , --END_DATE_ACTIVE ??
                                        'Y'   ,
                                        'Y'      ,
                                        'Y'     ,
                                        'Y' ,
                                        NULL, -- STAND_ALONE_FLAG ??
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL);
END IF;
EXCEPTION
WHEN OTHERS THEN
x_Return_Status := 'U';
x_Return_Msg := 'Others Exception raised whiling creating Default Business Process'||to_char(sqlcode)||'-'||sqlerrm;
raise_application_error(-20001,'While Creating Default Business Process:'||sqlerrm);
END Create_Bus_Process;

PROCEDURE create_bltype(p_billing_type IN varchar2,
                        p_txntype_id   IN number,
                        x_Return_status OUT NOCOPY Varchar2,
                        x_Return_Msg OUT NOCOPY Varchar2)
IS

   l_txnb_rec_in	   CS_TXNBTYPE_PVT.TXNBTYPE_REC_TYPE;
   l_txn_billing_type_id  Number;

   l_api_version              CONSTANT    NUMBER         := 1.0;
   l_init_msg_list            CONSTANT    VARCHAR2(1)    := 'T';
   l_validation_level         Number :=100;
   l_commit                   Varchar2(2000):='F';
   l_return_status            VARCHAR2(3);
   l_msg_count                NUMBER;
   l_msg_data                 VARCHAR2(2000);
   l_return_msg               VARCHAR2(2000);
   l_msg_index_out            Number;
   l_object_version_number    Number;

   e_Error                   EXCEPTION;

BEGIN
        l_return_status := 'S';
        l_return_msg    := NULL;

    l_txnb_rec_in.billing_type          :=p_billing_type;
    l_txnb_rec_in.transaction_type_id   :=p_txntype_id;
    l_txnb_rec_in.last_update_date      := sysdate;
    l_txnb_rec_in.last_updated_by       := 0;
    l_txnb_rec_in.creation_date         := sysdate;
    l_txnb_rec_in.created_by            := -1;
    l_txnb_rec_in.last_update_login     :=0;
    l_txnb_rec_in.attribute1            :=NULL;
    l_txnb_rec_in.attribute2            :=NULL;
    l_txnb_rec_in.attribute3            :=NULL;
    l_txnb_rec_in.attribute4            :=NULL;
    l_txnb_rec_in.attribute5            :=NULL;
    l_txnb_rec_in.attribute6            :=NULL;
    l_txnb_rec_in.attribute7            :=NULL;
    l_txnb_rec_in.attribute8            :=NULL;
    l_txnb_rec_in.attribute9            :=NULL;
    l_txnb_rec_in.attribute10           :=NULL;
    l_txnb_rec_in.attribute11           :=NULL;
    l_txnb_rec_in.attribute12           :=NULL;
    l_txnb_rec_in.attribute13           :=NULL;
    l_txnb_rec_in.attribute14           :=NULL;
    l_txnb_rec_in.attribute15           :=NULL;
    l_txnb_rec_in.context               :=NULL;
    l_txnb_rec_in.object_version_number :=1;
/*
        CS_TXNBTYPE_PVT.INSERT_ROW(
                 p_api_version                  =>l_api_version,
                 p_init_msg_list                =>l_init_msg_list,
                 p_validation_level             =>l_validation_level,
                 p_commit                       =>l_commit,
                 x_return_status                =>l_return_status,
                 x_msg_count                    =>l_msg_count,
                 x_msg_data                     =>l_msg_data,
                 p_txnbtype_rec                 =>l_txnb_rec_in,
                 x_txn_billing_type_id          =>l_txn_billing_type_id,
                 x_object_version_number        =>l_object_version_number);

             IF nvl(l_return_status,'*') <> 'S'
             THEN
               IF l_msg_count > 0
               THEN
                 FOR i in 1..l_msg_count
                 LOOP
                   fnd_msg_pub.get (p_msg_index     => -1,
                                    p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                    p_data          => l_msg_data,
                                    p_msg_index_out => l_msg_index_out);
                 END LOOP;
               END IF;
                 x_return_status := l_return_status;
                 x_return_msg := l_msg_data;

                 RAISE e_Error;
               END IF;
*/
EXCEPTION
WHEN e_ERROR
THEN
   x_Return_status := 'E';
   x_Return_msg:=l_msg_data;
   rollback;
WHEN OTHERS THEN
   x_return_status := 'U';
   x_return_msg    := SQLCODE||'-'||SQLERRM;
raise_application_error(-20001,'While Creating Default Bill Types:'||sqlerrm);

END Create_bltype;

PROCEDURE Create_Bus_process_Txn(p_txn_type_id IN Number,
                                 x_Return_status OUT NOCOPY Varchar2,
                                 x_Return_Msg OUT NOCOPY Varchar2)
IS
 CURSOR Cur_bus_proc IS
        SELECT business_process_id
        FROM   CS_BUSINESS_PROCESSES
        WHERE  NAME = 'SERVICE_CONTRACTS_UPGRADE_BP';

L_ROWID                        varchar2(2000) :=null;
L_BUSINESS_PROCESS_ID          NUMBER   :=null;
L_TRANSACTION_TYPE_ID          NUMBER   :=null;
L_START_DATE_ACTIVE            DATE     :=null;
L_END_DATE_ACTIVE              DATE     :=null;
L_ATTRIBUTE1                   VARCHAR2(150) :=null;
L_ATTRIBUTE2                   VARCHAR2(150) :=null;
L_ATTRIBUTE3                   VARCHAR2(150) :=null;
L_ATTRIBUTE4                   VARCHAR2(150) :=null;
L_ATTRIBUTE5                   VARCHAR2(150) :=null;
L_ATTRIBUTE6                   VARCHAR2(150) :=null;
L_ATTRIBUTE7                   VARCHAR2(150) :=null;
L_ATTRIBUTE8                   VARCHAR2(150) :=null;
L_ATTRIBUTE9                   VARCHAR2(150) :=null;
L_ATTRIBUTE10                  VARCHAR2(150) :=null;
L_ATTRIBUTE11                  VARCHAR2(150) :=null;
L_ATTRIBUTE12                  VARCHAR2(150) :=null;
L_ATTRIBUTE13                  VARCHAR2(150) :=null;
L_ATTRIBUTE14                  VARCHAR2(150) :=null;
L_ATTRIBUTE15                  VARCHAR2(150) :=null;
L_CONTEXT                      VARCHAR2(150) :=null;
L_MODE                         VARCHAR2(5) :=null;

BEGIN
      OPEN Cur_bus_proc;
      FETCH Cur_bus_proc into L_BUSINESS_PROCESS_ID;
      CLOSE Cur_bus_proc;

L_TRANSACTION_TYPE_ID := p_txn_type_id;
L_MODE := 'I';
/*
CS_BUS_PROCESS_TXNS_PKG.INSERT_ROW(
                         X_ROWID                => L_ROWID,
                         X_BUSINESS_PROCESS_ID  => L_BUSINESS_PROCESS_ID,
                         X_TRANSACTION_TYPE_ID  => L_TRANSACTION_TYPE_ID,
                         X_START_DATE_ACTIVE    => L_START_DATE_ACTIVE,
                         X_END_DATE_ACTIVE      => L_END_DATE_ACTIVE,
                         X_ATTRIBUTE1           => L_ATTRIBUTE1,
                         X_ATTRIBUTE2           => L_ATTRIBUTE2,
                         X_ATTRIBUTE3           => L_ATTRIBUTE3,
                         X_ATTRIBUTE4           => L_ATTRIBUTE4,
                         X_ATTRIBUTE5           => L_ATTRIBUTE5,
                         X_ATTRIBUTE6           => L_ATTRIBUTE6,
                         X_ATTRIBUTE7           => L_ATTRIBUTE7,
                         X_ATTRIBUTE8           => L_ATTRIBUTE8,
                         X_ATTRIBUTE9           => L_ATTRIBUTE9,
                         X_ATTRIBUTE10          => L_ATTRIBUTE10,
                         X_ATTRIBUTE11          => L_ATTRIBUTE11,
                         X_ATTRIBUTE12          => L_ATTRIBUTE12,
                         X_ATTRIBUTE13          => L_ATTRIBUTE13,
                         X_ATTRIBUTE14          => L_ATTRIBUTE14,
                         X_ATTRIBUTE15          => L_ATTRIBUTE15,
                         X_CONTEXT              => L_CONTEXT,
                         X_MODE                 => L_MODE);
*/
EXCEPTION
WHEN OTHERS THEN
   x_return_status := 'U';
   x_return_msg    := SQLCODE||'-'||SQLERRM;
raise_application_error(-20001,'While Creating Default Business Process Transaction :'||sqlerrm);

END Create_Bus_process_Txn;

PROCEDURE Create_Txn_bltypes(x_Return_status OUT NOCOPY Varchar2,
                             x_Return_Msg OUT NOCOPY Varchar2)
IS

 CURSOR Cur_Txn_type_cnt IS
       SELECT count(*) from CS_TRANSACTION_TYPES
       WHERE NAME='SERVICE_CONTRACTS_UPGRADE_TXN';

 CURSOR Cur_Txntype_max IS
       SELECT max(TRANSACTION_TYPE_ID)+1
       FROM   CS_TRANSACTION_TYPES;

   l_txnb_rec_in	   CS_TXNBTYPE_PVT.TXNBTYPE_REC_TYPE;

   l_txntype_id             NUMBER;
   l_txntype_cnt            NUMBER;

   l_api_version              CONSTANT    NUMBER         := 1.0;
   l_init_msg_list            CONSTANT    VARCHAR2(1)    := 'T';
   l_validation_level         Number :=100;
   l_commit                   Varchar2(2000):='F';
   l_return_status            VARCHAR2(3);
   l_msg_count                NUMBER;
   l_msg_data                 VARCHAR2(2000);
   l_return_msg               VARCHAR2(2000);
   l_msg_index_out            Number;

   e_Error           EXCEPTION;

  l_TRANSACTION_TYPE_ID  NUMBER ;
  l_SEEDED_FLAG          Varchar2(2000);
  l_NAME  Varchar2(2000);
  l_CREATION_DATE date;
  l_CREATED_BY number ;
  l_LAST_UPDATE_DATE date ;
  l_LAST_UPDATED_BY number ;
  l_LAST_UPDATE_LOGIN number ;
  L_ROWID         varchar2(2000) :=null;
  L_REVISION_FLAG        varchar2(2000) := null;
  L_END_DATE_ACTIVE    date := null;
  L_START_DATE_ACTIVE  Date := null;
  l_ATTRIBUTE1 varchar2(2000):=null;
  l_ATTRIBUTE2  varchar2(2000):=null;
  l_ATTRIBUTE3 varchar2(2000):=null;
  l_ATTRIBUTE4  varchar2(2000):=null;
  l_ATTRIBUTE5 varchar2(2000):=null;
  l_ATTRIBUTE6 varchar2(2000):=null;
  l_ATTRIBUTE7 varchar2(2000):=null;
  l_ATTRIBUTE8 varchar2(2000):=null;
  l_ATTRIBUTE9 varchar2(2000):=null;
  l_ATTRIBUTE10 varchar2(2000):=null;
  l_CONTEXT  varchar2(2000):=null;
  l_INSTALLED_CP_STATUS_ID number := null;
  l_ATTRIBUTE11 varchar2(2000):=null;
  l_ATTRIBUTE12 varchar2(2000):=null;
  l_ATTRIBUTE13 varchar2(2000):=null;
  l_ATTRIBUTE14 varchar2(2000):=null;
  l_ATTRIBUTE15 varchar2(2000):=null;
  l_INSTALLED_STATUS_CODE varchar2(2000) := null;
  l_INSTALLED_CP_RETURN_REQUIRED varchar2(2000) := null;
  l_NO_CHARGE_FLAG varchar2(2000) := NULL;
  l_DEPOT_REPAIR_FLAG varchar2(2000) := null;
  l_NEW_CP_STATUS_ID number := null;
  L_NEW_CP_STATUS_CODE varchar2(2000) := null;
  L_TRANSFER_SERVICE Varchar2(2000) := null;
  L_NEW_CP_RETURN_REQUIRED varchar2(2000):=null;
  L_DESCRIPTION Varchar2(2000) := null;
  L_MOVE_COUNTERS_FLAG varchar2(2000) := null;
  L_OBJECT_VERSION_NUMBER Number := 1;
  L_BLTYPE Varchar2(10) := NULL;

BEGIN
  x_Return_status := 'S';
  x_return_msg    := null;

      OPEN Cur_Txn_type_cnt;
      FETCH Cur_Txn_type_cnt into l_txntype_cnt;
      CLOSE Cur_Txn_type_cnt;

    IF l_txntype_cnt <> 0
    THEN
       NULL;
    ELSE
       OPEN Cur_txntype_max;
       FETCH Cur_txntype_max into l_txntype_id;
       CLOSE Cur_txntype_max;

  l_SEEDED_FLAG         := 'N';
  l_NAME                := 'SERVICE_CONTRACTS_UPGRADE_TXN';
  L_DESCRIPTION         := 'Transaction Type created for Upgrade';
  l_CREATION_DATE       := sysdate;
  l_CREATED_BY          := 1;
  l_LAST_UPDATE_DATE    := sysdate;
  l_LAST_UPDATED_BY     :=1;
  l_LAST_UPDATE_LOGIN   :=0;
/*

CS_TRANSACTION_TYPES_PKG.INSERT_ROW (
  X_ROWID                =>L_ROWID             ,
  X_TRANSACTION_TYPE_ID  => l_TXNTYPE_ID,
  X_SEEDED_FLAG          => L_SEEDED_FLAG          ,
  X_REVISION_FLAG        => L_REVISION_FLAG        ,
  X_END_DATE_ACTIVE      =>  L_END_DATE_ACTIVE    ,
  X_START_DATE_ACTIVE    => L_START_DATE_ACTIVE      ,
  X_ATTRIBUTE1           =>l_ATTRIBUTE1,
  X_ATTRIBUTE2           =>l_ATTRIBUTE2,
  X_ATTRIBUTE3           =>l_ATTRIBUTE3,
  X_ATTRIBUTE4           =>l_ATTRIBUTE4,
  X_ATTRIBUTE5           =>l_ATTRIBUTE5,
  X_ATTRIBUTE6           =>l_ATTRIBUTE6,
  X_ATTRIBUTE7           =>l_ATTRIBUTE7,
  X_ATTRIBUTE8           =>l_ATTRIBUTE8,
  X_ATTRIBUTE9           =>l_ATTRIBUTE9,
  X_ATTRIBUTE10           =>l_ATTRIBUTE10,
  X_CONTEXT              => l_CONTEXT,
  X_INSTALLED_CP_STATUS_ID => l_INSTALLED_CP_STATUS_ID,
  X_ATTRIBUTE11           =>l_ATTRIBUTE11,
  X_ATTRIBUTE12           =>l_ATTRIBUTE12,
  X_ATTRIBUTE13           =>l_ATTRIBUTE13,
  X_ATTRIBUTE14           =>l_ATTRIBUTE14,
  X_ATTRIBUTE15           =>l_ATTRIBUTE15,
  X_INSTALLED_STATUS_CODE => l_INSTALLED_STATUS_CODE,
  X_INSTALLED_CP_RETURN_REQUIRED =>l_INSTALLED_CP_RETURN_REQUIRED,
  X_NO_CHARGE_FLAG =>l_NO_CHARGE_FLAG ,
  X_DEPOT_REPAIR_FLAG =>l_DEPOT_REPAIR_FLAG,
  X_NEW_CP_STATUS_ID =>l_NEW_CP_STATUS_ID,
  X_NEW_CP_STATUS_CODE =>L_NEW_CP_STATUS_CODE,
  X_TRANSFER_SERVICE =>L_TRANSFER_SERVICE ,
  X_NEW_CP_RETURN_REQUIRED =>L_NEW_CP_RETURN_REQUIRED,
  X_NAME  =>L_NAME ,
  X_DESCRIPTION =>L_DESCRIPTION ,
  X_CREATION_DATE =>L_CREATION_DATE,
  X_CREATED_BY =>L_CREATED_BY ,
  X_LAST_UPDATE_DATE =>L_LAST_UPDATE_DATE,
  X_LAST_UPDATED_BY =>L_LAST_UPDATED_BY,
  X_LAST_UPDATE_LOGIN =>L_LAST_UPDATE_LOGIN ,
  X_MOVE_COUNTERS_FLAG =>L_MOVE_COUNTERS_FLAG,
  X_OBJECT_VERSION_NUMBER=>L_OBJECT_VERSION_NUMBER);
*/
          Create_Bus_process_Txn(l_txntype_id,
                                 l_Return_status,
                                 l_Return_Msg);
       IF l_return_status <> 'S'
       THEN
           l_return_msg := 'Error while creating Bus_process_Txn :'||l_Return_Msg;
           RAISE e_Error;
       END IF;
  -- Call this API for 'M,'L','E'
      l_bltype := 'M';
      Create_bltype(p_billing_type => l_bltype,
                    p_txntype_id   => l_txntype_id,
                    x_Return_status=> l_return_status,
                    x_Return_Msg   => l_return_msg);

       IF l_return_status <>'S'
       THEN
           raise e_Error;
       END IF;

      l_bltype := 'L';
      Create_bltype(p_billing_type => l_bltype,
                    p_txntype_id   => l_txntype_id,
                    x_Return_status=> l_return_status,
                    x_Return_Msg   => l_return_msg);
       IF l_return_status <>'S'
       THEN
           raise e_Error;
       END IF;

      l_bltype := 'E';
      Create_bltype(p_billing_type => l_bltype,
                    p_txntype_id   => l_txntype_id,
                    x_Return_status=> l_return_status,
                    x_Return_Msg   => l_return_msg);
       IF l_return_status <>'S'
       THEN
           raise e_Error;
       END IF;
END IF;

EXCEPTION
WHEN e_ERROR
THEN
   x_Return_status := 'E';
   x_Return_msg:=l_return_msg;
   rollback;
WHEN OTHERS THEN
   x_return_status := 'U';
   x_return_msg    := SQLCODE||'-'||SQLERRM;
raise_application_error(-20001,'While Creating Default Txn Billing Types :'||sqlerrm);

END Create_Txn_bltypes;


PROCEDURE Drive_Upg_Check IS

      l_return_status    Varchar2(3) := NULL;
      l_return_msg       Varchar2(2000):= NULL;
      l_exist_yn	 Varchar2(1);

	cursor Upg_Check_cur is
	select 'Y' from cs_cp_services_all
	where rownum < 2;

BEGIN

	Open Upg_Check_Cur;
	Fetch Upg_Check_Cur into l_exist_yn;

	if Upg_Check_Cur%notfound then
		l_exist_yn := 'N';
	end if;
	close Upg_Check_Cur;

	if l_exist_yn = 'Y' then
	   Insert_Time_code_units;

		Create_Index;
	end if;
END drive_upg_check;

PROCEDURE Update_status IS

	Cursor Cur_hdr_status IS
	select old_stat.name old_status
	from   okc_k_headers_v kh ,
		  cs_contracts_all csc,
	   	  cs_contract_statuses old_stat
	where csc.contract_status_id = old_stat.contract_status_id
	and   csc.contract_id = kh.id
	and   upper(kh.sts_code) <> upper(old_stat.name)
	and   exists (select b.code from okc_statuses_v b
	where upper(old_stat.name) = upper(b.code));

	Cursor Cur_line_status IS
	select old_stat.name old_status
	from   okc_k_lines_v kl ,
		  cs_cp_services_all ccs,
		  cs_contract_statuses old_stat
	where  ccs.contract_line_status_id = old_stat.contract_status_id
	and    ccs.cp_service_id = kl.id
	and    upper(kl.sts_code) <> upper(old_stat.name)
	and    exists (select b.code from okc_statuses_v b
	where upper(old_stat.name) = upper(b.code));

BEGIN

  FOR status_rec IN cur_hdr_status
  LOOP

     UPDATE OKC_K_HEADERS_B
	SET STS_CODE = UPPER(status_rec.old_status)
     WHERE id in (select cc.contract_id
     FROM cs_contracts_all cc,
	     cs_contract_statuses stat
     WHERE cc.contract_status_id = stat.contract_status_id
     AND  stat.name = status_rec.old_status);

  END LOOP;

  FOR status_rec IN cur_line_status
  LOOP

     UPDATE OKC_K_LINES_B
	SET STS_CODE = UPPER(status_rec.old_status)
     WHERE id in (select cs.cp_service_id
     FROM cs_cp_services_all cs,
	     cs_contract_statuses stat
     WHERE cs.contract_line_status_id = stat.contract_status_id
     AND  stat.name = status_rec.old_status);

  END LOOP;
  EXCEPTION when others then
	raise_application_error(-20000,'While updating STATUS :'||sqlerrm);
END Update_status;


PROCEDURE Update_time_zone IS

	CURSOR Cur_tz IS
	SELECT distinct dnz_chr_id
	FROM   CS_COVERAGE_TXN_GROUPS	 ctxg,
		  OKC_K_LINES_B    cle
	WHERE    cle.upg_Orig_System_Ref='CS_COVERAGE_TXN_GROUPS'
	AND      cle.upg_Orig_System_Ref_Id = ctxg.Coverage_txn_Group_id
	AND      ctxg.Time_Zone_Id IS NULL;

	l_cov_timezone_id Number;

BEGIN

  --l_cov_timezone_id := FND_PROFILE.value('OKS_COV_DEFAULT_TIMEZONE');
  l_cov_timezone_id := nvl(FND_PROFILE.value('CS_UPG_CONTRACTS_TIMEZONE'),47);

-- TVCP Migration 31-OCT-2003 MCHOUDHA
--updating the new OKS table OKS_COVERAGE_TIMEZONES with the
--value of the profile option

     UPDATE OKS_COVERAGE_TIMEZONES
	SET TIMEZONE_ID = l_cov_timezone_id --tz_rec.timezone_id
	WHERE  timezone_id = nvl(FND_PROFILE.value('CS_UPG_CONTRACTS_TIMEZONE'),47)
	AND dnz_chr_id IN --= tz_rec.chr_id
	( SELECT distinct dnz_chr_id
       FROM CS_COVERAGE_TXN_GROUPS	 ctxg,
    	       OKC_K_LINES_B      cle
       WHERE    cle.upg_Orig_System_Ref='CS_COVERAGE_TXN_GROUPS'
       AND      cle.upg_Orig_System_Ref_Id = ctxg.Coverage_txn_Group_id
       AND      ctxg.Time_Zone_Id IS NULL);

-- End Changes TVCP Migration 31-OCT-2003 MCHOUDHA

  EXCEPTION when others then
	raise_application_error(-20000,'While updating TIME ZONE :'||sqlerrm);

END Update_time_zone;

Procedure Create_Index Is

l_string	varchar2(5000) := NULL;
l_var		integer;
rc			integer;
l_index     varchar2(150);
l_index_name VARCHAR2(200);

cursor get_global_schema is
select oracle_username
 from fnd_oracle_userid
 where  read_only_flag = 'U';

cursor get_cov_sch_index(c_owner in varchar2) is
Select index_name
From all_indexes
Where index_name like 'OKC_K_LINES_B_UPG'
and owner = c_owner;

Cursor get_mtl_index(c_owner in varchar2) is
Select index_name
From all_indexes
Where index_name like 'COV_SCH_ID_N10'
and owner = c_owner;

 l_owner varchar2(100);

BEGIN

    open get_global_schema;
    fetch get_global_schema into l_owner;
    close get_global_schema;

      open get_mtl_index(c_owner => l_owner);
      fetch get_mtl_index into l_index_name;
  if(get_mtl_index%notfound) then

       l_string :=  'CREATE INDEX COV_SCH_ID_N10 ON MTL_SYSTEM_ITEMS_B(COVERAGE_SCHEDULE_ID)';

        BEGIN

                l_var := dbms_sql.open_cursor;
                dbms_sql.parse(l_var ,l_string,dbms_sql.native);
                rc := dbms_sql.execute(l_var);
                dbms_sql.close_cursor(l_var);
        END;


    End if;
    close get_mtl_index;

    FOR get_cov_sch_index_rec in get_cov_sch_index(c_owner => l_owner) LOOP
    l_index := get_cov_sch_index_rec.index_name;
    END LOOP;

    if l_index IS NULL then

	    l_string :=  'create index okc_k_lines_b_upg on okc_k_lines_b(upg_orig_system_ref,upg_orig_system_ref_id)';

	BEGIN
		l_var := dbms_sql.open_cursor;
		dbms_sql.parse(l_var ,l_string,dbms_sql.native);
		rc := dbms_sql.execute(l_var);
		dbms_sql.close_cursor(l_var);
	END;

	end if;

 EXCEPTION
 	WHEN OTHERS THEN
	 ROLLBACK;
 		RAISE_APPLICATION_ERROR(-20000,
				'Error In Procedure   Create_Index '||SQLERRM);
END Create_Index;

END OKS_UPGRADE_PRECHECK;


/
