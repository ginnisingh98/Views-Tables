--------------------------------------------------------
--  DDL for Package Body AHL_DI_SUBSCRIPTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_DI_SUBSCRIPTION_PUB" AS
 /* $Header: AHLPSUBB.pls 115.35 2004/04/29 06:45:14 adharia noship $ */
--
G_PKG_NAME  VARCHAR2(30)  := 'AHL_DI_SUBSCRIPTION_PUB';

/*-----------------------------------------------------------*/
/* procedure name: Check_lookup_name_Or_Id(private procedure)*/
/* description :  used to retrieve lookup code               */
/*                                                           */
/*-----------------------------------------------------------*/

--G_DEBUG 		 VARCHAR2(1):=FND_PROFILE.VALUE('AHL_API_FILE_DEBUG_ON');
  G_DEBUG                VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;

PROCEDURE Check_lookup_name_Or_Id
 ( p_lookup_type      IN FND_LOOKUPS.lookup_type%TYPE,
   p_lookup_code      IN FND_LOOKUPS.lookup_code%TYPE ,
   p_meaning          IN FND_LOOKUPS.meaning%TYPE,
   p_check_id_flag    IN VARCHAR2,
   x_lookup_code      OUT NOCOPY FND_LOOKUPS.lookup_code%TYPE,
   x_return_status    OUT NOCOPY VARCHAR2)
IS


BEGIN
      IF (p_lookup_code IS NOT NULL) THEN
        IF (p_check_id_flag = 'Y') THEN
          SELECT lookup_code INTO x_lookup_code
           FROM FND_LOOKUP_VALUES_VL
          WHERE lookup_type = p_lookup_type
            AND lookup_code = p_lookup_code
            AND sysdate between start_date_active
            AND nvl(end_date_active,sysdate);
        ELSE
           x_lookup_code := p_lookup_code;
        END IF;
     ELSE
          SELECT lookup_code INTO x_lookup_code
           FROM FND_LOOKUP_VALUES_VL
          WHERE lookup_type = p_lookup_type
            AND meaning     = p_meaning
            AND sysdate between start_date_active
            AND nvl(end_date_active,sysdate);
    END IF;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
   WHEN no_data_found THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN too_many_rows THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE;
END;
/*------------------------------------------------------*/
/* procedure name: create_subscription                  */
/* description :  Creates new subscription record       */
/*                for an associated document            */
/*                                                      */
/*------------------------------------------------------*/
PROCEDURE CREATE_SUBSCRIPTION
(
 p_api_version               IN      NUMBER    :=  1.0                ,
 p_init_msg_list             IN      VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                    IN      VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only             IN      VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level          IN      NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_subscription_tbl        IN  OUT NOCOPY subscription_tbl          ,
 p_module_type               IN      VARCHAR2                         ,
 x_return_status                 OUT NOCOPY VARCHAR2                         ,
 x_msg_count                     OUT NOCOPY NUMBER                           ,
 x_msg_data                      OUT NOCOPY VARCHAR2)
