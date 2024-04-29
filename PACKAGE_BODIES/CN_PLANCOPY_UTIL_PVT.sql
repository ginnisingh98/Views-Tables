--------------------------------------------------------
--  DDL for Package Body CN_PLANCOPY_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PLANCOPY_UTIL_PVT" AS
 /*$Header: cnpcutlb.pls 120.8 2007/10/05 17:40:07 sbadami noship $*/
 G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_PLANCOPY_UTIL_PVT';
 G_FILE_NAME                 CONSTANT VARCHAR2(12) := 'cnpcutlb.pls';



 PROCEDURE get_unique_name_for_component (
     p_id    IN  NUMBER,
     p_org_id IN NUMBER,
     p_type   IN VARCHAR2,
     p_suffix IN VARCHAR2,
     p_prefix IN VARCHAR2,
     x_name   OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count  OUT NOCOPY NUMBER,
     x_msg_data   OUT NOCOPY VARCHAR2
) IS

l_api_name  CONSTANT VARCHAR2(30) := 'get_unique_name_for_component';
l_unique_identifier VARCHAR2(5);
l_temp_name VARCHAR2(200);
l_obj_name VARCHAR2 (80);
l_obj_length NUMBER;
l_msg_copy varchar2(10);
l_length number;
RAND_NUM_LENGTH number := 3;
l_length_expscn number;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT   get_unique_name_for_component;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- ******* All the code needs to be written here *****
    -- PLAN ELEMENT Name : 80 characters
    -- PLAN         Name : 30 characters
    -- RATE TABLE   NAME : 80 characters
    -- RATE DIM     NAME : 30 characters
    -- EXPRESSION   Name : 30 Chararcters
    -- Formula      Name : 30 characters
    -- Scenario Name : 80 characters

    select substr(to_char(abs(dbms_random.random)),1,RAND_NUM_LENGTH) into l_unique_identifier from dual;
    select fnd_message.get_string('CN','CN_COPY_MSG') into l_msg_copy from dual;

    -- Magic number 2 is for an underscore and 1 extra character

    l_length := RAND_NUM_LENGTH + 2 + LENGTHB(l_msg_copy);

    l_length_expscn := RAND_NUM_LENGTH + 2 + LENGTHB(fnd_message.get_string('CN','CN_PLANS'));

    -- Whereever the length of column is 30 is present substr of 23 is used to accomadate to add an hyphen and 5 characters of unique string.

    if (p_type = 'PLAN') THEN
       SELECT SUBSTRB(NAME,1,(30-l_length)),LENGTHB(NAME) into l_obj_name,l_obj_length from cn_comp_plans_all where org_id = p_org_id and comp_plan_id = p_id;
    ELSIF (p_type = 'PLANELEMENT')  THEN
       SELECT SUBSTRB(NAME,1,(80-l_length)),LENGTHB(NAME) into l_obj_name,l_obj_length from cn_quotas_all where org_id = p_org_id and quota_id = p_id;
    ELSIF (p_type = 'EXPRESSION')  THEN
       SELECT SUBSTRB(NAME,1,(30-l_length)),LENGTHB(NAME) into l_obj_name,l_obj_length from cn_calc_sql_exps_all where org_id = p_org_id and CALC_SQL_EXP_ID = p_id;
    ELSIF (p_type = 'RATETABLE')  THEN
      SELECT SUBSTRB(NAME,1,(80-l_length)),LENGTHB(NAME) into l_obj_name,l_obj_length from cn_rate_schedules_all where org_id = p_org_id and RATE_SCHEDULE_ID = p_id;
    ELSIF (p_type = 'RATEDIMENSION')  THEN
      SELECT SUBSTRB(NAME,1,(30-l_length)),LENGTHB(NAME) into l_obj_name,l_obj_length from cn_rate_dimensions_all where org_id = p_org_id and RATE_DIMENSION_ID = p_id;
    ELSIF (p_type = 'FORMULA')  THEN
      SELECT SUBSTRB(NAME,1,(30-l_length)),LENGTHB(NAME) into l_obj_name,l_obj_length from cn_calc_formulas_all where org_id = p_org_id and CALC_FORMULA_ID = p_id;
    ELSIF (p_type = 'SCENARIO')  THEN
       SELECT SUBSTRB(NAME,1,(80-l_length)),LENGTHB(NAME) into l_obj_name,l_obj_length from cn_scenarios_all where org_id = p_org_id and scenario_id = p_id;
    ELSIF (p_type = 'EXPSCENARIO')  THEN
       SELECT SUBSTRB(NAME,1,(80-l_length_expscn)),LENGTHB(NAME) into l_obj_name,l_obj_length from cn_scenarios_all where org_id = p_org_id and scenario_id = p_id;
    END IF;

    if (p_type = 'EXPSCENARIO') THEN
     x_name := l_obj_name || fnd_message.get_string('CN','CN_PLANS') || l_unique_identifier;
    else
     x_name := l_obj_name || '_'|| l_msg_copy || l_unique_identifier;
    end if;
    -- ******* End of API body. ********

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
      (p_count                 =>      x_msg_count             ,
       p_data                  =>      x_msg_data              ,
       p_encoded               =>      FND_API.G_FALSE         );
 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO get_unique_name_for_component;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.count_and_get
 	(p_count                 =>      x_msg_count             ,
 	 p_data                  =>      x_msg_data              ,
 	 p_encoded               =>      FND_API.G_FALSE         );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO get_unique_name_for_component;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.count_and_get
 	(p_count                 =>      x_msg_count             ,
 	 p_data                  =>      x_msg_data              ,
 	 p_encoded               =>      FND_API.G_FALSE         );
    WHEN OTHERS THEN
       ROLLBACK TO get_unique_name_for_component;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       IF      FND_MSG_PUB.check_msg_level
 	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
 	THEN
 	 FND_MSG_PUB.add_exc_msg
 	   (G_PKG_NAME          ,
 	    l_api_name           );
       END IF;
       FND_MSG_PUB.count_and_get
 	(p_count                 =>      x_msg_count             ,
 	 p_data                  =>      x_msg_data              ,
 	 p_encoded               =>      FND_API.G_FALSE         );
 END get_unique_name_for_component;


 FUNCTION blob_to_clob (blob_in IN BLOB)
 RETURN CLOB
 AS
	 v_clob    CLOB;
	 v_varchar VARCHAR2(32767);
	 v_start PLS_INTEGER := 1;
	 v_buffer  PLS_INTEGER := 32767;
 BEGIN
	 DBMS_LOB.CREATETEMPORARY(v_clob, TRUE);

	 FOR i IN 1..CEIL(DBMS_LOB.GETLENGTH(blob_in) / v_buffer)
	 LOOP
	    v_varchar := UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(blob_in, v_buffer, v_start));
	    DBMS_LOB.WRITEAPPEND(v_clob, LENGTH(v_varchar), v_varchar);
  	    v_start := v_start + v_buffer;
	 END LOOP;

	 RETURN v_clob;
 END blob_to_clob;


 FUNCTION clob_to_xmltype (clob_in IN CLOB)
 RETURN XMLTYPE
  AS
  v_xmltype    XMLTYPE;
 BEGIN
    v_xmltype := XMLTYPE(clob_in);
    RETURN v_xmltype;
 END clob_to_xmltype;

 PROCEDURE convert_blob_to_clob
 (  p_api_version                IN      NUMBER                          ,
    p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
    p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
    p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_exp_imp_id			IN	CN_COPY_REQUESTS_ALL.EXP_IMP_REQUEST_ID%TYPE,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count  OUT NOCOPY NUMBER,
    x_msg_data   OUT NOCOPY VARCHAR2
 ) IS
 l_api_name  CONSTANT VARCHAR2(30) := 'convert_blob_to_clob';
 l_blob blob;
 l_clob clob;
 l_api_version             CONSTANT NUMBER       := 1.0;


 BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT   convert_blob_to_clob;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call
     (l_api_version           ,
      p_api_version           ,
      l_api_name              ,
      G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- ******* API Begins ************
     -- TODO : Error handling

     select file_content_blob into l_blob from cn_copy_requests_all
     where EXP_IMP_REQUEST_ID = p_exp_imp_id;


     l_clob := blob_to_clob(l_blob);

     update cn_copy_requests_all set file_content_clob = l_clob where EXP_IMP_REQUEST_ID = p_exp_imp_id;

     -- ******* End of API body. ********
     -- Standard check of p_commit.
     IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
     END IF;

     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
        p_data                  =>      x_msg_data              ,
       p_encoded               =>      FND_API.G_FALSE         );

 EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO convert_blob_to_clob;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.count_and_get
  	(p_count                 =>      x_msg_count             ,
  	 p_data                  =>      x_msg_data              ,
  	 p_encoded               =>      FND_API.G_FALSE         );
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO convert_blob_to_clob;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.count_and_get
  	(p_count                 =>      x_msg_count             ,
  	 p_data                  =>      x_msg_data              ,
  	 p_encoded               =>      FND_API.G_FALSE         );
     WHEN OTHERS THEN
        ROLLBACK TO convert_blob_to_clob;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF      FND_MSG_PUB.check_msg_level
  	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  	THEN
  	 FND_MSG_PUB.add_exc_msg
  	   (G_PKG_NAME          ,
  	    l_api_name           );
        END IF;
        FND_MSG_PUB.count_and_get
  	(p_count                 =>      x_msg_count             ,
  	 p_data                  =>      x_msg_data              ,
 	 p_encoded               =>      FND_API.G_FALSE         );
 END convert_blob_to_clob;



 PROCEDURE convert_clob_to_xmltype
 (  p_api_version                IN      NUMBER                          ,
    p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
    p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
    p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_exp_imp_id		 IN	 CN_COPY_REQUESTS_ALL.EXP_IMP_REQUEST_ID%TYPE,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count  OUT NOCOPY NUMBER,
    x_msg_data   OUT NOCOPY VARCHAR2
 )
 IS
 l_api_name  CONSTANT VARCHAR2(30) := 'convert_clob_to_xmltype';
 l_api_version             CONSTANT NUMBER       := 1.0;

 l_xmltype xmltype;
 l_clob clob;
 BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT   convert_clob_to_xmltype;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call
     (l_api_version           ,
      p_api_version           ,
      l_api_name              ,
      G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- ******* API Begins ************
     -- TODO : Error handling, waiting for xmltype to be added

     select file_content_clob into l_clob from cn_copy_requests_all
     where EXP_IMP_REQUEST_ID = p_exp_imp_id;

     l_xmltype := XMLTYPE(l_clob);

     update cn_copy_requests_all set file_content_xmltype = l_xmltype where EXP_IMP_REQUEST_ID = p_exp_imp_id;

     -- ******* End of API body. ********
     -- Standard check of p_commit.
     IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
     END IF;

     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
        p_data                  =>      x_msg_data              ,
       p_encoded               =>      FND_API.G_FALSE         );

 EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO convert_clob_to_xmltype;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.count_and_get
  	(p_count                 =>      x_msg_count             ,
  	 p_data                  =>      x_msg_data              ,
  	 p_encoded               =>      FND_API.G_FALSE         );
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO convert_clob_to_xmltype;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.count_and_get
  	(p_count                 =>      x_msg_count             ,
  	 p_data                  =>      x_msg_data              ,
  	 p_encoded               =>      FND_API.G_FALSE         );
     WHEN OTHERS THEN
        ROLLBACK TO convert_clob_to_xmltype;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF      FND_MSG_PUB.check_msg_level
  	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  	THEN
  	 FND_MSG_PUB.add_exc_msg
  	   (G_PKG_NAME          ,
  	    l_api_name           );
        END IF;
        FND_MSG_PUB.count_and_get
  	(p_count                 =>      x_msg_count             ,
  	 p_data                  =>      x_msg_data              ,
 	 p_encoded               =>      FND_API.G_FALSE         );
 END convert_clob_to_xmltype;


 PROCEDURE convert_blob_to_xmltype
 (  p_api_version                IN      NUMBER                          ,
    p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
    p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
    p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_exp_imp_id			IN	CN_COPY_REQUESTS_ALL.EXP_IMP_REQUEST_ID%TYPE,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count  OUT NOCOPY NUMBER,
    x_msg_data   OUT NOCOPY VARCHAR2
)
IS
 l_api_name  CONSTANT VARCHAR2(30) := 'convert_blob_to_xmltype';
 l_api_version    CONSTANT NUMBER       := 1.0;
 l_return_status VARCHAR2(2000);
 l_msg_count  NUMBER;
 l_msg_data   VARCHAR2(2000);

 BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT   convert_blob_to_xmltype;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call
     (l_api_version           ,
      p_api_version           ,
      l_api_name              ,
      G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;


    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- ******* API Begins ************
     -- TODO : Error handling, calling the other two procedures
     convert_blob_to_clob(p_api_version,
                          p_init_msg_list,
     			  p_commit,
     			  p_validation_level,
     			  p_exp_imp_id,
                          l_return_status,
                          l_msg_count,
                          l_msg_data);

     IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
       RAISE fnd_api.g_exc_error;
     END IF;

     IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
     END IF;


     convert_clob_to_xmltype(p_api_version,
                          p_init_msg_list,
     			  p_commit,
     			  p_validation_level,
     			  p_exp_imp_id,
                          l_return_status,
                          l_msg_count,
                          l_msg_data);

     IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
       RAISE fnd_api.g_exc_error;
     END IF;

     IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- ******* End of API body. ********
     -- Standard check of p_commit.
     IF FND_API.To_Boolean(p_commit) THEN
       COMMIT WORK;
     END IF;

     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
        p_data                  =>      x_msg_data              ,
       p_encoded               =>      FND_API.G_FALSE         );

 EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO convert_blob_to_xmltype;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.count_and_get
  	(p_count                 =>      x_msg_count             ,
  	 p_data                  =>      x_msg_data              ,
  	 p_encoded               =>      FND_API.G_FALSE         );
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO convert_blob_to_xmltype;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.count_and_get
  	(p_count                 =>      x_msg_count             ,
  	 p_data                  =>      x_msg_data              ,
  	 p_encoded               =>      FND_API.G_FALSE         );
     WHEN OTHERS THEN
        ROLLBACK TO convert_blob_to_xmltype;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF      FND_MSG_PUB.check_msg_level
  	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  	THEN
  	 FND_MSG_PUB.add_exc_msg
  	   (G_PKG_NAME          ,
  	    l_api_name           );
        END IF;
        FND_MSG_PUB.count_and_get
  	(p_count                 =>      x_msg_count             ,
  	 p_data                  =>      x_msg_data              ,
 	 p_encoded               =>      FND_API.G_FALSE         );
 END convert_blob_to_xmltype;


 FUNCTION  check_name_length (p_name VARCHAR2, p_org_id NUMBER,p_type varchar2,p_prefix varchar2)
  RETURN VARCHAR2 IS
  l_return_str varchar2(80) := null;
  l_temp_str varchar2(100);
  l_prefix_str varchar2(10);

 BEGIN
   l_prefix_str := p_prefix;
   IF (p_name is null or p_name = '') THEN
     l_return_str := NULL;
     return l_return_str;
   END IF;

   IF (p_org_id is null) THEN
        l_return_str := NULL;
        return l_return_str;
   END IF;

   IF (p_type <> 'PLAN' and
       p_type <> 'PLANELEMENT' and
       p_type <> 'EXPRESSION' and
       p_type <> 'RATETABLE' and
       p_type <> 'RATEDIMENSION' and
       p_type <> 'FORMULA') THEN
        l_return_str := NULL;
        return l_return_str;
   END IF;

   IF (p_prefix is null) THEN
        l_return_str := NULL;
        l_prefix_str := '';
   END IF;

   l_temp_str := CONCAT(p_prefix,p_name);


   if (p_type = 'PLAN') THEN
       SELECT SUBSTRB(l_temp_str,1,30) into l_return_str FROM DUAL;
   ELSIF (p_type = 'PLANELEMENT')  THEN
       SELECT SUBSTRB(l_temp_str,1,80) into l_return_str FROM DUAL;
   ELSIF (p_type = 'EXPRESSION')  THEN
       SELECT SUBSTRB(l_temp_str,1,30) into l_return_str FROM DUAL;
   ELSIF (p_type = 'RATETABLE')  THEN
      SELECT SUBSTRB(l_temp_str,1,80) into l_return_str FROM DUAL;
   ELSIF (p_type = 'RATEDIMENSION')  THEN
      SELECT SUBSTRB(l_temp_str,1,30) into l_return_str FROM DUAL;
   ELSIF (p_type = 'FORMULA')  THEN
      SELECT SUBSTRB(l_temp_str,1,30) into l_return_str FROM DUAL;
   END IF;

   return l_return_str;
 EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
 END check_name_length;


 END CN_PLANCOPY_UTIL_PVT;

/
