--------------------------------------------------------
--  DDL for Package Body BIM_RESPONSE_IMPORT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_RESPONSE_IMPORT_PUB" AS
/* $Header: bimpmrib.pls 120.1 2005/06/14 15:28:06 appldev  $ */

  g_pkg_name	CONSTANT VARCHAR2(30):='BIM_Response_IMPORT_PUB';
  G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
  G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

  TYPE local_resp_grade_table IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
  TYPE local_resp_invalid_table IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

-- ===============================================================
-- Start of Comments
-- Package name
--          BIM_Response_IMPORT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


PROCEDURE VALIDATE_RESPONSES(
     p_source_code                                  IN      VARCHAR2 ,
     p_response_country                             IN      VARCHAR2,
     p_response_source                              IN      VARCHAR2,
     p_response_grade_table                         IN      response_grade_table_type,
     p_response_invalid_table                       IN      response_invalid_table_type,
     p_response_creation_date                       IN      DATE,
     x_return_status                                OUT    NOCOPY VARCHAR2,
     x_msg_count                                    OUT    NOCOPY NUMBER,
     x_msg_data                                     OUT    NOCOPY VARCHAR2
                          )

  IS

    l_api_version CONSTANT NUMBER       := 1.0;
    l_api_name    CONSTANT VARCHAR2(30) := 'VALIDATE_RESPONSES';
    l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
    l_source_code                     Varchar2(30);
    l_response_country                Varchar2(30);
    l_response_source                 Varchar2(30);
    l_response_grade_table            response_grade_table_type;
    l_response_invalid_table          response_invalid_table_type;
    l_response_creation_date          Date;
    l_local_resp_grade_table          local_resp_grade_table;
    l_local_resp_invalid_table        local_resp_invalid_table;
    l_grade_lookup                    Varchar2(60) :='AMS_RESP_GRADE';
    l_reason_lookup                   Varchar2(60) :='AMS_RESP_REJECT_REASON';
    l_source_code_count               Number := 0;
    l_country_code_count              Number;
    l_resp_grade_count                Number;
    l_resp_reason_count               Number;
    k                                 Varchar2(30);
    l                                 Varchar2(30);
    l_dummy                           Varchar2(30);
    l_resp_reason_count               Number;
    i                                 Number := 1;
    l_grade_flag                      Varchar2(30) := 'F';
    l_reason_flag                     Varchar2(30) := 'F';
    j                                 Number := 1;
    n                                 Number := 1;


   CURSOR c_grade_lookup  IS
       SELECT lookup_code
       FROM   AMS_LOOKUPS
       WHERE  lookup_type = l_grade_lookup;

   CURSOR c_reason_lookup  IS
       SELECT lookup_code
       FROM   AMS_LOOKUPS
       WHERE  lookup_type = l_reason_lookup;

   CURSOR c_grade(l_cur_lookup_code Varchar2)  IS
       SELECT lookup_code
       FROM   AMS_LOOKUPS
       WHERE  lookup_type = l_grade_lookup
       AND    lookup_code = l_cur_lookup_code;

   CURSOR c_reason(l_cur_res_code Varchar2)  IS
       SELECT lookup_code
       FROM   AMS_LOOKUPS
       WHERE  lookup_type = l_reason_lookup
       AND    lookup_code = l_cur_res_code;

   CURSOR c_source_code(l_cur_source_code Varchar2)  IS
       SELECT source_code
       FROM   AMS_SOURCE_CODES
       WHERE  source_code = l_cur_source_code ;

   CURSOR c_country_code(l_cur_country_code Varchar2)  IS
       SELECT country_code
       FROM   JTF_LOC_HIERARCHIES_B
      WHERE  country_code = l_cur_country_code ;

   CURSOR c_duplicate(l_source_code Varchar2 ,l_response_country Varchar2,l_response_creation_date Date,l_response_source Varchar2)  IS
        SELECT interface_header_id
        FROM   BIM_R_RESP_INT_HEADER
        WHERE  source_code = l_source_code
        AND    country = l_response_country
        AND    response_create_date = l_response_creation_date
        AND    response_source = l_response_source;

  BEGIN

  SAVEPOINT VALIDATE_RESPONSES;

     --dbms_output.put_line('inside VALIDATE_RESPONSES');
     l_source_code            := p_source_code;
     l_response_country       := p_response_country;
     l_response_source        := p_response_source;
     l_response_creation_date := p_response_creation_date;
     l_response_grade_table   := p_response_grade_table ;
     l_response_invalid_table := p_response_invalid_table;

     --dbms_output.put_line(' before source code validation'||l_source_code);

     --Validation of source code passed

 OPEN c_source_code(l_source_code);
      FETCH c_source_code INTO l_dummy;
          IF c_source_code%NOTFOUND THEN
	   CLOSE c_source_code;
	   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
              -- FND_MESSAGE.set_name('AMS', 'AMS_INVALID_SOURCE_CODE');
	      FND_MESSAGE.set_name('BIM', 'BIM_INVALID_SOURCE_CODE');
              FND_MSG_PUB.add;
          END IF;
          RAISE FND_API.g_exc_error;
        END IF;
 CLOSE c_source_code;

 -- dbms_output.put_line('source code validated');

  --Validation of response_country


 OPEN c_country_code(l_response_country);
     FETCH c_country_code INTO l_dummy;
         IF c_country_code%NOTFOUND THEN
	   CLOSE c_country_code;
	   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('BIM', 'BIM_INVALID_COUNTRY_CODE');
              FND_MSG_PUB.add;
          END IF;
           RAISE FND_API.g_exc_error;
        END IF;
 CLOSE c_country_code;

   --dbms_output.put_line('country code validated');

    --Validating duplicate entries

 OPEN c_duplicate(l_source_code,l_response_country,l_response_creation_date,l_response_source);
         FETCH c_duplicate INTO l_dummy;
          IF c_duplicate%FOUND THEN
	   CLOSE c_duplicate;
	   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('BIM', 'BIM_RESP_DUPLICATE_RECORD');
              FND_MSG_PUB.add;
          END IF;
           RAISE FND_API.g_exc_error;
        END IF;
 CLOSE c_duplicate;

  --Cursor to fetch the lookup codes defined in Grade look up into local table

 OPEN c_grade_lookup;
    LOOP
     FETCH c_grade_lookup INTO l_local_resp_grade_table(i);
     EXIT WHEN c_grade_lookup%NOTFOUND;
     --dbms_output.put_line('local grades'||l_local_resp_grade_table(i));
     i := i + 1;
    END LOOP;
 CLOSE c_grade_lookup;

 IF (l_response_grade_table.COUNT >0) THEN
 FOR i IN 1.. l_response_grade_table.COUNT
 LOOP

    IF l_response_grade_table(i).response_grade IS NULL
        THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('BIM', 'BIM_RESP_NO_GRADE');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --dbms_output.put_line('l_local_resp_grade_table.COUNT'|| l_local_resp_grade_table.COUNT);

           FOR j IN 1.. l_local_resp_grade_table.COUNT
	   loop
        --dbms_output.put_line('loop 1'|| l_response_grade_table(i).response_grade );
	--dbms_output.put_line('loop2'|| l_local_resp_grade_table(j));
          if  ( l_response_grade_table(i).response_grade =  l_local_resp_grade_table(j)) then
	        l_grade_flag := 'T';
	--dbms_output.put_line('grade passed1'|| l_grade_flag);
          end if;
	  end loop;
        --dbms_output.put_line('grade passed'|| l_grade_flag);
	  IF (l_grade_flag<>'T') THEN
	  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('BIM', 'BIM_INVALID_GRADE');
              FND_MSG_PUB.add;
          END IF;
          RAISE FND_API.g_exc_error;
      END IF;

     --dbms_output.put_line('response Grade is '||l_response_grade_table(i).response_grade);

 END LOOP;

 --dbms_output.put_line('grade validated'|| l_resp_grade_count);