IS

 --Used to retrieve the party id for party name
 CURSOR for_party_name(c_party_name  IN VARCHAR2)
 IS
 SELECT party_id
 FROM hz_parties
 WHERE upper(party_name) = upper(c_party_name);

 --Get the party id from hz parties
 CURSOR for_party_id(c_party_id  IN NUMBER)
 IS
 SELECT party_id
 FROM hz_parties
 WHERE party_id = c_party_id;

 -- enhancement #2525108: lov for PO Number : pbarman april 2003
  -- Get Puchase Order Number from PO_PURCHASE_ORDER_V
  CURSOR for_ponumber_id(c_ponumber IN VARCHAR2)
   IS
   SELECT distinct segment1
   FROM PO_HEADERS_V
   WHERE nvl(approved_flag, 'N')='Y' and upper(segment1) = upper(c_ponumber);

 -- Used to retrieve vendor id from po vendors
 CURSOR for_vendor_id(c_vendor_name IN VARCHAR2)
 IS
 SELECT vendor_id
 FROM po_vendors
 WHERE upper(vendor_name) = upper(c_vendor_name);

 --Used to retrieve the party id from party name
 CURSOR get_party_name (c_party_name  IN VARCHAR2)
 IS
 --Modified pjha 07-Aug-2002 for performance
  /*
  SELECT person_id
  FROM per_people_f ppf, per_person_types ppt
  WHERE upper(ppf.FULL_NAME) = upper(c_party_name)
    AND trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date
    AND nvl(ppf.current_employee_flag,'x') = 'Y'
    AND ppf.person_type_id = ppt.person_type_id
    AND ppt.system_person_type ='EMP';
  */
  --Modified pjha 29-Aug-2002 for bug#2536490(added trim function)
  SELECT person_id
  FROM per_all_people_f pap, per_person_types ppt
  WHERE trim(upper(FULL_NAME)) = upper(c_party_name)
  AND trunc(sysdate) between pap.effective_start_date and pap.effective_end_date
  AND nvl(pap.current_employee_flag,'x') = 'Y'
  AND pap.person_type_id = ppt.person_type_id
  AND ppt.system_person_type ='EMP'
  AND decode(HR_SECURITY.VIEW_ALL ,'Y' , 'TRUE', HR_SECURITY.SHOW_RECORD('PER_ALL_PEOPLE_F', pap.person_id,
             pap.person_type_id, pap.employee_number,pap.applicant_number)) = 'TRUE'
  AND decode(hr_general.get_xbg_profile,'Y',pap.business_group_id , hr_general.get_business_group_id)
            = pap.business_group_id;

 --
 l_api_name         CONSTANT VARCHAR2(30) := 'CREATE_SUBSCRIPTION';
 l_api_version      CONSTANT NUMBER       := 1.0;
 l_msg_count                 NUMBER;
 l_msg_data                  VARCHAR2(2000);
 l_return_status             VARCHAR2(1);
 l_supplier_id               NUMBER;
 l_requested_by_party_id     NUMBER;
 l_media_type_code           VARCHAR2(30);
 l_frequency_code            VARCHAR2(30);
 l_subscription_type_code    VARCHAR2(30);
 l_status_code               VARCHAR2(30);
 l_subscription_tbl          AHL_DI_SUBSCRIPTION_PVT.subscription_tbl;
 l_init_msg_list          VARCHAR2(10) := FND_API.G_TRUE;
 -- Enhancement #2205830: pbarman april 2003
 l_check_quantity            NUMBER;
 -- Enhancement #2525108: pbarman april 2003
 l_purchase_order_no         VARCHAR2(20);

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT create_subscription;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;

	END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'enter ahl_di_subscription_pub.Create Subscription','+SUB+');

	END IF;
    END IF;
   -- Standard call to check for call compatibility.
   IF FND_API.to_boolean(l_init_msg_list)
   THEN
     FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
    x_return_status := 'S';
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --Start of API Body
   IF p_x_subscription_tbl.count > 0
   THEN
     FOR i IN p_x_subscription_tbl.FIRST..p_x_subscription_tbl.LAST
     LOOP
     	-- For Requested By...
        -- Party Name is present
        IF (p_x_subscription_tbl(i).requested_by_pty_name IS NOT NULL)
           THEN

           IF ahl_di_doc_index_pvt.get_product_install_status('PER') in ('N','L') THEN
              -- Use cursor to retrieve party id using party name: party id will be unique for given party name
              OPEN for_party_name(p_x_subscription_tbl(i).requested_by_pty_name);
              FETCH for_party_name INTO l_requested_by_party_id;
              IF for_party_name%FOUND THEN
                 p_x_subscription_tbl(i).requested_by_party_id := l_requested_by_party_id;
              ELSE
                 FND_MESSAGE.SET_NAME('AHL','AHL_DI_REQ_PTY_ID_NOT_EXISTS');
                 FND_MSG_PUB.ADD;
              END IF;
              CLOSE for_party_name;

           ELSIF ahl_di_doc_index_pvt.get_product_install_status('PER') in ('I','S') THEN
              -- If party id is already present, use it; if not, retrieve using party name
	         -- Use cursor to retrieve party id using party name: party id may not be unique for given party name
	         OPEN get_party_name(p_x_subscription_tbl(i).requested_by_pty_name);
	         LOOP
		    FETCH get_party_name INTO l_requested_by_party_id;
		    EXIT WHEN get_party_name%NOTFOUND;
	         END LOOP;
	         -- If no records for name, then name is INVALID: show error
	         IF get_party_name%ROWCOUNT = 0 THEN
		    FND_MESSAGE.SET_NAME('AHL','AHL_DI_REQ_ID_NOT_EXISTS');
		    FND_MESSAGE.SET_TOKEN('REQ',p_x_subscription_tbl(i).requested_by_pty_name);


		    FND_MSG_PUB.ADD;
		 -- If only 1 record for name, use the id: id will be unique: use id
	         ELSIF get_party_name%ROWCOUNT = 1 THEN
		    p_x_subscription_tbl(i).requested_by_party_id := l_requested_by_party_id;
	         -- If more than 1 record, then error: id is not unique: ask user to choose from LOV
	         ELSIF
	                --p_x_subscription_tbl(i).requested_by_party_id IS NULL AND
	         	p_x_subscription_tbl(i).requested_by_party_id IS NULL
	         THEN
	      --    FND_MESSAGE.SET_NAME('AHL','LOV dup val');
		    FND_MESSAGE.SET_NAME('AHL','AHL_DI_REQUESTED_BY_USE_LOV');
		    FND_MSG_PUB.ADD;
	         END IF;
	         CLOSE get_party_name;
	   END IF;

        -- Party Name is not present: since id is mandatory: show error
        ELSE
     --        FND_MESSAGE.SET_NAME('AHL',' '|| p_x_subscription_tbl(i).requested_by_pty_name);
           FND_MESSAGE.SET_NAME('AHL','AHL_DI_REQ_PTY_ID_NULL');
           FND_MSG_PUB.ADD;

        END IF;

 	-- For Subscribed From...
        -- Party Name is present, retrieve party id from party name
        IF (p_x_subscription_tbl(i).subscribed_frm_pty_name IS NOT NULL)
           THEN

 		 IF ahl_di_doc_index_pvt.get_product_install_status('PO') IN ('N','L') THEN
                    OPEN  for_party_name(p_x_subscription_tbl(i).subscribed_frm_pty_name);
                    FETCH for_party_name INTO l_supplier_id;
                    IF for_party_name%FOUND
                    THEN
                       l_subscription_tbl(i).subscribed_frm_party_id := l_supplier_id;
                    ELSE
                       FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUB_PTY_ID_INVALID');
                       FND_MSG_PUB.ADD;
                    END IF;
                    CLOSE for_party_name;

                 ELSIF ahl_di_doc_index_pvt.get_product_install_status('PO') IN ('I','S') THEN
                    OPEN  for_vendor_id(p_x_subscription_tbl(i).subscribed_frm_pty_name);
                    FETCH for_vendor_id INTO l_supplier_id;
                    IF for_vendor_id%FOUND
                    THEN
                       l_subscription_tbl(i).subscribed_frm_party_id := l_supplier_id;
                    ELSE
                       --FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUB_PTY_ID_INVALID');
                       FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUB_ID_INVALID');
                       FND_MESSAGE.SET_TOKEN('SUP',p_x_subscription_tbl(i).subscribed_frm_pty_name);
                       FND_MSG_PUB.ADD;
                    END IF;
                    CLOSE for_vendor_id;

                 END IF;

        -- Enhancement #2034767 : Party Name is mandatory. Throw error message : pbarman Arpil 2003
        ELSE

        --  l_subscription_tbl(i).subscribed_frm_party_id := null;
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUBSCRIPTION_REQD');
       FND_MESSAGE.SET_TOKEN('FIELD1',p_x_subscription_tbl(i).requested_by_pty_name);
            FND_MSG_PUB.ADD;
        END IF;

        --For Media Type Code
        IF p_x_subscription_tbl(i).media_type_desc IS NOT NULL
         THEN
             --
             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_MEDIA_TYPE',
                  p_lookup_code  => null,
                  p_meaning      => p_x_subscription_tbl(i).media_type_desc,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_subscription_tbl(i).media_type_code,
                  x_return_status => l_return_status);

         IF nvl(l_return_status, 'X') <> 'S'
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_MEDTYP_CODE_NOT_EXISTS');
            FND_MSG_PUB.ADD;
         END IF;
       END IF;
         -- If id is present
          -- Both are missing
           l_subscription_tbl(i).media_type_code := p_x_subscription_tbl(i).media_type_code;

        --For Subscription  Type Code
        IF p_x_subscription_tbl(i).subscription_type_desc IS NOT NULL
         THEN
             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_SUBSCRIPTION_TYPE',
                  p_lookup_code  => null,
                  p_meaning      => p_x_subscription_tbl(i).subscription_type_desc,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_subscription_tbl(i).subscription_type_code,
                  x_return_status => l_return_status);

         IF nvl(l_return_status, 'X') <> 'S'
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUBTYP_CODE_NOT_EXISTS');
            FND_MSG_PUB.ADD;
         END IF;
       END IF;
       -- Code Presents
           l_subscription_tbl(i).subscription_type_code := p_x_subscription_tbl(i).subscription_type_code;

        --For Frequency Code
        IF p_x_subscription_tbl(i).frequency_desc IS NOT NULL
         THEN

             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_FREQUENCY_TYPE',
                  p_lookup_code  => null,
                  p_meaning      => p_x_subscription_tbl(i).frequency_desc,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_subscription_tbl(i).frequency_code,
                  x_return_status => l_return_status);

         IF nvl(l_return_status, 'X') <> 'S'
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_FREQCY_CODE_NOT_EXISTS');
            FND_MSG_PUB.ADD;
         END IF;
       END IF;
         -- Frequency Code present
           l_subscription_tbl(i).frequency_code := p_x_subscription_tbl(i).frequency_code;

        --For Status Code
        IF p_x_subscription_tbl(i).status_desc IS NOT NULL
         THEN

             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_SUBSCRIBE_STATUS_TYPE',
                  p_lookup_code  => null,
                  p_meaning      => p_x_subscription_tbl(i).status_desc,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_subscription_tbl(i).status_code,
                  x_return_status => l_return_status);

         IF nvl(l_return_status, 'X') <> 'S'
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_STATUS_CODE_NOT_EXISTS');
            FND_MSG_PUB.ADD;
         END IF;
       END IF;
         -- If Status Code is Avialable
         IF p_x_subscription_tbl(i).status_code IS NOT NULL
         THEN
           l_subscription_tbl(i).status_code := p_x_subscription_tbl(i).status_code;
         ELSE
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_STATUS_CODE_NULL');
            FND_MSG_PUB.ADD;
         END IF;


        -- Enhancement #2205830:If quantity is non integral. pbarman march 2003

        IF p_x_subscription_tbl(i).quantity IS NOT NULL
	THEN
	     l_check_quantity  :=  p_x_subscription_tbl(i).quantity;
	     IF l_check_quantity > TRUNC(l_check_quantity,0)
	     THEN
	         FND_MESSAGE.SET_NAME('AHL','AHL_DI_QTY_NON_INT');
                 FND_MSG_PUB.ADD;
	     END IF;
	END IF;
        -- Enhancement #2525108: check PO Number against PO Numbers in PO_PURCHASE_ORDER_V: pbarman april 2003

        IF p_x_subscription_tbl(i).purchase_order_no IS NOT NULL
        THEN

              IF ahl_di_doc_index_pvt.get_product_install_status('PO') in ('I','S')THEN
		      OPEN for_ponumber_id(p_x_subscription_tbl(i).purchase_order_no);
		      FETCH for_ponumber_id INTO l_purchase_order_no;
		      IF for_ponumber_id%FOUND THEN
			 l_subscription_tbl(i).purchase_order_no := l_purchase_order_no;
		      ELSE
			 FND_MESSAGE.SET_NAME('AHL','AHL_DI_PO_NUM_NOT_EXISTS');
			 FND_MSG_PUB.ADD;
		      END IF;
		      CLOSE for_ponumber_id;

	      ELSIF ahl_di_doc_index_pvt.get_product_install_status('PO') in ('N','L')THEN
	      	     l_subscription_tbl(i).purchase_order_no := p_x_subscription_tbl(i).purchase_order_no;
              END IF;

        END IF;

        --Assigning the values
        l_subscription_tbl(i).document_id             := p_x_subscription_tbl(i).document_id;
        l_subscription_tbl(i).requested_by_party_id   := p_x_subscription_tbl(i).requested_by_party_id;
        l_subscription_tbl(i).quantity                := p_x_subscription_tbl(i).quantity;
        l_subscription_tbl(i).start_date              := p_x_subscription_tbl(i).start_date;
        l_subscription_tbl(i).end_date                := p_x_subscription_tbl(i).end_date;
        --l_subscription_tbl(i).purchase_order_no       := p_x_subscription_tbl(i).purchase_order_no;
        l_subscription_tbl(i).attribute_category      := p_x_subscription_tbl(i).attribute_category;
        l_subscription_tbl(i).attribute1              := p_x_subscription_tbl(i).attribute1;
        l_subscription_tbl(i).attribute2              := p_x_subscription_tbl(i).attribute2;
        l_subscription_tbl(i).attribute3              := p_x_subscription_tbl(i).attribute3;
        l_subscription_tbl(i).attribute4              := p_x_subscription_tbl(i).attribute4;
        l_subscription_tbl(i).attribute5              := p_x_subscription_tbl(i).attribute5;
        l_subscription_tbl(i).attribute6              := p_x_subscription_tbl(i).attribute6;
        l_subscription_tbl(i).attribute7              := p_x_subscription_tbl(i).attribute7;
        l_subscription_tbl(i).attribute8              := p_x_subscription_tbl(i).attribute8;
        l_subscription_tbl(i).attribute9              := p_x_subscription_tbl(i).attribute9;
        l_subscription_tbl(i).attribute10             := p_x_subscription_tbl(i).attribute10;
        l_subscription_tbl(i).attribute11             := p_x_subscription_tbl(i).attribute11;
        l_subscription_tbl(i).attribute12             := p_x_subscription_tbl(i).attribute12;
        l_subscription_tbl(i).attribute13             := p_x_subscription_tbl(i).attribute13;
        l_subscription_tbl(i).attribute14             := p_x_subscription_tbl(i).attribute14;
        l_subscription_tbl(i).attribute15             := p_x_subscription_tbl(i).attribute15;
        l_subscription_tbl(i).delete_flag             := p_x_subscription_tbl(i).delete_flag;
        l_subscription_tbl(i).object_version_number   := p_x_subscription_tbl(i).object_version_number;
        l_subscription_tbl(i).source_lang             := p_x_subscription_tbl(i).source_lang;
        l_subscription_tbl(i).language                := p_x_subscription_tbl(i).language;
        l_subscription_tbl(i).comments                := p_x_subscription_tbl(i).comments;


 END LOOP;
