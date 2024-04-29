--------------------------------------------------------
--  DDL for Package HRI_STRUCT_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_STRUCT_SUMMARY" AUTHID CURRENT_USER AS
/* $Header: hribstrc.pkh 115.5 2002/12/06 14:54:55 cbridge noship $ */
PROCEDURE Load_Org_Hierarchies
  (p_business_group_id       IN     NUMBER   DEFAULT NULL
  ,p_primary_hrchy_only      IN     VARCHAR2 DEFAULT 'Y'
  ,p_date                    IN     DATE     DEFAULT SYSDATE);

PROCEDURE Load_All_Org_Hierarchies;

PROCEDURE Load_All_Org_Hierarchies
  (errbuf                       OUT NOCOPY  VARCHAR2
  ,retcode                      OUT  NOCOPY NUMBER  );

PROCEDURE Load_Sup_Hierarchies
  (p_business_group_id       IN     NUMBER   DEFAULT NULL
  ,p_include_supervisor      IN     BOOLEAN  DEFAULT FALSE
  ,p_primary_ass_only        IN     VARCHAR2 DEFAULT 'Y'
  ,p_date                    IN     DATE     DEFAULT SYSDATE);

PROCEDURE Load_All_Sup_Hierarchies;

PROCEDURE Load_All_Sup_Hierarchies
  (errbuf                       OUT NOCOPY  VARCHAR2
  ,retcode                      OUT  NOCOPY NUMBER  );


PROCEDURE Load_Gen_Hierarchies
  (p_business_group_id       IN     NUMBER   DEFAULT NULL);

PROCEDURE Load_All_Gen_Hierarchies;

PROCEDURE Load_All_Gen_Hierarchies
  (errbuf                       OUT  NOCOPY VARCHAR2
  ,retcode                      OUT  NOCOPY NUMBER  );

END HRI_STRUCT_SUMMARY; -- Package Specification HRI_STRUCT_SUMMARY

 

/
