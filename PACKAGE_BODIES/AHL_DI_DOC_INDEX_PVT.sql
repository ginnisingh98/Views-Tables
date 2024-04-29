--------------------------------------------------------
--  DDL for Package Body AHL_DI_DOC_INDEX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_DI_DOC_INDEX_PVT" AS
/* $Header: AHLVDIXB.pls 120.2.12010000.4 2010/04/19 06:47:03 pekambar ship $ */
--
G_PKG_NAME  VARCHAR2(30)  := 'AHL_DI_DOC_INDEX_PVT';
G_DEBUG          VARCHAR2(1):=AHL_DEBUG_PUB.is_log_enabled;
--
/* ===========================================================================
G_DEBUG          VARCHAR2(1):=AHL_DEBUG_PUB.is_log_enabled;
  FUNCTION NAME : get_product_install_status (x_product_name IN VARCHAR2)
                                                RETURN VARCHAR2

  DESCRIPTION   : Returns the product's installation status

  CLIENT/SERVER : SERVER

  PARAMETERS    : x_product_name - Name of the product
                  For eg - 'PER','PO','ENG'

  ALGORITHM     : Use fnd_installation.get function to retreive
                  the status of product installation.
                  Function expects product id to be passed
                  Product Id will be derived from FND_APPLICATION table
                  Product       Product Id
                  --------      -----------
                  INV           401
                  PO            201

  NOTES         : valid installation status:
                  I - Product is installed
                  S - Product is partially installed
                  N - Product is not installed
                  L - Product is a local (custom) application


=========================================================================== */

FUNCTION get_product_install_status ( x_product_name IN VARCHAR2) RETURN VARCHAR2 IS
  x_progress     VARCHAR2(3) := NULL;
  x_app_id       NUMBER;
  x_install      BOOLEAN;
  x_status       VARCHAR2(1);
  x_org          VARCHAR2(1);
  x_temp_product_name varchar2(10);
BEGIN
  --Retreive product id from fnd_application based on product name
  x_progress := 10;

  SELECT application_id
  INTO   x_app_id
  FROM   fnd_application
  WHERE application_short_name = x_product_name ;

  --get product installation status
  x_progress := 20;
  x_install := fnd_installation.get(x_app_id,x_app_id,x_status,x_org);

  if x_product_name in ('OE', 'ONT') then

    if Oe_install.get_active_product() in ('OE', 'ONT') then
        x_status := 'I';
    else
        x_status := 'N';
    end if;
  end if;

  RETURN(x_status);

  EXCEPTION
    WHEN NO_DATA_FOUND then
      null;
      RETURN(null);
    WHEN OTHERS THEN
    po_message_s.sql_error('get_product_install_status', x_progress, sqlcode);
      RAISE;

END get_product_install_status;

/*---------------------------------------------------------*/
/* procedure name: validate_document(private procedure)    */
/* description :  Validation checks for before inserting   */
/*                new record as well before modification   */
/*                takes place                              */
/*---------------------------------------------------------*/

PROCEDURE VALIDATE_DOCUMENT
(
 p_document_id           IN   NUMBER    ,
 p_source_party_id       IN   NUMBER    ,
 p_doc_type_code         IN   VARCHAR2  ,
 p_doc_sub_type_code     IN   VARCHAR2  ,
 p_document_no           IN   VARCHAR2  ,
 p_operator_code         IN   VARCHAR2  ,
 p_product_type_code     IN   VARCHAR2  ,
 p_subscribe_avail_flag  IN   VARCHAR2  ,
 p_subscribe_to_flag     IN   VARCHAR2  ,
 p_object_version_number IN   NUMBER    ,
 p_delete_flag           IN   VARCHAR2  := 'N'
 )
 IS
  -- Cursor to retrieve doc type code from fnd lookups
  CURSOR get_doc_type_code(c_doc_type_code VARCHAR2)
   IS
  SELECT lookup_code
    FROM FND_LOOKUPS
   WHERE lookup_code = c_doc_type_code
     AND lookup_type = 'AHL_DOC_TYPE'
     AND ENABLED_FLAG = 'Y'
 -- pbarman April 2003
     AND sysdate between nvl(start_date_active,sysdate)
     AND nvl(end_date_active,sysdate);
   --Cursor to retrieve doc sub type code from fnd lookups
   CURSOR get_doc_sub_type_code(c_doc_sub_type_code VARCHAR2)
    IS
   SELECT lookup_code
     FROM FND_LOOKUPS
    WHERE lookup_code = c_doc_sub_type_code
      AND lookup_type = 'AHL_DOC_SUB_TYPE'
      AND ENABLED_FLAG = 'Y'
-- pbarman April 2003
      AND sysdate between nvl(start_date_active,sysdate)
      AND nvl(end_date_active,sysdate);
   --Cursor to retrieve operator code from fnd lookups
   --CURSOR get_operator_code(c_operator_code VARCHAR2)
   -- IS
   --SELECT lookup_code
   --  FROM FND_LOOKUPS
   -- WHERE lookup_code = c_operator_code
   --   AND lookup_type = 'AHL_OPERATOR_TYPE'
   --   AND sysdate between nvl(start_date_active,sysdate)
   --     AND nvl(end_date_active,sysdate);

   --Cursor to retrieve operator code from hz parties
   --Enhancement no #2275357 : pbarman : April 2003
   CURSOR get_operator_code_hz(c_operator_code VARCHAR2)
    IS
   SELECT party_id
   FROM HZ_PARTIES
   WHERE party_id = c_operator_code
   AND ( party_type ='ORGANIZATION' or party_type = 'PERSON' );


   --Cursor to retrieve product type code from fnd lookups

   CURSOR get_product_type_code(c_product_type_code VARCHAR2)
    IS
   SELECT lookup_code
     FROM FND_LOOKUP_VALUES_VL
    WHERE lookup_code = c_product_type_code
--Enhancement #2525604: pbarman : April 2003
      AND lookup_type = 'ITEM_TYPE'

      AND sysdate between nvl(start_date_active,sysdate)
      AND nvl(end_date_active,sysdate)
      AND enabled_flag = 'Y'
      AND view_Application_id = 3;

   --Cursor to used retrieve the record from base table
   CURSOR get_doc_rec_b_info (c_document_id NUMBER)
    IS
   SELECT source_party_id,
          doc_type_code,
          doc_sub_type_code,
          document_no,
          operator_code,
          product_type_code,
          subscribe_avail_flag,
          subscribe_to_flag
     FROM AHL_DOCUMENTS_B
   WHERE document_id = c_document_id;

  CURSOR get_sub_type_exists(c_doc_type_code VARCHAR2,
                         c_doc_sub_type_code VARCHAR2)
        IS
        SELECT doc_sub_type_code
        FROM AHL_DOCUMENT_SUB_TYPES
        WHERE doc_type_code like c_doc_type_code
        AND doc_sub_type_code like c_doc_sub_type_code;

  -- Cursor used to verify for duplicate record based on document no
  CURSOR dup_rec(c_source_party_id  NUMBER,
                 c_document_no  VARCHAR2)
   IS
  SELECT 'X'
    FROM AHL_DOCUMENTS_B
   WHERE document_no  = c_document_no
     AND source_party_id    = c_source_party_id;


  l_api_name     CONSTANT VARCHAR2(30) := 'VALIDATE_DOCUMENT';
  l_api_version  CONSTANT NUMBER       := 1.0;
  l_dummy                 VARCHAR2(2000);
  l_document_id           NUMBER;
  l_source_party_id       NUMBER;
  l_doc_type_code         VARCHAR2(30);
  l_doc_sub_type_code     VARCHAR2(30);
  l_document_no           VARCHAR2(30);
  l_operator_code         VARCHAR2(30);
  l_product_type_code     VARCHAR2(30);
  l_subscribe_avail_flag  VARCHAR2(1);
  l_subscribe_to_flag     VARCHAR2(1);
  l_delete_flag           VARCHAR2(1);
BEGIN
   --When the action is insert or update
   -- Check if API is called in debug mode. If yes, enable debug.
        /*FND_MESSAGE.SET_NAME('AHL','i am in validate'|| p_Delete_flag);
        FND_MSG_PUB.ADD;
   */
   l_delete_flag := nvl(p_delete_flag, 'N');

   AHL_DEBUG_PUB.enable_debug;
   -- Debug info.
   IF AHL_DEBUG_PUB.G_FILE_DEBUG THEN
      AHL_DEBUG_PUB.debug( 'enter ahl_di_doc_index_pvt.VALIDATE_DOCUMENT','+DI+');
   END IF;
   IF l_delete_flag  <> 'Y'
   THEN
       IF p_document_id IS NOT NULL
    THEN
       OPEN get_doc_rec_b_info (p_document_id);
       FETCH get_doc_rec_b_info  INTO l_source_party_id, l_doc_type_code,
                                     l_doc_sub_type_code,l_document_no,
                                     l_operator_code, l_product_type_code,
                                     l_subscribe_avail_flag,
                                     l_subscribe_to_flag;
       CLOSE get_doc_rec_b_info;
    END IF;
    --
    IF p_document_id IS NOT NULL
    THEN
        l_document_id := p_document_id;
    END IF;
    --
    IF p_source_party_id IS NOT NULL
    THEN
        l_source_party_id := p_source_party_id;
    END IF;
    --
    IF p_doc_type_code IS NOT NULL
    THEN
        l_doc_type_code := p_doc_type_code;
    END IF;
    --
    IF p_doc_sub_type_code IS NOT NULL
    THEN
        l_doc_sub_type_code := p_doc_sub_type_code;
    END IF;
    --
    IF p_document_no IS NOT NULL
    THEN
        l_document_no := p_document_no;
    END IF;
    --
    IF p_operator_code IS NOT NULL
    THEN
        l_operator_code := p_operator_code;
    END IF;
    --
   IF p_product_type_code IS NOT NULL
    THEN
        l_product_type_code := p_product_type_code;
    END IF;
    --
    IF p_subscribe_avail_flag IS NOT NULL
    THEN
        l_subscribe_avail_flag := p_subscribe_avail_flag;
    END IF;
    --
    IF p_subscribe_to_flag IS NOT NULL
    THEN
        l_subscribe_to_flag := p_subscribe_to_flag;
    END IF;
    --

    IF p_document_id IS NULL THEN
       l_document_id := null;
    ELSE
       l_document_id := p_document_id;
    END IF;
    --This condition checks for Source Party Id
     IF ((p_document_id IS NULL AND
         p_source_party_id IS NULL)
        OR
        (p_document_id IS NOT NULL
        AND l_source_party_id IS NULL))
     THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_DI_SOURCE_PARTY_ID_NULL');
        FND_MSG_PUB.ADD;
     END IF;
     --This condition checks for doc type code
     IF ((p_document_id IS NULL AND
         p_doc_type_code IS NULL)
         OR
        (p_document_id IS NOT NULL
        AND l_doc_type_code IS NULL))
     THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_TYPE_CODE_NULL');
        FND_MSG_PUB.ADD;
     END IF;
     --This condition checks for document number
     IF ((p_document_id IS NULL AND
          p_document_no IS NULL)
        OR
        (p_document_id IS NOT NULL
        AND l_document_no IS NULL))
     THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOCUMENT_NO_NULL');
        FND_MSG_PUB.ADD;
     END IF;
     --This condition checks for Subscriptions available flag
     IF ((p_document_id IS NULL AND
         p_subscribe_avail_flag IS NULL)
        OR
        (p_document_id IS NOT NULL
        AND l_subscribe_avail_flag IS NULL))
     THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUBSC_AVAIL_FLAG_NULL');
        FND_MSG_PUB.ADD;
     END IF;
      --This condition checks for subscribe to flag
     IF ((p_document_id IS NULL AND
         p_subscribe_to_flag IS NULL)
        OR
        (p_document_id IS NOT NULL
        AND l_subscribe_to_flag IS NULL))
     THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUBSC_TO_FLAG_NULL');
        FND_MSG_PUB.ADD;
     END IF;
     --Modified pjha 25-Jun-2002 for restricting Subscription available based on Subscribed To : Begin
     /*
     IF (l_subscribe_to_flag = 'Y' AND l_subscribe_avail_flag = 'N')
     THEN
       FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUBSC_AVAIL_FLAG_NO');
       FND_MSG_PUB.ADD;
     END IF;
    --Modified pjha 25-Jun-2002 for restricting Subscription available based on Subscribed To : End

    --Added pjha 02-Jul-2002 for Restricting Subscription Avail to 'Yes' If supplier
    --Exists for the doc: Begin
    IF (l_subscribe_avail_flag = 'N' AND p_document_id IS NOT NULL)
    THEN
      OPEN check_sup_exists(p_document_id);
      FETCH check_sup_exists INTO l_dummy;
      IF check_sup_exists%FOUND
      THEN
         FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUPPLIER_EXISTS');
     FND_MSG_PUB.ADD;
      END IF;
      CLOSE check_sup_exists;
    END IF;
    */
    --Added pjha 02-Jul-2002 for Restricting Subscription Avail to 'Yes' If supplier
    --Exists for the doc: End

     --This condition checks for existence of doc type code in fnd lookups     \

    IF p_doc_type_code IS NOT NULL
    THEN
       OPEN get_doc_type_code(p_doc_type_code);
       FETCH get_doc_type_code INTO l_dummy;
       IF get_doc_type_code%NOTFOUND
       THEN
          FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_TYPE_CODE_NOT_EXIST');
          FND_MSG_PUB.ADD;
        END IF;
        CLOSE get_doc_type_code;
     END IF;
     --Checks for sub type code in fnd lookups


     IF p_doc_sub_type_code IS NOT NULL
     THEN
        OPEN get_doc_sub_type_code(p_doc_sub_type_code);
        FETCH get_doc_sub_type_code INTO l_dummy;
        IF get_doc_sub_type_code%NOTFOUND
        THEN
           FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_SUBT_COD_NOT_EXISTS');
           FND_MSG_PUB.ADD;
         END IF;
     CLOSE get_doc_sub_type_code;
    -- Checks for sub_type_Code in ahl_document_subtypes
     OPEN get_sub_type_exists(p_doc_type_code, p_doc_sub_type_code);
      FETCH get_sub_type_exists INTO l_dummy;
      IF get_sub_type_exists%NOTFOUND
            THEN
             FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_SUBT_COD_NOT_EXISTS');
             FND_MSG_PUB.ADD;
          END IF;

          CLOSE get_sub_type_exists;
 END IF;
      --Checks for Operator code in fnd lookups
     IF p_operator_code IS NOT NULL
     THEN
