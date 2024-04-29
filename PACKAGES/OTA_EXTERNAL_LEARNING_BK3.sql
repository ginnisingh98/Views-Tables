--------------------------------------------------------
--  DDL for Package OTA_EXTERNAL_LEARNING_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_EXTERNAL_LEARNING_BK3" AUTHID CURRENT_USER as
/* $Header: otnhsapi.pkh 120.2 2006/01/09 03:19:33 dbatra noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< <DELETE_EXTERNAL_LEARNING_b >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_external_learning_b
  (p_nota_history_id      in number
  ,p_object_version_number in number
  );


--
-- ----------------------------------------------------------------------------
-- |-------------------------< <DELETE_EXTERNAL_LEARNING_a >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_external_learning_a
  (p_nota_history_id        in number
  ,p_object_version_number  in number
  );
end OTA_EXTERNAL_LEARNING_BK3;

 

/
