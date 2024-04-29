--------------------------------------------------------
--  DDL for Package HRI_BPL_PYUGEN_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_PYUGEN_WRAPPER" AUTHID CURRENT_USER AS
/* $Header: hribpgw.pkh 115.0 2004/04/28 14:58:37 ssherloc noship $ */
--
-- User defined exceptions
--
  sub_process_not_found           EXCEPTION;
  sub_process_failed              EXCEPTION;
--

PROCEDURE process_request
  (p_collection_name     IN VARCHAR2
  ,p_business_group_id   IN VARCHAR2
  ,p_collect_from_date   IN VARCHAR2 DEFAULT TO_CHAR(NULL)
  ,p_collect_to_date     IN VARCHAR2 DEFAULT TO_CHAR(NULL)
  ,p_full_refresh        IN VARCHAR2 DEFAULT TO_CHAR(NULL)
  ,p_attribute1          IN VARCHAR2 DEFAULT TO_CHAR(NULL)
  ,p_attribute2          IN VARCHAR2 DEFAULT TO_CHAR(NULL)
  );

PROCEDURE process_request
  (errbuf                OUT NOCOPY VARCHAR2
  ,retcode               OUT NOCOPY NUMBER
  ,p_collection_name     IN VARCHAR2
  ,p_business_group_id   IN VARCHAR2
  ,p_collect_from_date   IN VARCHAR2 DEFAULT TO_CHAR(NULL)
  ,p_collect_to_date     IN VARCHAR2 DEFAULT TO_CHAR(NULL)
  ,p_full_refresh        IN VARCHAR2 DEFAULT TO_CHAR(NULL)
  ,p_attribute1          IN VARCHAR2 DEFAULT TO_CHAR(NULL)
  ,p_attribute2          IN VARCHAR2 DEFAULT TO_CHAR(NULL)
  );

END hri_bpl_pyugen_wrapper;

 

/
