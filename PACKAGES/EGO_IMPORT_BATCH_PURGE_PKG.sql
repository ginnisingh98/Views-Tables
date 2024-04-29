--------------------------------------------------------
--  DDL for Package EGO_IMPORT_BATCH_PURGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_IMPORT_BATCH_PURGE_PKG" AUTHID CURRENT_USER as
/* $Header: EGOIPURS.pls 120.0.12010000.4 2009/11/18 06:21:46 naaddepa noship $ */

-- ****************************************************************** --
--  API name    : Ego_import_batch_purge_pkg                          --
--  Type        : Private                                             --
--  Pre-reqs    : None.                                               --
--  Parameters  :                                                     --
--       IN     :                                                     --
--                p_batch_id                 NUMBER   Required        --
--                p_purge_criteria           varchar2                 --
--
--       OUT    : retcode                    VARCHAR2(1)              --
--                error_buf                  VARCHAR2(30)             --
--  Version     :                                                     --
--                Current version       1.0                           --
--                Initial version       1.0                           --
--                                                                    --
--  Notes       :                                                      --

-- ****************************************************************** --



PROCEDURE batch_purge( err_buff OUT   NOCOPY  VARCHAR2,
                      ret_code OUT   NOCOPY  VARCHAR2,
                    p_batch_id  IN    NUMBER,
               p_purge_criteria IN    varchar2);

PROCEDURE Structure_Purge(p_batch_id IN NUMBER, p_purge_criteria IN VARCHAR2,ret_code OUT   NOCOPY  VARCHAR2, err_buff OUT NOCOPY  VARCHAR2);

PROCEDURE Item_Purge(p_batch_id IN NUMBER, p_purge_criteria IN VARCHAR2,ret_code OUT   NOCOPY  VARCHAR2, err_buff OUT NOCOPY  VARCHAR2);

PROCEDURE Purge_All(p_batch_id IN NUMBER,ret_code OUT   NOCOPY  VARCHAR2, err_buff OUT NOCOPY  VARCHAR2);

END Ego_import_batch_purge_pkg;


/
