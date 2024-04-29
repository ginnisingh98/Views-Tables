--------------------------------------------------------
--  DDL for Package FND_IMP_CONV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_IMP_CONV_PKG" AUTHID CURRENT_USER AS
/* $Header: afimpconvs.pls 120.1 2005/07/02 04:36:34 appldev noship $ */

FUNCTION compare_rcsid(rcsname1 varchar2, rcsname2 varchar2) return INTEGER;
FUNCTION compare_rcsid(rcsid1 FND_IMP_RCSID, rcsid2 FND_IMP_RCSID) return INTEGER;
FUNCTION get_rcsid(rcsname varchar2) return FND_IMP_RCSID;
FUNCTION get_rcsname(rcsname varchar2) return VARCHAR2;
FUNCTION check_branching(rcsid1 FND_IMP_RCSID, rcsid2 FND_IMP_RCSID) return INTEGER;
FUNCTION check_branching(rcsname1 varchar2, rcsname2 varchar2) return INTEGER;
PROCEDURE uninstall;

END FND_IMP_CONV_PKG;

 

/
