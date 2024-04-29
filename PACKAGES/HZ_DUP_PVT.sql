--------------------------------------------------------
--  DDL for Package HZ_DUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_DUP_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHDUPBS.pls 120.16.12010000.3 2009/10/28 18:00:19 awu ship $*/

-- all candidates, except master party_id in a dup set
TYPE dup_party_rec_type IS RECORD (
   party_id                    NUMBER
  ,score                       NUMBER
  ,merge_flag                  VARCHAR2(1)
  ,not_dup                     VARCHAR2(1)
  ,merge_seq_id                NUMBER
  ,merge_batch_id              NUMBER
  ,merge_batch_name            VARCHAR2(30) );

TYPE dup_party_tbl_type IS TABLE OF dup_party_rec_type INDEX BY BINARY_INTEGER;

-- dup batch record
TYPE dup_batch_rec_type IS RECORD (
   dup_batch_name              VARCHAR2(255)
  ,match_rule_id               NUMBER
  ,application_id              NUMBER
  ,request_type                VARCHAR2(30) );

-- dup set and dup set parties record
TYPE dup_set_rec_type IS RECORD (
   dup_batch_id                NUMBER
  ,winner_party_id             NUMBER
  ,status                      VARCHAR2(60)
  ,assigned_to_user_id         NUMBER
  ,merge_type                  VARCHAR2(30) );

-- This procedure create one dup batch, one dup set and one dup set party record
PROCEDURE create_dup (
   dup_batch_name              IN      VARCHAR2
  ,match_rule_id               IN      NUMBER
  ,application_id              IN      NUMBER
  ,request_type                IN      VARCHAR2
  ,winner_party_id             IN      NUMBER
  ,status                      IN      VARCHAR2
  ,assigned_to_user_id         IN      NUMBER DEFAULT NULL
  ,merge_type                  IN      VARCHAR2
  ,party_id                    IN      NUMBER DEFAULT NULL
  ,score                       IN      NUMBER DEFAULT 0
  ,merge_flag                  IN      VARCHAR2 DEFAULT 'Y'
  ,not_dup                     IN      VARCHAR2 DEFAULT NULL
  ,merge_seq_id                IN      NUMBER DEFAULT NULL
  ,merge_batch_id              IN      NUMBER DEFAULT NULL
  ,merge_batch_name            IN      VARCHAR2 DEFAULT NULL
  ,x_dup_batch_id              OUT NOCOPY     NUMBER
  ,x_dup_set_id                OUT NOCOPY    NUMBER
  ,x_return_status             OUT NOCOPY    VARCHAR2
  ,x_msg_count                 OUT NOCOPY    NUMBER
  ,x_msg_data                  OUT NOCOPY    VARCHAR2 );

-- This procedure create only dup set party record
PROCEDURE create_dup_set_party (
   p_dup_set_id                IN      NUMBER
  ,p_dup_set_party_id          IN      NUMBER
  ,p_score                     IN      NUMBER DEFAULT 0
  ,p_merge_flag                IN      VARCHAR2 DEFAULT 'Y'
  ,p_not_dup                   IN      VARCHAR2 DEFAULT NULL
  ,p_merge_seq_id              IN      NUMBER DEFAULT NULL
  ,p_merge_batch_id            IN      NUMBER DEFAULT NULL
  ,p_merge_batch_name          IN      VARCHAR2 DEFAULT NULL
  ,x_return_status             OUT NOCOPY     VARCHAR2
  ,x_msg_count                 OUT NOCOPY     NUMBER
  ,x_msg_data                  OUT NOCOPY     VARCHAR2 );

-- create records in dup set and dup set parties based on existing dup_batch
PROCEDURE create_dup_set (
   p_dup_set_rec               IN      DUP_SET_REC_TYPE
  ,p_dup_party_tbl             IN      DUP_PARTY_TBL_TYPE
  ,x_dup_set_id                OUT NOCOPY     NUMBER
  ,x_return_status             OUT NOCOPY     VARCHAR2
  ,x_msg_count                 OUT NOCOPY     NUMBER
  ,x_msg_data                  OUT NOCOPY     VARCHAR2 );

-- create records in dup batch, dup_set and dup_set_parties
PROCEDURE create_dup_batch (
   p_dup_batch_rec             IN      DUP_BATCH_REC_TYPE
  ,p_dup_set_rec               IN      DUP_SET_REC_TYPE
  ,p_dup_party_tbl             IN      DUP_PARTY_TBL_TYPE
  ,x_dup_batch_id              OUT NOCOPY     NUMBER
  ,x_dup_set_id                OUT NOCOPY     NUMBER
  ,x_return_status             OUT NOCOPY     VARCHAR2
  ,x_msg_count                 OUT NOCOPY     NUMBER
  ,x_msg_data                  OUT NOCOPY     VARCHAR2 );

