--------------------------------------------------------
--  DDL for Package Body AHL_DI_DOC_INDEX_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_DI_DOC_INDEX_PUB" AS
/* $Header: AHLPDIXB.pls 120.1 2006/02/07 03:51:04 sagarwal noship $ */
--
G_PKG_NAME  VARCHAR2(30)  := 'AHL_DI_DOC_INDEX_PUB';
--
/*-----------------------------------------------------------*/
/* procedure name: Check_lookup_name_Or_Id(private procedure)*/
/* description :  used to retrieve lookup code               */
/*                                                           */
/*-----------------------------------------------------------*/

PROCEDURE Check_lookup_name_Or_Id
 ( p_lookup_type      IN FND_LOOKUPS.lookup_type%TYPE,
   p_lookup_code      IN FND_LOOKUPS.lookup_code%TYPE,
   p_meaning          IN FND_LOOKUPS.meaning%TYPE,
   p_check_id_flag    IN VARCHAR2,
   x_lookup_code      OUT NOCOPY VARCHAR2,
   x_return_status    OUT NOCOPY VARCHAR2)
IS


BEGIN
      IF (p_lookup_code IS NOT NULL) THEN
        IF (p_check_id_flag = 'Y') THEN
          SELECT lookup_code INTO x_lookup_code
           FROM FND_LOOKUP_VALUES_VL
          WHERE lookup_type = p_lookup_type
            AND lookup_code = p_lookup_code
            AND ENABLED_FLAG= 'Y'
            AND sysdate between nvl(start_date_active,sysdate)
            AND nvl(end_date_active,sysdate);
        ELSE
           x_lookup_code := p_lookup_code;
        END IF;
     ELSE
          SELECT lookup_code INTO x_lookup_code
           FROM FND_LOOKUP_VALUES_VL
          WHERE lookup_type = p_lookup_type
            AND upper(meaning)     = upper(p_meaning)
        AND ENABLED_FLAG= 'Y'
            AND sysdate between nvl(start_date_active,sysdate)
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
/* procedure name: create_document                      */
/* description :  Creates new document record and its   */
/*                associated suppliers, recipients,     */
/*                subscriptions,revision and copies     */
/*                                                      */
/*------------------------------------------------------*/

PROCEDURE CREATE_DOCUMENT
 (
 p_api_version               IN     NUMBER    := '1.0'               ,
 p_init_msg_list             IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                    IN     VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only             IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level          IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_document_tbl            IN OUT NOCOPY Document_Tbl              ,
-- p_x_doc_rev_tbl             IN OUT NOCOPY AHL_DI_DOC_REVISION_PUB.Revision_Tbl ,
-- p_x_doc_rev_copy_tbl        IN OUT NOCOPY AHL_DI_DOC_REVISION_PUB.Revision_Copy_Tbl,
-- p_x_subscription_tbl        IN OUT NOCOPY AHL_DI_SUBSCRIPTION_PUB.Subscription_Tbl,
 p_x_supplier_tbl            IN OUT NOCOPY Supplier_Tbl              ,
 p_x_recipient_tbl           IN OUT NOCOPY Recipient_Tbl             ,
 p_module_type               IN     VARCHAR2                         ,
 x_return_status                OUT NOCOPY VARCHAR2                         ,
 x_msg_count                    OUT NOCOPY NUMBER                           ,
 x_msg_data                     OUT NOCOPY VARCHAR2)
 IS
-- Used to retrieve the party id for passed meaning
CURSOR for_party_name(c_party_number  IN VARCHAR2)
IS
  SELECT party_id
   FROM hz_parties
 WHERE party_number = c_party_number;
 -- Used to retrieve party id for passed id
 CURSOR for_party_id(c_party_id  IN NUMBER)
 IS
  SELECT party_id
   FROM hz_parties
 WHERE party_id = c_party_id;
 -- Used to retrieve vendor id from po vendors
 CURSOR for_vendor_id(c_segment1  IN VARCHAR2)
 IS
  SELECT vendor_id
   FROM po_vendors
 WHERE segment1 = c_segment1;

 --Enhancement #2275357: pbarman 1st April 2003
 --Cursor to retrieve operator code from hz parties
 CURSOR get_operator_name_hz(c_operator_name VARCHAR2)
     IS
    SELECT party_id
    FROM HZ_PARTIES
    WHERE upper(party_name) = upper(c_operator_name)
    AND ( party_type ='ORGANIZATION' or party_type = 'PERSON' );

    -- For Bug Fix #3446159
    CURSOR get_operator_name_hz_id(c_operator_name VARCHAR2, c_operator_id NUMBER)
     IS
    SELECT party_id
    FROM HZ_PARTIES
    WHERE upper(party_name) = upper(c_operator_name)
                AND party_id = c_operator_id
    AND ( party_type ='ORGANIZATION' or party_type = 'PERSON' );


 --
 l_api_name        CONSTANT VARCHAR2(30) := 'CREATE_DOCUMENT';
 l_api_version     CONSTANT NUMBER       := 1.0;
 l_num_rec                  NUMBER;
 l_msg_count                NUMBER;
 l_msg_data                 VARCHAR2(2000);
 l_return_status            VARCHAR2(1);
 l_source_party_id          NUMBER;
 l_supplier_id              NUMBER;
 l_recipient_id             NUMBER;
 l_recipient_party_id       NUMBER;
 l_requested_by_party_id    NUMBER;
 l_approved_by_party_id     NUMBER;
 l_received_by_party_id     NUMBER;
 l_doc_type_code            VARCHAR2(30);
 l_doc_sub_type_code        VARCHAR2(30);
 l_preference_code          VARCHAR2(30);
 l_status_code              VARCHAR2(30);
 l_media_type_code          VARCHAR2(30);
 l_frequency_code           VARCHAR2(30);
 l_subscription_type_code   VARCHAR2(30);
 l_revision_type_code       VARCHAR2(30);
 l_revision_status_code     VARCHAR2(30);
 l_copy_type_code           VARCHAR2(30);
 l_operator_code            VARCHAR2(30);
 l_product_type_code        VARCHAR2(30);
 l_document_tbl             AHL_DI_DOC_INDEX_PVT.document_tbl;
-- l_revision_tbl             AHL_DI_DOC_REVISION_PVT.revision_tbl;
-- l_revision_copy_tbl        AHL_DI_DOC_REVISION_PVT.revision_copy_tbl;
-- l_subscription_tbl         AHL_DI_SUBSCRIPTION_PVT.subscription_tbl;
 l_supplier_tbl             AHL_DI_DOC_INDEX_PVT.supplier_tbl;
 l_recipient_tbl            AHL_DI_DOC_INDEX_PVT.recipient_tbl;
 l_init_msg_list          VARCHAR2(10) := FND_API.G_TRUE;


BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT create_document;
   -- Check if API is called in debug mode. If yes, enable debug.
   AHL_DEBUG_PUB.enable_debug;
   -- Debug info.
   IF AHL_DEBUG_PUB.G_FILE_DEBUG THEN
       AHL_DEBUG_PUB.debug( 'enter ahl_di_doc_index_pub.Create Document','+DI+');
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
   --  Start of API Body
   IF p_x_document_tbl.COUNT > 0
   THEN
      FOR i IN p_x_document_tbl.FIRST..p_x_document_tbl.LAST
      LOOP
         --Process flag is 'D' i.e Create Document
         IF p_x_document_tbl(i).process_flag = 'D'
         THEN
            -- Module type is 'JSP' then make it null for the following fields
            IF (p_module_type = 'JSP') THEN
                p_x_document_tbl(i).source_party_id := null;
                p_x_document_tbl(i).product_type_code := null;
            END IF;
            --For Source by Party Id
            IF (p_x_document_tbl(i).source_party_id IS NULL) OR
               (p_x_document_tbl(i).source_party_id = FND_API.G_MISS_NUM)
            THEN
            -- If Party Name is available
            IF (p_x_document_tbl(i).source_party_number IS NOT NULL) AND
               (p_x_document_tbl(i).source_party_number <> FND_API.G_MISS_CHAR)
              THEN
                 OPEN  for_party_name(p_x_document_tbl(i).source_party_number);
                 FETCH for_party_name INTO l_source_party_id;
                 IF for_party_name%FOUND
                 THEN
                     l_document_tbl(i).source_party_id := l_source_party_id;
                 ELSE
                   FND_MESSAGE.SET_NAME('AHL','AHL_DI_SOURCE_ID_NOT_EXISTS');
                   FND_MSG_PUB.ADD;
                 END IF;
                 CLOSE for_party_name;
            ELSE
              --Both Party Id and Name are missing
               FND_MESSAGE.SET_NAME('AHL','AHL_DI_SOURCE_PARTY_ID_NULL');
               FND_MSG_PUB.ADD;
            END IF;
           --Check for If ID present
         ELSIF (p_x_document_tbl(i).source_party_id IS NOT NULL AND
               p_x_document_tbl(i).source_party_id <> FND_API.G_MISS_NUM)
               THEN
                 OPEN  for_party_id(p_x_document_tbl(i).source_party_id);
                 FETCH for_party_id INTO l_document_tbl(i).source_party_id;
                 IF for_party_id%FOUND
                   THEN
                     l_document_tbl(i).source_party_id := p_x_document_tbl(i).source_party_id;
                  ELSE
                   FND_MESSAGE.SET_NAME('AHL','AHL_DI_SOURCE_ID_INVALID');
                   FND_MSG_PUB.ADD;
                  END IF;
                  CLOSE for_party_id;
         END IF;

         --For Operator Code, Meaning presnts
         IF p_x_document_tbl(i).operator_name IS NOT NULL AND
            p_x_document_tbl(i).operator_name <> FND_API.G_MISS_CHAR
         THEN
    -- Check if operator name and id match
    OPEN get_operator_name_hz_id(p_x_document_tbl(i).operator_name, TO_NUMBER(p_x_document_tbl(i).operator_code));

    FETCH get_operator_name_hz_id INTO l_document_tbl(i).operator_code;
    IF get_operator_name_hz_id%NOTFOUND THEN
    -- the operator name has been changed

         --Enhancement #2275357: pbarman 1st April 2003
          CLOSE get_operator_name_hz_id;
          OPEN get_operator_name_hz(p_x_document_tbl(i).operator_name);
      LOOP
          FETCH get_operator_name_hz INTO l_document_tbl(i).operator_code;
      EXIT WHEN get_operator_name_hz%NOTFOUND;
      END LOOP;


      IF get_operator_name_hz%ROWCOUNT = 0
      THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_DI_OPERATOR_CODE_NOT_EXIST');
      FND_MSG_PUB.ADD;
      ELSIF get_operator_name_hz%ROWCOUNT > 1
      THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_DI_OPERATOR_USE_LOV');
      FND_MSG_PUB.ADD;
          END IF;
      CLOSE get_operator_name_hz;
        END IF;

         END IF;

        --For Product type Code, Meaning presnts
         IF p_x_document_tbl(i).product_type_desc IS NOT NULL AND
            p_x_document_tbl(i).product_type_desc <> FND_API.G_MISS_CHAR
         THEN
             Check_lookup_name_Or_Id (
             --Enhancement #2525604 pbarman : April 2003
                  p_lookup_type  => 'ITEM_TYPE',
                  p_lookup_code  => null,
                  p_meaning      => p_x_document_tbl(i).product_type_desc,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_document_tbl(i).product_type_code,
                  x_return_status => l_return_status);

         IF nvl(l_return_status, 'X') <> 'S'
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_PRODTYPE_CODE_NOT_EXIST');
            FND_MSG_PUB.ADD;
         END IF;

        --ID presntes
         ELSIF p_x_document_tbl(i).product_type_code IS NOT NULL AND
            p_x_document_tbl(i).product_type_code <> FND_API.G_MISS_CHAR
         THEN
          l_document_tbl(i).product_type_code := p_x_document_tbl(i).product_type_code;
          --Both missing
         ELSE
          l_document_tbl(i).product_type_code := p_x_document_tbl(i).product_type_code;
         END IF;

         --For Doc Type Code
         IF p_x_document_tbl(i).doc_type_desc IS NOT NULL AND
            p_x_document_tbl(i).doc_type_desc <> FND_API.G_MISS_CHAR
         THEN
             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_DOC_TYPE',
                  p_lookup_code  => null,
                  p_meaning      => p_x_document_tbl(i).doc_type_desc,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_document_tbl(i).doc_type_code,
                  x_return_status => l_return_status);

         IF nvl(l_return_status, 'X') <> 'S'
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_TYPE_CODE_NOT_EXIST');
            FND_MSG_PUB.ADD;
         END IF;
        END IF;
        -- Id presents
         IF p_x_document_tbl(i).doc_type_code IS NOT NULL AND
            p_x_document_tbl(i).doc_type_code <> FND_API.G_MISS_CHAR
         THEN
           l_document_tbl(i).doc_type_code := p_x_document_tbl(i).doc_type_code;
        ELSE
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_TYPE_CODE_NOT_EXIST');
            FND_MSG_PUB.ADD;
        END IF;

        --For Doc Sub Type Code, meaning presents
         IF p_x_document_tbl(i).doc_sub_type_desc IS NOT NULL AND
            p_x_document_tbl(i).doc_sub_type_desc <> FND_API.G_MISS_CHAR
         THEN

             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_DOC_SUB_TYPE_CODE',
                  p_lookup_code  => null,
                  p_meaning      => p_x_document_tbl(i).doc_sub_type_desc,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_document_tbl(i).doc_sub_type_code,
                  x_return_status => l_return_status);

         IF nvl(l_return_status, 'X') <> 'S'
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_SUBT_COD_NOT_EXISTS');
            FND_MSG_PUB.ADD;
         END IF;
        END IF;
        --Id presents
         IF p_x_document_tbl(i).doc_sub_type_code IS NOT NULL AND
            p_x_document_tbl(i).doc_sub_type_code <> FND_API.G_MISS_CHAR
         THEN
           l_document_tbl(i).doc_sub_type_code := p_x_document_tbl(i).doc_sub_type_code;
        ELSE
           l_document_tbl(i).doc_sub_type_code := p_x_document_tbl(i).doc_sub_type_code;
        END IF;


        --

        l_document_tbl(i).document_id          := p_x_document_tbl(i).document_id;
        l_document_tbl(i).document_no          := p_x_document_tbl(i).document_no;
        l_document_tbl(i).subscribe_avail_flag := p_x_document_tbl(i).subscribe_avail_flag;
        l_document_tbl(i).subscribe_to_flag    := p_x_document_tbl(i).subscribe_to_flag;
        l_document_tbl(i).document_title       := p_x_document_tbl(i).document_title;
        l_document_tbl(i).language             := p_x_document_tbl(i).language;
        l_document_tbl(i).source_lang          := p_x_document_tbl(i).source_lang;
        l_document_tbl(i).attribute_category   := p_x_document_tbl(i).attribute_category;
        l_document_tbl(i).attribute1           := p_x_document_tbl(i).attribute1;
        l_document_tbl(i).attribute2           := p_x_document_tbl(i).attribute2;
        l_document_tbl(i).attribute3           := p_x_document_tbl(i).attribute3;
        l_document_tbl(i).attribute4           := p_x_document_tbl(i).attribute4;
        l_document_tbl(i).attribute5           := p_x_document_tbl(i).attribute5;
        l_document_tbl(i).attribute6           := p_x_document_tbl(i).attribute6;
        l_document_tbl(i).attribute7           := p_x_document_tbl(i).attribute7;
        l_document_tbl(i).attribute8           := p_x_document_tbl(i).attribute8;
        l_document_tbl(i).attribute9           := p_x_document_tbl(i).attribute9;
        l_document_tbl(i).attribute10          := p_x_document_tbl(i).attribute10;
        l_document_tbl(i).attribute11          := p_x_document_tbl(i).attribute11;
        l_document_tbl(i).attribute12          := p_x_document_tbl(i).attribute12;
        l_document_tbl(i).attribute13          := p_x_document_tbl(i).attribute13;
        l_document_tbl(i).attribute14          := p_x_document_tbl(i).attribute14;
        l_document_tbl(i).attribute15          := p_x_document_tbl(i).attribute15;
        l_document_tbl(i).delete_flag          := p_x_document_tbl(i).delete_flag;
        l_document_tbl(i).object_version_number := p_x_document_tbl(i).object_version_number;

   --Standard check to count messages
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
   -- Debug info.
   IF AHL_DEBUG_PUB.G_FILE_DEBUG THEN
       AHL_DEBUG_PUB.debug( 'Before processing Supplier Record ahl_di_doc_index_pub.create_document','+DI+');
    END IF;
   --For Supplier Record, If the process flag is 'S' i.e Create Supplier
   ELSIF p_x_document_tbl(i).process_flag = 'S'
   THEN
   --For Supplier Id
   IF p_x_supplier_tbl.COUNT > 0
   THEN
       FOR i IN p_x_supplier_tbl.FIRST..p_x_supplier_tbl.LAST
       LOOP
       IF (p_x_supplier_tbl(i).supplier_id IS NULL) OR
          (p_x_supplier_tbl(i).supplier_id = FND_API.G_MISS_NUM) THEN
          -- If Supplier Name is available
       IF (p_x_supplier_tbl(i).supplier_number IS NOT NULL) AND
          (p_x_supplier_tbl(i).supplier_number <> FND_API.G_MISS_CHAR)
        THEN
         IF ahl_di_doc_index_pvt.get_product_install_status('PO') IN ('N','L')
         THEN
              OPEN  for_party_name(p_x_supplier_tbl(i).supplier_number);
              FETCH for_party_name INTO l_supplier_id;
                 IF for_party_name%FOUND
                 THEN
                     l_supplier_tbl(i).supplier_id := l_supplier_id;
                 ELSE
                   FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUPPL_ID_NOT_EXIST');
                   FND_MESSAGE.SET_TOKEN('SUPNAME',p_x_supplier_tbl(i).supplier_number);
                   FND_MSG_PUB.ADD;
                 END IF;
              CLOSE for_party_name;
            ELSIF ahl_di_doc_index_pvt.get_product_install_status('PO') IN ('I','S')
         THEN
              OPEN  for_vendor_id(p_x_supplier_tbl(i).supplier_number);
              FETCH for_vendor_id INTO l_supplier_id;
                 IF for_vendor_id%FOUND
                 THEN
                     l_supplier_tbl(i).supplier_id := l_supplier_id;
                 ELSE
                   FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUPPL_ID_NOT_EXIST');
                   FND_MESSAGE.SET_TOKEN('SUPNAME',p_x_supplier_tbl(i).supplier_number);
                   FND_MSG_PUB.ADD;
                 END IF;
              CLOSE for_vendor_id;
            END IF;
           --Id presents
        ELSIF (p_x_supplier_tbl(i).supplier_id IS NOT NULL) AND
              (p_x_supplier_tbl(i).supplier_id <> FND_API.G_MISS_NUM)
              THEN
             l_supplier_tbl(i).supplier_id := p_x_supplier_tbl(i).supplier_id;
         ELSE
              --Both Supplier Id and Name are missing
               FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUPPL_ID_NOT_EXIST');
               FND_MESSAGE.SET_TOKEN('SUPNAME',p_x_supplier_tbl(i).supplier_number);
               FND_MSG_PUB.ADD;
         END IF;
      END IF;
      -- For Preference Code, meaning presents
      IF p_x_supplier_tbl(i).preference_desc IS NOT NULL AND
         p_x_supplier_tbl(i).preference_desc <> FND_API.G_MISS_CHAR
         THEN

             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_SUPPLIER_PREF_TYPE',
                  p_lookup_code  => null,
                  p_meaning      => p_x_supplier_tbl(i).preference_desc,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_supplier_tbl(i).preference_code,
                  x_return_status => l_return_status);

         IF nvl(l_return_status, 'X') <> 'S'
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUPPLIER_PREF_TYPE');
            FND_MSG_PUB.ADD;
         END IF;
      END IF;
      -- Pref Code presents
      IF p_x_supplier_tbl(i).preference_code IS NOT NULL AND
         p_x_supplier_tbl(i).preference_code <> FND_API.G_MISS_CHAR
         THEN
          l_supplier_tbl(i).preference_code := p_x_supplier_tbl(i).preference_code;
       ELSE
       --Both missing
          l_supplier_tbl(i).preference_code := p_x_supplier_tbl(i).preference_code;
      END IF;

        l_supplier_tbl(i).supplier_document_id     := p_x_supplier_tbl(i).supplier_document_id;
        l_supplier_tbl(i).document_id              := p_x_supplier_tbl(i).document_id;
        l_supplier_tbl(i).attribute_category       := p_x_supplier_tbl(i).attribute_category;
        l_supplier_tbl(i).attribute1               := p_x_supplier_tbl(i).attribute1;
        l_supplier_tbl(i).attribute2               := p_x_supplier_tbl(i).attribute2;
        l_supplier_tbl(i).attribute3               := p_x_supplier_tbl(i).attribute3;
        l_supplier_tbl(i).attribute4               := p_x_supplier_tbl(i).attribute4;
        l_supplier_tbl(i).attribute5               := p_x_supplier_tbl(i).attribute5;
        l_supplier_tbl(i).attribute6               := p_x_supplier_tbl(i).attribute6;
        l_supplier_tbl(i).attribute7               := p_x_supplier_tbl(i).attribute7;
        l_supplier_tbl(i).attribute8               := p_x_supplier_tbl(i).attribute8;
        l_supplier_tbl(i).attribute9               := p_x_supplier_tbl(i).attribute9;
        l_supplier_tbl(i).attribute10              := p_x_supplier_tbl(i).attribute10;
        l_supplier_tbl(i).attribute11              := p_x_supplier_tbl(i).attribute11;
        l_supplier_tbl(i).attribute12              := p_x_supplier_tbl(i).attribute12;
        l_supplier_tbl(i).attribute13              := p_x_supplier_tbl(i).attribute13;
        l_supplier_tbl(i).attribute14              := p_x_supplier_tbl(i).attribute14;
        l_supplier_tbl(i).attribute15              := p_x_supplier_tbl(i).attribute15;
        l_supplier_tbl(i).delete_flag              := p_x_supplier_tbl(i).delete_flag;
        l_supplier_tbl(i).object_version_number    := p_x_supplier_tbl(i).object_version_number;
        --Standard check to count messages
