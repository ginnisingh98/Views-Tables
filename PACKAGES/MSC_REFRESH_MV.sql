--------------------------------------------------------
--  DDL for Package MSC_REFRESH_MV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_REFRESH_MV" AUTHID CURRENT_USER AS
/* $Header: MSCRFMVS.pls 120.1 2005/06/19 23:03:02 appldev ship $ */

   G_SUCCESS    CONSTANT NUMBER := 0;
   G_WARNING    CONSTANT NUMBER := 1;
   G_ERROR	CONSTANT NUMBER := 2;

   SYS_YES      CONSTANT NUMBER := 1;
   SYS_NO       CONSTANT NUMBER := 2;

PROCEDURE REFRESH_MAT_VIEWS(
                      ERRBUF             OUT NOCOPY VARCHAR2, /* file.sql.39 change 4405879 */
                      RETCODE            OUT NOCOPY NUMBER, /* file.sql.39 change 4405879 */
                      p_mv_name          IN  VARCHAR2,
                      p_schema_id        IN  NUMBER DEFAULT 724);



END MSC_REFRESH_MV;
 

/
