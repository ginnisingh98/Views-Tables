--------------------------------------------------------
--  DDL for Package HZ_MERGE_DUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_MERGE_DUP_PVT" AUTHID CURRENT_USER AS
/* $Header: ARHCMBAS.pls 115.9 2004/03/25 03:09:26 awu noship $ */

PROCEDURE Create_Merge_Batch(
  p_dup_set_id            IN NUMBER,
  p_default_mapping       IN VARCHAR2,
  p_object_version_number IN OUT NOCOPY  NUMBER,
  x_merge_batch_id        OUT NOCOPY NUMBER,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2 );

PROCEDURE map_detail_record(
  p_batch_party_id        IN NUMBER,
  p_entity                IN VARCHAR2,
  p_from_entity_id        IN NUMBER,
  p_to_entity_id          IN NUMBER,
  p_object_version_number IN OUT NOCOPY  NUMBER,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2 );

PROCEDURE map_within_party(
  p_batch_party_id        IN NUMBER,
  p_entity                IN VARCHAR2,
  p_from_entity_id        IN NUMBER,
  p_to_entity_id          IN NUMBER,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2);

PROCEDURE submit_batch(
  p_batch_id              IN NUMBER,
  p_preview               IN VARCHAR2,
  x_request_id            OUT NOCOPY NUMBER,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2 );

-- create records in dup batch, dup set and dup set parties
PROCEDURE suggested_defaults (
   p_batch_id                  IN      NUMBER
  ,x_return_status             OUT NOCOPY     VARCHAR2
  ,x_msg_count                 OUT NOCOPY     NUMBER
  ,x_msg_data                  OUT NOCOPY     VARCHAR2
);

PROCEDURE apply_suggested_default (
   p_batch_id                  IN      NUMBER
  ,p_entity_name               IN      VARCHAR2
  ,x_return_status             OUT NOCOPY     VARCHAR2
  ,x_msg_count                 OUT NOCOPY     NUMBER
  ,x_msg_data                  OUT NOCOPY     VARCHAR2
);

PROCEDURE clear_suggested_default (
   p_batch_id                  IN      NUMBER
  ,p_entity_name               IN      VARCHAR2
  ,p_merge_type                IN      VARCHAR2
  ,x_return_status             OUT NOCOPY     VARCHAR2
  ,x_msg_count                 OUT NOCOPY     NUMBER
  ,x_msg_data                  OUT NOCOPY     VARCHAR2
);

PROCEDURE suggested_party_sites (
   p_batch_id                  IN      NUMBER
  ,p_merge_type                IN      VARCHAR2
  ,p_rule_id                   IN      NUMBER
);

PROCEDURE suggested_party_reln (
   p_batch_id                  IN      NUMBER
  ,p_merge_type                IN      VARCHAR2
  ,p_rule_id                   IN      NUMBER
);

PROCEDURE create_reln_sysbatch (
   p_batch_id                  IN      NUMBER
  ,p_merge_type                IN      VARCHAR2
  ,x_return_status             OUT NOCOPY     VARCHAR2
  ,x_msg_count                 OUT NOCOPY     NUMBER
  ,x_msg_data                  OUT NOCOPY     VARCHAR2
);

PROCEDURE delete_mapping (
   p_batch_id                  IN      NUMBER
  ,p_merge_type                IN      VARCHAR2
  ,x_return_status             OUT NOCOPY     VARCHAR2
  ,x_msg_count                 OUT NOCOPY     NUMBER
  ,x_msg_data                  OUT NOCOPY     VARCHAR2
);

PROCEDURE unmap_child_records(
  p_merge_batch_id        IN NUMBER,
  p_entity                IN VARCHAR2,
  p_entity_id             IN NUMBER,
  p_merge_type            IN VARCHAR2,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2
);
-- If it has been called from DL project, pass in p_dup_set_id
-- if it has been called from party merge concurrent, pass in merge_batch_id only
-- and pass in null for p_dup_set_id
procedure validate_overlapping_merge_req(
  p_dup_set_id            IN NUMBER,
  p_merge_batch_id        IN NUMBER,
  p_init_msg_list         IN VARCHAR2,
  p_reject_req_flag       IN VARCHAR2,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2 );

-- Only called from Data Librarian UI
function is_acct_site_merge_required(p_merge_batch_id in number) return varchar2;

-- Only called from Data Librarian UI
procedure site_merge_warning(
  p_merge_batch_id        IN NUMBER,
  p_generate_note_flag    IN VARCHAR2,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2 );

END HZ_MERGE_DUP_PVT;

 

/
