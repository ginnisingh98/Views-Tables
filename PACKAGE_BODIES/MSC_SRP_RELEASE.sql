--------------------------------------------------------
--  DDL for Package Body MSC_SRP_RELEASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_SRP_RELEASE" AS
/* $Header: MSCPSRPB.pls 120.8.12010000.7 2009/11/13 09:20:21 vsiyer ship $ */

PROCEDURE log_message( p_user_info IN VARCHAR2) IS
BEGIN
       FND_FILE.PUT_LINE(FND_FILE.LOG, p_user_info);
EXCEPTION
   WHEN OTHERS THEN
   RAISE;
END log_message;

PROCEDURE log_output( p_user_info IN VARCHAR2) IS
BEGIN
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT, p_user_info);
EXCEPTION
   WHEN OTHERS THEN
   RAISE;
END log_output;

PROCEDURE  Release_new_ERO (       errbuf        OUT NOCOPY VARCHAR2,
                                   retcode       OUT NOCOPY VARCHAR2,
                                   p_batch_id    IN  number) IS

  Cursor Ro_release_data( p_batch_id number) is
	  Select *
    from    MRP_ERO_RELEASE
    where batch_id =p_batch_id
    order by transaction_id ;


    new_transaction_id boolean := FALSE;
    lv_transaction_id number := -999 ;
    lv_count number:=0 ;
    lv_tran_count number := 0;
    p_defective_parts_tbl Csp_repair_po_grp.defective_parts_tbl_Type; /* Table of records identifying
                                                                    all the defective parts and
                                                                    their quantities */
  X_Msg_Data            VARCHAR2(5000);
  X_Return_Status       VARCHAR2(1000);
  X_Msg_Count           NUMBER;
  x_requisition_header_id  NUMBER;
  x_msg_index_out NUMBER;
  p_msg_count NUMBER;
  /* For security */
   l_user_id   NUMBER;
   l_appl_id   NUMBER;
   l_src_org_id    number := 0;
   l_prev_src_org_id number := -99999;
   l_level_id  number;
   l_level_value  number;
   lv_req_number number ;

  Lv_repair_supplier_id MRP_ERO_RELEASE.REPAIR_SUPPLIER_ID%Type;
  Lv_repair_org_id      MRP_ERO_RELEASE.REPAIR_SUPPLIER_ORG_ID%Type;
  Lv_repair_program     MRP_ERO_RELEASE.REPAIR_PROGRAM%Type;
  Lv_destination_org_id MRP_ERO_RELEASE.DESTINATION_ORG_ID%Type;
  Lv_source_org_id      MRP_ERO_RELEASE.SOURCE_ORG_ID%Type;
  Lv_inventory_item_id  MRP_ERO_RELEASE.INVENTORY_ITEM_ID%Type;
  Lv_quantity           MRP_ERO_RELEASE.QUANTITY%Type;
  Lv_promise_date       MRP_ERO_RELEASE.PROMISE_DATE%Type;
  l_msg VARCHAR2(5000);
BEGIN
    log_output('                                            Repair Purchase Order Release Report');
    log_output('--------------------------------------------------------------------------------------------------');
    log_output('');
    log_output('Document Header ');
    --log_output('in PWB                                                                                              Req No.                                                                                                             ');
    log_output('--------------------------------------------------------------------------------------------------');

  begin
   l_user_id := fnd_global.user_id();
   l_appl_id := 724;  -- Application id for Advanced Supply Chain Planning


  For  l_ero_release in Ro_release_data(p_batch_id) loop
       Begin
        New_transaction_id := FALSE;

              If  lv_count <>  0  and  lv_transaction_id <> l_ero_release.transaction_id  then
		             New_transaction_id := TRUE;
		             lv_tran_count := 0;
 	            END IF ;

     if  new_transaction_id  then
  -- Get responsibility id
         log_message(' l_ero_release.SOURCE_ORG_ID-'||l_ero_release.SOURCE_ORG_ID);

         log_message('  l_user_id-'||l_user_id);
         log_message('  l_appl_id-'||l_appl_id);

        -- fnd_global.apps_initialize(l_user_id, l_level_value, l_appl_id);



         LOG_MESSAGE('p_api_version            :'||   1.0);
         LOG_MESSAGE('p_Init_Msg_List          :'||   'FND_API.G_FALSE');
         LOG_MESSAGE('p_commit                 :'||   'FND_API.G_FALSE');
         LOG_MESSAGE('P_repair_supplier_id	   :'||	 Lv_repair_supplier_id);
         LOG_MESSAGE('P_repair_supplier_org_id :'||	 Lv_repair_org_id);
         LOG_MESSAGE('P_repair_program	    	 :'||	 Lv_repair_program);
         LOG_MESSAGE('P_dest_organization_id	 :'||   Lv_destination_org_id);
         LOG_MESSAGE('P_source_organization_id :'||   Lv_source_org_id);
         LOG_MESSAGE('P_repair_to_item_id	  	 :'||   Lv_inventory_item_id);
         LOG_MESSAGE('P_quantity		        	 :'||   Lv_quantity);
         LOG_MESSAGE('P_need_by_date           :'||   Lv_promise_date);

         For i in 1 .. P_defective_parts_tbl.COUNT loop
         LOG_MESSAGE('P_defective_parts_tbl	   item :-'||i||' - '||   P_defective_parts_tbl(i).defective_item_id)	;
         LOG_MESSAGE('P_defective_parts_tbl	   qty  :-'||i||' - '||   P_defective_parts_tbl(i).defective_quantity)	;
         end loop;

        CSP_REPAIR_PO_GRP.CREATE_REPAIR_PO
         (p_api_version            =>   1.0
         ,p_Init_Msg_List          =>   FND_API.G_FALSE
         ,p_commit                 =>   FND_API.G_FALSE
         ,P_repair_supplier_id	   =>	  Lv_repair_supplier_id
         ,P_repair_supplier_org_id =>	  Lv_repair_org_id
         ,P_repair_program	    	 =>	  Lv_repair_program
         ,P_dest_organization_id	 =>   Lv_destination_org_id
         ,P_source_organization_id =>   Lv_source_org_id
         ,P_repair_to_item_id	  	 =>   Lv_inventory_item_id
         ,P_quantity		        	 =>   Lv_quantity
         ,P_need_by_date           =>   Lv_promise_date
         ,P_defective_parts_tbl	   =>   P_defective_parts_tbl
         ,x_requisition_header_id  =>   X_requisition_header_id
         ,x_return_status          =>   X_Return_Status
         ,x_msg_count              =>   X_Msg_Count
         ,x_msg_data               =>   X_Msg_Data
         );


               --COMMIT;
         IF (X_Return_Status <> 'S') THEN

              log_message('Number of Error Messages : '||TO_CHAR(x_msg_count));

           FOR i IN 1..X_Msg_Count LOOP
             FND_MSG_PUB.Get(p_msg_index     => i,
                            p_encoded       => 'F',
                            p_data          => x_msg_data,
                            p_msg_index_out => x_msg_index_out );
            log_message('message data ='||X_Msg_Data);
           END LOOP;
         END IF ;

         IF X_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              LOG_MESSAGE('Error in Repair Req creation  : FND_API.G_RET_STS_UNEXP_ERROR');
              rollback ;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            LOG_MESSAGE('Error in  Repair Req creation : FND_API.G_RET_STS_ERROR');
                rollback ;
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
            log_message('Successful in Creating Repair Req .');
            log_output('Successful in Creating Repair Req .');
            select requisition_number into lv_req_number from csp_repair_po_headers
            where REQUISITION_HEADER_ID=X_requisition_header_id;
            log_output('External Repair Requisition number      :' ||lv_req_number);
            Commit ;
        END IF;

          lv_transaction_id := NULL;

          For i in 1 .. P_defective_parts_tbl.COUNT loop
           P_defective_parts_tbl(i).defective_item_id := NULL;
           P_defective_parts_tbl(i).defective_quantity := NULL;
          end loop;

          Lv_repair_supplier_id :=NULL;
	        Lv_repair_org_id :=NULL;
          Lv_repair_program := NULL;
          Lv_destination_org_id :=NULL;
          Lv_source_org_id := NULL;
          Lv_inventory_item_id :=NULL;
          Lv_quantity := NULL;
          Lv_promise_date:=NULL;



