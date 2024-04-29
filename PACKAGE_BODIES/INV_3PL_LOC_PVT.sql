--------------------------------------------------------
--  DDL for Package Body INV_3PL_LOC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_3PL_LOC_PVT" 
/* $Header: INVVSSCB.pls 120.0.12010000.6 2010/02/27 17:11:24 damahaja noship $ */
AS
g_debug       NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);


PROCEDURE update_locator_capacity
  ( x_return_status             OUT NOCOPY VARCHAR2, -- return status (success/error/unexpected_error)
    x_msg_count                 OUT NOCOPY NUMBER,   -- number of messages in the message queue
    x_msg_data                  OUT NOCOPY VARCHAR2, -- message text when x_msg_count>0
    p_inventory_location_id     IN         NUMBER,   -- identifier of locator
    p_organization_id           IN         NUMBER,   -- org of locator whose capacity is to be determined
    p_client_code               IN         VARCHAR2,   -- identifier of item
    p_transaction_action_id     IN            NUMBER,   -- transaction action id for pack,unpack,issue,receive,transfer
    p_quantity                  IN         NUMBER,
    p_transaction_date          IN         DATE
  )
IS
    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(1000);
    l_old_record                mtl_3pl_locator_occupancy%ROWTYPE;
    l_Last_Receipt_Date    DATE;
    l_current_onhand NUMBER;
    l_locator_id NUMBER;
    l_transaction_date DATE;
    l_transaction_action NUMBER;
    l_transaction_quantity NUMBER;
    -- l_-- last_invoiced_date DATE;
    l_number_of_days NUMBER :=1;
    l_success   VARCHAR2(1);
    l_client_code VARCHAR2(10);
    l_organization_id NUMBER;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

            IF (g_debug = 1) THEN
            inv_trx_util_pub.TRACE('In update locator capcity ', 'update_current_capacity', 4);
            inv_trx_util_pub.TRACE('Locator ID' || p_inventory_location_id , 'update_current_capacity',4);
            inv_trx_util_pub.TRACE('Client Code ' || p_client_code, 'update_current_capacity', 4);
            END IF;

    BEGIN
          Select *
          INTO l_old_Record
          FROM mtl_3pl_locator_occupancy
          WHERE locator_id = p_inventory_location_id
          and organization_id = p_organization_id
          AND client_code = p_client_code;

           IF (g_debug = 1) THEN
          inv_trx_util_pub.TRACE('Locator Record Exists in Occupancy table', 'update_current_capacity', 4);
            END IF;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
     IF (g_debug = 1) THEN
    inv_trx_util_pub.TRACE('Locator Record Does not exist , creating a new record in Occupancy table', 'update_current_capacity', 4);
    END IF;

        inv_trx_util_pub.TRACE('p_transaction_date => ' ||p_transaction_date, 'update_current_capacity', 4);
        inv_trx_util_pub.TRACE('p_quantity => ' || p_quantity, 'update_current_capacity', 4);
        inv_trx_util_pub.TRACE('p_inventory_location_id => ' ||p_inventory_location_id, 'update_current_capacity', 4);
        inv_trx_util_pub.TRACE('p_transaction_date => ' ||p_transaction_date, 'update_current_capacity', 4);
        inv_trx_util_pub.TRACE('p_transaction_action_id => ' ||p_transaction_action_id, 'update_current_capacity', 4);
        inv_trx_util_pub.TRACE('p_organization_id => ' ||p_organization_id, 'update_current_capacity', 4);
        inv_trx_util_pub.TRACE('l_client_code => ' ||p_client_code, 'update_current_capacity', 4);

        l_success := insert_3pl_loc_occupancy(
                                  p_transaction_date ,
                                  p_quantity ,
                                  p_inventory_location_id ,
                                  p_transaction_date ,
                                  p_transaction_action_id ,
                                  p_quantity ,
                                  p_organization_id ,
                                  p_client_code,
                                  1
                                  );

        IF ( l_success <> fnd_api.g_ret_sts_success )
            THEN
           x_msg_data := SQLERRM;
        END IF;
      x_return_status := l_success;
      RETURN;
    END;

     IF (g_debug = 1) THEN
    inv_trx_util_pub.TRACE('Updating The current record ', 'update_current_capacity', 4);
    inv_trx_util_pub.TRACE('Transaction action ID' || p_transaction_action_id, 'update_current_capacity', 4);
    end if;

      IF ( p_quantity > 0 and l_old_Record.locator_id is not null ) --AND NOT(l_old_Record.Current_Onhand + p_quantity < 0) )
          THEN
        IF (g_debug = 1) THEN
                      inv_trx_util_pub.TRACE('Just before adding days .... :', 'update_current_capacity', 4);
                      inv_trx_util_pub.TRACE('Transaction_date :' || p_transaction_date , 'update_current_capacity', 4);
                      inv_trx_util_pub.TRACE('l_old_Record.Last_Receipt_Date :' || l_old_Record.Last_Receipt_Date , 'update_current_capacity', 4);
                      inv_trx_util_pub.TRACE('l_number_of_days :' || l_number_of_days , 'update_current_capacity', 4);
                      end if;

           IF ( to_date(l_old_Record.last_invoiced_date,'dd/mm/yyyy') <> to_date(p_transaction_date,'dd/mm/yyyy') ) -- Here the transaction date is same as the creation date
             THEN
              IF  l_old_Record.Current_Onhand = 0 Then
                  l_number_of_days := l_number_of_days + 1;

              ELSIF  ( p_transaction_date >= l_old_Record.Last_Receipt_Date AND l_old_Record.Current_Onhand  > 0 )
                  THEN
                 IF (g_debug = 1) THEN
                inv_trx_util_pub.TRACE('Inside 2nd if' || l_number_of_days , 'update_current_capacity', 4);
                end if;
                l_number_of_days := l_old_Record.number_of_days + to_number(to_date(p_transaction_date,'dd/mm/yyyy') - to_date(l_old_Record.Last_Receipt_Date,'dd/mm/yyyy'));
              END IF;
           ELSE
                l_number_of_days := l_old_record.number_of_days;
           END IF;

           IF (g_debug = 1) THEN
          inv_trx_util_pub.TRACE('New number of days' || l_number_of_days , 'update_current_capacity', 4);
          END IF;

          l_Last_Receipt_Date := p_transaction_date ;
          l_current_onhand := NVL(l_old_record.current_onhand,0) + p_quantity;
          l_locator_id := p_inventory_location_id;
          l_transaction_date := p_transaction_date;
          l_transaction_action := p_transaction_action_id;
          l_transaction_quantity := p_quantity;
          l_organization_id := p_organization_id;
          l_client_code := p_client_code;
          -- l_-- last_invoiced_date := NULL;

          IF (g_debug = 1) THEN
          inv_trx_util_pub.TRACE(' Calling update_3pl_loc_occupancy ', 'update_current_capacity', 4);
          END IF;

          l_success := update_3pl_loc_occupancy(
                                      l_Last_Receipt_Date ,
                                      l_current_onhand ,
                                      l_locator_id ,
                                      l_transaction_date ,
                                      l_transaction_action ,
                                      l_transaction_quantity ,
                                      l_organization_id,
                                      l_client_code ,
                                      l_number_of_days
                                      );

          ELSIF ( p_quantity < 0 and l_old_Record.locator_id is not null )
           THEN
             IF (g_debug = 1) THEN
                inv_trx_util_pub.TRACE('For issue transactions', 'update_current_capacity', 4);
                inv_trx_util_pub.TRACE('Just before adding days .... :', 'update_current_capacity', 4);
                inv_trx_util_pub.TRACE('p_transaction_date :' || p_transaction_date , 'update_current_capacity', 4);
                inv_trx_util_pub.TRACE('l_old_Record.Last_Receipt_Date :' || l_old_Record.Last_Receipt_Date , 'update_current_capacity', 4);
                inv_trx_util_pub.TRACE('l_number_of_days :' || l_number_of_days , 'update_current_capacity', 4);
                inv_trx_util_pub.TRACE('p_quantity :' || p_quantity , 'update_current_capacity', 4);
            END IF;

             IF ( to_date(l_old_Record.last_invoiced_date,'dd/mm/yyyy') <> to_date(p_transaction_date,'dd/mm/yyyy') ) -- Here the transaction date is same as the creation date
                THEN
                  IF ( l_old_Record.Current_Onhand + p_quantity = 0 ) Then
                      l_number_of_days := NVL(l_old_record.number_of_days,0) + to_number(p_transaction_date - l_old_Record.last_receipt_date );--MAX(l_old_Record.last_receipt_date,l_old_record.Last_invoice_date) );
                  ELSE
                      l_number_of_days := NVL(l_old_record.number_of_days,0);
                  END IF;
             ELSE
                      l_number_of_days := NVL(l_old_record.number_of_days,0);
             END IF;

                  l_Last_Receipt_Date := l_old_record.Last_Receipt_Date ;
                  l_current_onhand := NVL(l_old_record.current_onhand,0) + p_quantity;
                  l_locator_id := p_inventory_location_id;
                  l_transaction_date := p_transaction_date;
                  l_transaction_action := p_transaction_action_id;
                  l_transaction_quantity := p_quantity;
                  l_organization_id := p_organization_id;
                  l_client_code := p_client_code;

                  IF (g_debug = 1) THEN
                  inv_trx_util_pub.TRACE('Before calling update_3pl_loc_occupancy ', 'update_current_capacity', 4);
                  END IF;

                  l_success := update_3pl_loc_occupancy(
                                              l_Last_Receipt_Date ,
                                              l_current_onhand ,
                                              l_locator_id ,
                                              l_transaction_date ,
                                              l_transaction_action ,
                                              l_transaction_quantity ,
                                              l_organization_id,
                                              l_client_code,
                                              l_number_of_days
                                              );

            IF ( l_success <> fnd_api.g_ret_sts_success )
                THEN
           x_msg_data := SQLERRM;
            END IF;
          x_return_status := l_success;
          RETURN;
       END IF;

    EXCEPTION
    WHEN OTHERS THEN
        IF (g_debug = 1) THEN
            inv_trx_util_pub.TRACE(' Exception in update_locator_capacity =>  '||sqlerrm, 'update_current_capacity', 4);
        END IF;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
  END update_locator_capacity;

