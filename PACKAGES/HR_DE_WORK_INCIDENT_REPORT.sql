--------------------------------------------------------
--  DDL for Package HR_DE_WORK_INCIDENT_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DE_WORK_INCIDENT_REPORT" AUTHID CURRENT_USER AS
  /* $Header: pedewinr.pkh 115.4 2002/11/26 16:33:27 jahobbs noship $ */
  --
  --
  -- Outputs work incidents.
  --
  PROCEDURE run_report
  (errbuf              OUT NOCOPY VARCHAR2
  ,retcode             OUT NOCOPY VARCHAR2
  ,p_business_group_id  IN NUMBER
  ,p_from_date          IN VARCHAR2
  ,p_to_date            IN VARCHAR2);
END;

 

/
