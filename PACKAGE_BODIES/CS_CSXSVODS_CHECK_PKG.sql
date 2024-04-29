--------------------------------------------------------
--  DDL for Package Body CS_CSXSVODS_CHECK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CSXSVODS_CHECK_PKG" AS
/*$Header: cssvcceb.pls 115.3 99/07/16 09:02:30 porting ship  $*/

PROCEDURE Service_Check_Overlap (p_overlap_flag IN OUT VARCHAR2,
                                                   p_inventory_item_id NUMBER,
                                                   p_manu_org_id  NUMBER,
					           p_customer_product_id NUMBER,
                                                   p_start_date   DATE,
                                                   p_end_date     DATE) IS
  CURSOR check_overlap IS
  select 'Y'
  from cs_cp_services
  where service_inventory_item_id+0 = p_inventory_item_id
    And service_manufacturing_org_id= p_manu_org_id
    And customer_product_id = p_customer_product_id
    And start_date_active <> end_date_active
    and (  (p_start_date <= end_date_active
        and start_date_active <= p_start_date)
    OR (start_date_active <= p_end_date
        and p_start_date <= start_date_active)
    OR (start_date_active >= p_start_date
        and end_date_active <= p_end_date)
    OR (start_date_active <= p_start_date
        and end_date_active >= p_end_date));
BEGIN
   OPEN check_overlap;

   FETCH check_overlap
   INTO  p_overlap_flag;

   IF check_overlap%NOTFOUND THEN
     p_overlap_flag  := 'N';
   END IF;

   CLOSE check_overlap;
END Service_Check_Overlap;



/* Procedure to check whether the current service is being processed in Order Entry */

PROCEDURE service_check_duplicate(p_duplicate_flag IN OUT VARCHAR2,
                                  p_inventory_item_id NUMBER,
                                  p_customer_product_id NUMBER) IS

 CURSOR check_duplicate IS
 select 'Y'
 from so_lines_interface
 where inventory_item_id+0 = p_inventory_item_id
 AND   customer_product_id = p_customer_product_id;

 BEGIN
 OPEN check_duplicate;

 FETCH check_duplicate into p_duplicate_flag;

 IF check_duplicate%NOTFOUND THEN
  p_duplicate_flag := 'N';
 END IF;

 CLOSE check_duplicate;
END Service_Check_Duplicate;


PROCEDURE service_check_duplicate_soline(p_duplicate_flag IN OUT VARCHAR2,
                                  p_inventory_item_id NUMBER,
                                  p_customer_product_id NUMBER) IS


 CURSOR check_duplicate IS
 select 'Y'
 from so_lines  sol,
 so_headers soh
 where inventory_item_id+0 = p_inventory_item_id
 AND   customer_product_id = p_customer_product_id
 AND  nvl(soh.cancelled_flag,'N') = 'N'
 AND  nvl(sol.open_flag,'N') = 'Y';
 BEGIN
 OPEN check_duplicate;

 FETCH check_duplicate into p_duplicate_flag;

 IF check_duplicate%NOTFOUND THEN
  p_duplicate_flag := 'N';
 END IF;

 CLOSE check_duplicate;
END Service_Check_duplicate_soline;




/** This procedure is used to check whether or not a customer is
    eligible for service. This is used in the form Order Service,
    CSXSVODS and in renew service.
    **/

PROCEDURE CS_Check_Service_ELigibility (
                            p_cp_eligibility  IN OUT VARCHAR2,
                            p_ord_serv_inv_item_id	IN NUMBER,
                            p_control_manu_org_id	IN NUMBER,
                            p_cp_inventory_item_id	IN NUMBER,
                            p_cp_customer_id	IN NUMBER,
                            p_cp_revision	IN VARCHAR2,
                            p_order_reneW_date		IN DATE) IS
/* Cursor 1 : Check if a record is defined at all in the service availability
		    setup form*/
