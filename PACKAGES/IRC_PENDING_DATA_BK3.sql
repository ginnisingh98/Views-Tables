--------------------------------------------------------
--  DDL for Package IRC_PENDING_DATA_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_PENDING_DATA_BK3" AUTHID CURRENT_USER as
/* $Header: iripdapi.pkh 120.7 2008/02/21 14:22:51 viviswan noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_PENDING_DATA_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_PENDING_DATA_b
  (p_pending_data_id              in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_PENDING_DATA_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_PENDING_DATA_a
  (p_pending_data_id              in     number
  );
--
end IRC_PENDING_DATA_BK3;

/
