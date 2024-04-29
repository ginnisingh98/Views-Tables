--------------------------------------------------------
--  DDL for Package IGC_PSB_COMMITMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_PSB_COMMITMENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: IGCVWCLS.pls 120.5.12000000.4 2007/11/19 08:58:08 mbremkum ship $ */

FUNCTION Is_Cbc_Enabled
( p_set_of_books_id IN NUMBER
) RETURN VARCHAR2;

/*Added for Base Bug 6634822. Also refer Bug 6636273 and 6636531 - Start*/

FUNCTION IGCFCK_WRAPPER(
   p_sobid             IN  NUMBER,
   p_header_id         IN  NUMBER,
   p_mode              IN  VARCHAR2,
   p_actual_flag       IN  VARCHAR2,
   p_doc_type          IN  VARCHAR2,
   p_ret_status        OUT NOCOPY VARCHAR2,
   p_batch_result_code OUT NOCOPY VARCHAR2,
   p_debug             IN  VARCHAR2:=FND_API.G_FALSE,
   p_conc_proc         IN  VARCHAR2:=FND_API.G_FALSE
) RETURN BOOLEAN;

/*Added for Base Bug 6634822. Also refer Bug 6636273 and 6636531 - End*/

END IGC_PSB_COMMITMENTS_PVT;


 

/
