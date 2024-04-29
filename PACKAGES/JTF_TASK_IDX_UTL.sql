--------------------------------------------------------
--  DDL for Package JTF_TASK_IDX_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_IDX_UTL" AUTHID CURRENT_USER AS
/* $Header: jtfptkis.pls 115.2 2003/05/08 18:48:42 cjang noship $ */

    PROCEDURE sync_index(errbuf  OUT NOCOPY VARCHAR2
                        ,retcode OUT NOCOPY NUMBER);

END JTF_TASK_IDX_UTL;

 

/
