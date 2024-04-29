--------------------------------------------------------
--  DDL for Package Body PV_PRGM_PMT_MODE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PRGM_PMT_MODE_PVT" as
/* $Header: pvxvppmb.pls 120.2 2006/08/14 18:28:48 speddu ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_PRGM_PMT_MODE_PVT
-- Purpose
--
-- History
--         26-APR-2002    Peter.Nixon         Created
--         30-APR-2002    Peter.Nixon         Modified
--  03/03/03  sveeerave bug fix#2830585 in Get_Pmnt_Mode_Desc
--  25/07/03  ktsao     Added Copy_Prgm_Pmt_Mode for program copy functionality
--  14/10/03  ktsao     Took out Copy_Prgm_Pmt_Mode.
--  29/08/05  ktsao     Fixed for bug 4572286.
--
-- NOTE
--
-- Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA
--                          All rights reserved.
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_PRGM_PMT_MODE_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvppmb.pls';
l_pmt_mode_desc      VARCHAR2(35) := null;


-- Following procedure gives the description for the Payment Method Code passed

PV_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Get_Pmnt_Mode_Desc(
   p_program_payment_mode IN  VARCHAR2
  ,p_program_id   IN  NUMBER
  ,p_geo_hierarchy_id IN  NUMBER
  ,x_pmt_mode_desc OUT NOCOPY VARCHAR2
  )
IS

l_api_name                  CONSTANT  VARCHAR2(30)            := 'Get_Pmnt_Mode_Desc';

-- corrected the queries, logic for bug fix#2830585. -- sveerave,03/03/03
CURSOR c_get_oe_prgm_pmt_mode(cv_program_payment_mode  VARCHAR2, cv_program_id NUMBER, cv_program_geo_hierarchy_id NUMBER) IS
  SELECT  lkp.MEANING
  FROM  oe_lookups lkp,
    PV_PROGRAM_PAYMENT_MODE pay_mode
  WHERE lkp.LOOKUP_CODE = cv_program_payment_mode
    AND pay_mode.PROGRAM_ID = cv_program_id
    AND pay_mode.GEO_HIERARCHY_ID = cv_program_geo_hierarchy_id
    AND lkp.lookup_type = 'PAYMENT TYPE';

CURSOR c_get_pv_prgm_pmt_mode(cv_program_payment_mode  VARCHAR2, cv_program_id NUMBER, cv_program_geo_hierarchy_id NUMBER) IS
  SELECT  lkp.MEANING
  FROM  pv_lookups lkp,
    PV_PROGRAM_PAYMENT_MODE pay_mode
  WHERE lkp.LOOKUP_CODE = cv_program_payment_mode
    AND pay_mode.PROGRAM_ID = cv_program_id
    AND pay_mode.GEO_HIERARCHY_ID = cv_program_geo_hierarchy_id
    AND lkp.lookup_type = 'PV_PAYMENT_TYPE';

BEGIN
      -- Initialize API return status to SUCCESS
      ---------------Initialize --------------------
      -- Standard Start of API savepoint
      SAVEPOINT Get_Pmnt_Mode_Desc;
      OPEN c_get_oe_prgm_pmt_mode(p_program_payment_mode , p_program_id, p_geo_hierarchy_id);
      FETCH c_get_oe_prgm_pmt_mode INTO x_pmt_mode_desc  ;
      IF c_get_oe_prgm_pmt_mode%NOTFOUND THEN
        CLOSE c_get_oe_prgm_pmt_mode;
        OPEN c_get_pv_prgm_pmt_mode(p_program_payment_mode , p_program_id, p_geo_hierarchy_id);
        FETCH c_get_pv_prgm_pmt_mode INTO x_pmt_mode_desc  ;
        IF c_get_pv_prgm_pmt_mode%NOTFOUND THEN
          CLOSE c_get_pv_prgm_pmt_mode;
          FND_MESSAGE.set_name('PV', 'PV_API_MISSING_ENTITY');
          FND_MESSAGE.set_token('MODE','find');
          FND_MESSAGE.set_token('ENTITY','Payment Method Meaning');
          FND_MESSAGE.set_token('ID','Payment Method: '||p_program_payment_mode
                                     ||' Program Id: '||p_program_id
                                     ||' Geo Hierarchy Id: '|| p_geo_hierarchy_id);
          FND_MSG_PUB.add;
          IF (PV_DEBUG_HIGH_ON) THEN
            PVX_UTILITY_PVT.debug_message('No Data found for the payment method description in Get_Pmnt_Mode_Desc');
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE c_get_pv_prgm_pmt_mode;
      END IF;
      CLOSE c_get_oe_prgm_pmt_mode;
End Get_Pmnt_Mode_Desc;

-- The following procedure get the Geo_Area_Name and the Location Type

PROCEDURE Get_Pmnt_Geo_Hierarhy(
   p_program_payment_mode IN  VARCHAR2
  ,p_program_id     IN  NUMBER
  ,p_geo_hierarchy_id   IN  NUMBER
  ,x_geo_area_name    OUT NOCOPY VARCHAR2
  ,x_location_type_name OUT NOCOPY VARCHAR2
  )
IS



CURSOR c_get_geo_hierarchy(cv_program_payment_mode  VARCHAR2, cv_program_id NUMBER, cv_program_geo_hierarchy_id NUMBER) IS
  SELECT DECODE(LH.LOCATION_TYPE_CODE, 'AREA1', LH.AREA1_NAME, 'AREA2',LH.AREA2_NAME, 'COUNTRY',
                      LH.COUNTRY_NAME, 'CREGION',LH.COUNTRY_REGION_NAME, 'STATE', LH.STATE_NAME, 'SREGION',
                      LH.STATE_REGION_NAME, 'CITY', LH.CITY_NAME,'POSTAL_CODE',
                      LH.POSTAL_CODE_START||'-'||LH.POSTAL_CODE_END) GEO_AREA_NAME,
          LH.LOCATION_TYPE_NAME LOCATION_TYPE_NAME
  FROM  PV_PROGRAM_PAYMENT_MODE PPPMNT,
      JTF_LOC_HIERARCHIES_VL LH
  WHERE   PPPMNT.PROGRAM_ID = cv_program_id
  AND   PPPMNT.GEO_HIERARCHY_ID = cv_program_geo_hierarchy_id
  AND   PPPMNT.MODE_OF_PAYMENT = cv_program_payment_mode
  AND   LH.LOCATION_HIERARCHY_ID = PPPMNT.GEO_HIERARCHY_ID
  AND   PPPMNT.mode_type = 'PAYMENT';

BEGIN
      -- Initialize API return status to SUCCESS


      ---------------Initialize --------------------
      -- Standard Start of API savepoint
      SAVEPOINT GET_pmnt_method_PVT;


      OPEN c_get_geo_hierarchy(p_program_payment_mode , p_program_id, p_geo_hierarchy_id);
      FETCH c_get_geo_hierarchy INTO x_geo_area_name, x_location_type_name  ;
       IF c_get_geo_hierarchy%NOTFOUND THEN
      FND_MESSAGE.set_name('PV', 'PV_API_MISSING_ENTITY');
      FND_MESSAGE.set_token('MODE','');
      FND_MESSAGE.set_token('ENTITY','GET_pmnt_method_PVT');
      FND_MESSAGE.set_token('ID','No Data found in c_get_geo_hierarchy');
          FND_MSG_PUB.add;
        IF (PV_DEBUG_HIGH_ON) THEN

        PVX_UTILITY_PVT.debug_message('No Data found for the payment method description');
        END IF;
      RAISE FND_API.G_EXC_ERROR;
     END IF;
    CLOSE c_get_geo_hierarchy;


End Get_Pmnt_Geo_Hierarhy;











PROCEDURE Create_Prgm_Pmt_Mode(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_prgm_pmt_mode_rec          IN   prgm_pmt_mode_rec_type  := g_miss_prgm_pmt_mode_rec
    ,x_program_payment_mode_id    OUT NOCOPY  NUMBER
    )

 IS
   l_api_version_number        CONSTANT  NUMBER                  := 1.0;
   l_api_name                  CONSTANT  VARCHAR2(30)            := 'Create_Prgm_Pmt_Mode';
   l_full_name                 CONSTANT  VARCHAR2(60)            := g_pkg_name ||'.'|| l_api_name;


   l_prgm_pmt_mode_rec                   prgm_pmt_mode_rec_type  := p_prgm_pmt_mode_rec;

   l_object_version_number               NUMBER                  := 1;
   l_uniqueness_check                    VARCHAR2(1);
   l_create                              BOOLEAN;

   -- Cursor to get the sequence for pv_program_payment_mode_id
   CURSOR c_prgm_pmt_mode_id_seq IS
      SELECT PV_PROGRAM_PAYMENT_MODE_S.NEXTVAL
      FROM dual;


   -- Cursor to validate the uniqueness
   CURSOR c_prgm_pmt_mode_id_seq_exists (l_id IN NUMBER) IS
      SELECT  'X'
      FROM PV_PROGRAM_PAYMENT_MODE
      WHERE program_payment_mode_id = l_id;


   CURSOR c_prgm_pmt_mode_id (l_id IN NUMBER) IS
      select PROGRAM_PAYMENT_MODE_ID, object_version_number, MODE_OF_PAYMENT
      from PV_PROGRAM_PAYMENT_MODE
      where GEO_HIERARCHY_ID = l_id
      AND MODE_OF_PAYMENT in ('PO_NUM_DISABLED', 'PO_NUM_ENABLED');

BEGIN
      ---------------Initialize --------------------
      -- Standard Start of API savepoint
      SAVEPOINT Create_Prgm_Pmt_Mode_PVT;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
            l_api_version_number
           ,p_api_version_number
           ,l_api_name
           ,G_PKG_NAME
           )
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: '||l_full_name||' - start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

       --------------- validate -------------------------

      IF (PV_DEBUG_HIGH_ON) THEN



      PVX_Utility_PVT.debug_message(l_full_name ||': validate');

      END IF;

      IF FND_GLOBAL.User_Id IS NULL THEN
          FND_MESSAGE.set_name('PV', 'PV_API_USER_PROFILE_MISSING');
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_create := true;
      IF l_prgm_pmt_mode_rec.mode_of_payment = 'PO_NUM_DISABLED' or l_prgm_pmt_mode_rec.mode_of_payment = 'PO_NUM_ENABLED' THEN
         FOR x in c_prgm_pmt_mode_id (l_prgm_pmt_mode_rec.geo_hierarchy_id) LOOP
         IF (PV_DEBUG_HIGH_ON) THEN
            PVX_Utility_PVT.debug_message(l_prgm_pmt_mode_rec.geo_hierarchy_id ||'l_prgm_pmt_mode_rec.geo_hierarchy_id');
            PVX_Utility_PVT.debug_message(x.program_payment_mode_id ||'x.program_payment_mode_id');
            PVX_Utility_PVT.debug_message(x.object_version_number ||'x.object_version_number');
         END IF;
         l_create := false;

	    if(x.MODE_OF_PAYMENT <> l_prgm_pmt_mode_rec.mode_of_payment) then

             l_prgm_pmt_mode_rec.program_payment_mode_id := x.program_payment_mode_id;
             l_prgm_pmt_mode_rec.object_version_number := x.object_version_number;

             Update_Prgm_Pmt_Mode(
               l_api_version_number,
               p_init_msg_list,
               p_commit,
               p_validation_level,
               x_return_status,
               x_msg_count,
               x_msg_data,
               l_prgm_pmt_mode_rec);
               x_program_payment_mode_id := l_prgm_pmt_mode_rec.program_payment_mode_id;

	     END IF;
         END LOOP;
      END IF;

      IF l_create THEN
         IF l_prgm_pmt_mode_rec.program_payment_mode_id IS NULL OR
           l_prgm_pmt_mode_rec.program_payment_mode_id = FND_API.g_miss_num THEN
           LOOP
              -- Get the identifier
             OPEN c_prgm_pmt_mode_id_seq;
             FETCH c_prgm_pmt_mode_id_seq INTO l_prgm_pmt_mode_rec.program_payment_mode_id;
             CLOSE c_prgm_pmt_mode_id_seq;

              -- Check the uniqueness of the identifier
             OPEN c_prgm_pmt_mode_id_seq_exists(l_prgm_pmt_mode_rec.program_payment_mode_id);
             FETCH c_prgm_pmt_mode_id_seq_exists INTO l_uniqueness_check;
             -- Exit when the identifier uniqueness is established
             EXIT WHEN c_prgm_pmt_mode_id_seq_exists%ROWCOUNT = 0;
             CLOSE c_prgm_pmt_mode_id_seq_exists;
           END LOOP;
         END IF;

         -- Debug message
         IF (PV_DEBUG_HIGH_ON) THEN

         PVX_UTILITY_PVT.debug_message('Private API: ' || l_full_name || ' - program_payment_mode_id = '|| l_prgm_pmt_mode_rec.program_payment_mode_id);
         END IF;

         IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
             -- Debug message
             IF (PV_DEBUG_HIGH_ON) THEN

             PVX_UTILITY_PVT.debug_message('Private API: ' || l_full_name || ' - Validate_Prgm_Pmt_Mode');
             END IF;

              -- Populate the default required items
              l_prgm_pmt_mode_rec.last_update_date        := SYSDATE;
              l_prgm_pmt_mode_rec.last_updated_by         := FND_GLOBAL.user_id;
              l_prgm_pmt_mode_rec.creation_date           := SYSDATE;
              l_prgm_pmt_mode_rec.created_by              := FND_GLOBAL.user_id;
              l_prgm_pmt_mode_rec.last_update_login       := FND_GLOBAL.conc_login_id;
              l_prgm_pmt_mode_rec.object_version_number   := l_object_version_number;

             -- Invoke validation procedures
             Validate_Prgm_Pmt_Mode(
                p_api_version_number     => 1.0
               ,p_init_msg_list          => FND_API.G_FALSE
               ,p_validation_level       => p_validation_level
               ,p_validation_mode        => JTF_PLSQL_API.g_create
               ,p_prgm_pmt_mode_rec      => l_prgm_pmt_mode_rec
               ,x_return_status          => x_return_status
               ,x_msg_count              => x_msg_count
               ,x_msg_data               => x_msg_data
               );
             -- Debug message
             IF (PV_DEBUG_HIGH_ON) THEN

             PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' -  Validate_Prgm_Pmt_Mode return_status = ' || x_return_status );
             END IF;
         END IF;

         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;

         -- Debug Message
         IF (PV_DEBUG_HIGH_ON) THEN

         PVX_UTILITY_PVT.debug_message( 'Private API:' || l_full_name || ' -  Calling create table handler');
         END IF;

         -- Invoke table handler(PV_PRGM_PMT_MODE_PKG.Insert_Row)
         PV_PRGM_PMT_MODE_PKG.Insert_Row(
              px_program_payment_mode_id  => l_prgm_pmt_mode_rec.program_payment_mode_id
             ,p_program_id                => l_prgm_pmt_mode_rec.program_id
             ,p_geo_hierarchy_id          => l_prgm_pmt_mode_rec.geo_hierarchy_id
             ,p_mode_of_payment           => l_prgm_pmt_mode_rec.mode_of_payment
             ,p_last_update_date          => l_prgm_pmt_mode_rec.last_update_date
             ,p_last_updated_by           => l_prgm_pmt_mode_rec.last_updated_by
             ,p_creation_date             => l_prgm_pmt_mode_rec.creation_date
             ,p_created_by                => l_prgm_pmt_mode_rec.created_by
             ,p_last_update_login         => l_prgm_pmt_mode_rec.last_update_login
             ,p_object_version_number     => l_object_version_number
             ,p_mode_type           => l_prgm_pmt_mode_rec.mode_type
             );

         x_program_payment_mode_id := l_prgm_pmt_mode_rec.program_payment_mode_id;
      END IF;

      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

     FND_MSG_PUB.count_and_get(
        p_encoded => FND_API.g_false
       ,p_count   => x_msg_count
       ,p_data    => x_msg_data
       );

     -- Debug Message
     IF (PV_DEBUG_HIGH_ON) THEN

     PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' - end');
     END IF;

     -- Standard check for p_commit
     IF FND_API.to_Boolean( p_commit ) THEN
         COMMIT WORK;
     END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Create_Prgm_Pmt_Mode_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Create_Prgm_Pmt_Mode_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

   WHEN OTHERS THEN
     ROLLBACK TO Create_Prgm_Pmt_Mode_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

End Create_Prgm_Pmt_Mode;


PROCEDURE Update_Prgm_Pmt_Mode(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_prgm_pmt_mode_rec          IN   prgm_pmt_mode_rec_type
    )

IS

 CURSOR c_get_prgm_pmt_mode(cv_program_payment_mode_id NUMBER) IS
    SELECT *
    FROM  PV_PROGRAM_PAYMENT_MODE
    WHERE PROGRAM_PAYMENT_MODE_ID = cv_program_payment_mode_id;

  l_api_name                  CONSTANT VARCHAR2(30) := 'Update_Prgm_Pmt_Mode';
  l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_api_version_number        CONSTANT NUMBER       := 1.0;

  -- Local Variables
  l_ref_prgm_pmt_mode_rec              c_get_prgm_pmt_mode%ROWTYPE ;
  l_tar_prgm_pmt_mode_rec              PV_PRGM_PMT_MODE_PVT.prgm_pmt_mode_rec_type := p_prgm_pmt_mode_rec;
  l_rowid                              ROWID;
  l_update                             BOOLEAN := true;

  CURSOR c_prgm_pmt_mode_id (l_id IN NUMBER) IS
      select GEO_HIERARCHY_ID, MODE_OF_PAYMENT
      from PV_PROGRAM_PAYMENT_MODE
      where PROGRAM_PAYMENT_MODE_ID = l_id
      and MODE_OF_PAYMENT in ('PO_NUM_DISABLED', 'PO_NUM_ENABLED');

  CURSOR c_prgm_duplicate_pmt_mode (l_id IN NUMBER) IS
      select GEO_HIERARCHY_ID, MODE_OF_PAYMENT, PROGRAM_PAYMENT_MODE_ID, object_version_number
      from PV_PROGRAM_PAYMENT_MODE
      where GEO_HIERARCHY_ID = l_id
      and MODE_OF_PAYMENT in ('PO_NUM_DISABLED', 'PO_NUM_ENABLED');

 BEGIN




     ---------Initialize ------------------

      -- Standard Start of API savepoint
      SAVEPOINT Update_Prgm_Pmt_Mode_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (l_api_version_number
                                         ,p_api_version_number
                                         ,l_api_name
                                         ,G_PKG_NAME
                                         )
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      OPEN c_get_prgm_pmt_mode( l_tar_prgm_pmt_mode_rec.program_payment_mode_id);
      FETCH c_get_prgm_pmt_mode INTO l_ref_prgm_pmt_mode_rec  ;

       IF ( c_get_prgm_pmt_mode%NOTFOUND) THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_ENTITY');
         FND_MESSAGE.set_token('MODE','Update');
         FND_MESSAGE.set_token('ENTITY','prgm_pmt_mode');
         FND_MESSAGE.set_token('ID',TO_CHAR(l_tar_prgm_pmt_mode_rec.program_payment_mode_id));
         FND_MSG_PUB.add;
         RAISE FND_API.G_EXC_ERROR;
       END IF;

       -- Debug Message
         IF (PV_DEBUG_HIGH_ON) THEN

         PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Close Cursor');
         END IF;
       CLOSE  c_get_prgm_pmt_mode;

      If (l_tar_prgm_pmt_mode_rec.object_version_number is NULL or
          l_tar_prgm_pmt_mode_rec.object_version_number = FND_API.G_MISS_NUM ) THEN

           FND_MESSAGE.set_name('PV', 'PV_API_VERSION_MISSING');
           FND_MESSAGE.set_token('COLUMN','object_version_number');
           FND_MSG_PUB.add;
           RAISE FND_API.G_EXC_ERROR;
      END IF;



      -- Check Whether record has been changed by someone else
      IF (l_tar_prgm_pmt_mode_rec.object_version_number <> l_ref_prgm_pmt_mode_rec.object_version_number) THEN
           FND_MESSAGE.set_name('PV', 'PV_API_RECORD_CHANGED');
           FND_MESSAGE.set_token('VALUE','prgm_pmt_mode');
           FND_MSG_PUB.add;
           RAISE FND_API.G_EXC_ERROR;
      END IF;



       IF p_prgm_pmt_mode_rec.mode_of_payment = 'PO_NUM_DISABLED' or p_prgm_pmt_mode_rec.mode_of_payment = 'PO_NUM_ENABLED' THEN
         FOR x in c_prgm_pmt_mode_id (p_prgm_pmt_mode_rec.program_payment_mode_id) LOOP
            if(x.geo_hierarchy_id <>  p_prgm_pmt_mode_rec.geo_hierarchy_id) then
	      FOR y in c_prgm_duplicate_pmt_mode(p_prgm_pmt_mode_rec.geo_hierarchy_id) LOOP
                  Delete_Prgm_Pmt_Mode(
                      p_api_version_number        => l_api_version_number
                     ,p_init_msg_list             => FND_API.G_FALSE
                     ,p_commit                    => FND_API.G_FALSE
                     ,p_validation_level          => FND_API.G_VALID_LEVEL_FULL
                     ,x_return_status             => x_return_status
                     ,x_msg_count                 => x_msg_count
                     ,x_msg_data                  => x_msg_data
                     ,p_program_payment_mode_id   => y.program_payment_mode_id
                     ,p_object_version_number     => y.object_version_number
                   );

	           IF (PV_DEBUG_HIGH_ON) THEN
                     PVX_UTILITY_PVT.debug_message('X_return_status from delete api to delete the duplicate record ' || x_return_status);
                     PVX_UTILITY_PVT.debug_message('x_msg_count from delete api to delete the duplicate record  ' || x_msg_count);
                     PVX_UTILITY_PVT.debug_message('x_msg_data from delete api to delete the duplicate record  ' || x_msg_data);
                   END IF;

                   IF x_return_status = FND_API.g_ret_sts_error THEN
                       RAISE FND_API.g_exc_error;
                   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                       RAISE FND_API.g_exc_unexpected_error;
                   END IF;
	      END LOOP;

	   elsif (x.mode_of_payment =  p_prgm_pmt_mode_rec.mode_of_payment) then
                l_update := false;
	   END IF;
         END LOOP;
         END IF;


     if(l_update) then



      IF ( p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
          -- Debug message
           IF (PV_DEBUG_HIGH_ON) THEN

           PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Validate_Prgm_Pmt_Mode');
           END IF;

          -- Invoke validation procedures
          Validate_Prgm_Pmt_Mode(
             p_api_version_number  => 1.0
            ,p_init_msg_list       => FND_API.G_FALSE
            ,p_validation_level    => p_validation_level
            ,p_validation_mode     => JTF_PLSQL_API.g_update
            ,p_prgm_pmt_mode_rec   => p_prgm_pmt_mode_rec
            ,x_return_status       => x_return_status
            ,x_msg_count           => x_msg_count
            ,x_msg_data            => x_msg_data
            );
      END IF;

     IF x_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
     ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
     END IF;

     -- replace g_miss_char/num/date with current column values
     Complete_Rec(
              p_prgm_pmt_mode_rec => p_prgm_pmt_mode_rec
             ,x_complete_rec      => l_tar_prgm_pmt_mode_rec
             );

      -- Debug Message
       IF (PV_DEBUG_HIGH_ON) THEN

       PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Calling update table handler');
       END IF;

      -- Invoke table handler(PV_PRGM_PMT_MODE_PKG.Update_Row)
      PV_PRGM_PMT_MODE_PKG.Update_Row(
           p_program_payment_mode_id  => l_tar_prgm_pmt_mode_rec.program_payment_mode_id
          ,p_program_id               => l_tar_prgm_pmt_mode_rec.program_id
          ,p_geo_hierarchy_id         => l_tar_prgm_pmt_mode_rec.geo_hierarchy_id
          ,p_mode_of_payment          => l_tar_prgm_pmt_mode_rec.mode_of_payment
          ,p_last_update_date         => SYSDATE
          ,p_last_updated_by          => FND_GLOBAL.user_id
          ,p_last_update_login        => FND_GLOBAL.conc_login_id
          ,p_object_version_number    => l_tar_prgm_pmt_mode_rec.object_version_number
	  ,p_mode_type          => l_tar_prgm_pmt_mode_rec.mode_type
          );

     End if;

     -- Check for commit
     IF FND_API.to_boolean(p_commit) THEN
        COMMIT;
     END IF;

    FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false
      ,p_count   => x_msg_count
      ,p_data    => x_msg_data
      );

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' - end');
      END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Update_Prgm_Pmt_Mode_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_Prgm_Pmt_Mode_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

   WHEN OTHERS THEN
     ROLLBACK TO Update_Prgm_Pmt_Mode_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );
End Update_Prgm_Pmt_Mode;



PROCEDURE Delete_Prgm_Pmt_Mode(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,p_program_payment_mode_id    IN   NUMBER
    ,p_object_version_number      IN   NUMBER
    )

 IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Delete_Prgm_Pmt_Mode';
l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_api_version_number        CONSTANT NUMBER       := 1.0;
l_object_version_number              NUMBER;

BEGIN

     ---- Initialize----------------

      -- Standard Start of API savepoint
      SAVEPOINT Delete_Prgm_Pmt_Mode_PVT;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' - start');
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (l_api_version_number
                                         ,p_api_version_number
                                         ,l_api_name
                                         ,G_PKG_NAME
                                         )
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');
      END IF;

      -- Invoke table handler(PV_PRGM_PMT_MODE_PKG.Delete_Row)
      PV_PRGM_PMT_MODE_PKG.Delete_Row(
           p_program_payment_mode_id  => p_program_payment_mode_id
          ,p_object_version_number    => p_object_version_number
          );

     -- Check for commit
     IF FND_API.to_boolean(p_commit) THEN
        COMMIT;
     END IF;

    FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false
      ,p_count   => x_msg_count
      ,p_data    => x_msg_data
      );

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' - end');
      END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Delete_Prgm_Pmt_Mode_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Delete_Prgm_Pmt_Mode_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

   WHEN OTHERS THEN
     ROLLBACK TO Delete_Prgm_Pmt_Mode_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

End Delete_Prgm_Pmt_Mode;



PROCEDURE Lock_Prgm_Pmt_Mode(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_program_payment_mode_id    IN   NUMBER
    ,p_object_version             IN   NUMBER
    )

 IS
 l_api_name                  CONSTANT VARCHAR2(30) := 'Lock_Prgm_Pmt_Mode';
 l_api_version_number        CONSTANT NUMBER       := 1.0;
 l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
 l_program_payment_mode_id            NUMBER;

CURSOR c_prgm_pmt_mode IS
   SELECT program_payment_mode_id
   FROM PV_PROGRAM_PAYMENT_MODE
   WHERE program_payment_mode_id = p_program_payment_mode_id
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

BEGIN

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: '||l_full_name||' - start');
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
              l_api_version_number
             ,p_api_version_number
             ,l_api_name
             ,G_PKG_NAME
             )
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


------------------------ lock -------------------------

  IF (PV_DEBUG_HIGH_ON) THEN



  PVX_UTILITY_PVT.debug_message(l_full_name||': start');

  END IF;
  OPEN c_prgm_pmt_mode;

  FETCH c_prgm_pmt_mode INTO l_program_payment_mode_id;

  IF (c_prgm_pmt_mode%NOTFOUND) THEN
    CLOSE c_prgm_pmt_mode;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_prgm_pmt_mode;

 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
     p_encoded => FND_API.g_false
    ,p_count   => x_msg_count
    ,p_data    => x_msg_data
    );

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' - end');
      END IF;

EXCEPTION
/*
   WHEN PVX_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
  PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');
*/
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Lock_Prgm_Pmt_Mode_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Lock_Prgm_Pmt_Mode_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );


   WHEN OTHERS THEN
     ROLLBACK TO Lock_Prgm_Pmt_Mode_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