CURSOR  service_available  IS
SELECT 'x'
FROM cs_service_availability serv
WHERE  serv.service_inventory_item_id = p_ord_serv_inv_item_id
  AND  serv.service_manufacturing_org_id = p_control_manu_org_id ;

/* Cursor 2 : Check if a record is defined for service availability */
CURSOR  check_available IS
SELECT 'x'
FROM   cs_service_availability avail
WHERE  avail.service_inventory_item_id  = p_ord_serv_inv_item_id
AND  avail.service_manufacturing_org_id = p_control_manu_org_id
AND  NVL(avail.inventory_item_id, p_Cp_inventory_item_id)
                                        = p_cp_inventory_item_id
AND  NVL(avail.customer_id, p_cp_customer_id)
                                       = p_cp_customer_id
AND  (NVL(p_cp_revision,'-999')
         BETWEEN NVL(avail.revision_low, NVL(p_cp_revision,'-999'))
                  AND NVL(avail.revision_high, NVL(p_cp_revision,'-999')))
AND  (p_order_renew_date
          BETWEEN NVL(avail.start_date_active, p_order_renew_date)
                   AND NVL(avail.end_date_active, p_order_renew_date))
AND  avail.service_available_flag = 'Y';

 /* Cursor 3 : Check if a record is defined for service restricted */
CURSOR  check_restricted IS
SELECT 'x'
FROM   cs_service_availability avail
WHERE  avail.service_inventory_item_id    = p_ord_serv_inv_item_id
AND  avail.service_manufacturing_org_id   = p_control_manu_org_id
AND  NVL(avail.inventory_item_id, p_cp_inventory_item_id)
                                          = p_cp_inventory_item_id
 AND  NVL(avail.customer_id, p_cp_customer_id)
                                          = p_cp_customer_id
 AND  (NVL(p_cp_revision,'-999')
          BETWEEN NVL(avail.revision_low, NVL(p_cp_revision,'-999'))
                  AND NVL(avail.revision_high, NVL(p_cp_revision,'-999')))
 AND  (p_order_renew_date
          BETWEEN NVL(avail.start_date_active, p_order_renew_date)
                   AND NVL(avail.end_date_active, p_order_renew_date))
 AND  avail.service_available_flag = 'N';

/* Cursor 4 : Check if any record is defined for service restricted */
CURSOR  check_any_restricted IS
SELECT 'x'
FROM   cs_service_availability avail
WHERE  avail.service_inventory_item_id   = p_ord_serv_inv_item_id
AND  avail.service_manufacturing_org_id  = p_control_manu_org_id
AND  avail.service_available_flag = 'N';

/* Cursor 5 : Check if any record is defined for service available */
CURSOR  check_any_available IS
SELECT 'x'
FROM   cs_service_availability avail
WHERE  avail.service_inventory_item_id    = p_ord_serv_inv_item_id
AND  avail.service_manufacturing_org_id   = p_control_manu_org_id
AND  avail.service_available_flag = 'Y';

/* Cursor 6 : Check if a record is defined for service restricted for
                        the same customer/product/revision (no date check) */
CURSOR  check_same_restricted IS
SELECT 'x'
FROM   cs_service_availability avail
WHERE  avail.service_inventory_item_id   = p_ord_serv_inv_item_id
AND  avail.service_manufacturing_org_id  = p_control_manu_org_id
AND  NVL(avail.inventory_item_id, p_cp_inventory_item_id)
                                         = p_cp_inventory_item_id
 AND  NVL(avail.customer_id, p_cp_customer_id)
                                         = p_cp_customer_id
 AND  (NVL(p_cp_revision,'-999')
          BETWEEN NVL(avail.revision_low, NVL(p_cp_revision,'-999'))
                  AND NVL(avail.revision_high, NVL(p_cp_revision,'-999')))
AND  avail.service_available_flag = 'N';


/* Cursor 6 : Check if a record is defined for service available for
                        the same customer/product/revision (no date check)  */
