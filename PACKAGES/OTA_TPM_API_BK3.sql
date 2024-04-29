--------------------------------------------------------
--  DDL for Package OTA_TPM_API_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TPM_API_BK3" AUTHID CURRENT_USER as
/* $Header: ottpmapi.pkh 120.1 2005/10/02 02:08:35 aroussel $ */

-- ----------------------------------------------------------------------------
-- |-------------------------< delete_training_plan_member_b >----------------|
-- ----------------------------------------------------------------------------
procedure delete_training_plan_member_b
  (p_training_plan_member_id       in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_training_plan_member_a >----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_training_plan_member_a
  (p_training_plan_member_id       in     number
  ,p_object_version_number         in     number
  );
--
end ota_tpm_api_bk3;

 

/
