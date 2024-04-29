--------------------------------------------------------
--  DDL for Package PO_PERIODS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PERIODS_SV" AUTHID CURRENT_USER as
-- $Header: POXCOPES.pls 120.0.12010000.2 2012/06/15 10:01:48 gjyothi ship $



-----------------------------------------------------------------------------
-- Public procedures.
-----------------------------------------------------------------------------

PROCEDURE get_period_info(
   p_roll_logic                     IN             VARCHAR2
,  p_set_of_books_id                IN             NUMBER
,  p_date_tbl                       IN             po_tbl_date
,  x_period_name_tbl                OUT NOCOPY     po_tbl_varchar30
,  x_period_year_tbl                OUT NOCOPY     po_tbl_number
,  x_period_num_tbl                 OUT NOCOPY     po_tbl_number
,  x_quarter_num_tbl                OUT NOCOPY     po_tbl_number
,  x_invalid_period_flag            OUT NOCOPY     VARCHAR2
);


PROCEDURE get_period_name(
   x_sob_id                         IN             NUMBER
,  x_gl_date                        IN             DATE
,  x_gl_period                      OUT NOCOPY     VARCHAR2
);

  --14178037 <GL DATE Project Start> Derive proper GL date, when the profile
  -- PO: Validate GL Period: Redefault has been set to Redefault.
  PROCEDURE get_gl_date(x_sob_id  IN NUMBER,
                        x_gl_date IN OUT NOCOPY po_tbl_date);


  PROCEDURE build_GL_Encumbered_Date(l_sob_id    IN NUMBER,
                                     x_gl_date   IN OUT NOCOPY DATE,
                                     x_gl_period OUT NOCOPY VARCHAR2);

  --14178037 <GL DATE Project End>


END PO_PERIODS_SV;

/
