--------------------------------------------------------
--  DDL for Package EGO_POST_PROCESS_MESSAGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_POST_PROCESS_MESSAGE_PVT" AUTHID CURRENT_USER AS
/* $Header: EGOVPPMS.pls 120.3 2007/06/20 13:08:16 bbpatel noship $ */

  -- Message type constants
  G_CIC_REVIEW_MESSAGE_TYPE             CONSTANT  VARCHAR2(240)   :=  'REVIEW';
  G_CIC_SYNC_MESSAGE_TYPE               CONSTANT  VARCHAR2(240)   :=  'SYNCHRONISED';
  G_CIC_REJECTED_MESSAGE_TYPE           CONSTANT  VARCHAR2(240)   :=  'REJECTED';
  G_CIC_ACCEPTED_MESSAGE_TYPE           CONSTANT  VARCHAR2(240)   :=  'ACCEPTED';
  G_DATE_FORMAT                         CONSTANT  VARCHAR2(50)    :=  'DD-MON-YYYY HH24:MI:SS';

  PROCEDURE  Get_Canonical_CIC_Multi
              (
                  p_version                     IN          VARCHAR2
                 ,p_entity_name                 IN          VARCHAR2
                 ,p_pk1_value                   IN          VARCHAR2
                 ,p_pk2_value                   IN          VARCHAR2
                 ,p_pk3_value                   IN          VARCHAR2
                 ,p_pk4_value                   IN          VARCHAR2
                 ,p_pk5_value                   IN          VARCHAR2
                , p_message_status              IN          VARCHAR2
                , p_language_code               IN          VARCHAR2
                , p_start_index                 IN          NUMBER
                , p_bundles_window_size         IN          NUMBER
                , p_last_update_date            IN          VARCHAR2
                , x_canonical_cic_payload       OUT NOCOPY  XMLTYPE
                , x_bundles_processed_count     OUT NOCOPY  NUMBER
                , x_remaining_bundles_count     OUT NOCOPY  NUMBER
                , x_return_status               OUT NOCOPY  VARCHAR2
                , x_msg_data                    OUT NOCOPY  VARCHAR2
              );

  PROCEDURE  Update_Message_Sent_Info_Multi
              (
                  p_version                     IN          VARCHAR2
                 ,p_entity_name                 IN          VARCHAR2
                 ,p_pk1_value                   IN          VARCHAR2
                 ,p_pk2_value                   IN          VARCHAR2
                 ,p_pk3_value                   IN          VARCHAR2
                 ,p_pk4_value                   IN          VARCHAR2
                 ,p_pk5_value                   IN          VARCHAR2
                , p_message_status              IN          VARCHAR2
                , p_start_index                 IN          NUMBER
                , p_bundles_window_size         IN          NUMBER
                , p_commit_flag                 IN          VARCHAR2
                , p_last_update_date            IN          VARCHAR2
                , x_return_status               OUT NOCOPY  VARCHAR2
                , x_msg_data                    OUT NOCOPY  VARCHAR2
              );

  PROCEDURE  Update_Corrective_Info
              (
                  p_bundle_id_tbl               IN          EGO_VARCHAR_TBL_TYPE
                , p_source_system_id_tbl        IN          EGO_VARCHAR_TBL_TYPE
                , p_source_system_ref_tbl       IN          EGO_VARCHAR_TBL_TYPE
                , p_message_type_code           IN          VARCHAR2
                , p_status_code                 IN          VARCHAR2
                , p_corrective_action_code      IN          VARCHAR2
                , p_additional_info             IN          VARCHAR2
                , p_last_update_date            IN          VARCHAR2
                , x_last_update_date            OUT NOCOPY  VARCHAR2
                , x_return_status               OUT NOCOPY  VARCHAR2
                , x_msg_data                    OUT NOCOPY  VARCHAR2
              );

  PROCEDURE  Send_Sync_Msg_On_Batch_Import
              (
                  p_batch_id                    IN          NUMBER
                , p_request_id                  IN          NUMBER
                , p_commit_flag                 IN          VARCHAR2
                , x_return_status               OUT NOCOPY  VARCHAR2
                , x_msg_data                    OUT NOCOPY  VARCHAR2
              );

END EGO_POST_PROCESS_MESSAGE_PVT;

/