--Enhancement no #2275357 : pbarman : April 2003
        OPEN get_operator_code_hz(p_operator_code);
        FETCH get_operator_code_hz INTO l_dummy;
        IF get_operator_code_hz%NOTFOUND
        THEN
           FND_MESSAGE.SET_NAME('AHL','AHL_DI_OPERATOR_CODE_NOT_EXIST');
           FND_MSG_PUB.ADD;
        END IF;
        CLOSE get_operator_code_hz;

      END IF;
     --Checks for Product Type Code
     IF p_product_type_code IS NOT NULL
     THEN
        OPEN get_product_type_code(p_product_type_code);
        FETCH get_product_type_code INTO l_dummy;
        IF get_product_type_code%NOTFOUND
        THEN
           FND_MESSAGE.SET_NAME('AHL','AHL_DI_PRODTYPE_CODE_NOT_EXIST');
           FND_MSG_PUB.ADD;
        END IF;
        CLOSE get_product_type_code;
      END IF;
     --Checks for Duplicate Record
    IF p_document_id IS NULL
    THEN
       OPEN dup_rec(l_source_party_id ,l_document_no);
       FETCH dup_rec INTO l_dummy;
          IF dup_rec%FOUND THEN
          FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOCUMENT_DUP_RECORD');
          FND_MSG_PUB.ADD;
          END IF;
      CLOSE dup_rec;
    END IF;


 END IF;
 IF AHL_DEBUG_PUB.G_FILE_DEBUG THEN
       AHL_DEBUG_PUB.debug( 'exit ahl_di_doc_index_pvt.VALIDATE_DOCUMENT','+DI+');
   END IF;
 --
 END VALIDATE_DOCUMENT;
/*------------------------------------------------------*/
/* procedure name: create_document                      */
/* description :  Creates new document record and its   */
/*                suppliers, recipients/*                                                      */
/*------------------------------------------------------*/

 PROCEDURE CREATE_DOCUMENT
 (
 p_api_version               IN     NUMBER    := 1.0               ,
 p_init_msg_list             IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                    IN     VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only             IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level          IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_document_tbl            IN OUT NOCOPY Document_Tbl              ,
 p_x_supplier_tbl            IN OUT NOCOPY Supplier_Tbl              ,
 p_x_recipient_tbl           IN OUT NOCOPY Recipient_Tbl             ,
 x_return_status                OUT NOCOPY VARCHAR2                         ,
 x_msg_count                    OUT NOCOPY NUMBER                           ,
 x_msg_data                     OUT NOCOPY VARCHAR2)
 IS
 -- Cursor to check for uniqueness
 CURSOR unique_rec(c_document_no  VARCHAR2)
   IS
 SELECT 'X'
    FROM AHL_DOCUMENTS_B
   WHERE document_no  = c_document_no;
 --
 l_api_name     CONSTANT VARCHAR2(30) := 'CREATE_DOCUMENT';
 l_api_version  CONSTANT NUMBER       := 1.0;
 l_num_rec               NUMBER;
 l_msg_count             NUMBER;
 l_dummy                 VARCHAR2(2000);
 l_rowid                 ROWID;
 l_document_id           NUMBER;
 l_document_info         doc_rec;
 l_rowid1   varchar2(30);
 BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT create_document;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.enable_debug;

    END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug( 'enter ahl_di_doc_index_pvt.create_document','+DI+');

    END IF;
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
   --Starts API Body
   IF p_x_document_tbl.COUNT > 0
   THEN
     FOR i IN p_x_document_tbl.FIRST..p_x_document_tbl.LAST
     LOOP
        VALIDATE_DOCUMENT
        (
          p_document_id           => p_x_document_tbl(i).document_id,
          p_source_party_id       => p_x_document_tbl(i).source_party_id,
          p_doc_type_code         => p_x_document_tbl(i).doc_type_code,
          p_doc_sub_type_code     => p_x_document_tbl(i).doc_sub_type_code,
          p_document_no           => p_x_document_tbl(i).document_no,
          p_operator_code         => p_x_document_tbl(i).operator_code,
          p_product_type_code     => p_x_document_tbl(i).product_type_code,
          p_subscribe_avail_flag  => p_x_document_tbl(i).subscribe_avail_flag,
          p_subscribe_to_flag     => p_x_document_tbl(i).subscribe_to_flag,
          p_object_version_number => p_x_document_tbl(i).object_version_number,
          p_delete_flag           => p_x_document_tbl(i).delete_flag);

     END LOOP;
   --Standard Call to count messages
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   FOR i IN p_x_document_tbl.FIRST..p_x_document_tbl.LAST
   LOOP
     IF  p_x_document_tbl(i).document_id IS NULL
     THEN
         -- Thease conditions are required for optional fields, Frequency code

           l_document_info.doc_sub_type_code := p_x_document_tbl(i).doc_sub_type_code;
           l_document_info.operator_code := p_x_document_tbl(i).operator_code;
           l_document_info.product_type_code := p_x_document_tbl(i).product_type_code;
           l_document_info.document_title := p_x_document_tbl(i).document_title;
           l_document_info.attribute_category := p_x_document_tbl(i).attribute_category;
           l_document_info.attribute1 := p_x_document_tbl(i).attribute1;
           l_document_info.attribute2 := p_x_document_tbl(i).attribute2;
           l_document_info.attribute3 := p_x_document_tbl(i).attribute3;
           l_document_info.attribute4 := p_x_document_tbl(i).attribute4;
           l_document_info.attribute5 := p_x_document_tbl(i).attribute5;
           l_document_info.attribute6 := p_x_document_tbl(i).attribute6;
           l_document_info.attribute7 := p_x_document_tbl(i).attribute7;
           l_document_info.attribute8 := p_x_document_tbl(i).attribute8;
           l_document_info.attribute9 := p_x_document_tbl(i).attribute9;
           l_document_info.attribute10 := p_x_document_tbl(i).attribute10;
           l_document_info.attribute11 := p_x_document_tbl(i).attribute11;
           l_document_info.attribute12 := p_x_document_tbl(i).attribute12;
           l_document_info.attribute13 := p_x_document_tbl(i).attribute13;
           l_document_info.attribute14 := p_x_document_tbl(i).attribute14;
           l_document_info.attribute15 := p_x_document_tbl(i).attribute15;
        --Check for uniquences
       OPEN unique_rec(p_x_document_tbl (i).document_no);
       FETCH unique_rec INTO l_dummy;
          IF unique_rec%FOUND THEN
          FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOCUMENT_DUP_RECORD');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
          END IF;
      CLOSE unique_rec;
    -- Get the sequence number

    SELECT  AHL_DOCUMENTS_B_S.Nextval INTO
           l_document_id from DUAL;
/*-------------------------------------------------------- */
/* procedure name: AHL_DI_DOCUMENTS_PKG.INSERT_ROW         */
/* description   :  Added by Senthil to call Table Handler */
/*      Date     : Dec 07 2001                             */
/*---------------------------------------------------------*/

AHL_DOCUMENTS_PKG.INSERT_ROW(
X_ROWID                         =>      l_rowid1    ,
X_DOCUMENT_ID                   =>  l_document_id,
X_SUBSCRIBE_AVAIL_FLAG          =>  p_x_document_tbl (i).subscribe_avail_flag,
X_SUBSCRIBE_TO_FLAG             =>  p_x_document_tbl (i).subscribe_to_flag   ,
X_DOC_TYPE_CODE                 =>  p_x_document_tbl (i).doc_type_code,
X_DOC_SUB_TYPE_CODE             =>  l_document_info.doc_sub_type_code,
X_OPERATOR_CODE                 =>  l_document_info.operator_code,
X_PRODUCT_TYPE_CODE             =>  l_document_info.product_type_code,
X_ATTRIBUTE_CATEGORY            =>  l_document_info.attribute_category ,
X_ATTRIBUTE1                    =>  l_document_info.attribute1,
X_ATTRIBUTE2                    =>  l_document_info.attribute2,
X_ATTRIBUTE3                    =>  l_document_info.attribute3,
X_ATTRIBUTE4                    =>  l_document_info.attribute4,
X_ATTRIBUTE5                    =>  l_document_info.attribute5,
X_ATTRIBUTE6                    =>  l_document_info.attribute6,
X_ATTRIBUTE7                    =>  l_document_info.attribute7,
X_ATTRIBUTE8                    =>  l_document_info.attribute8,
X_ATTRIBUTE9                    =>  l_document_info.attribute9,
X_ATTRIBUTE10                   =>  l_document_info.attribute10,
X_ATTRIBUTE11                   =>  l_document_info.attribute11,
X_ATTRIBUTE12                   =>  l_document_info.attribute12,
X_ATTRIBUTE13                   =>  l_document_info.attribute13,
X_ATTRIBUTE14                   =>  l_document_info.attribute14,
X_ATTRIBUTE15                   =>  l_document_info.attribute15,
X_OBJECT_VERSION_NUMBER         =>  1,
X_SOURCE_PARTY_ID               =>  p_x_document_tbl (i).source_party_id,
X_DOCUMENT_NO                   =>  p_x_document_tbl (i).document_no,
X_DOCUMENT_TITLE                =>  l_document_info.document_title,
X_CREATION_DATE                 =>  sysdate ,
X_CREATED_BY                    =>  fnd_global.user_id,
X_LAST_UPDATE_DATE              =>  sysdate ,
X_LAST_UPDATED_BY               =>  fnd_global.user_id,
X_LAST_UPDATE_LOGIN             =>  fnd_global.login_id

);
-- Assign the value for out parameter
     p_x_document_tbl(i).document_id := l_document_id;

   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
  --
  END IF;
 END LOOP;
END IF;
-- Debug info.
IF G_DEBUG='Y' THEN
     IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug( 'Before processing Supplier Record ahl_di_doc_index_pvt.create_document','+DI+');

    END IF;
END IF;
-- Checks for any suppliers exists for the document index
IF p_x_supplier_tbl.COUNT > 0 THEN
     create_supplier
     ( p_api_version      => p_api_version       ,
       p_init_msg_list    => FND_API.G_TRUE      ,
       p_commit           => FND_API.G_FALSE     ,
       p_validate_only    => FND_API.G_TRUE      ,
       p_validation_level => FND_API.G_VALID_LEVEL_FULL,
       p_x_supplier_tbl   => p_x_supplier_tbl    ,
       x_return_status    => x_return_status     ,
       x_msg_count        => x_msg_count         ,
       x_msg_data         => x_msg_data
     );
END IF;
 -- Debug info.
 IF G_DEBUG='Y' THEN
      IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug( 'Before processing Recipient Record ahl_di_doc_index_pub.create_document','+DI+');

    END IF;
 END IF;
