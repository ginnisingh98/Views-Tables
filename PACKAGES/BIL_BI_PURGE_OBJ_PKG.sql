--------------------------------------------------------
--  DDL for Package BIL_BI_PURGE_OBJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIL_BI_PURGE_OBJ_PKG" AUTHID CURRENT_USER AS
/*$Header: bilbprgs.pls 115.0 2003/01/27 11:14:37 rathirum noship $*/

   PROCEDURE trunc_obj( errbuf 		   IN OUT NOCOPY VARCHAR2,
                        retcode              IN OUT  NOCOPY VARCHAR2,
				p_obj_name           IN VARCHAR2
			     );

   PROCEDURE purge_obj( errbuf 		   IN OUT NOCOPY VARCHAR2,
                        retcode              IN OUT  NOCOPY VARCHAR2,
				p_obj_name           IN VARCHAR2,
				p_end_date		   IN VARCHAR2
			     );


END bil_bi_purge_obj_pkg;

 

/
