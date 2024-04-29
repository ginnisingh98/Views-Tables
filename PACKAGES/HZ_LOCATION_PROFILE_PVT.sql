--------------------------------------------------------
--  DDL for Package HZ_LOCATION_PROFILE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_LOCATION_PROFILE_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHLCPVS.pls 120.1 2005/10/28 00:05:27 acng noship $*/

TYPE location_profile_rec_type IS RECORD (
   location_profile_id         NUMBER
  ,location_id                 NUMBER
  ,actual_content_source       VARCHAR2(30)
  ,effective_start_date        DATE
  ,effective_end_date          DATE
  ,validation_sst_flag         VARCHAR2(1)
  ,validation_status_code      VARCHAR2(30)
  ,date_validated              DATE
  ,address1                    VARCHAR2(240)
  ,address2                    VARCHAR2(240)
  ,address3                    VARCHAR2(240)
  ,address4                    VARCHAR2(240)
  ,city                        VARCHAR2(60)
  ,postal_code                 VARCHAR2(60)
  ,prov_state_admin_code       VARCHAR2(60)
  ,county                      VARCHAR2(60)
  ,country                     VARCHAR2(2) );

TYPE location_profile_tbl_type IS TABLE OF location_profile_rec_type INDEX BY BINARY_INTEGER;

-- This procedure create a record in location profile
PROCEDURE create_location_profile (
   p_init_msg_list             IN VARCHAR2 := FND_API.G_FALSE
  ,p_location_profile_rec      IN location_profile_rec_type
  ,x_location_profile_id       OUT NOCOPY    NUMBER
  ,x_return_status             OUT NOCOPY    VARCHAR2
  ,x_msg_count                 OUT NOCOPY    NUMBER
  ,x_msg_data                  OUT NOCOPY    VARCHAR2 );

-- This procedure update a record in location profile
PROCEDURE update_location_profile (
   p_init_msg_list             IN VARCHAR2 := FND_API.G_FALSE
  ,p_location_profile_rec      IN location_profile_rec_type
--  ,px_object_version_number    IN OUT NOCOPY NUMBER
  ,x_return_status             OUT NOCOPY    VARCHAR2
  ,x_msg_count                 OUT NOCOPY    NUMBER
  ,x_msg_data                  OUT NOCOPY    VARCHAR2 );

PROCEDURE validate_mandatory_column(
   p_create_update_flag        IN VARCHAR2
  ,p_location_profile_rec      IN location_profile_rec_type
  ,x_return_status             IN OUT NOCOPY VARCHAR2 );

PROCEDURE set_effective_end_date (
   p_location_profile_id       IN NUMBER
  ,x_return_status             IN OUT NOCOPY VARCHAR2 );

PROCEDURE set_validation_status_code(
   p_location_profile_id       IN NUMBER
  ,p_validation_status_code    IN VARCHAR2
  ,x_return_status             IN OUT NOCOPY VARCHAR2 );

END HZ_LOCATION_PROFILE_PVT;

 

/
