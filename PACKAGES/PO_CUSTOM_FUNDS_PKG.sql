--------------------------------------------------------
--  DDL for Package PO_CUSTOM_FUNDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CUSTOM_FUNDS_PKG" AUTHID CURRENT_USER AS
  /* $Header: PO_CUSTOM_FUNDS_PKG.pls 120.0.12010000.2 2012/06/27 10:45:17 gjyothi noship $*/

/* 14178037 <GL DATE Project Start> Custom hook to retrun the customer preferred GL Date, when the profile
  "PO: Validate GL Period" has been set to "Redefault". */

 PROCEDURE GL_DATE(p_gl_encumbered_date IN OUT NOCOPY DATE,
                    p_gl_period          IN OUT NOCOPY VARCHAR2);

end PO_CUSTOM_FUNDS_PKG  ;

/
