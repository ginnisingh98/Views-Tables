--------------------------------------------------------
--  DDL for Package AMS_MANUAL_LIST_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_MANUAL_LIST_GEN" AUTHID CURRENT_USER AS
/* $Header: amsvlmls.pls 120.0 2005/05/31 15:07:24 appldev noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'AMS_MANUAL_LIST_GEN';

TYPE primary_key_Tbl_Type  is table of number
    INDEX BY BINARY_INTEGER;
TYPE varchar2_Tbl_Type IS TABLE OF varchar2(400)
    INDEX BY BINARY_INTEGER;

TYPE child_type      IS TABLE OF VARCHAR2(80) INDEX  BY BINARY_INTEGER;

PROCEDURE process_manual_list(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_list_header_id    in  NUMBER,
   p_primary_key_tbl   IN  JTF_NUMBER_TABLE, --primary_key_Tbl_Type ,
   p_master_type       in   VARCHAR2,
   x_added_entry_count OUT NOCOPY NUMBER
);

--Wrapper API added for supporting contact list created from OSO
--bug 4348939
PROCEDURE process_manual_list(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_list_header_id    in  NUMBER,
   p_primary_key_tbl   IN  JTF_NUMBER_TABLE,--primary_key_Tbl_Type ,
   p_master_type       in  VARCHAR2
-- , x_added_entry_count OUT NOCOPY NUMBER --- manual entries changes added:musman
);

PROCEDURE process_employee_list(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_list_header_id    in  NUMBER,
   p_primary_key_tbl   IN  primary_key_Tbl_Type ,
   p_last_name_tbl     IN  varchar2_Tbl_Type ,
   p_first_name_tbl    IN  varchar2_Tbl_Type ,
   p_email_tbl         IN  varchar2_Tbl_Type ,
   p_master_type       in  VARCHAR2
) ;

END AMS_MANUAL_LIST_GEN ;

 

/