-- update winner_party_id in HZ_DUP_SETS table
PROCEDURE update_winner_party (
   p_dup_set_id                IN      NUMBER
  ,p_winner_party_id           IN      NUMBER
  ,px_set_obj_version_number   IN OUT NOCOPY  NUMBER
  ,x_return_status             OUT NOCOPY     VARCHAR2
  ,x_msg_count                 OUT NOCOPY     NUMBER
  ,x_msg_data                  OUT NOCOPY     VARCHAR2 );

-- remove candidate in HZ_DUP_SETS table
PROCEDURE delete_dup_party (
   p_dup_set_id                IN      NUMBER
  ,p_dup_party_id              IN      NUMBER
  ,p_new_winner_party_id       IN      NUMBER
  ,px_set_obj_version_number   IN OUT NOCOPY NUMBER
  ,x_return_status             OUT NOCOPY     VARCHAR2
  ,x_msg_count                 OUT NOCOPY     NUMBER
  ,x_msg_data                  OUT NOCOPY     VARCHAR2 );

-- restamp merge_type and hard delete candidates in HZ_DUP_SET_PARTIES table
PROCEDURE reset_merge_type (
   p_dup_set_id                IN      NUMBER
  ,px_set_obj_version_number   IN OUT NOCOPY NUMBER
  ,x_return_status             OUT NOCOPY    VARCHAR2
  ,x_msg_count                 OUT NOCOPY    NUMBER
  ,x_msg_data                  OUT NOCOPY    VARCHAR2 );

-- reject merge request
PROCEDURE reject_merge (
   p_dup_set_id                IN      NUMBER
  ,px_set_obj_version_number   IN OUT NOCOPY NUMBER
  ,p_init_msg_list             IN      VARCHAR2 := FND_API.G_TRUE
  ,x_return_status             OUT  NOCOPY   VARCHAR2
  ,x_msg_count                 OUT  NOCOPY   NUMBER
  ,x_msg_data                  OUT  NOCOPY   VARCHAR2 );

-- call concurrent program - create_merge
PROCEDURE submit_dup (
   p_dup_set_id        IN NUMBER
  ,x_request_id       OUT NOCOPY NUMBER
  ,x_return_status    OUT NOCOPY VARCHAR2
  ,x_msg_count        OUT NOCOPY NUMBER
  ,x_msg_data         OUT NOCOPY VARCHAR2 );

-- concurrent program to create merge base on dup_set_id
PROCEDURE create_merge (
   Errbuf                      OUT NOCOPY    VARCHAR2
  ,Retcode                     OUT NOCOPY    VARCHAR2
  ,p_dup_set_id                IN      NUMBER );

-- called by Data Librarian UI. Default master based on the profile.
-- Dup set has to be created first with random winner party, then change
-- winner party id to the one based on defaulting rule.

procedure default_master(
 p_dup_set_id            IN NUMBER,
 x_master_party_id        OUT NOCOPY NUMBER,
 x_master_party_name     OUT NOCOPY VARCHAR2,
 x_return_status         OUT NOCOPY VARCHAR2,
 x_msg_count             OUT NOCOPY NUMBER,
 x_msg_data              OUT NOCOPY VARCHAR2 );


PROCEDURE validate_party_modeling( p_party_ids    IN   VARCHAR2,
                                   x_cert_warn     OUT NOCOPY VARCHAR2,
				   x_reln_warn     OUT NOCOPY VARCHAR2,
				   x_reln_token    OUT NOCOPY VARCHAR2
				 );
FUNCTION get_automerge_candidate(p_party_score NUMBER, p_automerge_score NUMBER)
		RETURN VARCHAR2;

procedure party_merge_dss_check(p_merge_batch_id in number,
			    x_dss_update_flag out nocopy varchar2,
			    x_return_status   OUT NOCOPY VARCHAR2,
  			    x_msg_count       OUT NOCOPY NUMBER,
  			    x_msg_data        OUT NOCOPY VARCHAR2 );

function show_dss_lock(p_dup_set_id in number) return varchar2;
FUNCTION get_update_flag(x_dup_set_id NUMBER) RETURN VARCHAR2;

PROCEDURE reprocess_merge_request (
   p_dup_set_id        IN NUMBER
  ,x_request_id       OUT NOCOPY NUMBER
  ,x_return_status    OUT NOCOPY VARCHAR2
  ,x_msg_count        OUT NOCOPY NUMBER
  ,x_msg_data         OUT NOCOPY VARCHAR2 );

procedure reset_dup_set_status;

procedure get_match_rule_thresholds(p_match_rule_id in number,
				    x_match_threshold out nocopy number,
				    x_automerge_threshold out nocopy number);

procedure get_most_matching_party(p_search_ctx_id in number,
				  p_new_party_id in number,
				       x_party_id out nocopy number,
				       x_match_score out nocopy number,
				       x_party_name out nocopy varchar2);
procedure validate_master_party_id(px_party_id in out nocopy number,
				   x_overlap_merge_req_id out nocopy number);

END HZ_DUP_PVT;

/