CURSOR  check_same_available IS
SELECT 'x'
FROM   cs_service_availability avail
WHERE  avail.service_inventory_item_id   = p_ord_serv_inv_item_id
AND  avail.service_manufacturing_org_id  = p_control_manu_org_id
AND  NVL(avail.inventory_item_id, p_cp_inventory_item_id)
                                         = p_cp_inventory_item_id
 AND  NVL(avail.customer_id, p_cp_customer_id)
                                         = p_cp_customer_id
 AND  (NVL(p_cp_revision,'-999')
          BETWEEN NVL(avail.revision_low, NVL(p_cp_revision,'-999'))
                  AND NVL(avail.revision_high, NVL(p_cp_revision,'-999')))
AND  avail.service_available_flag = 'Y';


BEGIN

OPEN  service_available;
FETCH service_available
INTO p_cp_eligibility;
IF service_available%NOTFOUND THEN
p_cp_eligibility := 'Y';
CLOSE  service_available;
ELSE
 CLOSE  service_available;
OPEN check_restricted;
FETCH  check_restricted
INTO p_cp_eligibility;
IF check_restricted%FOUND THEN
 p_cp_eligibility := 'N';
CLOSE  check_restricted;
ELSE
CLOSE  check_restricted;
OPEN check_available;
FETCH  check_available
 INTO p_cp_eligibility;
IF check_available%FOUND THEN
p_cp_eligibility := 'Y';
CLOSE  check_available;
ELSE
 CLOSE  check_available;
OPEN check_any_restricted ;
FETCH check_any_restricted
   INTO p_cp_eligibility;
IF check_any_restricted%NOTFOUND THEN
   p_cp_eligibility := 'N';
   CLOSE check_any_restricted;
ELSE
   CLOSE check_any_restricted;
   OPEN check_any_available;
   FETCH check_any_available
      INTO p_cp_eligibility;
   IF check_any_available%NOTFOUND THEN
       p_cp_eligibility := 'N';
       CLOSE check_any_available;
    ELSE
       CLOSE check_any_available;
       OPEN check_same_restricted;
       FETCH check_same_restricted
          INTO p_cp_eligibility;
       IF check_same_restricted%NOTFOUND THEN
          p_cp_eligibility := 'N';
          CLOSE check_same_restricted;
       ELSE
          CLOSE check_same_restricted;
          OPEN check_same_available;
          FETCH check_same_available
             INTO p_cp_eligibility;
          IF check_same_available%NOTFOUND THEN
              p_cp_eligibility := 'Y';
          ELSE
              p_cp_eligibility := 'N';
           END IF; /* End check same avai. */
           CLOSE check_same_available;
    END IF; /* End check same restr. */
END IF; /* End check any avail. */
END IF; /* End check any restr. */
END IF; /* End check avail */
 END IF ; /* End check restr. */
END IF;
END CS_Check_Service_Eligibility;


/*********************************************************************
    This procedure checks to see whether or not the combination of
    service, price list and uom code exist in SO_PRICE_LIST_LINES.
    If the combination does not exist, the client displays a warning.
    It is called from the header block (orders) of Order Service and
    from the lines block (CP) for each line selected of Renew Service.
**********************************************************************/

PROCEDURE Check_Price_List(check_value IN OUT VARCHAR2,
			            p_price_list_id       IN NUMBER,
                           service_inv_item_id IN NUMBER,
                           uom_code            IN VARCHAR2) IS

CURSOR  get_price_list  IS
	  SELECT 'Y'
	  FROM	 so_price_list_lines SOPL
       WHERE  SOPL.price_list_id = p_price_list_id
       AND  SOPL.inventory_item_id = service_inv_item_id
       AND  SOPL.unit_code = uom_code ;