END IF;


/*------------------------------------------------------------------------*/
/* procedure name: AHL_DI_SUBSCRIPTION_CUHK.CREATE_SUBSCRIPTION_PRE       */
/*                 AHL_DI_SUBSCRIPTION_VUHK.CREATE_SUBSCRIPTION_PRE       */
/* description   :  Added by siddhartha to call User Hooks                */
/* Date     : Dec 20 2001                                                 */
/*------------------------------------------------------------------------*/

IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_SUBSCRIPTION_PUB','CREATE_SUBSCRIPTION',
					'B', 'C' )  then

   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Start AHL_DI_SUBSCRIPTION_CUHK.CREATE_SUBSCRIPTION_Pre');

	END IF;
            AHL_DI_SUBSCRIPTION_CUHK.CREATE_SUBSCRIPTION_Pre(
			P_X_SUBSCRIPTION_TBL    =>	l_subscription_tbl,
			X_RETURN_STATUS        	=>	l_return_status      ,
			X_MSG_COUNT            	=>	l_msg_count           ,
			X_MSG_DATA             	=>	l_msg_data  );

   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End AHL_DI_SUBSCRIPTION_CUHK.CREATE_SUBSCRIPTION_Pre');

	END IF;

      		IF   l_return_status = FND_API.G_RET_STS_ERROR  THEN
    			RAISE FND_API.G_EXC_ERROR;
             	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
