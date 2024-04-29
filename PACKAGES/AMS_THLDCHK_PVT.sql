--------------------------------------------------------
--  DDL for Package AMS_THLDCHK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_THLDCHK_PVT" AUTHID CURRENT_USER as
/* $Header: amsvthcs.pls 115.14 2002/11/22 23:39:27 dbiswas ship $ */

-- Start of Comments
--
-- NAME
--   AMS_Thldchk_PVT
--
-- PURPOSE
--   This package is a Private API for managing Trigger Checks information in
--   AMS.  It contains specification for pl/sql records and tables
--
--   Procedures:
--
--     ams_trigger_checks:
--
--   Create_Thldchk (see below for specification)
--   Update_Thldchk (see below for specification)
--   Delete_Thldchk (see below for specification)
--   Lock_Thldchk (see below for specification)
--   Validate_Thldchk (see below for specification)
--   Check_Thldchk_Items (see below for specification)
--   Check_Thldchk_Record (see below for specification)
--   Init_Thldchk_Rec (see below for specification)
--   Complete_Thldchk_rec (see below for specification)
--
--
-- NOTES
--
--
-- HISTORY
--   06/29/1999        ptendulk            created
--  15-Feb-2001        ptendulk      Modified for Hornet release ,
--                                   Added chk1/chk2 object ids in record type.
-- End of Comments
--
-- ams_trigger_checks
--
TYPE thldchk_rec_type IS RECORD
(
-- PK
   trigger_check_id                  NUMBER ,
   last_update_date                  DATE ,
   last_updated_by                   NUMBER ,
   creation_date                     DATE,
   created_by                        NUMBER,
   last_update_login                 NUMBER,
   object_version_number             NUMBER,
   trigger_id                        NUMBER,
   order_number                      NUMBER,
   chk1_type                         VARCHAR2(30),
   chk1_arc_source_code_from         VARCHAR2(30),
   chk1_act_object_id                NUMBER,
   chk1_source_code                  VARCHAR2(30),
   chk1_source_code_metric_id        NUMBER,
   chk1_source_code_metric_type      VARCHAR2(30),
   chk1_workbook_owner               NUMBER,
   chk1_workbook_name                VARCHAR2(254),
   chk1_to_chk2_operator_type        VARCHAR2(30),
   chk2_type                         VARCHAR2(30),
   chk2_value                        NUMBER,
   chk2_low_value                    NUMBER,
   chk2_high_value                   NUMBER,
   chk2_uom_code                     VARCHAR2(3),
   chk2_currency_code                VARCHAR2(15),
   chk2_source_code                  VARCHAR2(30),
   chk2_arc_source_code_from         VARCHAR2(30),
   chk2_act_object_id                NUMBER,
   chk2_source_code_metric_id        NUMBER,
   chk2_source_code_metric_type      VARCHAR2(30),
   chk2_workbook_name                VARCHAR2(254),
   chk2_workbook_owner               VARCHAR2(100),
   chk2_worksheet_name               VARCHAR2(254)
   --
   );