BEGIN

  OPEN get_price_list ;
  FETCH get_price_list
   INTO check_value ;
  CLOSE get_price_list ;


  EXCEPTION
	WHEN NO_DATA_FOUND THEN
		Check_value := 'N';
	WHEN OTHERS THEN
		Check_value := 'N';

END Check_Price_List;

/*********************************************************************
    This procedure calculates the service duration of a new service or
    renewed service in terms of the uom code specified. The service
    duration is first calculated in terms of the number of days (as
    per the day_uom_code) by taking the diff. between the start and end
    dates. Thereafter, the number of days is converted to the specified
    unit. If the value of the duration gets rounded in the conversion
    process (e.g. 11 hours gets rounded to 24 hours), the rounded flag
    is set so that the client can display a warning message.
**********************************************************************/


PROCEDURE Calculate_Service_duration (Service_duration   IN OUT NUMBER,
                                      Service_Start_Date IN DATE,
                                      Service_End_Date   IN DATE,
                                      Inventory_Item_ID  IN NUMBER,
                                      Period_Code        IN VARCHAR2,
                                      Day_UOM_Code       IN VARCHAR2 ,
                                      Rounded_Flag       IN OUT VARCHAR2,
			              Order_Duration     IN NUMBER) IS
   Duration_Days NUMBER;
 BEGIN
    /* If the duration quantity is not a whole number, round it off
       to the nearest whole number */
    IF (Service_End_Date IS NOT NULL) AND
       (Service_Start_Date IS NOT NULL) AND
       (Order_Duration IS NULL) THEN

        SELECT DECODE((TO_NUMBER(TO_DATE(Service_End_Date,'DD-MON-RR')
                           - TO_DATE(Service_Start_Date,'DD-MON-RR'))
                             ) ,0,1,
                    (TO_NUMBER(TO_DATE(Service_End_Date,'DD-MON-RR')
                           - TO_DATE(Service_Start_Date,'DD-MON-RR')))
               )
      INTO Duration_Days
      FROM sys.dual;
      Service_duration := inv_convert.inv_um_convert(inventory_item_id,
                                      8,
                from_quantity => Duration_Days,
                from_unit     => day_uom_code,
                to_unit       => period_code,
                from_name     => '',
                to_name       => '');

    ELSE
 /* First convert the duration to days - day_uom_code - only if the
    specified unit is not day_uom_code */
      Duration_Days := Order_Duration ;


      IF (period_code <> day_uom_code) THEN
        Service_duration := inv_convert.inv_um_convert(inventory_item_id,
                                      8,
                          from_quantity => Duration_Days,
                          from_unit     => period_codE,
                          to_unit       => day_uom_code,
                          from_name     => '',
                          to_name       => '');


        /* Now convert the day duration to the uom specified */
        IF (Service_Duration < 1) THEN
          Duration_Days := 1 ;
        ELSE
          Duration_Days := service_Duration ;
        END IF;
        Service_duration := inv_convert.inv_um_convert(inventory_item_id,
                                      8,
                from_quantity => Duration_Days,
                from_unit     => day_uom_code,
                to_unit       => period_code,
                from_name     => '',
                to_name       => '');
      ELSE
        Service_duration := Order_duration;
      END IF;
    END IF;

    /* If the diff. between start date and end date is not a whole
       number, set the rounded flag so that the user can receive a
       warning. Also, if the start and end dates are the same,
       set the rounded flag to give the user a warning. */

    IF (Order_Duration <> Service_Duration) AND
	  (day_uom_code <> period_code) THEN
      rounded_flag := 'Y';
    END IF;
    --DBMS_OUTPUT.PUT_LINE('FLAG   : ' || rounded_flag);
END Calculate_Service_Duration ;