END IF;


IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_SUBSCRIPTION_PUB','CREATE_SUBSCRIPTION',
					'B', 'V' )  then
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Start AHL_DI_SUBSCRIPTION_VUHK.CREATE_SUBSCRIPTION_Pre');

	END IF;
            AHL_DI_SUBSCRIPTION_VUHK.CREATE_SUBSCRIPTION_Pre(
			P_X_SUBSCRIPTION_TBL   	=>	l_subscription_tbl,
			X_RETURN_STATUS        	=>	l_return_status      ,
			X_MSG_COUNT            	=>	l_msg_count           ,
			X_MSG_DATA             	=>	l_msg_data  );

   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'END AHL_DI_SUBSCRIPTION_VUHK.CREATE_SUBSCRIPTION_Pre');

	END IF;

      		IF   l_return_status = FND_API.G_RET_STS_ERROR  THEN
    			RAISE FND_API.G_EXC_ERROR;
             	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
END IF;


/*---------------------------------------------------------*/
/*     End ; Date     : Dec 20 2001                        */
/*---------------------------------------------------------*/
-- Standard call to get message count and if count is  get message info.
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
         X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSE
        X_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;


  -- Call the Private API
   AHL_DI_SUBSCRIPTION_PVT.CREATE_SUBSCRIPTION
                        (
                         p_api_version        => 1.0                ,
                         p_init_msg_list      => l_init_msg_list    ,
                         p_commit             => p_commit           ,
                         p_validate_only      => p_validate_only    ,
                         p_validation_level   => p_validation_level ,
                         p_x_subscription_tbl => l_subscription_tbl ,
                         x_return_status      => l_return_status    ,
                         x_msg_count          => l_msg_count        ,
                         x_msg_data           => l_msg_data
                         );

   -- Standard call to get message count and if count is  get message info.
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
         X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSE
        X_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
   ELSE
      FOR i IN 1..l_subscription_tbl.COUNT
      LOOP
         p_x_subscription_tbl(i).subscription_id := l_subscription_tbl(i).subscription_id;
      END LOOP;
   END IF;


/*------------------------------------------------------------------------*/
/* procedure name: AHL_DI_SUBSCRIPTION_VUHK.CREATE_SUBSCRIPTION_Post      */
/*                 AHL_DI_SUBSCRIPTION_CUHK.CREATE_SUBSCRIPTION_Post      */
/* description   :  Added by siddhartha to call User Hooks                */
/* Date     : Dec 20 2001                                                 */
/*------------------------------------------------------------------------*/


IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_SUBSCRIPTION_PUB','CREATE_SUBSCRIPTION',
					'A', 'V' )  then

   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Start AHL_DI_SUBSCRIPTION_VUHK.CREATE_SUBSCRIPTION_Post');

	END IF;

            AHL_DI_SUBSCRIPTION_VUHK.CREATE_SUBSCRIPTION_Post(
			P_SUBSCRIPTION_TBL   	=>	l_subscription_tbl,
			X_RETURN_STATUS        	=>	l_return_status      ,
			X_MSG_COUNT            	=>	l_msg_count           ,
			X_MSG_DATA             	=>	l_msg_data  );

IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End AHL_DI_SUBSCRIPTION_VUHK.CREATE_SUBSCRIPTION_Post');

	END IF;


      		IF   l_return_status = FND_API.G_RET_STS_ERROR  THEN
    			RAISE FND_API.G_EXC_ERROR;
             	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
END IF;

IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_SUBSCRIPTION_PUB','CREATE_SUBSCRIPTION',
					'A', 'C' )  then
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Start AHL_DI_SUBSCRIPTION_CUHK.CREATE_SUBSCRIPTION_Post');

	END IF;
            AHL_DI_SUBSCRIPTION_CUHK.CREATE_SUBSCRIPTION_Post(
			P_SUBSCRIPTION_TBL    =>	l_subscription_tbl,
			X_RETURN_STATUS        	=>	l_return_status      ,
			X_MSG_COUNT            	=>	l_msg_count           ,
			X_MSG_DATA             	=>	l_msg_data  );

   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End AHL_DI_SUBSCRIPTION_CUHK.CREATE_SUBSCRIPTION_Post');

	END IF;

      		IF   l_return_status = FND_API.G_RET_STS_ERROR  THEN
    			RAISE FND_API.G_EXC_ERROR;
             	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
END IF;