END IF;
--dbms_output.put_line('l_response_invalid_table.COUNT'|| l_response_invalid_table.COUNT);

--Cursor to fetch the lookup codes defined in Reason look up into local table

 OPEN c_reason_lookup;
    LOOP
     FETCH c_reason_lookup INTO l_local_resp_invalid_table(n);
     EXIT WHEN c_reason_lookup%NOTFOUND;
     --dbms_output.put_line('local grades'||l_local_resp_invalid_table(n));
     n := n + 1;
    END LOOP;
  CLOSE c_reason_lookup;

 IF(l_response_invalid_table.COUNT>0) THEN
 j := 1;
 FOR  j IN 1..l_response_invalid_table.COUNT
 LOOP
   --dbms_output.put_line('response reason is '||l_response_invalid_table(j).invalid_reason);

    IF l_response_invalid_table(j).invalid_reason IS NULL
        THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('BIM', 'BIM_RESP_NO_REASON');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- dbms_output.put_line('l_local_resp_invalid_table.COUNT'|| l_local_resp_invalid_table.COUNT);

        FOR b IN 1.. l_local_resp_invalid_table.COUNT
	   loop
        --dbms_output.put_line('loop 1'|| l_response_invalid_table(j).invalid_reason );
	--dbms_output.put_line('loop2'|| l_local_resp_invalid_table(b));
        if  ( l_response_invalid_table(j).invalid_reason =  l_local_resp_invalid_table(b)) then
        l_reason_flag := 'T';
	--dbms_output.put_line('reason passed1'|| l_reason_flag);
          end if;
	  end loop;
        --dbms_output.put_line('reason passed'|| l_reason_flag);
	  IF (l_reason_flag<>'T') THEN
	  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('BIM', 'BIM_INVALID_REJECT_REASON');
              FND_MSG_PUB.add;
          END IF;
          RAISE FND_API.g_exc_error;
      END IF;

   END LOOP;

 -- dbms_output.put_line('reason validated');
  END IF;
EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_RESPONSES;
     --dbms_output.put_line('in un excepted exception block');
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

     WHEN FND_API.g_exc_error THEN
     --dbms_output.put_line('in exception block');
      --dbms_output.put_line('in exception block');
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_RESPONSES;
     -- dbms_output.put_line('in others exception block');
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

 END VALIDATE_RESPONSES;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Import_Responses
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number        IN   NUMBER     Optional Default  = 1.0
--       p_init_msg_list             IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                    IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level          IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_interface_header_id       IN   NUMBER
--       p_commit                    IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level          IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_interface_header_id       IN   NUMBER
--       p_response_hdr_rec          IN   response_hdr_rec_type,
--       p_response_grade_table      IN   response_grade_table_type,
--       p_response_invalid_table    IN   response_invalid_table_type,



--   OUT
--       x_return_status           OUT  NOCOPYVARCHAR2
--       x_msg_count               OUT  NOCOPYNUMBER
--       x_msg_data                OUT  NOCOPYVARCHAR2

--   End of Comments
--   ==============================================================================
--

PROCEDURE IMPORT_RESPONSES(
    p_api_version_number                 IN    NUMBER       :=    1.0,
    p_init_msg_list                      IN    VARCHAR2     :=    FND_API.G_FALSE,
    p_commit                             IN    VARCHAR2     :=  FND_API.G_FALSE,
    p_validation_level                   IN    NUMBER       :=  FND_API.G_VALID_LEVEL_FULL,
    p_response_hdr_rec                   IN    response_hdr_rec_type,
    p_response_grade_table               IN    response_grade_table_type,
    p_response_invalid_table             IN    response_invalid_table_type,
    x_return_status                      OUT  NOCOPY VARCHAR2,
    x_msg_count                          OUT  NOCOPY NUMBER,
    x_msg_data                           OUT NOCOPY  VARCHAR2)

    IS

  l_api_version                     CONSTANT NUMBER       := 1.0;
  l_api_name                        CONSTANT VARCHAR2(30) := 'IMPORT_RESPONSES';
  l_full_name                       CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_source_code                     Varchar2(30);
  l_response_country                Varchar2(30);
  l_region_code                     Varchar2(30);
  l_response_source                 Varchar2(30);
  l_response_grade_table            response_grade_table_type;
  l_response_invalid_table          response_invalid_table_type;
  l_response_creation_date          Date;
  l_local_resp_hdr_rec              response_hdr_rec_type;
  l_local_resp_grade_table          local_resp_grade_table;
  l_local_resp_invalid_table        local_resp_invalid_table;
  l_total_grades                    Number;
  l_total_reasons                   Number;
  l_landing_pad_hits                Number;
  l_survey_completed                Number;
  l_interface_header_id             Number;
  l_interface_grade_id              Number;
  l_interface_reason_id             Number;
  l_grade_id                        Number;
  l_reason_id                       Number;
  l_source_code_id                  Number;
  l_object_id                       Number;
  i                                 Number;
  j                                 Number;
  l_return_status         VARCHAR2(1);
  l_process_flag          VARCHAR2(1) := 'N';
  l_msg_data              VARCHAR2(200);
  l_obj_type              VARCHAR2(30);

    CURSOR c_header_id IS
      SELECT bim_r_resp_int_header_s.NEXTVAL
      FROM dual;

    CURSOR c_grade_id IS
      SELECT bim_r_resp_int_grades_s.NEXTVAL
      FROM dual;

    CURSOR c_reason_id IS
      SELECT bim_r_resp_int_reason_s.NEXTVAL
      FROM dual;

   CURSOR c_source_code_ids (c_source_code IN Varchar2) IS
      SELECT source_code_id ,source_code_for_id ,arc_source_code_for
      FROM   AMS_SOURCE_CODES
      WHERE  source_code = c_source_code;

   CURSOR c_region_code (c_country_code IN Varchar2) IS
      SELECT area2_code
      FROM   JTF_LOC_HIERARCHIES_B
      WHERE  country_code = c_country_code;

    BEGIN

      SAVEPOINT IMPORT_RESPONSES;

      --dbms_output.put_line('Inside Import responses');
      l_local_resp_hdr_rec          := p_response_hdr_rec;
      l_response_grade_table        := p_response_grade_table ;
      l_response_invalid_table      := p_response_invalid_table;
      l_source_code                 := l_local_resp_hdr_rec.source_code;
      l_response_country            := l_local_resp_hdr_rec.response_country;
      l_response_source             := l_local_resp_hdr_rec.response_source;
      l_response_creation_date      := l_local_resp_hdr_rec.response_create_date;

     IF l_source_code IS NULL
        THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('BIM', 'BIM_RESP_NO_SOURCE_CODE');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF l_response_country IS NULL
        THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('BIM', 'BIM_RESP_NO_COUNTRY_CODE');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF l_response_creation_date IS NULL
        THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('BIM', 'BIM_RESP_NO_CREATE_DATE');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF l_response_source IS NULL
        THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('BIM', 'BIM_RESP_NO_RESPONSE_SOURCE');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  -- dbms_output.put_line('Before validate');
   VALIDATE_RESPONSES(
                         p_source_code                => l_source_code,
                         p_response_country           => l_response_country,
                         p_response_source            => l_response_source,
                         p_response_creation_date     => l_response_creation_date,
                         p_response_grade_table       => l_response_grade_table,
                         p_response_invalid_table     => l_response_invalid_table,
                         x_return_status              => l_return_status,
		         x_msg_count                  => x_msg_count,
                         x_msg_data                   => x_msg_data
                      );

  -- dbms_output.put_line('after validate');
     IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;
  -- dbms_output.put_line('validation ends..back to import');

   -- Validation Ends

  l_landing_pad_hits          := l_local_resp_hdr_rec.landing_pad_hits;
  l_survey_completed          := l_local_resp_hdr_rec.survey_completed;

  OPEN c_header_id;
      FETCH c_header_id INTO l_interface_header_id;
  CLOSE c_header_id;

  OPEN c_source_code_ids(l_source_code);
      FETCH c_source_code_ids INTO l_source_code_id , l_object_id ,l_obj_type;
  CLOSE c_source_code_ids;

  OPEN c_region_code(l_response_country);
      FETCH c_region_code INTO l_region_code;
  CLOSE c_region_code;


 -- dbms_output.put_line('before inserting into BIM_R_RESP_INT_HEADER '||l_interface_header_id );
 -- dbms_output.put_line('before inserting into BIM_R_RESP_INT_HEADER object_id '||l_object_id );
 -- dbms_output.put_line('before inserting into BIM_R_RESP_INT_HEADER source_code'||l_source_code );
 -- dbms_output.put_line('before inserting into BIM_R_RESP_INT_HEADER source_code_id '||l_source_code_id );
 -- dbms_output.put_line('before inserting into BIM_R_RESP_INT_HEADER response_creation_date'||l_response_creation_date );
 -- dbms_output.put_line('before inserting into BIM_R_RESP_INT_HEADER region '||l_region_code );
 -- dbms_output.put_line('before inserting into BIM_R_RESP_INT_HEADER landing pad hits'||l_landing_pad_hits );
 -- dbms_output.put_line('before inserting into BIM_R_RESP_INT_HEADER survey completed '||l_survey_completed );
 -- dbms_output.put_line('before inserting into BIM_R_RESP_INT_HEADER response source '||l_response_source );
 -- dbms_output.put_line('before inserting into BIM_R_RESP_INT_HEADER creation_date'||SYSDATE );
 -- dbms_output.put_line('before inserting into BIM_R_RESP_INT_HEADER created_by '||G_USER_ID );
 -- dbms_output.put_line('before inserting into BIM_R_RESP_INT_HEADER last_update_login '||G_LOGIN_ID );
 --dbms_output.put_line('before inserting into BIM_R_RESP_INT_HEADER object_type '||l_obj_type );

   IF l_object_id IS NULL
        THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('BIM', 'BIM_RESP_NO_OBJECT_ID');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF l_obj_type IS NULL
        THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('BIM', 'BIM_RESP_NO_OBJECT_TYPE');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF l_region_code IS NULL
        THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('BIM', 'BIM_RESP_NO_REGION_CODE');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF l_source_code_id IS NULL
        THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('BIM', 'BIM_RESP_NO_SOURCE_CODE_ID');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF l_process_flag IS NULL
        THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('BIM', 'BIM_RESP_NO_PROCESS_FLAG');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF l_interface_header_id IS NULL
        THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('BIM', 'BIM_RESP_NO_HEADER_ID');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  INSERT INTO BIM_R_RESP_INT_HEADER
  (
     creation_date,
     last_update_date,
     created_by,
     last_updated_by,
     last_update_login,
     interface_header_id,
     object_id,
     object_type,
     country,
     region,
     source_code,
     source_code_id,
     response_create_date,
     landing_pad_hits,
     survey_completed,
     process_flag,
     response_source

) VALUES

