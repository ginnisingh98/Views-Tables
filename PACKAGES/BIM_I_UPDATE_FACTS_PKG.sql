--------------------------------------------------------
--  DDL for Package BIM_I_UPDATE_FACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_I_UPDATE_FACTS_PKG" AUTHID CURRENT_USER AS
/*$Header: bimiulms.pls 120.5 2005/10/11 05:38:27 sbassi noship $*/

 G_PKG_NAME CONSTANT VARCHAR2(30) := 'BIM_I_UPDATE_FACTS_PKG';

 PROCEDURE INVOKE_BUDGET_F
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER    DEFAULT 1,
    p_start_date            IN   DATE      DEFAULT NULL,
    p_proc_num              IN   NUMBER    DEFAULT 8,
    p_truncate_flg	    IN	 VARCHAR2
    );
PROCEDURE INVOKE_BUDGET_I
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER    DEFAULT 1,
    p_proc_num              IN   NUMBER    DEFAULT 8
    );

 PROCEDURE INVOKE_MARKETING_F
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER    DEFAULT 1,
    p_start_date            IN   DATE      DEFAULT NULL,
    p_proc_num              IN   NUMBER    DEFAULT 8,
    p_truncate_flg	    IN	 VARCHAR2
    );

 PROCEDURE INVOKE_MARKETING_I
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER    DEFAULT 1,
    p_proc_num              IN   NUMBER    DEFAULT 8
    );

 PROCEDURE INVOKE_LEADS_F
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER    DEFAULT 1,
    p_start_date            IN   DATE      DEFAULT NULL,
    p_proc_num              IN   NUMBER    DEFAULT 8,
    p_truncate_flg	    IN	 VARCHAR2
    );

 PROCEDURE INVOKE_LEADS_I
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER    DEFAULT 1,
    p_proc_num              IN   NUMBER    DEFAULT 8
    );

 PROCEDURE INVOKE_SOURCE_CODES_F
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER    DEFAULT 1,
    p_start_date            IN   DATE      DEFAULT NULL,
    p_proc_num              IN   NUMBER    DEFAULT 8,
    p_truncate_flg	    IN	 VARCHAR2
    );

 PROCEDURE INVOKE_SOURCE_CODES_I
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER    DEFAULT 1,
    p_proc_num              IN   NUMBER    DEFAULT 8
    );

 PROCEDURE INVOKE_SGMT_F
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER    DEFAULT 1,
    p_start_date            IN   DATE      DEFAULT NULL,
    p_proc_num              IN   NUMBER    DEFAULT 8,
	p_truncate_flg			IN	 VARCHAR2
    );

 PROCEDURE INVOKE_SGMT_I
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER    DEFAULT 1,
    p_proc_num              IN   NUMBER    DEFAULT 8
    );

 PROCEDURE INVOKE_SGMT_ACT_F
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER    DEFAULT 1,
    p_start_date            IN   DATE      DEFAULT NULL,
    p_proc_num              IN   NUMBER    DEFAULT 8,
    p_truncate_flg          IN	 VARCHAR2
    );

 PROCEDURE INVOKE_SGMT_ACT_I
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER    DEFAULT 1,
    p_proc_num              IN   NUMBER    DEFAULT 8
    );

 PROCEDURE INVOKE_SGMT_CUST_F
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER    DEFAULT 1,
    p_start_date            IN   DATE      DEFAULT NULL,
    p_proc_num              IN   NUMBER    DEFAULT 8,
    p_truncate_flg          IN	 VARCHAR2
    );

 PROCEDURE INVOKE_SGMT_CUST_I
   (ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  NUMBER,
    p_api_version_number    IN   NUMBER    DEFAULT 1,
    p_proc_num              IN   NUMBER    DEFAULT 8
    );

END BIM_I_UPDATE_FACTS_PKG;

 

/
