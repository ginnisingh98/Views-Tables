--------------------------------------------------------
--  DDL for Package IGS_SC_GRANTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_SC_GRANTS_PVT" AUTHID CURRENT_USER AS
/* $Header: IGSSC01S.pls 120.1 2005/07/22 07:03:24 appldev ship $ */

/******************************************************************

    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
                         All rights reserved.

 Created By         : Arkadi Tereshenkov

 Date Created By    : Oct-01-2002

 Purpose            : Grant processing package

 remarks            : None

 Change History

Who                   When           What
-----------------------------------------------------------
Arkadi Tereshenkov    Apr-10-2002    New Package created.

******************************************************************/



-- ------------------------------------------------------------------
-- Main procedure
-- ------------------------------------------------------------------
PROCEDURE generate_grant(
  p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER   := FND_API.G_VALID_LEVEL_NONE,
  p_object_name       IN   VARCHAR2,
  p_function_type     IN   VARCHAR2,
  x_where_clause      OUT NOCOPY VARCHAR2,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2
);

PROCEDURE construct_grant(
  p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER   := FND_API.G_VALID_LEVEL_NONE,
  p_grant_id          IN   NUMBER,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2
);


FUNCTION generate_grant(
  p_object_name       IN   VARCHAR2,
  p_function_type     IN   VARCHAR2
) RETURN VARCHAR2;


-- PRAGMA RESTRICT_REFERENCES(generate_grant,WNDS);

PROCEDURE set_ctx(
  p_name VARCHAR2,
  p_val  VARCHAR2
);


PROCEDURE populate_user_attrib(
  p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER   := FND_API.G_VALID_LEVEL_NONE,
  p_attrib_id         IN   NUMBER   := NULL,
  p_user_id           IN   NUMBER   := NULL,
  p_all_attribs       IN   VARCHAR2 :='N',
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2
);


PROCEDURE unlock_all_grants(
  p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER   := FND_API.G_VALID_LEVEL_NONE,
  p_conc_program_flag IN   VARCHAR2 := FND_API.G_FALSE,
  p_disable_security  IN   VARCHAR2 := FND_API.G_FALSE,
  p_obj_group_id      IN   NUMBER,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2
);

PROCEDURE lock_all_grants(
  p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER   := FND_API.G_VALID_LEVEL_NONE,
  p_conc_program_flag IN   VARCHAR2 := FND_API.G_FALSE,
  p_obj_group_id      IN   NUMBER,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2
);



-- Returns current user id for attribute generation function
FUNCTION get_current_user
RETURN NUMBER;

-- Returns current party id for attribute generation function
FUNCTION get_current_party
RETURN NUMBER;

--Check if admin mode enabled for the curretn installation
FUNCTION admin_mode
RETURN VARCHAR2;

PROCEDURE Generate_Message;

FUNCTION check_grant_text (
  p_table_name VARCHAR2,
  p_select_text VARCHAR2)
RETURN BOOLEAN;

PROCEDURE run_diagnostic(
  p_dirpath           IN   VARCHAR2,
  p_file_name         IN   VARCHAR2,
  p_log_level         IN   VARCHAR2,
  p_user_id           IN   NUMBER := -1,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2
);


FUNCTION check_attrib_text (
  p_table_name VARCHAR2,
  p_select_text VARCHAR2,
  p_obj_attrib_type VARCHAR2 )

RETURN BOOLEAN ;

FUNCTION getBodmasCondition(p_cond VARCHAR2) RETURN VARCHAR2;


END IGS_SC_GRANTS_PVT;

 

/
