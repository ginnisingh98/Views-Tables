--------------------------------------------------------
--  DDL for Package FV_FACTS1_GL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_FACTS1_GL_PKG" AUTHID CURRENT_USER AS
/* $Header: FVFCJCRS.pls 120.1 2005/09/09 20:58:20 sasukuma noship $ */

PROCEDURE MAIN(p_err_buff OUT NOCOPY VARCHAR2,
               p_err_code OUT NOCOPY NUMBER,
               p_sob_id IN NUMBER,
               p_period_name IN VARCHAR2,
               p_called_from_main IN VARCHAR2 DEFAULT 'N',
               p_trading_partner_att IN VARCHAR2 DEFAULT NULL);

END FV_FACTS1_GL_PKG;

 

/