End Lock_Prgm_Pmt_Mode;



PROCEDURE Check_UK_Items(
     p_prgm_pmt_mode_rec         IN  prgm_pmt_mode_rec_type
    ,p_validation_mode           IN  VARCHAR2 := JTF_PLSQL_API.g_create
    ,x_return_status             OUT NOCOPY VARCHAR2
    )

IS

l_valid_flag  VARCHAR2(1);
l_geo_area_name VARCHAR2(20) ;
l_location_type_name VARCHAR2(20);
l_mode_of_payment VARCHAR2(20) ;

   -- Cursor to get the geoAreaName of the given location hierarchy id
   CURSOR c_geo_area_name (l_loc_hie_id IN NUMBER) IS
      select DECODE(LH.LOCATION_TYPE_CODE, 'AREA1', LH.AREA1_NAME, 'AREA2',LH.AREA2_NAME,
                    'COUNTRY', LH.COUNTRY_NAME, 'CREGION', LH.COUNTRY_REGION_NAME,
                    'STATE', LH.STATE_NAME, 'SREGION', LH.STATE_REGION_NAME, 'CITY', LH.CITY_NAME,
                    'POSTAL_CODE', LH.POSTAL_CODE_START||'-'||LH.POSTAL_CODE_END, to_char(LOCATION_HIERARCHY_ID)),
                    LH.LOCATION_TYPE_NAME LOCATION_TYPE_NAME
      from JTF_LOC_HIERARCHIES_VL LH
      where LOCATION_HIERARCHY_ID = l_loc_hie_id;

   -- Cursor to get the meaning of paymentCode
   CURSOR c_payment_code (l_payment_code IN VARCHAR2) IS
      select meaning from pv_lookups
      where lookup_type = 'PV_PAYMENT_TYPE'
      and lookup_code = l_payment_code;