-- Checks for any Recipients exists for the document index
IF p_x_recipient_tbl.COUNT > 0 THEN
     create_recipient
     ( p_api_version      => p_api_version       ,
       p_init_msg_list    => FND_API.G_TRUE      ,
       p_commit           => FND_API.G_FALSE     ,
       p_validate_only    => FND_API.G_TRUE      ,
       p_validation_level => FND_API.G_VALID_LEVEL_FULL,
       p_x_recipient_tbl  => p_x_recipient_tbl   ,
       x_return_status    => x_return_status     ,
       x_msg_count        => x_msg_count         ,
       x_msg_data         => x_msg_data
     );
END IF;
   --Standard check for message count
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
 --Standard check for commit;
IF FND_API.TO_BOOLEAN(p_commit) THEN
   COMMIT;
  --DBMS_OUTPUT.PUT_LINE('THE RECORD IS NOT COMMITTED .THE TEST RUN HAS BEEN SUCESSFUL');
  --ROLLBACK;
END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_document;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_index_pvt.create document','+DI+');


        -- Check if API is called in debug mode. If yes, disable debug.

          AHL_DEBUG_PUB.disable_debug;

    END IF;
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO create_document;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_index_pvt.create document','+DI+');



        -- Check if API is called in debug mode. If yes, disable debug.

           AHL_DEBUG_PUB.disable_debug;

    END IF;
 WHEN OTHERS THEN
    ROLLBACK TO create_document;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_DOC_INDEX_PVT',
                            p_procedure_name  =>  'CREATE_DOCUMENT',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_index_pvt.create document','+DI+');



        -- Check if API is called in debug mode. If yes, disable debug.

           AHL_DEBUG_PUB.disable_debug;

    END IF;
END CREATE_DOCUMENT;
/*------------------------------------------------------*/
/* procedure name: modify_document                      */
/* description :  Updates the  document record and its  */
/*                associated suppliers, recipients      */
/*                                                      */
/*------------------------------------------------------*/

PROCEDURE MODIFY_DOCUMENT
(
 p_api_version               IN     NUMBER    := 1.0              ,
 p_init_msg_list             IN     VARCHAR2  := FND_API.G_TRUE     ,
 p_commit                    IN     VARCHAR2  := FND_API.G_FALSE    ,
 p_validate_only             IN     VARCHAR2  := FND_API.G_TRUE     ,
 p_validation_level          IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_document_tbl            IN OUT NOCOPY document_tbl             ,
 p_x_supplier_tbl            IN OUT NOCOPY Supplier_Tbl              ,
 p_x_recipient_tbl           IN OUT NOCOPY Recipient_Tbl             ,
 x_return_status                OUT NOCOPY VARCHAR2                         ,
 x_msg_count                    OUT NOCOPY NUMBER                           ,
 x_msg_data                     OUT NOCOPY VARCHAR2
 )
 IS
 --Used to retrieve the existing record
 CURSOR get_doc_rec_b_info(c_document_id  NUMBER)
  IS
 SELECT ROWID,
        document_id,
        source_party_id,
        doc_type_code,
        doc_sub_type_code,
        document_no,
        operator_code,
        product_type_code,
        subscribe_avail_flag,
        subscribe_to_flag,
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
   FROM AHL_DOCUMENTS_B
  WHERE document_id = c_document_id;
--FOR UPDATE OF object_version_number NOWAIT;

--
l_api_name     CONSTANT VARCHAR2(30) := 'MODIFY_DOCUMENT';
l_api_version  CONSTANT NUMBER       := 1.0;
l_msg_count             NUMBER;
l_num_rec               NUMBER;
l_rowid                 ROWID;
--l_document_title        VARCHAR2(80);
l_document_title        VARCHAR2(240);
l_document_info         get_doc_rec_b_info%ROWTYPE;
--
l_num          VARCHAR2(10);
 BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT modify_document;

   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.enable_debug;

    END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug( 'enter ahl_di_doc_index_pvt.modify_document','+DI+');

    END IF;
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


   --Start API Body
   IF p_x_document_tbl.COUNT > 0
   THEN
     FOR i IN p_x_document_tbl.FIRST..p_x_document_tbl.LAST
     LOOP


        VALIDATE_DOCUMENT(
          p_document_id           => p_x_document_tbl(i).document_id,
          p_source_party_id       => p_x_document_tbl(i).source_party_id,
          p_doc_type_code         => p_x_document_tbl(i).doc_type_code,
          p_doc_sub_type_code     => p_x_document_tbl(i).doc_sub_type_code,
          p_document_no           => p_x_document_tbl(i).document_no,
          p_operator_code         => p_x_document_tbl(i).operator_code,
          p_product_type_code     => p_x_document_tbl(i).product_type_code,
          p_subscribe_avail_flag  => p_x_document_tbl(i).subscribe_avail_flag,
          p_subscribe_to_flag     => p_x_document_tbl(i).subscribe_to_flag,
          p_object_version_number => p_x_document_tbl(i).object_version_number,
          p_delete_flag           => p_x_document_tbl(i).delete_flag);


     END LOOP;
   --Standard check to count messages
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;


 FOR i IN p_x_document_tbl.FIRST..p_x_document_tbl.LAST
 LOOP
    OPEN get_doc_rec_b_info(p_x_document_tbl(i).document_id);
    FETCH get_doc_rec_b_info INTO l_document_info;
    CLOSE get_doc_rec_b_info;

    --

     --pekambar changes for bug # 9226988 --start
    if (p_x_document_tbl(i).attribute1 IS NULL ) THEN
       p_x_document_tbl(i).attribute1 :=  l_document_info.attribute1;
    ELSIF(p_x_document_tbl(i).attribute1 = FND_API.G_MISS_CHAR ) THEN
       p_x_document_tbl(i).attribute1 :=  NULL;
    END IF;
    if (p_x_document_tbl(i).attribute2 IS NULL ) THEN
       p_x_document_tbl(i).attribute2 :=  l_document_info.attribute2;
    ELSIF(p_x_document_tbl(i).attribute2 = FND_API.G_MISS_CHAR) THEN
       p_x_document_tbl(i).attribute2 :=  NULL;
    END IF;
    if (p_x_document_tbl(i).attribute3 IS NULL ) THEN
       p_x_document_tbl(i).attribute3 :=  l_document_info.attribute3;
    ELSIF(p_x_document_tbl(i).attribute3 = FND_API.G_MISS_CHAR ) THEN
       p_x_document_tbl(i).attribute3 :=  l_document_info.attribute1;
    END IF;
    if (p_x_document_tbl(i).attribute4 IS NULL ) THEN
       p_x_document_tbl(i).attribute4 :=  l_document_info.attribute4;
    ELSIF(p_x_document_tbl(i).attribute4 = FND_API.G_MISS_CHAR ) THEN
       p_x_document_tbl(i).attribute4 := NULL;
    END IF;
    if (p_x_document_tbl(i).attribute5 IS NULL ) THEN
       p_x_document_tbl(i).attribute5 :=  l_document_info.attribute5;
    ELSIF(p_x_document_tbl(i).attribute5 = FND_API.G_MISS_CHAR ) THEN
       p_x_document_tbl(i).attribute5 :=  NULL;
    END IF;
    if (p_x_document_tbl(i).attribute6 IS NULL ) THEN
       p_x_document_tbl(i).attribute6:=  l_document_info.attribute6;
    ELSIF(p_x_document_tbl(i).attribute6 = FND_API.G_MISS_CHAR ) THEN
       p_x_document_tbl(i).attribute6 :=  NULL;
    END IF;
    if (p_x_document_tbl(i).attribute7 IS NULL ) THEN
       p_x_document_tbl(i).attribute7:=  l_document_info.attribute7;
    ELSIF(p_x_document_tbl(i).attribute7 = FND_API.G_MISS_CHAR ) THEN
       p_x_document_tbl(i).attribute7 :=  NULL;
    END IF;
    if (p_x_document_tbl(i).attribute8 IS NULL ) THEN
       p_x_document_tbl(i).attribute8 :=  l_document_info.attribute8;
    ELSIF(p_x_document_tbl(i).attribute8 = FND_API.G_MISS_CHAR ) THEN
       p_x_document_tbl(i).attribute8 :=  NULL;
    END IF;
    if (p_x_document_tbl(i).attribute9 IS NULL ) THEN
       p_x_document_tbl(i).attribute9 :=  l_document_info.attribute9;
    ELSIF(p_x_document_tbl(i).attribute9 = FND_API.G_MISS_CHAR ) THEN
       p_x_document_tbl(i).attribute9 :=  NULL;
    END IF;
    if (p_x_document_tbl(i).attribute10 IS NULL ) THEN
       p_x_document_tbl(i).attribute10 :=  l_document_info.attribute10;
    ELSIF(p_x_document_tbl(i).attribute10 = FND_API.G_MISS_CHAR ) THEN
       p_x_document_tbl(i).attribute10 :=  NULL;
    END IF;
    if (p_x_document_tbl(i).attribute11 IS NULL ) THEN
       p_x_document_tbl(i).attribute11 :=  l_document_info.attribute11;
    ELSIF(p_x_document_tbl(i).attribute11 = FND_API.G_MISS_CHAR) THEN
       p_x_document_tbl(i).attribute11 :=  NULL;
    END IF;
    if (p_x_document_tbl(i).attribute12 IS NULL ) THEN
       p_x_document_tbl(i).attribute12 :=  l_document_info.attribute12;
    ELSIF(p_x_document_tbl(i).attribute12 = FND_API.G_MISS_CHAR) THEN
       p_x_document_tbl(i).attribute12 :=  NULL;
    END IF;
    if (p_x_document_tbl(i).attribute13 IS NULL ) THEN
       p_x_document_tbl(i).attribute13 :=  l_document_info.attribute13;
    ELSIF(p_x_document_tbl(i).attribute13 = FND_API.G_MISS_CHAR ) THEN
       p_x_document_tbl(i).attribute13 :=  NULL;
    END IF;
    if (p_x_document_tbl(i).attribute14 IS NULL ) THEN
       p_x_document_tbl(i).attribute14 :=  l_document_info.attribute14;
    ELSIF(p_x_document_tbl(i).attribute14 = FND_API.G_MISS_CHAR ) THEN
       p_x_document_tbl(i).attribute14 :=  NULL;
    END IF;
    if (p_x_document_tbl(i).attribute15 IS NULL ) THEN
       p_x_document_tbl(i).attribute15 :=  l_document_info.attribute15;
    ELSIF(p_x_document_tbl(i).attribute15 = FND_API.G_MISS_CHAR) THEN
       p_x_document_tbl(i).attribute15 :=  NULL;
    END IF;
   --pekambar changes for bug # 9226988 --end


    -- This condition will take care of  lost update data bug  when concurrent users are
    -- updating same record...02/05/02
    if (l_document_info.object_version_number <>p_x_document_tbl(i).object_version_number)
    then
        FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    end if;
    -- The following conditions compare the new record value with old  record
    -- value, if its different then assign the new value else continue
    IF p_x_document_tbl(i).document_id IS NOT NULL
    THEN
         --Update the document table
/*-------------------------------------------------------- */
/* procedure name: AHL_DOCUMENTS_PKG.UPDATE_ROW        */
/* description   :  Added by Senthil to call Table Handler */
/*      Date     : Dec 07 2001                             */
/*---------------------------------------------------------*/


