--------------------------------------------------------
--  DDL for Package PV_USER_ROLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_USER_ROLE_PVT" AUTHID CURRENT_USER AS
 /* $Header: pvxvrols.pls 115.5 2002/12/19 00:51:15 rmikkili ship $ */

G_FILE_NAME  CONSTANT VARCHAR2(15) := 'pvxvrols.pls';


PROCEDURE ASSIGN_DEF_ROLES(
   p_api_version_number       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full
  ,P_USERNAME          in  VARCHAR2
  ,P_USERTYPE          in VARCHAR
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  );



END PV_USER_ROLE_PVT;

 

/