--
-- Start of Comments
--
--SQL> desc ams_trigger_checks ;
-- Name                                                  Null?    Type
-- ----------------------------------------------------- -------- -----------------------
-- TRIGGER_CHECK_ID                                      NOT NULL NUMBER
-- LAST_UPDATE_DATE                                      NOT NULL DATE
-- LAST_UPDATED_BY                                       NOT NULL NUMBER(15)
-- CREATION_DATE                                         NOT NULL DATE
-- CREATED_BY                                            NOT NULL NUMBER(15)
-- LAST_UPDATE_LOGIN                                              NUMBER(15)
-- OBJECT_VERSION_NUMBER                                          NUMBER(9)
-- TRIGGER_ID                                            NOT NULL NUMBER
-- ORDER_NUMBER                                          NOT NULL NUMBER(15)
-- CHK1_TYPE                                             NOT NULL VARCHAR2(30)
-- CHK1_ARC_SOURCE_CODE_FROM                                      VARCHAR2(30)
-- CHK1_SOURCE_CODE                                               VARCHAR2(30)
-- CHK1_SOURCE_CODE_METRIC_ID                                     NUMBER
-- CHK1_SOURCE_CODE_METRIC_TYPE                                   VARCHAR2(30)
-- CHK1_WORKBOOK_OWNER                                            NUMBER(15)
-- CHK1_WORKBOOK_NAME                                             VARCHAR2(254)
-- CHK1_TO_CHK2_OPERATOR_TYPE                            NOT NULL VARCHAR2(30)
-- CHK2_TYPE                                             NOT NULL VARCHAR2(30)
-- CHK2_VALUE                                                     NUMBER(15)
-- CHK2_LOW_VALUE                                                 NUMBER(15)
-- CHK2_HIGH_VALUE                                                NUMBER(15)
-- CHK2_SOURCE_CODE                                               VARCHAR2(30)
-- CHK2_ARC_SOURCE_CODE_FROM                                      VARCHAR2(30)
-- CHK2_SOURCE_CODE_METRIC_ID                                     NUMBER
-- CHK2_SOURCE_CODE_METRIC_TYPE                                   VARCHAR2(30)
-- CHK2_WORKBOOK_NAME                                             VARCHAR2(254)
-- CHK2_WORKBOOK_OWNER                                            VARCHAR2(100)
-- CHK2_UOM_CODE                                                  VARCHAR2(3)
-- CHK2_CURRENCY_CODE                                             VARCHAR2(15)
-- CHK2_WORKSHEET_NAME                                            VARCHAR2(254)
-- CHK1_ACT_OBJECT_ID                                             NUMBER
-- CHK2_ACT_OBJECT_ID                                             NUMBER
-----
-- End of Comments
--


-- global constants
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
-------------------------------- AMS_TRIGGER_CHECKS-------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------


/*****************************************************************************************/
-- Start of Comments
--
--    API name    : Create_Thldchk
--    Type        : Private
--    Function    : Create a row in ams_trigger_checks table
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    standard IN parameters
--    p_api_version          IN NUMBER       := NULL           		Required
--    p_init_msg_list        IN VARCHAR2     := FND_API.G_FALSE,
--    p_commit			     IN VARCHAR2     := FND_API.G_FALSE, Optional
--    p_validation_level     IN NUMBER       := FND_API.G_VALID_LEVEL_FULL,
--
--    API's IN parameters
--    p_Thldchk_Rec               IN     thldchk_rec_type,
--    OUT        :
--    standard OUT parameters
--    x_return_status             OUT    VARCHAR2(1)
--    x_msg_count                 OUT    NUMBER
--    x_msg_data                  OUT    VARCHAR2(2000)
--
--
--    API's OUT parameters
--    x_trigger_check_id      	  OUT    NUMBER
--
--
--    Version    :     Current version     1.0
--                     Initial version     1.0
--
--    Business rules:
-- 1. ...
--
--
-- End Of Comments

PROCEDURE Create_thldchk
( p_api_version                   IN     NUMBER,
  p_init_msg_list                 IN     VARCHAR2 := FND_API.G_False,
  p_commit                        IN     VARCHAR2 := FND_API.G_False,
  p_validation_level              IN     NUMBER	  := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                 OUT NOCOPY    VARCHAR2,
  x_msg_count                     OUT NOCOPY    NUMBER,
  x_msg_data                      OUT NOCOPY    VARCHAR2,

  p_thldchk_Rec                   IN     thldchk_rec_type,
  x_trigger_check_id	          OUT NOCOPY    NUMBER
);