(
    SYSDATE,
    SYSDATE,
    G_USER_ID,
    G_USER_ID,
    G_LOGIN_ID,
    l_interface_header_id,
    l_object_id,
    l_obj_type,
    l_response_country,
    l_region_code,
    l_source_code,
    l_source_code_id,
    l_response_creation_date,
    l_landing_pad_hits,
    l_survey_completed,
    l_process_flag,
    l_response_source

);

--dbms_output.put_line('after inserting into BIM_R_RESP_INT_HEADER '||l_interface_header_id );
--dbms_output.put_line('l_response_grade_table.COUNT '||l_response_grade_table.COUNT);
 IF(l_response_grade_table.COUNT > 0) THEN
   FOR i IN 1..l_response_grade_table.COUNT LOOP

  OPEN c_grade_id;
      FETCH c_grade_id INTO l_interface_grade_id;
  CLOSE c_grade_id;
  IF l_response_grade_table (i).response_grade_count IS NULL
     THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('BIM', 'BIM_RESP_NO_GRADE_COUNT');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF l_interface_grade_id IS NULL
        THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('BIM', 'BIM_RESP_NO_GRADE_ID');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

 --dbms_output.put_line('before inserting into bim_r_resp_int_grades '||l_local_resp_grade_count_table(i) );
 -- dbms_output.put_line('before inserting into bim_r_resp_int_grades interface header id '||l_interface_header_id );
 -- dbms_output.put_line('before inserting into bim_r_resp_int_grades interface greade id '||l_interface_grade_id );
 -- dbms_output.put_line('before inserting into bim_r_resp_int_grades response_grade'||l_local_resp_grade_table(i) );

