--------------------------------------------------------
--  DDL for Package GMFARUPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMFARUPD" AUTHID CURRENT_USER AS
/* $Header: gmfarups.pls 120.2 2005/09/20 13:01:18 rseshadr noship $ */
PROCEDURE glarupd (
    errbuf              OUT NOCOPY VARCHAR2,
    retcode             OUT NOCOPY NUMBER,
    p_co_code		IN VARCHAR2,
    pf_orgn_code	IN VARCHAR2 DEFAULT NULL,
    pt_orgn_code	IN VARCHAR2 DEFAULT NULL,
    pf_bol_no		IN VARCHAR2 DEFAULT NULL,
    pt_bol_no		IN VARCHAR2 DEFAULT NULL);
END GMFARUPD;

 

/