END IF ;
EXCEPTION
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             LOG_MESSAGE('Error in Release_new_ERO : FND_API.G_EXC_UNEXPECTED_ERROR');
             LOG_MESSAGE(SQLERRM);
             retcode := 1;
             rollback  ;
             log_message('Transaction rolled back');
             log_message('----------------------------------------------------------');

          WHEN FND_API.G_EXC_ERROR THEN
             LOG_MESSAGE('Error in Release_new_ERO : FND_API.G_EXC_ERROR');
             LOG_MESSAGE(SQLERRM);
             retcode := 1;
              rollback ;
             log_message('Transaction rolled back');
             log_message('----------------------------------------------------------');
          WHEN OTHERS THEN
             LOG_MESSAGE('Error in Release_new_ERO : Err OTHERS');
             LOG_MESSAGE(SQLERRM);
             retcode := 1;
              log_message('Transaction rolled back');
             log_message('----------------------------------------------------------');
      END ; -- Begin at For Loop

                 Lv_count:= lv_count+1;
                 lv_tran_count := lv_tran_count+1;

             		 lv_transaction_id := l_ero_release.transaction_id;

                 P_defective_parts_tbl(lv_tran_count).defective_item_id := l_ero_release.defective_item_id;
                 P_defective_parts_tbl(lv_tran_count).defective_quantity := l_ero_release.DEFECTIVE_ITEM_QTY;


                 Lv_repair_supplier_id :=l_ero_release.repair_supplier_id;
    	           Lv_repair_org_id :=l_ero_release.repair_supplier_org_id;
                 Lv_repair_program := l_ero_release.repair_program;
                 Lv_destination_org_id :=l_ero_release.destination_org_id;
                 Lv_source_org_id := l_ero_release.source_org_id;
                 Lv_inventory_item_id :=l_ero_release.inventory_item_id;
                 Lv_quantity := l_ero_release.quantity;
                 Lv_promise_date:=l_ero_release.promise_date;


End loop;

/* for last record */
-- Get responsibility id
         log_message('Lv_source_org_id-'||Lv_source_org_id);

         log_message('l_user_id-'||l_user_id);
         log_message('l_appl_id-'||l_appl_id);

         --fnd_global.apps_initialize(l_user_id, l_level_value, l_appl_id);

         LOG_MESSAGE('p_api_version               :'||   1.0);
         LOG_MESSAGE('p_Init_Msg_List             :'||   'FND_API.G_FALSE');
         LOG_MESSAGE('p_commit                    :'||   'FND_API.G_FALSE');
         LOG_MESSAGE('P_repair_supplier_id	      :'||	 Lv_repair_supplier_id);
         LOG_MESSAGE('P_repair_supplier_org_id    :'||	 Lv_repair_org_id);
         LOG_MESSAGE('P_repair_program	    	    :'||	 Lv_repair_program);
         LOG_MESSAGE('P_dest_organization_id	    :'||   Lv_destination_org_id);
         LOG_MESSAGE('P_source_organization_id    :'||   Lv_source_org_id);
         LOG_MESSAGE('P_repair_to_item_id	  	    :'||   Lv_inventory_item_id);
         LOG_MESSAGE('P_quantity		        	    :'||   Lv_quantity);
         LOG_MESSAGE('P_need_by_date              :'||   Lv_promise_date);

          For i in 1 .. P_defective_parts_tbl.COUNT loop

            LOG_MESSAGE('P_defective_parts_tbl	   item :-'||i||'-' ||P_defective_parts_tbl(i).defective_item_id)	;
            LOG_MESSAGE('P_defective_parts_tbl	   qty  :-'||i||'-'|| P_defective_parts_tbl(i).defective_quantity)	;
          end loop;

      CSP_REPAIR_PO_GRP.CREATE_REPAIR_PO
         (p_api_version            =>   1.0
         ,p_Init_Msg_List          =>   FND_API.G_FALSE
         ,p_commit                 =>   FND_API.G_FALSE
         ,P_repair_supplier_id	   =>	  Lv_repair_supplier_id
         ,P_repair_supplier_org_id =>	  Lv_repair_org_id
         ,P_repair_program	    	 =>	  Lv_repair_program
         ,P_dest_organization_id	 =>   Lv_destination_org_id
         ,P_source_organization_id =>   Lv_source_org_id
         ,P_repair_to_item_id	  	 =>   Lv_inventory_item_id
         ,P_quantity		        	 =>   Lv_quantity
         ,P_need_by_date           =>   Lv_promise_date
         ,P_defective_parts_tbl	   =>   P_defective_parts_tbl
         ,x_requisition_header_id  =>   X_requisition_header_id
         ,x_return_status          =>   X_Return_Status
         ,x_msg_count              =>   X_Msg_Count
         ,x_msg_data               =>   X_Msg_Data
         );

                      --       COMMIT;

        IF (X_Return_Status <> 'S') THEN

              log_message('Number of Error Messages : '||TO_CHAR(x_msg_count));

           FOR i IN 1..X_Msg_Count LOOP
             FND_MSG_PUB.Get(p_msg_index     => i,
                            p_encoded       => 'F',
                            p_data          => x_msg_data,
                            p_msg_index_out => x_msg_index_out );
            log_message('message data ='||X_Msg_Data);
           END LOOP;
        END IF ;

         IF X_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              LOG_MESSAGE('Error in Repair req creation  : FND_API.G_RET_STS_UNEXP_ERROR');
              rollback ;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            LOG_MESSAGE('Error in  Repair Req creation : FND_API.G_RET_STS_ERROR');
                rollback ;
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
            log_message('Successful in Creating Repair Req .');
            log_output('Successful in Creating Repair Req .');
            select requisition_number into lv_req_number from csp_repair_po_headers
            where REQUISITION_HEADER_ID=X_requisition_header_id;
            log_output('External Repair Requisition number     :' ||lv_req_number);
            Commit ;
        END IF;
  EXCEPTION
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           LOG_MESSAGE('Error in Release_new_ERO : FND_API.G_EXC_UNEXPECTED_ERROR');
           LOG_MESSAGE(SQLERRM);
           retcode := 1;
           rollback  ;
           log_message('Transaction rolled back');
           log_message('----------------------------------------------------------');

        WHEN FND_API.G_EXC_ERROR THEN
           LOG_MESSAGE('Error in Release_new_ERO : FND_API.G_EXC_ERROR');
           LOG_MESSAGE(SQLERRM);
           retcode := 1;
            rollback ;
           log_message('Transaction rolled back');
           log_message('----------------------------------------------------------');
        WHEN OTHERS THEN
           LOG_MESSAGE('Error in Release_new_ERO : Err OTHERS');
           LOG_MESSAGE(SQLERRM);
           retcode := 1;
            log_message('Transaction rolled back');
           log_message('----------------------------------------------------------');
  End;

    DELETE FROM MRP_ERO_RELEASE WHERE BATCH_ID=p_batch_id ;
    Commit;

END Release_new_ERO;

Procedure update_iro (errbuf        OUT NOCOPY VARCHAR2,
                      retcode       OUT NOCOPY VARCHAR2,
                      p_repair_line_id  IN NUMBER,
                      p_quantity  IN NUMBER:= NULL,
                      p_promise_date IN DATE:= NULL)
IS
    Cursor c1(p_repair_line_id number) is
    select * from csd_repairs
    where repair_line_id = p_repair_line_id ;

    l_repair_rec          CSD_REPAIRS%rowtype;
    l_Init_Msg_List       VARCHAR2(1000):= FND_API.G_FALSE;
    l_Commit              VARCHAR2(1000):= FND_API.G_FALSE;
    l_validation_level    NUMBER:=FND_API.G_VALID_LEVEL_FULL;
    Q_REPLN_Rec           CSD_REPAIRS_PUB.REPLN_Rec_Type;
    X_Return_Status       VARCHAR2(1000);
    p_Msg_Count           NUMBER;
    X_Msg_Data            VARCHAR2(5000);
    l_msg                 VARCHAR2(5000);
