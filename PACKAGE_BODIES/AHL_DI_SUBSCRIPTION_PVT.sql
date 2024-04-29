--------------------------------------------------------
--  DDL for Package Body AHL_DI_SUBSCRIPTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_DI_SUBSCRIPTION_PVT" AS
/* $Header: AHLVSUBB.pls 120.2 2006/02/07 03:49:26 sagarwal noship $ */
--
G_PKG_NAME  VARCHAR2(30)  := 'AHL_DI_SUBSCRIPTION_PVT';
--

-- Validates the Subscriptions Info
/*---------------------------------------------------------*/
/* procedure name: validate_subscription(private procedure)*/
/* description :  Validation checks for before inserting   */
/*                new record as well before modification   */
/*                takes place                              */
/*---------------------------------------------------------*/

G_DEBUG          VARCHAR2(1):=AHL_DEBUG_PUB.is_log_enabled;
PROCEDURE VALIDATE_SUBSCRIPTION
(
 P_SUBSCRIPTION_ID         IN NUMBER     ,
 P_DOCUMENT_ID             IN NUMBER     ,
 P_STATUS_CODE             IN VARCHAR2   ,
 P_REQUESTED_BY_PARTY_ID   IN NUMBER     ,
 P_QUANTITY                IN NUMBER     ,
 P_FREQUENCY_CODE          IN VARCHAR2   ,
 P_SUBSCRIBED_FRM_PARTY_ID IN NUMBER     ,
 P_START_DATE              IN DATE       ,
 P_END_DATE                IN DATE       ,
 P_MEDIA_TYPE_CODE         IN VARCHAR2   ,
 P_SUBSCRIPTION_TYPE_CODE  IN VARCHAR2   ,
 P_PURCHASE_ORDER_NO       IN VARCHAR2   ,
 P_DELETE_FLAG             IN VARCHAR2   := 'N')
IS

-- Cursor to retrieve the status code from fnd lookups table
 CURSOR get_status_code(c_status_code VARCHAR2)
  IS
 SELECT lookup_code
   FROM FND_LOOKUP_VALUES_VL
  WHERE lookup_code = c_status_code
    AND lookup_type = 'AHL_SUBSCRIBE_STATUS_TYPE'
    AND sysdate between start_date_active
    AND nvl(end_date_active,sysdate);
-- Cursor to retrieve the frequency from fnd lookups
 CURSOR get_frequency_code(c_frequency_code VARCHAR2)
  IS
 SELECT lookup_code
   FROM FND_LOOKUP_VALUES_VL
  WHERE lookup_code = c_frequency_code
    AND lookup_type = 'AHL_FREQUENCY_TYPE'
    AND sysdate between start_date_active
    AND nvl(end_date_active,sysdate);
-- Cursor to retrieve the sub type code from fnd lookups table
 CURSOR get_sub_type_code(c_subscription_type_code VARCHAR2)
  IS
 SELECT lookup_code
   FROM FND_LOOKUP_VALUES_VL
  WHERE lookup_code = c_subscription_type_code
    AND lookup_type = 'AHL_SUBSCRIPTION_TYPE'
    AND sysdate between start_date_active
    AND nvl(end_date_active,sysdate);
-- Cursor to retrieve the media type code from fnd lookups
 CURSOR get_media_type_code(c_media_type_code VARCHAR2)
  IS
 SELECT lookup_code
   FROM FND_LOOKUP_VALUES_VL
  WHERE lookup_code = c_media_type_code
    AND lookup_type = 'AHL_MEDIA_TYPE'
    AND sysdate between start_date_active
    AND nvl(end_date_active,sysdate);

--Cursor is used to check the record exists in supplier documents
--Modified pjha 05-Jul-2002 for bug# 2448536: validating supplier: Begin
/*
 CURSOR subc_from_pty_info(c_subscribed_frm_pty_id IN NUMBER)
  IS
 SELECT  'x'
   FROM AHL_SUPPLIER_DOCUMENTS S
  WHERE S.supplier_id = c_subscribed_frm_pty_id;
*/
CURSOR subc_from_pty_info(c_subscribed_frm_pty_id IN NUMBER,
                          c_document_id IN NUMBER)
  IS
 SELECT  'x'
   FROM AHL_SUPPLIER_DOCUMENTS S
  WHERE S.supplier_id = c_subscribed_frm_pty_id
  AND S.document_id = c_document_id;
--Modified pjha 05-Jul-2002 for bug# 2448536: validating supplier: End

 -- Used to validate the document id
 CURSOR check_doc_info(c_document_id  NUMBER)
  IS
 SELECT 'X'
   FROM AHL_DOCUMENTS_B
  WHERE document_id  = c_document_id;
-- Cursor to retrieve the exisiting subscription record from base table
 CURSOR get_sub_rec_b_info (c_subscription_id NUMBER)
  IS
 SELECT document_id,
        status_code,
        requested_by_party_id,
        quantity,
        frequency_code,
        subscribed_frm_party_id,
        start_date,
        end_date,
        media_type_code
   FROM AHL_SUBSCRIPTIONS_B
  WHERE subscription_id = c_subscription_id;
-- Cursor is used to check for duplicate record
 CURSOR dup_rec(c_document_id  NUMBER,
                c_requested_by_party_id NUMBER)
  IS
 SELECT 'X'
   FROM AHL_SUBSCRIPTIONS_B
  WHERE document_id           = c_document_id
    AND requested_by_party_id = c_requested_by_party_id;
 --

 -- Cursor is used to get requested by name given requested id
  -- Perf Fixes for 4919023
  /*
  CURSOR get_requested_name(c_requested_by_party_id NUMBER)
   IS
  SELECT party_name
    FROM ahl_hz_per_employees_v
   WHERE party_id= c_requested_by_party_id;
  */

  CURSOR get_requested_name_hz(c_requested_by_party_id NUMBER)
   IS
  SELECT PARTY_NAME
    FROM HZ_PARTIES
   WHERE party_id= c_requested_by_party_id
     AND PARTY_TYPE ='PERSON';

  CURSOR get_requested_name_ppf(c_requested_by_party_id NUMBER)
   IS
  SELECT PPF.FULL_NAME
    FROM PER_PEOPLE_F PPF, PER_PERSON_TYPES PPT
   WHERE PPF.PERSON_ID= c_requested_by_party_id
     AND TRUNC(SYSDATE) BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
     AND NVL(PPF.CURRENT_EMPLOYEE_FLAG, 'X') = 'Y'
     AND PPF.PERSON_TYPE_ID = PPT.PERSON_TYPE_ID
     AND PPT.SYSTEM_PERSON_TYPE ='EMP';

-- enhancement #2525108: lov for PO Number : pbarman april 2003
-- Get Puchase Order Number from PO_PURCHASE_ORDER_V
   CURSOR for_ponumber_id(c_ponumber IN VARCHAR2)
   IS
   SELECT distinct segment1
   FROM PO_HEADERS_V
   WHERE nvl(approved_flag, 'N')='Y' and upper(segment1) = upper(c_ponumber);
--

  l_requested_by_name          VARCHAR2(301) := NULL;
  l_api_name          CONSTANT VARCHAR2(30)    := 'VALIDATE_SUBSCRIPTION';
  l_api_version       CONSTANT NUMBER          := 1.0;
  l_dummy                      VARCHAR2(2000);
  l_subscription_id            NUMBER;
  l_document_id                NUMBER;
  l_status_code                VARCHAR2(30);
  l_requested_by_party_id      NUMBER;
  l_quantity                   NUMBER;
  l_frequency_code             VARCHAR2(30);
  l_subscription_frm_party_id  NUMBER;
  l_start_date                 DATE;
  l_end_date                   DATE;
  l_subscription_type_code     VARCHAR2(30);
  l_media_type_code            VARCHAR2(30);
  l_purchase_order_no          VARCHAR2(20);
  l_prod_install_status        VARCHAR2(30);

  --