/*---------------------------------------------------------*/
/*     End ; Date     : Dec 20 2001                        */
/*---------------------------------------------------------*/



   -- Standard check of p_commit.
   IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End of public api Create Subscription','+SUB+');

	END IF;
   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.disable_debug;

	END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_subscription;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_subscription_pub.Create Subscription','+SUB+');


        -- Check if API is called in debug mode. If yes, disable debug.
           AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO create_subscription;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
        IF G_DEBUG='Y' THEN
             AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
             AHL_DEBUG_PUB.debug( 'ahl_di_subscription_pub.Create Subscription','+SUB+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN OTHERS THEN
    ROLLBACK TO create_subscription;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_SUBSCRIPTION_PUB',
                            p_procedure_name  =>  'CREATE_SUBSCRIPTION',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_subscription_pub.Create Subscription','+SUB+');


        -- Check if API is called in debug mode. If yes, disable debug.
           AHL_DEBUG_PUB.disable_debug;

	END IF;

END CREATE_SUBSCRIPTION;
/*------------------------------------------------------ */
/* procedure name: modify_subscription                   */
/* description :  Update the existing subscription record*/
/*                                                       */
/*------------------------------------------------------ */
PROCEDURE MODIFY_SUBSCRIPTION
(
 p_api_version                IN      NUMBER    :=  1.0               ,
 p_init_msg_list              IN      VARCHAR2  := FND_API.G_TRUE     ,
 p_commit                     IN      VARCHAR2  := FND_API.G_FALSE    ,
 p_validate_only              IN      VARCHAR2  := FND_API.G_TRUE     ,
 p_validation_level           IN      NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_subscription_tbl         IN  OUT NOCOPY subscription_tbl         ,
 p_module_type                IN      VARCHAR2                        ,
 x_return_status                  OUT NOCOPY VARCHAR2                        ,
 x_msg_count                      OUT NOCOPY NUMBER                          ,
 x_msg_data                       OUT NOCOPY VARCHAR2
)
IS

 -- Get the party id from hz parties
 CURSOR for_party_name(c_party_name  IN VARCHAR2)
 IS
 SELECT party_id
 FROM hz_parties
 WHERE upper(party_name) = upper(c_party_name);

 --Get the party id from hz parties
 CURSOR for_party_id(c_party_id  IN NUMBER)
 IS
 SELECT party_id
 FROM hz_parties
 WHERE party_id = c_party_id;

 -- Enhancement #2525108: lov for PO Number : pbarman april 2003
   -- Get Puchase Order Number from PO_PURCHASE_ORDER_V
   CURSOR for_ponumber_id(c_ponumber IN VARCHAR2)
    IS
    SELECT distinct segment1
   FROM PO_HEADERS_V
   WHERE nvl(approved_flag, 'N')='Y' and upper(segment1) = upper(c_ponumber);

 -- Used to retrieve vendor id from po vendors
 CURSOR for_vendor_id(c_vendor_name IN VARCHAR2)
 IS
 SELECT vendor_id
 FROM po_vendors
 WHERE upper(vendor_name) = upper(c_vendor_name);

 --Used to retrieve the party id for party name
 CURSOR get_party_name (c_party_name  IN VARCHAR2)
 IS
 --Modified pjha 07-Aug-2002 for performance
 /*
 SELECT person_id
 FROM per_people_f ppf, per_person_types ppt
 WHERE upper(ppf.first_name||' '||ppf.last_name) = upper(c_party_name)
   AND trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date
   AND nvl(ppf.current_employee_flag,'x') = 'Y'
   AND ppf.person_type_id = ppt.person_type_id
   AND ppt.system_person_type ='EMP';
 */
 --Modified pjha 29-Aug-2002 for bug#2536490(added trim function)
 SELECT person_id
 FROM per_all_people_f pap, per_person_types ppt
 WHERE trim(upper(FULL_NAME)) = upper(c_party_name)
 AND trunc(sysdate) between pap.effective_start_date and pap.effective_end_date
 AND nvl(pap.current_employee_flag,'x') = 'Y'
 AND pap.person_type_id = ppt.person_type_id
 AND ppt.system_person_type ='EMP'
 AND decode(HR_SECURITY.VIEW_ALL ,'Y' , 'TRUE', HR_SECURITY.SHOW_RECORD('PER_ALL_PEOPLE_F', pap.person_id,
            pap.person_type_id, pap.employee_number,pap.applicant_number)) = 'TRUE'
 AND decode(hr_general.get_xbg_profile,'Y',pap.business_group_id , hr_general.get_business_group_id)
            = pap.business_group_id;

 --Used to retrieve the party id for party name and party id
 CURSOR get_party_name_id (c_party_name  IN VARCHAR2, c_party_id IN NUMBER)
 IS
 SELECT person_id
 FROM per_people_f ppf, per_person_types ppt
 WHERE upper(FULL_NAME) = upper(c_party_name)
   AND ppf.person_id = c_party_id
   AND trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date
   AND nvl(ppf.current_employee_flag,'x') = 'Y'
   AND ppf.person_type_id = ppt.person_type_id
   AND ppt.system_person_type ='EMP';

 --
 l_api_name       CONSTANT VARCHAR2(30) := 'MODIFY_SUBSCRIPTION';
 l_api_version    CONSTANT NUMBER       := 1.0;
 l_num_rec                 NUMBER;
 l_msg_count               NUMBER;
 l_msg_data                VARCHAR2(2000);
 l_return_status           VARCHAR2(1);
 l_supplier_id             NUMBER;
 l_requested_by_party_id   NUMBER;
 l_media_type_code         VARCHAR2(30);
 l_frequency_code          VARCHAR2(30);
 l_subscription_type_code  VARCHAR2(30);
 l_status_code             VARCHAR2(30);
 l_party_name              VARCHAR2(80);
 l_subscription_tbl        AHL_DI_SUBSCRIPTION_PVT.subscription_tbl;
 l_init_msg_list          VARCHAR2(10) := FND_API.G_TRUE;

 -- Enhancement #2205830: pbarman april 2003
 l_check_quantity            NUMBER;
 -- Enhancement #2525108: pbarman april 2003
 l_purchase_order_no         VARCHAR2(20);

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT modify_subscription;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;

	END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'enter ahl_di_subscription_pub.Modify Subscription','+SUB+');

	END IF;
    END IF;
    -- Standard call to check for call compatibility.
   IF FND_API.to_boolean(l_init_msg_list)
   THEN
     FND_MSG_PUB.initialize;
   END IF;
    --  Initialize API return status to success
    x_return_status := 'S';
    -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --Start of API Body
   IF p_x_subscription_tbl.count > 0
   THEN
     FOR i IN p_x_subscription_tbl.FIRST..p_x_subscription_tbl.LAST
     LOOP
        -- For Requested By...
        -- Party Name is present
        IF (p_x_subscription_tbl(i).requested_by_pty_name IS NOT NULL)
           THEN

           IF ahl_di_doc_index_pvt.get_product_install_status('PER') in ('N','L') THEN
              -- Use cursor to retrieve party id using party name: party id will be unique for given party name
              OPEN for_party_name(p_x_subscription_tbl(i).requested_by_pty_name);
              FETCH for_party_name INTO l_requested_by_party_id;
              IF for_party_name%FOUND THEN
                 l_subscription_tbl(i).requested_by_party_id := l_requested_by_party_id;
              ELSE
                 FND_MESSAGE.SET_NAME('AHL','AHL_DI_REQ_PTY_ID_NOT_EXISTS');
                 FND_MSG_PUB.ADD;
              END IF;
              CLOSE for_party_name;

           ELSIF ahl_di_doc_index_pvt.get_product_install_status('PER') in ('I','S') THEN
              -- If party id and name are present, retrieve party id using both
              OPEN get_party_name_id (p_x_subscription_tbl(i).requested_by_pty_name, p_x_subscription_tbl(i).requested_by_party_id);
              FETCH get_party_name_id INTO l_requested_by_party_id;
              -- If 1 record retrieved then party id and name match, use party id
              p_x_subscription_tbl(i).requested_by_party_id := l_requested_by_party_id;
              -- If no records, then party name has been changed
              IF get_party_name_id%NOTFOUND THEN
                 -- Retrieve party id using party name
                 OPEN get_party_name (p_x_subscription_tbl(i).requested_by_pty_name);
                 LOOP
                    FETCH get_party_name INTO l_requested_by_party_id;
                    EXIT WHEN get_party_name%NOTFOUND;
                 END LOOP;
                 -- If no records for name, then name is INVALID: show error
                 IF get_party_name%ROWCOUNT = 0 THEN

                 --   FND_MESSAGE.SET_NAME('AHL','AHL_DI_REQ_PTY_ID_NOT_EXISTS');
                    FND_MESSAGE.SET_NAME('AHL','AHL_DI_REQ_ID_NOT_EXISTS');
		    FND_MESSAGE.SET_TOKEN('REQ',p_x_subscription_tbl(i).requested_by_pty_name);
                    FND_MSG_PUB.ADD;


                 -- If only 1 record for name, use the id: id will be unique: use id
                 ELSIF get_party_name%ROWCOUNT = 1 THEN
                    p_x_subscription_tbl(i).requested_by_party_id := l_requested_by_party_id;
                 -- If more than 1 record, then error: id is not unique: ask user to choose from LOV
                 ELSIF p_x_subscription_tbl(i).requested_by_party_id IS NULL
                 THEN
		  -- FND_MESSAGE.SET_NAME('AHL','AHL_DI_edit');
                     FND_MESSAGE.SET_NAME('AHL','AHL_DI_REQUESTED_BY_USE_LOV');
		     FND_MSG_PUB.ADD;
                 END IF;
                 CLOSE get_party_name;
              END IF;
              CLOSE get_party_name_id;

           END IF;

        -- Party Name is not present: since id is mandatory: show error
        ELSE
           IF p_x_subscription_tbl(i).delete_flag = 'N'
           THEN
             FND_MESSAGE.SET_NAME('AHL','AHL_DI_REQ_PTY_ID_NULL');
             FND_MSG_PUB.ADD;
           END IF;
        END IF;

        -- For Subscribed From...
        -- Party Name is available

        IF (p_x_subscription_tbl(i).subscribed_frm_pty_name IS NOT NULL)
        THEN
