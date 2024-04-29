--------------------------------------------------------
--  DDL for Package FND_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_DRT_PKG" AUTHID CURRENT_USER as
/* $Header: AFSCDRTS.pls 120.0.12010000.5 2019/02/27 22:18:38 rarmaly noship $ */
----------------------------------------------------------------------------
--
-- fnd_user_drc (PUBLIC)
--
-- Data Removal Constraint API for person type : FND User
-- Determines impact of deleting a record associated with an FND User
--
-- Input:
-- USER_ID	ID for FND User to be removed
--
-- Output:
-- RESULT_TBL	Output result table on return from the procedure
--
-- 	PERSON_ID		TCA party ID, HR person ID, or FND user ID
-- 	ENTITY_TYPE	Person type, could be 'TCA', 'HR', or 'FND'
-- 	Status		"E" for Error, user data cannot be removed
--				due to a specified constraint.
--				"W" for Warning, impact of removing user data is not
--				significant.
--				Warnings may be ignored to choose data removal.
--				"S" for Success, no constraints on user data removal.
-- 	MSGCODE		one message code per constraint
-- 	MSGAPLID		Application ID associated with the message
--
procedure fnd_user_drc(
  p_user_id IN NUMBER,
  result_tbl OUT nocopy per_drt_pkg.result_tbl_type );

----------------------------------------------------------------------------
--
-- fnd_user_post (PUBLIC)
--
-- Data Removal Post Processing API for person type : FND User
-- Permanently masks or removes FND-PII (personal identifiable information)
-- of data linked to the USER_NAME in the FND_USER table and the USER_NAME
-- will become available for reuse.  The masked user name is propagated
-- to fnd dictionary objects with FND_USER.USER_NAME foreign key
-- The USER_ID will be end-dated and not be reusable,
-- and FND_GRANTS are end-dated for the FND User.
-- The OID user name linked to the EBS user will be masked.
-- Business events associated with FND user update are raised.
--
-- Input:
-- USER_ID	ID for FND User to be removed
--
procedure fnd_user_post(
  p_user_id IN NUMBER);

----------------------------------------------------------------------------
--
-- remove_user_name (PUBLIC)
--   This api changes username, synchronizes changes with LDAP and WF
--   and updates foreign keys that were using the old username.
--
-- Input:
-- OLD_USER_NAME Old FND User name
-- NEW_USER_NAME New FND User name
--
PROCEDURE remove_user_name(x_old_user_name            in varchar2,
                           x_new_user_name            in varchar2);

----------------------------------------------------------------------------
--
-- mask_pii_user (PUBLIC)
--
-- Permanently masks or removes FND-PII (personal identifiable information)
-- of data linked to the USER_NAME in the FND_USER table and the USER_NAME
-- will become available for reuse.  The masked user name is propagated
-- to fnd dictionary objects with FND_USER.USER_NAME foreign key
-- The USER_ID will be end-dated and not be reusable,
-- and FND_GRANTS are end-dated for the FND User.
-- The OID user name linked to the EBS user will be masked.
-- Business events associated with FND user update are raised.
--
-- Input:
-- user_name		FND Username
--
-- Return codes:
-- PIISUCC CONSTANT number := 0; /* Everything completed successfully */
-- PIINOUSR CONSTANT number := -1; /* The USER didn't exist on FND_USER */
-- PIIWFPED CONSTANT number := -2; /* The USER has pending workflow  */
-- PIIWFPROP CONSTANT number := -3; /* Error at wf_local_synch.propagate_user */
-- PIIUERR CONSTANT number := -4; /* Unexpected Error */
--
  FUNCTION mask_pii_user(
           x_user_name VARCHAR2) RETURN number;

/* mask_pii_user return codes */
 PIISUCC CONSTANT number := 0; /* Everything completed successfully */
 PIINOUSR CONSTANT number := -1; /* The USER didn't exist on FND_USER */
 PIIWFPED CONSTANT number := -2; /* The USER has pending workflow  */
 PIIWFPROP CONSTANT number := -3; /* Error at wf_local_synch.propagate_user */
 PIIUERR CONSTANT number := -4; /* Unexpected Error */

end FND_DRT_PKG;

/