PROCEDURE create_cust_interact_new_ord(control_user_id        IN  NUMBER,
				                   parent_interaction_id  IN  VARCHAR2,
				                   cp_last_update_login   IN  NUMBER,
				                   cp_bill_to_contact_id  IN  NUMBER,
				                   order_customer_id      IN  NUMBER,
							    return_status          OUT VARCHAR2,
							    return_msg             OUT VARCHAR2) IS
     l_ret_status  VARCHAR2(1);
     l_msg_count NUMBER;
	l_msg_data VARCHAR2(1000);
	l_interaction_id NUMBER;
	l_employee_id NUMBER;
--	l_return_error VARCHAR2;
--	l_return_unexp_error VARCHAR2;


BEGIN

    SELECT employee_id
    INTO   l_employee_id
    FROM   FND_USER
    WHERE  user_id = control_user_id;

--    l_return_error := cs_response_center_pkg.GET_ERROR_CONSTANT('G_RET_STS_ERROR');
--    l_return_unexp_error := cs_response_center_pkg.GET_ERROR_CONSTANT('G_RET_STS_UNEXP_ERROR');

    return_status := NULL;
    return_msg    := NULL;
    IF order_customer_id IS NOT NULL THEN

       CS_Interaction_PVT.Create_Interaction
                 (p_api_version                 => 1.0,
			   p_init_msg_list               => FND_API.G_TRUE,
			   p_commit                      => FND_API.G_FALSE,
		        p_validation_level   => CS_INTERACTION_PVT.G_VALID_LEVEL_INT,
			   x_return_status               => l_ret_status,
			   x_msg_count                   => l_msg_count,
  			   x_msg_data                    => l_msg_data,
			   p_resp_appl_id                => NULL,
		   	   p_resp_id                     => NULL,
			   p_user_id                     => control_user_id,
			   p_login_id                    => cp_last_update_login,
			   p_org_id                      => FND_PROFILE.Value('ORG_ID'),
			   p_customer_id                 => order_customer_id,
			   p_contact_id                  => cp_bill_to_contact_id,
			   p_contact_lastname            => NULL,
			   p_contact_firstname           => NULL,
			   p_phone_area_code             => NULL,
			   p_phone_number                => NULL,
			   p_phone_extension             => NULL,
			   p_fax_area_code               => NULL,
			   p_fax_number                  => NULL,
			   p_email_address               => NULL,
			   p_interaction_type_code       => 'SRV_ORD',
   		        p_interaction_category_code   => 'CS',
			   p_interaction_method_code     => 'SYSTEM',
			   p_interaction_date            => SYSDATE,
			   p_interaction_document_code   => NULL,
			   p_source_document_id          => NULL,
			   p_source_document_name        => NULL,
			   p_reference_form              => NULL,
			   p_source_document_status      => NULL,
			   p_employee_id                 => l_employee_id,
	  		   p_public_flag                 => NULL,
			   p_follow_up_action            => NULL,
			   p_notes                       => NULL,
			   p_parent_interaction_id       => parent_interaction_id,
			   p_attribute1                  => NULL,
			   p_attribute2                  => NULL,
			   p_attribute3                  => NULL,
			   p_attribute4                  => NULL,
			   p_attribute5                  => NULL,
			   p_attribute6                  => NULL,
			   p_attribute7                  => NULL,
	   		   p_attribute8                  => NULL,
		  	   p_attribute9                  => NULL,
		 	   p_attribute10                 => NULL,
			   p_attribute11                 => NULL,
			   p_attribute12                 => NULL,
			   p_attribute13                 => NULL,
			   p_attribute14                 => NULL,
			   p_attribute15                 => NULL,
			   p_attribute_category          => NULL,
			   x_interaction_id              => l_interaction_id);
	     return_status := l_ret_status;
	     return_msg := l_msg_data;
    END IF;

    IF (l_ret_status = FND_API.G_RET_STS_ERROR OR
   	   l_ret_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	  -- 1 meaning error, 0 meaning OK
	  return_status := '1';
    END IF;


END create_cust_interact_new_ord;


PROCEDURE create_cust_interact_renew(control_user_id       IN  NUMBER,
			                      cp_cp_service_id      IN  NUMBER,
				                 parent_interaction_id IN  VARCHAR2,
				                 cp_last_update_login  IN  NUMBER,
				                 cp_bill_to_contact_id IN  NUMBER,
                                     cp_customer_id        IN  NUMBER,
							  return_status         OUT VARCHAR2,
							  return_msg            OUT VARCHAR2) IS

     l_ret_status  VARCHAR2(1);
     l_msg_count NUMBER;
     l_msg_data VARCHAR2(1000);
     l_interaction_id NUMBER;
     l_customer_id NUMBER;
     l_employee_id NUMBER;
--     l_return_error VARCHAR2;
--     l_return_unexp_error VARCHAR2;


BEGIN

     SELECT employee_id
     INTO   l_employee_id
     FROM   FND_USER
     WHERE  user_id = control_user_id;



--     l_return_error := cs_response_center_pkg.GET_ERROR_CONSTANT('G_RET_STS_ERROR');
--     l_return_unexp_error := cs_response_center_pkg.GET_ERROR_CONSTANT('G_RET_STS_UNEXP_ERROR');

     return_status := NULL;
	return_msg    := NULL;
     IF cp_customer_id IS NOT NULL THEN

       CS_Interaction_PVT.Create_Interaction
             (p_api_version                 => 1.0,
              p_init_msg_list               => FND_API.G_TRUE,
              p_commit                      => FND_API.G_FALSE,
              p_validation_level            => FND_API.G_VALID_LEVEL_NONE,
              x_return_status               => l_ret_status,
              x_msg_count                   => l_msg_count,
              x_msg_data                    => l_msg_data,
              p_resp_appl_id                => NULL,
              p_resp_id                     => NULL,
              p_user_id                     => control_user_id,
              p_login_id                    => cp_last_update_login,
              p_org_id                      => FND_PROFILE.Value('ORG_ID'),
              p_customer_id                 => cp_customer_id,
              p_contact_id                  => cp_bill_to_contact_id,
              p_contact_lastname            => NULL,
              p_contact_firstname           => NULL,
              p_phone_area_code             => NULL,
              p_phone_number                => NULL,
              p_phone_extension             => NULL,
              p_fax_area_code               => NULL,
              p_fax_number                  => NULL,
              p_email_address               => NULL,
              p_interaction_type_code       => 'SRV_REN',
              p_interaction_category_code   => 'CS',
              p_interaction_method_code     => 'SYSTEM',
              p_interaction_date            => SYSDATE,
              p_interaction_document_code   => NULL,
              p_source_document_id          => NULL,
              p_source_document_name        => NULL,
              p_reference_form              => NULL,
              p_source_document_status      => NULL,
              p_employee_id                 => l_employee_id,
              p_public_flag                 => NULL,
              p_follow_up_action            => NULL,
              p_notes                       => NULL,
              p_parent_interaction_id       => parent_interaction_id,
              p_attribute1                  => NULL,
              p_attribute2                  => NULL,
              p_attribute3                  => NULL,
              p_attribute4                  => NULL,
              p_attribute5                  => NULL,
              p_attribute6                  => NULL,
              p_attribute7                  => NULL,
              p_attribute8                  => NULL,
              p_attribute9                  => NULL,
              p_attribute10                 => NULL,
              p_attribute11                 => NULL,
              p_attribute12                 => NULL,
              p_attribute13                 => NULL,
              p_attribute14                 => NULL,
              p_attribute15                 => NULL,
              p_attribute_category          => NULL,
              x_interaction_id              => l_interaction_id);
         return_status := l_ret_status;
	    return_msg := l_msg_data;
      END IF;

      IF (l_ret_status = FND_API.G_RET_STS_ERROR OR
          l_ret_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	    -- 1 meaning error, 0 meaning OK
	    return_status := '1';
      END IF;



END create_cust_interact_renew;


END Cs_Csxsvods_Check_Pkg;

/
