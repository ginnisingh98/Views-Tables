--------------------------------------------------------
--  DDL for Package XTR_DNM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_DNM_PKG" AUTHID CURRENT_USER AS
/* $Header: xtrdnmps.pls 115.3 2002/03/08 17:34:46 pkm ship      $ */
PROCEDURE AUTHORIZE(p_batch_id in NUMBER);
PROCEDURE UNAUTHORIZE(p_batch_id in NUMBER);

END XTR_DNM_PKG;

 

/