/*****************************************************************************************/
-- Start of Comments
--
--    API name    : Update_Thldchk
--    Type        : Private
--    Function    : Update a row in ams_trigger_checks table
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN          :
--    standard IN parameters
--    p_api_version       IN NUMBER       := NULL           		Required
--    p_init_msg_list     IN VARCHAR2     := FND_API.G_FALSE Optional
--    p_commit            IN VARCHAR2     := FND_API.G_FALSE Optional
--    p_validation_level  IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
--    API's IN parameters
--    p_thldchk_rec       IN     thldchk_rec_type

--    OUT        :
--    standard OUT parameters
--    x_return_status                OUT    VARCHAR2(1)
--    x_msg_count                    OUT    NUMBER
--    x_msg_data                     OUT    VARCHAR2(2000)
--
--
--    Version    :     Current version     1.0
--                     Initial version     1.0
--    Business rules:
-- 1. ...
--
-- End Of Comments

PROCEDURE Update_Thldchk
( p_api_version                IN     NUMBER,
  p_init_msg_list              IN     VARCHAR2   := FND_API.G_False,
  p_commit                     IN     VARCHAR2   := FND_API.G_False,
  p_validation_level           IN     NUMBER     := FND_API.G_VALID_LEVEL_FULL,

  x_return_status              OUT NOCOPY    VARCHAR2,
  x_msg_count                  OUT NOCOPY    NUMBER,
  x_msg_data                   OUT NOCOPY    VARCHAR2,

  p_thldchk_rec                IN     thldchk_rec_type
);

/*****************************************************************************************/
-- Start of Comments
--
--    API name    : Delete_Thldchk
--    Type        : Private
--    Function    : Delete a row in ams_trigger_checks table
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    standard IN parameters
--    p_api_version               IN 	NUMBER       := NULL   		Required
--    p_init_msg_list             IN 	VARCHAR2     := FND_API.G_FALSE Optional
--    p_commit			     	  IN 	VARCHAR2     := FND_API.G_FALSE Optional
--    API's IN parameters
--      p_trigger_check_id   		IN     NUMBER,
--      p_object_version_number     IN     NUMBER
--
--    OUT        :
--    standard OUT parameters
--    x_return_status             OUT    VARCHAR2(1)
--    x_msg_count                 OUT    NUMBER
--    x_msg_data                  OUT    VARCHAR2(2000)
--
--    Version    :     Current version   1.0
--                     Initial version   1.0
--
--    Business rules:
-- 1. ...
--
-- End Of Comments

PROCEDURE Delete_Thldchk
( p_api_version               IN     NUMBER,
  p_init_msg_list             IN     VARCHAR2    := FND_API.G_False,
  p_commit                    IN     VARCHAR2    := FND_API.G_False,

  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_count                 OUT NOCOPY    NUMBER,
  x_msg_data                  OUT NOCOPY    VARCHAR2,

  p_trigger_check_id          IN     NUMBER,
  p_object_version_number     IN     NUMBER
);


/******************************************************************************/
-- Start of Comments
--
--    API name    : Lock_Thldchk
--    Type        : Private
--    Function    : Lock a row in ams_trigger_checks
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    standard IN parameters
--    p_api_version       IN NUMBER    := NULL              Required
--    p_init_msg_list     IN VARCHAR2  := FND_API.G_FALSE   Optional
--
--    API's IN parameters
--    p_trigger_check_id          IN     NUMBER
--    p_object_version_number     IN     NUMBER
--
--    OUT        :
--    standard OUT parameters
--    x_return_status                OUT    VARCHAR2(1)
--    x_msg_count                    OUT    NUMBER
--    x_msg_data                     OUT    VARCHAR2(2000)
--
--
--    Version    :     Current version     1.0
--                     Initial version     1.0
--
-- End Of Comments



PROCEDURE Lock_Thldchk
( p_api_version               IN     NUMBER,
  p_init_msg_list             IN     VARCHAR2 := FND_API.G_False,

  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_count                 OUT NOCOPY    NUMBER,
  x_msg_data                  OUT NOCOPY    VARCHAR2,

  p_trigger_check_id          IN     NUMBER,
  p_object_version_number     IN  NUMBER
);