--{{adharia
/*
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
*/
--}}adharia
     END LOOP;
   END IF;
   -- Debug info.
   IF AHL_DEBUG_PUB.G_FILE_DEBUG THEN
       AHL_DEBUG_PUB.debug( 'Before processing Recipient Record ahl_di_doc_index_pub.create_document','+DI+');
    END IF;
 --for Creating Recipient Record, 'R'
 ELSIF p_x_document_tbl(i).process_flag = 'R'
 THEN
      IF p_x_recipient_tbl.COUNT > 0
      THEN
       FOR i IN p_x_recipient_tbl.FIRST..p_x_recipient_tbl.LAST
       LOOP
         --For Recipient Id
         IF (p_x_recipient_tbl(i).recipient_party_id IS NULL) OR
            (p_x_recipient_tbl(i).recipient_party_id = FND_API.G_MISS_NUM)
          THEN
          -- If Recipient Name is available
           IF (p_x_recipient_tbl(i).recipient_party_number IS NOT NULL) AND
              (p_x_recipient_tbl(i).recipient_party_number <> FND_API.G_MISS_CHAR)
              THEN
                 OPEN  for_party_name(p_x_recipient_tbl(i).recipient_party_number);
                 FETCH for_party_name INTO l_recipient_id;
                 IF for_party_name%FOUND
                 THEN
                     l_recipient_tbl(i).recipient_party_id := l_recipient_id;
                 ELSE
                   FND_MESSAGE.SET_NAME('AHL','AHL_DI_RECIPIENT_ID_NOT_EXIST');
                   FND_MESSAGE.SET_TOKEN('RECPNAME',p_x_recipient_tbl(i).recipient_party_number);
                   FND_MSG_PUB.ADD;
                 END IF;
                 CLOSE for_party_name;
            --ID presents
           ELSIF (p_x_recipient_tbl(i).recipient_party_id IS NOT NULL) AND
              (p_x_recipient_tbl(i).recipient_party_id <> FND_API.G_MISS_NUM)
              THEN
               l_recipient_tbl(i).recipient_party_id := p_x_recipient_tbl(i).recipient_party_id;
            ELSE
              --Both Recipient Id and Name are missing
               FND_MESSAGE.SET_NAME('AHL','AHL_DI_RECIPIENT_ID_NOT_EXIST');
               FND_MESSAGE.SET_TOKEN('RECPNAME',p_x_recipient_tbl(i).recipient_party_number);
               FND_MSG_PUB.ADD;
         END IF;
      END IF;
        l_recipient_tbl(i).recipient_document_id    := p_x_recipient_tbl(i).recipient_document_id;
        l_recipient_tbl(i).document_id              := p_x_recipient_tbl(i).document_id;
        l_recipient_tbl(i).attribute_category       := p_x_recipient_tbl(i).attribute_category;
        l_recipient_tbl(i).attribute1               := p_x_recipient_tbl(i).attribute1;
        l_recipient_tbl(i).attribute2               := p_x_recipient_tbl(i).attribute2;
        l_recipient_tbl(i).attribute3               := p_x_recipient_tbl(i).attribute3;
        l_recipient_tbl(i).attribute4               := p_x_recipient_tbl(i).attribute4;
        l_recipient_tbl(i).attribute5               := p_x_recipient_tbl(i).attribute5;
        l_recipient_tbl(i).attribute6               := p_x_recipient_tbl(i).attribute6;
        l_recipient_tbl(i).attribute7               := p_x_recipient_tbl(i).attribute7;
        l_recipient_tbl(i).attribute8               := p_x_recipient_tbl(i).attribute8;
        l_recipient_tbl(i).attribute9               := p_x_recipient_tbl(i).attribute9;
        l_recipient_tbl(i).attribute10              := p_x_recipient_tbl(i).attribute10;
        l_recipient_tbl(i).attribute11              := p_x_recipient_tbl(i).attribute11;
        l_recipient_tbl(i).attribute12              := p_x_recipient_tbl(i).attribute12;
        l_recipient_tbl(i).attribute13              := p_x_recipient_tbl(i).attribute13;
        l_recipient_tbl(i).attribute14              := p_x_recipient_tbl(i).attribute14;
        l_recipient_tbl(i).attribute15              := p_x_recipient_tbl(i).attribute15;
        l_recipient_tbl(i).delete_flag              := p_x_recipient_tbl(i).delete_flag;
        l_recipient_tbl(i).object_version_number    := p_x_recipient_tbl(i).object_version_number;
      --Standard check to count messages