BEGIN
     retcode:=0 ;
     open c1(p_repair_line_id);
     fetch c1 into l_repair_rec;
     close c1;
     Q_REPLN_Rec.REPAIR_NUMBER:= l_repair_rec.REPAIR_NUMBER;
     Q_REPLN_Rec.INCIDENT_ID:= l_repair_rec.INCIDENT_ID;
		 Q_REPLN_Rec.INVENTORY_ITEM_ID:= l_repair_rec.INVENTORY_ITEM_ID;
     Q_REPLN_Rec.CUSTOMER_PRODUCT_ID:= l_repair_rec.CUSTOMER_PRODUCT_ID;
		 Q_REPLN_Rec.UNIT_OF_MEASURE:=l_repair_rec.UNIT_OF_MEASURE;
	   Q_REPLN_Rec.REPAIR_TYPE_ID:=l_repair_rec.REPAIR_TYPE_ID;
     Q_REPLN_Rec.RESOURCE_GROUP:=NULL;
     Q_REPLN_Rec.RESOURCE_ID:=l_repair_rec.RESOURCE_ID;
     Q_REPLN_Rec.PROJECT_ID:=l_repair_rec.PROJECT_ID;
     Q_REPLN_Rec.TASK_ID:= l_repair_rec.TASK_ID;
     Q_REPLN_Rec.UNIT_NUMBER:= l_repair_rec.UNIT_NUMBER;
     Q_REPLN_Rec.CONTRACT_LINE_ID:=l_repair_rec.CONTRACT_LINE_ID;
     Q_REPLN_Rec.AUTO_PROCESS_RMA:=l_repair_rec.AUTO_PROCESS_RMA;
     Q_REPLN_Rec.REPAIR_MODE:= l_repair_rec.REPAIR_MODE;
     Q_REPLN_Rec.OBJECT_VERSION_NUMBER:=l_repair_rec.OBJECT_VERSION_NUMBER;
     Q_REPLN_Rec.ITEM_REVISION:=l_repair_rec.ITEM_REVISION;
     Q_REPLN_Rec.INSTANCE_ID:=l_repair_rec.INSTANCE_ID;
     Q_REPLN_Rec.STATUS:= l_repair_rec.STATUS;
     Q_REPLN_Rec.STATUS_REASON_CODE:=l_repair_rec.STATUS_REASON_CODE;
     Q_REPLN_Rec.DATE_CLOSED:=l_repair_rec.DATE_CLOSED;
     Q_REPLN_Rec.APPROVAL_REQUIRED_FLAG:=l_repair_rec.APPROVAL_REQUIRED_FLAG;
     Q_REPLN_Rec.APPROVAL_STATUS:=l_repair_rec.APPROVAL_STATUS;
     Q_REPLN_Rec.SERIAL_NUMBER:=l_repair_rec.SERIAL_NUMBER;
     IF p_promise_date is not null then
      Q_REPLN_Rec.PROMISE_DATE:= p_promise_date;--   NULL;-- '2/20/2007'
     ELSE
      Q_REPLN_Rec.PROMISE_DATE:=l_repair_rec.PROMISE_DATE;
     END IF;
     Q_REPLN_Rec.ATTRIBUTE_CATEGORY:=l_repair_rec.ATTRIBUTE_CATEGORY;
     Q_REPLN_Rec.ATTRIBUTE1:=l_repair_rec.ATTRIBUTE1;
     Q_REPLN_Rec.ATTRIBUTE2:=l_repair_rec.ATTRIBUTE2;
     Q_REPLN_Rec.ATTRIBUTE3:=l_repair_rec.ATTRIBUTE3;
     Q_REPLN_Rec.ATTRIBUTE4:=l_repair_rec.ATTRIBUTE4;
     Q_REPLN_Rec.ATTRIBUTE5:=l_repair_rec.ATTRIBUTE5;
     Q_REPLN_Rec.ATTRIBUTE6:=l_repair_rec.ATTRIBUTE6;
     Q_REPLN_Rec.ATTRIBUTE7:=l_repair_rec.ATTRIBUTE7;
     Q_REPLN_Rec.ATTRIBUTE8:=l_repair_rec.ATTRIBUTE8;
     Q_REPLN_Rec.ATTRIBUTE9:=l_repair_rec.ATTRIBUTE9;
     Q_REPLN_Rec.ATTRIBUTE10:=l_repair_rec.ATTRIBUTE10;
     Q_REPLN_Rec.ATTRIBUTE11:=l_repair_rec.ATTRIBUTE11;
     Q_REPLN_Rec.ATTRIBUTE12:=l_repair_rec.ATTRIBUTE12;
     Q_REPLN_Rec.ATTRIBUTE13:=l_repair_rec.ATTRIBUTE13;
     Q_REPLN_Rec.ATTRIBUTE14:=l_repair_rec.ATTRIBUTE14;
     Q_REPLN_Rec.ATTRIBUTE15:=l_repair_rec.ATTRIBUTE15;
     IF p_quantity is not null then
      Q_REPLN_Rec.QUANTITY:=p_quantity;
     ELSE
      Q_REPLN_Rec.QUANTITY:=l_repair_rec.quantity ;
     END IF ;
     Q_REPLN_Rec.QUANTITY_IN_WIP:=l_repair_rec.QUANTITY_IN_WIP;
     Q_REPLN_Rec.QUANTITY_RCVD:=l_repair_rec.QUANTITY_RCVD;
     Q_REPLN_Rec.QUANTITY_SHIPPED:= l_repair_rec.QUANTITY_SHIPPED;
     Q_REPLN_Rec.CURRENCY_CODE:=l_repair_rec.CURRENCY_CODE;
     Q_REPLN_Rec.DEFAULT_PO_NUM:=l_repair_rec.DEFAULT_PO_NUM;
     Q_REPLN_Rec.REPAIR_GROUP_ID:=l_repair_rec.REPAIR_GROUP_ID;
     Q_REPLN_Rec.RO_TXN_STATUS:=l_repair_rec.RO_TXN_STATUS;
     Q_REPLN_Rec.ORDER_LINE_ID:=l_repair_rec.ORDER_LINE_ID;
     Q_REPLN_Rec.ORIGINAL_SOURCE_REFERENCE :=l_repair_rec.ORIGINAL_SOURCE_REFERENCE;
     Q_REPLN_Rec.ORIGINAL_SOURCE_HEADER_ID :=l_repair_rec.ORIGINAL_SOURCE_HEADER_ID;
     Q_REPLN_Rec.ORIGINAL_SOURCE_LINE_ID   :=l_repair_rec.ORIGINAL_SOURCE_LINE_ID;
     Q_REPLN_Rec.PRICE_LIST_HEADER_ID  :=l_repair_rec.PRICE_LIST_HEADER_ID;
     Q_REPLN_Rec.SUPERCESSION_INV_ITEM_ID :=l_repair_rec.SUPERCESSION_INV_ITEM_ID;
     Q_REPLN_Rec.FLOW_STATUS_ID:=l_repair_rec.FLOW_STATUS_ID;
     Q_REPLN_Rec.FLOW_STATUS_CODE:=null;
     Q_REPLN_Rec.FLOW_STATUS:=null;
     Q_REPLN_Rec.INVENTORY_ORG_ID:=l_repair_rec.INVENTORY_ORG_ID;
     Q_REPLN_Rec.PROBLEM_DESCRIPTION:=l_repair_rec.PROBLEM_DESCRIPTION;
     Q_REPLN_Rec.RO_PRIORITY_CODE:=l_repair_rec.RO_PRIORITY_CODE;

     CSD_Repairs_PUB.Update_Repair_Order(
                                  P_Api_Version_Number => 1.0,
                                  P_Init_Msg_List => l_Init_Msg_List,
                                  P_Commit => l_Commit,
                                  p_validation_level   => l_validation_level,
                                  P_REPAIR_LINE_ID => P_REPAIR_LINE_ID,
                                  P_REPLN_Rec       => Q_REPLN_Rec,
                                  X_Return_Status =>  X_Return_Status,
                                  X_Msg_Count =>      p_Msg_Count,
                                  X_Msg_Data  =>      X_Msg_Data);

     IF p_msg_count IS NOT NULL THEN
          IF p_msg_count = 1 THEN
                l_msg :=  fnd_msg_pub.get(p_msg_index => 1,
                                          p_encoded => 'F' );
                log_message(l_msg);
          ELSIF p_msg_count > 1 THEN
                FOR i IN 1..p_msg_count
                LOOP
                     l_msg := fnd_msg_pub.get(p_msg_index => i,
                                              p_encoded => 'F' );
                      Fnd_file.put_line(fnd_file.LOG,l_msg);
                 END LOOP;
           END IF;
     END IF;
     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           LOG_MESSAGE('Error in updating reapir order  : FND_API.G_RET_STS_UNEXP_ERROR');
            rollback ;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
           LOG_MESSAGE('Error in updating reapir order : FND_API.G_RET_STS_ERROR');
            rollback ;
           RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
            log_message('Successful in Updating repair order .');
            log_message('repair number     :' ||l_repair_rec.repair_number);
    END IF;
EXCEPTION
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         LOG_MESSAGE('Error in updating reapir order : FND_API.G_EXC_UNEXPECTED_ERROR');
         LOG_MESSAGE(SQLERRM);
         retcode := 1;
         rollback  ;
         log_message('Transaction rolled back');
         log_message('----------------------------------------------------------');

      WHEN FND_API.G_EXC_ERROR THEN
         LOG_MESSAGE('Error in updating reapir order : FND_API.G_EXC_ERROR');
         LOG_MESSAGE(SQLERRM);
         retcode := 1;
          rollback ;
         log_message('Transaction rolled back');
         log_message('----------------------------------------------------------');
      WHEN OTHERS THEN
         LOG_MESSAGE('Error in updating reapir order : Err OTHERS');
         LOG_MESSAGE(SQLERRM);
         retcode := 1;
          rollback ;
          log_message('Transaction rolled back');
         log_message('----------------------------------------------------------');
END update_iro;


