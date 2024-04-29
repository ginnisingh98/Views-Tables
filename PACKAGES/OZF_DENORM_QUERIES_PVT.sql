--------------------------------------------------------
--  DDL for Package OZF_DENORM_QUERIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_DENORM_QUERIES_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvofds.pls 120.0 2005/06/01 00:24:29 appldev noship $ */
G_PKG_NAME CONSTANT VARCHAR2(30) := 'OZF_Denorm_Queries_PVT';

TYPE stringArray IS TABLE OF VARCHAR2(4000)INDEX BY BINARY_INTEGER ;


TYPE denorm_queries_rec_type IS RECORD
(
   DENORM_QUERY_ID               NUMBER
  ,QUERY_FOR                     VARCHAR2(30)
  ,CONTEXT                       VARCHAR2(30)
  ,ATTRIBUTE                     VARCHAR2(30)
  ,SQL_STATEMENT                 VARCHAR2(32000)
  ,ACTIVE_FLAG                   VARCHAR2(1)
  ,CONDITION_NAME_COLUMN         VARCHAR2(30)
  ,CONDITION_ID_COLUMN           VARCHAR2(30)
  ,LAST_UPDATE_DATE              DATE
  ,LAST_UPDATED_BY               NUMBER
  ,CREATION_DATE                 DATE
  ,CREATED_BY                    NUMBER
  ,LAST_UPDATE_LOGIN             NUMBER
  ,OBJECT_VERSION_NUMBER         NUMBER
  ,SECURITY_GROUP_ID             NUMBER

 );



PROCEDURE create_denorm_queries
(
   p_api_version         IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2  := FND_API.g_false,
   p_commit              IN  VARCHAR2  := FND_API.g_false,
   p_validation_level    IN  NUMBER    := FND_API.g_valid_level_full,

   p_denorm_queries_rec  IN  denorm_queries_rec_type,

   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2,

   x_denorm_query_id     OUT NOCOPY NUMBER
);

PROCEDURE update_denorm_queries
(
   p_api_version         IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2  := FND_API.g_false,
   p_commit              IN  VARCHAR2  := FND_API.g_false,
   p_validation_level    IN  NUMBER    := FND_API.g_valid_level_full,

   p_denorm_queries_rec  IN  denorm_queries_rec_type,

   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2

);

PROCEDURE delete_denorm_queries
(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_commit            IN  VARCHAR2 := FND_API.g_false,

   p_denorm_query_id   IN  NUMBER,
   p_object_version    IN  NUMBER,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
);

PROCEDURE validate_denorm_queries(
   p_api_version        IN  NUMBER,
   p_init_msg_list      IN  VARCHAR2  := FND_API.g_false,
   p_validation_level   IN  NUMBER    := FND_API.g_valid_level_full,
   p_validation_mode    IN VARCHAR2,
   p_denorm_queries_rec IN  denorm_queries_rec_type,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE

--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS

---------------------------------------------------------------------
PROCEDURE check_denorm_queries_items(
   p_denorm_queries_rec         IN  denorm_queries_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE

--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS

---------------------------------------------------------------------

PROCEDURE check_denorm_queries_record (
   p_denorm_queries_rec          IN  denorm_queries_rec_type,
   x_return_status    OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    init_denorm_queries_rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE init_denorm_queries_rec(
   x_denorm_queries_rec         OUT NOCOPY  denorm_queries_rec_type
);
PROCEDURE complete_denorm_queries_rec(
   p_denorm_queries_rec       IN  denorm_queries_rec_type,
   x_complete_rec  OUT NOCOPY denorm_queries_rec_type
);


PROCEDURE string_length_check(sqlst IN VARCHAR2, sArray  OUT NOCOPY stringArray);

END Ozf_Denorm_Queries_Pvt;

 

/