BEGIN
   -- When the delte flag is 'YES' means either insert or update
   --Enhancement nos #2034767 and #2205830: pbarman : April 2003
   IF (NVL(p_delete_flag, 'N') = 'N' )
   THEN
    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.enable_debug;
    END IF;

    -- Perf Fixes for 4919023
    BEGIN
        IF G_DEBUG='Y' THEN
           AHL_DEBUG_PUB.debug( 'Fetching Installation Status of PER','+SUB+');
        END IF;
        SELECT AHL_DI_DOC_INDEX_PVT.GET_PRODUCT_INSTALL_STATUS('PER')
          INTO l_prod_install_status
          FROM DUAL;
    END;

      -- Debug info.
    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'VALIDATION START');
    END IF;
   --When the process is update
    IF p_subscription_id IS NOT NULL
    THEN
       OPEN get_sub_rec_b_info (p_subscription_id);
       FETCH get_sub_rec_b_info INTO l_document_id,
                                     l_status_code,
                                     l_requested_by_party_id,
                                     l_quantity,
                                     l_frequency_code,
                                     l_subscription_frm_party_id,
                                     l_start_date,
                                     l_end_date,
                                     l_media_type_code;
       CLOSE get_sub_rec_b_info;
    END IF;
    --
    IF p_document_id IS NOT NULL
    THEN
        l_document_id := p_document_id;
    END IF;
    --
    IF p_status_code IS NOT NULL
    THEN
        l_status_code := p_status_code;
    END IF;
    --
    IF p_requested_by_party_id IS NOT NULL
    THEN
        l_requested_by_party_id := p_requested_by_party_id;
    END IF;
    --
    IF p_quantity IS NOT NULL
    THEN
        l_quantity := p_quantity;
    END IF;
    --
    IF p_frequency_code IS NOT NULL
    THEN
        l_frequency_code := p_frequency_code;
    END IF;
    --
    IF p_start_date IS NOT NULL
    THEN
        l_start_date := p_start_date;
    END IF;
    --
   IF p_end_date IS NOT NULL
    THEN
        l_end_date := p_end_date;
    END IF;
   --
   IF p_media_type_code IS NOT NULL
   THEN
        l_media_type_code := p_media_type_code;
    END IF;
   --
   IF p_subscribed_frm_party_id IS NOT NULL
   THEN
        l_subscription_frm_party_id := p_subscribed_frm_party_id;
    END IF;

       l_subscription_id := p_subscription_id;
    -- This condition checks Document Id, when the action is insert or update
     IF ((p_subscription_id IS NULL AND
        p_document_id IS NULL)  OR

        (p_subscription_id IS NOT NULL
        AND l_document_id IS NULL))

     THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOCUMENT_ID_NULL');
        FND_MSG_PUB.ADD;
     END IF;
     -- This condition checks Status Code, When the action is insert or update
     IF ((p_subscription_id IS NULL AND
        p_status_code IS NULL)  OR

        (p_subscription_id IS NOT NULL
        AND l_status_code IS NULL))
     THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_DI_STATUS_CODE_NULL');
        FND_MSG_PUB.ADD;
     END IF;

            -- Perf Fixes for 4919023
            /*
            OPEN get_requested_name(l_requested_by_party_id);
            FETCH get_requested_name INTO l_requested_by_name;
            CLOSE get_requested_name;
            */

            IF l_prod_install_status IN ('N','L') THEN
               OPEN get_requested_name_hz(l_requested_by_party_id);
               FETCH get_requested_name_hz INTO l_requested_by_name;
               CLOSE get_requested_name_hz;
            ELSIF l_prod_install_status IN ('I','S') THEN
               OPEN get_requested_name_ppf(l_requested_by_party_id);
               FETCH get_requested_name_ppf INTO l_requested_by_name;
               CLOSE get_requested_name_ppf;
            END IF;

     -- This condition checks Quantity Field, When the action is insert or update
     IF ((p_subscription_id IS NULL AND
        p_quantity IS NULL) OR

        (p_subscription_id IS NOT NULL
        AND p_quantity IS NULL))
       THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_DI_QUAN_REQID_NULL');
       FND_MESSAGE.SET_TOKEN('REQ',l_requested_by_name);
       FND_MSG_PUB.ADD;
     END IF;


      -- Enhancement #2525108: check PO Number against PO Numbers in PO_PURCHASE_ORDER_V: pbarman april 2003

     IF p_purchase_order_no IS NOT NULL
     THEN

     IF ahl_di_doc_index_pvt.get_product_install_status('PO') in ('I','S')THEN
           OPEN for_ponumber_id(p_purchase_order_no);
       FETCH for_ponumber_id INTO l_purchase_order_no;
       IF for_ponumber_id%NOTFOUND THEN
          FND_MESSAGE.SET_NAME('AHL','AHL_DI_PO_NUM_NOT_EXISTS');
          FND_MSG_PUB.ADD;
       END IF;
       CLOSE for_ponumber_id;
      END IF;
     END IF;
     -- Checks for Valid  Subscription from party id, Record should exist in supplier
     -- documents table
     --Modified pjha 12-Jul-2002 added end_date conditions to do the validation
     --only in the case of active subscriptions: Begin
          --IF (l_subscription_frm_party_id IS NOT NULL AND
          --    l_subscription_frm_party_id IS NOT NULL)
          IF (l_subscription_frm_party_id IS NOT NULL AND
              (p_end_date IS NULL OR
              p_end_date >= TRUNC(sysdate)))

     --Modified pjha 12-Jul-2002 added end_date conditions to do the validation
     --only in the case of active subscriptions: End
     THEN
         --Modified pjha 05-Jul-2002 for bug# 2448536: validating supplier: Begin
         --OPEN subc_from_pty_info(l_subscription_frm_party_id);
         OPEN subc_from_pty_info(l_subscription_frm_party_id,
                                 l_document_id);
         --Modified pjha 05-Jul-2002 for bug# 2448536: validating supplier: End
         FETCH subc_from_pty_info INTO l_dummy;
         IF subc_from_pty_info%NOTFOUND
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUB_PTY_ID_INVALID');
            FND_MSG_PUB.ADD;
         END IF;
         CLOSE subc_from_pty_info;
      END IF;
     --Validates Requested by
     IF ((p_subscription_id IS NULL AND
        p_requested_by_party_id IS NULL)
        OR

        (p_subscription_id IS NOT NULL
        AND l_requested_by_party_id IS NULL))
     THEN

       FND_MESSAGE.SET_NAME('AHL','AHL_DI_REQUES_BY_PARTY_ID_NULL');
       FND_MSG_PUB.ADD;
     END IF;
   -- Validates the Quantity Field
   IF p_quantity IS NOT NULL
      OR
      l_quantity IS NOT NULL
   THEN
     IF(p_quantity <= 0 or l_quantity <= 0) THEN
       --FND_MESSAGE.SET_NAME('AHL','AHL_DI_QUANTITY_INVALID');

       FND_MESSAGE.SET_NAME('AHL','AHL_DI_QUAN_REQID_NULL');
       FND_MESSAGE.SET_TOKEN('REQ',l_requested_by_name);
       FND_MSG_PUB.ADD;
     END IF;
   END IF;
   -- Validations for start date
   IF (p_start_date IS NOT NULL
      AND p_end_date IS NOT NULL)
        OR
      (l_start_date IS NOT NULL
       AND l_end_date IS NOT NULL)

   THEN
     --Modified pjha 12-Jun-2002 for date range check and for picking right message bug# 2314334 Begin
          /*
          IF(p_start_date > nvl(l_end_date, p_start_date))  OR
            (l_start_date > nvl(l_end_date,l_start_date))
            THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_INVALID_DATE');
            FND_MSG_PUB.ADD;
          END IF;
          */
          IF(p_start_date >= nvl(l_end_date, p_start_date))  OR
            (l_start_date >= nvl(l_end_date,l_start_date))
            THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_INVALID_DATE_RANGE');
            FND_MSG_PUB.ADD;
          END IF;

     --Modified pjha 12-Jun-2002 for date range check and for picking right message bug# 2314334 End
  END IF;
    -- Checks for existence of status code in fnd lookups
    IF p_status_code IS NOT NULL
    THEN
       OPEN get_status_code(p_status_code);
       FETCH get_status_code INTO l_dummy;
       IF get_status_code%NOTFOUND
       THEN
          FND_MESSAGE.SET_NAME('AHL','AHL_DI_STATUS_CODE_NOT_EXISTS');
          FND_MSG_PUB.ADD;
        END IF;
        CLOSE get_status_code;
     END IF;
    -- This condition checks the document id exists in ahl documents table
    IF p_document_id IS NOT NULL
    THEN
       OPEN Check_doc_info(p_document_id);
       FETCH Check_doc_info INTO l_dummy;
       IF Check_doc_info%NOTFOUND
       THEN
          FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOCUMENT_ID_NOT_EXISTS');
          FND_MSG_PUB.ADD;
        END IF;
        CLOSE Check_doc_info;
     END IF;
     -- Checks for existence of status code in fnd lookups
     IF p_media_type_code IS NOT NULL
     THEN
        OPEN get_media_type_code(p_media_type_code);
        FETCH get_media_type_code INTO l_dummy;
        IF get_media_type_code%NOTFOUND
        THEN
           FND_MESSAGE.SET_NAME('AHL','AHL_DI_MEDTYP_CODE_NOT_EXISTS');
           FND_MSG_PUB.ADD;
        END IF;
        CLOSE get_media_type_code;
      END IF;
     -- Checks for existence of subscription type code in fnd lookups
     IF p_subscription_type_code IS NOT NULL
     THEN
        OPEN get_sub_type_code(p_subscription_type_code);
        FETCH get_sub_type_code INTO l_dummy;
        IF get_sub_type_code%NOTFOUND
        THEN
           FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUBTYP_CODE_NOT_EXISTS');
           FND_MSG_PUB.ADD;
        END IF;
        CLOSE get_sub_type_code;
      END IF;
     -- Checks for existence of frequency code in fnd lookups
     IF p_frequency_code IS NOT NULL
     THEN
        OPEN get_frequency_code(p_frequency_code);
        FETCH get_frequency_code INTO l_dummy;
        IF get_frequency_code%NOTFOUND
        THEN
           FND_MESSAGE.SET_NAME('AHL','AHL_DI_FREQCY_CODE_NOT_EXISTS');
           FND_MSG_PUB.ADD;
        END IF;
        CLOSE get_frequency_code;
      END IF;
   -- Checks for Duplicate Record, when inserting new subscription record
   IF p_subscription_id IS NULL
   THEN
       OPEN dup_rec(l_document_id ,
                    l_requested_by_party_id);
       FETCH dup_rec INTO l_dummy;
          IF dup_rec%FOUND THEN
          --FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUBSC_DUP_RECORD');

          /*
           OPEN get_requested_name(l_requested_by_party_id);
           FETCH get_requested_name INTO l_requested_by_name;
           CLOSE get_requested_name;
          */

          FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUBS_DUP_RECORD');
          FND_MESSAGE.SET_TOKEN('REQID',l_requested_by_name);
          FND_MSG_PUB.ADD;
          END IF;
       CLOSE dup_rec;
    END IF;
