--------------------------------------------------------
--  DDL for Package Body GME_ERES_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_ERES_UTILS" AS
/* $Header: GMEERESB.pls 120.2 2005/07/17 21:32:52 jsrivast noship $ */
/*
REM **********************************************************************
REM *                                                                    *
REM * FILE:    GMEERESB.pls                                              *
REM * PURPOSE: Package Body for the GME ERES_UTILS routines              *
REM *          It contens all the routines to support the ERES output    *
REM *          during XML mapping, used by gateway product.              *
REM * AUTHOR:  Shrikant Nene, OPM Development                            *
REM * DATE:    August 18th 2002                                          *
REM **********************************************************************
* This file contains the procedure for create batch steps in Oracle      *
* Process Manufacturing (OPM). Each procedure has a common set of        *
* parameters to which API-specific parameters are appended.              *
*************************************************************************/

   PROCEDURE get_phantom_or_not (p_batch_id IN NUMBER, x_phantom OUT NOCOPY VARCHAR2)
   IS
      CURSOR cur_get_phant IS
       SELECT count(1)
       FROM   gme_material_details
       WHERE  phantom_id = p_batch_id
       AND    ROWNUM     = 1;

      l_exists              NUMBER;
   BEGIN
      OPEN  cur_get_phant;
      FETCH cur_get_phant INTO l_exists;
      CLOSE cur_get_phant;

      IF l_exists > 0 THEN
         x_phantom := fnd_message.get_string('GME','GME_PHANTOM');
      ELSE
         x_phantom := NULL;
      END IF;
   END get_phantom_or_not;

   /* This procedure returns the plant code and batch number for a
      given batch_id */
   PROCEDURE get_batch_number (
      p_batch_id       IN              NUMBER
     ,x_batch_number   OUT NOCOPY      VARCHAR2)
   IS
      CURSOR get_doc_number (v_batch_id IN NUMBER)
      IS
         SELECT organization_code || ' ' || batch_no
         FROM   gme_batch_header_vw
         WHERE  batch_id = v_batch_id;
   BEGIN
      OPEN  get_doc_number (p_batch_id);
      FETCH get_doc_number INTO x_batch_number;
      CLOSE get_doc_number;
   END get_batch_number;
END gme_eres_utils;

/
