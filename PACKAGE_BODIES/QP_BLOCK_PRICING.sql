--------------------------------------------------------
--  DDL for Package Body QP_BLOCK_PRICING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_BLOCK_PRICING" AS
/* $Header: QPXPCCFB.pls 120.2 2005/10/06 18:52:13 hwong noship $ */
  FUNCTION Enabled
    RETURN VARCHAR2
  IS
  BEGIN
    IF qp_code_control.get_code_release_level > '110508' THEN
      RETURN 'Y';
    END IF;
    RETURN 'N';
  END;
END QP_Block_Pricing;

/