END IF;

END VALIDATE_SUBSCRIPTION;
/*------------------------------------------------------*/
/* procedure name: create_subscription                  */
/* description :  Creates new subscription record       */
/*                for an associated document            */
/*                                                      */
/*------------------------------------------------------*/

PROCEDURE CREATE_SUBSCRIPTION
(
 p_api_version                 IN      NUMBER    :=  1.0                ,
 p_init_msg_list               IN      VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                      IN      VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only               IN      VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level            IN      NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_subscription_tbl          IN  OUT NOCOPY subscription_tbl          ,
 x_return_status                   OUT NOCOPY VARCHAR2                         ,
 x_msg_count                       OUT NOCOPY NUMBER                           ,
 x_msg_data                        OUT NOCOPY VARCHAR2
 )
IS
 l_api_name        CONSTANT VARCHAR2(30) := 'CREATE_SUBSCRIPTION';
 l_api_version     CONSTANT NUMBER       := 1.0;
 l_num_rec                  NUMBER;
 l_msg_count                NUMBER;
 l_rowid                    ROWID;
 l_subscription_id          NUMBER;
 l_requested_by_party_id    NUMBER;
 l_subscription_info        subscription_rec;
 -- Added pjha 15-May-2002 for modifying 'subscribed to' Begin
  l_subscribe_to_flag       VARCHAR2(1);
 -- Added pjha 15-May-2002 for modifying 'subscribed to' End
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
          AHL_DEBUG_PUB.debug( 'enter ahl_di_subscription_pvt.Create Subscription','+SUB+');

    END IF;
    END IF;
   -- Standard call to check for call compatibility.
   IF FND_API.to_boolean(p_init_msg_list)
   THEN
     FND_MSG_PUB.initialize;
   END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
  --Start API Body
  IF p_x_subscription_tbl.COUNT > 0
  THEN
     FOR i IN p_x_subscription_tbl.FIRST..p_x_subscription_tbl.LAST
     LOOP
        VALIDATE_SUBSCRIPTION
        (
        p_subscription_id         => p_x_subscription_tbl(i).subscription_id,
        p_document_id             =>p_x_subscription_tbl(i).document_id,
        p_status_code             =>p_x_subscription_tbl(i).status_code,
        p_requested_by_party_id   =>p_x_subscription_tbl(i).requested_by_party_id,
        p_quantity                =>p_x_subscription_tbl(i).quantity,
        p_frequency_code          =>p_x_subscription_tbl(i).frequency_code,
        p_subscribed_frm_party_id =>p_x_subscription_tbl(i).subscribed_frm_party_id,
        p_start_date              =>p_x_subscription_tbl(i).start_date,
        p_end_date                =>p_x_subscription_tbl(i).end_date,
        p_media_type_code         =>p_x_subscription_tbl(i).media_type_code,
        p_subscription_type_code  =>p_x_subscription_tbl(i).subscription_type_code,
        p_purchase_order_no       =>p_x_subscription_tbl(i).purchase_order_no,
        p_delete_flag             =>p_x_subscription_tbl(i).delete_flag
        );
   END LOOP;
   -- Standard call to get message count and if count is  get message info.
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   FOR i IN p_x_subscription_tbl.FIRST..p_x_subscription_tbl.LAST
   LOOP
      IF  (p_x_subscription_tbl(i).subscription_id IS NULL)
      THEN
         -- These conditions are required for optional fields, Frequency code
            l_subscription_info.frequency_code := p_x_subscription_tbl(i).frequency_code;
         -- Subscribed from party id
            l_subscription_info.subscribed_frm_party_id := p_x_subscription_tbl(i).subscribed_frm_party_id;

         -- Start Date
         IF p_x_subscription_tbl(i).start_date IS NULL
         THEN
         --Modified pjha 03-Jul-2002 for making default start date: Begin
            --l_subscription_info.start_date := null;
            l_subscription_info.start_date := sysdate;
         --Modified pjha 03-Jul-2002 for making default start date: End
         ELSE
            l_subscription_info.start_date := p_x_subscription_tbl(i).start_date;
         END IF;
            l_subscription_info.end_date := p_x_subscription_tbl(i).end_date;
            l_subscription_info.purchase_order_no := p_x_subscription_tbl(i).purchase_order_no;
            l_subscription_info.subscription_type_code := p_x_subscription_tbl(i).subscription_type_code;
            l_subscription_info.media_type_code := p_x_subscription_tbl(i).media_type_code;
            l_subscription_info.comments := p_x_subscription_tbl(i).comments;
            l_subscription_info.attribute_category := p_x_subscription_tbl(i).attribute_category;
            l_subscription_info.attribute1 := p_x_subscription_tbl(i).attribute1;
            l_subscription_info.attribute2 := p_x_subscription_tbl(i).attribute2;
            l_subscription_info.attribute3 := p_x_subscription_tbl(i).attribute3;
            l_subscription_info.attribute4 := p_x_subscription_tbl(i).attribute4;
            l_subscription_info.attribute5 := p_x_subscription_tbl(i).attribute5;
            l_subscription_info.attribute6 := p_x_subscription_tbl(i).attribute6;
            l_subscription_info.attribute7 := p_x_subscription_tbl(i).attribute7;
            l_subscription_info.attribute8 := p_x_subscription_tbl(i).attribute8;
            l_subscription_info.attribute9 := p_x_subscription_tbl(i).attribute9;
            l_subscription_info.attribute10 := p_x_subscription_tbl(i).attribute10;
            l_subscription_info.attribute11 := p_x_subscription_tbl(i).attribute11;
            l_subscription_info.attribute12 := p_x_subscription_tbl(i).attribute12;
            l_subscription_info.attribute13 := p_x_subscription_tbl(i).attribute13;
            l_subscription_info.attribute14 := p_x_subscription_tbl(i).attribute14;
            l_subscription_info.attribute15 := p_x_subscription_tbl(i).attribute15;
         -- Retrive the subscription id from sequence
    Select AHL_SUBSCRIPTIONS_B_S.Nextval Into
    l_subscription_id from dual;