IF ahl_di_doc_index_pvt.get_product_install_status('PO') IN ('N','L') THEN
                    OPEN  for_party_name(p_x_subscription_tbl(i).subscribed_frm_pty_name);
                    FETCH for_party_name INTO l_supplier_id;
                    IF for_party_name%FOUND
                    THEN
                       l_subscription_tbl(i).subscribed_frm_party_id := l_supplier_id;
                    ELSE
                       FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUB_PTY_ID_INVALID');
                       FND_MSG_PUB.ADD;
                    END IF;
                    CLOSE for_party_name;

                 ELSIF ahl_di_doc_index_pvt.get_product_install_status('PO') IN ('I','S') THEN
                    OPEN  for_vendor_id(p_x_subscription_tbl(i).subscribed_frm_pty_name);
                    FETCH for_vendor_id INTO l_supplier_id;
                    IF for_vendor_id%FOUND
                    THEN
                       l_subscription_tbl(i).subscribed_frm_party_id := l_supplier_id;
                    ELSE
                       --FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUB_PTY_ID_INVALID');
                       FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUB_ID_INVALID');
		       FND_MESSAGE.SET_TOKEN('SUP',p_x_subscription_tbl(i).subscribed_frm_pty_name);


                       FND_MSG_PUB.ADD;
                    END IF;
                    CLOSE for_vendor_id;

                 END IF;

        --  Enhancement : #2034767 : Party Name is mandatory. So Throw error message. : pbarman april 2003
        ELSE
           --l_subscription_tbl(i).subscribed_frm_party_id := null;
           IF p_x_subscription_tbl(i).delete_flag = 'N'
           THEN
             FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUBSCRIPTION_REQD');
													IF p_x_subscription_tbl(i).requested_by_pty_name IS NOT NULL THEN
										       FND_MESSAGE.SET_TOKEN('FIELD1',p_x_subscription_tbl(i).requested_by_pty_name);
													ELSE
										       FND_MESSAGE.SET_TOKEN('FIELD1', '');
													END IF;

             FND_MSG_PUB.ADD;
           END IF;
        END IF;

        --For Media Type Code
        IF p_x_subscription_tbl(i).media_type_desc IS NOT NULL
         THEN
             --
             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_MEDIA_TYPE',
                  p_lookup_code  => null,
                  p_meaning      => p_x_subscription_tbl(i).media_type_desc,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_subscription_tbl(i).media_type_code,
                  x_return_status => l_return_status);

         IF nvl(l_return_status, 'X') <> 'S'
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_MEDTYP_CODE_NOT_EXISTS');
            FND_MSG_PUB.ADD;
         END IF;
       END IF;
         -- If id is present
           l_subscription_tbl(i).media_type_code := p_x_subscription_tbl(i).media_type_code;

        --For Subscription  Type Code
        IF p_x_subscription_tbl(i).subscription_type_desc IS NOT NULL
         THEN
             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_SUBSCRIPTION_TYPE',
                  p_lookup_code  => null,
                  p_meaning      => p_x_subscription_tbl(i).subscription_type_desc,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_subscription_tbl(i).subscription_type_code,
                  x_return_status => l_return_status);

         IF nvl(l_return_status, 'X') <> 'S'
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUBTYP_CODE_NOT_EXISTS');
            FND_MSG_PUB.ADD;
         END IF;
       END IF;
         -- Subscription type code is available
           l_subscription_tbl(i).subscription_type_code := p_x_subscription_tbl(i).subscription_type_code;

        --For Frequency Code
        IF p_x_subscription_tbl(i).frequency_desc IS NOT NULL
         THEN

             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_FREQUENCY_TYPE',
                  p_lookup_code  => null,
                  p_meaning      => p_x_subscription_tbl(i).frequency_desc,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_subscription_tbl(i).frequency_code,
                  x_return_status => l_return_status);

         IF nvl(l_return_status, 'X') <> 'S'
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_FREQCY_CODE_NOT_EXISTS');
            FND_MSG_PUB.ADD;
         END IF;
       END IF;
         -- Frequency Code present
           l_subscription_tbl(i).frequency_code := p_x_subscription_tbl(i).frequency_code;

        --For Status Code
        IF p_x_subscription_tbl(i).status_desc IS NOT NULL
         THEN

             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_SUBSCRIBE_STATUS_TYPE',
                  p_lookup_code  => null,
                  p_meaning      => p_x_subscription_tbl(i).status_desc,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_subscription_tbl(i).status_code,
                  x_return_status => l_return_status);

         IF nvl(l_return_status, 'X') <> 'S'
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_STATUS_CODE_NOT_EXISTS');
            FND_MSG_PUB.ADD;
         END IF;
       END IF;
         -- If Status Code is Avialable
           l_subscription_tbl(i).status_code := p_x_subscription_tbl(i).status_code;
        --
        -- Enhancement #2205830 :If quantity is non integral. pbarman march 2003

	IF p_x_subscription_tbl(i).quantity IS NOT NULL
	THEN
	     l_check_quantity  :=  p_x_subscription_tbl(i).quantity;
	     IF l_check_quantity > TRUNC(l_check_quantity,0)
	     THEN
		FND_MESSAGE.SET_NAME('AHL','AHL_DI_QTY_NON_INT');
	        FND_MSG_PUB.ADD;
	     END IF;
	END IF;

	-- enhancement : #2525108 : check PO Number against PO Numbers in PO_PURCHASE_ORDER_V: pbarman april 2003

	IF p_x_subscription_tbl(i).purchase_order_no IS NOT NULL
	THEN

        IF ahl_di_doc_index_pvt.get_product_install_status('PO') in ('I','S')THEN


	OPEN for_ponumber_id(p_x_subscription_tbl(i).purchase_order_no);
        FETCH for_ponumber_id INTO l_purchase_order_no;
        IF for_ponumber_id%FOUND THEN
	    l_subscription_tbl(i).purchase_order_no := l_purchase_order_no;

        ELSE
           IF p_x_subscription_tbl(i).delete_flag = 'N'
	   THEN
	     FND_MESSAGE.SET_NAME('AHL','AHL_DI_PO_NUM_NOT_EXISTS');
	     FND_MSG_PUB.ADD;
	   END IF;
        END IF;
        CLOSE for_ponumber_id;

        ELSIF ahl_di_doc_index_pvt.get_product_install_status('PO') in ('N','L')THEN

           l_subscription_tbl(i).purchase_order_no := p_x_subscription_tbl(i).purchase_order_no;
        END IF;
	END IF;

        l_subscription_tbl(i).subscription_id         := p_x_subscription_tbl(i).subscription_id;
        l_subscription_tbl(i).requested_by_party_id   := p_x_subscription_tbl(i).requested_by_party_id;
        l_subscription_tbl(i).document_id             := p_x_subscription_tbl(i).document_id;
        l_subscription_tbl(i).quantity                := p_x_subscription_tbl(i).quantity;
        l_subscription_tbl(i).start_date              := p_x_subscription_tbl(i).start_date;
        l_subscription_tbl(i).end_date                := p_x_subscription_tbl(i).end_date;
        --l_subscription_tbl(i).purchase_order_no       := p_x_subscription_tbl(i).purchase_order_no;
        l_subscription_tbl(i).attribute_category      := p_x_subscription_tbl(i).attribute_category;
        l_subscription_tbl(i).attribute1              := p_x_subscription_tbl(i).attribute1;
        l_subscription_tbl(i).attribute2              := p_x_subscription_tbl(i).attribute2;
        l_subscription_tbl(i).attribute3              := p_x_subscription_tbl(i).attribute3;
        l_subscription_tbl(i).attribute4              := p_x_subscription_tbl(i).attribute4;
        l_subscription_tbl(i).attribute5              := p_x_subscription_tbl(i).attribute5;
        l_subscription_tbl(i).attribute6              := p_x_subscription_tbl(i).attribute6;
        l_subscription_tbl(i).attribute7              := p_x_subscription_tbl(i).attribute7;
        l_subscription_tbl(i).attribute8              := p_x_subscription_tbl(i).attribute8;
        l_subscription_tbl(i).attribute9              := p_x_subscription_tbl(i).attribute9;
        l_subscription_tbl(i).attribute10             := p_x_subscription_tbl(i).attribute10;
        l_subscription_tbl(i).attribute11             := p_x_subscription_tbl(i).attribute11;
        l_subscription_tbl(i).attribute12             := p_x_subscription_tbl(i).attribute12;
        l_subscription_tbl(i).attribute13             := p_x_subscription_tbl(i).attribute13;
        l_subscription_tbl(i).attribute14             := p_x_subscription_tbl(i).attribute14;
        l_subscription_tbl(i).attribute15             := p_x_subscription_tbl(i).attribute15;
        l_subscription_tbl(i).delete_flag             := p_x_subscription_tbl(i).delete_flag;
        l_subscription_tbl(i).object_version_number   := p_x_subscription_tbl(i).object_version_number;
        l_subscription_tbl(i).source_lang             := p_x_subscription_tbl(i).source_lang;
        l_subscription_tbl(i).language                := p_x_subscription_tbl(i).language;
        l_subscription_tbl(i).comments                := p_x_subscription_tbl(i).comments;

  END LOOP;