Function update_3pl_loc_occupancy (
                                l_Last_Receipt_Date date,
                                l_current_onhand NUMBER ,
                                l_locator_id NUMBER ,
                                l_transaction_date DATE ,
                                l_transaction_action NUMBER ,
                                l_transaction_quantity NUMBER  ,
                                l_organization_id NUMBER,
                                l_client_code VARCHAR2 ,
                                l_number_of_days  number
                                ) RETURN VARCHAR2
IS

cursor c is select client_code , locator_id , organization_id
              FROM mtl_3pl_locator_occupancy
              WHERE client_code = l_client_code
              AND locator_id = l_locator_id
              and organization_id = l_organization_id
              FOR UPDATE nowait;

 BEGIN

  IF (g_debug = 1) THEN
  inv_trx_util_pub.TRACE('In update_3pl_loc_occupancy ', 'update_current_capacity', 4);
  END IF;

  FOR recinfo IN c
     LOOP
      IF (g_debug = 1) THEN
     inv_trx_util_pub.TRACE('recinfo.locator_id ' || recinfo.locator_id , 'update_current_capacity', 4);
     inv_trx_util_pub.TRACE('recinfo.client_code ' || recinfo.client_code , 'update_current_capacity', 4);
     END IF;

      Update mtl_3pl_locator_occupancy
      set Last_Receipt_Date  =  l_Last_Receipt_Date,
          current_onhand     = l_current_onhand ,
          transaction_date   = l_transaction_date ,
          transaction_action_id  =  l_transaction_action ,
          transaction_quantity   = l_transaction_quantity ,
          number_of_days     = l_number_of_days
      where locator_id = recinfo.locator_id
      and client_code = recinfo.client_code
      and organization_id = recinfo.organization_id;
     END LOOP;

    RETURN  FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
    WHEN OTHERS THEN
        IF (g_debug = 1) THEN
            inv_trx_util_pub.TRACE(' Exception in update_3pl_loc_occupancy =>  '||sqlerrm, 'update_current_capacity', 4);
        END IF;

     RETURN FND_API.G_RET_STS_ERROR;
    END update_3pl_loc_occupancy;

