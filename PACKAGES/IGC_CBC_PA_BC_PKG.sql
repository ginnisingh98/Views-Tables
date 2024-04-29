--------------------------------------------------------
--  DDL for Package IGC_CBC_PA_BC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CBC_PA_BC_PKG" AUTHID CURRENT_USER AS
/* $Header: IGCBPBCS.pls 120.4.12000000.3 2007/10/08 03:55:25 mbremkum ship $ */

FUNCTION IGCPAFCK(
   p_sobid             IN  NUMBER,
   p_header_id         IN  NUMBER,
   p_mode              IN  VARCHAR2,
   p_actual_flag       IN  VARCHAR2,
   p_doc_type          IN  VARCHAR2,
   p_ret_status        OUT NOCOPY VARCHAR2,
   p_batch_result_code OUT NOCOPY VARCHAR2,
   p_debug             IN  VARCHAR2:=FND_API.G_FALSE,
   p_conc_proc         IN  VARCHAR2:=FND_API.G_FALSE
--   p_packet_id         IN  NUMBER DEFAULT NULL
) RETURN BOOLEAN ;


END IGC_CBC_PA_BC_PKG;

 

/
