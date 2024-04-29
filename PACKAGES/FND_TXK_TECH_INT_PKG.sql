--------------------------------------------------------
--  DDL for Package FND_TXK_TECH_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_TXK_TECH_INT_PKG" AUTHID CURRENT_USER AS
/* $Header: fndtxk01s.pls 120.0.12010000.3 2009/09/07 21:49:43 upinjark noship $ */

FUNCTION store_into_fnd_preference (p_file_id NUMBER)
RETURN NUMBER ;


FUNCTION store_into_fnd_lob ( p_args_table IN FND_TXK_BPEL_ARGS_TYPE)
RETURN NUMBER;

FUNCTION remove_bpel_info_if_exists
RETURN NUMBER ;


PROCEDURE store_bpel_info ( errbuf            OUT NOCOPY VARCHAR2,
                            retcode           OUT NOCOPY NUMBER,
                            p_args_table      IN  FND_TXK_BPEL_ARGS_TYPE
                          );


END FND_TXK_TECH_INT_PKG;

/
