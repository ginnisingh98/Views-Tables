--------------------------------------------------------
--  DDL for Package JTF_CAL_ADDR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_CAL_ADDR_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvcas.pls 115.6 2002/04/09 10:56:35 pkm ship      $ */

TYPE AddrRec IS RECORD
  ( ADDRESS_ID            NUMBER
  , RESOURCE_ID           NUMBER
  , CREATED_BY            NUMBER
  , CREATION_DATE         DATE
  , LAST_UPDATED_BY       NUMBER
  , LAST_UPDATE_DATE      DATE
  , LAST_UPDATE_LOGIN     NUMBER
  , LAST_NAME             VARCHAR2(2000)
  , FIRST_NAME            VARCHAR2(2000)
  , JOB_TITLE             VARCHAR2(2000)
  , COMPANY               VARCHAR2(2000)
  , PRIMARY_CONTACT       NUMBER
  , CONTACT1_TYPE         VARCHAR2(2000)
  , CONTACT1              VARCHAR2(2000)
  , CONTACT2_TYPE         VARCHAR2(2000)
  , CONTACT2              VARCHAR2(2000)
  , CONTACT3_TYPE         VARCHAR2(2000)
  , CONTACT3              VARCHAR2(2000)
  , CONTACT4_TYPE         VARCHAR2(2000)
  , CONTACT4              VARCHAR2(2000)
  , CONTACT5_TYPE         VARCHAR2(2000)
  , CONTACT5              VARCHAR2(2000)
  , WWW_ADDRESS           VARCHAR2(2000)
  , ASSISTANT_NAME        VARCHAR2(2000)
  , ASSISTANT_PHONE       VARCHAR2(2000)
  , CATEGORY              NUMBER
  , ADDRESS1              VARCHAR2(2000)
  , ADDRESS2              VARCHAR2(2000)
  , ADDRESS3              VARCHAR2(2000)
  , ADDRESS4              VARCHAR2(2000)
  , CITY                  VARCHAR2(2000)
  , COUNTY                VARCHAR2(2000)
  , STATE                 VARCHAR2(2000)
  , ZIP                   VARCHAR2(2000)
  , COUNTRY               VARCHAR2(2000)
  , NOTE                  VARCHAR2(4000)
  , PRIVATE_FLAG          VARCHAR2(1)
  , DELETED_AS_OF         DATE
  , APPLICATION_ID        NUMBER
  , SECURITY_GROUP_ID     NUMBER
  , OBJECT_VERSION_NUMBER NUMBER(9)
  );

--------------------------------------------------------------------------
-- Start of comments
--  API name    : Insert_Row
--  Type        : Private
--  Function    : Create record in JTF_CAL_ADDRESSES table.
--  Pre-reqs    : None.
--  Parameters  :
--      name                 direction  type     required?
--      ----                 ---------  ----     ---------
--      p_api_version        IN         NUMBER   required
--      p_init_msg_list      IN         VARCHAR2 optional
--      p_commit             IN         VARCHAR2 optional
--      p_validation_level   IN         NUMBER   optional
--      x_return_status         OUT     VARCHAR2 required
--      x_msg_count             OUT     NUMBER   required
--      x_msg_data              OUT     VARCHAR2 required
--      p_bel_rec            IN         cal_address_rec_type   required
--      x_address_id            OUT     NUMBER   required
--
--  Version : Current  version 1.0
--            Previous version 1.0
--            Initial  version 1.0
--
--  Notes: The object_version_number of a new entry is always 1.
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Insert_Row
( p_api_version       IN     NUMBER
, p_init_msg_list     IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit            IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level  IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status        OUT VARCHAR2
, x_msg_count            OUT NUMBER
, x_msg_data             OUT VARCHAR2
, p_adr_rec           IN     AddrRec
, x_address_id           OUT NUMBER
);

--------------------------------------------------------------------------
-- Start of comments
--  API name   : Update_Row
--  Type       : Private
--  Function   : Update record in JTF_CAL_ADDRESSES table.
--  Pre-reqs   : None.
--  Parameters :
--      name                    direction  type       required?
--      ----                    ---------  --------   ---------
--      p_api_version           IN         NUMBER     required
--      p_init_msg_list         IN         VARCHAR2   optional
--      p_commit                IN         VARCHAR2   optional
--      p_validation_level      IN         NUMBER     optional
--      x_return_status            OUT     VARCHAR2   required
--      x_msg_count                OUT     NUMBER     required
--      x_msg_data                 OUT     VARCHAR2   required
--      p_adr_rec               IN         cal_address_rec_type required
--      x_object_version_number    OUT     NUMBER      required
--
--  Version : Current  version 1.0
--            Previous version 1.0
--            Initial  version 1.0
--
--  Notes: An address can only be updated if the object_version_number
--         is an exact match.
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Update_Row
( p_api_version           IN     NUMBER
, p_init_msg_list         IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit                IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level      IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status            OUT VARCHAR2
, x_msg_count                OUT NUMBER
, x_msg_data                 OUT VARCHAR2
, p_adr_rec               IN     AddrRec
, x_object_version_number    OUT NUMBER
);


--------------------------------------------------------------------------
-- Start of comments
--  API Name    : Delete_Row
--  Type        : Private
--  Description : Soft delete record in JTF_CAL_ADDRESSES table.
--  Pre-reqs    : None
--  Parameters  :
--      name                    direction  type     required?
--      ----                    ---------  ----     ---------
--      p_api_version           IN         NUMBER   required
--      p_init_msg_list         IN         VARCHAR2 optional
--      p_commit                IN         VARCHAR2 optional
--      p_validation_level      IN         NUMBER   optional
--      x_return_status            OUT     VARCHAR2 required
--      x_msg_count                OUT     NUMBER   required
--      x_msg_data                 OUT     VARCHAR2 required
--      p_address_id            IN         NUMBER   required
--      p_object_version_number IN         NUMBER   required
--
--  Version : Current  version 1.0
--            Previous version 1.0
--            Initial  version 1.0
--
--  Notes: An address can only be deleted if the object_version_number
--         is an exact match.
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Delete_Row
( p_api_version           IN     NUMBER
, p_init_msg_list         IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit                IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level      IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status            OUT VARCHAR2
, x_msg_count                OUT NUMBER
, x_msg_data                 OUT VARCHAR2
, p_address_id            IN     NUMBER
, p_object_version_number IN     NUMBER
);
END JTF_CAL_Addr_PVT;

 

/