--{{adharia
/*
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
  */
--{{adharia

      END LOOP;
    END IF;
  END IF;
 END LOOP;
END IF;
/*
 -- For Creating Subscriptions Record
   IF p_x_subscription_tbl.count > 0
   THEN
     FOR i IN p_x_subscription_tbl.FIRST..p_x_subscription_tbl.LAST
     LOOP
        -- Module type is 'JSP' then make it null for the following fields
        IF (p_module_type = 'JSP') THEN
            p_x_subscription_tbl(i).requested_by_party_id := null;
            p_x_subscription_tbl(i).subscribed_frm_party_id := null;
        END IF;
        -- For Requested by party Id
        IF (p_x_subscription_tbl(i).requested_by_pty_name IS NOT NULL) AND
           (p_x_subscription_tbl(i).requested_by_pty_name <> FND_API.G_MISS_CHAR)
         THEN
             OPEN for_party_name(p_x_subscription_tbl(i).requested_by_pty_name);
             FETCH for_party_name INTO l_requested_by_party_id;
               IF for_party_name%FOUND
               THEN
                   l_subscription_tbl(i).requested_by_party_id := l_requested_by_party_id;
                ELSE
                  FND_MESSAGE.SET_NAME('AHL','AHL_DI_REQ_PTY_ID_NOT_EXISTS');
                  FND_MSG_PUB.ADD;
                 END IF;
              CLOSE for_party_name;

           -- Party Id is present
           ELSIF (p_x_subscription_tbl(i).requested_by_party_id IS NOT NULL) AND
              (p_x_subscription_tbl(i).requested_by_party_id <> FND_API.G_MISS_NUM)
              THEN
                 OPEN for_party_id(p_x_subscription_tbl(i).requested_by_party_id);
                 FETCH for_party_id INTO l_requested_by_party_id;
                 IF for_party_id%FOUND
                 THEN
                     l_subscription_tbl(i).requested_by_party_id := l_requested_by_party_id;
                  ELSE
                   FND_MESSAGE.SET_NAME('AHL','AHL_DI_REQ_PTY_ID_NOT_EXISTS');
                   FND_MSG_PUB.ADD;
                 END IF;
                 CLOSE for_party_id;
           ELSE
             --Both Party Id and Name are missing
             FND_MESSAGE.SET_NAME('AHL','AHL_DI_REQ_PTY_ID_NULL');
             FND_MSG_PUB.ADD;
            END IF;
          --For Subscribed from party id
          -- If subscribed from Party Name is available
          IF (p_x_subscription_tbl(i).subscribed_frm_pty_name IS NOT NULL) AND
              (p_x_subscription_tbl(i).subscribed_frm_pty_name <> FND_API.G_MISS_CHAR)
              THEN
                 OPEN  for_party_name(p_x_subscription_tbl(i).subscribed_frm_pty_name);
                 FETCH for_party_name INTO l_supplier_id;
                 IF for_party_name%FOUND
                 THEN
                    l_subscription_tbl(i).subscribed_frm_party_id := l_supplier_id;
                  ELSE
                    l_subscription_tbl(i).subscribed_frm_party_id := p_x_subscription_tbl(i).subscribed_frm_party_id;
                  END IF;
                  CLOSE for_party_name;
               -- If Part id is present
            ELSIF (p_x_subscription_tbl(i).subscribed_frm_party_id IS NOT NULL AND
               p_x_subscription_tbl(i).subscribed_frm_party_id <> FND_API.G_MISS_NUM)
               THEN
                 OPEN  for_party_id(p_x_subscription_tbl(i).subscribed_frm_party_id);
                 FETCH for_party_id INTO l_supplier_id;
                 IF for_party_id%FOUND
                 THEN
                    l_subscription_tbl(i).subscribed_frm_party_id := l_supplier_id;
                  ELSE
                    l_subscription_tbl(i).subscribed_frm_party_id := p_x_subscription_tbl(i).subscribed_frm_party_id;
                  END IF;
                  CLOSE for_party_id;
                --Both are missing
             ELSE
                l_subscription_tbl(i).subscribed_frm_party_id := p_x_subscription_tbl(i).subscribed_frm_party_id;
          END IF;
        --For Media Type Code
        IF p_x_subscription_tbl(i).media_type_desc IS NOT NULL AND
            p_x_subscription_tbl(i).media_type_desc <> FND_API.G_MISS_CHAR
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
       IF p_x_subscription_tbl(i).media_type_code IS NOT NULL AND
             p_x_subscription_tbl(i).media_type_code <> FND_API.G_MISS_CHAR
        THEN
           l_subscription_tbl(i).media_type_code := p_x_subscription_tbl(i).media_type_code;
       ELSE
          -- Both are missing
           l_subscription_tbl(i).media_type_code := p_x_subscription_tbl(i).media_type_code;
      END IF;

        --For Subscription  Type Code
        IF p_x_subscription_tbl(i).subscription_type_desc IS NOT NULL AND
            p_x_subscription_tbl(i).subscription_type_desc <> FND_API.G_MISS_CHAR
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
        IF p_x_subscription_tbl(i).subscription_type_code IS NOT NULL AND
             p_x_subscription_tbl(i).subscription_type_code <> FND_API.G_MISS_CHAR
         THEN
           l_subscription_tbl(i).subscription_type_code := p_x_subscription_tbl(i).subscription_type_code;
        ELSE
           l_subscription_tbl(i).subscription_type_code := p_x_subscription_tbl(i).subscription_type_code;
       END IF;

        --For Frequency Code
        IF p_x_subscription_tbl(i).frequency_desc IS NOT NULL AND
            p_x_subscription_tbl(i).frequency_desc <> FND_API.G_MISS_CHAR
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
       IF p_x_subscription_tbl(i).frequency_code IS NOT NULL AND
            p_x_subscription_tbl(i).frequency_code <> FND_API.G_MISS_CHAR
         THEN
           l_subscription_tbl(i).frequency_code := p_x_subscription_tbl(i).frequency_code;
          -- both missing
        ELSE
           l_subscription_tbl(i).frequency_code := p_x_subscription_tbl(i).frequency_code;
        END IF;

        --For Status Code
        IF p_x_subscription_tbl(i).status_desc IS NOT NULL AND
            p_x_subscription_tbl(i).status_desc <> FND_API.G_MISS_CHAR
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
       IF p_x_subscription_tbl(i).status_code IS NOT NULL  AND
             p_x_subscription_tbl(i).status_code <> FND_API.G_MISS_CHAR
         THEN
           l_subscription_tbl(i).status_code := p_x_subscription_tbl(i).status_code;
         -- If both are missing
         ELSE
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_STATUS_CODE_NULL');
            FND_MSG_PUB.ADD;
         END IF;

        l_subscription_tbl(i).document_id             := p_x_subscription_tbl(i).document_id;
        l_subscription_tbl(i).quantity                := p_x_subscription_tbl(i).quantity;
        l_subscription_tbl(i).start_date              := p_x_subscription_tbl(i).start_date;
        l_subscription_tbl(i).end_date                := p_x_subscription_tbl(i).end_date;
        l_subscription_tbl(i).purchase_order_no       := p_x_subscription_tbl(i).purchase_order_no;
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
     --Standard check to count messages
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
    END LOOP;
  END IF;       */
   -- For creating revisions
/*   IF p_x_doc_rev_tbl.COUNT > 0
   THEN
     FOR i IN p_x_doc_rev_tbl.FIRST..p_x_doc_rev_tbl.LAST
     LOOP
        -- Module type is 'JSP' then make it null for the following fields
        IF (p_module_type = 'JSP') THEN
            p_x_doc_rev_tbl(i).approved_by_party_id := null;
        END IF;

         --For Approved by Party Id, Party Name is present
           IF (p_x_doc_rev_tbl(i).approved_by_pty_name IS NOT NULL) AND
              (p_x_doc_rev_tbl(i).approved_by_pty_name <> FND_API.G_MISS_CHAR)
              THEN
                 OPEN  for_party_name(p_x_doc_rev_tbl(i).approved_by_pty_name);
                 FETCH for_party_name INTO l_approved_by_party_id;
                 IF for_party_name%FOUND
                 THEN
                  l_revision_tbl(i).approved_by_party_id := l_approved_by_party_id;
                  ELSE
                   FND_MESSAGE.SET_NAME('AHL','AHL_DI_APP_BY_PTY_ID_NOT_EXIST');
                   FND_MSG_PUB.ADD;
                 END IF;
                 CLOSE for_party_name;
           --If Party Id is present
           ELSIF (p_x_doc_rev_tbl(i).approved_by_party_id IS NOT NULL) AND
              (p_x_doc_rev_tbl(i).approved_by_party_id <> FND_API.G_MISS_NUM)
              THEN
                 OPEN  for_party_id(p_x_doc_rev_tbl(i).approved_by_party_id);
                 FETCH for_party_id INTO l_approved_by_party_id;
                 IF for_party_id%FOUND
                 THEN
                  l_revision_tbl(i).approved_by_party_id := l_approved_by_party_id;
                  ELSE
                   FND_MESSAGE.SET_NAME('AHL','AHL_DI_APP_BY_PTY_ID_NOT_EXIST');
                   FND_MSG_PUB.ADD;
                 END IF;
                 CLOSE for_party_id;
            ELSE
              --Both Party Id and Name are missing

                  l_revision_tbl(i).approved_by_party_id := p_x_doc_rev_tbl(i).approved_by_party_id;
            END IF;
         --For Revision Type Code
       IF p_x_doc_rev_tbl(i).revision_type_desc IS NOT NULL AND
          p_x_doc_rev_tbl(i).revision_type_desc <> FND_API.G_MISS_CHAR
       THEN

             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_REVISION_TYPE',
                  p_lookup_code  => null,
                  p_meaning      => p_x_doc_rev_tbl(i).revision_type_desc,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_revision_tbl(i).revision_type_code,
                  x_return_status => l_return_status);

         IF nvl(l_return_status, 'X') <> 'S'
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_REV_TYPE_CODE_NOT_EXIST');
            FND_MSG_PUB.ADD;
         END IF;
        END IF;
         -- If Code is present
        IF (p_x_doc_rev_tbl(i).revision_type_code IS NOT NULL AND
            p_x_doc_rev_tbl(i).revision_type_code <> FND_API.G_MISS_CHAR)
         THEN
           l_revision_tbl(i).revision_type_code := p_x_doc_rev_tbl(i).revision_type_code;
        --If both are missing
        ELSE
           l_revision_tbl(i).revision_type_code := p_x_doc_rev_tbl(i).revision_type_code;
        END IF;
        --For Media Type Code, meaning is present
        IF p_x_doc_rev_tbl(i).media_type_desc IS NOT NULL AND
            p_x_doc_rev_tbl(i).media_type_desc <> FND_API.G_MISS_CHAR
         THEN

             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_MEDIA_TYPE',
                  p_lookup_code  => null,
                  p_meaning      => p_x_doc_rev_tbl(i).media_type_desc,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_revision_tbl(i).media_type_code,
                  x_return_status => l_return_status);

         IF nvl(l_return_status, 'X') <> 'S'
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_MEDTYP_CODE_NOT_EXISTS');
            FND_MSG_PUB.ADD;
         END IF;
        END IF;
         -- If ID presnt
        IF p_x_doc_rev_tbl(i).media_type_code IS NOT NULL AND
            p_x_doc_rev_tbl(i).media_type_code <> FND_API.G_MISS_CHAR
         THEN
           l_revision_tbl(i).media_type_code := p_x_doc_rev_tbl(i).media_type_code;
         --Both are missing
         ELSE
           l_revision_tbl(i).media_type_code := p_x_doc_rev_tbl(i).media_type_code;
         END IF;
         --For Revision Status Code
         IF p_x_doc_rev_tbl(i).revision_status_desc IS NOT NULL AND
            p_x_doc_rev_tbl(i).revision_status_desc <> FND_API.G_MISS_CHAR
         THEN

             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_REVISION_STATUS_TYPE',
                  p_lookup_code  => null,
                  p_meaning      => p_x_doc_rev_tbl(i).revision_status_desc,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_revision_tbl(i).revision_status_code,
                  x_return_status => l_return_status);

         IF nvl(l_return_status, 'X') <> 'S'
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_REV_STAT_CODE_NOT_EXIST');
            FND_MSG_PUB.ADD;
         END IF;
        END IF;
        -- If Revision status code presents
         IF p_x_doc_rev_tbl(i).revision_status_code IS NOT NULL AND
            p_x_doc_rev_tbl(i).revision_status_code <> FND_API.G_MISS_CHAR
         THEN
           l_revision_tbl(i).revision_status_code := p_x_doc_rev_tbl(i).revision_status_code;
         ELSE
          --Both are missing
           l_revision_tbl(i).revision_status_code := p_x_doc_rev_tbl(i).revision_status_code;
         END IF;
        --
        l_revision_tbl(i).doc_revision_id      := p_x_doc_rev_tbl(i).doc_revision_id;
        l_revision_tbl(i).document_id          := p_x_doc_rev_tbl(i).document_id;
        l_revision_tbl(i).revision_no          := p_x_doc_rev_tbl(i).revision_no;
        l_revision_tbl(i).revision_date        := p_x_doc_rev_tbl(i).revision_date;
        l_revision_tbl(i).approved_date        := p_x_doc_rev_tbl(i).approved_date;
        l_revision_tbl(i).effective_date       := p_x_doc_rev_tbl(i).effective_date;
        l_revision_tbl(i).obsolete_date        := p_x_doc_rev_tbl(i).obsolete_date;
        l_revision_tbl(i).issue_date           := p_x_doc_rev_tbl(i).issue_date;
        l_revision_tbl(i).received_date        := p_x_doc_rev_tbl(i).received_date;
        l_revision_tbl(i).url                  := p_x_doc_rev_tbl(i).url;
        l_revision_tbl(i).volume               := p_x_doc_rev_tbl(i).volume;
        l_revision_tbl(i).issue                := p_x_doc_rev_tbl(i).issue;
        l_revision_tbl(i).issue_number         := p_x_doc_rev_tbl(i).issue_number;
        l_revision_tbl(i).language             := p_x_doc_rev_tbl(i).language;
        l_revision_tbl(i).source_lang          := p_x_doc_rev_tbl(i).source_lang;
        l_revision_tbl(i).comments             := p_x_doc_rev_tbl(i).comments;
        l_revision_tbl(i).attribute_category   := p_x_doc_rev_tbl(i).attribute_category;
        l_revision_tbl(i).attribute1           := p_x_doc_rev_tbl(i).attribute1;
        l_revision_tbl(i).attribute2           := p_x_doc_rev_tbl(i).attribute2;
        l_revision_tbl(i).attribute3           := p_x_doc_rev_tbl(i).attribute3;
        l_revision_tbl(i).attribute4           := p_x_doc_rev_tbl(i).attribute4;
        l_revision_tbl(i).attribute5           := p_x_doc_rev_tbl(i).attribute5;
        l_revision_tbl(i).attribute6           := p_x_doc_rev_tbl(i).attribute6;
        l_revision_tbl(i).attribute7           := p_x_doc_rev_tbl(i).attribute7;
        l_revision_tbl(i).attribute8           := p_x_doc_rev_tbl(i).attribute8;
        l_revision_tbl(i).attribute9           := p_x_doc_rev_tbl(i).attribute9;
        l_revision_tbl(i).attribute10          := p_x_doc_rev_tbl(i).attribute10;
        l_revision_tbl(i).attribute11          := p_x_doc_rev_tbl(i).attribute11;
        l_revision_tbl(i).attribute12          := p_x_doc_rev_tbl(i).attribute12;
        l_revision_tbl(i).attribute13          := p_x_doc_rev_tbl(i).attribute13;
        l_revision_tbl(i).attribute14          := p_x_doc_rev_tbl(i).attribute14;
        l_revision_tbl(i).attribute15          := p_x_doc_rev_tbl(i).attribute15;
        l_revision_tbl(i).delete_flag          := p_x_doc_rev_tbl(i).delete_flag;
        l_revision_tbl(i).object_version_number := p_x_doc_rev_tbl(i).object_version_number;

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
  END LOOP;
 END IF;       */


/*-----------------------------------------------------------*/
/* procedure name: AHL_DI_DOC_INDEX_CHUK.CREATE_DOCUMENT_PRE */
/*         AHL_DI_DOC_INDEX_VHUK.CREATE_DOCUMENT_PRE */
/*                               */
/* description   : Added by Siddhartha to call User Hooks    */
/*      Date     : Dec 28 2001                               */
/*-----------------------------------------------------------*/


IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_DOC_INDEX_PUB','CREATE_DOCUMENT',
                    'B', 'C' )  then
 AHL_DEBUG_PUB.debug( 'Start AHL_DI_DOC_INDEX_CUHK.CREATE_DOCUMENT_PRE');

AHL_DI_DOC_INDEX_CUHK.CREATE_DOCUMENT_PRE
(

     p_x_document_tbl            =>     l_document_tbl ,
     p_x_supplier_tbl        =>         l_supplier_tbl,
         p_x_recipient_tbl           =>         l_recipient_tbl,
     x_return_status             =>     l_return_status,
     x_msg_count                 =>     l_msg_count   ,
     x_msg_data                  =>     l_msg_data
);


      AHL_DEBUG_PUB.debug( 'End AHL_DI_DOC_INDEX_CUHK.CREATE_DOCUMENT_PRE');

    IF   l_return_status = FND_API.G_RET_STS_ERROR  THEN
                RAISE FND_API.G_EXC_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
END IF;

IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_DOC_INDEX_PUB','CREATE_DOCUMENT','B', 'V' )
    then

      AHL_DEBUG_PUB.debug( 'Start  AHL_DI_DOC_INDEX_VUHK.CREATE_DOCUMENT_PRE');

  AHL_DI_DOC_INDEX_VUHK.CREATE_DOCUMENT_PRE
        (
            p_x_document_tbl    =>  l_document_tbl ,
            p_x_supplier_tbl    =>  l_supplier_tbl,
                        p_x_recipient_tbl   =>  l_recipient_tbl,
            X_RETURN_STATUS         =>  l_return_status  ,
            X_MSG_COUNT             =>  l_msg_count      ,
            X_MSG_DATA              =>  l_msg_data  );

/*
       --Standard check to count messages
       l_msg_count := FND_MSG_PUB.count_msg;
*/
      AHL_DEBUG_PUB.debug( 'End  AHL_DI_DOC_INDEX_VUHK.CREATE_DOCUMENT_PRE');

            IF   l_return_status = FND_API.G_RET_STS_ERROR  THEN
                RAISE FND_API.G_EXC_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;



END IF;


/*---------------------------------------------------------*/
/*     End ; Date     : Dec 28 2001                        */
/*---------------------------------------------------------*/

  -- Call the Private API
--{{adharia
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
--}}adharia

   AHL_DI_DOC_INDEX_PVT.CREATE_DOCUMENT(
                         p_api_version      => 1.0,
                         p_init_msg_list    => p_init_msg_list,
                         p_commit           => p_commit,
                         p_validate_only       => p_validate_only,
                         p_validation_level => p_validation_level,
                         p_x_document_tbl   => l_document_tbl,
                         p_x_supplier_tbl   => l_supplier_tbl,
                         p_x_recipient_tbl  => l_recipient_tbl,
                         x_return_status    => l_return_status,
                         x_msg_count        => l_msg_count,
                         x_msg_data         => l_msg_data);

   --Standard check to count messages
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


/*----------------------------------------------------------------------------- */
/* procedure name: AHL_DI_DOC_INDEX_VHUK.CREATE_DOCUMENT_POST           */
/*         AHL_DI_DOC_INDEX_CHUK.CREATE_DOCUMENT_POST           */
/*                                          */
/* description   :  Added by ssaklani to call User Hooks            */
/*      Date     : Dec 28 2001                                      */
/*------------------------------------------------------------------------------*/

IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_DOC_INDEX_PUB','CREATE_DOCUMENT',
                    'A', 'V' )  then

      AHL_DEBUG_PUB.debug( 'Start AHL_DI_DOC_INDEX_VUHK.CREATE_DOCUMENT_POST ');


            AHL_DI_DOC_INDEX_VUHK.CREATE_DOCUMENT_POST
        (
            p_document_tbl      =>  l_document_tbl ,
            p_supplier_tbl      =>  l_supplier_tbl,
                        p_recipient_tbl     =>  l_recipient_tbl,
            X_RETURN_STATUS         =>  l_return_status      ,
            X_MSG_COUNT             =>  l_msg_count        ,
            X_MSG_DATA              =>  l_msg_data  );

            IF   l_return_status = FND_API.G_RET_STS_ERROR  THEN
                RAISE FND_API.G_EXC_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

   AHL_DEBUG_PUB.debug( 'End AHL_DI_DOC_INDEX_VUHK.CREATE_DOCUMENT_POST ');

END IF;

IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_DOC_INDEX_PUB','CREATE_DOCUMENT',
                    'A', 'C' )  then

   AHL_DEBUG_PUB.debug( 'Start AHL_DI_DOC_INDEX_CUHK.CREATE_DOCUMENT_POST');


            AHL_DI_DOC_INDEX_CUHK.CREATE_DOCUMENT_POST(

            p_document_tbl      =>  l_document_tbl ,
            p_supplier_tbl      =>  l_supplier_tbl,
                        p_recipient_tbl     =>  l_recipient_tbl,
            X_RETURN_STATUS         =>  l_return_status      ,
            X_MSG_COUNT             =>  l_msg_count           ,
            X_MSG_DATA              =>  l_msg_data  );


            IF   l_return_status = FND_API.G_RET_STS_ERROR  THEN
                RAISE FND_API.G_EXC_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

   AHL_DEBUG_PUB.debug( 'End AHL_DI_DOC_INDEX_CUHK.CREATE_DOCUMENT_POST');


END IF;


/*---------------------------------------------------------*/
/*     End ; Date     : Dec 28 2001                        */
/*---------------------------------------------------------*/


   IF l_document_tbl.COUNT > 0
   THEN
      FOR i IN l_document_tbl.FIRST..l_document_tbl.LAST
      LOOP
         p_x_document_tbl(i).document_id := l_document_tbl(i).document_id;
      END LOOP;
   END IF;
   --Assign Suppliers
  IF l_supplier_tbl.COUNT > 0
  THEN
    FOR i IN l_supplier_tbl.FIRST..l_supplier_tbl.LAST
    LOOP
       p_x_supplier_tbl(i).supplier_document_id := l_supplier_tbl(i).supplier_document_id;
    END LOOP;
  END IF;
  -- Assign Recipients
  IF l_recipient_tbl.COUNT > 0
  THEN
    FOR i IN l_recipient_tbl.FIRST..l_recipient_tbl.LAST
    LOOP
       p_x_recipient_tbl(i).recipient_document_id := l_recipient_tbl(i).recipient_document_id;
    END LOOP;
  END IF;
   --Standard check for commit
   IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   -- Debug info
   AHL_DEBUG_PUB.debug( 'End of public api Create Document','+DI+');
   -- Check if API is called in debug mode. If yes, disable debug.
   AHL_DEBUG_PUB.disable_debug;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_document;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
        IF AHL_DEBUG_PUB.G_FILE_DEBUG THEN
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_index_pub.Create Document','+DI+');
        END IF;
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO create_document;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
        IF AHL_DEBUG_PUB.G_FILE_DEBUG THEN
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_index_pub.Create Document','+DI+');
        END IF;
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;

 WHEN OTHERS THEN
    ROLLBACK TO create_document;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_DOC_INDEX_PUB',
                            p_procedure_name  =>  'CREATE_DOCUMENT',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
        IF AHL_DEBUG_PUB.G_FILE_DEBUG THEN
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_index_pub.Create Document','+DI+');
        END IF;
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;

END CREATE_DOCUMENT;
/*------------------------------------------------------*/
/* procedure name: modify_document                      */
/* description :  Updates existing document record and its */
/*                associated suppliers, recipients,     */
/*                subscriptions,revision and copies     */
/*                                                      */
/*------------------------------------------------------*/

PROCEDURE MODIFY_DOCUMENT
(
 p_api_version                IN     NUMBER    := '1.0'            ,
 p_init_msg_list              IN     VARCHAR2  := FND_API.G_TRUE   ,
 p_commit                     IN     VARCHAR2  := FND_API.G_FALSE  ,
 p_validate_only              IN     VARCHAR2  := FND_API.G_TRUE   ,
 p_validation_level           IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_document_tbl             IN OUT NOCOPY document_tbl           ,
-- p_x_doc_rev_tbl              IN OUT NOCOPY AHL_DI_DOC_REVISION_PUB.Revision_Tbl ,
-- p_x_doc_rev_copy_tbl         IN OUT NOCOPY AHL_DI_DOC_REVISION_PUB.Revision_Copy_Tbl,
-- p_x_subscription_tbl         IN OUT NOCOPY AHL_DI_SUBSCRIPTION_PUB.Subscription_Tbl,
 p_x_supplier_tbl             IN OUT NOCOPY Supplier_Tbl           ,
 p_x_recipient_tbl            IN OUT NOCOPY Recipient_Tbl          ,
 p_module_type                IN     VARCHAR2                      ,
 x_return_status                 OUT NOCOPY VARCHAR2                      ,
 x_msg_count                     OUT NOCOPY NUMBER                        ,
 x_msg_data                      OUT NOCOPY VARCHAR2)
 IS
-- Cursor is used to retrieve party id
CURSOR for_party_name(c_party_number  IN VARCHAR2)
 IS
SELECT party_id
  FROM hz_parties
 WHERE party_number = c_party_number;
 --
 CURSOR for_party_id(c_party_id  IN NUMBER)
  IS
 SELECT party_id
   FROM hz_parties
  WHERE party_id = c_party_id;
 -- Used to retrieve vendor id from po vendors
 CURSOR for_vendor_id(c_segment1  IN VARCHAR2)
 IS
  SELECT vendor_id
   FROM po_vendors
 WHERE segment1 = c_segment1;
 --Added pjha for Restricting Subscription Avail to 'Yes' If supplier or subscription
 --Exists for the doc: Begin
    -- Cursor used to find if a supplier exist for the document
    CURSOR check_sup_exists(c_document_id NUMBER)
    IS
    SELECT 'X'
    FROM ahl_supplier_documents
    WHERE document_id = c_document_id;
   -- Cursor to find if there are active subscription for the document
   -- adharia -- added nvl to end_date;--11 July 2002
   CURSOR check_sub_exists(c_document_id NUMBER)
   IS
   SELECT 'X'
   FROM ahl_subscriptions_b
   WHERE document_id = c_document_id
   AND NVL(end_date, sysdate) >= TRUNC(sysdate);
  --Added pjha for Restricting Subscription Avail to 'Yes' If supplier or subscription
    --Exists for the doc: End

 --Enhancement #2275357: pbarman 1st April 2003
 --Cursor to retrieve operator code from hz parties
 CURSOR get_operator_name_hz(c_operator_name VARCHAR2)
     IS
    SELECT party_id
    FROM HZ_PARTIES
    WHERE upper(party_name) = upper(c_operator_name)
    AND ( party_type ='ORGANIZATION' or party_type = 'PERSON' );
  -- For Bug Fix #3446159
    CURSOR get_operator_name_hz_id(c_operator_name VARCHAR2, c_operator_id NUMBER)
     IS
    SELECT party_id
    FROM HZ_PARTIES
    WHERE upper(party_name) = upper(c_operator_name)
                AND party_id = c_operator_id
    AND ( party_type ='ORGANIZATION' or party_type = 'PERSON' );

  --pbarman : 28th July 2003
  CURSOR for_subcr_validate(c_supplier_id NUMBER, c_doc_id NUMBER)
  IS
  SELECT subscription_id
  FROM AHL_SUBSCRIPTIONS_B
  WHERE SUBSCRIBED_FRM_PARTY_ID = c_supplier_id
  AND DOCUMENT_ID = c_doc_id;

  -- Bug : Perf Fixes for 4918997
  /*
  CURSOR for_supplier_name(c_supplier_no NUMBER )
    IS
    SELECT DISTINCT party_name
    FROM AHL_HZ_PO_SUPPLIERS_V
    WHERE PARTY_NUMBER = c_supplier_no;
  */

CURSOR for_supplier_name_hz(c_supplier_no NUMBER)
IS
 SELECT DISTINCT PARTY_NAME
 FROM   HZ_PARTIES
 WHERE PARTY_NUMBER =c_supplier_no;

CURSOR for_supplier_name_po(c_supplier_no NUMBER)
IS
 SELECT DISTINCT VENDOR_NAME
 FROM   PO_VENDORS
 WHERE SEGMENT1 =c_supplier_no;

--

 l_api_name       CONSTANT VARCHAR2(30) := 'MODIFY_DOCUMENT';
 l_api_version    CONSTANT NUMBER       := 1.0;
 l_msg_count               NUMBER;
 l_num_rec                 NUMBER;
 l_msg_data                VARCHAR2(2000);
 l_return_status           VARCHAR2(1);
 l_source_party_id         NUMBER;
 l_supplier_id             NUMBER;
 l_recipient_id            NUMBER;
 l_recipient_party_id      NUMBER;
 l_requested_by_party_id   NUMBER;
 l_approved_by_party_id    NUMBER;
 l_received_by_party_id    NUMBER;
 l_doc_type_code           VARCHAR2(30);
 l_doc_sub_type_code       VARCHAR2(30);
 l_preference_code         VARCHAR2(30);
 l_status_code             VARCHAR2(30);
 l_media_type_code         VARCHAR2(30);
 l_frequency_code          VARCHAR2(30);
 l_subscription_type_code  VARCHAR2(30);
 l_revision_type_code      VARCHAR2(30);
 l_revision_status_code    VARCHAR2(30);
 l_copy_type_code          VARCHAR2(30);
 l_operator_code           VARCHAR2(30);
 l_product_type_code       VARCHAR2(30);
 l_document_tbl            AHL_DI_DOC_INDEX_PVT.document_tbl;
-- l_revision_tbl            AHL_DI_DOC_REVISION_PVT.revision_tbl;
-- l_revision_copy_tbl       AHL_DI_DOC_REVISION_PVT.revision_copy_tbl;
-- l_subscription_tbl        AHL_DI_SUBSCRIPTION_PVT.subscription_tbl;
 l_supplier_tbl            AHL_DI_DOC_INDEX_PVT.supplier_tbl;
 l_recipient_tbl           AHL_DI_DOC_INDEX_PVT.recipient_tbl;
 l_init_msg_list          VARCHAR2(10) := FND_API.G_TRUE;
 l_subscription_id          NUMBER;
 l_supplier_name            VARCHAR2(360);
 l_prod_install_status      VARCHAR2(30);

--

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT modify_document;

   -- Check if API is called in debug mode. If yes, enable debug.
   AHL_DEBUG_PUB.enable_debug;
   -- Debug info.
   IF AHL_DEBUG_PUB.G_FILE_DEBUG THEN
       AHL_DEBUG_PUB.debug( 'enter ahl_di_doc_index_pub.Modify Document','+DI+');
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

   BEGIN
       IF AHL_DEBUG_PUB.G_FILE_DEBUG THEN
           AHL_DEBUG_PUB.debug( 'Fetching Product Installation Status','+DI+');
       END IF;
       Select AHL_DI_DOC_INDEX_PVT.GET_PRODUCT_INSTALL_STATUS('PO')
         into l_prod_install_status
         from dual;
   END;

   IF p_x_document_tbl.COUNT > 0
   THEN
     FOR i IN p_x_document_tbl.FIRST..p_x_document_tbl.LAST
     LOOP
     -- Process flag 'D' means Modifying Document record
     IF p_x_document_tbl(i).process_flag = 'D'
     THEN
        -- Module type is 'JSP' then make it null for the following fields
        IF (p_module_type = 'JSP') THEN
            p_x_document_tbl(i).source_party_id := null;
            p_x_document_tbl(i).product_type_code := null;
            --p_x_document_tbl(i).operator_code := null;
        END IF;
         --For Source by Party Id
         IF (p_x_document_tbl(i).source_party_id IS NULL) OR
            (p_x_document_tbl(i).source_party_id = FND_API.G_MISS_NUM)
          THEN

          -- If Party Name is available
           IF (p_x_document_tbl(i).source_party_number IS NOT NULL) AND
              (p_x_document_tbl(i).source_party_number <> FND_API.G_MISS_CHAR)
              THEN
                 OPEN  for_party_name(p_x_document_tbl(i).source_party_number);
                 FETCH for_party_name INTO l_source_party_id;
                 IF for_party_name%FOUND
                 THEN
                     l_document_tbl(i).source_party_id := l_source_party_id;
                 ELSE
                   FND_MESSAGE.SET_NAME('AHL','AHL_DI_SOURCE_ID_NOT_EXISTS');
                   FND_MSG_PUB.ADD;
                 END IF;
                 CLOSE for_party_name;
            ELSE
              --Both Party Id and Name are missing
              FND_MESSAGE.SET_NAME('AHL','AHL_DI_SOURCE_PARTY_ID_NULL');
              FND_MSG_PUB.ADD;
            END IF;

           --Check for If ID present
         ELSIF (p_x_document_tbl(i).source_party_id IS NOT NULL AND
               p_x_document_tbl(i).source_party_id <> FND_API.G_MISS_NUM)
               THEN
                 OPEN  for_party_id(p_x_document_tbl(i).source_party_id);
                 FETCH for_party_id INTO l_document_tbl(i).source_party_id;
                 IF for_party_id%FOUND
                   THEN
                     l_document_tbl(i).source_party_id := p_x_document_tbl(i).source_party_id;
                  ELSE
                     l_document_tbl(i).source_party_id := p_x_document_tbl(i).source_party_id;
                  END IF;
                  CLOSE for_party_id;
            ELSE
              --Both Party Id and Name are missing
              FND_MESSAGE.SET_NAME('AHL','AHL_DI_SOURCE_PARTY_ID_NULL');
              FND_MSG_PUB.ADD;
         END IF;
 --For Operator Code, Meaning presnts
         IF p_x_document_tbl(i).operator_name IS NOT NULL AND
            p_x_document_tbl(i).operator_name <> FND_API.G_MISS_CHAR
         THEN
    -- Check if operator name and id match
    OPEN get_operator_name_hz_id(p_x_document_tbl(i).operator_name, TO_NUMBER(p_x_document_tbl(i).operator_code));

    FETCH get_operator_name_hz_id INTO l_document_tbl(i).operator_code;
    IF get_operator_name_hz_id%NOTFOUND THEN
    -- the operator name has been changed

         --Enhancement #2275357: pbarman 1st April 2003
          CLOSE get_operator_name_hz_id;
          OPEN get_operator_name_hz(p_x_document_tbl(i).operator_name);
      LOOP
          FETCH get_operator_name_hz INTO l_document_tbl(i).operator_code;
      EXIT WHEN get_operator_name_hz%NOTFOUND;
      END LOOP;


      IF get_operator_name_hz%ROWCOUNT = 0
      THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_DI_OPERATOR_CODE_NOT_EXIST');
      FND_MSG_PUB.ADD;
      ELSIF get_operator_name_hz%ROWCOUNT > 1
      THEN
      FND_MESSAGE.SET_NAME('AHL','AHL_DI_OPERATOR_USE_LOV');
      FND_MSG_PUB.ADD;
          END IF;
      CLOSE get_operator_name_hz;
        END IF;

         END IF;

        --For Product type Code, Meaning presnts
         IF p_x_document_tbl(i).product_type_desc IS NOT NULL AND
            p_x_document_tbl(i).product_type_desc <> FND_API.G_MISS_CHAR
         THEN
             Check_lookup_name_Or_Id (
              --Enhancement #2525604 pbarman : April 2003
                  p_lookup_type  => 'ITEM_TYPE',
                  p_lookup_code  => null,
                  p_meaning      => p_x_document_tbl(i).product_type_desc,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_document_tbl(i).product_type_code,
                  x_return_status => l_return_status);

         IF nvl(l_return_status, 'X') <> 'S'
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_PRODTYPE_CODE_NOT_EXIST');
            FND_MSG_PUB.ADD;
         END IF;

        --ID presntes
         ELSIF p_x_document_tbl(i).product_type_code IS NOT NULL AND
            p_x_document_tbl(i).product_type_code <> FND_API.G_MISS_CHAR
         THEN
          l_document_tbl(i).product_type_code := p_x_document_tbl(i).product_type_code;
          --Both missing
         ELSE
          l_document_tbl(i).product_type_code := p_x_document_tbl(i).product_type_code;
         END IF;

         --For Doc Type Code
         IF p_x_document_tbl(i).doc_type_desc IS NOT NULL AND
            p_x_document_tbl(i).doc_type_desc <> FND_API.G_MISS_CHAR
         THEN
             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_DOC_TYPE',
                  p_lookup_code  => null,
                  p_meaning      => p_x_document_tbl(i).doc_type_desc,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_document_tbl(i).doc_type_code,
                  x_return_status => l_return_status);

         IF nvl(l_return_status, 'X') <> 'S'
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_TYPE_CODE_NOT_EXIST');
            FND_MSG_PUB.ADD;
         END IF;
        END IF;
        -- Id presents
         IF p_x_document_tbl(i).doc_type_code IS NOT NULL AND
            p_x_document_tbl(i).doc_type_code <> FND_API.G_MISS_CHAR
         THEN
           l_document_tbl(i).doc_type_code := p_x_document_tbl(i).doc_type_code;
        ELSE
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_TYPE_CODE_NOT_EXIST');
            FND_MSG_PUB.ADD;
        END IF;

        --For Doc Sub Type Code, meaning presents
         IF p_x_document_tbl(i).doc_sub_type_desc IS NOT NULL AND
            p_x_document_tbl(i).doc_sub_type_desc <> FND_API.G_MISS_CHAR
         THEN

             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_DOC_SUB_TYPE_CODE',
                  p_lookup_code  => null,
                  p_meaning      => p_x_document_tbl(i).doc_sub_type_desc,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_document_tbl(i).doc_sub_type_code,
                  x_return_status => l_return_status);

         IF nvl(l_return_status, 'X') <> 'S'
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_SUBT_COD_NOT_EXISTS');
            FND_MSG_PUB.ADD;
         END IF;
        END IF;
        --Id presents
         IF p_x_document_tbl(i).doc_sub_type_code IS NOT NULL AND
            p_x_document_tbl(i).doc_sub_type_code <> FND_API.G_MISS_CHAR
         THEN
           l_document_tbl(i).doc_sub_type_code := p_x_document_tbl(i).doc_sub_type_code;
        ELSE
           l_document_tbl(i).doc_sub_type_code := p_x_document_tbl(i).doc_sub_type_code;
        END IF;
        --Added pjha: 08-Jul-2002 for Restricting Subscription Avail to 'Yes' If supplier or subscription
        --Exists for the doc: Begin
    IF (p_x_document_tbl(i).subscribe_avail_flag = 'N')
       THEN
          OPEN check_sub_exists(p_x_document_tbl(i).document_id);
          FETCH check_sub_exists INTO l_operator_code;
          IF check_sub_exists%FOUND THEN
         FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUBSC_AVAIL_FLAG_NO');
         FND_MSG_PUB.ADD;
          ELSE
         p_x_document_tbl(i).subscribe_to_flag := 'N';
          END IF;
          CLOSE check_sub_exists;

          OPEN check_sup_exists(p_x_document_tbl(i).document_id);
          FETCH check_sup_exists INTO l_operator_code;
          IF check_sup_exists%FOUND
          THEN
         FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUPPLIER_EXISTS');
             FND_MSG_PUB.ADD;
          END IF;
          CLOSE check_sup_exists;
    END IF;
        --Added pjha: 08-Jul-2002 for Restricting Subscription Avail to 'Yes' If supplier or subscription
        --Exists for the doc: End
        --
        l_document_tbl(i).document_id          := p_x_document_tbl(i).document_id;
        l_document_tbl(i).document_no          := p_x_document_tbl(i).document_no;
        l_document_tbl(i).subscribe_avail_flag := p_x_document_tbl(i).subscribe_avail_flag;
        l_document_tbl(i).subscribe_to_flag    := p_x_document_tbl(i).subscribe_to_flag;
        l_document_tbl(i).document_title       := p_x_document_tbl(i).document_title;
        l_document_tbl(i).language             := p_x_document_tbl(i).language;
        l_document_tbl(i).source_lang          := p_x_document_tbl(i).source_lang;
        l_document_tbl(i).attribute_category   := p_x_document_tbl(i).attribute_category;
        l_document_tbl(i).attribute1           := p_x_document_tbl(i).attribute1;
        l_document_tbl(i).attribute2           := p_x_document_tbl(i).attribute2;
        l_document_tbl(i).attribute3           := p_x_document_tbl(i).attribute3;
        l_document_tbl(i).attribute4           := p_x_document_tbl(i).attribute4;
        l_document_tbl(i).attribute5           := p_x_document_tbl(i).attribute5;
        l_document_tbl(i).attribute6           := p_x_document_tbl(i).attribute6;
        l_document_tbl(i).attribute7           := p_x_document_tbl(i).attribute7;
        l_document_tbl(i).attribute8           := p_x_document_tbl(i).attribute8;
        l_document_tbl(i).attribute9           := p_x_document_tbl(i).attribute9;
        l_document_tbl(i).attribute10          := p_x_document_tbl(i).attribute10;
        l_document_tbl(i).attribute11          := p_x_document_tbl(i).attribute11;
        l_document_tbl(i).attribute12          := p_x_document_tbl(i).attribute12;
        l_document_tbl(i).attribute13          := p_x_document_tbl(i).attribute13;
        l_document_tbl(i).attribute14          := p_x_document_tbl(i).attribute14;
        l_document_tbl(i).attribute15          := p_x_document_tbl(i).attribute15;
        l_document_tbl(i).delete_flag          := p_x_document_tbl(i).delete_flag;
        l_document_tbl(i).object_version_number := p_x_document_tbl(i).object_version_number;

   --Standard check for count messages
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
   -- Debug info.
   IF AHL_DEBUG_PUB.G_FILE_DEBUG THEN
       AHL_DEBUG_PUB.debug( 'Before processing Supplier Record ahl_di_doc_index_pub.modify document','+DI+');
    END IF;

  --For update supplier record
 ELSIF p_x_document_tbl(i).process_flag = 'S'
 THEN
     IF p_x_supplier_tbl.COUNT > 0
     THEN
       FOR i IN p_x_supplier_tbl.FIRST..p_x_supplier_tbl.LAST
       LOOP
       IF (p_x_supplier_tbl(i).supplier_id IS NULL) OR
         (p_x_supplier_tbl(i).supplier_id = FND_API.G_MISS_NUM) THEN
          -- If Supplier Name is available
       IF (p_x_supplier_tbl(i).supplier_number IS NOT NULL) AND
          (p_x_supplier_tbl(i).supplier_number <> FND_API.G_MISS_CHAR)
        THEN
         IF ahl_di_doc_index_pvt.get_product_install_status('PO') IN ('N','L')
         THEN
              OPEN  for_party_name(p_x_supplier_tbl(i).supplier_number);
              FETCH for_party_name INTO l_supplier_id;
                 IF for_party_name%FOUND
                 THEN
                     l_supplier_tbl(i).supplier_id := l_supplier_id;
                 ELSE
                   FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUPPL_ID_NOT_EXIST');
                   FND_MESSAGE.SET_TOKEN('SUPNAME',p_x_supplier_tbl(i).supplier_number);
                   FND_MSG_PUB.ADD;
                 END IF;
              CLOSE for_party_name;
            ELSIF ahl_di_doc_index_pvt.get_product_install_status('PO') IN ('I','S')
         THEN
              OPEN  for_vendor_id(p_x_supplier_tbl(i).supplier_number);
              FETCH for_vendor_id INTO l_supplier_id;
                 IF for_vendor_id%FOUND
                 THEN
                     l_supplier_tbl(i).supplier_id := l_supplier_id;
                 ELSE
                   FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUPPL_ID_NOT_EXIST');
                   FND_MESSAGE.SET_TOKEN('SUPNAME',p_x_supplier_tbl(i).supplier_number);
                   FND_MSG_PUB.ADD;
                 END IF;
              CLOSE for_vendor_id;
            END IF;
           --Id presents
        ELSIF (p_x_supplier_tbl(i).supplier_id IS NOT NULL) AND
              (p_x_supplier_tbl(i).supplier_id <> FND_API.G_MISS_NUM)
              THEN
             l_supplier_tbl(i).supplier_id := p_x_supplier_tbl(i).supplier_id;
         ELSE
            IF p_x_supplier_tbl(i).delete_flag <> 'Y' THEN
              --Both Supplier Id and Name are missing
               FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUPPL_ID_NOT_EXIST');
               FND_MESSAGE.SET_TOKEN('SUPNAME',p_x_supplier_tbl(i).supplier_number);
               FND_MSG_PUB.ADD;
              ELSE
             l_supplier_tbl(i).supplier_id := p_x_supplier_tbl(i).supplier_id;
             END IF;
         END IF;
      END IF;
      -- For Preference Code, meaning presents
      IF p_x_supplier_tbl(i).preference_desc IS NOT NULL AND
         p_x_supplier_tbl(i).preference_desc <> FND_API.G_MISS_CHAR
         THEN

             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_SUPPLIER_PREF_TYPE',
                  p_lookup_code  => null,
                  p_meaning      => p_x_supplier_tbl(i).preference_desc,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_supplier_tbl(i).preference_code,
                  x_return_status => l_return_status);

         IF nvl(l_return_status, 'X') <> 'S'
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUPPLIER_PREF_TYPE');
            FND_MSG_PUB.ADD;
         END IF;
      END IF;
      -- Pref Code presents
      IF p_x_supplier_tbl(i).preference_code IS NOT NULL AND
         p_x_supplier_tbl(i).preference_code <> FND_API.G_MISS_CHAR
         THEN
          l_supplier_tbl(i).preference_code := p_x_supplier_tbl(i).preference_code;
       ELSE
       --Both missing
          l_supplier_tbl(i).preference_code := p_x_supplier_tbl(i).preference_code;
      END IF;

      --if a Subscription exists that Subscribes from the particular Supplier, this Supplier cannot be deleted :prithwi
     IF p_x_supplier_tbl(i).delete_flag = 'Y' THEN
           if p_x_supplier_tbl(i).document_id IS NULL then
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUPPL_DOC_ID_NULL');
            FND_MSG_PUB.ADD;
           end if;
           OPEN for_subcr_validate(l_supplier_tbl(i).supplier_id, p_x_supplier_tbl(i).document_id );
       FETCH for_subcr_validate INTO l_subscription_id;
          IF for_subcr_validate%FOUND
          THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUPPL_ASSOC_EXISTS');

        -- Bug : Perf Fixes for 4918997
        /*
        OPEN  for_supplier_name(p_x_supplier_tbl(i).supplier_number);
        FETCH for_supplier_name INTO l_supplier_name;
        CLOSE for_supplier_name;
        */
        IF l_prod_install_status IN ('N','L') THEN
           OPEN for_supplier_name_hz(p_x_supplier_tbl(i).supplier_number);
           FETCH for_supplier_name_hz INTO l_supplier_name;
           CLOSE for_supplier_name_hz;
        ELSIF l_prod_install_status IN ('I','S') THEN
           OPEN for_supplier_name_po(p_x_supplier_tbl(i).supplier_number);
           FETCH for_supplier_name_po INTO l_supplier_name;
           CLOSE for_supplier_name_po;
        END IF;

        FND_MESSAGE.SET_TOKEN('SUPP',l_supplier_name);
        FND_MSG_PUB.ADD;
          END IF;
           CLOSE for_subcr_validate;

     END IF;

        l_supplier_tbl(i).supplier_document_id     := p_x_supplier_tbl(i).supplier_document_id;
        l_supplier_tbl(i).document_id              := p_x_supplier_tbl(i).document_id;
        l_supplier_tbl(i).attribute_category       := p_x_supplier_tbl(i).attribute_category;
        l_supplier_tbl(i).attribute1               := p_x_supplier_tbl(i).attribute1;
        l_supplier_tbl(i).attribute2               := p_x_supplier_tbl(i).attribute2;
        l_supplier_tbl(i).attribute3               := p_x_supplier_tbl(i).attribute3;
        l_supplier_tbl(i).attribute4               := p_x_supplier_tbl(i).attribute4;
        l_supplier_tbl(i).attribute5               := p_x_supplier_tbl(i).attribute5;
        l_supplier_tbl(i).attribute6               := p_x_supplier_tbl(i).attribute6;
        l_supplier_tbl(i).attribute7               := p_x_supplier_tbl(i).attribute7;
        l_supplier_tbl(i).attribute8               := p_x_supplier_tbl(i).attribute8;
        l_supplier_tbl(i).attribute9               := p_x_supplier_tbl(i).attribute9;
        l_supplier_tbl(i).attribute10              := p_x_supplier_tbl(i).attribute10;
        l_supplier_tbl(i).attribute11              := p_x_supplier_tbl(i).attribute11;
        l_supplier_tbl(i).attribute12              := p_x_supplier_tbl(i).attribute12;
        l_supplier_tbl(i).attribute13              := p_x_supplier_tbl(i).attribute13;
        l_supplier_tbl(i).attribute14              := p_x_supplier_tbl(i).attribute14;
        l_supplier_tbl(i).attribute15              := p_x_supplier_tbl(i).attribute15;
        l_supplier_tbl(i).delete_flag              := p_x_supplier_tbl(i).delete_flag;
        l_supplier_tbl(i).object_version_number    := p_x_supplier_tbl(i).object_version_number;
   --Standard check for count messages
