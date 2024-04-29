--------------------------------------------------------
--  DDL for Package IGC_CBC_FUNDS_CHECKER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CBC_FUNDS_CHECKER" AUTHID CURRENT_USER AS
/* $Header: IGCBEFCS.pls 120.6.12000000.3 2007/10/05 13:11:35 mbremkum ship $ */

/* ------------------------------------------------------------------------- */
/*                                                                           */
/*  Funds Check API for CC and PSB whenever Funds Check and/or Funds         */
/*  Funds Reservation need to be performed.                                  */
/*                                                                           */
/*  This routine returns TRUE if successful; otherwise, it returns FALSE     */
/*                                                                           */
/*  In case of failure, this routine will populate the global Message Stack  */
/*  using FND_MESSAGE. The calling routine will retrieve the message from    */
/*  the Stack                                                                */
/*                                                                           */
/*  External Packages which are being invoked include :                      */
/*                                                                           */
/*            FND_*                                                          */
/*                                                                           */
/*  GL Tables which are being used include :                                 */
/*                                                                           */
/*            GL_*                                                           */
/*                                                                           */
/*  AOL Tables which are being used include :                                */
/*                                                                           */
/*            FND_*                                                          */
/*                                                                           */
/* ------------------------------------------------------------------------- */

-- Parameters   :

-- p_sobid      : set of books ID
-- p_header_id  : CC header ID
-- p_mode       : funds check mode - 'C' or 'R'
-- p_ret_status : return status of funds checking/reservation
-- p_actual_flag: 'E' for CC or 'B' for PSB

FUNCTION IGCFCK(p_sobid         IN  NUMBER,
                p_header_id     IN  NUMBER,
                p_mode          IN  VARCHAR2,
                p_actual_flag   IN  VARCHAR2,
                p_doc_type      IN  VARCHAR2,
                p_ret_status    OUT NOCOPY VARCHAR2,
                p_batch_result_code OUT NOCOPY VARCHAR2,
                p_debug         IN  VARCHAR2:=FND_API.G_FALSE,
                p_conc_proc     IN  VARCHAR2:=FND_API.G_FALSE
--                p_packet_id     IN  NUMBER DEFAULT NULL
) RETURN BOOLEAN ;
/* Function gives caller the value of Budget info required for temp JE */


/* Procuedure Gets budget information for temporary JE */
FUNCTION Get_Rank(
  p_code IN VARCHAR2)
RETURN NUMBER;

--bug 3199488
--PRAGMA RESTRICT_REFERENCES(Get_Rank,WNDS);


FUNCTION Get_Status_By_Result(
  p_result_code IN VARCHAR2)
RETURN VARCHAR2;

--bug 3199488
--PRAGMA RESTRICT_REFERENCES(Get_Status_By_Result,WNDS);

FUNCTION Get_Result_By_Rank(
  p_rank IN NUMBER)
RETURN VARCHAR2;

FUNCTION Get_Batch_Result_Code (
  p_mode              VARCHAR2,
  p_batch_result_code VARCHAR2 )
RETURN VARCHAR2;


END IGC_CBC_FUNDS_CHECKER;


 

/
