--------------------------------------------------------
--  DDL for Package IGS_AS_INCOMP_GRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_INCOMP_GRADE" AUTHID CURRENT_USER AS
/* $Header: IGSAS41S.pls 115.2 2002/11/28 22:49:37 nsidana noship $ */

PROCEDURE incomp_grade_process(
  	errbuf  	OUT NOCOPY  VARCHAR2,
  	retcode 	OUT NOCOPY  NUMBER  );

END IGS_AS_INCOMP_GRADE ;

 

/
