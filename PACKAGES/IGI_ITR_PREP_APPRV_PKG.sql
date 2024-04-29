--------------------------------------------------------
--  DDL for Package IGI_ITR_PREP_APPRV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_ITR_PREP_APPRV_PKG" AUTHID CURRENT_USER as
-- $Header: igiitrus.pls 120.4.12010000.2 2008/08/04 13:04:36 sasukuma ship $
--

  --
  --	Public variables
  --
   diagn_msg_flag	BOOLEAN := TRUE;    -- Determines if diagnostic messages are displayed
  --
  --  Procedure can_preparer_approve
  --

  PROCEDURE can_preparer_approve
                                 (p_cc_id NUMBER
                                 ,p_cc_line_num NUMBER
                                 ,p_preparer_fnd_user_id NUMBER
                                 ,p_sob_id NUMBER
                                 ,p_prep_can_approve OUT NOCOPY VARCHAR2);



END IGI_ITR_PREP_APPRV_PKG;

/