/*--{{adharia
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
--{{adharia
*/
  END LOOP;
 END IF;
  -- Debug info.
  IF AHL_DEBUG_PUB.G_FILE_DEBUG THEN
      AHL_DEBUG_PUB.debug( 'Before processing Recipient Record ahl_di_doc_index_pub.modify document','+DI+');
  END IF;
 --For Update Recipient Record
 ELSIF p_x_document_tbl(i).process_flag = 'R'
 THEN
      IF p_x_recipient_tbl.COUNT > 0
      THEN
       FOR i IN p_x_recipient_tbl.FIRST..p_x_recipient_tbl.LAST
       LOOP
         --For Recipient Id

         IF (p_x_recipient_tbl(i).recipient_party_id IS NULL) OR
            (p_x_recipient_tbl(i).recipient_party_id = FND_API.G_MISS_NUM) THEN
          -- If Recipient Name is available
           IF (p_x_recipient_tbl(i).recipient_party_number IS NOT NULL) AND
              (p_x_recipient_tbl(i).recipient_party_number <> FND_API.G_MISS_CHAR)
              THEN

                 OPEN  for_party_name(p_x_recipient_tbl(i).recipient_party_number);
                 FETCH for_party_name INTO l_recipient_id;
                 IF for_party_name%FOUND
                 THEN
                     l_recipient_tbl(i).recipient_party_id := l_recipient_id;
                 ELSE
                   FND_MESSAGE.SET_NAME('AHL','AHL_DI_RECIPIENT_ID_NOT_EXIST');
                   FND_MESSAGE.SET_TOKEN('RECPNAME',p_x_recipient_tbl(i).recipient_party_number);
                   FND_MSG_PUB.ADD;
                 END IF;
                 CLOSE for_party_name;
            --ID presents
           ELSIF (p_x_recipient_tbl(i).recipient_party_id IS NOT NULL) AND
              (p_x_recipient_tbl(i).recipient_party_id <> FND_API.G_MISS_NUM)
              THEN
               l_recipient_tbl(i).recipient_party_id := p_x_recipient_tbl(i).recipient_party_id;
            ELSE
              --Both Recipient Id and Name are missing
               l_recipient_tbl(i).recipient_party_id := p_x_recipient_tbl(i).recipient_party_id;
         END IF;
      END IF;
        l_recipient_tbl(i).recipient_document_id    := p_x_recipient_tbl(i).recipient_document_id;
        l_recipient_tbl(i).document_id              := p_x_recipient_tbl(i).document_id;
        --Added pjha 24-Jul-2002 for bug#2473425
        l_recipient_tbl(i).recipient_party_number     := p_x_recipient_tbl(i).recipient_party_number;
        l_recipient_tbl(i).attribute_category       := p_x_recipient_tbl(i).attribute_category;
        l_recipient_tbl(i).attribute1               := p_x_recipient_tbl(i).attribute1;
        l_recipient_tbl(i).attribute2               := p_x_recipient_tbl(i).attribute2;
        l_recipient_tbl(i).attribute3               := p_x_recipient_tbl(i).attribute3;
        l_recipient_tbl(i).attribute4               := p_x_recipient_tbl(i).attribute4;
        l_recipient_tbl(i).attribute5               := p_x_recipient_tbl(i).attribute5;
        l_recipient_tbl(i).attribute6               := p_x_recipient_tbl(i).attribute6;
        l_recipient_tbl(i).attribute7               := p_x_recipient_tbl(i).attribute7;
        l_recipient_tbl(i).attribute8               := p_x_recipient_tbl(i).attribute8;
        l_recipient_tbl(i).attribute9               := p_x_recipient_tbl(i).attribute9;
        l_recipient_tbl(i).attribute10              := p_x_recipient_tbl(i).attribute10;
        l_recipient_tbl(i).attribute11              := p_x_recipient_tbl(i).attribute11;
        l_recipient_tbl(i).attribute12              := p_x_recipient_tbl(i).attribute12;
        l_recipient_tbl(i).attribute13              := p_x_recipient_tbl(i).attribute13;
        l_recipient_tbl(i).attribute14              := p_x_recipient_tbl(i).attribute14;
        l_recipient_tbl(i).attribute15              := p_x_recipient_tbl(i).attribute15;
        l_recipient_tbl(i).delete_flag              := p_x_recipient_tbl(i).delete_flag;
        l_recipient_tbl(i).object_version_number    := p_x_recipient_tbl(i).object_version_number;
   --Standard check for count messages
