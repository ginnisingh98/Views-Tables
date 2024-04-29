--------------------------------------------------------
--  DDL for Package BOMPCCLT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOMPCCLT" AUTHID CURRENT_USER AS
/* $Header: BOMCCLTS.pls 120.4 2005/06/21 05:39:25 appldev ship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMCCLTS.pls
--
--  DESCRIPTION
--
--      Spec of package BOMPCCLT
--
--  NOTES
--
--   History:       Oct 6, 1997  ryee  Streamlined process.  Make only Process
--             Items public.
--      Aug 21, 1998 Mani  Added end_item_unit_number parameter for
--          Serial effectivity implementation.
--
***************************************************************************/

PROCEDURE process_items(
  org_id      IN NUMBER,
  roll_id     IN NUMBER,
  unit_number IN VARCHAR2,
  eff_date    IN DATE,
  prgm_id     IN NUMBER,
  prgm_app_id IN NUMBER,
  req_id      IN NUMBER,
  err_msg     IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2); -- encrypted message

   PROCEDURE process_items(
          p_org_id                IN NUMBER,
          p_item_id               IN NUMBER,
          p_roll_id               IN OUT NOCOPY NUMBER,
          p_unit_number           IN VARCHAR2,
          p_eff_date              IN DATE,
          p_alternate_bom_code    IN VARCHAR2,
          p_prgm_id               IN NUMBER,
          p_prgm_app_id           IN NUMBER,
          p_req_id                IN NUMBER,
          x_err_msg               IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

        PROCEDURE Delete_Processed_Rows
                  (p_rollup_id          IN  NUMBER);

END BOMPCCLT;

 

/
