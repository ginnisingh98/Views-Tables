--------------------------------------------------------
--  DDL for Package Body IBE_COPY_LOGICALCONTENT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_COPY_LOGICALCONTENT_GRP" AS
 /* $Header: IBECLCTB.pls 120.0.12010000.2 2009/12/16 17:06:15 ytian noship $ */

l_true VARCHAR2(1)                := FND_API.G_TRUE;
--- Generate primary key for the table
CURSOR obj_lgl_ctnt_id_seq IS
  SELECT ibe_dsp_obj_lgl_ctnt_s1.NEXTVAL
    FROM DUAL;

PROCEDURE copy_lgl_ctnt(
  p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,
  p_commit              IN  VARCHAR2 := FND_API.g_false,
  p_object_type_code    IN  VARCHAR2,
  p_from_Product_id     IN NUMBER,
  p_from_Context_ids	IN Ids_List,
  p_to_product_ids       IN Ids_List,
x_copy_status         OUT NOCOPY IDS_LIST,
    x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2
 )
IS
   l_api_name    CONSTANT VARCHAR2(30) := 'copy_lgl_ctnt';
   i PLS_INTEGER;
   l_cntcount          NUMBER;
   l_context_id        NUMBER;
   l_from_deliverable_ids  Ids_List;
   l_deliverable_id NUMBER;

BEGIN
   SAVEPOINT copy_logical_content;
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('Copy_lg_ctnt: p_from_product_id'
                  || p_from_product_id);

   END IF;

   IF (p_from_context_ids is not null) then
      l_cntCount := p_from_context_ids.count;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('l_cntCount='
                  || l_cntCount);

      END IF;
   end if;


   FOR i in 1..l_cntcount LOOP
      l_context_id := p_from_context_ids(i);
      if (l_from_deliverable_ids is null ) then
        l_from_deliverable_ids := IDS_LIST();
      END IF;
      l_from_deliverable_ids.extend();
      BEGIN
         select item_id
         into  l_deliverable_id
         from ibe_dsp_obj_lgl_ctnt
         where context_id = l_context_id
         and object_id = p_from_product_id;
         l_from_deliverable_ids(i) := l_deliverable_id;

      EXCEPTION
       WHEN NO_DATA_FOUND then
         l_from_deliverable_ids(i) := null;
      END;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('i='||i||' l_deliverable_id='
                  || l_deliverable_id);

      END IF;


   end LOOP;

   copy_lgl_ctnt(
    p_api_version         ,
    p_init_msg_list       ,
    p_commit              ,
    p_object_type_code    ,
    p_from_Product_id     ,
    p_from_Context_ids	,
    l_from_deliverable_ids ,
    p_to_product_ids       ,
    x_copy_status,
    x_return_status       ,
    x_msg_count           ,
    x_msg_data
   );

   EXCEPTION
     WHEN OTHERS THEN
     --ROLLBACK TO copy_logical_content;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
     THEN
       FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
     END IF;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data );


END copy_lgl_ctnt;

PROCEDURE copy_lgl_ctnt(
  p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,
  p_commit              IN  VARCHAR2 := FND_API.g_false,
  p_object_type_code    IN  VARCHAR2,
  p_from_Product_id     IN NUMBER,
  p_from_Context_ids	IN Ids_List,
  p_from_deliverable_ids IN Ids_List,
  p_to_product_ids       IN Ids_List,
  x_copy_status         OUT NOCOPY IDS_LIST,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2
 )
IS

  l_api_name    CONSTANT VARCHAR2(30) := 'copy_lgl_ctnt';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_return_status     VARCHAR2(1);
  l_index	      NUMBER ;
  l_context_id        NUMBER;
  l_deliverable_id    NUMBER := null;
  l_exists	      NUMBER := null;
  l_context_type      VARCHAR2(100);
  l_obj_lgl_ctnt_id   NUMBER;
  l_applicable_to     VARCHAR2(40);
  l_cntcount          NUMBER;
  l_object_type varchar2(1) := 'I';
  l_to_count NUMBER;
  l_to_product_id NUMBER;
  l_ctnt_id NUMBER;
  l_version_number NUMBER;
  i PLS_INTEGER;
  j PLS_INTEGER;
  l_item_id NUMBER;