/*
--{{adharia
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
--}}adharia
*/

  END LOOP;
 END IF;
 END IF;
 END LOOP;
END IF;


/*-----------------------------------------------------------*/
/* procedure name: AHL_DI_DOC_INDEX_CHUK.MODIFY_DOCUMENT_PRE */
/*         AHL_DI_DOC_INDEX_VHUK.MODIFY_DOCUMENT_PRE */
/*                               */
/* description   : Added by Siddhartha to call User Hooks    */
/*      Date     : Dec 28 2001                               */
/*-----------------------------------------------------------*/


IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_DOC_INDEX_PUB','MODIFY_DOCUMENT',
                    'B', 'C' )  then
      AHL_DEBUG_PUB.debug( 'Start AHL_DI_DOC_INDEX_CUHK.MODIFY_DOCUMENT_PRE');

AHL_DI_DOC_INDEX_CUHK.MODIFY_DOCUMENT_PRE
(

     p_x_document_tbl            =>     l_document_tbl ,
     p_x_supplier_tbl            =>     l_supplier_tbl,
     p_x_recipient_tbl           =>     l_recipient_tbl,
     x_return_status             =>     l_return_status,
     x_msg_count                 =>     l_msg_count   ,
     x_msg_data                  =>     l_msg_data
);


     AHL_DEBUG_PUB.debug( 'End AHL_DI_DOC_INDEX_CUHK.MODIFY_DOCUMENT_PRE');


            IF   l_return_status = FND_API.G_RET_STS_ERROR  THEN
                RAISE FND_API.G_EXC_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