/*-------------------------------------------------------- */
/* procedure name: AHL_SUBSCRIPTIONS_PKG.INSERT_ROW        */
/* description   :  Added by Senthil to call Table Handler */
/*      Date     : Dec 31 2001                             */
/*---------------------------------------------------------*/
    -- Insert the new record into subscriptions table and trans table
    AHL_SUBSCRIPTIONS_PKG.INSERT_ROW (
        X_ROWID             =>  l_rowid,
        X_SUBSCRIPTION_ID       =>  l_subscription_id,
        X_ATTRIBUTE5            =>  l_subscription_info.attribute5,
        X_DOCUMENT_ID           =>  p_x_subscription_tbl(i).document_id,
        X_REQUESTED_BY_PARTY_ID     =>  p_x_subscription_tbl(i).requested_by_party_id,
        X_ATTRIBUTE6            =>  l_subscription_info.attribute6,
        X_ATTRIBUTE7            =>  l_subscription_info.attribute7,
        X_ATTRIBUTE8            =>  l_subscription_info.attribute8,
        X_ATTRIBUTE9            =>  l_subscription_info.attribute9,
        X_ATTRIBUTE10           =>  l_subscription_info.attribute10,
        X_ATTRIBUTE11           =>  l_subscription_info.attribute11,
        X_ATTRIBUTE12           =>  l_subscription_info.attribute12,
        X_ATTRIBUTE13           =>  l_subscription_info.attribute13,
        X_ATTRIBUTE14           =>  l_subscription_info.attribute14,
        X_ATTRIBUTE_CATEGORY        =>  l_subscription_info.attribute_category,
        X_ATTRIBUTE1            =>  l_subscription_info.attribute1,
        X_ATTRIBUTE2            =>  l_subscription_info.attribute2,
        X_ATTRIBUTE3            =>  l_subscription_info.attribute3,
        X_ATTRIBUTE4            =>  l_subscription_info.attribute4,
        X_OBJECT_VERSION_NUMBER     =>  1,
        X_ATTRIBUTE15           =>  l_subscription_info.attribute15,
        X_SUBSCRIBED_FRM_PARTY_ID   =>  l_subscription_info.subscribed_frm_party_id,
        X_QUANTITY          =>  p_x_subscription_tbl(i).quantity,
        X_STATUS_CODE           =>  p_x_subscription_tbl(i).status_code,
        X_PURCHASE_ORDER_NO     =>  l_subscription_info.purchase_order_no,
        X_FREQUENCY_CODE        =>  l_subscription_info.frequency_code,
        X_SUBSCRIPTION_TYPE_CODE    =>  l_subscription_info.subscription_type_code,
        X_MEDIA_TYPE_CODE       =>  l_subscription_info.media_type_code,
        X_START_DATE            =>  l_subscription_info.start_date,
        X_END_DATE          =>  l_subscription_info.end_date,
        X_COMMENTS          =>  l_subscription_info.comments,
        X_CREATION_DATE         =>  sysdate,
        X_CREATED_BY            =>  fnd_global.user_id,
        X_LAST_UPDATE_DATE      =>  sysdate,
        X_LAST_UPDATED_BY       =>  fnd_global.user_id,
        X_LAST_UPDATE_LOGIN     =>  fnd_global.login_id
        ) ;
/*
    -- Insert the new record into subscriptions table
    INSERT INTO AHL_SUBSCRIPTIONS_B
                (
                 SUBSCRIPTION_ID,
                 DOCUMENT_ID,
                 STATUS_CODE,
                 REQUESTED_BY_PARTY_ID,
                 QUANTITY,
                 FREQUENCY_CODE,
                 SUBSCRIBED_FRM_PARTY_ID,
                 START_DATE,
                 END_DATE,
                 PURCHASE_ORDER_NO,
                 SUBSCRIPTION_TYPE_CODE,
                 MEDIA_TYPE_CODE,
                 OBJECT_VERSION_NUMBER,
                 ATTRIBUTE_CATEGORY,
                 ATTRIBUTE1,
                 ATTRIBUTE2,
                 ATTRIBUTE3,
                 ATTRIBUTE4,
                 ATTRIBUTE5,
                 ATTRIBUTE6,
                 ATTRIBUTE7,
                 ATTRIBUTE8,
                 ATTRIBUTE9,
                 ATTRIBUTE10,
                 ATTRIBUTE11,
                 ATTRIBUTE12,
                 ATTRIBUTE13,
                 ATTRIBUTE14,
                 ATTRIBUTE15,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_LOGIN
                )
      VALUES
               (
                 l_subscription_id,
                 p_x_subscription_tbl(i).document_id,
                 p_x_subscription_tbl(i).status_code,
                 p_x_subscription_tbl(i).requested_by_party_id,
                 p_x_subscription_tbl(i).quantity,
                 l_subscription_info.frequency_code,
                 l_subscription_info.subscribed_frm_party_id,
                 l_subscription_info.start_date,
                 l_subscription_info.end_date,
                 l_subscription_info.purchase_order_no,
                 l_subscription_info.subscription_type_code,
                 l_subscription_info.media_type_code,
                 1,
                 l_subscription_info.attribute_category,
                 l_subscription_info.attribute1,
                 l_subscription_info.attribute2,
                 l_subscription_info.attribute3,
                 l_subscription_info.attribute4,
                 l_subscription_info.attribute5,
                 l_subscription_info.attribute6,
                 l_subscription_info.attribute7,
                 l_subscription_info.attribute8,
                 l_subscription_info.attribute9,
                 l_subscription_info.attribute10,
                 l_subscription_info.attribute11,
                 l_subscription_info.attribute12,
                 l_subscription_info.attribute13,
                 l_subscription_info.attribute14,
                 l_subscription_info.attribute15,
                 sysdate,
                 fnd_global.user_id,
                 sysdate,
                 fnd_global.user_id,
                 fnd_global.login_id
                );
       p_x_subscription_tbl(i).subscription_id := l_subscription_id;
       p_x_subscription_tbl(i).object_version_number := 1;
       -- Insert the record into trans table
       INSERT INTO AHL_SUBSCRIPTIONS_TL
                  (
                   SUBSCRIPTION_ID,
                   LAST_UPDATE_DATE,
                   LAST_UPDATED_BY,
                   CREATION_DATE,
                   CREATED_BY,
                   COMMENTS,
                   LANGUAGE,
                   SOURCE_LANG
                  )
          SELECT
                  l_subscription_id,
                  sysdate,
                  fnd_global.user_id,
                  sysdate,
                  fnd_global.user_id,
                  l_subscription_info.comments,
                  L.LANGUAGE_CODE,
                  userenv('LANG')
             FROM FND_LANGUAGES L
            WHERE L.INSTALLED_FLAG IN ('I','B')
              AND NOT EXISTS
           (SELECT NULL
              FROM AHL_SUBSCRIPTIONS_TL T
             WHERE T.subscription_id = l_subscription_id
               AND T.language = L.LANGUAGE_CODE);
*/

       -- Added pjha 15-May-2002 for modifying 'subscribed to' Begin

              --Check whether Subscribed To is Yes or No in AHL_DOCUMENTS_B
              SELECT subscribe_to_flag
              INTO l_subscribe_to_flag
              FROM AHL_DOCUMENTS_B
              WHERE document_id =  p_x_subscription_tbl(i).document_id;

              --If Subscribed To  is no, then make it yes
              IF l_subscribe_to_flag = 'N' THEN
                UPDATE AHL_DOCUMENTS_B
                SET subscribe_to_flag = 'Y'
                WHERE document_id =  p_x_subscription_tbl(i).document_id;
              END IF;

       -- Added pjha 15-May-2002 for modifying 'subscribed to' End

       --Assign the values
       p_x_subscription_tbl(i).subscription_id := l_subscription_id;
       p_x_subscription_tbl(i).object_version_number := 1;
       --
       l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
         X_msg_count := l_msg_count;
         X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
  END LOOP;