AHL_DOCUMENTS_PKG.UPDATE_ROW (
X_DOCUMENT_ID  =>     p_x_document_tbl(i).document_id,
X_SUBSCRIBE_AVAIL_FLAG =>     p_x_document_tbl(i).subscribe_avail_flag,
X_SUBSCRIBE_TO_FLAG =>    p_x_document_tbl(i).subscribe_to_flag,
X_DOC_TYPE_CODE =>    p_x_document_tbl(i).doc_type_code,
X_DOC_SUB_TYPE_CODE =>    p_x_document_tbl(i).doc_sub_type_code,
X_OPERATOR_CODE =>    p_x_document_tbl(i).operator_code,
X_PRODUCT_TYPE_CODE =>    p_x_document_tbl(i).product_type_code,
X_ATTRIBUTE_CATEGORY =>   p_x_document_tbl(i).attribute_category,
X_ATTRIBUTE1 =>   p_x_document_tbl(i).attribute1,
X_ATTRIBUTE2 =>   p_x_document_tbl(i).attribute2,
X_ATTRIBUTE3 =>   p_x_document_tbl(i).attribute3,
X_ATTRIBUTE4 =>   p_x_document_tbl(i).attribute4,
X_ATTRIBUTE5 =>   p_x_document_tbl(i).attribute5,
 X_ATTRIBUTE6 =>      p_x_document_tbl(i).attribute6 ,
 X_ATTRIBUTE7 =>      p_x_document_tbl(i).attribute7 ,
 X_ATTRIBUTE8 =>      p_x_document_tbl(i).attribute8 ,
 X_ATTRIBUTE9 =>      p_x_document_tbl(i).attribute9 ,
 X_ATTRIBUTE10 =>     p_x_document_tbl(i).attribute10 ,
 X_ATTRIBUTE11 =>     p_x_document_tbl(i).attribute11 ,
 X_ATTRIBUTE12 =>     p_x_document_tbl(i).attribute12 ,
 X_ATTRIBUTE13 =>     p_x_document_tbl(i).attribute13 ,
 X_ATTRIBUTE14 =>     p_x_document_tbl(i).attribute14 ,
 X_ATTRIBUTE15 =>     p_x_document_tbl(i).attribute15 ,
X_OBJECT_VERSION_NUMBER =>    p_x_document_tbl(i).object_version_number+1,
X_SOURCE_PARTY_ID =>      p_x_document_tbl(i).source_party_id,
X_DOCUMENT_NO =>      p_x_document_tbl(i).document_no,
X_DOCUMENT_TITLE =>   p_x_document_tbl(i).document_title,
 X_LAST_UPDATE_DATE =>    sysdate ,
 X_LAST_UPDATED_BY =>     fnd_global.user_id ,
X_LAST_UPDATE_LOGIN =>    fnd_global.login_id
);
    END IF;
    END LOOP;
 END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug( 'Before start processing Supplier Record ahl_di_doc_index_pvt.modify document','+DI+');

    END IF;
    END IF;

-- Checks for any suppliers modifications exists for the document index
IF p_x_supplier_tbl.COUNT > 0 THEN
     modify_supplier
     ( p_api_version      => p_api_version       ,
       p_init_msg_list    => FND_API.G_TRUE      ,
       p_commit           => FND_API.G_FALSE     ,
       p_validate_only    => FND_API.G_TRUE      ,
       p_validation_level => FND_API.G_VALID_LEVEL_FULL,
       p_supplier_tbl     => p_x_supplier_tbl    ,
       x_return_status    => x_return_status     ,
       x_msg_count        => x_msg_count         ,
       x_msg_data         => x_msg_data
     );
END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug( 'Before start processing Recipient Record ahl_di_doc_index_pvt.modify document','+DI+');

    END IF;
    END IF;

-- Checks for any Recipients exists for the document index
IF p_x_recipient_tbl.COUNT > 0 THEN
     modify_recipient
     ( p_api_version      => p_api_version       ,
       p_init_msg_list    => FND_API.G_TRUE      ,
       p_commit           => FND_API.G_FALSE     ,
       p_validate_only    => FND_API.G_TRUE      ,
       p_validation_level => FND_API.G_VALID_LEVEL_FULL,
       p_recipient_tbl    => p_x_recipient_tbl   ,
       x_return_status    => x_return_status     ,
       x_msg_count        => x_msg_count         ,
       x_msg_data         => x_msg_data
     );
END IF;
   --Standard check for message count
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
 --Standard check for commit
 IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT;
 END IF;
 -- Debug info
 IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug( 'End of private api modify document','+DI+');

    END IF;
 -- Check if API is called in debug mode. If yes, disable debug.
 IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;

    END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO modify_document;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_index_pvt.modify document','+DI+');



        -- Check if API is called in debug mode. If yes, disable debug.

        AHL_DEBUG_PUB.disable_debug;

    END IF;

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO modify_document;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_index_pvt.modify document','+DI+');


        -- Check if API is called in debug mode. If yes, disable debug.

          AHL_DEBUG_PUB.disable_debug;

    END IF;

 WHEN OTHERS THEN
    ROLLBACK TO modify_document;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_DOC_INDEX_PVT',
                            p_procedure_name  =>  'MODIFY_DOCUMENT',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_index_pvt.modify document','+DI+');



        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

    END IF;

 END MODIFY_DOCUMENT;
/*-----------------------------------------------------*/
/* procedure name: validate_supplier(private procedure)*/
/* description :  Validation checks for before insert  */
/*                new record as well before update     */
/*-----------------------------------------------------*/
PROCEDURE VALIDATE_SUPPLIER
( P_SUPPLIER_DOCUMENT_ID   IN   NUMBER    ,
  P_SUPPLIER_ID            IN   NUMBER    ,
  P_DOCUMENT_ID            IN   NUMBER    ,
  P_PREFERENCE_CODE        IN   VARCHAR2  ,
  --P_OBJECT_VERSION_NUMBER  IN   NUMBER,
  P_DELETE_FLAG            IN   VARCHAR2  := 'N')
IS
-- Cursor to retrieve the preference code from fnd lookups
 CURSOR get_preference_code(c_preference_code VARCHAR2)
  IS
 SELECT lookup_code
   FROM FND_LOOKUP_VALUES_VL
  WHERE lookup_code = c_preference_code
    AND lookup_type = 'AHL_SUPPLIER_PREF_TYPE'
    AND sysdate between nvl(start_date_active,sysdate)
    AND nvl(end_date_active,sysdate);
 -- Used to validate document id
 CURSOR check_doc_info(c_document_id  NUMBER)
  IS
 SELECT 'X'
   FROM AHL_DOCUMENTS_B
  WHERE document_id  = c_document_id;
--Cursor to get supplier info
CURSOR get_supplier_rec_info (c_supplier_document_id NUMBER)
 IS
SELECT supplier_id,
       document_id,
       preference_code
  FROM AHL_SUPPLIER_DOCUMENTS
 WHERE supplier_document_id = c_supplier_document_id;
-- Used to check Duplicate Record
CURSOR dup_rec(c_supplier_id NUMBER,
               c_document_id  NUMBER)
 IS
SELECT 'X'
  FROM AHL_SUPPLIER_DOCUMENTS
 WHERE supplier_id  = c_supplier_id
   AND document_id = c_document_id;

-- Perf Bug Fix 4919011.
-- Replacing get_supplier_name by get_supplier_name_hz and get_supplier_name_po below
/*
CURSOR get_supplier_name(c_supplier_id NUMBER)
IS
 SELECT party_number
 FROM   AHL_HZ_PO_SUPPLIERS_V
 WHERE party_id =c_supplier_id;
*/

CURSOR get_supplier_name_hz(c_supplier_id NUMBER)
IS
 SELECT party_number
 FROM   HZ_PARTIES
 WHERE party_id =c_supplier_id;

CURSOR get_supplier_name_po(c_supplier_id NUMBER)
IS
 SELECT SEGMENT1
 FROM   PO_VENDORS
 WHERE VENDOR_ID =c_supplier_id;

--
l_api_name        CONSTANT VARCHAR2(30) := 'VALIDATE_SUPPLIER';
l_api_version     CONSTANT NUMBER       := 1.0;
l_dummy                    VARCHAR2(2000);
l_supplier_id              NUMBER;
l_document_id              NUMBER;
l_preference_code          VARCHAR2(30);
l_supplier_document_id     NUMBER;
l_supplier_name            VARCHAR2(30);
l_prod_install_status      VARCHAR2(30);

BEGIN

   -- Perf Bug Fix 4919011.
   BEGIN
       IF G_DEBUG='Y' THEN
         AHL_DEBUG_PUB.debug( 'Fetching Installation Status of PO','+SUP+');
       END IF;
       SELECT AHL_DI_DOC_INDEX_PVT.GET_PRODUCT_INSTALL_STATUS('PO')
         INTO l_prod_install_status
         FROM DUAL;
   END;

   --When the process is insert or update(FLAG <> 'YES')
   IF p_delete_flag  <> 'Y'
   THEN
      IF p_supplier_document_id IS NOT NULL
      THEN
         OPEN get_supplier_rec_info(p_supplier_document_id);
         FETCH get_supplier_rec_info INTO l_supplier_id,
                                          l_document_id,
                                          l_preference_code;
         CLOSE get_supplier_rec_info;
      END IF;
      --
      IF p_supplier_id IS NOT NULL
      THEN
          l_supplier_id := p_supplier_id;
      END IF;
      --
      IF p_document_id IS NOT NULL
      THEN
          l_document_id := p_document_id;
      END IF;
      --
      IF p_preference_code IS NOT NULL
      THEN
          l_preference_code := p_preference_code;
      END IF;
      --
         l_supplier_document_id := p_supplier_document_id;
      -- This condition checks for supplier id value is Null
      IF ((p_supplier_document_id IS NULL AND
         p_supplier_id IS NULL)
         OR
         (p_supplier_document_id IS NOT NULL
         AND l_supplier_id IS NULL))
      THEN
         FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUPPLIER_ID_NULL');
         FND_MSG_PUB.ADD;
      END IF;
      -- This condition checks for Document id Is Null
      IF ((p_supplier_document_id IS NULL AND
          p_document_id IS NULL)
         OR
         (p_supplier_document_id IS NOT NULL
         AND l_document_id IS NULL))
      THEN
         FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOCUMENT_ID_NULL');
         FND_MSG_PUB.ADD;
      END IF;
      -- This condition checks for existence of preference code in fnd lookups
      IF p_preference_code IS NOT NULL
      THEN
         OPEN get_preference_code(p_preference_code);
         FETCH get_preference_code INTO l_dummy;
         IF get_preference_code%NOTFOUND
         THEN
             FND_MESSAGE.SET_NAME('AHL','AHL_DI_PREF_CODE_NOT_EXIST');
             FND_MSG_PUB.ADD;
          END IF;
         CLOSE get_preference_code;
      END IF;
      -- This condition checks for document record in ahl documents table
      IF p_document_id IS NOT NULL
      THEN
         OPEN Check_doc_info(p_document_id);
         FETCH Check_doc_info INTO l_dummy;
         IF Check_doc_info%NOTFOUND
         THEN
             FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_ID_NOT_EXISTS');
             FND_MSG_PUB.ADD;
          END IF;
          CLOSE Check_doc_info;
       END IF;
       --Check for Duplicate Record
       IF p_supplier_document_id IS NULL
       THEN
          OPEN dup_rec(l_supplier_id, l_document_id);
          FETCH dup_rec INTO l_dummy;
          IF dup_rec%FOUND THEN
             -- Perf Bug Fix 4919011.
             /*
             OPEN get_supplier_name(l_supplier_id);
             FETCH get_supplier_name INTO l_supplier_name;
             CLOSE get_supplier_name;
             */
             IF l_prod_install_status IN ('N','L') THEN
                OPEN get_supplier_name_hz(l_supplier_id);
                FETCH get_supplier_name_hz INTO l_supplier_name;
                CLOSE get_supplier_name_hz;
             ELSIF l_prod_install_status IN ('I','S') THEN
                OPEN get_supplier_name_po(l_supplier_id);
                FETCH get_supplier_name_po INTO l_supplier_name;
                CLOSE get_supplier_name_po;
             END IF;
             FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUPPLIER_DUP_RECORD');
             FND_MESSAGE.SET_TOKEN('SUPNAME',l_supplier_name);
             FND_MSG_PUB.ADD;
          END IF;
          CLOSE dup_rec;
       END IF;
  END IF;

END VALIDATE_SUPPLIER;

/*--------------------------------------------------*/
/* procedure name: create_supplier                  */
/* description :  Creates new supplier record       */
/*                for an associated document        */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE CREATE_SUPPLIER
 (
 p_api_version             IN     NUMBER    := 1.0            ,
 p_init_msg_list           IN     VARCHAR2  := FND_API.G_TRUE   ,
 p_commit                  IN     VARCHAR2  := FND_API.G_FALSE  ,
 p_validate_only           IN     VARCHAR2  := FND_API.G_TRUE   ,
 p_validation_level        IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_supplier_tbl          IN OUT NOCOPY supplier_tbl           ,
 x_return_status              OUT NOCOPY VARCHAR2                      ,
 x_msg_count                  OUT NOCOPY NUMBER                        ,
 x_msg_data                   OUT NOCOPY VARCHAR2)
IS
-- Used to check Duplicate Record
CURSOR dup_rec(c_supplier_id NUMBER,
               c_document_id  NUMBER)
 IS
SELECT 'X'
  FROM AHL_SUPPLIER_DOCUMENTS
 WHERE supplier_id  = c_supplier_id
   AND document_id = c_document_id;

-- Perf Bug Fix 4919011.
-- Replacing get_supplier_name by get_supplier_name_hz and get_supplier_name_po below
/*
CURSOR get_supplier_name(c_supplier_id NUMBER)
IS
 SELECT party_number
 FROM   AHL_HZ_PO_SUPPLIERS_V
 WHERE party_id =c_supplier_id;
*/

