--------------------------------------------------------
--  DDL for Package GMF_COPY_PERCENTAGE_BURDEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_COPY_PERCENTAGE_BURDEN" AUTHID CURRENT_USER AS
/* $Header: gmfcppbs.pls 120.2 2005/08/18 02:59:06 anthiyag noship $ */

/*****************************************************************************
 *  PACKAGE
 *    GMF_COPY_PERCENTAGE_BURDEN
 *
 *  DESCRIPTION
 *    Copy Percentage Burdens
 *
 *  CONTENTS
 *    PROCEDURE	copy_percentage_burden ( ... )
 *
 *  HISTORY
 *    13-Oct-1999    Uday Moogala	      Created.
 *    30-OCT-2002    RajaSekhar           Bug#2641405 Added NOCOPY hint.
 *    1-jul-2005     Anand Thiyagarajan   Bug#4429329
 ******************************************************************************/

   PROCEDURE copy_percentage_burden
   (
   po_errbuf		                     OUT NOCOPY     VARCHAR2,
   po_retcode		                     OUT NOCOPY     VARCHAR2,
   pi_legal_entity_id_from          IN                gmf_burden_percentages.legal_entity_id%TYPE,
   pi_calendar_code_from            IN                cm_cldr_hdr.calendar_code%TYPE,
   pi_period_code_from              IN                cm_cldr_dtl.period_code%TYPE,
   pi_cost_type_id_from             IN                cm_mthd_mst.cost_type_id%TYPE,
   pi_legal_entity_id_to            IN                gmf_burden_percentages.legal_entity_id%TYPE,
   pi_calendar_code_to              IN                cm_cldr_hdr.calendar_code%TYPE,
   pi_period_code_to                IN                cm_cldr_dtl.period_code%TYPE,
   pi_cost_type_id_to               IN                cm_mthd_mst.cost_type_id%TYPE,
   pi_burden_code_from              IN                gmf_burden_codes.burden_code%TYPE,
   pi_burden_code_to                IN                gmf_burden_codes.burden_code%TYPE,
   pi_rem_repl                      IN                VARCHAR2,
   pi_all_periods_from              IN                cm_cldr_dtl.period_code%TYPE,
   pi_all_periods_to                IN                cm_cldr_dtl.period_code%TYPE
   );

END GMF_COPY_PERCENTAGE_BURDEN;

 

/
