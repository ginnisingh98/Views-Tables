--------------------------------------------------------
--  DDL for Package HR_PHONE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PHONE_BK3" AUTHID CURRENT_USER as
/* $Header: pephnapi.pkh 120.1.12010000.2 2009/03/12 10:03:48 dparthas ship $ */
--
-- ----------------------------------------------------------------------
-- |---------------------< delete_phone_b >------------------|
-- ---------------------------------------------------------------------
--
procedure delete_phone_b
  (p_phone_id                       in     number
  ,p_object_version_number          in     number
  );
--
-- ----------------------------------------------------------------------
-- |---------------------< delete_phone_a >------------------|
-- ----------------------------------------------------------------------
--
procedure delete_phone_a
  (p_phone_id                       in     number
  ,p_object_version_number          in     number
  ,P_PERSON_ID                      in     NUMBER
  );
end hr_phone_bk3;

/