INSERT INTO bim_r_resp_int_grades
  (
     creation_date,
     last_update_date,
     created_by,
     last_updated_by,
     last_update_login,
     interface_grade_id,
     interface_header_id,
     response_grade,
     response_grade_count


) VALUES

(
    SYSDATE,
    SYSDATE,
    G_USER_ID,
    G_USER_ID,
    G_LOGIN_ID,
    l_interface_grade_id,
    l_interface_header_id,
    l_response_grade_table (i).response_grade,
    l_response_grade_table (i).response_grade_count

);

 END LOOP;
 --dbms_output.put_line('after inserting into bim_r_resp_int_grades');
 END IF;

IF (l_response_invalid_table.COUNT > 0) THEN
 FOR  j IN 1..l_response_invalid_table.COUNT LOOP

  IF l_response_invalid_table (j).invalid_responses IS NULL
     THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('BIM', 'BIM_RESP_NO_REASON_COUNT');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

 OPEN c_reason_id;
      FETCH c_reason_id INTO l_interface_reason_id;
 CLOSE c_reason_id;

   IF l_interface_reason_id IS NULL
        THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('BIM', 'BIM_RESP_NO_REASON_ID');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- dbms_output.put_line('before inserting into bim_r_resp_int_reason '||l_interface_reason_id);
 --dbms_output.put_line('before inserting into bim_r_resp_int_reason invalid reason'||l_local_resp_invalid_table(j) );
-- dbms_output.put_line('before inserting into bim_r_resp_int_reason invalid responses'||l_local_resp_inv_count_table(j) );

 INSERT INTO bim_r_resp_int_reason
  (
     creation_date,
     last_update_date,
     created_by,
     last_updated_by,
     last_update_login,
     interface_reason_id,
     interface_header_id,
     invalid_reason,
     invalid_responses

) VALUES

(
    SYSDATE,
    SYSDATE,
    G_USER_ID,
    G_USER_ID,
    G_LOGIN_ID,
    l_interface_reason_id,
    l_interface_header_id,
    l_response_invalid_table(j).invalid_reason ,
    l_response_invalid_table(j).invalid_responses

);

 END LOOP;

--dbms_output.put_line('end inserting into bim_r_resp_int_reason');
END IF;

  -- Check for commit
    IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
    END IF;

 EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO IMPORT_RESPONSES;
     x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO IMPORT_RESPONSES;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
   WHEN OTHERS THEN
     ROLLBACK TO IMPORT_RESPONSES;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

END IMPORT_RESPONSES;

END BIM_Response_IMPORT_PUB;

/