BEGIN

      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN

         l_valid_flag := PVX_UTILITY_PVT.check_uniqueness(
         'PV_PROGRAM_PAYMENT_MODE',
         'program_payment_mode_id = ''' || p_prgm_pmt_mode_rec.program_payment_mode_id ||''''
         );

        IF l_valid_flag = FND_API.g_false THEN
          FND_MESSAGE.set_name('PV', 'PV_API_DUPLICATE_ENTITY');
          FND_MESSAGE.set_token('ID',to_char(p_prgm_pmt_mode_rec.program_payment_mode_id) );
          FND_MESSAGE.set_token('ENTITY','PRGM_PMT_MODE');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
        END IF;

      END IF;

        -- Debug message
        IF (PV_DEBUG_HIGH_ON) THEN

        PVX_UTILITY_PVT.debug_message('- In Check_UK_Items API' );
        END IF;

         l_valid_flag := PVX_UTILITY_PVT.check_uniqueness(
         'PV_PROGRAM_PAYMENT_MODE',
         'mode_type = '''||
	 p_prgm_pmt_mode_rec.mode_type ||
	 ''' and mode_of_payment = '''||
	 p_prgm_pmt_mode_rec.mode_of_payment||
	 ''' AND GEO_HIERARCHY_ID = ''' ||
	 p_prgm_pmt_mode_rec.GEO_HIERARCHY_ID||'''  '
         );

   IF l_valid_flag = FND_API.g_false THEN
        FND_MESSAGE.set_name('PV', 'PV_PMNT_MODE_DUPLICATE_ENTITY');
        OPEN c_payment_code(p_prgm_pmt_mode_rec.mode_of_payment);
        FETCH c_payment_code into l_mode_of_payment;
        FND_MESSAGE.set_token('ENTITY1', l_mode_of_payment);
        CLOSE c_payment_code;

        -- Get the get_area_name
        OPEN c_geo_area_name(p_prgm_pmt_mode_rec.GEO_HIERARCHY_ID);
        FETCH c_geo_area_name into l_geo_area_name, l_location_type_name;
        FND_MESSAGE.set_token('ENTITY2', l_location_type_name);
        FND_MESSAGE.set_token('ENTITY3', l_geo_area_name);
        CLOSE c_geo_area_name;

        FND_MSG_PUB.ADD;
        x_return_status := Fnd_Api.g_ret_sts_error;
        RETURN;

    /*
        Get_Pmnt_Mode_Desc ( p_prgm_pmt_mode_rec.mode_of_payment
               , p_prgm_pmt_mode_rec.program_id
               , p_prgm_pmt_mode_rec.GEO_HIERARCHY_ID
                 , x_pmt_mode_desc
       );


       Get_Pmnt_Geo_Hierarhy( p_prgm_pmt_mode_rec.mode_of_payment
                  , p_prgm_pmt_mode_rec.program_id
                  , p_prgm_pmt_mode_rec.GEO_HIERARCHY_ID
                , x_geo_area_name
                , x_location_type_name
      );


           FND_MESSAGE.set_name('PV', 'PV_PMNT_MODE_DUPLICATE_ENTITY');
           FND_MESSAGE.set_token('ENTITY1',x_pmt_mode_desc);
       FND_MESSAGE.set_token('ENTITY2',x_location_type_name);
         FND_MESSAGE.set_token('ENTITY3',x_geo_area_name);
           FND_MSG_PUB.add;

          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
     */
        END IF;


END Check_UK_Items;



PROCEDURE Check_Req_Items(
     p_prgm_pmt_mode_rec    IN  prgm_pmt_mode_rec_type
    ,p_validation_mode      IN  VARCHAR2 := JTF_PLSQL_API.g_create
    ,x_return_status      OUT NOCOPY VARCHAR2
    )

IS

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

      IF p_prgm_pmt_mode_rec.program_payment_mode_id = FND_API.g_miss_num
        OR p_prgm_pmt_mode_rec.program_payment_mode_id IS NULL THEN
         FND_MESSAGE.set_name('PV','PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','PROGRAM_PAYMENT_MODE_ID');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

/**
      IF p_prgm_pmt_mode_rec.program_id = FND_API.g_miss_num OR
         p_prgm_pmt_mode_rec.program_id IS NULL THEN
         FND_MESSAGE.set_name('PV','PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','PROGRAM_ID');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

*/
      IF p_prgm_pmt_mode_rec.geo_hierarchy_id = FND_API.g_miss_num OR
         p_prgm_pmt_mode_rec.geo_hierarchy_id IS NULL THEN
         FND_MESSAGE.set_name('PV','PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','geo_hierarchy_id');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prgm_pmt_mode_rec.mode_of_payment = FND_API.g_miss_char OR
         p_prgm_pmt_mode_rec.mode_of_payment IS NULL THEN
         FND_MESSAGE.set_name('PV','PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','MODE_OF_PAYMENT');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_prgm_pmt_mode_rec.mode_type = FND_API.g_miss_char OR
         p_prgm_pmt_mode_rec.mode_type IS NULL THEN
         FND_MESSAGE.set_name('PV','PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','mode_type');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_prgm_pmt_mode_rec.last_update_date = FND_API.g_miss_date OR
         p_prgm_pmt_mode_rec.last_update_date IS NULL THEN
         FND_MESSAGE.set_name('PV','PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','LAST_UPDATE_DATE');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prgm_pmt_mode_rec.last_updated_by = FND_API.g_miss_num OR
         p_prgm_pmt_mode_rec.last_updated_by IS NULL THEN
         FND_MESSAGE.set_name('PV','PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','LAST_UPDATED_BY');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prgm_pmt_mode_rec.creation_date = FND_API.g_miss_date OR
         p_prgm_pmt_mode_rec.creation_date IS NULL THEN
         FND_MESSAGE.set_name('PV','PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','CREATION_DATE');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      -- Debug message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('- In Check_Req_Items API Before Created_by Check' );
      END IF;

      IF p_prgm_pmt_mode_rec.created_by = FND_API.g_miss_num OR
         p_prgm_pmt_mode_rec.created_by IS NULL THEN
         FND_MESSAGE.set_name('PV','PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','CREATED_BY');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prgm_pmt_mode_rec.last_update_login = FND_API.g_miss_num OR
         p_prgm_pmt_mode_rec.last_update_login IS NULL THEN
         FND_MESSAGE.set_name('PV','PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','LAST_UPDATE_LOGIN');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prgm_pmt_mode_rec.object_version_number = FND_API.g_miss_num OR
         p_prgm_pmt_mode_rec.object_version_number IS NULL THEN
         FND_MESSAGE.set_name('PV','PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','OBJECT_VERSION_NUMBER');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   ELSE

      IF p_prgm_pmt_mode_rec.program_payment_mode_id IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','PROGRAM_PAYMENT_MODE_ID');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_prgm_pmt_mode_rec.object_version_number IS NULL THEN
          FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
          FND_MESSAGE.set_token('COLUMN','OBJECT_VERSION_NUMBER');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END Check_Req_Items;



PROCEDURE Check_FK_Items(
     p_prgm_pmt_mode_rec  IN  prgm_pmt_mode_rec_type
    ,x_return_status      OUT NOCOPY VARCHAR2
    )

IS

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

 ----------------------- PROGRAM_ID ------------------------
 IF (p_prgm_pmt_mode_rec.PROGRAM_ID <> FND_API.g_miss_num
       AND p_prgm_pmt_mode_rec.PROGRAM_ID IS NOT NULL ) THEN

 -- Debug message
 IF (PV_DEBUG_HIGH_ON) THEN

 PVX_UTILITY_PVT.debug_message('In Check_FK_Items : Before PROGRAM_ID fk check : PROGRAM_ID ' || p_prgm_pmt_mode_rec.PROGRAM_ID);
 END IF;

   IF PVX_Utility_PVT.check_fk_exists(
         'PV_PARTNER_PROGRAM_B',                     -- Parent schema object having the primary key
         'PROGRAM_ID',                               -- Column name in the parent object that maps to the fk value
         p_prgm_pmt_mode_rec.PROGRAM_ID,             -- Value of fk to be validated against the parent object's pk column
         PVX_utility_PVT.g_number,                   -- datatype of fk
         NULL
   ) = FND_API.g_false
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('PV', 'PV_NOT_A_VALID_PARTNER_PROGRAM');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;
 END IF;

 IF (PV_DEBUG_HIGH_ON) THEN



 PVX_UTILITY_PVT.debug_message('In Check_FK_Items : After program_id fk check ');

 END IF;

 ----------------------- GEO_HIERARCHY_ID ------------------------
 IF (p_prgm_pmt_mode_rec.GEO_HIERARCHY_ID <> FND_API.g_miss_num
       AND p_prgm_pmt_mode_rec.GEO_HIERARCHY_ID IS NOT NULL ) THEN

 -- Debug message
 IF (PV_DEBUG_HIGH_ON) THEN

 PVX_UTILITY_PVT.debug_message('- In Check_FK_Items : Before GEO_HIERARCHY_ID fk check : GEO_HIERARCHY_ID ' || p_prgm_pmt_mode_rec.GEO_HIERARCHY_ID);
 END IF;

   IF PVX_Utility_PVT.check_fk_exists(
         'JTF_LOC_HIERARCHIES_VL',                   -- Parent schema object having the primary key
         'LOCATION_HIERARCHY_ID',                    -- Column name in the parent object that maps to the fk value
         p_prgm_pmt_mode_rec.GEO_HIERARCHY_ID,      -- Value of fk to be validated against the parent object's pk column
         PVX_UTILITY_PVT.g_number,                   -- datatype of fk
         NULL
   ) = FND_API.g_false
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('PV', 'PV_NOT_A_GEO_HIERARCHY');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;
 END IF;

END Check_FK_Items;



PROCEDURE Check_Lookup_Items(
     p_prgm_pmt_mode_rec  IN  prgm_pmt_mode_rec_type
    ,x_return_status      OUT NOCOPY VARCHAR2
    )
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_prgm_pmt_mode_rec.mode_type <> FND_API.g_miss_char  THEN

      IF PVX_Utility_PVT.check_lookup_exists(
            'PV_LOOKUPS',      -- Look up Table Name
            'PV_MODE_TYPE',    -- Lookup Type
            p_prgm_pmt_mode_rec.mode_type       -- Lookup Code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('PV', 'PV_NOT_A_VALID_MODE_TYPE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;

      END IF;
   END IF;
   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- In Check_Lookup_Items : After lookup check. x_return_status = '||x_return_status);
   END IF;

END Check_Lookup_Items;




PROCEDURE Check_Items (
     p_prgm_pmt_mode_rec      IN    prgm_pmt_mode_rec_type
    ,p_validation_mode        IN    VARCHAR2
    ,x_return_status          OUT NOCOPY   VARCHAR2
    )

IS

  l_api_name    CONSTANT VARCHAR2(30) := 'Check_Items';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

BEGIN

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- Check_Items API prior to Check_Req_Items call');
   END IF;

   -- Check Items Required/NOT NULL API calls
   Check_Req_Items(
       p_prgm_pmt_mode_rec  => p_prgm_pmt_mode_rec
      ,p_validation_mode    => p_validation_mode
      ,x_return_status      => x_return_status
      );

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- After Check_Req_Items. return status = ' || x_return_status);
   END IF;

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- Check_Items API prior to Check_UK_Items call');
   END IF;

    -- Check Items Uniqueness API calls
   Check_UK_Items(
       p_prgm_pmt_mode_rec  => p_prgm_pmt_mode_rec
      ,p_validation_mode    => p_validation_mode
      ,x_return_status      => x_return_status
      );

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- After Check_UK_Items. return status = ' || x_return_status);
   END IF;

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- Check_Items API prior to Check_FK_Items call');
   END IF;

   -- Check Items Foreign Keys API calls
   Check_FK_Items(
       p_prgm_pmt_mode_rec  => p_prgm_pmt_mode_rec
      ,x_return_status      => x_return_status
      );

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- After Check_FK_Items. return status = ' || x_return_status);
   END IF;

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- Check_Items API prior to Check_Lookup_Items call');
   END IF;

   -- Check Items Lookups
   Check_Lookup_Items(
       p_prgm_pmt_mode_rec  => p_prgm_pmt_mode_rec
      ,x_return_status      => x_return_status
      );

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- After Check_Lookup_Items. return status = ' || x_return_status);
   END IF;

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_Items;



PROCEDURE Complete_Rec (
    p_prgm_pmt_mode_rec  IN  prgm_pmt_mode_rec_type
   ,x_complete_rec       OUT NOCOPY prgm_pmt_mode_rec_type
   )

IS

   CURSOR c_complete IS
      SELECT *
      FROM PV_PROGRAM_PAYMENT_MODE
      WHERE program_payment_mode_id = p_prgm_pmt_mode_rec.program_payment_mode_id;

   l_prgm_pmt_mode_rec c_complete%ROWTYPE;

BEGIN

   x_complete_rec := p_prgm_pmt_mode_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_prgm_pmt_mode_rec;
   CLOSE c_complete;

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- In Complete_Rec API prior to assigning program_id');
   END IF;

   -- program_payment_mode_id

   -- IF p_prgm_pmt_mode_rec.program_payment_mode_id = FND_API.g_miss_num THEN

   IF p_prgm_pmt_mode_rec.program_payment_mode_id IS NULL THEN
      x_complete_rec.program_payment_mode_id := l_prgm_pmt_mode_rec.program_payment_mode_id;
   END IF;

   -- program_id
   -- IF p_prgm_pmt_mode_rec.program_id = FND_API.g_miss_num THEN

   IF p_prgm_pmt_mode_rec.program_id IS NULL THEN
      x_complete_rec.program_id := l_prgm_pmt_mode_rec.program_id;
   END IF;

   -- geo_hierarchy_id
   -- IF p_prgm_pmt_mode_rec.geo_hierarchy_id = FND_API.g_miss_num THEN

   IF p_prgm_pmt_mode_rec.geo_hierarchy_id IS NULL THEN
      x_complete_rec.geo_hierarchy_id := l_prgm_pmt_mode_rec.geo_hierarchy_id;
   END IF;

   -- mode_of_payment
   -- IF p_prgm_pmt_mode_rec.mode_of_payment = FND_API.g_miss_char THEN

   IF p_prgm_pmt_mode_rec.mode_of_payment IS NULL THEN
      x_complete_rec.mode_of_payment := l_prgm_pmt_mode_rec.mode_of_payment;
   END IF;

   -- mode_type
   -- IF p_prgm_pmt_mode_rec.mode_type = FND_API.g_miss_char THEN

   IF p_prgm_pmt_mode_rec.mode_type IS NULL THEN
      x_complete_rec.mode_type := l_prgm_pmt_mode_rec.mode_type;
   END IF;

   -- last_update_date
   -- IF p_prgm_pmt_mode_rec.last_update_date = FND_API.g_miss_date THEN

   IF p_prgm_pmt_mode_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_prgm_pmt_mode_rec.last_update_date;
   END IF;

   -- last_updated_by
   -- IF p_prgm_pmt_mode_rec.last_updated_by = FND_API.g_miss_num THEN

   IF p_prgm_pmt_mode_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_prgm_pmt_mode_rec.last_updated_by;
   END IF;

   -- creation_date
   -- IF p_prgm_pmt_mode_rec.creation_date = FND_API.g_miss_date THEN

   IF p_prgm_pmt_mode_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_prgm_pmt_mode_rec.creation_date;
   END IF;

   -- created_by
   -- IF p_prgm_pmt_mode_rec.created_by = FND_API.g_miss_num THEN

   IF p_prgm_pmt_mode_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_prgm_pmt_mode_rec.created_by;
   END IF;

   -- last_update_login
   -- IF p_prgm_pmt_mode_rec.last_update_login = FND_API.g_miss_num THEN

   IF p_prgm_pmt_mode_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_prgm_pmt_mode_rec.last_update_login;
   END IF;

   -- object_version_number
   -- IF p_prgm_pmt_mode_rec.object_version_number = FND_API.g_miss_num THEN

   IF p_prgm_pmt_mode_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_prgm_pmt_mode_rec.object_version_number;
   END IF;

END Complete_Rec;



PROCEDURE Validate_Prgm_Pmt_Mode(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2         := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER           := FND_API.G_VALID_LEVEL_FULL
    ,p_prgm_pmt_mode_rec          IN   prgm_pmt_mode_rec_type
    ,p_validation_mode            IN   VARCHAR2       := JTF_PLSQL_API.G_UPDATE
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    )

IS

l_api_name                  CONSTANT VARCHAR2(30) := 'Validate_Prgm_Pmt_Mode';
l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_api_version_number        CONSTANT NUMBER       := 1.0;
l_object_version_number              NUMBER;
l_prgm_pmt_mode_rec                  PV_PRGM_PMT_MODE_PVT.prgm_pmt_mode_rec_type;

BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT Validate_Prgm_Pmt_Mode_;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
      END IF;

       -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('  Private API: ' || l_full_name || ' - start');
      END IF;

     IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
     -- Debug message
     IF (PV_DEBUG_HIGH_ON) THEN

     PVX_UTILITY_PVT.debug_message('  Private API: ' || l_full_name || ' - prior to Check_Items call');
     END IF;

              Check_Items(
                  p_prgm_pmt_mode_rec         => p_prgm_pmt_mode_rec
                 ,p_validation_mode           => p_validation_mode
                 ,x_return_status             => x_return_status
                 );

              -- Debug message
              IF (PV_DEBUG_HIGH_ON) THEN

              PVX_UTILITY_PVT.debug_message('  Private API: ' || l_full_name || ' - return status after Check_Items call ' || x_return_status);
              END IF;

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_Rec(
            p_api_version_number     => 1.0
           ,p_init_msg_list          => FND_API.G_FALSE
           ,x_return_status          => x_return_status
           ,x_msg_count              => x_msg_count
           ,x_msg_data               => x_msg_data
           ,p_prgm_pmt_mode_rec      => l_prgm_pmt_mode_rec
           );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_full_name || ' - end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        ( p_encoded => FND_API.G_FALSE,
         p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Validate_Prgm_Pmt_Mode_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Validate_Prgm_Pmt_Mode_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

   WHEN OTHERS THEN
     ROLLBACK TO Validate_Prgm_Pmt_Mode_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

End Validate_Prgm_Pmt_Mode;



PROCEDURE Validate_Rec(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,p_prgm_pmt_mode_rec          IN   prgm_pmt_mode_rec_type
    ,p_validation_mode            IN   VARCHAR2
    )
IS
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Hint: Validate data
      -- If data not valid
      -- THEN
      -- x_return_status := FND_API.G_RET_STS_ERROR;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: Validate_dm_model_rec');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get (
          p_count          =>   x_msg_count
         ,p_data           =>   x_msg_data
         );

END Validate_Rec;

END PV_PRGM_PMT_MODE_PVT;

/