CURSOR get_supplier_name_hz(c_supplier_id NUMBER)
IS
 SELECT party_number
 FROM   HZ_PARTIES
 WHERE party_id =c_supplier_id;

CURSOR get_supplier_name_po(c_supplier_id NUMBER)
IS
 SELECT SEGMENT1
 FROM   PO_VENDORS
 WHERE VENDOR_ID =c_supplier_id;

--
 l_api_name     CONSTANT VARCHAR2(30) := 'CREATE_SUPPLIER';
 l_api_version  CONSTANT NUMBER       := 1.0;
 l_msg_count             NUMBER;
 l_supplier_document_id  NUMBER;
 l_dummy                 VARCHAR2(2000);
 l_supplier_name         VARCHAR2(360);
 l_supplier_info         supplier_rec;
 l_prod_install_status      VARCHAR2(30);
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT create_supplier;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'enter ahl_di_doc_index_pvt.Create Supplier','+SUP+');
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

   -- Perf Bug Fix 4919011.
   BEGIN
       IF G_DEBUG='Y' THEN
         AHL_DEBUG_PUB.debug( 'Fetching Installation Status of P0','+SUP+');
       END IF;
       SELECT AHL_DI_DOC_INDEX_PVT.GET_PRODUCT_INSTALL_STATUS('PO')
         INTO l_prod_install_status
         FROM DUAL;
   END;

   --Start API Body
   IF p_x_supplier_tbl.COUNT > 0
   THEN
      FOR i IN p_x_supplier_tbl.FIRST..p_x_supplier_tbl.LAST
      LOOP
         VALIDATE_SUPPLIER
          (
           p_supplier_document_id   => p_x_supplier_tbl(i).supplier_document_id,
           p_supplier_id            => p_x_supplier_tbl(i).supplier_id,
           p_document_id            => p_x_supplier_tbl(i).document_id,
           p_preference_code        => p_x_supplier_tbl(i).preference_code,
           p_delete_flag            => p_x_supplier_tbl(i).delete_flag
          );
       END LOOP;
   -- Standard call to get message count and if count is  get message info.
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   FOR i IN p_x_supplier_tbl.FIRST..p_x_supplier_tbl.LAST
   LOOP
     IF  (p_x_supplier_tbl(i).supplier_document_id IS NULL)
     THEN
       --The following conditions are required for null columns
          l_supplier_info.preference_code := p_x_supplier_tbl(i).preference_code;
          l_supplier_info.attribute_category := p_x_supplier_tbl(i).attribute_category;
           l_supplier_info.attribute1 := p_x_supplier_tbl(i).attribute1;
           l_supplier_info.attribute2 := p_x_supplier_tbl(i).attribute2;
           l_supplier_info.attribute3 := p_x_supplier_tbl(i).attribute3;
           l_supplier_info.attribute4 := p_x_supplier_tbl(i).attribute4;
           l_supplier_info.attribute5 := p_x_supplier_tbl(i).attribute5;
           l_supplier_info.attribute6 := p_x_supplier_tbl(i).attribute6;
           l_supplier_info.attribute7 := p_x_supplier_tbl(i).attribute7;
           l_supplier_info.attribute8 := p_x_supplier_tbl(i).attribute8;
           l_supplier_info.attribute9 := p_x_supplier_tbl(i).attribute9;
           l_supplier_info.attribute10 := p_x_supplier_tbl(i).attribute10;
           l_supplier_info.attribute11 := p_x_supplier_tbl(i).attribute11;
           l_supplier_info.attribute12 := p_x_supplier_tbl(i).attribute12;
           l_supplier_info.attribute13 := p_x_supplier_tbl(i).attribute13;
           l_supplier_info.attribute14 := p_x_supplier_tbl(i).attribute14;
           l_supplier_info.attribute15 := p_x_supplier_tbl(i).attribute15;
        -- check for duplicate records
          OPEN dup_rec(p_x_supplier_tbl(i).supplier_id,
                      p_x_supplier_tbl(i).document_id);
          FETCH dup_rec INTO l_dummy;
          IF dup_rec%FOUND THEN
             -- Perf Bug Fix 4919011.
             /*
             OPEN get_supplier_name(p_x_supplier_tbl(i).supplier_id);
             FETCH get_supplier_name INTO l_supplier_name;
             CLOSE get_supplier_name;
             */
             IF l_prod_install_status IN ('N','L') THEN
                OPEN get_supplier_name_hz(p_x_supplier_tbl(i).supplier_id);
                FETCH get_supplier_name_hz INTO l_supplier_name;
                CLOSE get_supplier_name_hz;
             ELSIF l_prod_install_status IN ('I','S') THEN
                OPEN get_supplier_name_po(p_x_supplier_tbl(i).supplier_id);
                FETCH get_supplier_name_po INTO l_supplier_name;
                CLOSE get_supplier_name_po;
             END IF;
             FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUPPLIER_DUP_RECORD');
             FND_MESSAGE.SET_TOKEN('SUPNAME',l_supplier_name);
             FND_MSG_PUB.ADD;

--AD         RAISE FND_API.G_EXC_ERROR;
--AD         END IF;
--ad          CLOSE dup_rec;

          ELSE
        --Retrieve the sequence number
        SELECT AHL_SUPPLIER_DOCUMENTS_S.Nextval INTO
               l_supplier_document_id from DUAL;
        --Insert the record into supplier documents table
        INSERT INTO AHL_SUPPLIER_DOCUMENTS
                   (
                    SUPPLIER_DOCUMENT_ID,
                    SUPPLIER_ID,
                    DOCUMENT_ID,
                    PREFERENCE_CODE,
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
                   l_supplier_document_id,
                   p_x_supplier_tbl(i).supplier_id,
                   p_x_supplier_tbl(i).document_id,
                   l_supplier_info.preference_code,
                   1,
                   l_supplier_info.attribute_category,
                   l_supplier_info.attribute1,
                   l_supplier_info.attribute2,
                   l_supplier_info.attribute3,
                   l_supplier_info.attribute4,
                   l_supplier_info.attribute5,
                   l_supplier_info.attribute6,
                   l_supplier_info.attribute7,
                   l_supplier_info.attribute8,
                   l_supplier_info.attribute9,
                   l_supplier_info.attribute10,
                   l_supplier_info.attribute11,
                   l_supplier_info.attribute12,
                   l_supplier_info.attribute13,
                   l_supplier_info.attribute14,
                   l_supplier_info.attribute15,
                   sysdate,
                   fnd_global.user_id,
                   sysdate,
                   fnd_global.user_id,
                   fnd_global.login_id
                 );
       p_x_supplier_tbl(i).supplier_document_id := l_supplier_document_id;
      END IF;--ad
      CLOSE dup_rec;--ad

/*
--{{adharia comment
   l_msg_count := FND_MSG_PUB.count_msg;
   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
--{{adharia comment
*/
  END IF;
 END LOOP;
END IF;

