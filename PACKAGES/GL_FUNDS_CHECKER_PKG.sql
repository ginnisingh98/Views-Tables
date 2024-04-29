--------------------------------------------------------
--  DDL for Package GL_FUNDS_CHECKER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_FUNDS_CHECKER_PKG" AUTHID CURRENT_USER AS
/* $Header: glfbcfcs.pls 120.2 2002/11/13 04:18:19 djogg ship $ */

  -- Funds Checker Main Routine

  FUNCTION glxfck(p_sobid             IN  NUMBER,
                  p_packetid          IN  NUMBER,
                  p_mode              IN  VARCHAR2 DEFAULT 'C',
                  p_partial_resv_flag IN  VARCHAR2 DEFAULT 'N',
                  p_override          IN  VARCHAR2 DEFAULT 'N',
                  p_conc_flag         IN  VARCHAR2 DEFAULT 'N',
                  p_user_id           IN  NUMBER DEFAULT NULL,
                  p_user_resp_id      IN  NUMBER DEFAULT NULL,
                  p_return_code       OUT NOCOPY VARCHAR2) RETURN BOOLEAN;


  -- Purge Packets after Funds Check

  PROCEDURE glxfpp(p_packetid IN NUMBER,
                   p_packetid_ursvd IN NUMBER DEFAULT 0);


  -- Get Debug Information

  FUNCTION get_debug RETURN VARCHAR2;


END GL_FUNDS_CHECKER_PKG;

 

/
