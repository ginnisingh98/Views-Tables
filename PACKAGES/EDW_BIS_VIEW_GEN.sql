--------------------------------------------------------
--  DDL for Package EDW_BIS_VIEW_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_BIS_VIEW_GEN" AUTHID CURRENT_USER AS
/* $Header: EDWBISVS.pls 115.5 2002/12/06 20:14:32 arsantha ship $ */
Procedure generateAllViews(Errbuf       in out  NOCOPY Varchar2,
	                Retcode      in out  NOCOPY Varchar2,
			p_object_long_name in   varchar2 default null);

Procedure generateOneView(p_view_name IN VARCHAR2);


END EDW_BIS_VIEW_GEN;

 

/