--{{adharia added
   l_msg_count := FND_MSG_PUB.count_msg;
   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
--{{adharia

   -- Standard check of p_commit.
   IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug( 'End of private api Create Supplier','+SUP+');

    END IF;
   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;

    END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_supplier;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_index_pvt.Create Supplier','+SUP+');


        -- Check if API is called in debug mode. If yes, disable debug.

            AHL_DEBUG_PUB.disable_debug;

    END IF;

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO create_supplier;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_index_pub.Create Supplier','+SUP+');


        -- Check if API is called in debug mode. If yes, disable debug.
           AHL_DEBUG_PUB.disable_debug;

    END IF;

 WHEN OTHERS THEN
    ROLLBACK TO create_supplier;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_DOC_INDEX_PVT',
                            p_procedure_name  =>  'CREATE_SUPPLIER',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_index_pvt.Create Supplier','+SUP+');


        -- Check if API is called in debug mode. If yes, disable debug.
           AHL_DEBUG_PUB.disable_debug;

    END IF;

 END CREATE_SUPPLIER;
/*------------------------------------------------------*/
/* procedure name: modify_supplier                      */
/* description :  Update the existing supplier record   */
/*                for an associated document            */
/*                                                      */
/*------------------------------------------------------*/

PROCEDURE MODIFY_SUPPLIER
(
 p_api_version              IN     NUMBER    :=  1.0                ,
 p_init_msg_list            IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                   IN     VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only            IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level         IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_supplier_tbl             IN     supplier_tbl                     ,
 x_return_status               OUT NOCOPY VARCHAR2                         ,
 x_msg_count                   OUT NOCOPY NUMBER                           ,
 x_msg_data                    OUT NOCOPY VARCHAR2
)
IS
-- To get the supplier info
CURSOR get_supplier_rec_info(c_supplier_document_id  NUMBER)
 IS
SELECT ROWID,
       supplier_id,
       document_id,
       preference_code,
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
       attribute15,
       object_version_number
  FROM AHL_SUPPLIER_DOCUMENTS
 WHERE supplier_document_id = c_supplier_document_id
   FOR UPDATE OF object_version_number NOWAIT;

-- Perf Bug Fix 4919011.
-- Replacing get_supplier_name by get_supplier_name_hz and get_supplier_name_po below
/*
CURSOR get_supplier_name(c_supplier_id NUMBER)
IS
 SELECT party_number
 FROM   AHL_HZ_PO_SUPPLIERS_V
 WHERE party_id =c_supplier_id;
*/

CURSOR get_supplier_name_hz(c_supplier_id NUMBER)
IS
 SELECT party_number
 FROM   HZ_PARTIES
 WHERE party_id =c_supplier_id;

CURSOR get_supplier_name_po(c_supplier_id NUMBER)
IS
 SELECT SEGMENT1
 FROM   PO_VENDORS
 WHERE VENDOR_ID =c_supplier_id;


--
l_api_name     CONSTANT   VARCHAR2(30) := 'MODIFY_SUPPLIER';
l_api_version  CONSTANT   NUMBER       := 1.0;
l_msg_count               NUMBER;
l_num_rec                 NUMBER;
l_rowid                   ROWID;
l_supplier_name           VARCHAR2(390);
l_supplier_info           get_supplier_rec_info%ROWTYPE;
l_prod_install_status      VARCHAR2(30);
BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT modify_supplier;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.enable_debug;

   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'anand enter ahl_di_doc_index_pvt.Modify Supplier','+SUP+');
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

    -- Perf Bug Fix 4919011.
    BEGIN
       IF G_DEBUG='Y' THEN
         AHL_DEBUG_PUB.debug( 'Fetching Installation Status of PO','+SUP+');
       END IF;
        SELECT AHL_DI_DOC_INDEX_PVT.GET_PRODUCT_INSTALL_STATUS('PO')
          INTO l_prod_install_status
          FROM DUAL;
    END;

    IF p_supplier_tbl.COUNT > 0
    THEN
        FOR i IN p_supplier_tbl.FIRST..p_supplier_tbl.LAST
        LOOP
          -- Calling validate suppliers
   --ad
   IF G_DEBUG='Y' THEN
       IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug( ' anand enter ahl_di_doc_index_pvt.Modify Supplier before validate supplier ','+SUP+');

    END IF;
    END IF;
   --ad
          VALIDATE_SUPPLIER
           (
            p_supplier_document_id   => p_supplier_tbl(i).supplier_document_id,
            p_supplier_id            => p_supplier_tbl(i).supplier_id,
            p_document_id            => p_supplier_tbl(i).document_id,
            p_preference_code        => p_supplier_tbl(i).preference_code,
            p_delete_flag            => p_supplier_tbl(i).delete_flag
           );
       END LOOP;
       --End of Validations
       -- Standard call to get message count
       l_msg_count := FND_MSG_PUB.count_msg;
   --ad
   IF G_DEBUG='Y' THEN
       IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug( ' anand enter ahl_di_doc_index_pvt.Modify Supplier after validate sup '||l_msg_count,'+SUP+');

    END IF;
    END IF;
   --ad


      IF l_msg_count > 0 THEN
         X_msg_count := l_msg_count;
         X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   FOR i IN p_supplier_tbl.FIRST..p_supplier_tbl.LAST
   LOOP
      --Retrieve the existing supplier record
      OPEN get_supplier_rec_info(p_supplier_tbl(i).supplier_document_id);
      FETCH get_supplier_rec_info INTO l_supplier_info;
      CLOSE get_supplier_rec_info;

    -- This condition will take care of  lost update data bug  when concurrent users are
    -- updating same record...02/05/02
    IF l_supplier_info.object_version_number <>p_supplier_tbl(i).object_version_number
    THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
        FND_MSG_PUB.ADD;
--AD    RAISE FND_API.G_EXC_ERROR;
    ELSE    --AD
      -- The following conditions compare the new record value with old  record
      -- value, if its different then assign the new value else continue
      IF p_supplier_tbl(i).supplier_document_id IS NOT NULL
        AND p_supplier_tbl(i).delete_flag <> 'Y'
      THEN
           l_supplier_info.supplier_id := p_supplier_tbl(i).supplier_id;
         l_supplier_info.document_id := p_supplier_tbl(i).document_id;
         l_supplier_info.preference_code := p_supplier_tbl(i).preference_code;
         l_supplier_info.attribute_category := p_supplier_tbl(i).attribute_category;
         l_supplier_info.attribute1 := p_supplier_tbl(i).attribute1;
         l_supplier_info.attribute2 := p_supplier_tbl(i).attribute2;
         l_supplier_info.attribute3 := p_supplier_tbl(i).attribute3;
         l_supplier_info.attribute4 := p_supplier_tbl(i).attribute4;
         l_supplier_info.attribute5 := p_supplier_tbl(i).attribute5;
         l_supplier_info.attribute6 := p_supplier_tbl(i).attribute6;
         l_supplier_info.attribute7 := p_supplier_tbl(i).attribute7;
         l_supplier_info.attribute8 := p_supplier_tbl(i).attribute8;
         l_supplier_info.attribute9 := p_supplier_tbl(i).attribute9;
         l_supplier_info.attribute10 := p_supplier_tbl(i).attribute10;
         l_supplier_info.attribute11 := p_supplier_tbl(i).attribute11;
         l_supplier_info.attribute12 := p_supplier_tbl(i).attribute12;
         l_supplier_info.attribute13 := p_supplier_tbl(i).attribute13;
         l_supplier_info.attribute14 := p_supplier_tbl(i).attribute14;
         l_supplier_info.attribute15 := p_supplier_tbl(i).attribute15;
         -- Perf Bug Fix 4919011.
         /*
         OPEN get_supplier_name(l_supplier_info.supplier_id);
         FETCH get_supplier_name INTO l_supplier_name;
         CLOSE get_supplier_name;
         */
         IF l_prod_install_status IN ('N','L') THEN
            OPEN get_supplier_name_hz(l_supplier_info.supplier_id);
            FETCH get_supplier_name_hz INTO l_supplier_name;
            CLOSE get_supplier_name_hz;
         ELSIF l_prod_install_status IN ('I','S') THEN
            OPEN get_supplier_name_po(l_supplier_info.supplier_id);
            FETCH get_supplier_name_po INTO l_supplier_name;
            CLOSE get_supplier_name_po;
         END IF;



      --Updates the supplier table
          UPDATE AHL_SUPPLIER_DOCUMENTS
             SET supplier_id           = l_supplier_info.supplier_id,
                 document_id           = l_supplier_info.document_id,
                 preference_code       = l_supplier_info.preference_code,
                 object_version_number = l_supplier_info.object_version_number+1,
                 attribute_category    = l_supplier_info.attribute_category,
                 attribute1            = l_supplier_info.attribute1,
                 attribute2            = l_supplier_info.attribute2,
                 attribute3            = l_supplier_info.attribute3,
                 attribute4            = l_supplier_info.attribute4,
                 attribute5            = l_supplier_info.attribute5,
                 attribute6            = l_supplier_info.attribute6,
                 attribute7            = l_supplier_info.attribute7,
                 attribute8            = l_supplier_info.attribute8,
                 attribute9            = l_supplier_info.attribute9,
                 attribute10           = l_supplier_info.attribute10,
                 attribute11           = l_supplier_info.attribute11,
                 attribute12           = l_supplier_info.attribute12,
                 attribute13           = l_supplier_info.attribute13,
                 attribute14           = l_supplier_info.attribute14,
                 attribute15           = l_supplier_info.attribute15,
                 last_update_date      = sysdate,
                 last_updated_by       = fnd_global.user_id,
                 last_update_login     = fnd_global.login_id
         WHERE          ROWID          = l_supplier_info.rowid;
    END IF;
 --Incase of delete supplier record
  IF (p_supplier_tbl(i).supplier_document_id IS NOT NULL AND
       p_supplier_tbl(i).delete_flag = 'Y' )
    THEN
      DELETE_SUPPLIER
       (
        p_api_version         => 1.0               ,
        p_init_msg_list       => FND_API.G_FALSE      ,
        p_commit              => FND_API.G_FALSE     ,
        p_validate_only       => FND_API.G_TRUE      ,
        p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
        p_supplier_rec        => p_supplier_tbl(i)   ,
        x_return_status       => x_return_status     ,
        x_msg_count           => x_msg_count         ,
        x_msg_data            => x_msg_data
        );
   END IF;


    END IF;--AD IF THERE IS ERROR DONT INSERT

  END LOOP;
 END IF;
 --{{ADHARIA

     l_msg_count := FND_MSG_PUB.count_msg;
    --ad
    IF G_DEBUG='Y' THEN
       IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug( ' anand enter ahl_di_doc_index_pvt.Modify Supplier after modify sup '||l_msg_count,'+SUP+');

    END IF;
    END IF;
    --ad
     IF l_msg_count > 0 THEN
        X_msg_count := l_msg_count;
        X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
 --{{ADHARIA

    -- Standard check of p_commit.
    IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT;
    END IF;

   -- Debug info
   IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug( 'End of private api Modify Supplier','+SUP+');

    END IF;
   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;

    END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO modify_supplier;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_index_pvt.Modify supplier','+SUP+');



        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

    END IF;

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO modify_supplier;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_index_pvt.Modify Supplier','+SUP+');



        -- Check if API is called in debug mode. If yes, disable debug.
           AHL_DEBUG_PUB.disable_debug;

    END IF;

 WHEN DUP_VAL_ON_INDEX THEN
    ROLLBACK TO modify_supplier;
    X_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUPPLIER_DUP_RECORD');
         FND_MESSAGE.SET_TOKEN('SUPNAME',l_supplier_name);
         FND_MSG_PUB.ADD;
        -- Check if API is called in debug mode. If yes, disable debug.
        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;

    END IF;

 WHEN OTHERS THEN
    ROLLBACK TO modify_supplier;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_DOC_INDEX_PVT',
                            p_procedure_name  =>  'MODIFY_SUPPLIER',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_index_pvt.Modify Supplier','+SUP+');



        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

    END IF;

END MODIFY_SUPPLIER;
/*------------------------------------------------------*/
/* procedure name: delete_supplier                      */
/* description :  Removes the supplier record           */
/*                for an associated document            */
/*                                                      */
/*------------------------------------------------------*/

PROCEDURE DELETE_SUPPLIER
(
 p_api_version               IN     NUMBER    := 1.0               ,
 p_init_msg_list             IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                    IN     VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only             IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level          IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_supplier_rec              IN     supplier_rec                     ,
 x_return_status                OUT NOCOPY VARCHAR2                         ,
 x_msg_count                    OUT NOCOPY NUMBER                           ,
 x_msg_data                     OUT NOCOPY VARCHAR2)
IS
--To get the supplier info
CURSOR get_supplier_rec_info(c_supplier_document_id  NUMBER)
 IS
SELECT ROWID ,
       supplier_id,
       document_id,
       object_version_number
  FROM AHL_SUPPLIER_DOCUMENTS
 WHERE supplier_document_id = c_supplier_document_id
   FOR UPDATE OF object_version_number NOWAIT;
--Cursor to check the record exists in Subscriptions table
--Cursor modified to check only active subscriptions: pjha: 16-Jul-2002
CURSOR get_subc_rec(c_supplier_id NUMBER,
                    c_document_id NUMBER)
 IS
SELECT 'X'
  FROM AHL_SUBSCRIPTIONS_B
 WHERE document_id = c_document_id
 --AND subscribed_frm_party_id = c_supplier_id;
 AND subscribed_frm_party_id = c_supplier_id
 AND NVL(end_date,sysdate) >= TRUNC(sysdate);

-- Perf Bug Fix 4919011.
-- Replacing get_supplier_name by get_supplier_name_hz and get_supplier_name_po below
/*
CURSOR get_supplier_name(c_supplier_id NUMBER)
IS
 SELECT party_number
 FROM   AHL_HZ_PO_SUPPLIERS_V
 WHERE party_id =c_supplier_id;
*/

CURSOR get_supplier_name_hz(c_supplier_id NUMBER)
IS
 SELECT party_number
 FROM   HZ_PARTIES
 WHERE party_id =c_supplier_id;

CURSOR get_supplier_name_po(c_supplier_id NUMBER)
IS
 SELECT SEGMENT1
 FROM   PO_VENDORS
 WHERE VENDOR_ID =c_supplier_id;

--
l_api_name     CONSTANT VARCHAR2(30) := 'DELETE_SUPPLIER';
l_api_version  CONSTANT NUMBER       := 1.0;
l_rowid                 ROWID;
l_msg_count             NUMBER;
l_object_version_number NUMBER;
l_supplier_id           NUMBER;
l_document_id           NUMBER;
l_supplier_name         VARCHAR2(30);
l_dummy                 VARCHAR2(2000);
l_prod_install_status   VARCHAR2(30);
BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT delete_supplier;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.enable_debug;

   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'enter ahl_di_doc_index_pvt.Delete Supplier','+SUP+');
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

    -- Perf Bug Fix 4919011.
    BEGIN
        IF G_DEBUG='Y' THEN
           AHL_DEBUG_PUB.debug( 'Fetching Product Install Status for PO');
        END IF;
        SELECT AHL_DI_DOC_INDEX_PVT.GET_PRODUCT_INSTALL_STATUS('PO')
          INTO l_prod_install_status
          FROM DUAL;
    END;

    --IF p_supplier_tbl.COUNT > 0
    --THEN
          OPEN get_supplier_rec_info(p_supplier_rec.supplier_document_id);
          l_rowid := null;
          l_supplier_id := 0;
      l_document_id := 0;
      l_object_version_number := 0;
          FETCH get_supplier_rec_info INTO l_rowid,
                                           l_supplier_id,
                                           l_document_id,
                                           l_object_version_number;
          IF (get_supplier_rec_info%NOTFOUND)
          THEN
             FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUPPLIER_REC_INVALID');
             FND_MSG_PUB.ADD;
          END IF;
          CLOSE get_supplier_rec_info;
           -- Check for version number
          IF (l_object_version_number <> p_supplier_rec.object_version_number)
          THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_TL_REC_CHANGED');
            FND_MSG_PUB.ADD;
          END IF;
          --Check for Subscriptions Record
         IF p_supplier_rec.supplier_document_id IS NOT NULL
         THEN
            OPEN get_subc_rec(l_supplier_id,l_document_id);
            FETCH get_subc_rec INTO l_dummy;
            IF get_subc_rec%FOUND
            THEN
            -- Perf Bug Fix 4919011.
            /*
               OPEN get_supplier_name(l_supplier_id);
               FETCH get_supplier_name INTO l_supplier_name;
               CLOSE get_supplier_name;
            */
               IF l_prod_install_status IN ('N','L') THEN
                  OPEN get_supplier_name_hz(l_supplier_id);
                  FETCH get_supplier_name_hz INTO l_supplier_name;
                  CLOSE get_supplier_name_hz;
               ELSIF l_prod_install_status IN ('I','S') THEN
                  OPEN get_supplier_name_po(l_supplier_id);
                  FETCH get_supplier_name_po INTO l_supplier_name;
                  CLOSE get_supplier_name_po;
               END IF;
               FND_MESSAGE.SET_NAME('AHL','AHL_DI_SUBC_REC_EXISTS');
               FND_MESSAGE.SET_TOKEN('SUPNAME',l_supplier_name);
               FND_MSG_PUB.ADD;
             END IF;
             CLOSE get_subc_rec;
         END IF;
       -- Delete the record from suppliers table
       DELETE FROM  AHL_SUPPLIER_DOCUMENTS
         WHERE ROWID = l_rowid;
 --END IF;
       -- Standard call to get message count
       l_msg_count := FND_MSG_PUB.count_msg;

      IF l_msg_count > 0 THEN
         X_msg_count := l_msg_count;
         X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--AD     RAISE FND_API.G_EXC_ERROR;
      END IF;

    -- Standard check of p_commit.
    IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT;
    END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug( 'End of private api Delete Supplier','+SUP+');

    END IF;
   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;

    END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO delete_supplier;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_index_pvt.delete Supplier','+SUP+');


        -- Check if API is called in debug mode. If yes, disable debug.
           AHL_DEBUG_PUB.disable_debug;

    END IF;

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO delete_supplier;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_index_pvt.Delete Supplier','+SUP+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

    END IF;

 WHEN OTHERS THEN
    ROLLBACK TO delete_supplier;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_DOC_INDEX_PVT',
                            p_procedure_name  =>  'DELETE_SUPPLIER',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_index_pvt.Delete Supplier','+SUP+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

    END IF;

END DELETE_SUPPLIER;
/*-------------------------------------------------------*/
/* procedure name: validate_recipient(private procedure) */
/* description :  Validation checks for before inserting */
/*                new record as well before update       */
/*                                                       */
/*-------------------------------------------------------*/

PROCEDURE VALIDATE_RECIPIENT
( p_recipient_document_id   IN   NUMBER    ,
  p_recipient_party_id      IN   NUMBER    ,
  p_document_id             IN   NUMBER    ,
  p_object_version_number   IN   NUMBER    ,
  p_delete_flag             IN   VARCHAR2  := 'N')
IS
-- Cursor to get the recipient info
CURSOR get_recipient_rec_info (c_recipient_document_id NUMBER)
 IS
SELECT recipient_party_id,
       document_id
  FROM AHL_RECIPIENT_DOCUMENTS
 WHERE recipient_document_id = c_recipient_document_id;

 -- Used to validate the document id
 CURSOR check_doc_info(c_document_id  NUMBER)
  IS
 SELECT 'X'
   FROM AHL_DOCUMENTS_B
  WHERE document_id  = c_document_id;

--Cursor to check duplicate record
CURSOR dup_rec(c_recipient_party_id NUMBER,
               c_document_id  NUMBER)
 IS
SELECT 'X'
  FROM AHL_RECIPIENT_DOCUMENTS
 WHERE recipient_party_id  = c_recipient_party_id
   AND document_id         = c_document_id;

CURSOR DUP_REC_NAME(c_recipient_party_id NUMBER)
 IS
 SELECT party_number
     FROM hz_parties
     WHERE party_id = c_recipient_party_id;



--
  l_api_name     CONSTANT  VARCHAR2(30) := 'VALIDATE_RECIPIENT';
  l_api_version  CONSTANT  NUMBER       := 1.0;
  l_dummy                  VARCHAR2(2000);
  l_recipient_party_id     NUMBER;
  l_document_id            NUMBER;
  l_recipient_document_id  NUMBER;
  l_dup_rec_name           varchar2(360);
BEGIN
    --When the action is insert or update
    IF p_delete_flag  <> 'Y'
    THEN
      IF p_recipient_document_id IS NOT NULL
      THEN
         OPEN get_recipient_rec_info(p_recipient_document_id);
         FETCH get_recipient_rec_info INTO l_recipient_party_id,
                                           l_document_id;
         CLOSE get_recipient_rec_info;
      END IF;
      --
      IF p_recipient_party_id IS NOT NULL
      THEN
          l_recipient_party_id := p_recipient_party_id;
      END IF;
      --
      IF p_document_id IS NOT NULL
      THEN
         l_document_id := p_document_id;
      END IF;
      --
         l_recipient_document_id := p_recipient_document_id;
      --This condition checks for recipient party id null
      IF ((p_recipient_document_id IS NULL AND
          p_recipient_party_id IS NULL)
         OR
         (p_recipient_document_id IS NOT NULL
         AND l_recipient_party_id IS NULL))
      THEN
         FND_MESSAGE.SET_NAME('AHL','AHL_DI_RECIPIENT_PTY_ID_NULL');
         FND_MSG_PUB.ADD;
      END IF;
      --This condition checks for Document Id
      IF ((p_recipient_document_id IS NULL AND
          p_document_id IS NULL)
         OR
         (p_recipient_document_id IS NOT NULL
         AND l_document_id IS NULL))
      THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOCUMENT_ID_NULL');
        FND_MSG_PUB.ADD;
      END IF;
      -- This condition checks for existence of document record in ahl documents table
      IF p_document_id IS NOT NULL
      THEN
         OPEN Check_doc_info(p_document_id);
         FETCH Check_doc_info INTO l_dummy;
         IF Check_doc_info%NOTFOUND
         THEN
            FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_ID_NOT_EXISTS');
            FND_MSG_PUB.ADD;
         END IF;
         CLOSE Check_doc_info;
      END IF;
      -- Check for Duplicate Record
      IF p_recipient_document_id IS NULL
      THEN
         OPEN dup_rec(l_recipient_party_id, l_document_id);
         FETCH dup_rec INTO l_dummy;
         IF dup_rec%FOUND THEN
           OPEN DUP_REC_NAME(l_recipient_party_id);
           FETCH DUP_REC_NAME INTO L_DUP_REC_NAME;
             FND_MESSAGE.SET_NAME('AHL','AHL_DI_RECIPIENT_DUP_RECORD');
             FND_MESSAGE.SET_TOKEN('RECPTID',l_DUP_REC_NAME);
             FND_MSG_PUB.ADD;
           CLOSE DUP_REC_NAME;
         END IF;
         CLOSE dup_rec;
      END IF;
  END IF;

END VALIDATE_RECIPIENT;
/*------------------------------------------------------*/
/* procedure name: create_recipient                     */
/* description :  Creates new recipient record          */
/*                for an associated document            */
/*                                                      */
/*------------------------------------------------------*/

PROCEDURE CREATE_RECIPIENT
(
 p_api_version              IN     NUMBER    :=  1.0             ,
 p_init_msg_list            IN     VARCHAR2  := FND_API.G_TRUE   ,
 p_commit                   IN     VARCHAR2  := FND_API.G_FALSE  ,
 p_validate_only            IN     VARCHAR2  := FND_API.G_TRUE   ,
 p_validation_level         IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_x_recipient_tbl          IN OUT NOCOPY recipient_tbl          ,
 x_return_status               OUT NOCOPY VARCHAR2                      ,
 x_msg_count                   OUT NOCOPY NUMBER                        ,
 x_msg_data                    OUT NOCOPY VARCHAR2)
IS
--Check for same record multiple times
CURSOR dup_rec(c_recipient_party_id NUMBER,
               c_document_id  NUMBER)
 IS
SELECT 'X'
  FROM AHL_RECIPIENT_DOCUMENTS
 WHERE recipient_party_id  = c_recipient_party_id
   AND document_id         = c_document_id;

CURSOR DUP_REC_NAME(c_recipient_party_id NUMBER)
 IS
 SELECT party_number
     FROM hz_parties
     WHERE party_id = c_recipient_party_id;

 l_dup_rec_name           varchar2(360);
 --
 l_api_name     CONSTANT  VARCHAR2(30) := 'CREATE_RECIPIENT';
 l_api_version  CONSTANT  NUMBER       := 1.0;
 l_msg_count              NUMBER;
 l_dummy                  VARCHAR2(2000);
 l_recipient_document_id  NUMBER;
 l_recipient_info         Recipient_rec;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT create_recipient;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.enable_debug;

    END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug( 'enter ahl_di_doc_index_pvt.Create Recipient','+REP+');

    END IF;
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
   --Start API Body
   IF p_x_recipient_tbl.COUNT > 0
   THEN
      FOR i IN p_x_recipient_tbl.FIRST..p_x_recipient_tbl.LAST
      LOOP
        VALIDATE_RECIPIENT
         (
          p_recipient_document_id   => p_x_recipient_tbl(i).recipient_document_id,
          p_recipient_party_id      => p_x_recipient_tbl(i).recipient_party_id,
          p_document_id             => p_x_recipient_tbl(i).document_id,
          p_object_version_number   => p_x_recipient_tbl(i).object_version_number,
          p_delete_flag             => p_x_recipient_tbl(i).delete_flag);
      END LOOP;
      -- Standard call to get message count and if count is  get message info.
      l_msg_count := FND_MSG_PUB.count_msg;

     IF l_msg_count > 0 THEN
        X_msg_count := l_msg_count;
        X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE FND_API.G_EXC_ERROR;
     END IF;

   FOR i IN p_x_recipient_tbl.FIRST..p_x_recipient_tbl.LAST
   LOOP
     IF  p_x_recipient_tbl(i).recipient_document_id IS NULL
     THEN
        --
           l_recipient_info.attribute_category := p_x_recipient_tbl(i).attribute_category;
          l_recipient_info.attribute1 := p_x_recipient_tbl(i).attribute1;
           l_recipient_info.attribute2 := p_x_recipient_tbl(i).attribute2;
           l_recipient_info.attribute3 := p_x_recipient_tbl(i).attribute3;
           l_recipient_info.attribute4 := p_x_recipient_tbl(i).attribute4;
           l_recipient_info.attribute5 := p_x_recipient_tbl(i).attribute5;
           l_recipient_info.attribute6 := p_x_recipient_tbl(i).attribute6;
           l_recipient_info.attribute7 := p_x_recipient_tbl(i).attribute7;
           l_recipient_info.attribute8 := p_x_recipient_tbl(i).attribute8;
           l_recipient_info.attribute9 := p_x_recipient_tbl(i).attribute9;
           l_recipient_info.attribute10 := p_x_recipient_tbl(i).attribute10;
           l_recipient_info.attribute11 := p_x_recipient_tbl(i).attribute11;
           l_recipient_info.attribute12 := p_x_recipient_tbl(i).attribute12;
          l_recipient_info.attribute13 := p_x_recipient_tbl(i).attribute13;
           l_recipient_info.attribute14 := p_x_recipient_tbl(i).attribute14;
           l_recipient_info.attribute15 := p_x_recipient_tbl(i).attribute15;

        --Check for duplication
         OPEN dup_rec(p_x_recipient_tbl(i).recipient_party_id,
                      p_x_recipient_tbl(i).document_id);
         FETCH dup_rec INTO l_dummy;
         IF dup_rec%FOUND THEN
           OPEN DUP_REC_NAME(p_x_recipient_tbl(i).recipient_party_id);
           FETCH DUP_REC_NAME INTO L_DUP_REC_NAME;
             FND_MESSAGE.SET_NAME('AHL','AHL_DI_RECIPIENT_DUP_RECORD');
             FND_MESSAGE.SET_TOKEN('RECPTID',l_DUP_REC_NAME);
             FND_MSG_PUB.ADD;
           CLOSE DUP_REC_NAME;
--ad            RAISE FND_API.G_EXC_ERROR;
--ad         END IF;
--ad         CLOSE dup_rec;
       else --ad
        --Retrieves the sequence number
       SELECT AHL_RECIPIENT_DOCUMENTS_S.Nextval INTO
             l_recipient_document_id from DUAL;
        --Insert the record into recipient documents
       INSERT INTO AHL_RECIPIENT_DOCUMENTS
                   (
                    RECIPIENT_DOCUMENT_ID,
                    RECIPIENT_PARTY_ID,
                    DOCUMENT_ID,
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
                    l_recipient_document_id,
                    p_x_recipient_tbl(i).recipient_party_id,
                    p_x_recipient_tbl(i).document_id,
                    1,
                    l_recipient_info.attribute_category,
                    l_recipient_info.attribute1,
                    l_recipient_info.attribute2,
                    l_recipient_info.attribute3,
                    l_recipient_info.attribute4,
                    l_recipient_info.attribute5,
                    l_recipient_info.attribute6,
                    l_recipient_info.attribute7,
                    l_recipient_info.attribute8,
                    l_recipient_info.attribute9,
                    l_recipient_info.attribute10,
                    l_recipient_info.attribute11,
                    l_recipient_info.attribute12,
                    l_recipient_info.attribute13,
                    l_recipient_info.attribute14,
                    l_recipient_info.attribute15,
                    sysdate,
                    fnd_global.user_id,
                    sysdate,
                    fnd_global.user_id,
                    fnd_global.login_id
                  );
       p_x_recipient_tbl(i).recipient_document_id := l_recipient_document_id;
   -- Standard check to count messages
/*adharia
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_ERROR;
         END IF;--ad
adharia*/
   END IF;
   CLOSE dup_rec;--ad
  END IF;
 END LOOP;
END IF;
--adharia
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   end if;
--adharia

   -- Standard check of p_commit.
   IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug( 'End of private api Create Recipient','+REP+');

    END IF;
   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;

    END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_recipient;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_index_pvt.Create Recipient','+REP+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

    END IF;

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO create_recipient;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_index_pvt.Create Recipient','+REP+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

    END IF;

 WHEN OTHERS THEN
    ROLLBACK TO create_recipient;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_DOC_INDEX_PVT',
                            p_procedure_name  =>  'CREATE_RECIPIENT',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_index_pvt.Create Recipient','+REP+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

    END IF;

END CREATE_RECIPIENT;
/*----------------------------------------------------*/
/* procedure name: modify_recipient                   */
/* description :  Update the existing recipient record*/
/*                for an associated document          */
/*                                                    */
/*----------------------------------------------------*/

PROCEDURE MODIFY_RECIPIENT
(
 p_api_version                IN     NUMBER    :=  1.0            ,
 p_init_msg_list              IN     VARCHAR2  := FND_API.G_TRUE  ,
 p_commit                     IN     VARCHAR2  := FND_API.G_FALSE ,
 p_validate_only              IN     VARCHAR2  := FND_API.G_TRUE  ,
 p_validation_level           IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_recipient_tbl              IN OUT NOCOPY recipient_tbl         ,
 x_return_status                 OUT NOCOPY VARCHAR2                     ,
 x_msg_count                     OUT NOCOPY NUMBER                       ,
 x_msg_data                      OUT NOCOPY VARCHAR2)
IS
-- To get the exisitng record
CURSOR get_recipient_rec_info(c_recipient_document_id  NUMBER)
 IS
SELECT ROWID,
       recipient_party_id,
       document_id,
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
  FROM AHL_RECIPIENT_DOCUMENTS
 WHERE recipient_document_id = c_recipient_document_id
   FOR UPDATE OF object_version_number NOWAIT;
--
l_api_name     CONSTANT  VARCHAR2(30) := 'MODIFY_RECIPIENT';
l_api_version  CONSTANT  NUMBER       := 1.0;
l_msg_count              NUMBER;
l_num_rec                NUMBER;
l_rowid                  ROWID;
l_document_id            NUMBER;
l_recipient_document_id  NUMBER;
l_recipient_info         get_recipient_rec_info%ROWTYPE;
 BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT modify_recipient;
   -- Check if API is called in debug mode. If yes, enable debug.

   IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.enable_debug;

    END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug( 'enter ahl_di_doc_index_pvt.Modify Recipient','+REP+');

    END IF;
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
   IF p_recipient_tbl.COUNT > 0
   THEN
      FOR i IN p_recipient_tbl.FIRST..p_recipient_tbl.LAST
      LOOP
        -- Calling validate recipients
       VALIDATE_RECIPIENT
        ( p_recipient_document_id   => p_recipient_tbl(i).recipient_document_id,
          p_recipient_party_id      => p_recipient_tbl(i).recipient_party_id,
          p_document_id             => p_recipient_tbl(i).document_id,
          p_object_version_number   => p_recipient_tbl(i).object_version_number,
          p_delete_flag             => p_recipient_tbl(i).delete_flag
       );
      END LOOP;
    --Standard call to count messages
   l_msg_count := FND_MSG_PUB.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   FOR i IN p_recipient_tbl.FIRST..p_recipient_tbl.LAST
   LOOP

      --Retrieve the existing recipient record
      OPEN get_recipient_rec_info(p_recipient_tbl(i).recipient_document_id);
      FETCH get_recipient_rec_info INTO l_recipient_info;
      CLOSE get_recipient_rec_info;

    -- This condition will take care of  lost update data bug  when concurrent users are
    -- updating same record...02/05/02

    if (l_recipient_info.object_version_number <>p_recipient_tbl(i).object_version_number)
    then
        FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
        FND_MSG_PUB.ADD;
--ad        RAISE FND_API.G_EXC_ERROR;
--ad    end if;
     else --ad

      -- The following conditions compare the new record value with old  record
      -- value, if its different then assign the new value else continue
      IF (p_recipient_tbl(i).recipient_document_id IS NOT NULL
         AND p_recipient_tbl(i).delete_flag <> 'Y')
      THEN
           l_recipient_info.recipient_party_id := p_recipient_tbl(i).recipient_party_id;
          l_recipient_info.document_id := p_recipient_tbl(i).document_id;
          l_recipient_info.attribute_category := p_recipient_tbl(i).attribute_category;
          l_recipient_info.attribute1 := p_recipient_tbl(i).attribute1;
          l_recipient_info.attribute2 := p_recipient_tbl(i).attribute2;
          l_recipient_info.attribute3 := p_recipient_tbl(i).attribute3;
          l_recipient_info.attribute3 := p_recipient_tbl(i).attribute3;
          l_recipient_info.attribute4 := p_recipient_tbl(i).attribute4;
          l_recipient_info.attribute5 := p_recipient_tbl(i).attribute5;
          l_recipient_info.attribute6 := p_recipient_tbl(i).attribute6;
          l_recipient_info.attribute7 := p_recipient_tbl(i).attribute7;
          l_recipient_info.attribute8 := p_recipient_tbl(i).attribute8;
          l_recipient_info.attribute9 := p_recipient_tbl(i).attribute9;
          l_recipient_info.attribute10 := p_recipient_tbl(i).attribute10;
          l_recipient_info.attribute11 := p_recipient_tbl(i).attribute11;
          l_recipient_info.attribute12 := p_recipient_tbl(i).attribute12;
          l_recipient_info.attribute13 := p_recipient_tbl(i).attribute13;
          l_recipient_info.attribute14 := p_recipient_tbl(i).attribute14;
          l_recipient_info.attribute15 := p_recipient_tbl(i).attribute15;
       --  update the table
           UPDATE AHL_RECIPIENT_DOCUMENTS
              SET recipient_party_id    = l_recipient_info.recipient_party_id,
                  document_id           = l_recipient_info.document_id,
                  object_version_number = l_recipient_info.object_version_number+1,
                  attribute_category    = l_recipient_info.attribute_category,
                  attribute1            = l_recipient_info.attribute1,
                  attribute2            = l_recipient_info.attribute2,
                  attribute3            = l_recipient_info.attribute3,
                  attribute4            = l_recipient_info.attribute4,
                  attribute5            = l_recipient_info.attribute5,
                  attribute6            = l_recipient_info.attribute6,
                  attribute7            = l_recipient_info.attribute7,
                  attribute8            = l_recipient_info.attribute8,
                  attribute9            = l_recipient_info.attribute9,
                  attribute10           = l_recipient_info.attribute10,
                  attribute11           = l_recipient_info.attribute11,
                  attribute12           = l_recipient_info.attribute12,
                  attribute13           = l_recipient_info.attribute13,
                  attribute14           = l_recipient_info.attribute14,
                  attribute15           = l_recipient_info.attribute15,
                  last_update_date      = sysdate,
                  last_updated_by       = fnd_global.user_id,
                  last_update_login     = fnd_global.login_id
            WHERE         ROWID =   l_recipient_info.rowid;

  --Incase of delete a recipient record
 ELSIF (p_recipient_tbl(i).recipient_document_id IS NOT NULL AND
        p_recipient_tbl(i).delete_flag = 'Y')
    THEN
       DELETE_RECIPIENT
       ( p_api_version         => 1.0               ,
         p_init_msg_list       => FND_API.G_FALSE      ,
         p_commit              => FND_API.G_FALSE     ,
         p_validate_only       => FND_API.G_TRUE      ,
         p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
         p_recipient_rec       => p_recipient_tbl(i)    ,
         x_return_status       => x_return_status    ,
         x_msg_count           => x_msg_count        ,
         x_msg_data            => x_msg_data);
      END IF;
    end if;--ad
   END LOOP;
 END IF;
    -- Standard check of p_commit.
 IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT;
 END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug( 'End of private api Modify Recipient','+REP+');

    END IF;
   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;

    END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO modify_recipient;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_index_pvt.Modify Recipient','+REP+');

        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

    END IF;

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO modify_recipient;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_index_pvt.Modify Recipient','+REP+');


        -- Check if API is called in debug mode. If yes, disable debug.
           AHL_DEBUG_PUB.disable_debug;

    END IF;

 WHEN DUP_VAL_ON_INDEX THEN
    ROLLBACK TO modify_recipient;
    X_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('AHL','AHL_DI_RECIPIENT_DUP_RECORD');
         FND_MSG_PUB.ADD;
        -- Check if API is called in debug mode. If yes, disable debug.
        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;

    END IF;
 WHEN OTHERS THEN
    ROLLBACK TO modify_recipient;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_DOC_INDEX_PVT',
                            p_procedure_name  =>  'MODIFY_RECIPIENT',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_index_pvt.Modify Recipient','+REP+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

    END IF;

END MODIFY_RECIPIENT;
/*----------------------------------------------------*/
/* procedure name: delete_recipient                   */
/* description :  Removes the recipient record for an */
/*                associated document                 */
/*                                                    */
/*----------------------------------------------------*/

PROCEDURE DELETE_RECIPIENT
(
 p_api_version            IN     NUMBER    := 1.0               ,
 p_init_msg_list          IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_commit                 IN     VARCHAR2  := FND_API.G_FALSE     ,
 p_validate_only          IN     VARCHAR2  := FND_API.G_TRUE      ,
 p_validation_level       IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
 p_recipient_rec          IN     recipient_rec                    ,
 x_return_status          OUT    NOCOPY VARCHAR2                         ,
 x_msg_count              OUT    NOCOPY NUMBER                           ,
 x_msg_data               OUT    NOCOPY VARCHAR2)
IS
--
--Code commented: pjha 23-Jul-2002 :because recipient is uneditable after creation, hence no need.
--also bug#2473425
CURSOR get_recipient_rec_info(c_recipient_document_id  NUMBER)
 IS
SELECT ROWID ,
       object_version_number
  FROM AHL_RECIPIENT_DOCUMENTS
 WHERE recipient_document_id = c_recipient_document_id
   FOR UPDATE OF object_version_number NOWAIT;

l_api_name     CONSTANT VARCHAR2(30) := 'DELETE_RECIPIENT';
l_api_version  CONSTANT NUMBER       := 1.0;
l_rowid                 ROWID;
l_object_version_number NUMBER;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT delete_recipient;
   -- Check if API is called in debug mode. If yes, enable debug.

   IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.enable_debug;

    END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug( 'enter ahl_di_doc_index_pvt.Delete Recipient','+REP+');

    END IF;
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
  -- IF p_recipient_tbl.COUNT > 0
  -- THEN
  --    FOR i IN p_recipient_tbl.FIRST..p_recipient_tbl.LAST
  --    LOOP
    OPEN get_recipient_rec_info(p_recipient_rec.recipient_document_id);
        FETCH get_recipient_rec_info INTO l_rowid,
                                          l_object_version_number;
        IF (get_recipient_rec_info%NOTFOUND) THEN
          --Modified pjha 24-Jul-2002 for bug#2473425: Begin
          --FND_MESSAGE.SET_NAME('AHL','AHL_DI_RECIP_PTY_ID_INVALID');
          FND_MESSAGE.SET_NAME('AHL','AHL_DI_RECIPIENT_DELETED');
          FND_MESSAGE.SET_TOKEN('RECPNAME',p_recipient_rec.recipient_party_number);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
          --Modified pjha 24-Jul-2002 for bug#2473425: End
        END IF;
        CLOSE get_recipient_rec_info;
        --Commented pjha 24-Jul-2002 no need of this check since record can only be
        -- deleted and hence would previous check would suffice
        /*
        -- Check for version number
       IF (l_object_version_number <> p_recipient_rec.object_version_number)
       THEN
          FND_MESSAGE.SET_NAME('AHL','AHL_DI_DOC_TL_REC_CHANGED');
          FND_MSG_PUB.ADD;
       END IF;
       */

       -- Delete the record from suppliers table
       DELETE FROM  AHL_RECIPIENT_DOCUMENTS
         WHERE ROWID = l_rowid;
   -- END LOOP;
  -- END IF;
       --Standarad check for commit
      IF FND_API.TO_BOOLEAN(p_commit) THEN
            COMMIT;
      END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug( 'End of private api Delete Recipient','+REP+');

    END IF;
   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;

    END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO delete_recipient;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_index_pvt.Delete Recipient','+REP+');


        -- Check if API is called in debug mode. If yes, disable debug.
           AHL_DEBUG_PUB.disable_debug;

    END IF;

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO delete_recipient;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_index_pvt.Delete Recipient','+REP+');


        -- Check if API is called in debug mode. If yes, disable debug.
            AHL_DEBUG_PUB.disable_debug;

    END IF;

 WHEN OTHERS THEN
    ROLLBACK TO delete_recipient;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_DI_DOC_INDEX_PVT',
                            p_procedure_name  =>  'DELETE_RECIPIENT',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_di_doc_index_pvt.Delete Recipient','+REP+');


        -- Check if API is called in debug mode. If yes, disable debug.
           AHL_DEBUG_PUB.disable_debug;

    END IF;

END DELETE_RECIPIENT;

END AHL_DI_DOC_INDEX_PVT;

/