BEGIN
 SAVEPOINT copy_logical_content;

 if (p_from_context_ids is not null) then

  l_cntCount := p_from_context_ids.count;
  l_to_count := p_to_product_ids.count;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('from product context numbers:'||l_cntCount);
          IBE_Util.Debug('to product numbers:'||l_to_Count);
  END IF;

  FOR i in 1..l_cntcount LOOP

    l_context_id := p_from_context_ids(i);
    l_deliverable_id := p_from_deliverable_ids(i);

    if (x_copy_status is null ) then
        x_copy_status := IDS_LIST();
    END IF;
    x_copy_status.extend();

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('Content Component loop i:'||i);
          IBE_Util.Debug('context_id=:'||l_context_id);
          IBE_Util.Debug('deliverableid=:'||l_deliverable_id);

    END IF;

    SAVEPOINT copy_logical_content2;

    for j in 1..l_to_count Loop

     l_to_product_id := p_to_product_ids(j);

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('Target Products loop j:'||j);
          IBE_Util.Debug('toproductid=:'||l_to_product_id);
     END IF;

      BEGIN
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('check if existing in the target product');
         END IF;

         select obj_lgl_ctnt_id, object_version_number,item_id
         into l_ctnt_id, l_version_number, l_item_id
         from ibe_dsp_obj_lgl_ctnt
         where context_id = l_context_id
         and object_id = l_to_product_id;

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('target product Content rec exists l_ctnt_id='||l_ctnt_id || ' version='||l_version_number);
         END IF;

         -- update the existing record
         IF (l_deliverable_id is  null) then
            DELETE FROM IBE_DSP_OBJ_LGL_ctnt
            WHERE obj_lgl_ctnt_id       = l_ctnt_id
            AND   object_version_number = l_version_number
            AND   object_type           = l_object_type;

            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
               IBE_Util.Debug('delete if l_deliverable_id is null');
            END IF;


          ELSE
           if (l_item_id <> l_deliverable_id) THEN
            UPDATE IBE_DSP_OBJ_LGL_CTNT
            SET    LAST_UPDATE_DATE  = SYSDATE,
             LAST_UPDATED_BY   = FND_GLOBAL.user_id,
             LAST_UPDATE_LOGIN = FND_GLOBAL.user_id,
             OBJECT_ID         = l_to_product_id,
             OBJECT_TYPE       = l_object_type,
             CONTEXT_id        = l_context_id,
             ITEM_id           = l_deliverable_id ,
             OBJECT_VERSION_NUMBER = l_version_number+1
            WHERE OBJ_LGL_CTNT_id        = l_ctnt_id
            AND   OBJECT_VERSION_NUMBER  = l_version_number;

              IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                IBE_Util.Debug('update with the new l_deliverable_id is null');
               END IF;
            END IF; --updating the target product record

           END IF; -- end if updating the product record
      EXCEPTION
        when no_data_found then
              IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                IBE_Util.Debug('target product content rec not exist, insert one if  l_deliverable_id is null');
               END IF;

     IF (l_deliverable_id is not null) then
         --insert new rec
      OPEN obj_lgl_ctnt_id_seq;
      FETCH obj_lgl_ctnt_id_seq INTO l_obj_lgl_ctnt_id;
      CLOSE obj_lgl_ctnt_id_seq;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('begin insert new rec for target product, seq id='||l_obj_lgl_ctnt_id);
      END IF;

      INSERT INTO IBE_DSP_OBJ_LGL_CTNT (
        OBJ_LGL_CTNT_ID,
        OBJECT_VERSION_NUMBER,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        OBJECT_ID,
        OBJECT_TYPE,
        CONTEXT_ID,
        ITEM_ID )
      VALUES (
        l_obj_lgl_ctnt_id,
        1,
        SYSDATE,
        FND_GLOBAL.user_id,
        SYSDATE,
        FND_GLOBAL.user_id,
        FND_GLOBAL.user_id,
        l_to_product_id,
        l_object_type,
        l_context_id,
        l_deliverable_id);

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('done inserting, l_to_product_id'||l_to_product_id
                         ||' object_type='||l_object_type
                         ||' context_id='||l_context_id||' l_deveriableid='||l_deliverable_id);
      END IF;

     END IF; -- l_deliverable_id is not null

   end; -- end inserting if target product content rec not exists

   end LOOP;

   x_copy_status(i) := 0; -- 0 success, -1 fail

  END Loop;



  end if;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data );

 EXCEPTION
     WHEN OTHERS THEN
     ROLLBACK TO copy_logical_content2;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
     THEN
       FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
     END IF;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data );


END copy_lgl_ctnt;

END IBE_copy_LogicalContent_GRP;

/
