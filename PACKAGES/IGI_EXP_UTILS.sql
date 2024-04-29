--------------------------------------------------------
--  DDL for Package IGI_EXP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_EXP_UTILS" AUTHID CURRENT_USER AS
-- $Header: igiexpqs.pls 120.4.12000000.2 2007/09/21 07:10:50 dvjoshi ship $
   --

   --
   -- Procedure
   --   Generate_Number
   -- Purpose
   --   Generates DU/TU Order/Legal Numbers
   -- History
   --   27-NOV-2001 L Silveira  Initial Version
   --
   PROCEDURE Generate_Number(pi_number_type   IN  VARCHAR2,
                             pi_number_class  IN  VARCHAR2,
                             pi_du_tu_type_id IN  NUMBER,
                             pi_fiscal_year   IN  NUMBER,
                             po_du_tu_number  OUT NOCOPY VARCHAR2,
                             po_error_message OUT NOCOPY VARCHAR2
                            );

   --
   -- Procedure
   --   Get Fiscal Year
   -- Purpose
   --   Gets the fiscal year corresponding to the passed date
   -- History
   --   03-DEC-2001 L Silveira  Initial Version
   --
   PROCEDURE Get_Fiscal_Year(pi_gl_date       IN  DATE,
                             po_fiscal_year   OUT NOCOPY NUMBER,
                             po_error_message OUT NOCOPY VARCHAR2
                            );


   --
   -- Procedure
   --   ValidateGLDate
   -- Purpose
   --  Validates whether a date passed existed in the current open period
   --  If not, checks if the date exists within the last open period
   --  If not assign date to sysdate
   --  If p_app_id = 200, checks if encumbrance is  on, if so, checks if
   --  the period year is greater than then encumbrance year.  If so,
   --  set the p_update_gl_date falg to 'N'.
   -- History
   --   11-DEC-2001 A Smales  Initial Version
   --
   PROCEDURE ValidateGLDate(p_app_id          IN      VARCHAR2,
                            p_gl_date         IN OUT NOCOPY  DATE,
                            p_update_gl_date  OUT NOCOPY     VARCHAR2,
                            p_du_id           IN             VARCHAR2
                            );


   --
   -- Procedure
   --   CompleteDU
   -- Purpose
   --   Completes the DU passed from EXP Workflow
   -- History
   --   11-DEC-2001 A Smales  Initial Version
   --
   PROCEDURE Complete_Du (p_du_id         IN      NUMBER,
                          p_app_id        IN      NUMBER,
                          p_gl_date       IN  OUT NOCOPY DATE,
                          p_error_message IN  OUT NOCOPY VARCHAR2,
                          p_trx_id        OUT NOCOPY     NUMBER
                          );



END igi_exp_utils;

 

/
