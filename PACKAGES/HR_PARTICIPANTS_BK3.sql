--------------------------------------------------------
--  DDL for Package HR_PARTICIPANTS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PARTICIPANTS_BK3" AUTHID CURRENT_USER as
/* $Header: peparapi.pkh 120.2.12010000.2 2008/08/06 09:20:39 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_participant_b >--------------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_participant_b
	(
         p_participant_id          in   number,
         p_object_version_number   in   number
	);
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_participant_a >--------------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_participant_a
	(
          p_participant_id         in   number,
          p_object_version_number  in   number
	);

end hr_participants_bk3;

/