PROCEDURE MSC_RELEASE_IRO( p_user_name        IN  VARCHAR2,
                           p_resp_name        IN  VARCHAR2,
                           p_application_name IN  VARCHAR2,
                           p_application_id   IN  NUMBER,
                           p_batch_id    IN       number,
                           p_load_type   IN       number,
                           arg_iro_load_id            IN OUT  NOCOPY  Number
                            ) IS


l_request     number;
l_result      BOOLEAN;
lv_user_name         VARCHAR2(100);
lv_resp_name         VARCHAR2(100);

    l_user_id            NUMBER;
    lv_log_msg           varchar2(500);

BEGIN
   BEGIN
      SELECT USER_ID
       INTO l_user_id
       FROM FND_USER
      WHERE USER_NAME = p_user_name;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
          LOG_MESSAGE('Error in MSC_RELEASE_IRO : NO_USER_DEFINED');
          raise_application_error (-20001, 'NO_USER_DEFINED');
      WHEN OTHERS THEN RAISE;
   END;

    IF MRP_CL_FUNCTION.validateUser(l_user_id,MSC_UTIL.TASK_RELEASE,lv_log_msg) THEN
        MRP_CL_FUNCTION.MSC_Initialize(MSC_UTIL.TASK_RELEASE,
                                       l_user_id,
                                       -1, --l_resp_id,
                                       -1 --l_application_id
                                       );
    ELSE
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  lv_log_msg);
        raise_application_error (-20001, lv_log_msg);
    END IF;

    l_result := FND_REQUEST.SET_MODE(TRUE);

--=====================================
         l_request := FND_REQUEST.SUBMIT_REQUEST
         ('MSC',
          'MSCRLIRO',
          'Release IRO to Source',
           null,
           FALSE,
           p_batch_id);

   IF nvl(l_request,0) = 0 THEN
      LOG_MESSAGE('Error in MSC_RELEASE_IRO');
   ELSE
      IF p_load_type = IRO_LOAD THEN
         arg_iro_load_id := l_request;
         LOG_MESSAGE('Concurrent Request ID For IRO Load : ' || arg_iro_load_id);
      END IF;
   END IF;
    LOG_MESSAGE('MSC_RELEASE_IRO completed successfully');

END MSC_RELEASE_IRO;


Procedure  Release_new_IRO (
                                   errbuf        OUT NOCOPY VARCHAR2,
                                   retcode       OUT NOCOPY VARCHAR2,
                                    p_batch_id    IN  number) IS
l_iso_header_id Number ;
l_req_header_id Number ;
l_iso_header_id1 Number ;
l_iso_header_id2 Number ;
l_req_header_id1 Number ;
l_req_header_id2 Number ;
p_msg_count NUMBER;
l_msg VARCHAR2(5000);
x_return_status VARCHAR2(1000);
x_msg_data  VARCHAR2(2000);

lv_repair_line_id number;
x_service_request_number VARCHAR2(3000);

P_Init_Msg_List       VARCHAR2(1000);
P_Commit              VARCHAR2(1000);
p_validation_level    NUMBER;
P_REPAIR_LINE_ID      NUMBER;
Q_REPLN_Rec           CSD_REPAIRS_PUB.REPLN_Rec_Type;
p_create_default_logistics   VARCHAR2(100) := 'N';

X_REPAIR_NUMBER       VARCHAR2(1000);
X_Msg_Count           NUMBER;
global_retcode             NUMBER := 0;

Cursor Ro_release_data( p_batch_id number)  is
	Select Transaction_id,Quantity,in_req_quantity,out_req_quantity,In_req_transaction_id,
        Out_req_transaction_id,Batch_id,Inventory_item_id
        Uom_code,Organization_id,Promise_date
  from    MRP_IRO_RELEASE
  where batch_id =p_batch_id
  and  load_type = IRO_LOAD
  AND In_req_transaction_id is not NULL;

Cursor Ro_release_OH_data( p_batch_id number)  is
   Select distinct Transaction_id, Quantity,
        Out_req_transaction_id, Batch_id, Inventory_item_id,
        Uom_code, Organization_id, Promise_date ,deliver_to_location_id,
        src_organization_id,LOAD_TYPE
  from    MRP_IRO_RELEASE
  where batch_id =p_batch_id
  and  load_type =IRO_LOAD
  and  in_req_transaction_id  is  null ;

p_service_request_rec CS_SERVICEREQUEST_PUB.SERVICE_REQUEST_REC_TYPE;
p_notes CS_SERVICEREQUEST_PUB.NOTES_TABLE;
p_contacts CS_SERVICEREQUEST_PUB.CONTACTS_TABLE;
x_request_id NUMBER;
x_request_number VARCHAR2(2000);
x_interaction_id NUMBER;
x_workflow_process_id NUMBER := NULL;--2271;
x_msg_index_out NUMBER;
x_individual_owner NUMBER;
x_group_owner NUMBER;
x_individual_type    VARCHAR2(30);
v_lang   VARCHAR2(30);
    l_customer_id              NUMBER;
    l_address_id               NUMBER;
    l_site_use_id              NUMBER;
    l_customer_NAME            VARCHAR2(2000);
    l_party_id                 NUMBER;


--Q_REPLN_Rec           CSD_REPAIRS_PUB.REPLN_Rec_Type;
--p_create_default_logistics   VARCHAR2(100) := 'N';
--P_REPAIR_LINE_ID      NUMBER;
P_REPAIR_TYPE         NUMBER;
X_REPAIR_LINE_ID      NUMBER;
l_currency_code       VARCHAR2(100);
--X_REPAIR_NUMBER       VARCHAR2(1000);
l_customer_contact_id  NUMBER;
l_user_id NUMBER;
l_group_id  NUMBER;
x_wipEntityID  NUMBER;

l_wip_job_name      VARCHAR2(2000);
px_REPAIR_JOB_XREF_ID NUMBER;
l_return_status VARCHAR2(2000);
BEGIN
    log_output('                                            Internal Requisition/ISO Release and Reschedule Report');
    log_output('                                            ------------------------------------------------------');
    log_output('');
    log_output('Order No      Load Type     ISO No     Quantity   Schedule Shipment Date   Schedule Arrival Date   Internal   Need By Date');
    log_output('in PWB                                                                                              Req No.                                                                                                             ');
    log_output('-----------   -----------   --------   --------   ----------------------   ----------------------   --------   ----------------------');



   Delete from  MRP_IRO_RELEASE mir
      where batch_id =p_batch_id
        And in_req_transaction_id  is null
        AND load_type = IRO_LOAD
        And  exists (  select 1 from mrp_iro_release mir1
	                         Where mir1.batch_id =p_batch_id
	                          And  mir1.in_req_transaction_id  is not null
	                          And  mir1.transaction_id = mir.transaction_id
                    );

    -- Added to process repair orders with no inward movement of defectives
    -- ie onhand pegged defective supplies

    For  l_ro_release in Ro_release_OH_data(p_batch_id) loop

    BEGIN
    LOG_MESSAGE('Creating MOVE OUT lines');

    Update  mrp_org_transfer_release
     set part_condition ='G'
     where transaction_id= l_ro_release.Out_req_transaction_id;

    mrp_create_schedule_iso.Create_IR_ISO(errbuf,retcode ,l_req_header_id,l_iso_header_id, l_ro_release.Out_req_transaction_id, l_ro_release.batch_id );
        l_iso_header_id1 := l_iso_header_id;
        l_req_header_id1:= l_req_header_id ;
        if  (retcode=0  ) then

          LOG_MESSAGE('Creating Repair Incident');
          CS_SERVICEREQUEST_PUB.initialize_rec(p_service_request_rec);
          p_service_request_rec.request_date := SYSDATE;
          p_service_request_rec.type_name := '';

            p_service_request_rec.type_id := to_number(FND_PROFILE.VALUE('INC_DEFAULT_INCIDENT_TYPE'));
              if (p_service_request_rec.type_id  <> 4) Then
                LOG_MESSAGE('Please set a correct value for Profile :-Service: Default Service Request Type-');
              end if;
          p_service_request_rec.status_id := 1; -- Open
          p_service_request_rec.status_name := '';

            p_service_request_rec.severity_id := to_number(FND_PROFILE.VALUE('INC_DEFAULT_INCIDENT_SEVERITY'));
              if (p_service_request_rec.severity_id  <> 4) Then
                LOG_MESSAGE('Please set a correct value for Profile :-Service: Default Service Request Severity-');
              end if;

          p_service_request_rec.severity_name := '';

             p_service_request_rec.urgency_id := to_number(FND_PROFILE.VALUE('INC_DEFAULT_INCIDENT_URGENCY'));
              if (p_service_request_rec.urgency_id  <> 44) Then
                LOG_MESSAGE('Please set a correct value for Profile :-Service: Default Service Request Urgency-');
              end if;

          p_service_request_rec.urgency_name := '';
          p_service_request_rec.closed_date := TO_DATE('');

             p_service_request_rec.owner_id := to_number(FND_PROFILE.VALUE('INC_DEFAULT_INCIDENT_OWNER'));
              if (p_service_request_rec.owner_id  is null) Then
                LOG_MESSAGE('Please set a correct value for Profile :-Service: Default Service Request Owner-');
              end if;

            -- Get Customer ID
          BEGIN
  	         log_message('Source organization id => ' || l_ro_release.src_organization_id);

             po_customers_sv.get_cust_details(l_ro_release.deliver_to_location_id,
  			                                          l_customer_id,
                                                  l_address_id,
                                                  l_site_use_id,
  						                              l_ro_release.src_organization_id);

