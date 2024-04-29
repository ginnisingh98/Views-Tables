--------------------------------------------------------
--  DDL for Package Body MTL_BILLING_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_BILLING_LINES_PKG" AS
/* $Header: INVBLINB.pls 120.0.12010000.3 2010/01/19 13:00:48 damahaja noship $ */

  procedure INSERT_ROW(
       x_billing_rule_line_id IN NUMBER ,
       x_billing_rule_header_id IN NUMBER ,
       x_client_code IN VARCHAR2 ,
       x_client_number IN VARCHAR2 ,
       x_service_agreement_line_id IN NUMBER ,
       x_inventory_item_id IN NUMBER ,
       x_billing_source_id IN NUMBER ,
       x_creation_date IN DATE ,
       x_created_by IN NUMBER,
       x_last_update_date IN DATE,
       x_last_updated_by IN NUMBER ,
       x_last_update_login IN NUMBER
  ) AS

  BEGIN

         INSERT INTO mtl_billing_rule_lines
          (   billing_rule_line_id,
              billing_rule_header_id ,
              client_code ,
              client_number  ,
              service_agreement_line_id ,
              inventory_item_id,
              billing_source_id ,
              creation_date ,
              created_by ,
              last_update_date ,
              last_updated_by ,
              last_update_login
          )
          VALUES
          (  x_billing_rule_line_id,
              x_billing_rule_header_id ,
              x_client_code ,
              x_client_number  ,
              x_service_agreement_line_id ,
              x_inventory_item_id ,
              x_billing_source_id ,
              x_last_update_date , -- x_creation_date ,
              x_last_updated_by ,--x_created_by ,
              x_last_update_date ,
              x_last_updated_by ,
              x_last_update_login
          );


        -- commit;
  END INSERT_ROW;

procedure UPDATE_ROW(
       x_billing_rule_line_id IN NUMBER ,
       x_billing_rule_header_id IN NUMBER ,
       x_client_code IN VARCHAR2 ,
       x_client_number IN VARCHAR2 ,
       x_service_agreement_line_id IN NUMBER ,
       x_inventory_item_id IN NUMBER ,
       x_billing_source_id IN NUMBER ,
       x_creation_date IN DATE ,
       x_created_by IN NUMBER,
       x_last_update_date IN DATE,
       x_last_updated_by IN NUMBER ,
       x_last_update_login IN NUMBER

  ) AS

  l_billing_rule_line_id NUMBER;

 BEGIN

  IF x_billing_rule_line_id IS NULL
    THEN


       INSERT INTO mtl_billing_rule_lines
          (   billing_rule_line_id,
              billing_rule_header_id ,
              client_code ,
              client_number  ,
              service_agreement_line_id ,
              inventory_item_id,
              billing_source_id ,
              creation_date ,
              created_by ,
              last_update_date ,
              last_updated_by ,
              last_update_login
          )
          VALUES
          (   x_billing_rule_line_id,
              x_billing_rule_header_id ,
              x_client_code ,
              x_client_number  ,
              x_service_agreement_line_id ,
              x_inventory_item_id,
              x_billing_source_id,
              x_last_update_date, -- x_creation_date ,
              x_last_updated_by, --x_created_by ,
              x_last_update_date ,
              x_last_updated_by ,
              x_last_update_login
          );


          RETURN;

   ELSE

  update mtl_billing_rule_lines set
             billing_rule_header_id = x_billing_rule_header_id,
             client_code = x_client_code,
             client_number = x_client_number,
             service_agreement_line_id = x_service_agreement_line_id,
             billing_source_id = x_billing_source_id,
             last_update_date = x_last_update_date,
             last_updated_by = x_last_updated_by,
             last_update_login = x_last_update_login
    where billing_rule_line_id = x_billing_rule_line_id;

      if (sql%notfound) then
          raise no_data_found;
      end IF;

    END IF;
END UPDATE_ROW;


procedure DELETE_ROW (
  x_billing_rule_line_id in NUMBER
) is
BEGIN

  delete from mtl_billing_rule_lines
  where billing_rule_line_id = x_billing_rule_line_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;


procedure LOCK_ROW (
       x_billing_rule_line_id IN NUMBER ,
       x_billing_rule_header_id IN NUMBER ,
       x_client_code IN VARCHAR2 ,
       x_client_number IN VARCHAR2 ,
       x_service_agreement_line_id IN NUMBER ,
       x_inventory_item_id IN NUMBER ,
       x_billing_source_id IN NUMBER ,
       x_creation_date IN DATE ,
       x_created_by IN NUMBER,
       x_last_update_date IN DATE,
       x_last_updated_by IN NUMBER ,
       x_last_update_login IN NUMBER
  ) AS

   l_billing_rule_line_id NUMBER;

  cursor c is SELECT
              billing_rule_line_id,
              billing_rule_header_id ,
              client_code ,
              client_number  ,
              service_agreement_line_id ,
              inventory_item_id,
              billing_source_id  ,
              creation_date ,
              created_by ,
              last_update_date ,
              last_updated_by ,
              last_update_login
    from mtl_billing_rule_lines
    where billing_rule_line_id = x_billing_rule_line_id
    for update of billing_rule_line_id nowait;

  recinfo c%rowtype;

BEGIN

  IF x_billing_rule_line_id IS NULL
    THEN
    NULL;
  ELSE
      open c;
      fetch c into recinfo;
      if (c%notfound) then
        close c;
        fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
        app_exception.raise_exception;
      end if;
      close c;
      if (
          (recinfo.billing_rule_line_id = x_billing_rule_line_id)
          AND (recinfo.service_agreement_line_id = X_service_agreement_line_id)
         )
          then
        null;
        else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
        end if;
  END IF;

return;
end LOCK_ROW;

END;

/
