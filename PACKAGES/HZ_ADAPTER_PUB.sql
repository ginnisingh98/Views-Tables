--------------------------------------------------------
--  DDL for Package HZ_ADAPTER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_ADAPTER_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHADPUS.pls 120.3 2004/05/17 06:51:32 dmmehta noship $*/

TYPE adapter_rec_type IS RECORD (
   adapter_id                  NUMBER
  ,adapter_content_source      VARCHAR2(30)
  ,adapter_meaning             VARCHAR2(80)
  ,adapter_description         VARCHAR2(240) DEFAULT NULL
  ,message_format_code         VARCHAR2(30)
  ,synchronous_flag            VARCHAR2(1) DEFAULT 'Y'
  ,invoke_method_code          VARCHAR2(30)
  ,host_address                VARCHAR2(240)
  ,enabled_flag                VARCHAR2(1) DEFAULT 'Y'
  ,maximum_batch_size          NUMBER
  ,default_batch_size          NUMBER
  ,default_replace_status_level VARCHAR2(30)
  ,username                    VARCHAR2(100)
  ,encrypted_password          VARCHAR2(100) );

TYPE adapter_terr_rec_type IS RECORD (
   adapter_id                  NUMBER
  ,territory_code              VARCHAR2(30)
  ,enabled_flag                VARCHAR2(1) DEFAULT 'Y'
  ,default_flag                VARCHAR2(1) );

-- This procedure create a record in location adapter by passing location adapter record type
PROCEDURE create_adapter (
   p_adapter_rec               IN adapter_rec_type
  ,x_adapter_id                OUT NOCOPY    NUMBER
  ,x_return_status             OUT NOCOPY    VARCHAR2
  ,x_msg_count                 OUT NOCOPY    NUMBER
  ,x_msg_data                  OUT NOCOPY    VARCHAR2 );

-- This procedure create a record in location adapter territory by passing
-- location adapter territory record type
PROCEDURE create_adapter_terr (
   p_adapter_terr_rec          IN adapter_terr_rec_type
  ,x_return_status             OUT NOCOPY    VARCHAR2
  ,x_msg_count                 OUT NOCOPY    NUMBER
  ,x_msg_data                  OUT NOCOPY    VARCHAR2 );

-- This procedure update a record in location adapater
 PROCEDURE update_adapter (
   p_adapter_rec               IN adapter_rec_type
  ,px_object_version_number    IN OUT NOCOPY NUMBER
  ,x_return_status             OUT NOCOPY    VARCHAR2
  ,x_msg_count                 OUT NOCOPY    NUMBER
  ,x_msg_data                  OUT NOCOPY    VARCHAR2 );

-- This procedure update a record in location adapter territory
 PROCEDURE update_adapter_terr (
   p_adapter_terr_rec          IN adapter_terr_rec_type
  ,px_object_version_number    IN OUT NOCOPY NUMBER
  ,x_return_status             OUT NOCOPY    VARCHAR2
  ,x_msg_count                 OUT NOCOPY    NUMBER
  ,x_msg_data                  OUT NOCOPY    VARCHAR2 );

PROCEDURE validate_adapter(
   p_create_update_flag        IN VARCHAR2,
   p_adapter_rec               IN adapter_rec_type,
   x_return_status             IN OUT NOCOPY VARCHAR2 );

PROCEDURE validate_adapter_terr(
   p_create_update_flag        IN VARCHAR2,
   p_adapter_terr_rec          IN adapter_terr_rec_type,
   x_return_status             IN OUT NOCOPY VARCHAR2 );

END HZ_ADAPTER_PUB;

 

/