/*             select cust_account_id,account_number
             into l_acct_id,l_acct_number
             from hz_cust_accounts_all
                where cust_account_id = l_customer_id -- bug # 8299478
                and customer_type ='I'
                and rownum < 2;
                */

             select hp.party_number, hp.party_id
             into l_customer_NAME,l_party_id
              from  hz_parties hp,hz_cust_accounts_all hca --ra_customers
              where hp.party_id = hca.party_id
              and hca.cust_account_id = l_customer_id  -- bug # 8299478
              and hca.customer_type ='I'
              and rownum < 2;
  	      Exception
          when others then
           LOG_MESSAGE('Error in Getting Customer Details for the Incident' ||l_customer_id);
           LOG_MESSAGE(SQLERRM);
           RAISE;
  				END;
          p_service_request_rec.owner_group_id := NULL; -- CS_SR_DEFAULT_GROUP_OWNER
          p_service_request_rec.publish_flag := '';
          p_service_request_rec.SUMMARY := 'DEPOT REPAIR';
          p_service_request_rec.caller_type := 'ORGANIZATION';
          p_service_request_rec.customer_id := l_party_id ; -- bug # 8299478
          p_service_request_rec.customer_number := NULL;
          p_service_request_rec.employee_id := NULL;
          p_service_request_rec.employee_number := '';
          p_service_request_rec.verify_cp_flag := FND_API.G_MISS_CHAR;
          p_service_request_rec.customer_product_id := NULL;
          p_service_request_rec.platform_id := NULL;
          p_service_request_rec.platform_version_id := NULL;
          p_service_request_rec.cp_component_id := NULL;
          p_service_request_rec.cp_component_version_id := NULL;
          p_service_request_rec.cp_subcomponent_id := NULL;
          p_service_request_rec.cp_subcomponent_version_id := NULL;
          p_service_request_rec.language_id := NULL;
            Begin
             select userenv('LANG')
             Into v_lang from dual;

             p_service_request_rec.LANGUAGE := v_lang;
            End;
          p_service_request_rec.cp_ref_number := NULL;

          p_service_request_rec.inventory_item_id := l_ro_release.Inventory_item_id;
          p_service_request_rec.inventory_item_conc_segs := '';
          p_service_request_rec.inventory_item_segment1 := '';
          p_service_request_rec.inventory_item_segment2 := '';
          p_service_request_rec.inventory_item_segment3 := '';
          p_service_request_rec.inventory_item_segment4 := '';
          p_service_request_rec.inventory_item_segment5 := '';
          p_service_request_rec.inventory_item_segment6 := '';
          p_service_request_rec.inventory_item_segment7 := '';
          p_service_request_rec.inventory_item_segment8 := '';
          p_service_request_rec.inventory_item_segment9 := '';
          p_service_request_rec.inventory_item_segment10 := '';
          p_service_request_rec.inventory_item_segment11 := '';
          p_service_request_rec.inventory_item_segment12 := '';
          p_service_request_rec.inventory_item_segment13 := '';
          p_service_request_rec.inventory_item_segment14 := '';
          p_service_request_rec.inventory_item_segment15 := '';
          p_service_request_rec.inventory_item_segment16 := '';
          p_service_request_rec.inventory_item_segment17 := '';
          p_service_request_rec.inventory_item_segment18 := '';
          p_service_request_rec.inventory_item_segment19 := '';
          p_service_request_rec.inventory_item_segment20 := '';
          p_service_request_rec.inventory_item_vals_or_ids := '';

          p_service_request_rec.inventory_org_id := l_ro_release.Organization_id;
          p_service_request_rec.current_serial_number := '';
          p_service_request_rec.original_order_number := NULL;
          p_service_request_rec.purchase_order_num := '';
          p_service_request_rec.problem_code := '';
          p_service_request_rec.exp_resolution_date := TO_DATE('');
          p_service_request_rec.install_site_use_id := NULL;
          p_service_request_rec.request_attribute_1 := '';
          p_service_request_rec.request_attribute_2 := '';
          p_service_request_rec.request_attribute_3 := '';
          p_service_request_rec.request_attribute_4 := '';
          p_service_request_rec.request_attribute_5 := '';
          p_service_request_rec.request_attribute_6 := '';
          p_service_request_rec.request_attribute_7 := '';
          p_service_request_rec.request_attribute_8 := '';
          p_service_request_rec.request_attribute_9 := '';
          p_service_request_rec.request_attribute_10 := '';
          p_service_request_rec.request_attribute_11 := '';
          p_service_request_rec.request_attribute_12 := '';
          p_service_request_rec.request_attribute_13 := '';
          p_service_request_rec.request_attribute_14 := '';
          p_service_request_rec.request_attribute_15 := '';
          p_service_request_rec.request_context := '';
          p_service_request_rec.bill_to_site_use_id := NULL;
          p_service_request_rec.bill_to_contact_id := NULL;
          p_service_request_rec.ship_to_site_use_id := NULL;
          p_service_request_rec.ship_to_contact_id := NULL;
          p_service_request_rec.resolution_code := '';
          p_service_request_rec.act_resolution_date := TO_DATE('');
          p_service_request_rec.public_comment_flag := '';
          p_service_request_rec.parent_interaction_id := NULL;
          p_service_request_rec.contract_service_id := NULL;
          p_service_request_rec.contract_service_number := '';
          p_service_request_rec.contract_id := NULL;
          p_service_request_rec.project_number := '';
          p_service_request_rec.qa_collection_plan_id := NULL;

          p_service_request_rec.account_id :=  l_customer_id;

          p_service_request_rec.resource_type := 'RS_EMPLOYEE';
          p_service_request_rec.resource_subtype_id := NULL;
          p_service_request_rec.cust_po_number := '';
          p_service_request_rec.cust_ticket_number := '';
          p_service_request_rec.sr_creation_channel := 'Phone';
          p_service_request_rec.obligation_date := TO_DATE('');
          p_service_request_rec.time_zone_id := NULL;
          p_service_request_rec.time_difference := NULL;
          p_service_request_rec.site_id := NULL;
          p_service_request_rec.customer_site_id := NULL;
          p_service_request_rec.territory_id := NULL;
          p_service_request_rec.initialize_flag := '';
          p_service_request_rec.cp_revision_id := NULL;
          p_service_request_rec.inv_item_revision := '';
          p_service_request_rec.inv_component_id := NULL;
          p_service_request_rec.inv_component_version := '';
          p_service_request_rec.inv_subcomponent_id := NULL;
          p_service_request_rec.inv_subcomponent_version := '';
          p_notes(1).note := '';
          p_notes(1).note_detail := '';
          p_notes(1).note_type := '';
          p_notes(1).note_context_type_01 := '';
          p_notes(1).note_context_type_id_01 := NULL;
          p_notes(1).note_context_type_02 := '';
          p_notes(1).note_context_type_id_02 := NULL;
          p_notes(1).note_context_type_03 := '';
          p_notes(1).note_context_type_id_03 := NULL;
          p_contacts(1).sr_contact_point_id := NULL;

          /* For Getting a contact point for this customer */
          BEGIN
          SELECT r.party_id
              INTO l_customer_contact_id
              FROM    Hz_Parties sub,
              Hz_Relationships r,
              Hz_Parties obj
              WHERE r.object_id = l_party_id
              --AND   r.party_id  = p_customer_contact_id
              AND   sub.status = 'A'
              AND   r.status   = 'A'
              AND   obj.status = 'A'
              AND   r.subject_id = sub.party_id
              AND   r.object_id  = obj.party_id
              AND   sub.party_type = 'PERSON'
              AND   obj.party_type = 'ORGANIZATION'
              AND   NVL(r.start_date, SYSDATE-1) <= SYSDATE
              AND   NVL(r.end_date, SYSDATE+1) > SYSDATE
              AND ROWNUM < 2
              ORDER BY r.LAST_UPDATE_DATE Desc;
          LOG_MESSAGE('Contatc For Cusomer-'||l_customer_contact_id);
          EXCEPTION
          When Others Then
           LOG_MESSAGE('Error in getting the contact for customer id-'||l_customer_id);
           LOG_MESSAGE(SQLERRM);
           ROLLBACK;
          END;

          p_contacts(1).party_id := l_customer_contact_id	;
          p_contacts(1).contact_point_id := NULL;
          p_contacts(1).contact_point_type := '';
          p_contacts(1).primary_flag := 'Y';
          p_contacts(1).contact_type := 'PARTY_RELATIONSHIP';

          /* Call to CSD API to cretate Incident Id for repair Order */
          BEGIN
          cs_servicerequest_pub.create_servicerequest
                        (p_api_version             => 3.0,
                        p_init_msg_list            =>  FND_API.G_TRUE,
                        p_commit                   =>  FND_API.G_TRUE,
                        x_return_status            =>  x_return_status,
                        x_msg_count                =>  x_msg_count,
                        x_msg_data                 =>  x_msg_data,
                        p_resp_appl_id             =>  NULL,
                        p_resp_id                  =>  NULL,
                        p_user_id                  =>  NULL,
                        p_login_id                 =>  NULL,
                        p_org_id                   =>  NULL,
                        p_request_id               =>  NULL,
                        p_request_number           =>  '',
                        p_service_request_rec      =>  p_service_request_rec,
                        p_notes                    =>  p_notes,
                        p_contacts                 =>  p_contacts,
                        p_auto_assign              =>  'N',
                        x_request_id               =>  x_request_id,
                        x_request_number           =>  x_request_number,
                        x_interaction_id           =>  x_interaction_id,
                        x_workflow_process_id      =>  x_workflow_process_id,
                        x_individual_owner         =>  x_individual_owner,
                        x_group_owner              =>  x_group_owner,
                        x_individual_type          =>  x_individual_type);

            --COMMIT;
            IF (x_return_status <> 'S') THEN
              LOG_MESSAGE('Number of Error Messages : '||TO_CHAR(x_msg_count));
              FOR i IN 1..x_msg_Count LOOP
                    FND_MSG_PUB.Get(p_msg_index     => i,
                                    p_encoded       => 'F',
                                    p_data          => x_msg_data,
                                    p_msg_index_out => x_msg_index_out );
              LOG_MESSAGE('message data ='||x_msg_data);
             END LOOP;
             LOG_MESSAGE('error msg       = '||SQLERRM);
           ELSE
              -- Output the results
              LOG_MESSAGE('x_return_status = '||x_return_status);
              LOG_MESSAGE('x_msg_count = '||TO_CHAR(x_msg_count));
              LOG_MESSAGE('x_msg_data = '||x_msg_data);
              LOG_MESSAGE('x_request_id/Incident_id = '||TO_CHAR(x_request_id));
              LOG_MESSAGE('x_request_number/Incident_number = '||x_request_number);
              LOG_MESSAGE('x_interaction_id = '||TO_CHAR(x_interaction_id));
              LOG_MESSAGE('x_workflow_process_id = '||TO_CHAR(x_workflow_process_id));

              log_output('Service Incident Number:'||To_Char(x_request_number));
              LOG_MESSAGE('-------------------------------------------------------------------');

              LOG_MESSAGE('Trying to Create a Repair Order for this incident');

              Q_REPLN_Rec.REPAIR_NUMBER        :=   NULL;
              Q_REPLN_Rec.INCIDENT_ID          :=   x_request_id;
              Q_REPLN_Rec.INVENTORY_ITEM_ID    :=   l_ro_release.Inventory_item_id;
              Q_REPLN_Rec.CUSTOMER_PRODUCT_ID  :=   NULL;
              Q_REPLN_Rec.UNIT_OF_MEASURE      :=   l_ro_release.Uom_code;
                BEGIN
                 select repair_type_id
                   Into P_REPAIR_TYPE
                   from CSD_REPAIR_TYPES_B
                    where repair_mode = 'WIP'
                      and internal_order_flag = 'Y'
                      and rownum < 2;
                Q_REPLN_Rec.REPAIR_TYPE_ID       :=        P_REPAIR_TYPE;
                EXCEPTION
                 When others then
                 Q_REPLN_Rec.REPAIR_TYPE_ID       :=  NULL;
                 LOG_MESSAGE('Error while getting a repair Type');
                 LOG_MESSAGE(SQLERRM);
                END;


              Q_REPLN_Rec.RESOURCE_GROUP :=           NULL;
              Q_REPLN_Rec.RESOURCE_ID    :=           NULL;
              Q_REPLN_Rec.PROJECT_ID    :=            NULL;
              Q_REPLN_Rec.TASK_ID      :=             NULL;
              Q_REPLN_Rec.UNIT_NUMBER    :=           NULL;
              Q_REPLN_Rec.CONTRACT_LINE_ID    :=      NULL;
              Q_REPLN_Rec.AUTO_PROCESS_RMA   :=       NULL;
              Q_REPLN_Rec.REPAIR_MODE     :=          'WIP';
              Q_REPLN_Rec.OBJECT_VERSION_NUMBER   :=  NULL;
              Q_REPLN_Rec.ITEM_REVISION   :=          NULL;
              Q_REPLN_Rec.INSTANCE_ID     :=          NULL;
              Q_REPLN_Rec.STATUS        :=            'O';
              Q_REPLN_Rec.STATUS_REASON_CODE   :=     NULL;
              Q_REPLN_Rec.DATE_CLOSED     :=          NULL;
              Q_REPLN_Rec.APPROVAL_REQUIRED_FLAG  :=  'N';
              Q_REPLN_Rec.APPROVAL_STATUS     :=      NULL;
              Q_REPLN_Rec.SERIAL_NUMBER     :=        NULL;
              Q_REPLN_Rec.PROMISE_DATE      :=        NULL;
              Q_REPLN_Rec.ATTRIBUTE_CATEGORY  :=      NULL;
              Q_REPLN_Rec.ATTRIBUTE1            :=    NULL;
              Q_REPLN_Rec.ATTRIBUTE2    :=            NULL;
              Q_REPLN_Rec.ATTRIBUTE3      :=          NULL;
              Q_REPLN_Rec.ATTRIBUTE4        :=        NULL;
              Q_REPLN_Rec.ATTRIBUTE5          :=      NULL;
              Q_REPLN_Rec.ATTRIBUTE6            :=    NULL;
              Q_REPLN_Rec.ATTRIBUTE7   :=             NULL;
              Q_REPLN_Rec.ATTRIBUTE8     :=           NULL;
              Q_REPLN_Rec.ATTRIBUTE9       :=         NULL;
              Q_REPLN_Rec.ATTRIBUTE10        :=       NULL;
              Q_REPLN_Rec.ATTRIBUTE11          :=     NULL;
              Q_REPLN_Rec.ATTRIBUTE12            :=   NULL;
              Q_REPLN_Rec.ATTRIBUTE13  :=             NULL;
              Q_REPLN_Rec.ATTRIBUTE14    :=           NULL;
              Q_REPLN_Rec.ATTRIBUTE15      :=         NULL;
              Q_REPLN_Rec.QUANTITY           :=       l_ro_release.Quantity;
              Q_REPLN_Rec.QUANTITY_IN_WIP      :=     NULL;
              Q_REPLN_Rec.QUANTITY_RCVD          :=   NULL;
              Q_REPLN_Rec.QUANTITY_SHIPPED         := NULL;
              BEGIN
              select     lgr.currency_code
                  into l_currency_code
                  from
                        hr_organization_information hoi,
                        gl_ledgers lgr
                  where
                          hoi.organization_id = l_ro_release.Organization_id
                     AND (hoi.org_information_context || '') = 'Accounting Information'
                     AND to_number(decode(RTRIM(TRANSLATE(hoi.org_information1,   '0123456789',   ' ')),   NULL,   hoi.org_information1,   -99999)) = lgr.ledger_id
                     AND lgr.object_type_code = 'L'
                     AND nvl(lgr.complete_flag,   'Y') = 'Y';

              Q_REPLN_Rec.CURRENCY_CODE     :=   l_currency_code;
              LOG_MESSAGE('Currency Code'||l_currency_code);
              Exception
              when others then
               LOG_MESSAGE('Error while getting the default currecny for depot org');
               LOG_MESSAGE(SQLERRM);
               Q_REPLN_Rec.CURRENCY_CODE     :=   NULL;
              END;

             -- Q_REPLN_Rec.CURRENCY_CODE     :=        NULL;--'USD';
              Q_REPLN_Rec.DEFAULT_PO_NUM      :=      NULL;
              Q_REPLN_Rec.REPAIR_GROUP_ID       :=    NULL;
              Q_REPLN_Rec.RO_TXN_STATUS           :=  'OM_BOOKED';
              Q_REPLN_Rec.ORDER_LINE_ID    :=         NULL;
              Q_REPLN_Rec.ORIGINAL_SOURCE_REFERENCE := NULL;
              Q_REPLN_Rec.ORIGINAL_SOURCE_HEADER_ID := NULL;
              Q_REPLN_Rec.ORIGINAL_SOURCE_LINE_ID   := NULL;
             -- Q_REPLN_Rec.PRICE_LIST_HEADER_ID  :=    1000;
              Q_REPLN_Rec.SUPERCESSION_INV_ITEM_ID := NULL;
             -- Q_REPLN_Rec.FLOW_STATUS_ID     :=       1008;
              Q_REPLN_Rec.FLOW_STATUS_CODE     :=    NULL;
              Q_REPLN_Rec.FLOW_STATUS            :=   NULL;
              Q_REPLN_Rec.INVENTORY_ORG_ID      :=    l_ro_release.Organization_id; -- bug 7447541

              Q_REPLN_Rec.PROBLEM_DESCRIPTION  :=     NULL;
              Q_REPLN_Rec.RO_PRIORITY_CODE       :=   NULL;
               BEGIN
               LOG_MESSAGE('Inv org id.   :'||l_ro_release.Organization_id);
               LOG_MESSAGE('Calling API CSD_Repairs_PUB.Create_Repair_Order');

               CSD_Repairs_PUB.Create_Repair_Order(P_Api_Version_Number => 1.0,
                                                    P_Init_Msg_List     => FND_API.G_FALSE,
                                                    P_Commit            => FND_API.G_FALSE,
                                                    p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                                                    P_REPAIR_LINE_ID    => P_REPAIR_LINE_ID,
                                                    P_REPLN_Rec         => Q_REPLN_Rec,
                                                    p_create_default_logistics => p_create_default_logistics,
                                                    X_REPAIR_LINE_ID    =>  X_REPAIR_LINE_ID,
                                                    X_REPAIR_NUMBER     =>  X_REPAIR_NUMBER,
                                                    X_Return_Status     =>  X_Return_Status,
                                                    X_Msg_Count         =>  X_Msg_Count,
                                                    X_Msg_Data          =>  X_Msg_Data);
                  LOG_MESSAGE('Called API CSD_Repairs_PUB.Create_Repair_Order -'||X_Return_Status);
                  LOG_MESSAGE('Return Status.   :'||X_Return_Status);
                  LOG_MESSAGE('X_REPAIR_LINE_ID :'||X_REPAIR_LINE_ID);
                  LOG_MESSAGE('X_REPAIR_NUMBER  :'||X_REPAIR_NUMBER);

                  log_output('Repair Order Number:'||To_Char(X_REPAIR_NUMBER));

                            IF X_Return_Status <> 'S' THEN
                                  FOR i IN 1..X_msg_count
                                  LOOP
                            	       l_msg :=  fnd_msg_pub.get(p_msg_index => 1,
                                                            p_encoded => 'F' );
                                      LOG_MESSAGE('Error Message Data...'||X_Msg_Data||l_msg);
                                  END LOOP;
                            ELSE
                                  LOG_MESSAGE('CSD_Repairs_PUB.Create_Repair_Order Called...');
                                  LOG_MESSAGE('Return Status.   :'||X_Return_Status);
                                  LOG_MESSAGE('X_REPAIR_LINE_ID :'||X_REPAIR_LINE_ID);
                                  LOG_MESSAGE('X_REPAIR_NUMBER  :'||X_REPAIR_NUMBER);
                               --   COMMIT;
                                  BEGIN -- CAll to API TO Create a WIP JOb
                                  LOG_MESSAGE('-------------------------------------------------------------------');
                                  l_user_id := fnd_global.user_id();
                                  SELECT wip_job_schedule_interface_s.NEXTVAL
                                  INTO l_group_id FROM dual;

                                  Select To_Char(WIP_JOB_NUMBER_S.NEXTVAL)
                                  into  l_wip_job_name from dual;
                                  --l_group_id
                                    BEGIN
                                    -- INSERTING WIP JOB
                                    LOG_MESSAGE('Inserting into wip_job_schedule_interface');

                                    INSERT INTO wip_job_schedule_interface
                                      	(
                                      	last_update_date,
                                      	last_updated_by,
                                      	creation_date,
                                      	created_by,
                                      	load_type,
                                      	process_phase,
                                      	process_status,
                                      	group_id,
                                      	source_code,
                              	  	    source_line_id,
                                      	job_name,
                                      	organization_id,
                                      	status_type,
                                      	first_unit_start_date,
                                      	last_unit_completion_date,
                                      	start_quantity,
                                      	net_quantity,
                                      	class_code,
                                      	primary_item_id,
                                        interface_id
                                      	)
                                      	VALUES
                                       	(
                                        SYSDATE,
                                        l_user_id,
                                        SYSDATE,
                                        l_user_id,
                                        4,
                                        2,
                                        1,
                                        l_group_id,
                                        'MSC',
                                        X_REPAIR_LINE_ID,
                                      	l_wip_job_name,
                                        l_ro_release.Organization_id,
                                        3,
                                        SYSDATE,
                                        l_ro_release.Promise_date,
                                        l_ro_release.Quantity,
                                        l_ro_release.Quantity,
                                        'Rework',
                                        l_ro_release.Inventory_item_id,
                                        l_group_id
                                        );

                                        LOG_MESSAGE('Inserted into wip_job_schedule_interface group id '||to_char(l_group_id));

                                        LOG_MESSAGE('Calling API WIP_MASSLOAD_PUB.createOneJob');

                                        WIP_MASSLOAD_PUB.createOneJob( p_interfaceID => l_group_id,
                                                                       p_validationLevel => FND_API.G_VALID_LEVEL_FULL,
                                                                       x_wipEntityID => x_wipEntityID,
                                                                       x_returnStatus => x_return_status,
                                                                       x_errorMsg => x_msg_data );

                                        LOG_MESSAGE('Return Status.   :'||X_Return_Status);
                                        LOG_MESSAGE('x_wipEntityID    :'||x_wipEntityID);

                                        log_output('Wip Job:'||l_wip_job_name);

                                         IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                                            LOG_MESSAGE('Error Rep-work order creation : FND_API.G_RET_STS_UNEXP_ERROR');
                                     --       /* rollback ; */ commit;
                                            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                                          ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
                                            LOG_MESSAGE('Error in Rep-work order creation : FND_API.G_RET_STS_ERROR');
                                            rollback ;
                                            RAISE FND_API.G_EXC_ERROR;
                                          ELSIF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                                            LOG_MESSAGE('Successful in Creating Rep-work .');
                                            LOG_MESSAGE('wip etity id :' ||x_wipEntityID);
                                     --       commit ;
                                            LOG_MESSAGE('-------------------------------------------------------------------');
                                            LOG_MESSAGE('Calling API To Connect Wip job with the repair Order');

                                            BEGIN -- Code to call API to link WIp job To REpair ORder
                                                 csd_to_form_repair_job_xref.validate_and_write(
                                                                             p_api_version_number => 1.0,
                                                                             p_init_msg_list => FND_API.G_FALSE,
                                                                             p_commit => FND_API.G_FALSE,
                                                                             p_validation_level => NULL,
                                                                             p_action_code => 0,
                                                                             px_repair_job_xref_id => px_REPAIR_JOB_XREF_ID,
                                                                             p_created_by =>  l_user_id,
                                                                             p_creation_date => SYSDATE,
                                                                             p_last_updated_by => l_user_id,
                                                                             p_last_update_date => SYSDATE,
                                                                             p_last_update_login => l_user_id,
                                                                             p_repair_line_id => X_REPAIR_LINE_ID, --10960,
                                                                             p_wip_entity_id => x_wipEntityID, --760063,
                                                                             p_group_id => l_group_id,  --required
                                                                             p_organization_id => l_ro_release.Organization_id,
                                                                             p_quantity => l_ro_release.Quantity,
                                                                             p_INVENTORY_ITEM_ID => l_ro_release.Inventory_item_id,
                                                                             p_ITEM_REVISION =>  null,
                                                                             p_OBJECT_VERSION_NUMBER => 1,
                                                                             p_attribute_category => NULL,
                                                                             p_attribute1 => NULL,
                                                                             p_attribute2 => NULL,
                                                                             p_attribute3 => NULL,
                                                                             p_attribute4 => NULL,
                                                                             p_attribute5 => NULL,
                                                                             p_attribute6 => NULL,
                                                                             p_attribute7 => NULL,
                                                                             p_attribute8 => NULL,
                                                                             p_attribute9 => NULL,
                                                                             p_attribute10 => NULL,
                                                                             p_attribute11 => NULL,
                                                                             p_attribute12 => NULL,
                                                                             p_attribute13 => NULL,
                                                                             p_attribute14 => NULL,
                                                                             p_attribute15 => NULL,
                                                                             p_quantity_completed => NULL,
                                                                             p_job_name  =>  l_wip_job_name,
                                                                             p_source_type_code  =>  'MANUAL',
                                                                             p_source_id1  =>  NULL,
                                                                             p_ro_service_code_id  =>  NULL,
                                                                             x_return_status => l_return_status,
                                                                             x_msg_count => X_Msg_Count,
                                                                             x_msg_data => X_Msg_Data);

                                                  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                                                               LOG_MESSAGE('Error Rep-work order updation  : FND_API.G_RET_STS_UNEXP_ERROR');
                                                               rollback ;
                                                               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                                                        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                                                               LOG_MESSAGE('Error in  Rep-work order updation : FND_API.G_RET_STS_ERROR');
                                                               rollback ;
                                                               RAISE FND_API.G_EXC_ERROR;
                                                        ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                                                               LOG_MESSAGE('Successful in updating Rep-work .');
                                                               LOG_MESSAGE('px_REPAIR_JOB_XREF_ID    :' ||px_REPAIR_JOB_XREF_ID);
                                                               commit ;
                                                  END IF;
                                                   LOG_MESSAGE('Ending....');
                                                   EXCEPTION
                                                      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                                                         LOG_MESSAGE('Error : FND_API.G_EXC_UNEXPECTED_ERROR');
                                                         LOG_MESSAGE(SQLERRM);
                                                      --   retcode := 1;
                                                      --   rollback  ;
                                                         LOG_MESSAGE('Transaction rolled back');
                                                         LOG_MESSAGE('----------------------------------------------------------');

                                                      WHEN FND_API.G_EXC_ERROR THEN
                                                         LOG_MESSAGE('Error  : FND_API.G_EXC_ERROR');
                                                         LOG_MESSAGE(SQLERRM);
                                                      --   retcode := 1;
                                                      --    rollback ;
                                                         LOG_MESSAGE('Transaction rolled back');
                                                         LOG_MESSAGE('----------------------------------------------------------');
                                                      WHEN OTHERS THEN
                                                         LOG_MESSAGE('Error  : Err OTHERS');
                                                         LOG_MESSAGE(SQLERRM);
                                                      --   retcode := 1;
                                                       --   rollback ;
                                                         LOG_MESSAGE('Transaction rolled back');
                                                         LOG_MESSAGE('----------------------------------------------------------');

                                            END;
                                         END IF;
                                          LOG_MESSAGE('x_return_status :'||x_return_status);
                                          LOG_MESSAGE('Ending....');
                                         EXCEPTION
                                            WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                                               LOG_MESSAGE('Error : FND_API.G_EXC_UNEXPECTED_ERROR');
                                               LOG_MESSAGE(SQLERRM);
                                               -- retcode := 1;
                                               -- rollback ;
                                               LOG_MESSAGE('Transaction rolled back');
                                               LOG_MESSAGE('----------------------------------------------------------');

                                            WHEN FND_API.G_EXC_ERROR THEN
                                               LOG_MESSAGE('Error : FND_API.G_EXC_ERROR');
                                               LOG_MESSAGE(SQLERRM);
                                               -- retcode := 1;
                                               -- rollback ;
                                               LOG_MESSAGE('Transaction rolled back');
                                               LOG_MESSAGE('----------------------------------------------------------');
                                            WHEN OTHERS THEN
                                               LOG_MESSAGE('Error : Err OTHERS');
                                               LOG_MESSAGE(SQLERRM);
                                               -- retcode := 1;
                                               -- rollback ;
                                               LOG_MESSAGE('Transaction rolled back');
                                               LOG_MESSAGE('----------------------------------------------------------');
                                    END;

                                  END;
                            END IF;

                  END; -- BEGIN Block of repair order API

           END IF; -- outer block of incident


          END;

        end if ;
    END;
    END loop;

    --======================================================

    For  l_ro_release in ro_release_data(p_batch_id) loop
       BEGIN

              Savepoint Before_MOVE_IN ;

        Update  mrp_org_transfer_release
         set part_condition ='B'
         where transaction_id= l_ro_release.In_req_transaction_id;


        mrp_create_schedule_iso.Create_IR_ISO(errbuf,retcode ,l_req_header_id,l_iso_header_id, l_ro_release.In_req_transaction_id, l_ro_release.batch_id );
        l_iso_header_id1 := l_iso_header_id;
        l_req_header_id1:= l_req_header_id ;

        if  (retcode=0  ) then
            Update  mrp_org_transfer_release
             set part_condition ='G'
             where transaction_id= l_ro_release.out_req_transaction_id;

          	 mrp_create_schedule_iso.Create_IR_ISO(errbuf,retcode ,l_req_header_id,l_iso_header_id, l_ro_release.out_req_transaction_id, l_ro_release.batch_id );
            l_iso_header_id2 := l_iso_header_id;
            l_req_header_id2:= l_req_header_id ;

        end if ;

        if (retcode=0 ) then
	                 CSD_Refurbish_IRO_GRP.Create_InternalRO
                                          ( 1.0,
                                          FND_API.G_FALSE,
                                           FND_API.G_FALSE,
                                           FND_API.G_VALID_LEVEL_FULL,
                                          x_return_status ,
                                          p_msg_count	,
                                          x_msg_data	,
                                          l_req_header_id1,
                                          l_iso_header_id1,
                                          l_req_header_id2,
                                          l_iso_header_id2,
                                          x_service_request_number);

                    IF p_msg_count IS NOT NULL THEN
                        IF p_msg_count = 1 THEN
                          l_msg :=  fnd_msg_pub.get(p_msg_index => 1,
                                                     p_encoded => 'F' );
                          log_message(l_msg);
                        ELSIF p_msg_count > 1 THEN
                              FOR i IN 1..p_msg_count
                              LOOP
                                  l_msg := fnd_msg_pub.get(p_msg_index => i,
                                                          p_encoded => 'F' );
                              Fnd_file.put_line(fnd_file.LOG,l_msg);
                              END LOOP;
                      END IF;

                    END IF;

                    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                        LOG_MESSAGE('Error in Repair order creation  : FND_API.G_RET_STS_UNEXP_ERROR');
                        rollback ;
                         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
                      LOG_MESSAGE('Error in  Repair order creation : FND_API.G_RET_STS_ERROR');
                          rollback ;
                      RAISE FND_API.G_EXC_ERROR;
                   ELSIF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                      log_message('Successful in Creating Repair Req .');
                      log_message('service request number     :' ||x_service_request_number);
                      log_output('Successful in Creating Repair Req .');
                      log_output('service request number     :' ||x_service_request_number);
                       commit ;
                  END IF;

        end if ;

        if (l_ro_release.in_req_quantity <> l_ro_release.quantity and retcode =0 ) then
             select repair_line_id into lv_repair_line_id
             from csd_product_transactions
             where action_type='MOVE_IN'
             and   REQ_HEADER_ID= l_req_header_id1;

            /* call to update iro */
            update_iro(errbuf=>errbuf,
                       retcode=>retcode,
                       p_repair_line_id=>lv_repair_line_id,
                       p_quantity=>l_ro_release.quantity,
                       p_promise_date=> l_ro_release.Promise_date) ;
            if retcode =0 then
              commit;
            end if ;
      end if ;

      if  retcode <> 0 Then
       rollback to savepoint Before_MOVE_IN;
       global_retcode := retcode;
      end if;

      EXCEPTION
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             LOG_MESSAGE('Error in Release_new_IRO : FND_API.G_EXC_UNEXPECTED_ERROR');
             LOG_MESSAGE(SQLERRM);
             retcode := 1;
             rollback  ;
             log_message('Transaction rolled back');
             log_message('----------------------------------------------------------');

          WHEN FND_API.G_EXC_ERROR THEN
             LOG_MESSAGE('Error in Release_new_IRO : FND_API.G_EXC_ERROR');
             LOG_MESSAGE(SQLERRM);
             retcode := 1;
              rollback ;
             log_message('Transaction rolled back');
             log_message('----------------------------------------------------------');
          WHEN OTHERS THEN
             LOG_MESSAGE('Error in Release_new_IRO : Err OTHERS');
             LOG_MESSAGE(SQLERRM);
             retcode := 1;
              rollback ;
              log_message('Transaction rolled back');
             log_message('----------------------------------------------------------');
      END ;

    END loop;
     retcode := global_retcode;

  	DELETE FROM MRP_IRO_RELEASE WHERE BATCH_ID=p_batch_id ;
    Commit;
	  DELETE FROm MRP_ORG_TRANSFER_RELEASE WHERE BATCH_ID=p_batch_id;
    Commit;
END Release_new_IRO;


END MSC_SRP_RELEASE;

/
