--------------------------------------------------------
--  DDL for Package Body JTF_TASK_IDX_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_IDX_UTL" AS
/* $Header: jtfptkib.pls 115.4 2004/06/01 20:53:25 sachoudh noship $ */

    PROCEDURE sync_index(errbuf  OUT NOCOPY VARCHAR2
                        ,retcode OUT NOCOPY NUMBER)
    IS
         l_return_status BOOLEAN;
         l_status        VARCHAR2(1);
         l_oracle_schema VARCHAR2(30);
         l_industry      VARCHAR2(1);
    BEGIN
         l_return_status := FND_INSTALLATION.GET_APP_INFO(
         application_short_name => 'JTF',
         status                 => l_status,
         industry               => l_industry,
         oracle_schema          => l_oracle_schema);

         if (NOT l_return_status) or (l_oracle_schema IS NULL)
         then
         -- defaulted to the JTF
         l_oracle_schema := 'JTF';
         end if;

         retcode := 0;
         --ad_ctx_ddl.sync_index(idx_name => 'JTF.JTF_TASKS_TL_IM');
         ad_ctx_ddl.sync_index(idx_name => l_oracle_schema||'.JTF_TASKS_TL_IM');
    EXCEPTION
        WHEN OTHERS THEN
            errbuf := SUBSTR(SQLERRM, 1, 80);
            retcode := 2;
    END sync_index;

END JTF_TASK_IDX_UTL;

/