END IF;


/*------------------------------------------------------------------------*/
/* procedure name: AHL_DI_SUBSCRIPTION_CUHK.MODIFY_SUBSCRIPTION_PRE        */
/*                 AHL_DI_SUBSCRIPTION_VUHK.MODIFY_SUBSCRIPTION_PRE        */
/* description   :  Added by siddhartha to call User Hooks                */
/* Date     : Dec 20 2001                                                 */
/*------------------------------------------------------------------------*/

IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_SUBSCRIPTION_PUB','MODIFY_SUBSCRIPTION',
					'B', 'C' )  then
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Start AHL_DI_SUBSCRIPTION_CUHK.MODIFY_SUBSCRIPTION_Pre');

	END IF;
            AHL_DI_SUBSCRIPTION_CUHK.MODIFY_SUBSCRIPTION_Pre(
			P_X_SUBSCRIPTION_TBL    	=>	l_subscription_tbl,
			X_RETURN_STATUS        	=>	l_return_status      ,
			X_MSG_COUNT            	=>	l_msg_count           ,
			X_MSG_DATA             	=>	l_msg_data  );


   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End AHL_DI_SUBSCRIPTION_CUHK.MODIFY_SUBSCRIPTION_Pre');

	END IF;

      		IF   l_return_status = FND_API.G_RET_STS_ERROR  THEN
    			RAISE FND_API.G_EXC_ERROR;
             	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
