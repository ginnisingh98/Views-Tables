--------------------------------------------------------
--  DDL for Package Body OZF_DENORM_QUERIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_DENORM_QUERIES_PVT" AS
/*$Header: ozfvofdb.pls 120.0 2005/06/01 02:39:55 appldev noship $*/



---------------------------------------------------------------------
-- PROCEDURE
--    create_denorm_queries
--
-- HISTORY
-- pmothuku

---------------------------------------------------------------------
PROCEDURE create_denorm_queries(
   p_api_version         IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2  := FND_API.g_false,
   p_commit              IN  VARCHAR2  := FND_API.g_false,
   p_validation_level    IN  NUMBER    := FND_API.g_valid_level_full,

   p_denorm_queries_rec  IN  denorm_queries_rec_type,

   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2,

   x_denorm_query_id     OUT NOCOPY NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'create_denorm_queries';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status VARCHAR2(1);
   l_denorm_queries_rec      denorm_queries_rec_type:= p_denorm_queries_rec;
   l_stringArray stringArray;
   l_string varchar2(32000):= l_denorm_queries_rec.SQL_STATEMENT;
   l_denorm_count NUMBER;

   CURSOR c_denorm_queries_seq IS
   SELECT ozf_denorm_queries_s.NEXTVAL
   FROM DUAL;


 CURSOR c_denorm_count(denorm_id IN NUMBER) IS
   SELECT count(*)
     FROM ozf_denorm_queries
    WHERE denorm_query_id = denorm_id;
BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT create_denorm_queries;

   OZF_Utility_PVT.debug_message(l_full_name||': start');

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   --------------------API CODE--------------------------


   ----------------------- validate -----------------------
   OZF_Utility_PVT.debug_message(l_full_name ||': validate');
   --dbms_output.put_line('the validation begins');

	validate_denorm_queries(
		p_api_version        => l_api_version,
		p_init_msg_list      => p_init_msg_list,
		p_validation_level   => p_validation_level,
		p_validation_mode    =>'CRE',
		p_denorm_queries_rec => l_denorm_queries_rec,
		x_return_status      => l_return_status,
		x_msg_count          => x_msg_count,
		x_msg_data           => x_msg_data
	);
	IF l_return_status = FND_API.g_ret_sts_error THEN
		RAISE FND_API.g_exc_error;
	ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
		RAISE FND_API.g_exc_unexpected_error;
	END IF;

        --dbms_output.put_line('the denorm query id beginning');
	IF l_denorm_queries_rec.denorm_query_id IS NULL THEN
		    LOOP
			OPEN c_denorm_queries_seq;
			FETCH c_denorm_queries_seq INTO l_denorm_queries_rec.denorm_query_id;
			CLOSE c_denorm_queries_seq;

                    OPEN c_denorm_count(l_denorm_queries_rec.denorm_query_id);
		    FETCH c_denorm_count INTO l_denorm_count;
		    CLOSE c_denorm_count;

			EXIT WHEN l_denorm_count = 0;
		 END LOOP;

	 END IF;

	 --dbms_output.put_line('the denorm condition id IS'||l_denorm_queries_rec.condition_id_column);
         string_length_check(l_string,l_stringArray);
	 --dbms_output.put_line('before insert'||SUBSTR(l_stringArray(1),1,150));
         --dbms_output.put_line('before insert for sec'||SUBSTR(l_stringArray(2),1,150));
         INSERT INTO ozf_denorm_queries(
		                    DENORM_QUERY_ID
                                   ,QUERY_FOR
	                           ,CONTEXT
 				   ,ATTRIBUTE
				   ,CONDITION_ID_COLUMN
			           ,CONDITION_NAME_COLUMN
			           ,ACTIVE_FLAG
				   ,CREATION_DATE
		 	           ,CREATED_BY
 	        		   ,LAST_UPDATE_DATE
				   ,LAST_UPDATED_BY
		 	           ,LAST_UPDATE_LOGIN
				   ,SEEDED_FLAG
  				   ,SQL_VALIDATION_1
				   ,SQL_VALIDATION_2
				   ,SQL_VALIDATION_3
				   ,SQL_VALIDATION_4
		 	           ,SQL_VALIDATION_5
		 	           ,SQL_VALIDATION_6
		 	           ,SQL_VALIDATION_7
			           ,SQL_VALIDATION_8,
			   	   OBJECT_VERSION_NUMBER
                                    )
         VALUES(
		 l_denorm_queries_rec.denorm_query_id,
	         l_denorm_queries_rec.QUERY_FOR,
                 l_denorm_queries_rec.CONTEXT,
                 l_denorm_queries_rec.ATTRIBUTE ,
                 l_denorm_queries_rec.CONDITION_ID_COLUMN,
                 l_denorm_queries_rec.CONDITION_NAME_COLUMN,
	 	 nvl(l_denorm_queries_rec.active_flag,'N'),
	         SYSDATE,
		 FND_GLOBAL.user_id,
		 SYSDATE,
		 FND_GLOBAL.user_id,
		 FND_GLOBAL.conc_login_id,
		 'N',
		 l_stringArray(1),
                 l_stringArray(2),
		 l_stringArray(3),
                 l_stringArray(4),
                 l_stringArray(5),
		 l_stringArray(6),
                 l_stringArray(7),
                 l_stringArray(8),
		 1

	        );



	x_denorm_query_id := l_denorm_queries_rec.denorm_query_id;


   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   OZF_Utility_PVT.debug_message(l_full_name ||': end');

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO create_denorm_queries;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_denorm_queries;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN

     ROLLBACK TO create_denorm_queries;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END create_denorm_queries;

---------------------------------------------------------------------
-- PROCEDURE
--    update_denorm_queries
--
-- HISTORY
-- pmothuku  Created

----------------------------------------------------------------------
PROCEDURE update_denorm_queries(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   p_denorm_queries_rec          IN  denorm_queries_rec_type,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
)
IS

   l_api_version CONSTANT NUMBER := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'update_denorm_queries';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_denorm_queries_rec        denorm_queries_rec_type:=p_denorm_queries_rec;
   temp_denorm_queries_rec        denorm_queries_rec_type;

   l_count  NUMBER;
   l_msg    VARCHAR2(2000);
   l_msg_count			NUMBER;
  l_return_status VARCHAR2(1);
   l_stringArray stringArray;
BEGIN

   OZF_Utility_PVT.debug_message(l_full_name||': entered update');

  -------------------- initialize -------------------------
   SAVEPOINT update_denorm_queries;

   OZF_Utility_PVT.debug_message(l_full_name||': start');

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ----------------------- validate ----------------------

   OZF_Utility_PVT.debug_message(l_full_name ||': validate');
     OZF_Utility_PVT.debug_message(l_denorm_queries_rec.denorm_query_id ||': validate1');

  -- replace g_miss_char/num/date with current column values

   complete_denorm_queries_rec(l_denorm_queries_rec, temp_denorm_queries_rec);

  validate_denorm_queries(
		p_api_version        => l_api_version,
		p_init_msg_list      => p_init_msg_list,
		p_validation_level   => p_validation_level,
		p_validation_mode    =>'UPD',
		p_denorm_queries_rec => temp_denorm_queries_rec,
		x_return_status      => l_return_status,
		x_msg_count          => x_msg_count,
		x_msg_data           => x_msg_data
	);
	IF l_return_status = FND_API.g_ret_sts_error THEN
		RAISE FND_API.g_exc_error;
	ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
		RAISE FND_API.g_exc_unexpected_error;
	END IF;

  string_length_check(temp_denorm_queries_rec.SQL_STATEMENT,l_stringArray);



		UPDATE ozf_denorm_queries SET
		        last_update_date = SYSDATE,
			last_updated_by = FND_GLOBAL.user_id,
			last_update_login = FND_GLOBAL.conc_login_id,
			active_flag = nvl(temp_denorm_queries_rec.active_flag,'N'),
			query_for = temp_denorm_queries_rec.query_for,
			context = temp_denorm_queries_rec.context,
			attribute = temp_denorm_queries_rec.attribute,
			condition_name_column = temp_denorm_queries_rec.condition_name_column,
			condition_id_column = temp_denorm_queries_rec.condition_id_column,
			sql_validation_1 = l_stringArray(1),
			sql_validation_2 = l_stringArray(2),
			sql_validation_3 = l_stringArray(3),
			sql_validation_4 = l_stringArray(4),
			sql_validation_5 = l_stringArray(5),
			sql_validation_6 = l_stringArray(6),
			sql_validation_7 = l_stringArray(7),
			sql_validation_8 = l_stringArray(8),
			object_version_number=temp_denorm_queries_rec.object_version_number+1
			WHERE denorm_query_id = temp_denorm_queries_rec.denorm_query_id
		         AND object_version_number =temp_denorm_queries_rec.object_version_number;


	IF (SQL%NOTFOUND) THEN
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
			FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
			FND_MSG_PUB.add;
		END IF;
		RAISE FND_API.g_exc_error;
	END IF;




   -------------------- finish --------------------------
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   OZF_Utility_PVT.debug_message(l_full_name ||': end');

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO update_denorm_queries;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_denorm_queries;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN


      ROLLBACK TO update_denorm_queries;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END update_denorm_queries;

---------------------------------------------------------------
-- PROCEDURE
--    delete_denorm_queries
--
-- HISTORY
--    PMOTHUKU Created.
---------------------------------------------------------------
PROCEDURE delete_denorm_queries(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_commit            IN  VARCHAR2 := FND_API.g_false,

   p_denorm_query_id            IN  NUMBER,
   p_object_version    IN  NUMBER,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'delete_event_offer';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_denorm_query_id NUMBER;


BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT delete_denorm_queries;

   OZF_Utility_PVT.debug_message(l_full_name||': start');

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;


   ------------------------ delete ------------------------
   OZF_Utility_PVT.debug_message(l_full_name ||': delete');

   delete ozf_denorm_queries
   WHERE denorm_query_id = p_denorm_query_id
   AND OBJECT_VERSION_NUMBER=p_object_version;

   -------------------- finish --------------------------
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   OZF_Utility_PVT.debug_message(l_full_name ||': end');

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO delete_denorm_queries;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_denorm_queries;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO delete_denorm_queries;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END delete_denorm_queries;





--------------------------------------------------------------------
-- PROCEDURE
--    validate_event_offer
--
-- HISTORY
--      pmothuku  Created.
--------------------------------------------------------------------
PROCEDURE validate_denorm_queries(
   p_api_version        IN  NUMBER,
   p_init_msg_list      IN  VARCHAR2 := FND_API.g_false,
   p_validation_level   IN  NUMBER   := FND_API.g_valid_level_full,
   p_validation_mode    IN  VARCHAR2,
   p_denorm_queries_rec IN  denorm_queries_rec_type,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
)IS
   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'validate_denorm_queries';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status VARCHAR2(1);
   l_mode varchar2(3):=p_validation_mode;
BEGIN

   ----------------------- initialize --------------------
   OZF_Utility_PVT.debug_message(l_full_name||': start');

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

	---------------------- validate ------------------------
	OZF_Utility_PVT.debug_message(l_full_name||': check items');

	IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
		check_denorm_queries_items(
			p_denorm_queries_rec        => p_denorm_queries_rec,
			p_validation_mode => l_mode,
			x_return_status   => l_return_status
		);
		IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
			RAISE FND_API.g_exc_unexpected_error;
		ELSIF l_return_status = FND_API.g_ret_sts_error THEN
			RAISE FND_API.g_exc_error;
		END IF;
	END IF;

	OZF_Utility_PVT.debug_message(l_full_name||': check record');




   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   OZF_Utility_PVT.debug_message(l_full_name ||': end');

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END validate_denorm_queries;


---------------------------------------------------------------------
-- PROCEDURE
--    check_denorm_queries_update_items
--
-- HISTORY
--   pmothuku  Created.
---------------------------------------------------------------------
PROCEDURE check_denorm_queries_upd_items(
   p_denorm_queries_rec        IN  denorm_queries_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS

l_query_for varchar2(4):=p_denorm_queries_rec.query_for;
l_context_name varchar2(30):=p_denorm_queries_rec.context;
l_context_attribute varchar2(30):=p_denorm_queries_rec.attribute;

temp_query_for varchar2(4);
temp_context_name varchar2(30);
temp_context_attribute varchar2(30);
l_denorm_queries_rec  denorm_queries_rec_type;
l_denorm_query_id NUMBER;
 CURSOR chkexists(p_query_for IN varchar2,p_context_name IN varchar2,p_context_attribute IN varchar2) IS
 select denorm_query_id from ozf_denorm_queries
 where query_for=p_query_for and context=p_context_name
 and attribute=p_context_attribute;
BEGIN
/*
   OPEN chkexists(l_query_for,l_context_name,l_context_attribute);
   FETCH chkexists INTO l_denorm_query_id ;
   IF chkexists%NOTFOUND OR (l_denorm_query_id = p_denorm_queries_rec.denorm_query_id) THEN
   CLOSE chkexists;
   X_RETURN_STATUS:='S';
   ELSE
     IF(l_denorm_query_id<>p_denorm_queries_rec.denorm_query_id)THEN
     OZF_Utility_PVT.debug_message('This record already exists');
     x_return_status:='E';
     FND_MESSAGE.set_name('OZF', 'OZF_DENORM_QUERIES_EXISTS');
     FND_MSG_PUB.add;
     END IF;
    END IF;
*/
  NULL;
END ;


---------------------------------------------------------------------
-- PROCEDURE
--   check_denorm_queries_req_items
--
-- HISTORY
--    pmothuku  Created.
---------------------------------------------------------------------
PROCEDURE check_denorm_queries_req_items(
   p_denorm_queries_rec       IN  denorm_queries_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
  )
IS
l_msg_error varchar2(4000);

l_str varchar2(32000);
BEGIN

	x_return_status := FND_API.g_ret_sts_success;
  IF (p_denorm_queries_rec.query_for IS NULL OR p_denorm_queries_rec.query_for = FND_API.g_miss_char) THEN
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
			FND_MESSAGE.set_name('OZF', 'OZF_NO_QUERY_FOR_TYPE');
			FND_MSG_PUB.add;
		END IF;
		x_return_status := FND_API.g_ret_sts_error;
		RETURN;
	END IF;
 IF (p_denorm_queries_rec.context IS NULL OR p_denorm_queries_rec.context = FND_API.g_miss_char) THEN
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
			FND_MESSAGE.set_name('OZF', 'OZF_NO_QUALIFIER_CONTEXT');
			FND_MSG_PUB.add;
		END IF;
		x_return_status := FND_API.g_ret_sts_error;
		RETURN;
	END IF;
	------------------------ qualifier_context_attribute --------------------------
	IF (p_denorm_queries_rec.attribute IS NULL OR p_denorm_queries_rec.attribute = FND_API.g_miss_char) THEN
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
			FND_MESSAGE.set_name('OZF', 'OZF_NO_QUALIFIER_CONTEXT_ATTR');
			FND_MSG_PUB.add;
		END IF;
		x_return_status := FND_API.g_ret_sts_error;
		RETURN;



	END IF;



       IF (p_denorm_queries_rec.SQL_STATEMENT IS NULL ) OR (p_denorm_queries_rec.SQL_STATEMENT = FND_API.g_miss_char) THEN
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
			FND_MESSAGE.set_name('OZF', 'OZF_NO_SQLSTATEMENT');
			FND_MSG_PUB.add;
		END IF;
		x_return_status := FND_API.g_ret_sts_error;
		RETURN;
	END IF;

IF (((p_denorm_queries_rec.condition_id_column IS NULL ) OR (p_denorm_queries_rec.condition_id_column = FND_API.g_miss_char)) AND
   ((p_denorm_queries_rec.condition_name_column IS NULL ) OR (p_denorm_queries_rec.condition_name_column = FND_API.g_miss_char)))THEN

 EXECUTE IMMEDIATE p_denorm_queries_rec.SQL_STATEMENT;

ELSE
   IF (((p_denorm_queries_rec.condition_id_column <> NULL ) OR (p_denorm_queries_rec.condition_id_column <> FND_API.g_miss_char)) AND
    ((p_denorm_queries_rec.condition_name_column IS NULL ) OR (p_denorm_queries_rec.condition_name_column = FND_API.g_miss_char)))
   THEN
     l_str :=upper(p_denorm_queries_rec.SQL_STATEMENT);
     IF(INSTR(l_str,'WHERE',1,1)>0)THEN
     l_str:=l_str||' '||' '||'AND'||' '||' '||p_denorm_queries_rec.condition_id_column||'=1';
     ELSE
     l_str:=l_str||' '||' '||'WHERE'||' '||p_denorm_queries_rec.condition_id_column||'=1';
     END IF;

   ELSE
     IF (((p_denorm_queries_rec.condition_name_column <> NULL ) OR (p_denorm_queries_rec.condition_name_column <> FND_API.g_miss_char)) AND
    ((p_denorm_queries_rec.condition_id_column IS NULL ) OR (p_denorm_queries_rec.condition_id_column = FND_API.g_miss_char)))
     THEN
      l_str :=upper(p_denorm_queries_rec.SQL_STATEMENT);
      IF(INSTR(l_str,'WHERE',1,1)>0)THEN
      l_str:=l_str||' '||' '||'AND'||' '||' '||p_denorm_queries_rec.condition_name_column||'=''''';
      ELSE
      l_str:=l_str||' '||' '||'WHERE'||' '||p_denorm_queries_rec.condition_name_column||'=''''';
      END IF;

     ELSE
	  l_str :=upper(p_denorm_queries_rec.SQL_STATEMENT);
      IF(INSTR(l_str,'WHERE',1,1)>0)THEN
      l_str:=l_str||' '||' '||'AND'||' '||' '||p_denorm_queries_rec.condition_name_column||'='''''||''||' '||'AND'||' '||' '||p_denorm_queries_rec.condition_id_column||'=1';
      ELSE
      l_str:=l_str||' '||' '||'WHERE'||' '||p_denorm_queries_rec.condition_name_column||'='''''||''||' ' ||'AND'||' '||' '||p_denorm_queries_rec.condition_id_column||'=1';
      END IF;
    END IF;
   END IF;
 OZF_Utility_PVT.debug_message('the sql formed is '||l_str);
--p_denorm_queries_rec.SQL_STATEMENT:=p_denorm_queries_rec.SQL_STATEMENT||''||'AND'||''||p_denorm_queries_rec.condition_id_column=1;
 EXECUTE IMMEDIATE l_str;
END IF;
EXCEPTION
when others then
x_return_status := FND_API.g_ret_sts_error;
 FND_MESSAGE.set_name('OZF','OZF_NO_SQLSTATEMENT');
 FND_MSG_PUB.add;
 FND_MESSAGE.SET_NAME('OZF','OZF_API_DEBUG_MESSAGE');
 FND_MESSAGE.SET_TOKEN('TEXT',SQLERRM);
 FND_MSG_PUB.add;
END check_denorm_queries_req_items;


---------------------------------------------------------------------
-- PROCEDURE
--    check_denorm_queries_items
--
-- HISTORY
--    PMOTHUKU  Created.
---------------------------------------------------------------------
PROCEDURE check_denorm_queries_items(
   p_denorm_queries_rec         IN  denorm_queries_rec_type,
   p_validation_mode IN  VARCHAR2 ,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN



   -------------------------- Create or Update Mode ----------------------------
OZF_UTILITY_PVT.debug_message('before req_items');

  check_denorm_queries_req_items(
      p_denorm_queries_rec        => p_denorm_queries_rec,
      x_return_status  => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
OZF_UTILITY_PVT.debug_message('THE MODE IS'||p_validation_mode);
 IF p_validation_mode = 'CRE' THEN

		check_denorm_queries_record(
			p_denorm_queries_rec       => p_denorm_queries_rec,
			x_return_status  => x_return_status
		);
		IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
			RAISE FND_API.g_exc_unexpected_error;
		ELSIF x_return_status = FND_API.g_ret_sts_error THEN
			 RAISE FND_API.g_exc_error;
		END IF;
	END IF;
-------------------------- Update Mode ----------------------------

OZF_UTILITY_PVT.debug_message('before ok_items');
   IF p_validation_mode = 'UPD' THEN
   	  check_denorm_queries_upd_items(
      		p_denorm_queries_rec        => p_denorm_queries_rec,
      		x_return_status  => x_return_status
   	  );

   	  IF x_return_status <> FND_API.g_ret_sts_success THEN
      	 	RETURN;
   	  END IF;
    END IF;

END check_denorm_queries_items;


---------------------------------------------------------------------
-- PROCEDURE
--    check_denorm_queries_record
--
-- HISTORY
--    pmothuku  Created.
---------------------------------------------------------------------



PROCEDURE check_denorm_queries_record(
	p_denorm_queries_rec        IN  denorm_queries_rec_type,
	x_return_status   OUT NOCOPY  VARCHAR2
) IS
l_query_for varchar2(4):=p_denorm_queries_rec.query_for;
l_context_name varchar2(30):=p_denorm_queries_rec.context;
l_context_attribute varchar2(30):=p_denorm_queries_rec.attribute;

temp_query_for varchar2(4);
temp_context_name varchar2(30);
temp_context_attribute varchar2(30);
l_denorm_queries_rec  denorm_queries_rec_type;

 CURSOR chkexists(p_query_for IN varchar2,p_context_name IN varchar2,p_context_attribute IN varchar2) IS
 select query_for,context,attribute from ozf_denorm_queries
 where query_for=p_query_for and context=p_context_name
 and attribute=p_context_attribute;
BEGIN
/*
   OPEN chkexists(l_query_for,l_context_name,l_context_attribute);
   FETCH chkexists INTO temp_query_for,temp_context_name,temp_context_attribute;
   IF chkexists%NOTFOUND THEN
   CLOSE chkexists;
   X_RETURN_STATUS:='S';
   ELSE
    OZF_Utility_PVT.debug_message('This record already exists');
    x_return_status:='E';
     FND_MESSAGE.set_name('OZF', 'OZF_DENORM_QUERIES_EXISTS');
     FND_MSG_PUB.add;
    END IF;
*/
  NULL;
END check_denorm_queries_record;


---------------------------------------------------------------------
-- PROCEDURE
--    init_denorm_queries_rec
--
-- HISTORY
--    11/23/1999  pmothuku  Create.
---------------------------------------------------------------------
PROCEDURE init_denorm_queries_rec(
   x_denorm_queries_rec  OUT NOCOPY  denorm_queries_rec_type
)
IS
BEGIN

   RETURN;
END init_denorm_queries_rec;


---------------------------------------------------------------------
-- PROCEDURE
--    complete_denorm_queries_rec
--
-- HISTORY
--   pmothuku
---------------------------------------------------------------------
PROCEDURE complete_denorm_queries_rec(
   p_denorm_queries_rec       IN  denorm_queries_rec_type,
   x_complete_rec  OUT NOCOPY denorm_queries_rec_type
)
IS

   CURSOR c_denorm_queries IS
   SELECT *
     FROM ozf_denorm_queries
     WHERE denorm_query_id = p_denorm_queries_rec.denorm_query_id;


   l_denorm_queries_rec  c_denorm_queries%ROWTYPE;

BEGIN
OZF_UTILITY_PVT.debug_message('complete_denorm_queries_rec :'|| p_denorm_queries_rec.denorm_query_id);

   x_complete_rec := p_denorm_queries_rec;

   OPEN c_denorm_queries;
   FETCH c_denorm_queries INTO l_denorm_queries_rec;
   IF c_denorm_queries%NOTFOUND THEN
      CLOSE c_denorm_queries;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_denorm_queries;


   IF p_denorm_queries_rec.query_for = FND_API.g_miss_char THEN
      x_complete_rec.query_for:= NULL;
   END IF;
   IF p_denorm_queries_rec.query_for IS NULL THEN
      x_complete_rec.query_for:= l_denorm_queries_rec.query_for;
   END IF;

   IF p_denorm_queries_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date:= NULL;
   END IF;
   IF p_denorm_queries_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date:= l_denorm_queries_rec.creation_date;
   END IF;
     IF p_denorm_queries_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := NULL;
   END IF;
     IF p_denorm_queries_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_denorm_queries_rec.created_by;
   END IF;
  IF p_denorm_queries_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := NULL;
   END IF;
  IF p_denorm_queries_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_denorm_queries_rec.last_update_date;
   END IF;
  IF p_denorm_queries_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := NULL;
   END IF;
  IF p_denorm_queries_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_denorm_queries_rec.last_updated_by;
   END IF;

  IF p_denorm_queries_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := NULL;
  END IF;
  IF p_denorm_queries_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_denorm_queries_rec.last_update_login;
  END IF;

    IF p_denorm_queries_rec.active_flag = FND_API.g_miss_char THEN
      x_complete_rec.active_flag := NULL;
   END IF;
    IF p_denorm_queries_rec.active_flag IS NULL THEN
      x_complete_rec.active_flag := l_denorm_queries_rec.active_flag;
   END IF;

   IF p_denorm_queries_rec.context = fnd_api.g_miss_char then
      x_complete_rec.context := NULL;
   END IF;
   IF p_denorm_queries_rec.context IS NULL then
      x_complete_rec.context := l_denorm_queries_rec.context;
   END IF;

   IF p_denorm_queries_rec.attribute = FND_API.g_miss_char THEN
      x_complete_rec.attribute := NULL;
   END IF;
   IF p_denorm_queries_rec.attribute IS NULL THEN
      x_complete_rec.attribute := l_denorm_queries_rec.attribute;
   END IF;
   IF p_denorm_queries_rec.condition_name_column = fnd_api.g_miss_char then
      x_complete_rec.condition_name_column := NULL;
   END IF;
   IF p_denorm_queries_rec.condition_name_column IS NULL then
      x_complete_rec.condition_name_column := l_denorm_queries_rec.condition_name_column;
   END IF;

   IF p_denorm_queries_rec.condition_id_column = FND_API.g_miss_char THEN
      x_complete_rec.condition_id_column:= NULL;
   END IF;
   IF p_denorm_queries_rec.condition_id_column IS NULL THEN
      x_complete_rec.condition_id_column:= l_denorm_queries_rec.condition_id_column;
   END IF;
     IF p_denorm_queries_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number:= NULL;
   END IF;
     IF p_denorm_queries_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number:= l_denorm_queries_rec.object_version_number;
   END IF;
END complete_denorm_queries_rec;


PROCEDURE string_length_check(sqlst IN VARCHAR2, sArray  OUT NOCOPY stringArray)
 IS

  sqlstatement VARCHAR2(32000):=sqlst;
  lengthLimit  NUMBER:=4000;
  startIndexTrace NUMBER:=1;
  sLength NUMBER:=LENGTH(sqlstatement);
  counter NUMBER:=1;
  l_string1 varchar2(4000);

  BEGIN
        --dbms_output.put_line('the length,startIndex and counter is'||sLength||'next'||startIndexTrace||'next'||counter);
	 WHILE (sLength>lengthLimit) LOOP
            --dbms_output.put_line('statements in while');
         sArray(counter):=SUBSTR(sqlstatement,startIndexTrace,4000);
         counter:=counter+1;
         startIndexTrace:=startIndexTrace+lengthLimit;
	 sLength:=sLength-startIndexTrace;
	 END LOOP;
            --l_string1:=sArray(1);
	      --dbms_output.put_line('the statements before if-else clause ');
	   IF(counter>1) THEN
	     --dbms_output.put_line('the statements in if of if-else clause');
            sArray(counter):=SUBSTR(sqlstatement,startIndexTrace);

            ELSE
	       --dbms_output.put_line('the statements in else of if-else clause');
		    --dbms_output.put_line('the INPUT STRING IS'|| sqlstatement);
	    -- dbms_output.put_line('the SUBSTRING '||SUBSTR(sqlstatement,startIndexTrace,236));
	     sArray(counter):=SUBSTR(sqlstatement,startIndexTrace);
	     END IF;
	       IF(counter<8)THEN
	          FOR i in counter+1..8 LOOP
                  sArray(i):='';
		  END LOOP;
	       END IF;
           --dbms_output.put_line('the statements after if-else clause ');
	      l_string1:=sArray(1);

	--dbms_output.put_line('the separated values are'||SUBSTR(l_string1,startIndexTrace,236));



    END  string_length_check;


END Ozf_Denorm_Queries_Pvt;

/