/******************************************************************************/
-- Start of Comments
--
--    API name    : Validate_Thldchk
--    Type        : Private
--    Function    : Validate a row in ams_trigger_checks table
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    standard IN parameters
--    p_api_version       IN NUMBER   := NULL               Required
--    p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE    Optional
--    p_validation_level  IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
--
--    API's IN parameters
--    p_thldchk_Rec                  IN     thldchk_rec_type
--
--    OUT        :
--    standard OUT parameters
--    x_return_status             OUT    VARCHAR2(1)
--    x_msg_count                 OUT    NUMBER
--    x_msg_data                  OUT    VARCHAR2(2000)
--
--    API's OUT parameters
--    x_thldchk_rec              OUT    thldchk_rec_type
--
--
--    Version    :     Current version     1.0
--                     Initial version     1.0
--
-- End Of Comments

PROCEDURE Validate_Thldchk
( p_api_version                  IN     NUMBER,
  p_init_msg_list                IN     VARCHAR2    := FND_API.G_False,
  p_validation_level             IN     NUMBER      := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                OUT NOCOPY    VARCHAR2,
  x_msg_count                    OUT NOCOPY    NUMBER,
  x_msg_data                     OUT NOCOPY    VARCHAR2,

  p_thldchk_Rec                  IN     thldchk_rec_type

);

/******************************************************************************/
-- Start of Comments
--
--    Name        : Validate_Thldchk_Items
--    Type        : Private
--    Function    : Validate columns in ams_trigger_checks
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    p_thldchk_rec     IN  thldchk_rec_type,
--    p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create
--    OUT        :
--    x_return_status           OUT    VARCHAR2
--
--    Business rules:
-- 1. ...
--
-- End Of Comments

PROCEDURE Check_Thldchk_Items(
   p_thldchk_rec     IN  thldchk_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
);

/*****************************************************************************************/
-- Start of Comments
--
--    API name    : Validate_Thldchk_Record
--    Type        : Private
--    Function    : Validate a row in ams_trigger_checks table
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    standard IN parameters
--
--    API's IN parameters
--    p_Thldchk_rec         IN  thldchk_rec_type
--	  p_complete_rec    IN  thldchk_rec_type,
--
--    OUT        :
--    standard OUT parameters
--    x_return_status                OUT    VARCHAR2(1)
--
--    Version    :     Current version     1.0
--                     Initial version     1.0
--
--    Business rules:
-- 1. ...
--
-- End Of Comments

PROCEDURE Check_Thldchk_Record(
   p_thldchk_rec    IN  thldchk_rec_type,
   p_complete_rec   IN  thldchk_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
);


/*****************************************************************************************/
-- Start of Comments
--
--    Name        : Init_Thldchk_Rec
--    Type        : Private
--    Function    : CInitialize the Record type before Updation
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    p_thldchk_rec               IN     thldchk_rec_type Required
--    p_thldchk_req_item_rec      IN     thldchk_validate_rec_type,
--
--    OUT        :
--    x_return_status                        OUT    VARCHAR2
--
--
-- End Of Comments

PROCEDURE Init_Thldchk_Rec(
   x_thldchk_rec  OUT NOCOPY  thldchk_rec_type
);

/*****************************************************************************************/
-- Start of Comments
--
--    Name        : Complete_Thldchk_rec
--    Type        : Private
--    Function    : Complete the record as we don't pass whole record for Updation
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    p_thldchk_rec               IN     thldchk_rec_type Required
--
--    OUT        :
--    x_complete_rec              OUT    thldchk_rec_type
--
--    Business rules:
-- 1. ...
--
-- End Of Comments
PROCEDURE Complete_Thldchk_rec(
   p_thldchk_rec   IN  thldchk_rec_type,
   x_complete_rec  OUT NOCOPY thldchk_rec_type
)
;



END AMS_ThldChk_PVT;

 

/