Function insert_3pl_loc_occupancy (
                                l_Last_Receipt_Date date,
                                l_current_onhand NUMBER ,
                                l_locator_id NUMBER ,
                                l_transaction_date DATE ,
                                l_transaction_action NUMBER ,
                                l_transaction_quantity NUMBER  ,
                                l_organization_id NUMBER,
                                l_client_code VARCHAR2 ,
                                l_number_of_days  number
                                ) RETURN VARCHAR2
IS
 BEGIN

   IF (g_debug = 1) THEN
  inv_trx_util_pub.TRACE('IN insert_3pl_loc_occupancy ','update_current_capacity', 4);
  inv_trx_util_pub.TRACE('l_locator_id ' || l_locator_id,'update_current_capacity', 4);
  inv_trx_util_pub.TRACE('IN l_client_code ' || l_client_code ,'update_current_capacity', 4);
   END IF;

      INSERT INTO  mtl_3pl_locator_occupancy
            ( Last_Receipt_Date,
              current_onhand    ,
              transaction_date    ,
              transaction_action_id   ,
              transaction_quantity               ,
              last_invoiced_date   ,
              number_of_days         ,
              locator_id,
              organization_id ,
              client_code
               )
          VALUES
          (  l_Last_Receipt_Date,
             l_current_onhand ,
             l_transaction_date ,
             l_transaction_action ,
             l_transaction_quantity ,
             NULL  ,
             l_number_of_days   ,
             l_locator_id,
             l_organization_id ,
             l_client_code
          );

    RETURN  FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
        WHEN OTHERS THEN
            IF (g_debug = 1) THEN
                inv_trx_util_pub.TRACE(' Exception in insert_3pl_loc_occupancy =>  '||sqlerrm, 'update_current_capacity', 4);
            END IF;
        RETURN FND_API.G_RET_STS_ERROR;
    END insert_3pl_loc_occupancy;

END INV_3PL_LOC_PVT;

/