END IF;

IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_DOC_INDEX_PUB','MODIFY_DOCUMENT',
                    'B', 'V' )  then

      AHL_DEBUG_PUB.debug( 'Start AHL_DI_DOC_INDEX_VUHK.MODIFY_DOCUMENT_PRE');

            AHL_DI_DOC_INDEX_VUHK.MODIFY_DOCUMENT_PRE
        (
            p_x_document_tbl    =>  l_document_tbl ,
            p_x_supplier_tbl        =>  l_supplier_tbl,
            p_x_recipient_tbl       =>  l_recipient_tbl,
            X_RETURN_STATUS         =>  l_return_status       ,
            X_MSG_COUNT             =>  l_msg_count           ,
            X_MSG_DATA              =>  l_msg_data  );

            IF   l_return_status = FND_API.G_RET_STS_ERROR  THEN
                RAISE FND_API.G_EXC_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

     AHL_DEBUG_PUB.debug( 'End AHL_DI_DOC_INDEX_VUHK.MODIFY_DOCUMENT_PRE');

END IF;


/*---------------------------------------------------------*/
/*     End ; Date     : Dec 28 2001                        */
/*---------------------------------------------------------*/




  -- Call the Private API
--{{adharia
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
--{{adharia

   AHL_DI_DOC_INDEX_PVT.MODIFY_DOCUMENT
                        (
                         p_api_version        => 1.0,
                         p_init_msg_list      => p_init_msg_list,
                         p_commit             => p_commit,
                         p_validate_only      => p_validate_only,
                         p_validation_level   => p_validation_level,
                         p_x_document_tbl     => l_document_tbl,
                         p_x_supplier_tbl     => l_supplier_tbl,
                         p_x_recipient_tbl    => l_recipient_tbl,
                         x_return_status      => l_return_status,
                         x_msg_count          => l_msg_count,
                         x_msg_data           => l_msg_data
                         );
   --Standard check for count messages
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




/*----------------------------------------------------------------------------- */
/* procedure name: AHL_DI_DOC_INDEX_VHUK.MODIFY_DOCUMENT_POST           */
/*         AHL_DI_DOC_INDEX_CHUK.MODIFY_DOCUMENT_POST           */
/*                                          */
/* description   :  Added by ssaklani to call User Hooks            */
/*      Date     : Dec 28 2001                                      */
/*------------------------------------------------------------------------------*/



IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_DOC_INDEX_PUB','MODIFY_DOCUMENT','A', 'V' )
    then
  AHL_DEBUG_PUB.debug( 'Start AHL_DI_DOC_INDEX_VUHK.MODIFY_DOCUMENT_POST');

            AHL_DI_DOC_INDEX_VUHK.MODIFY_DOCUMENT_POST
        (
            p_document_tbl      =>  l_document_tbl ,
            p_supplier_tbl      =>  l_supplier_tbl,
            p_recipient_tbl     =>  l_recipient_tbl,
            X_RETURN_STATUS         =>  l_return_status      ,
            X_MSG_COUNT             =>  l_msg_count           ,
            X_MSG_DATA              =>  l_msg_data  );

            IF   l_return_status = FND_API.G_RET_STS_ERROR  THEN
                RAISE FND_API.G_EXC_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

   AHL_DEBUG_PUB.debug( 'End AHL_DI_DOC_INDEX_VUHK.MODIFY_DOCUMENT_POST');

END IF;

IF   JTF_USR_HKS.Ok_to_Execute( 'AHL_DI_DOC_INDEX_PUB','MODIFY_DOCUMENT','A', 'C' )
    then

   AHL_DEBUG_PUB.debug( 'Start AHL_DI_DOC_INDEX_CUHK.MODIFY_DOCUMENT_POST');

AHL_DI_DOC_INDEX_CUHK.MODIFY_DOCUMENT_POST(

            p_document_tbl      =>  l_document_tbl ,
            p_supplier_tbl      =>  l_supplier_tbl,
            p_recipient_tbl     =>  l_recipient_tbl,
            X_RETURN_STATUS         =>  l_return_status,
            X_MSG_COUNT             =>  l_msg_count,
            X_MSG_DATA              =>  l_msg_data);



            IF   l_return_status = FND_API.G_RET_STS_ERROR  THEN
                RAISE FND_API.G_EXC_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

 AHL_DEBUG_PUB.debug( 'End AHL_DI_DOC_INDEX_CUHK.MODIFY_DOCUMENT_POST');

END IF;

/*---------------------------------------------------------*/
/*     End ; Date     : Dec 28 2001                        */
/*---------------------------------------------------------*/




   --Standard check for commit
   IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   -- Debug info
   AHL_DEBUG_PUB.debug( 'End of public api Modify Document','+DI+');
   -- Check if API is called in debug mode. If yes, disable debug.
   AHL_DEBUG_PUB.disable_debug;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO modify_document;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
        IF AHL_DEBUG_PUB.G_FILE_DEBUG THEN
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_index_pub.Modify Document','+DI+');
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO modify_document;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
        IF AHL_DEBUG_PUB.G_FILE_DEBUG THEN
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_index_pub.Modify Document','+DI+');
        END IF;
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;

 WHEN OTHERS THEN
    ROLLBACK TO modify_document;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DOCUMENTS_PUB',
                            p_procedure_name  =>  'MODIFY_DOCUMENT',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
        IF AHL_DEBUG_PUB.G_FILE_DEBUG THEN
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_index_pub.Modify Document','+DI+');
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;

 END MODIFY_DOCUMENT;

END AHL_DI_DOC_INDEX_PUB;

/
