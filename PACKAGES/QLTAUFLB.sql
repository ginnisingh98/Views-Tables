--------------------------------------------------------
--  DDL for Package QLTAUFLB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QLTAUFLB" AUTHID CURRENT_USER AS
/* $Header: qltauflb.pls 120.2.12000000.1 2007/01/19 07:14:11 appldev ship $ */
--  Fill in missing elements/actions for an Inspection Plan.
-- 07/31/97
-- Munazza Bukhari

      --
      -- Bug 3926150 need to add a new out param.
      -- This proc is called from two places:
      -- QLTPLMDF.QP_TRANSACTIONS_CONTROL various procedures
      -- QASLSET.pld
      --
  FUNCTION auto_fill_missing_char (X_PLAN_ID NUMBER,
		X_COPY_PLAN_ID NUMBER,
		X_USER_ID NUMBER,
                X_DISABLED_INDEXED_ELEMENTS OUT NOCOPY VARCHAR2
		) RETURN NUMBER;

  FUNCTION add_ss_elements (p_plan_id NUMBER, p_user_id IN NUMBER)
    RETURN NUMBER;

--  Fill in missing elements for the action 'Create a work request'.
--  suramasw Fri Jun 21 00:42:03 PDT 2002

  PROCEDURE add_work_req_elements (p_plan_id IN NUMBER, p_user_id IN NUMBER);

 -- Bug 3517598. If lot/serial number is present in plan
 -- add LPN automatically. Function to add lpn to plan.

  FUNCTION auto_fill_lpn (X_PLAN_ID NUMBER,
				  X_USER_ID NUMBER
				  ) RETURN NUMBER;

   -- Bug 5147965 ksiddhar EAM Transaction Dependency Check
  FUNCTION auto_fill_missing_char_eam (X_PLAN_ID NUMBER,
		X_COPY_PLAN_ID NUMBER,
		X_USER_ID NUMBER
                 ) RETURN NUMBER;
   -- Bug 5147965 ksiddhar EAM Transaction Dependency Check
END QLTAUFLB;


 

/
