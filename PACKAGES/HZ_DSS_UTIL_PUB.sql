--------------------------------------------------------
--  DDL for Package HZ_DSS_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_DSS_UTIL_PUB" AUTHID CURRENT_USER AS
/* $Header: ARHPDSUS.pls 120.5 2005/10/30 04:21:58 appldev noship $ */

 TYPE dss_group_rec IS RECORD (
       dss_group_code   VARCHAR2(30) ,
       entity_id        NUMBER
  );

  TYPE dss_group_tbl_type IS TABLE of dss_group_rec INDEX BY BINARY_INTEGER;

  FUNCTION test_instance (
     p_operation_code     IN    VARCHAR2,
     p_db_object_name     IN    VARCHAR2,
     p_instance_pk1_value IN    VARCHAR2,
     p_instance_pk2_value IN    VARCHAR2 DEFAULT NULL,
     p_instance_pk3_value IN    VARCHAR2 DEFAULT NULL,
     p_instance_pk4_value IN    VARCHAR2 DEFAULT NULL,
     p_instance_pk5_value IN    VARCHAR2 DEFAULT NULL,
     p_user_name          IN    VARCHAR2 DEFAULT NULL,
     x_return_status      OUT NOCOPY VARCHAR2,
     x_msg_count          OUT NOCOPY NUMBER,
     x_msg_data           OUT NOCOPY VARCHAR2,
     p_init_msg_list      IN    VARCHAR2 DEFAULT NULL
     ) RETURN VARCHAR2;

   PROCEDURE get_granted_groups (
     p_user_name         IN    VARCHAR2,
     p_operation_code    IN    VARCHAR2,
     x_granted_groups    OUT NOCOPY   dss_group_tbl_type,
     x_return_status     OUT NOCOPY VARCHAR2,
     x_msg_count         OUT NOCOPY NUMBER,
     x_msg_data          OUT NOCOPY VARCHAR2);

 FUNCTION determine_dss_group(
   p_db_object_name     IN VARCHAR2,
   p_object_pk1         IN VARCHAR2,
   p_object_pk2         IN VARCHAR2  DEFAULT NULL,
   p_object_pk3         IN VARCHAR2  DEFAULT NULL,
   p_object_pk4         IN VARCHAR2  DEFAULT NULL,
   p_object_pk5         IN VARCHAR2  DEFAULT NULL,
   p_root_db_object_name IN VARCHAR2 DEFAULT NULL,
   p_root_object_pk1     IN VARCHAR2 DEFAULT NULL,
   p_root_object_pk2     IN VARCHAR2 DEFAULT NULL,
   p_root_object_pk3     IN VARCHAR2 DEFAULT NULL,
   p_root_object_pk4     IN VARCHAR2 DEFAULT NULL,
   p_root_object_pk5     IN VARCHAR2 DEFAULT NULL
   ) RETURN VARCHAR2 ;

  PROCEDURE  assign_dss_group(
   p_db_object_name      IN VARCHAR2,
   p_object_pk1          IN VARCHAR2,
   p_object_pk2          IN VARCHAR2,
   p_object_pk3          IN VARCHAR2,
   p_object_pk4          IN VARCHAR2,
   p_object_pk5          IN VARCHAR2,
   p_root_db_object_name IN VARCHAR2,
   p_root_object_pk1     IN VARCHAR2,
   p_root_object_pk2     IN VARCHAR2,
   p_root_object_pk3     IN VARCHAR2,
   p_root_object_pk4     IN VARCHAR2,
   p_root_object_pk5     IN VARCHAR2,
   p_process_subentities_flag IN VARCHAR2);



PROCEDURE switch_context (p_user_name IN VARCHAR2,
                           x_return_status    OUT NOCOPY VARCHAR2,
                           x_msg_count        OUT NOCOPY NUMBER,
                           x_msg_data         OUT NOCOPY VARCHAR2);


 PROCEDURE generate_predicate(
   p_dss_group_code     IN VARCHAR2,
   p_entity_id          IN NUMBER,
   x_predicate          OUT NOCOPY VARCHAR2,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2);


/**
 * FUNCTION
 *          get_display_name
 *
 * DESCRIPTION
 *          return the display name of an object or an object instance set.
 *
 *
 * SCOPE - PUBLIC
 *
 * EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS  : IN:
 *                 p_object_name           object name
 *                 p_object_instance_name  object instance name
 *
 * RETURNS    : NONE
 *
 * NOTES
 *
 * MODIFICATION HISTORY -
 *
 */

FUNCTION get_display_name (
    p_object_name                 IN     VARCHAR2,
    p_object_instance_name        IN     VARCHAR2
) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(get_display_name, WNDS, WNPS);

END HZ_DSS_UTIL_PUB;

 

/
