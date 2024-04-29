--------------------------------------------------------
--  DDL for Package XNP_DEF_JEOPARDY_LOGIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_DEF_JEOPARDY_LOGIC" AUTHID CURRENT_USER AS
/* $Header: XNPJTMRS.pls 120.0 2005/05/30 11:49:43 appldev noship $ */
--
--  API Name      : notify_fmc
--  Type          : Private
--  Purpose       : Starts a workflow to notify the FMC.
--   The FMC waits for a response from an FMC user
--  Parameters    : p_msg_header
--
--
PROCEDURE notify_fmc
(
	p_msg_header IN XNP_MESSAGE.MSG_HEADER_REC_TYPE
);

END XNP_DEF_JEOPARDY_LOGIC;

 

/
