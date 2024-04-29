--------------------------------------------------------
--  DDL for Package Body BIM_LOAD_FACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_LOAD_FACTS" AS
/* $Header: bimldfab.pls 120.1 2005/06/06 15:05:14 appldev  $*/

--g_pkg_name  CONSTANT  VARCHAR2(20) :='BIM_LOAD_FACTS';
--G_FILE_NAME CONSTANT  VARCHAR2(20) :='bimldfab.pls';

PROCEDURE invoke_object
   (ERRBUF                  OUT NOCOPY VARCHAR2,
    RETCODE		    OUT NOCOPY NUMBER,
    p_api_version_number    IN   NUMBER	,
    p_object                IN   VARCHAR2  DEFAULT NULL,
    p_mode                  IN   VARCHAR2  DEFAULT NULL,
    p_start_date            IN   DATE      DEFAULT NULL,
    p_end_date              IN   DATE      DEFAULT NULL,
    p_proc_num              IN   NUMBER    DEFAULT 8
    ) IS


BEGIN

NULL;

END invoke_object;


PROCEDURE recover_object
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE		    OUT NOCOPY NUMBER,
    p_api_version_number    IN   NUMBER	,
    p_object                IN   VARCHAR2  DEFAULT NULL,
    p_date                  IN   DATE    DEFAULT SYSDATE
    ) IS


BEGIN

NULL;

END recover_object;


END bim_load_facts;

/
