--------------------------------------------------------
--  DDL for Package Body PO_CUSTOM_FUNDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CUSTOM_FUNDS_PKG" AS
  /* $Header: PO_CUSTOM_FUNDS_PKG.plb 120.0.12010000.3 2012/06/27 11:31:57 gjyothi noship $*/


  -- Custom hook to validate funds in an external financial system

  /* 14178037 <GL DATE Project Start> Custom hook to retrun the customer preferred GL Date, when the profile
  "PO: Validate GL Period" has been set to "Redefault".
  Pre-req: 1. This function will be called, when the "PO: Validate GL Period" and also the present
  GL Date or SYSTEM Date is not valid.
  2. Its Customer's reponsibility to enter a GL Date, which is in Open Period. */
  PROCEDURE GL_DATE(p_gl_encumbered_date IN OUT NOCOPY DATE,
                    p_gl_period          IN OUT NOCOPY VARCHAR2) IS
  BEGIN

    -- Presently returning the passed GL Date and Periods, as it is. Customer is supposed to write the
    -- Custom logic or add Custom Procedure to default his own GL Date.
    NULL;
  END;
  -- 14178037 <GL DATE Project End>

end PO_CUSTOM_FUNDS_PKG;


/