END IF;
   -- Standard check of p_commit.
   IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug( 'End of private api Create Subscription','+SUB+');

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
            AHL_DEBUG_PUB.debug( 'ahl_di_subscription_pvt.Create Subscription','+SUB+');


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
            AHL_DEBUG_PUB.debug( 'ahl_di_subscription_pvt.Create Subscription','+SUB+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

    END IF;


 WHEN DUP_VAL_ON_INDEX THEN
    ROLLBACK TO create_subscription;
    X_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUBSC_DUP_RECORD');
         FND_MSG_PUB.ADD;
        -- Check if API is called in debug mode. If yes, disable debug.
        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;

    END IF;


 WHEN OTHERS THEN
    ROLLBACK TO create_subscription;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_SUBSCRIPTION_PVT',
                            p_procedure_name  =>  'CREATE_SUBSCRIPTION',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_subscription_pvt.Create Subscription','+SUB+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

    END IF;

END CREATE_SUBSCRIPTION;
/*------------------------------------------------------*/
/* procedure name: modify_subscription                  */
/* description :  Update the existing subscription recor*/
/*                d and removes the subscription record */
/*                for an associated document            */
/*                                                      */
/*------------------------------------------------------*/
PROCEDURE MODIFY_SUBSCRIPTION
(
 p_api_version                IN      NUMBER    :=  1.0               ,
 p_init_msg_list              IN      VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                     IN      VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only              IN      VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level           IN      NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_subscription_tbl         IN  OUT NOCOPY subscription_tbl          ,
 x_return_status                  OUT NOCOPY VARCHAR2                         ,
 x_msg_count                      OUT NOCOPY NUMBER                           ,
 x_msg_data                       OUT NOCOPY VARCHAR2
)
IS
-- Cursor to retrieve the existing subscriptions record
CURSOR get_sub_rec_b_info(c_subscription_id  NUMBER)
 IS
SELECT ROWID row_id,
       document_id,
       status_code,
       requested_by_party_id,
       quantity,
       frequency_code,
       subscribed_frm_party_id,
       start_date,
       end_date,
       purchase_order_no,
       subscription_type_code,
       media_type_code,
       object_version_number,
       attribute_category,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15
  FROM AHL_SUBSCRIPTIONS_B
 WHERE subscription_id = c_subscription_id
   FOR UPDATE OF object_version_number NOWAIT;
-- Cursor to retrieve the record from trans table
CURSOR get_sub_rec_tl_info(c_subscription_id NUMBER)
 IS
SELECT ROWID,
       comments
  FROM AHL_SUBSCRIPTIONS_TL
 WHERE subscription_id = c_subscription_id
   FOR UPDATE OF subscription_id NOWAIT;

-- modified the code for fixing Bug 2183529
-- Cursor to check for old subscriptions
CURSOR get_old_sub ( c_document_id  NUMBER,
                     c_requested_by_party_id NUMBER)
IS
SELECT subscription_id
FROM AHL_SUBSCRIPTIONS_B
WHERE   document_id           = c_document_id AND
    requested_by_party_id = c_requested_by_party_id;

--
--added pjha 28-Jun-2002 for proper update of Subscribed to
--Cursor to get maximum end_date for subscriptions for the document
CURSOR get_max_end_date(c_document_id NUMBER)
IS
SELECT MAX(NVL(end_date,SYSDATE))
FROM AHL_SUBSCRIPTIONS_B
WHERE document_id = c_document_id;

--
-- Cursor is used to get requested by name given requested id
  -- Perf Fixes for 4919023
  /*
  CURSOR get_requested_name(c_requested_by_party_id NUMBER)
   IS
  SELECT party_name
    FROM ahl_hz_per_employees_v
   WHERE party_id= c_requested_by_party_id;
  */

  CURSOR get_requested_name_hz(c_requested_by_party_id NUMBER)
   IS
  SELECT PARTY_NAME
    FROM HZ_PARTIES
   WHERE party_id= c_requested_by_party_id
     AND PARTY_TYPE ='PERSON';

  CURSOR get_requested_name_ppf(c_requested_by_party_id NUMBER)
   IS
  SELECT PPF.FULL_NAME
    FROM PER_PEOPLE_F PPF, PER_PERSON_TYPES PPT
   WHERE PPF.PERSON_ID= c_requested_by_party_id
     AND TRUNC(SYSDATE) BETWEEN PPF.EFFECTIVE_START_DATE AND PPF.EFFECTIVE_END_DATE
     AND NVL(PPF.CURRENT_EMPLOYEE_FLAG, 'X') = 'Y'
     AND PPF.PERSON_TYPE_ID = PPT.PERSON_TYPE_ID
     AND PPT.SYSTEM_PERSON_TYPE ='EMP';


--
l_requested_by_party_id      NUMBER;
l_requested_by_name   VARCHAR2(301) := NULL;
l_api_name       CONSTANT VARCHAR2(30)    := 'MODIFY_SUBSCRIPTION';
l_api_version    CONSTANT NUMBER          := 1.0;
l_comments                VARCHAR2(2000);
l_msg_count               NUMBER;
l_num_rec                 NUMBER;
l_rowid                   ROWID;
l_language                VARCHAR2(4);
l_source_lang             VARCHAR2(4);
l_subscription_info       get_sub_rec_b_info%ROWTYPE;
l_old_sub_id              NUMBER;
l_dup_flag                VARCHAR2(1) := 'N';
l_prod_install_status     VARCHAR2(30);

-- Added pjha 28-Jun-2002 for bug#2438718: Begin
l_subscription_tbl subscription_tbl;
-- Added pjha 28-Jun-2002 for bug#2438718: End

-- Added pjha 28-Jun-2002 for modifying 'subscribed to' Begin
l_end_date DATE;
-- Added pjha 28-Jun-2002 for modifying 'subscribed to' End

--
 BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT modify_subscription;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.enable_debug;

    END IF;
   -- Debug info.
       IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug( 'enter ahl_di_subscription_pvt.Modify Subscription','+SUB+');
       END IF;
    -- Standard call to check for call compatibility.
   IF FND_API.to_boolean(p_init_msg_list)
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

   -- Start API Body

   -- Perf Fixes for 4919023
   BEGIN
       IF G_DEBUG='Y' THEN
         AHL_DEBUG_PUB.debug( 'Fetching Installation Status of PER','+SUB+');
       END IF;
       SELECT AHL_DI_DOC_INDEX_PVT.GET_PRODUCT_INSTALL_STATUS('PER')
         INTO l_prod_install_status
         FROM DUAL;
   END;

   IF p_x_subscription_tbl.COUNT > 0
   THEN

      FOR i IN p_x_subscription_tbl.FIRST..p_x_subscription_tbl.LAST
      LOOP
      --Enhancement nos #2034767 and #2205830: pbarman : April 2003
         IF (NVL(p_x_subscription_tbl(i).delete_flag, 'N') = 'N' )
     THEN

        -- Calling validate subscriptions
        VALIDATE_SUBSCRIPTION
         (
          p_subscription_id         => p_x_subscription_tbl(i).subscription_id,
          p_document_id             =>p_x_subscription_tbl(i).document_id,
          p_status_code             =>p_x_subscription_tbl(i).status_code,
          p_requested_by_party_id   =>p_x_subscription_tbl(i).requested_by_party_id,
          p_quantity                =>p_x_subscription_tbl(i).quantity,
          p_frequency_code          =>p_x_subscription_tbl(i).frequency_code,
          p_subscribed_frm_party_id =>p_x_subscription_tbl(i).subscribed_frm_party_id,
          p_start_date              =>p_x_subscription_tbl(i).start_date,
          p_end_date                =>p_x_subscription_tbl(i).end_date,
          p_media_type_code         =>p_x_subscription_tbl(i).media_type_code,
          p_subscription_type_code  =>p_x_subscription_tbl(i).subscription_type_code,
          p_purchase_order_no       =>p_x_subscription_tbl(i).purchase_order_no,
          p_delete_flag             =>p_x_subscription_tbl(i).delete_flag
         );



         OPEN get_old_sub (p_x_subscription_tbl(i).document_id,
                   p_x_subscription_tbl(i).requested_by_party_id);
     FETCH get_old_sub INTO l_old_sub_id;
     IF (l_old_sub_id <> p_x_subscription_tbl(i).subscription_id) THEN
        --FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUBSC_DUP_RECORD');
     FOR j IN p_x_subscription_tbl.FIRST..p_x_subscription_tbl.LAST
     LOOP
        IF ((l_old_sub_id = p_x_subscription_tbl(j).subscription_id) AND (l_old_sub_id <> p_x_subscription_tbl(i).subscription_id)) THEN
          l_dup_flag := 'Y';
          IF(p_x_subscription_tbl(i).requested_by_party_id = p_x_subscription_tbl(j).requested_by_party_id) THEN

                    -- Perf Fixes for 4919023
                    /*
                   OPEN get_requested_name(p_x_subscription_tbl(i).requested_by_party_id);
                   FETCH get_requested_name INTO l_requested_by_name;
                   CLOSE get_requested_name;
                    */

                    IF l_prod_install_status IN ('N','L') THEN
                       OPEN get_requested_name_hz(p_x_subscription_tbl(i).requested_by_party_id);
                       FETCH get_requested_name_hz INTO l_requested_by_name;
                       CLOSE get_requested_name_hz;
                    ELSIF l_prod_install_status IN ('I','S') THEN
                       OPEN get_requested_name_ppf(p_x_subscription_tbl(i).requested_by_party_id);
                       FETCH get_requested_name_ppf INTO l_requested_by_name;
                       CLOSE get_requested_name_ppf;
                    END IF;

                  FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUBS_DUP_RECORD');
                  FND_MESSAGE.SET_TOKEN('REQID',l_requested_by_name);
                  FND_MSG_PUB.ADD;
         END IF;
       END IF;
     END LOOP;
     IF (l_dup_flag = 'N') THEN
        -- Perf Fixes for 4919023
        /*
        OPEN get_requested_name(p_x_subscription_tbl(i).requested_by_party_id);
        FETCH get_requested_name INTO l_requested_by_name;
        CLOSE get_requested_name;
        */

        IF l_prod_install_status IN ('N','L') THEN
           OPEN get_requested_name_hz(p_x_subscription_tbl(i).requested_by_party_id);
           FETCH get_requested_name_hz INTO l_requested_by_name;
           CLOSE get_requested_name_hz;
        ELSIF l_prod_install_status IN ('I','S') THEN
           OPEN get_requested_name_ppf(p_x_subscription_tbl(i).requested_by_party_id);
           FETCH get_requested_name_ppf INTO l_requested_by_name;
           CLOSE get_requested_name_ppf;
        END IF;

        FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUBS_DUP_RECORD');
            FND_MESSAGE.SET_TOKEN('REQID',l_requested_by_name);
        FND_MSG_PUB.ADD;
     END IF;
     l_dup_flag := 'N';
     END IF;
     CLOSE get_old_sub;
     END IF;
      END LOOP;
   --End of Validations
   -- Standard call to get message count
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   --Start of API Body
   FOR i IN p_x_subscription_tbl.FIRST..p_x_subscription_tbl.LAST
   LOOP
      --Retrieve the existing subscription record for passed subscription id
      OPEN get_sub_rec_b_info(p_x_subscription_tbl(i).subscription_id);
      FETCH get_sub_rec_b_info INTO l_subscription_info;
      CLOSE get_sub_rec_b_info;
      --Retrieves the existing tranlation record
      OPEN get_sub_rec_tl_info(p_x_subscription_tbl(i).subscription_id);
      FETCH get_sub_rec_tl_info INTO l_rowid,
                                     l_comments;
      CLOSE get_sub_rec_tl_info;

 --This is a fix  for  earlier bug when concurrent users are
 -- updating same record...02/05/02
    if (l_subscription_info.object_version_number <>p_x_subscription_tbl(i).object_version_number)
    then
        FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    end if;
      -- The following conditions compare the new record value with old  record
      -- value, if its different then assign the new value else continue
      IF p_x_subscription_tbl(i).subscription_id IS NOT NULL
      THEN
             l_subscription_info.status_code := p_x_subscription_tbl(i).status_code;
            l_subscription_info.requested_by_party_id := p_x_subscription_tbl(i).requested_by_party_id;
             l_subscription_info.quantity := p_x_subscription_tbl(i).quantity;
            l_subscription_info.frequency_code := p_x_subscription_tbl(i).frequency_code;
            l_subscription_info.subscribed_frm_party_id := p_x_subscription_tbl(i).subscribed_frm_party_id;
            l_subscription_info.start_date := p_x_subscription_tbl(i).start_date;
            l_subscription_info.end_date := p_x_subscription_tbl(i).end_date;
            l_subscription_info.purchase_order_no := p_x_subscription_tbl(i).purchase_order_no;
            l_subscription_info.media_type_code := p_x_subscription_tbl(i).media_type_code;
            l_subscription_info.subscription_type_code := p_x_subscription_tbl(i).subscription_type_code;
            l_comments := p_x_subscription_tbl(i).comments;
            l_subscription_info.attribute_category := p_x_subscription_tbl(i).attribute_category;
            l_subscription_info.attribute1 := p_x_subscription_tbl(i).attribute1;
            l_subscription_info.attribute2 := p_x_subscription_tbl(i).attribute2;
            l_subscription_info.attribute3 := p_x_subscription_tbl(i).attribute3;
            l_subscription_info.attribute3 := p_x_subscription_tbl(i).attribute3;
            l_subscription_info.attribute4 := p_x_subscription_tbl(i).attribute4;
            l_subscription_info.attribute5 := p_x_subscription_tbl(i).attribute5;
            l_subscription_info.attribute6 := p_x_subscription_tbl(i).attribute6;
            l_subscription_info.attribute7 := p_x_subscription_tbl(i).attribute7;
            l_subscription_info.attribute8 := p_x_subscription_tbl(i).attribute8;
            l_subscription_info.attribute9 := p_x_subscription_tbl(i).attribute9;
            l_subscription_info.attribute10 := p_x_subscription_tbl(i).attribute10;
            l_subscription_info.attribute11 := p_x_subscription_tbl(i).attribute11;
            l_subscription_info.attribute12 := p_x_subscription_tbl(i).attribute12;
            l_subscription_info.attribute13 := p_x_subscription_tbl(i).attribute13;
            l_subscription_info.attribute14 := p_x_subscription_tbl(i).attribute14;
            l_subscription_info.attribute15 := p_x_subscription_tbl(i).attribute15;

/*-------------------------------------------------------- */
/* procedure name: AHL_SUBSCRIPTIONS_PKG.UPDATE_ROW        */
/* description   :  Added by Senthil to call Table Handler */
/*      Date     : Dec 31 2001                             */
/*---------------------------------------------------------*/
         -- Updates subscriptions record and tranlation table
         --Enhancement nos #2034767 and #2205830: pbarman : April 2003
          IF (p_x_subscription_tbl(i).subscription_id IS NOT NULL AND
                      NVL(p_x_subscription_tbl(i).delete_flag, 'N') = 'N' )
     THEN
     AHL_SUBSCRIPTIONS_PKG.UPDATE_ROW (
          X_SUBSCRIPTION_ID         => p_x_subscription_tbl(i).subscription_id,
          X_ATTRIBUTE5          => l_subscription_info.attribute5,
          X_DOCUMENT_ID         => l_subscription_info.document_id,
          X_REQUESTED_BY_PARTY_ID   => l_subscription_info.requested_by_party_id,
          X_ATTRIBUTE6          => l_subscription_info.attribute6,
          X_ATTRIBUTE7          => l_subscription_info.attribute7,
          X_ATTRIBUTE8          => l_subscription_info.attribute8,
          X_ATTRIBUTE9          => l_subscription_info.attribute9,
          X_ATTRIBUTE10         => l_subscription_info.attribute10,
          X_ATTRIBUTE11         => l_subscription_info.attribute11,
          X_ATTRIBUTE12         => l_subscription_info.attribute12,
          X_ATTRIBUTE13         => l_subscription_info.attribute13,
          X_ATTRIBUTE14         => l_subscription_info.attribute14,
          X_ATTRIBUTE_CATEGORY      => l_subscription_info.attribute_category,
          X_ATTRIBUTE1          => l_subscription_info.attribute1,
          X_ATTRIBUTE2          => l_subscription_info.attribute2,
          X_ATTRIBUTE3          => l_subscription_info.attribute3,
          X_ATTRIBUTE4          => l_subscription_info.attribute4,
          X_OBJECT_VERSION_NUMBER   => l_subscription_info.object_version_number+1,
          X_ATTRIBUTE15         => l_subscription_info.attribute15,
          X_SUBSCRIBED_FRM_PARTY_ID     => l_subscription_info.subscribed_frm_party_id,
          X_QUANTITY            => l_subscription_info.quantity,
          X_STATUS_CODE         => l_subscription_info.status_code,
          X_PURCHASE_ORDER_NO       => l_subscription_info.purchase_order_no,
          X_FREQUENCY_CODE      => l_subscription_info.frequency_code,
          X_SUBSCRIPTION_TYPE_CODE  => l_subscription_info.subscription_type_code,
          X_MEDIA_TYPE_CODE         => l_subscription_info.media_type_code,
          X_START_DATE          => l_subscription_info.start_date,
          X_END_DATE            => l_subscription_info.end_date,
          X_COMMENTS            => l_comments,
          X_LAST_UPDATE_DATE        => sysdate,
          X_LAST_UPDATED_BY         => fnd_global.user_id,
          X_LAST_UPDATE_LOGIN       => fnd_global.login_id
        );
/*
         -- Updates subscriptions record


          UPDATE AHL_SUBSCRIPTIONS_B
             SET document_id             = l_subscription_info.document_id,
                 status_code             = l_subscription_info.status_code,
                 requested_by_party_id   = l_subscription_info.requested_by_party_id,
                 quantity                = l_subscription_info.quantity,
                 frequency_code          = l_subscription_info.frequency_code,
                 subscribed_frm_party_id =l_subscription_info.subscribed_frm_party_id,
                 start_date              = l_subscription_info.start_date,
                 end_date                = l_subscription_info.end_date,
                 purchase_order_no       = l_subscription_info.purchase_order_no,
                 subscription_type_code  = l_subscription_info.subscription_type_code,
                 media_type_code         = l_subscription_info.media_type_code,
                 object_version_number   = l_subscription_info.object_version_number+1,
                 attribute_category      = l_subscription_info.attribute_category,
                 attribute1              = l_subscription_info.attribute1,
                 attribute2              = l_subscription_info.attribute2,
                 attribute3              = l_subscription_info.attribute3,
                 attribute4              = l_subscription_info.attribute4,
                 attribute5              = l_subscription_info.attribute5,
                 attribute6              = l_subscription_info.attribute6,
                 attribute7              = l_subscription_info.attribute7,
                 attribute8              = l_subscription_info.attribute8,
                 attribute9              = l_subscription_info.attribute9,
                 attribute10             = l_subscription_info.attribute10,
                 attribute11             = l_subscription_info.attribute11,
                 attribute12             = l_subscription_info.attribute12,
                 attribute13             = l_subscription_info.attribute13,
                 attribute14             = l_subscription_info.attribute14,
                 attribute15             = l_subscription_info.attribute15,
                 last_update_date        = sysdate,
                 last_updated_by         = fnd_global.user_id,
                 last_update_login       = fnd_global.login_id
         WHERE   subscription_id      = p_x_subscription_tbl(i).subscription_id;
         --Update the tranlation table
               UPDATE AHL_SUBSCRIPTIONS_TL
                  SET comments          = l_comments,
                      last_update_date  = sysdate,
                      last_updated_by   = fnd_global.user_id,
                      last_update_login = fnd_global.login_id
               WHERE SUBSCRIPTION_ID    = p_x_subscription_tbl(i).subscription_id
                 AND userenv('LANG') in (LANGUAGE, SOURCE_LANG);


*/
     -- Incase of delte a subscription record set the end date,
     -- At this point we are not using delete subscriptions

     -- Modified pjha 28-Jun-2002 for modifying 'subscribed to' Begin

                   --Check if the document is subscribed and then update accordingly
                   OPEN get_max_end_date(p_x_subscription_tbl(i).document_id);
                   FETCH get_max_end_date INTO l_end_date;
                   --Modified pjha 09-Jul-2002 for fixing bug#2452714: Begin
                   IF (l_end_date IS NULL OR get_max_end_date%NOTFOUND OR l_end_date < TRUNC(sysdate)) THEN
                   --IF (get_max_end_date%NOTFOUND OR l_end_date < TRUNC(sysdate)) THEN
                   --Modified pjha 09-Jul-2002 for fixing bug#2452714: End
                     UPDATE AHL_DOCUMENTS_B
             SET subscribe_to_flag = 'N'
                     WHERE document_id = p_x_subscription_tbl(i).document_id;
                   ELSE
                     UPDATE AHL_DOCUMENTS_B
             SET subscribe_to_flag = 'Y'
                     WHERE document_id = p_x_subscription_tbl(i).document_id;
                   END IF;
                   CLOSE get_max_end_date;

      END IF;
      -- Modified pjha 28-Jun-2002 for modifying 'subscribed to' End

      END IF;

      IF (p_x_subscription_tbl(i).subscription_id IS NOT NULL AND
                NVL(p_x_subscription_tbl(i).delete_flag, 'N') = 'Y' )

        THEN
           -- Added pjha 28-Jun-2002 for bug#2438718: Begin
           l_subscription_tbl(1).subscription_id := p_x_subscription_tbl(i).subscription_id;
           DELETE_SUBSCRIPTION
           (
            p_api_version        => 1.0                        ,
            p_init_msg_list      => FND_API.G_TRUE             ,
            p_commit             => FND_API.G_FALSE            ,
            p_validate_only      => FND_API.G_TRUE             ,
            p_validation_level   => FND_API.G_VALID_LEVEL_FULL ,
            p_x_subscription_tbl =>  l_subscription_tbl      ,
            x_return_status      => x_return_status            ,
            x_msg_count          => x_msg_count                ,
            x_msg_data           => x_msg_data);

          -- Added pjha 28-Jun-2002 for bug#2438718: End


       -- Modified pjha 28-Jun-2002 for modifying 'subscribed to' Begin

       --Check if the document is subscribed and then update accordingly

           OPEN get_max_end_date(p_x_subscription_tbl(i).document_id);
       FETCH get_max_end_date INTO l_end_date;
       --Modified pjha 09-Jul-2002 for fixing bug#2452714: Begin
       IF (l_end_date IS NULL OR get_max_end_date%NOTFOUND OR l_end_date < TRUNC(sysdate)) THEN
       --IF (get_max_end_date%NOTFOUND OR l_end_date < TRUNC(sysdate)) THEN
       --Modified pjha 09-Jul-2002 for fixing bug#2452714: End
          UPDATE AHL_DOCUMENTS_B
          SET subscribe_to_flag = 'N'
          WHERE document_id = p_x_subscription_tbl(i).document_id;
       ELSE
          UPDATE AHL_DOCUMENTS_B
          SET subscribe_to_flag = 'Y'
          WHERE document_id = p_x_subscription_tbl(i).document_id;
       END IF;
       CLOSE get_max_end_date;




      -- Modified pjha 28-Jun-2002 for modifying 'subscribed to' End

      END IF;
   END LOOP;
 END IF;
    -- Standard check of p_commit.
   IF FND_API.TO_BOOLEAN(p_commit) THEN
       COMMIT;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug( 'End of private api Modify Subscription','+SUB+');

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
            AHL_DEBUG_PUB.debug( 'ahl_di_subscription_pvt.Modify Subscription','+SUB+');


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
            AHL_DEBUG_PUB.debug( 'ahl_di_subscription_pvt.Modify Subscription','+SUB+');


        -- Check if API is called in debug mode. If yes, disable debug.
           AHL_DEBUG_PUB.disable_debug;

    END IF;

 WHEN OTHERS THEN
    ROLLBACK TO modify_subscription;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_SUBSCRIPTION_PVT',
                            p_procedure_name  =>  'MODIFY_SUBSCRIPTION',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_subscription_pvt.Modify Subscription','+SUB+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

    END IF;

END MODIFY_SUBSCRIPTION;
/*-------------------------------------------------------*/
/* procedure name: delete_subscription                   */
/* description :we are not using this procedure, probably*/
/*               next phase                              */
/*                                                       */
/*-------------------------------------------------------*/


PROCEDURE DELETE_SUBSCRIPTION
(
 p_api_version                IN     NUMBER    := 1.0               ,
 p_init_msg_list              IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                     IN     VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only              IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level           IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_subscription_tbl         IN OUT NOCOPY subscription_tbl          ,
 x_return_status                 OUT NOCOPY VARCHAR2                         ,
 x_msg_count                     OUT NOCOPY NUMBER                           ,
 x_msg_data                      OUT NOCOPY VARCHAR2
)
IS

CURSOR get_sub_rec_b_info(c_subscription_id  NUMBER)
IS
SELECT ROWID,
       start_date,
       end_date,
       object_version_number
FROM AHL_SUBSCRIPTIONS_B
WHERE subscription_id = c_subscription_id
  FOR UPDATE OF object_version_number NOWAIT;

l_api_name     CONSTANT VARCHAR2(30) := 'DELETE_SUBSCRIPTION';
l_api_version  CONSTANT NUMBER       := 1.0;
l_rowid                 ROWID;
l_object_version_number NUMBER;
l_end_date              DATE;
l_start_date            DATE;
BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT delete_subscriptions;
    -- Standard call to check for call compatibility.
   IF FND_API.to_boolean(p_init_msg_list)
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
   IF p_x_subscription_tbl.COUNT > 0
   THEN
      FOR i IN p_x_subscription_tbl.FIRST..p_x_subscription_tbl.LAST
      LOOP
         OPEN get_sub_rec_b_info(p_x_subscription_tbl(i).subscription_id);
         FETCH get_sub_rec_b_info INTO l_rowid,
                                       l_start_date,
                                       l_end_date,
                                       l_object_version_number;

         IF (get_sub_rec_b_info%NOTFOUND)
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUB_RECORD_NOT_EXISTS');
            FND_MSG_PUB.ADD;
         END IF;
         CLOSE get_sub_rec_b_info;
         /* No need, it's done in modify document
         -- Check for version number
        IF (l_object_version_number <> p_x_subscription_tbl(i).object_version_number)
        THEN
           FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUB_RECORD_CHANGED');
           FND_MSG_PUB.ADD;
        END IF;
        */
        -- Validate with end date
        /* Not required, user should be able to delete subscriptions
        after they have become obsolete: pjha 09-Jul-2002
        IF (l_end_date IS NOT NULL AND l_end_date < sysdate )
        THEN
           FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUB_RECORD_CLOSED');
           FND_MSG_PUB.ADD;
        END IF;
        */
        /* Not required
        -- Check for start date
        IF l_start_date IS NULL
        THEN
           FND_MESSAGE.SET_NAME('AHL','AHL_DI_START_DATE_INVALID');
           FND_MSG_PUB.ADD;
        END IF;

        --Check for End Date
        IF (TRUNC(NVL(l_end_date, SYSDATE)) >
           TRUNC(NVL(p_x_subscription_tbl(i).end_date,SYSDATE)))
        THEN
           FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUB_E_DATE_INVALID');
           FND_MSG_PUB.ADD;
        END IF;
        */
        -- Update the end date in subscriptions table
        -- Modified pjha 15-May-2002 for modifying 'subscribed to' Begin


        -- Modified pjha 14-Jun-2002 for deleting the row: Begin
        AHL_SUBSCRIPTIONS_PKG.DELETE_ROW(
        X_SUBSCRIPTION_ID => p_x_subscription_tbl(i).subscription_id);


        /*
        UPDATE AHL_SUBSCRIPTIONS_B
                 SET END_DATE = sysdate
        WHERE ROWID = l_rowid;
        */

        -- Modified pjha 14-Jun-2002 for deleting the row: End
      END LOOP;
        -- Modified pjha 15-May-2002 for modifying 'subscribed to' End
 END IF;
    -- Standard check of p_commit.
    IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT;
    END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO delete_subscription;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO delete_subscription;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
 WHEN OTHERS THEN
    ROLLBACK TO delete_subscription;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_SUBSCRIPTION_PVT',
                            p_procedure_name  =>  'DELETE_SUBSCRIPTION',
                            p_error_text      =>   SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

END DELETE_SUBSCRIPTION;

END AHL_DI_SUBSCRIPTION_PVT;

/