END IF;

IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_SUBSCRIPTION_PUB','MODIFY_SUBSCRIPTION',
					'B', 'V' )  then
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Start AHL_DI_SUBSCRIPTION_VUHK.MODIFY_SUBSCRIPTION_Pre');

	END IF;

            AHL_DI_SUBSCRIPTION_VUHK.MODIFY_SUBSCRIPTION_Pre(
			P_X_SUBSCRIPTION_TBL   	=>	l_subscription_tbl,
			X_RETURN_STATUS        	=>	l_return_status      ,
			X_MSG_COUNT            	=>	l_msg_count           ,
			X_MSG_DATA             	=>	l_msg_data  );

   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End AHL_DI_SUBSCRIPTION_VUHK.MODIFY_SUBSCRIPTION_Pre');

	END IF;

      		IF   l_return_status = FND_API.G_RET_STS_ERROR  THEN
    			RAISE FND_API.G_EXC_ERROR;
             	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
END IF;
/*---------------------------------------------------------*/
/*     End ; Date     : Dec 20 2001                         */
/*---------------------------------------------------------*/

-- Standard call to get message count and if count is  get message info.
   l_msg_count := FND_MSG_PUB.count_msg;
   --
   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
         X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSE
        X_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;


  -- Call the Private API
   AHL_DI_SUBSCRIPTION_PVT.MODIFY_SUBSCRIPTION
                        (
                         p_api_version        => 1.0                ,
                         p_init_msg_list      => l_init_msg_list    ,
                         -- Modified pjha 15-May-2002 for modifying 'subscribed to' Begin
                         --p_commit             => p_commit           ,
                         p_commit             => FND_API.G_FALSE    ,
                         -- Modified pjha 15-May-2002 for modifying 'subscribed to' End
                         p_validate_only      => p_validate_only    ,
                         p_validation_level   => p_validation_level ,
                         p_x_subscription_tbl => l_subscription_tbl ,
                         x_return_status      => l_return_status    ,
                         x_msg_count          => l_msg_count        ,
                         x_msg_data           => l_msg_data
                         );

   -- Standard call to get message count and if count is  get message info.
   l_msg_count := FND_MSG_PUB.count_msg;
   --
   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
         X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSE
        X_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

/*------------------------------------------------------------------------*/
/* procedure name: AHL_DI_SUBSCRIPTION_VUHK.MODIFY_SUBSCRIPTION_Post      */
/*                 AHL_DI_SUBSCRIPTION_CUHK.MODIFY_SUBSCRIPTION_Post      */
/* description   :  Added by siddhartha to call User Hooks                */
/* Date     : Dec 20 2001                                                 */
/*------------------------------------------------------------------------*/


IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_SUBSCRIPTION_PUB','MODIFY_SUBSCRIPTION',
					'A', 'V' )  then
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Start AHL_DI_SUBSCRIPTION_VUHK.MODIFY_SUBSCRIPTION_Post');

	END IF;

            AHL_DI_SUBSCRIPTION_VUHK.MODIFY_SUBSCRIPTION_Post(
			P_SUBSCRIPTION_TBL   	=>	l_subscription_tbl,
			X_RETURN_STATUS        	=>	l_return_status      ,
			X_MSG_COUNT            	=>	l_msg_count           ,
			X_MSG_DATA             	=>	l_msg_data  );

   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End AHL_DI_SUBSCRIPTION_VUHK.MODIFY_SUBSCRIPTION_Post');

	END IF;

      		IF     l_return_status = FND_API.G_RET_STS_ERROR  THEN
    			RAISE FND_API.G_EXC_ERROR;
             	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
END IF;

IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_SUBSCRIPTION_PUB','MODIFY_SUBSCRIPTION',
					'A', 'C' )  then
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Start AHL_DI_SUBSCRIPTION_CUHK.MODIFY_SUBSCRIPTION_Post');

	END IF;
            AHL_DI_SUBSCRIPTION_CUHK.MODIFY_SUBSCRIPTION_Post(
			P_SUBSCRIPTION_TBL    =>	l_subscription_tbl,
			X_RETURN_STATUS        	=>	l_return_status      ,
			X_MSG_COUNT            	=>	l_msg_count           ,
			X_MSG_DATA             	=>	l_msg_data  );

   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End AHL_DI_SUBSCRIPTION_CUHK.MODIFY_SUBSCRIPTION_Post');

	END IF;

      		IF   l_return_status = FND_API.G_RET_STS_ERROR  THEN
    			RAISE FND_API.G_EXC_ERROR;
             	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
END IF;



/*---------------------------------------------------------*/
/*     End ; Date     : Dec 20 2001                        */
/*---------------------------------------------------------*/

    -- Standard check of p_commit.
   IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;


   -- Debug info
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End of public api Modify Subscription','+SUB+');

	END IF;
   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.disable_debug;

	END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO modify_subscription;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
        IF G_DEBUG='Y' THEN
             AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'ERROR' );
             AHL_DEBUG_PUB.debug( 'ahl_di_subscription_pub.Modify Subscription','+SUB+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO modify_subscription;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
        IF G_DEBUG='Y' THEN
              AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
              AHL_DEBUG_PUB.debug( 'ahl_di_subscription_pub.Modify Subscription','+SUB+');


        -- Check if API is called in debug mode. If yes, disable debug.
             AHL_DEBUG_PUB.disable_debug;

	END IF;

 WHEN OTHERS THEN
    ROLLBACK TO modify_subscription;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_SUBSCRIPTION_PUB',
                            p_procedure_name  =>  'MODIFY_SUBSCRIPTION',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_subscription_pub.Modify Subscription','+SUB+');


        -- Check if API is called in debug mode. If yes, disable debug.
           AHL_DEBUG_PUB.disable_debug;

	END IF;

END MODIFY_SUBSCRIPTION;
--
END AHL_DI_SUBSCRIPTION_PUB;

/
